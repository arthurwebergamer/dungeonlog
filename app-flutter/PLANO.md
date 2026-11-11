# Reescrita em Flutter: inventário e plano (2026-11-11)

Motivo: no POCO X4 GT o protótipo Flutter (branch `flutter-teste`, build 181d74d) ficou claramente mais fluido que o Capacitor/WebView. Este documento lista o que existe no app atual e a ordem de portagem.

## Decisões do dono (2026-11-11)

1. O app atual (HTML/TWA) **continua na Play Store** e segue recebendo correções. O Flutter é construído em paralelo. Qualquer mudança feita no HTML nesse período deve ser anotada em `app-flutter/PARIDADE.md`, para o Flutter alcançar depois.
2. Ordem: **núcleo jogável (aba Tarefas) primeiro, conta depois.**
3. **CRT e temas de cor entram na versão final** (fases 3 e 8), não na primeira.

## Como trabalhar (o dono não tem computador)

- Tudo é feito em sessões do Claude Code na nuvem, a partir do celular.
- Branch de trabalho: `flutter-teste`. Pasta: `app-flutter/`.
- Build pelo GitHub Actions (`.github/workflows/flutter-apk.yml`), APK em pré-release `flutter-teste`. O dono instala e testa no POCO X4 GT.
- A fila do GitHub às vezes demora; se um build ficar "queued" por muito tempo, cancele e dispare de novo com um commit.
- O Google (storage.googleapis.com, pub.dev) é bloqueado na nuvem, então o Flutter completo não roda lá. O **Dart puro** roda: baixar o pacote `dart-sdk` do conda-forge (`https://conda.anaconda.org/conda-forge/linux-64/`, arquivo `.conda`, que é um zip com um `.tar.zst`) e extrair; o dono autorizou rodar esse binário. Serve para testar regras de jogo (sem pacotes do pub.dev; usar asserts simples).
- Fonte da verdade das regras: `play/index.html` e `play/assets.js`. Comparar a saída do Dart com o JS (rodado no Node).
- Commits: terminar com as linhas de atribuição da sessão. Nunca mergear em `main` sem o dono dizer "mergeia".

## 1. Tamanho do app atual

| Arquivo | Linhas | Observação |
|---|---|---|
| `play/index.html` | 21.734 | 1.716 funções; HTML + todo o JS |
| `play/style.css` | 7.291 | |
| `play/assets.js` | 423 (313 KB) | 63 monstros, 8 heróis, 319 itens, 4 cenários (PNG em base64) |
| `play/sheet.png` | 232 KB (512x864) | folha de sprites dos itens, 16 colunas x 27 linhas, tiles de 32 px |

Fontes: Outfit (interface), Silkscreen (pixel), Cormorant Garamond (títulos); arquivos woff2 em `fonts/`. Idiomas: PT e EN (`TRADUCOES` em `play/index.html`, linhas ~20724 a 21051, ~295 chaves; mais nomes em `assets.js`).

Formatos úteis de `assets.js`:
- `ITENS[i] = [spriteIdx, nome, tipo, raridade, valor, bonusMoedas, bonusXp, cura, morto, nome_en]` (+ afixo/rer/base em posições 10 a 12 no save). Tipos: arma, armadura, elmo, escudo, acess, tesouro, cons, chave. 319 entradas.
- `MONSTROS[i] = {nome, nome_en, bioma?, img (data URL)}`; biomas: padrao, deserto, floresta, montanhas.
- `HEROIS[i] = {nome, nome_en, img, imgArena}`; 8 heróis.
- `TEMAS_ARENA = [{id, nome, nome_en, gratuito, desbloqueioGratis, arte (base64), arteEstagio, posicaoArte?}]` e `TEMA_ARENA_TILE_B64`.

## 2. Inventário de telas

**Abas (barra inferior, 5):** Tarefas, Inventário, Loja, Perfil, Estatísticas.

