# Fase 5: entrada (abertura, onboarding e tutorial)

Conferido no navegador (390x600 e 390x844 no original, tema grafite), lado a lado com `play/index.html`. Screenshots comparativos em `scratchpad/comparativos/` (pares `NN-nome-original.jpg` e `NN-nome-flutter.jpg`).

## Como o original REALMENTE funciona hoje (e o que foi portado)
O `index.html` tem camadas antigas (passo1 "Como funciona", passo3 "Primeira tarefa", diálogos com busto, slides de idioma) que ficam no DOM mas **nunca aparecem**. O fluxo vivo é:

1. **Abertura** (`#bootSplash`): fundo da cor do tema, herói correndo e "Carregando a masmorra..." (EN: "Loading the dungeon..." quando a língua do aparelho não é pt). Sai com fade de 280 ms quando o app termina de carregar. `lib/ui/splash.dart`.
2. **Carrossel de 5 slides** (só sem save começado): monstro "Gosma glacial" + "Chega de tarefa esquecida"; **quiz** (estudos/trabalho/rotina/tudo, grava `questlog.onboarding.categoria.v1`); herói + cartão de XP "NÍVEL 4"; emblemas de conquista (Coroa Real, Diamante, cadeado); **"É rápido assim"** com a animação do golpe (herói corre, corte por raridade da espada, moeda e gema voam, "+4 · +12 XP" sobe, a espada troca a cada golpe). Pontinhos, seta Voltar, "Pular" (vai ao login), botão "Começar ›", "Continuar ›" e "Criar minha conta ›". Fundo em gradiente (160 graus) com fusão entre slides.
3. **Login** (escolha: Google, e-mail, "Já tem conta? Entrar", "Entrar como convidado") sobre o cenário das montanhas, e o formulário de e-mail/senha (alternando Entrar/Criar conta).
4. **Configuração do herói** (depois de "Entrar como convidado"): escolha entre os 8 heróis (carrossel com setas) e **nome**. Ao fim grava o save v3 (`comecou: true`, nome, sprite) e o dia/vida iniciais, e o jogo abre.
5. **Tutorial** (`TOUR`, 9 passos) abre sozinho na primeira vez e tem os passos interativos (tocar em "+ Adicionar", escrever e criar a tarefa, tocar na caixinha e ver o golpe).

### Diferenças entre o pedido e o original (seguimos o original)
- **Não existe passo "primeira tarefa"** no fluxo atual do original (o nome é o último passo; a pessoa cria a tarefa dentro do app, guiada pelo tour). Por isso a entrada não cria tarefa nenhuma. O tour guiado é que leva à 1ª tarefa.
- **Não existe escolha de idioma** na entrada. O idioma padrão vem do aparelho (script do `<head>`: pt-BR, "pt" ou pt-BR em qualquer posição da lista = PT; senão EN) e é gravado em `questlog.idioma.v1` na primeira abertura (só se ainda não houver). Portado e testado contra o JS.
- Os **diálogos "Undertale" por tela** (`mostrarDialogoTelaAntigo`, letra por letra com busto) são **código morto** no original: hoje só o tour é usado e as outras telas só viram "vista". O **som `blip` não é tocado** (decisão v4.87 do original: o texto do tour é mudo, com vibração curta a cada 4 letras). Portei o tour e a digitação (2 letras a cada 38 ms + vibração), sem `blip` e sem gerar som novo.
- Contas: o login real é Fase 6. Google, o envio do formulário de e-mail e "Esqueceu a senha?" mostram o aviso "Disponível em breve". "Entrar como convidado" funciona como no original (grava `questlog.convidado.v1`) e é o único caminho que entra no jogo. O formulário não tem os ícones de OK/erro em tempo real nos campos de senha nem a caixa de aceite dos termos (só a linha "Ao continuar, você concorda...", com links para os termos).

## Regras e estado
- `lib/dominio/entrada.dart`: idioma padrão do aparelho, texto da abertura, slides (PT/EN), categorias, espadas e escalas do golpe. `lib/dominio/tutorial.dart`: os 9 passos, o registro `questlog.tutorialTelas.v2` (chave do APARELHO, fora de `CHAVES_SECUNDARIAS_CONTA`, como no original) e `posicionarCartaoTour` (posição do cartão do herói).
- `EstadoJogo`: `iniciar(permitirOnboarding: true)` (só a raiz do app) deixa o estado em modo **entrada pendente** sem gravar NADA (`_gravacaoSuspensa`): fechar o app no meio recomeça da entrada, igual ao original (que só grava ao fim). `concluirOnboarding(nome, heroi)` grava o save com `comecou: true` e o dia/vida iniciais. Quem tem save começado **nunca** vê a entrada; trocar/criar herói também não.
- O tutorial abre sozinho na 1ª vez por aparelho (aba Tarefas); as outras abas só marcam "vista"; "Pular" e "Concluir" marcam as 5. **Quem já tinha save de uma versão Flutter anterior e nunca viu o tutorial vai vê-lo uma vez** (é o que o original faz com jogador que volta).
- "Rever tutorial" (Configurações) fecha as telas, apaga as 5 marcas e reabre o tour 350 ms depois (`revisarTutorial`).

