# Fase 6, parte A: conta (login, cadastro, Google, sair, excluir) e build com Firebase

**Só autenticação e build.** A sincronização do save com a nuvem (Firestore) é a parte B e NÃO foi feita.

## O que foi feito
- **Pacotes** (`pubspec.yaml`): `firebase_core ^5.2.0`, `firebase_auth ^7.1.0`, `google_sign_in ^7.2.0` (`flutter pub get` resolve em Flutter 3.50 / Dart 3.14).
- **CI** (`.github/workflows/flutter-apk.yml` + `android_config/preparar_android.sh`): depois do `flutter create`, o script copia `google-services.json` e `teste.keystore`, aplica o plugin `com.google.gms.google-services` (declarado em `settings.gradle.kts`, aplicado em `app/build.gradle.kts`), cria o `signingConfig` "teste" para o release e **falha alto** se algum padrão esperado não for achado (testado com 3 projetos falsos: Groovy, sem plugin application, sem buildTypes). O retry do build foi mantido. No fim o CI confere o SHA-1 do APK e para se não for o esperado.
  - **Achado:** o `assembleRelease` falhava no `lintVitalAnalyzeRelease` do `firebase_core` (bug do lint do AGP 9: `NoSuchMethodError` no `JavaDocParser`; reproduziu nas 2 tentativas). O script agora desliga as tarefas `lintVital*` (`android/build.gradle.kts`). Sem isso o CI quebraria.
  - `minSdk` não precisou mudar: o Flutter já usa 24 (`flutter.minSdkVersion`) e o Firebase Auth pede 23. O script falha se isso deixar de ser verdade.
  - O APK só tem assinatura v2 (minSdk 24), então `keytool -jarfile` não serve ("não é um jar assinado"); a conferência usa o `apksigner` do SDK.
- **Camada de conta** (`lib/dados/`): `conta.dart` (interface `ServicoConta`, `UsuarioConta`, `ErroConta`, mensagens PT/EN idênticas às do HTML, regra de senha), `conta_firebase.dart` (implementação real, só o `main.dart` importa), `conta_falsa.dart` (`ServicoContaFalso` para testes, `ServicoContaIndisponivel` quando o Firebase não inicia). Funções: cadastrar (manda e-mail de confirmação), entrar, Google (web client ID do HTML como `serverClientId`), redefinir senha, sair, excluir (reautentica; gancho `apagarNuvem` para a parte B), observar usuário, reenviar confirmação, recarregar, "e-mail errado, corrigir".
- **EstadoJogo**: `uid` agora muda (`entrarNaConta`, `sairDaConta`, `aposExcluirConta`, `abrirDonoAtual`). A raiz (`app.dart`) abre direto na conta se a sessão do Firebase foi restaurada.
- **Telas**: login/cadastro/Google/esqueci a senha de verdade em `onboarding.dart` (validações, check/X da senha em tempo real, erro embaixo do campo, tela de carregando "bonequinho correndo" com frases e o estado "Algo deu errado / Tentar de novo"), "Bem-vindo de volta", trava "Confirme seu e-mail" (confere a cada 4 s), Configurações > Conta ("Logado como", Criar conta, Sair, Excluir conta com folha de confirmação, senha ou Google). Peças novas em `lib/ui/login_conta.dart`. A folha usa `abrirFolha`; sem `BackdropFilter`.

## Regra local de troca de conta (o `aoLogar` do HTML, sem rede)
- Veio do convidado (`questlog.convidado.v1`) **e** a conta é nova (`creationTime == lastSignInTime`): as chaves sem `.uid.` terminadas em `.pj.<id>` e as listas `questlog.personagens.v1` / `questlog.personagemAtivo.v1` são copiadas para `...uid.<uid>...` (só se o destino não existir) e as cruas são apagadas.
- Conta que já existe: **nada** do convidado é copiado (fica guardado, cru). A marca de convidado sai nos dois casos.
- Depois abre o herói ativo da conta; com save → "Bem-vindo de volta", sem save → escolher herói.
- Sair: volta ao jogo local sem conta (as chaves da conta ficam no aparelho, como no HTML) e abre o login.
- Excluir: apaga do aparelho só as chaves `.uid.<uid>` (o HTML faz `localStorage.clear()` inteiro; aqui não apaga idioma, tema, convidado etc.).