**Aba Tarefas**
- Topo: avatar, nome, nível, moedas, troca de herói (dropdown).
- Arena: herói x monstro do dia, barra de HP do monstro, golpe animado (efeito por raridade da arma), baús (padrão, especial trancado, extra), selo e barra de estágio, troca de cenário por swipe/setas, vitória.
- Barras de vida e XP.
- Lista do dia: abas de categoria, tarefa com dificuldade, cor, meta "N vezes", arrastar para reordenar (long-press, auto-scroll), concluir/desfazer.
- Folha "Nova tarefa": texto, categoria, modo (hoje / dias da semana / mensal / anual), dificuldade (4), vezes por dia (1 a 9), cor (presets + hex).
- Folha de edição, apagar recorrente ("só hoje" ou todas), categorias (criar/editar/apagar), "Terminar dia", dia de descanso.

**Aba Inventário:** 5 slots de equipamento (arma, armadura, elmo, escudo, acessório), busca, filtros e subfiltros, grade, ficha do item (equipar, usar, vender), forja/afixos (spec em `claude/afixos-e-forja-spec.md` do Projeto, se disponível), grimório.

**Aba Loja:** estoque diário (8 vagas, oferta do dia, nível mínimo por raridade), comprar, vender tesouros.

**Aba Perfil:** herói, prévia de conquistas e bestiário, botão de configurações. Sistema de atributos existe no código mas está **desligado** (decisão de 2026-11-04); fora da primeira versão.

**Aba Estatísticas:** sequência atual e recorde, "desde o início", taxa do mês (anel), últimos 7 dias (linha), composição do mês (donut), mapa do mês, histórico semana/mês/ano, cartão de compartilhar sequência (imagem 9:16). Parte é Pro.

**Telas cheias e popups**
- Configurações: conta, heróis (lista, novo, renomear, excluir), aparência (temas de cor), preferências (idioma, vibração, som, CRT, golpes variados, notificações), links legais, sair, excluir conta.
- Conquistas (V2, com resgate), Bestiário, ficha de monstro.
- Popups de jogo: loot do baú, subir de nível, estágio desbloqueado (cerimônia), queda (vida zerada), tarefas perdidas na virada do dia, celebração do dia, resumo do dia, contador global.
- Onboarding: carrossel, quiz de categoria, nome, escolha de herói, primeira tarefa, login.
- Tutorial: tour guiado e diálogos por tela.
- Login: e-mail/senha, Google, verificação de e-mail.
- Paywall: pitch, lembrete, planos (mensal com teste, anual, vitalício), compra OK.

## 3. Sistemas (regras de jogo)

- **Tarefa:** `{texto, tipo: hoje|repete|mensal|anual, data|dias|diaMes|diaAno+mesAno, feitaEm, dif, meta, corBox, categoriaId, pulaEm}`.
- **Economia (`ECO`, `play/index.html` ~2377):** XP por tarefa (28, cheio até a 10ª, depois 50%), multiplicador por dificuldade (0,5 / 1 / 1,5 / 2,25), moedas por tarefa e por vitória, nível (100 + 60 por nível), vida base 40 + 8 por nível.
- **Dia:** monstro do dia (`(diasCorridos + offset + semente) % n` sobre o pool do bioma do estágio), vitória ao concluir 100%, "terminar dia", virada de dia com dano por tarefa largada, cura, morte (perde 50% das moedas), descanso.
- **Loot:** itens por vitória, raridades (8 degraus), baú trancado com garantia (pity 6), chave, tesouros, afixos e forja.
- **Estágios:** 4 cenários liberados por tarefas concluídas no total (`LIMIARES_ESTAGIO = [10, 30, 70]`).
- **Heróis:** até 4 por conta (Pro), cada um com save próprio.
- **Plano:** grátis x Pro (`claude/plano-gratis-vs-pro.md` do Projeto), teste de 7 dias, limite de tarefas grátis.
- **Extras:** conquistas, bestiário, grimório, histórico, temas de cor, efeito CRT, sons sintetizados (WebAudio), vibração por evento.

## 4. Dados e serviços

