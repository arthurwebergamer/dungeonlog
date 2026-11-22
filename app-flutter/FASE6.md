# Fase 6, parte A: conta (login, cadastro, Google, sair, excluir) e build com Firebase

**Parte A: só autenticação e build.** A sincronização do save com a nuvem (Firestore) é a **parte B**, no fim deste arquivo.

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

## Decisões para a parte B (sincronização) — todas resolvidas na parte B, abaixo
1. **Convidado com progresso entra em conta que já existe**: no HTML a nuvem da conta vence e o jogo do convidado fica cru no aparelho. Aqui o convidado fica cru e a conta, sem save local, cai em "escolher herói" (**não há save nenhum, nem puxado da nuvem**). A parte B precisa **puxar a nuvem ANTES** de decidir entre "Bem-vindo de volta" e "escolher herói" (hoje `entrarNaConta` decide só pelo que há local) e decidir o que fazer com o jogo do convidado (merge por data? perguntar?). O HTML registra a mesma pendência (secão 37). Não inventei regra.
2. **Conta que já existe + save local diferente do da nuvem** (outro aparelho): HTML puxa a nuvem por cima. Falta timestamp/merge (o save v3 tem `salvoEm`).
3. **Excluir conta**: o HTML apaga `saves/{uid}` no Firestore antes de `deleteUser`. Aqui há o gancho `ServicoContaFirebase.iniciar(apagarNuvem: (uid) async {...})`, ainda sem uso. **Sem isso um save criado pelo app HTML na mesma conta fica órfão no Firestore** ao excluir pelo app Flutter.
4. **Migração do legado** (`questlog.v1` sem `.pj.`, `legadoMigrado`): não se aplica ao Flutter (chaves novas); só importa se a parte B importar saves do HTML.
5. O HTML sobe o save a cada `salvar()` e marca "sujo"; no Flutter o gancho natural é `EstadoJogo._salvarTudo` (só grava com `uid != null`, e `onboardingPendente` suspende a gravação).
6. `UsuarioConta.contaNova` vem de `creationTime == lastSignInTime` (precisão de segundos), igual ao HTML; ao logar de novo no mesmo aparelho logo depois de criar, vira false.

---

# Fase 6, parte B: sincronização do save com a nuvem (Firestore)

Compatível com o app HTML (mesmo projeto `questlog-d4c11`, mesmos documentos, mesmo JSON): uma conta pode alternar entre os dois apps.

## O que foi feito
- **Pacote:** `cloud_firestore ^7.2.0` (resolve com `firebase_core 5.2`/`firebase_auth 7.1`, Flutter 3.50). O plugin **não exigiu mudança** no gradle, no `minSdk` (24) nem em `preparar_android.sh`: o build do CI foi reproduzido sem tocar no script (ver "Como foi verificado").
- **Arquivos novos:** `lib/dominio/nuvem.dart` (regras PURAS: formato, `extras`, regra de decisão, histórico, entitlements), `lib/dados/nuvem.dart` (interface `RepositorioNuvem` + `RepositorioNuvemMemoria` para testes, que simula a regra "só o dono"), `lib/dados/nuvem_firestore.dart` (o Firestore de verdade; só o `main.dart` importa), `lib/dados/sincronizador_nuvem.dart` (o motor: decide, coalesce, envia, tenta de novo), `tools/gerar_casos_nuvem.mjs` + `test/fixtures/casos_nuvem_js.json`, `test/nuvem_paridade_test.dart`, `test/nuvem_test.dart`.
- **Ligações:** `EstadoJogo` (marca "sujo" a cada alteração real, `entrarNaConta` lê a nuvem antes de abrir os dados, `sincronizarAoAbrir`, `sairDaConta` espera o envio, `excluirConta`), `app.dart` (cria o motor, lê a nuvem antes de abrir os dados quando a sessão foi restaurada, ciclo de vida do app), `main.dart` (Firestore + gancho `apagarNuvem`), `login_conta.dart` (excluir passa por `EstadoJogo.excluirConta`), `conta_falsa.dart` (gancho `apagarNuvem` igual ao do serviço real, para teste).

