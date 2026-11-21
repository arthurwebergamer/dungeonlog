# Fase 4: aba Estatísticas

## Fiel ao app original (conferido no navegador, 390x844, tema grafite, lado a lado com `play/index.html`)
- **Tela inteira** (`#viewEstatisticas`, a versão "sem caixas" do CSS v2e/v2f): cabeçalho com o mês ("Novembro de 2026"), cartão da **sequência atual** (gradiente 135 graus, tocha que cresce com a sequência, cortada pelo cartão, seta no canto) + **"desde o início"** (tarefas concluídas, dias vencidos, taxa geral), abas **Semanal / Mensal / Anual**, e por aba:
  - **Mensal**: taxa de conclusão (anel de 100 px, arco em degradê, cheio em 100%) + "como foi o mês" (venceu / fugiu / descanso / sem tarefa) e o histórico do mês (calendário de 7 colunas, tocha acesa = venceu, tocha cinza = fugiu, tocha azul = descanso, número do dia);
  - **Semanal**: gráfico dos últimos 7 dias (linha, área em degradê, pontos; hoje sem resultado não gera ponto) e o histórico dos 7 dias;
  - **Anual**: seletor de ano (o ano de hoje não avança) e a grade jan a dez com um quadrado de 9 px por dia, quebrando linha como o original.
- Legenda do histórico, textos em PT e EN (as chaves `est.*` já estavam em `assets/dados/traducoes.json`; "Semanal/Mensal/Anual" e os nomes do mês vêm do JS, que também os tem fixos no código).
- **Popup "Sequência atual"** (`#estMontanhaOverlay`): fundo roxo fixo (como no original, não segue o tema), número colorido pela sequência (`corDoStreak`), frase ("Vença hoje pra começar...", "essa é a sua maior sequência!", "recorde de N (faltam M dias)"), tocha que cresce com sobrepasso e brilho radial, botão **Compartilhar** em degradê fixo.
- **Cartão de compartilhar** (`gerarCardCompartilhamento`): PNG 810x1440 (9:16) desenhado direto num `Canvas` fora da tela (sem widgets): fundo do tema, brilho, "DUNGEONLOG" em Silkscreen, nome do herói, tocha (2º quadro, sem suavização, escala 1,8 a 3,6x conforme a sequência; cinza se for 0), número e "N dias seguidos". Conferido contra o PNG que o original gera (mesmas posições e tamanhos).
- **Linha "Sequência" no resumo do dia** (`mostrarResumoDia`): entre "Experiência" e o estágio, com `estStreakAtual(estHistComHojeAoVivo(...))` (hoje conta ao vivo se todas as tarefas estão feitas).
- **Regras** em Dart puro, `lib/dominio/estatisticas.dart` (reaproveita `EntradaHist` e `melhorSequenciaDeVitorias` da Fase 3; o recorde `estRecorde` do JS é a mesma regra): sequência atual, recorde, histórico "ao vivo" de hoje, composição e taxa do mês, taxa geral, mapa do mês/semana/ano, pontos do gráfico de 7 dias, escala da tocha e cor do número. A aritmética de datas é pelo calendário (UTC civil), não depende do fuso do aparelho.