- **Save local:** JSON versão 3 em `questlog.v1` (por conta e por herói): `tarefas, inventario, variantes, afixos, equipado, xpTotal, moedas, derrotadoEm, nomeHeroi, heroi, semente, salvoEm, comecou`. Mais ~25 chaves secundárias por conta (`CHAVES_SECUNDARIAS_CONTA`: histórico, baú do dia, conquistas, descanso, vida, loja, temas etc.).
- **Firebase (`questlog-d4c11`):** Auth (e-mail/senha, Google); Firestore `saves/{uid}`, `saves/{uid}/historico`, `entitlements/{uid}`, `fcmTokens/{uid}`, `contadorGlobal/hoje`; FCM (push).
- **Cloudflare Worker (`cf-worker/`):** verificação de compra (`/billing/verify`) e push.
- **Play Billing:** SKUs `pro_mensal`, `pro_anual`, `pro_vitalicio` (hoje via Digital Goods API, só no TWA).

## 5. Arquitetura proposta para o Flutter

- **Camadas:** `dominio/` (modelos e regras em Dart puro, sem interface), `dados/` (save local, sincronização), `ui/` (telas). Estado com `ChangeNotifier`, sem biblioteca pesada.
- **Regra de ouro: mesmo formato de save.** O Flutter lê e grava o mesmo JSON versão 3 e os mesmos documentos do Firestore.
- **Regras conferidas contra o app atual:** as funções de regra do JS (XP, moedas, loot, datas, monstro do dia) rodam no Node e geram casos de teste; os testes do Dart precisam dar o mesmo resultado.
- **Assets:** script (Node) extrai os PNG em base64 do `assets.js` e recorta a `sheet.png`; desenho com filtro "nearest" (pixel art nítida). Tabelas `ITENS`/`MONSTROS`/`HEROIS`/`TEMAS_ARENA` e `TRADUCOES` exportadas para JSON pelo mesmo script.
- **Sons:** os efeitos são sintetizados no navegador; serão renderizados para arquivos de áudio uma vez e tocados no Flutter.
- **Plugins previstos:** `firebase_auth`, `google_sign_in`, `cloud_firestore`, `firebase_messaging`, `in_app_purchase`, `shared_preferences`, `share_plus`.

## 6. Ordem de portagem (cada fase termina em um APK instalável)

| Fase | Entrega | Depende do dono |
|---|---|---|
| 0. Base | Projeto, tema, fontes, assets extraídos, textos PT/EN, modelo de save, regras com testes | — |
| 1. Núcleo | Aba Tarefas completa: arena, lista, nova/editar tarefa, concluir, XP, nível, vitória, virada do dia, vida | Teste no celular |
| 2. Itens | Inventário, ficha, equipar/usar/vender, baús, forja, Loja | Teste |
| 3. Perfil | Perfil, conquistas, bestiário, grimório, configurações, heróis, temas de cor, idioma | Teste |
| 4. Estatísticas | Gráficos, histórico, descanso, compartilhar | Teste |
| 5. Entrada | Onboarding, tutorial, estágios e cerimônia, cenários | Teste |
| 6. Conta | Login e-mail/Google, sincronização com o save atual, excluir conta | Arquivo `google-services.json` e SHA-1 no Firebase |
| 7. Pro | Paywall, compra, teste grátis, restauração, push | Teste de compra pela Play (faixa de teste interno) |
| 8. Lançamento | Sons, vibração, ícone, splash, CRT, revisão geral, teste fechado, publicação como atualização de `com.dungeonlog` | Chave de assinatura (keystore) e Play Console |

## 7. Riscos

1. **Dois códigos para manter** enquanto o HTML seguir recebendo mudanças (ver `PARIDADE.md`).
2. **Convidados perdem o progresso na troca**: o save de quem joga sem conta fica no Chrome do TWA e o app Flutter não consegue ler. Mitigação: aviso no app atual pedindo para criar conta antes da troca.
3. **Paridade**: 1.716 funções com muitos casos de borda corrigidos ao longo do tempo (sincronização, virada de dia, baú). Exige testes e rodadas no celular.
4. **Assinantes atuais**: a assinatura é da conta Google + pacote; validar na fase 7 antes de publicar.
5. **Tamanho**: o APK de teste tem 47 MB (3 arquiteturas juntas); pela Play (App Bundle) fica menor.
6. **Fora da primeira versão**: sistema de atributos (desligado), ferramentas de debug, conquistas V1 e código morto.