### Formato (igual ao HTML)
| Documento | Campos | Quem grava |
|---|---|---|
| `saves/{uid}` | `data` (texto do save v3 do herói ATIVO, sem mexer), `extras` ({chave: texto}), `atualizadoEm` (ms) e **`pj`** (id do herói; só o Flutter grava, o HTML ignora e o apaga ao gravar) | os dois apps |
| `saves/{uid}/historico/h0..h5` | `{data, extras, em}`: a cada 30 min, rodando (`n % 6`) | os dois |
| `saves/{uid}/historico/d0..d13` | `{data, extras, em}`: 1x por dia UTC (`dia % 14`) | os dois |
| `entitlements/{uid}` | `proVitalicio`, `assinaturaAte`, `assinaturaProduto` | **só leitura** → `EstadoJogo.ehPro` (sem paywall; Fase 7) |

- **`extras`** = as chaves de `CHAVES_SECUNDARIAS_CONTA` do HTML (20, mesma ordem, conferida contra o JS no teste) do herói ativo que existem no aparelho, **menos `questlog.dia.v1`** (debug, nunca sobe nem desce). Chaves que o Flutter ainda não usa (`atrib`, `trial`, `hpMonstro`, `bauLog`, `temasDesbloqueados`...) descem e sobem de volta intactas: o HTML e as Cloud Functions (que leem `trial`/`hist`/`hpMonstro`) não perdem nada.
- Chaves locais por conta (mesmos nomes do HTML): `questlog.sujo.v1.uid.<uid>` (alteração que não chegou na nuvem), `questlog.backupLocal.v1.uid.<uid>` (3 últimas cópias do local antes de a nuvem sobrescrever), `questlog.histNuvem.v1.uid.<uid>.{h,d,n}`. Só do Flutter: `questlog.nuvemSync.v1.uid.<uid>` (este aparelho já falou com a nuvem desta conta).

### Quando lê e quando grava
- **Lê** `saves/{uid}` (sempre do SERVIDOR, nunca do cache; o cache offline do Firestore está desligado) no **login** (antes de decidir entre "Bem-vindo de volta" e "escolher herói"; espera até 10 s com a tela de carregando aberta) e ao **abrir o app com a sessão salva** (antes de abrir os dados; até 3 s, durante a abertura). Lê `entitlements/{uid}` junto.
- **Sem rede / erro:** o jogo abre e segue local; nova tentativa em 5 s, 15 s, 30 s, 1 min, 2 min, depois a cada 5 min, e ao voltar para o app. **Nada sobe antes de a nuvem ter sido lida** nesta sessão (nunca sobrescreve às cegas).
- **Grava:** cada alteração REAL do jogo marca "sujo" (como o `salvar()` do HTML) e agenda o envio com **atraso de 3 s** (várias alterações = um `setDoc`); **um envio por vez** (o que chega durante o voo sai logo depois, com o estado mais novo: fim da corrida de `setDoc` que o HTML documenta); app indo para o fundo = envia já; **Sair espera o envio (até 4 s) ANTES do `signOut`** (o comentário perto da linha 19962 do HTML: depois a regra nega). Envio confirmado sem alteração nova no meio → apaga o "sujo"; falhou → fica e tenta de novo. O toque do jogador nunca espera rede.
- Depois de cada envio bem-sucedido, o histórico (h a cada 30 min, d 1x/dia), sem esperar.
- **`salvoEm` agora só muda com alteração real** (antes o Flutter regravava tudo, com carimbo novo, a cada abertura). É isso que impede um aparelho parado de "rejuvenescer" o save velho e vencer o jogo feito em outro aparelho. Conteúdo igual com outra formatação também não conta como alteração.
- **Excluir conta:** segura os envios, reautentica, apaga `saves/{uid}` **e** os 20 documentos de histórico (um `WriteBatch`), depois o login. (O HTML só apaga `saves/{uid}`: o histórico fica órfão.)