## Tour: destaques sobre widgets reais
`GlobalKey`s em `TourAlvos` (`lib/ui/tour.dart`): `addbtn` (+ Adicionar), `input`/`save` (campo e "Criar tarefa" da folha), `tarefaBox` (caixinha da tarefa criada), `restbtn` (lua), `equipbox`, `lojaLinha`, `prevConquistas`/`prevBestiario`, `perfilCfgBtn`, `estCardPrincipal`. A camada fica no `builder` do `MaterialApp` (por cima das folhas); só o buraco do destaque deixa o toque passar (nos passos interativos). Escurecimento 86% (50% no passo do golpe), anel branco com pulso, cartão do herói com nome, "SUA VEZ", "n / 9", barra de progresso, Pular/Voltar/Próximo, tudo medido do CSS do original. A posição do cartão é a mesma conta do `tourPosicionar`.
- Passo interativo "criar": se a folha fecha sem criar, volta ao passo anterior (como o original). Passo "concluir": espera a tarefa ser feita e avança 1,3 s depois (o golpe aparece sem nada em cima).
- Mochila vazia: o Flutter não mostra a caixa de equipamento nesse caso (já era assim desde a Fase 2), então o passo "Equipe seus itens" destaca a mensagem da mochila vazia (um retângulo maior que o do original).

## Testes
- `test/entrada_paridade_test.dart` + `tools/gerar_casos_js.mjs` (seção "Entrada"): **15 listas de idiomas** do aparelho (rodando o script real do `<head>` num sandbox) e **400 posições do cartão do tour** (o trecho real de `tourPosicionar`, com larguras de 320 a 1024 e alvos aleatórios; cobre os ramos "base", "topo", numérico e tela larga). Mutações feitas e revertidas: limite de tela larga 700->600 e margem 12->10 (ambas falham).
- `test/entrada_test.dart` (12): regras, estado pendente (nada gravado até o fim; save existente pula a entrada), fluxo completo do onboarding (5 slides, quiz grava a categoria, voltar, login, aviso "em breve" do Google, convidado, escolha de herói, nome vazio recusado, nome cortado em 18, conclusão grava o save), Pular/voltar em 360 px e em inglês, e o tour (abre na 1ª vez, Pular marca as 5, não volta depois de visto, percorre os passos informativos até "Concluir").
- `gerar_casos_js.mjs` sobrescreve `casos_js.json`: rodado, e **toda a suíte segue verde (1852 testes)**.
- `tools/extrair_assets_entrada.mjs`: extrai do original o herói da abertura, os 4 ícones do quiz e os 5 cortes (576x64) para `assets/img/ui/`.

## Difere do original, e por quê
- Em telas baixas (menos de ~700 px) o original rola a tela inteira (o botão desce); aqui o conteúdo do slide rola e o botão fica fixo embaixo.
- A fonte no navegador de teste parece um pouco mais pesada no original (fonte web variável x TTF estático); medidas e posições batem (ver comparativos).
- Sem `BackdropFilter`: o tour não desfoca nada (o original também desliga o blur durante o tour).
- O quadro "dia +1 / baú?" que aparece no original em localhost é ferramenta de desenvolvimento (não portado).
- Animações: o carrossel desliza em 300 ms com a curva de mola do original, mas o "fundo gradiente com fusão" e o "passoIn" do herói/nome são aproximações (fade + deslize), não conferidas quadro a quadro.
- O pedido de permissão de notificação depois do tutorial (`pedirPushUmaVez`) não existe ainda (Fase 7/8).

## Depende das Fases 6 a 8
- **Fase 6**: login real (Google, e-mail/senha, verificação, "Bem-vindo de volta", "Conhecer o app"), migração do convidado (`questlog.convidado.v1` já é gravada), seta de voltar do login sem origem.
- **Fase 7**: pedir notificação após o tutorial.
- **Fase 8**: abertura nativa do Android (ícone/splash do sistema), revisão final.

## Não verificado
- No celular (fluidez do golpe, vibração do tour, teclado real, rotação). O navegador do painel roda a ~1 quadro/s: só layout, cores, textos e estado foram conferidos; as animações não foram julgadas por ele.
- O APK (nenhum pacote novo foi adicionado: `flutter_svg` e `url_launcher` já estavam no `pubspec.yaml`).