## Como foi verificado
- `flutter test`: **1901 testes verdes** (eram ~1853; 48 novos em `test/conta_test.dart` e `test/conta_telas_test.dart`: mensagens, serviço falso, regras de troca de dono, todas as telas e fluxos com o serviço falso, inglês, carregando/erro, excluir). Mutação feita e revertida: copiar o convidado para conta que já existe (o teste falhou). Teste antigo de "Disponível em breve" do Google foi removido.
- `flutter analyze`: 0 erros (os avisos restantes são os antigos do projeto).
- **Reprodução local do CI**: o script `repro_ci.sh` é gerado a partir do próprio `run:` do workflow (só troca os caminhos): `flutter create` + cópias + `preparar_android.sh` + `pub get` + `flutter build apk --release` numa pasta nova. Resultado: APK de ~55 MB; `apksigner verify --print-certs`: SHA-1 `eaf497d882930487df572129dd978e9720ba9b18` (= `EA:F4:97:D8:82:93:04:87:DF:57:21:29:DD:97:8E:97:20:BA:9B:18`), CN "Android Debug"; `aapt2 dump badging`: minSdk 24, permissão INTERNET presente.

## NÃO verificado
- Login real (Google, e-mail/senha, e-mail de redefinição, e-mail de confirmação, excluir no servidor): só no celular com rede. Nenhuma chamada real ao Firebase foi feita.
- Se o Firebase Auth aceita este APK sem exigir mais nada (SHA-256, Play Integrity/reCAPTCHA para e-mail/senha): só testando.
- Se o Google Sign-In no Android funciona com o `serverClientId` e o SHA-1 cadastrado: só no celular.
- O workflow rodando de verdade no GitHub (runner Linux): reproduzido no Windows com os mesmos comandos; diferenças possíveis: `apksigner` (no Linux o arquivo é `apksigner`, no Windows `.bat`; o workflow usa o sem extensão) e versão do Flutter do `subosito/flutter-action` (canal stable, pode ser mais nova que a 3.50 local).
- Visual comparado lado a lado com o HTML: não feito nesta rodada (as telas seguem textos, medidas e cores já usados na Fase 5; "Bem-vindo de volta", confirmar e-mail e a folha de excluir foram feitas do CSS lido, sem captura).

## Diferenças em relação ao HTML
- Sem a caixa "Li e concordo" do cadastro (só a linha "Ao continuar..." como na Fase 5).
- A trava de e-mail do HTML tem 10 min de tolerância na sessão aberta; aqui a trava é imediata ao entrar e ao abrir o app (é o que o HTML faz no login e na abertura).
- "Sair" não espera envio à nuvem nem remove token de push (não existem ainda).
- O toast "Conta criada! Enviamos um link..." não existe (no HTML `aviso()` está mudo).

## Decisões para a parte B (sincronização)
1. **Convidado com progresso entra em conta que já existe**: no HTML a nuvem da conta vence e o jogo do convidado fica cru no aparelho. Aqui o convidado fica cru e a conta, sem save local, cai em "escolher herói" (**não há save nenhum, nem puxado da nuvem**). A parte B precisa **puxar a nuvem ANTES** de decidir entre "Bem-vindo de volta" e "escolher herói" (hoje `entrarNaConta` decide só pelo que há local) e decidir o que fazer com o jogo do convidado (merge por data? perguntar?). O HTML registra a mesma pendência (secão 37). Não inventei regra.
2. **Conta que já existe + save local diferente do da nuvem** (outro aparelho): HTML puxa a nuvem por cima. Falta timestamp/merge (o save v3 tem `salvoEm`).
3. **Excluir conta**: o HTML apaga `saves/{uid}` no Firestore antes de `deleteUser`. Aqui há o gancho `ServicoContaFirebase.iniciar(apagarNuvem: (uid) async {...})`, ainda sem uso. **Sem isso um save criado pelo app HTML na mesma conta fica órfão no Firestore** ao excluir pelo app Flutter.
4. **Migração do legado** (`questlog.v1` sem `.pj.`, `legadoMigrado`): não se aplica ao Flutter (chaves novas); só importa se a parte B importar saves do HTML.
5. O HTML sobe o save a cada `salvar()` e marca "sujo"; no Flutter o gancho natural é `EstadoJogo._salvarTudo` (só grava com `uid != null`, e `onboardingPendente` suspende a gravação).
6. `UsuarioConta.contaNova` vem de `creationTime == lastSignInTime` (precisão de segundos), igual ao HTML; ao logar de novo no mesmo aparelho logo depois de criar, vira false.