## REGRA DE DECISÃO (local x nuvem, ao entrar)
Em `decidirNuvem` (`lib/dominio/nuvem.dart`), aplicada por `SincronizadorNuvem._aplicar`. "Começado" = JSON válido com `comecou` verdadeiro. `tL`/`tN` = `salvoEm` (`Number(...) || 0`, como o `lerSalvoEm` do HTML).

| # | Situação | HTML (`puxarNuvem`) | Flutter |
|---|---|---|---|
| 1 | "sujo" (alteração local não confirmada) e local começado | sobe o local, sem ler a nuvem | **sobe o local**; se a nuvem tinha outro save, a cópia dela vai antes para `historico/h*` (SEGURO) |
| 1' | "sujo" e local NÃO começado | sobe `data: ''`/lixo por cima da nuvem (perigoso) | SEGURO: **baixa a nuvem** (se tiver save) ou não faz nada |
| 2 | nuvem sem save começado (sem doc, `data` vazio, JSON inválido, `comecou` falso) | sem doc/vazio: nada (sobe no próximo `salvar`); inválido/não começado: pode **baixar por cima** | SEGURO: local começado **sobe já**; senão nada. Extras de uma nuvem sem save não descem |
| 3 | local sem save começado, nuvem com save | baixa (backup se havia texto); um local "não começado" com carimbo mais novo **subiria** | **baixa**, backup do texto local |
| 4 | mesmo texto | baixa (só as extras mudam) | igual ao HTML |
| 5a | os dois começados e diferentes, e **este aparelho nunca sincronizou esta conta** | (não existe) | SEGURO: vence o de **mais XP** (no jogo o XP só sobe); o outro vai para backup/histórico. Cobre o save nascido offline ou de convidado sem conhecer a nuvem |
| 5b | `tL ≠ 0`, `tN ≠ 0` e `tL > tN + 2000` | sobe o local; cópia da nuvem no histórico | igual ao HTML |
| 5c | `tL ≠ 0` e `tN == 0` (nuvem de versão antiga, sem carimbo) | baixa (backup do local) | SEGURO: **sobe o local**, cópia da nuvem no histórico |
| 5d | qualquer outro (nuvem mais nova, ou empate até 2 s) | baixa, backup do local | igual ao HTML |

Ao baixar: grava `data` e as `extras` que vieram (nunca apaga chave local que a nuvem não tinha, nunca o dia de debug) e **mescla o histórico de dias** (`questlog.hist.v1`): o da nuvem vence por data, os dias que só o aparelho tem são acrescentados e sobem de volta (generalização do `recarregarHistoricoNuvem` do HTML, que fazia isso só com os dias fechados na sessão).

**Vários heróis (f):** a nuvem guarda UM herói (o ativo; limitação do formato do HTML). O Flutter grava `pj` no documento: outro aparelho Flutter baixa no herói certo, coloca-o na lista e, se o aparelho não tem herói jogado, abre nele. Documento sem `pj` (gravado pelo HTML) desce no herói ativo do aparelho, como no HTML. Se a nuvem tem outro herói e o ativo daqui foi alterado, o outro é guardado localmente (pela regra acima) e o ativo sobe.

**Convidado com progresso entrando em conta que já existe (d)** (pendência da parte A, resolvida): a nuvem da conta tem save → ela vence (como o HTML) e o jogo do convidado fica intacto no aparelho (aparece em "Sair"). A conta confirmadamente não tem save, ou a leitura falhou → o jogo do convidado é **copiado** para a conta (as chaves cruas ficam) e sobe; se a leitura tinha falhado, a regra 5a decide depois pelo maior progresso. **Nada do convidado é apagado.** Conta nova continua como na parte A (copia e apaga as cruas, como o HTML).

**Abrir o app com a sessão salva:** o HTML NÃO lê a nuvem nesse caminho (só passa a enviar), e um aparelho parado sobe o save velho por cima do jogo feito em outro aparelho. O Flutter aplica a mesma regra do login (com a garantia de o `salvoEm` só mudar com alteração real). Se a leitura só der certo mais tarde (sem rede ao abrir) e a nuvem vencer, o jogo relê os dados na hora; se a conta estava na escolha do herói e agora tem save, entra no jogo.

