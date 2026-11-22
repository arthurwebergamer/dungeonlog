#!/usr/bin/env bash
# Prepara o projeto Android gerado por `flutter create` (o CI gera um novo a cada build) para o Firebase e para a
# assinatura fixa de teste. Uso: preparar_android.sh <pasta-do-projeto-flutter>
#
# O que faz (e FALHA ALTO, sem build, se algum padrao do arquivo gerado nao for encontrado):
#   1. copia google-services.json e teste.keystore para android/app/
#   2. declara o plugin com.google.gms.google-services em android/settings.gradle.kts
#   3. aplica o plugin em android/app/build.gradle.kts
#   4. desliga o lintVital do release (o lint do AGP 9 trava no firebase_core; APK de teste nao precisa dele)
#   5. cria o signingConfig "teste" (teste.keystore) e o usa no buildType release (o SHA-1 do APK fica fixo)
set -euo pipefail

raiz="${1:?uso: preparar_android.sh <pasta-do-projeto-flutter>}"
cfg="$(cd "$(dirname "$0")" && pwd)"
settings="$raiz/android/settings.gradle.kts"
appgradle="$raiz/android/app/build.gradle.kts"

falhar() { echo "preparar_android: $*" >&2; exit 1; }

[ -f "$settings" ] || falhar "nao achei $settings (o flutter create passou a gerar .gradle em vez de .gradle.kts? ajuste este script)"
[ -f "$appgradle" ] || falhar "nao achei $appgradle (o flutter create passou a gerar .gradle em vez de .gradle.kts? ajuste este script)"
[ -f "$cfg/google-services.json" ] || falhar "faltou $cfg/google-services.json"
[ -f "$cfg/teste.keystore" ] || falhar "faltou $cfg/teste.keystore"

# no Windows o flutter create gera CRLF; o Gradle aceita LF e os padroes abaixo ficam mais simples
sed -i 's/\r$//' "$settings" "$appgradle"

# insere $3 (uma linha) depois da UNICA linha que casa com o regex $2 em $1
inserir_apos() {
  local arq="$1" padrao="$2" texto="$3" n
  n=$(grep -c -E "$padrao" "$arq" || true)
  [ "$n" = "1" ] || falhar "esperava 1 linha casando /$padrao/ em $arq e achei $n"
  sed -i -E "/$padrao/a\\
$texto" "$arq"
}

# insere $3 (uma linha) antes da UNICA linha que casa com o regex $2 em $1
inserir_antes() {
  local arq="$1" padrao="$2" texto="$3" n
  n=$(grep -c -E "$padrao" "$arq" || true)
  [ "$n" = "1" ] || falhar "esperava 1 linha casando /$padrao/ em $arq e achei $n"
  sed -i -E "/$padrao/i\\
$texto" "$arq"
}

exigir() { grep -q -F "$2" "$1" || falhar "depois da edicao nao achei \"$2\" em $1"; }

cp "$cfg/google-services.json" "$raiz/android/app/google-services.json"
cp "$cfg/teste.keystore" "$raiz/android/app/teste.keystore"

# 2. plugin declarado (versao do plugin do Google Services)
inserir_apos "$settings" '^[[:space:]]*id\("com\.android\.application"\) version' '    id("com.google.gms.google-services") version "4.4.4" apply false'
exigir "$settings" 'id("com.google.gms.google-services") version "4.4.4" apply false'

# 3. plugin aplicado no app (depois do plugin do Flutter, que tem de vir por ultimo entre os do Android/Kotlin)
inserir_apos "$appgradle" '^[[:space:]]*id\("dev\.flutter\.flutter-gradle-plugin"\)' '    id("com.google.gms.google-services")'
exigir "$appgradle" 'id("com.google.gms.google-services")'

# 4. assinatura fixa: signingConfig "teste" antes do buildTypes e release usando-o em vez do debug da maquina
inserir_antes "$appgradle" '^[[:space:]]*buildTypes[[:space:]]*\{' '    signingConfigs {\
        create("teste") {\
            storeFile = file("teste.keystore")\
            storePassword = "android"\
            keyAlias = "androiddebugkey"\
            keyPassword = "android"\
        }\
    }\
'
n=$(grep -c -F 'signingConfig = signingConfigs.getByName("debug")' "$appgradle" || true)
[ "$n" = "1" ] || falhar "esperava 1 ocorrencia de signingConfig = signingConfigs.getByName(\"debug\") em $appgradle e achei $n"
sed -i 's/signingConfig = signingConfigs.getByName("debug")/signingConfig = signingConfigs.getByName("teste")/' "$appgradle"
exigir "$appgradle" 'signingConfig = signingConfigs.getByName("teste")'
exigir "$appgradle" 'create("teste")'

# lint: o assembleRelease roda o lintVital em cada plugin e ele quebra no firebase_core (NoSuchMethodError no JavaDocParser)
raizgradle="$raiz/android/build.gradle.kts"
[ -f "$raizgradle" ] || falhar "nao achei $raizgradle"
sed -i 's/\r$//' "$raizgradle"
grep -q -F 'subprojects {' "$raizgradle" || falhar "esperava um bloco subprojects em $raizgradle (o flutter create mudou?)"
cat >> "$raizgradle" <<'GRADLE'

// APK de teste: o lintVital do release (AGP 9) quebra com NoSuchMethodError no firebase_core, entao fica desligado
allprojects {
    tasks.configureEach {
        if (name.startsWith("lintVital")) {
            enabled = false
        }
    }
}
GRADLE
exigir "$raizgradle" 'name.startsWith("lintVital")'

# minSdk: o Firebase Auth pede 23 e o Flutter ja usa 24 (flutter.minSdkVersion). Garante que ninguem baixou isso.
grep -q -F 'minSdk = flutter.minSdkVersion' "$appgradle" || falhar "minSdk nao e mais flutter.minSdkVersion em $appgradle: confira se continua >= 23"

echo "preparar_android: ok ($raiz)"
