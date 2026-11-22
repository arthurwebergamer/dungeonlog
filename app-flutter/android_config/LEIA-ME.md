# Configuração Android (Firebase)

- `google-services.json`: config do app Android `com.dungeonlog.dungeonlog_flutter` no projeto Firebase `questlog-d4c11`
  (não é segredo: são identificadores públicos, o mesmo tipo de dado que o app HTML já expõe).
- `teste.keystore`: chave de assinatura **só dos APKs de teste** (a debug padrão do Android: alias `androiddebugkey`,
  senha `android`). O SHA-1 dela (`EA:F4:97:D8:82:93:04:87:DF:57:21:29:DD:97:8E:97:20:BA:9B:18`) está cadastrado no
  Firebase para o login com Google. **Nunca usar na publicação na Play Store** (a Fase 8 terá a chave de lançamento).
- `preparar_android.sh <pasta>`: roda no CI (e na reprodução local) logo depois do `flutter create`, que gera um projeto Android
  novo a cada build. Copia estes dois arquivos para `android/app/`, aplica o plugin `com.google.gms.google-services` nos
  `.gradle.kts` gerados, cria o `signingConfig` "teste" (esta keystore) para o release e desliga o `lintVital` do release
  (o lint do AGP 9 quebra no `firebase_core`). Se algum padrão esperado dos arquivos gerados não for achado, o script
  **falha** (e o CI para antes do build). O CI ainda confere o SHA-1 do APK no fim.