## Segurança (firestore.rules)
- As regras publicadas deixam o dono ler/gravar `saves/{uid}` e `saves/{uid}/historico/*`, e só LER `entitlements/{uid}` (`allow write: if false`; o catch-all nega o resto). O app só grava nesses dois caminhos e só lê `entitlements`: **a interface `RepositorioNuvem` nem tem método para gravar entitlements**. Nenhuma regra foi alterada.
- O campo extra `pj` é permitido (as regras não validam campos).
- Nada de dados do jogador em log; erros guardam só o código (`permission-denied`, `timeout`...).
- **Sugestões para as regras (NÃO aplicadas; decidir e publicar pelo Console):** (1) validar tipos/tamanho de `saves/{uid}` (`request.resource.data.data is string`, `extras is map`) para um cliente bugado não gravar lixo; (2) nada impede o dono de editar o próprio save (trapaça na própria conta): aceitável enquanto não houver ranking.

## Como foi verificado
- `flutter test`: **2129 testes verdes** (eram 1901; +228: 199 em `nuvem_paridade_test.dart`, 29 em `nuvem_test.dart`). Nenhum inicia o Firebase.
- **Paridade com o JS real** (`node app-flutter/tools/gerar_casos_nuvem.mjs`): recorta de `play/index.html` `puxarNuvem`, `empurrarNuvem`, `guardarHistorico`, `guardarBackupLocal`, `lerSalvoEm`, `marcarSujo`, `temSujo`, `chaveSujo`, `chaveSaveAtual`, `chaveConta` e `CHAVES_SECUNDARIAS_CONTA`, roda num `vm` do Node com localStorage e Firestore falsos e grava 196 cenários (5 locais × 10 nuvens × sujo × extras), 10 de `lerSalvoEm` e 7 de `guardarHistorico`. O Dart roda os mesmos cenários no `SincronizadorNuvem`: **38 idênticos ao JS** (todos os casos de nuvem mais nova/mais velha/dentro da folga/igual sem "sujo"); os outros 158 caem em 6 classes de divergência **declaradas pela entrada** (S1 sujo sem save local, S2 sujo + cópia da nuvem no histórico, S3 nuvem sem save, S4 sobe já, S5 local lixo, S6 nuvem sem carimbo) e em cada uma o teste confere a regra segura. Em TODOS os 196: nunca sobe save não começado, save local começado nunca vira vazio, todo local sobrescrito tem backup, toda nuvem sobrescrita tem cópia no histórico, o dia de debug nunca sobe/desce. `lerSalvoEm`, a escolha de `h`/`d` do histórico e a lista de chaves são idênticas ao JS.
- **Fluxos (a)–(j)** em `nuvem_test.dart`, com `EstadoJogo` + nuvem em memória: conta nova + convidado; baixar; local mais novo/mais velho/igual; convidado em conta existente (com save na nuvem, sem save, e sem rede seguido de rede); sem rede no login; gravação negada (`permission-denied`) e nova tentativa; abrir sem rede; coalescência (8 alterações = 1 `setDoc`); abrir sem mudar nada não muda `salvoEm` nem sobe; vários heróis (Flutter→Flutter e documento do HTML); histórico h/d e mescla de dias; excluir (senha errada não apaga; apaga doc + histórico; envio pendente não recria); sair (o envio chega ANTES do `signOut`: a conta falsa faz a nuvem negar tudo ao deslogar); trocar de aparelho (A parado baixa o que B fez); Pro via entitlements.
- **Mutação** (cada uma feita e revertida, arquivo conferido com `cmp`): (1) `tL > tN + 2000` → `<`: 12 testes falharam; (2) sem o ramo "sujo sobe": 21; (3) folga 2000 → 0: 3; (4) XP invertido na regra 5a: 2; (5) `sair()` sem esperar o envio: falha o teste (i); (6) permitir envio antes de ler a nuvem: 2. (Tirar a checagem só de `alterou` não falha nada porque o envio confere de novo: redundância de propósito.)
- `flutter analyze`: 0 erros (os 60 avisos/infos são os antigos; nenhum novo).
- **Build reproduzindo o CI** (script gerado do `run:` do workflow, só com os caminhos trocados; pasta fora do repo): `flutter create` + cópias + `preparar_android.sh` (sem mudança) + `pub get` + `flutter build apk --release` → APK de ~56,2 MB (com o código final; uma 1ª rodada só com o pacote novo deu 55,6 MB); `apksigner verify --print-certs`: SHA-1 `eaf497d882930487df572129dd978e9720ba9b18` (= `EA:F4:97:D8:82:93:04:87:DF:57:21:29:DD:97:8E:97:20:BA:9B:18`).