## Testes
- `test/estatisticas_paridade_test.dart`: **330 casos** contra o JS. `tools/gerar_casos_js.mjs` extrai do `index.html` as funções reais (`estStreakAtual`, `estRecorde`, `estHistComHojeAoVivo`, `renderEstatisticas`, `renderUltimos7Dias`, `renderDonutMes`, `renderMapaDoMes`, `renderHistoricoSemana/Ano`, `escalaTocha`, `corDoStreak`...) e as roda contra um **DOM falso**; o que elas escrevem nos elementos (textos, larguras, cores, classes dos tiles, pontos do gráfico) é o que o Dart precisa igualar. Hoje variados (virada de mês e de ano, 29/02, 31/01, 31/10...), histórico vazio/curto/longo, datas repetidas, fora de ordem e no futuro, descanso, hoje ao vivo, PT e EN, abas mês/semana/ano e ano escolhido. O JS foi rodado também em **9 fusos** (UTC, Tóquio, Auckland, St. John's, Kiritimati +14, Pago Pago -11, Lisboa, Nova York, Calcutá) e deu sempre o mesmo resultado (o gerador aborta se divergir).
- Mutações feitas (e revertidas): "descanso quebra a sequência" (25 casos falharam), "hoje em andamento vira ponto do gráfico" (135) e "ano: hoje some" (30).
- `test/estatisticas_test.dart` (15): histórico ao vivo no estado, tela (textos, bloqueio Pro, desbloqueio, abas, navegação de ano, sem dados, 360 px, inglês), popup da sequência, PNG do cartão (810x1440), linha "Sequência" do resumo do dia.
- O gerador agora produz um fixture maior (`casos_js.json` ~4 MB). Todos os testes antigos seguem verdes (suíte: 1838 passam).

## Pro (ponto de ligação para a Fase 7)
No original, taxa, composição do mês, 7 dias e histórico são Pro (`assinaturaAtiva()`); sequência, "desde o início" e as abas são livres. Aqui `EstadoJogo.ehPro` (false até a Fase 7) decide: bloqueado, o cartão mostra o conteúdo sob um **véu escuro** (o original usa `blur(5px)`, que não entra por causa do desempenho), com o **cadeado e o selo PRO** no meio; tocar abre o aviso "Disponível em breve" (no original abre o paywall). Para ligar na Fase 7: ligar `ehPro` à assinatura real e trocar `_avisoPro` (em `tela_estatisticas.dart`) por `abrirPaywall('estatisticas')`. Com `ehPro = true` tudo aparece destravado (conferido no navegador).

## Compartilhar: escolha do pacote
`share_plus` (^13.3.1): só Kotlin/Java, sem toolchain nativa extra (não usa NDK/CMake próprio), resolve com Flutter 3.50/Dart 3.14, e já cria o arquivo temporário a partir dos bytes (`XFile.fromData`), então não precisamos de `path_provider` nem de permissão de armazenamento. Abre a folha de compartilhamento do sistema com a imagem `dungeonlog-sequencia.png` e o texto "Olha minha sequência no Dungeonlog!" (EN: "Check out my Dungeonlog streak!"), igual ao original. Se o sistema não conseguir abrir a folha, aparece um aviso (o original cai para baixar o arquivo; no Android não há "download" equivalente sem permissão extra). Compilação do APK com `pubspec.lock` apagado conferida (ver relatório da sessão).

## Difere do original, e por quê
- **Pro**: véu escuro no lugar do blur (sem BackdropFilter/blur); selo "PRO" (no original, fora do app Android o selo vira "Versão completa"; no Android aparece "PRO", que é o que o app Flutter é). O toque avisa "em breve" em vez de abrir o paywall.
- **Anel e gráfico** animam ao abrir como o original, mas a mola do JS (stiffness 120) virou curva de 700 ms; a linha do gráfico desenha em 0,65 s e os pontos entram em cascata. O anel só anima quando o valor muda (como no original); o gráfico anima ao entrar na aba Semanal.
- A escolha de aba/ano vale enquanto o app está aberto (como as variáveis do módulo no original) e volta a "Mensal" ao reabrir.
- O gráfico dos 7 dias não tem a sombra suave nos pontos (`drop-shadow` 2 px).
- Código morto do original **não portado**: o bloco "estn" v2 (`renderEstN`, escondido por CSS e nunca chamado), o popup de período (`#estPeriodoOverlay`, substituído pelas abas) e o donut em anel (`display:none` no CSS; só a legenda aparece).
- Contagem de tempo: o original recalcula as estatísticas a cada tarefa concluída; aqui a tela ouve o estado e refaz as contas a cada mudança (mesmo efeito).

## Depende de fases futuras
- Fase 7: plano Pro de verdade (`ehPro`, paywall no toque dos cartões trancados).
- Fases 5/6/8: nada novo aqui (tutorial, conta/nuvem: a sequência já lê o histórico local; quando a nuvem existir, o histórico restaurado entra pelo mesmo `EstadoJogo.hist`).

## Não verificado
- No celular (fluidez, a chama animada, o gesto, a folha de compartilhar do Android com a imagem). O navegador embutido roda a ~1 quadro/s: só layout, cores, textos e estado foram conferidos; as animações não foram julgadas por ele. No navegador o `share_plus` usa a Web Share API, não testada.