## NÃO verificado (só no celular, com login real)
Nenhuma chamada real ao Firestore foi feita: regras publicadas, latência, o plugin sem rede e o documento visto pelo app HTML só se confirmam no aparelho. **Testes manuais para o dono** (use uma conta de TESTE):
1. **Conta nova:** jogue como convidado (crie e conclua 1 tarefa), crie a conta. No Firebase Console > Firestore > `saves` > (uid): campos `data`, `extras`, `atualizadoEm`, `pj`. Em `historico`: `h0` e um `dN`.
2. **HTML → Flutter:** no app HTML (logado nessa conta) crie uma tarefa e espere uns segundos. No Flutter: Configurações > Sair e entre de novo → a tarefa aparece ("Bem-vindo de volta").
3. **Flutter → HTML:** no Flutter crie uma tarefa e mande o app para o fundo. No HTML: Sair e entrar de novo → a tarefa aparece.
4. **Aparelho parado:** com o Flutter fechado (logado), jogue no HTML. Abra o Flutter → em até ~3 s mostra o que foi feito no HTML (e não o contrário).
5. **Sem rede:** modo avião, abra o Flutter, conclua uma tarefa, feche. Tire o modo avião e abra → no Console o `data` passa a ter a tarefa feita.
6. **Excluir conta (de teste):** Configurações > Excluir conta → no Console somem `saves/(uid)` e o `historico`.
7. **Pro:** na conta de revisor (`entitlements/(uid).proVitalicio = true`), entre → "+ Novo herói" sem o selo Pro.

## Riscos conhecidos
- **Um herói por documento** (formato do HTML): com vários heróis em aparelhos diferentes, a nuvem só tem o último ativo; os outros vivem nos aparelhos (e no histórico da nuvem). O HTML, ao ler um documento com `pj` de outro herói, ainda grava no herói ativo dele.
- **Conflito real** (os dois aparelhos alteraram sem rede): vence o "sujo" de quem entrar primeiro (regra do HTML); o save perdedor só fica em `historico/h*` (recuperar só pelo Console) ou no backup local (`questlog.backupLocal.v1.uid.<uid>`, sem tela para restaurar).
- **Relógio do aparelho** decide (folga de 2 s), como no HTML: um aparelho com o relógio muito adiantado tende a vencer.
- **O app HTML** continua com o comportamento antigo: sessão restaurada sobe o save dele sem ler a nuvem (pode passar por cima do que foi feito no Flutter; o save do Flutter fica no histórico). Não foi mexido.
- **Histórico de dias sem teto** (`questlog.hist.v1` cresce 1 entrada por dia): o documento tem limite de 1 MiB no Firestore (longe: ~70 bytes por dia).
- **Primeira abertura depois de baixar** pode subir uma vez as chaves que o Flutter cria com o valor padrão (o `data` e o `salvoEm` não mudam).
- **Abertura sem rede** espera até 3 s pela nuvem durante a tela de abertura (depois segue local).
- **Releitura em segundo plano** (só quando a nuvem é lida mais tarde e vence) troca a tela por baixo do jogador; o local fica no backup.
- **Excluir** pelo app HTML continua deixando o `historico` órfão (só o Flutter apaga tudo).
