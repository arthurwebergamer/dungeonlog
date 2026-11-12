# Fase 1 (Núcleo): aba Tarefas

## O que já funciona
- Abertura: carrega o save v3 (`questlog.v1.pj.pj1`), a vida, o descanso e o contador de tarefas concluídas, e roda a virada do dia (dano por tarefa largada, queda, vitória automática) com aviso na tela.
- Topo (avatar do herói, nível em numeral romano, pilha de moedas), arena (herói x monstro do dia com "vs", barra de vida fina em cima do monstro = fração de tarefas pendentes, golpe ao concluir), cartão de Vida e Experiência.
- Lista do dia (só as pendentes, como no original): a caixa conclui (XP, moedas, cura, nível, aviso "+XP · +moedas", aviso de nível), tarefas com meta (N vezes por dia, ganho dividido), tocar no cartão abre o editor, o "X" apaga (a que se repete pergunta "Só hoje" ou "Hoje e nos outros dias"; a de um dia só apaga direto).
- Arrastar para reordenar (pela alça ou segurando o cartão): grava `ordem` de 10 em 10 nas pendentes, como o `soltar()` do original.
- Descanso (botão da lua): "Descansar hoje?" marca o dia em `questlog.descanso.v1`; "Cancelar descanso" desmarca; concluir uma tarefa também cancela. O botão some depois que o monstro cai.
- Folha "Nova tarefa": texto, Hoje / Semana / Mês / Ano, dificuldade, vezes por dia. Folha "Editar tarefa": texto, dificuldade e vezes por dia.
- "Terminar dia": derrota o monstro, paga a vitória (16 + 5 por tarefa, até 6), cura 25% da vida, mostra o resumo "Dia vencido" e bloqueia novas tarefas até amanhã, como no app atual.
- Barra de navegação com os 5 ícones do original (as outras 4 abas mostram "Em breve").

## Visual (igual ao app original, tema grafite)
O visual da aba Tarefas foi refeito a partir do CSS computado de `play/` em 390x844 (cores, raios, espaçamentos e tamanhos de fonte):
- Cores do tema padrão `grafite` em `lib/ui/tema.dart` (fundo `#282828`, painéis `#323232` / `#3D3D3D` / `#494949`, linha `#5C5C5C`).
- Fontes Outfit (texto) e Silkscreen (letras dos dias da semana, selo "DIA VENCIDO" do resumo, aviso do topo), em `assets/fonts` (licença OFL, os mesmos arquivos que o original carrega do Google Fonts).
- Imagens da interface em `assets/img/ui` (pilha de moedas, moeda solta, tochas), extraídas por `tools/extrair_assets.mjs` de `play/index.html` e `play/style.css`.
- Ícones da barra, "check", alça e lua desenhados em `lib/ui/icones.dart` a partir dos SVG do original.
- Folhas e diálogos em `lib/ui/folhas.dart`.

### O que ainda difere do original
- Sem desfoque do fundo atrás das folhas (o original usa `backdrop-filter: blur(3px)`); aqui é só o véu escuro.
- A folha de nova tarefa e a de edição não têm "Opções avançadas" (cor da tarefa), e a de edição não tem o bloco "Quando" (trocar a repetição): a regra ainda não existe no Flutter.
- O resumo "Dia vencido" mostra nível, tarefas concluídas e moedas; faltam a arte da arena e as linhas de experiência do dia, sequência e estágio (dependem das Fases 4 e 5).
- Subir de nível, "Você caiu" e a virada do dia usam um aviso central simples, não as cerimônias em tela cheia.
- Ao concluir aparece um aviso "+XP · +moedas" no topo (o original mostra só o golpe e a contagem das moedas).
- Arena sem baú, sem equipamento no herói, sem selo de estágio e sem os pontos de troca de cenário (Fases 2 e 5). O monstro não tem a animação própria de cada espécie.
- A vida do monstro continua sendo a fração de pendentes (o original guarda um contador próprio em `questlog.hpMonstro.v1`).

## Testes
`flutter test`: 50 de paridade (Fase 0) + 16 do estado do jogo e da tela (`test/estado_jogo_test.dart`), incluindo reordenar, descanso, rótulo de repetição, o "X" de apagar e o fluxo criar / editar / concluir / terminar dia.
Os testes de tela carregam as fontes reais e avançam o relógio com `pump()` (a arena tem animações em laço, então `pumpAndSettle()` não termina).
Rodar a tela no Chrome: compilar a casca web (ver `tools/rodar_emulador.ps1` para o projeto-casca) e abrir `build/web`.

## Fora desta etapa (ainda)
- Baús, loot e chaves (Fase 2) e o efeito de golpe por raridade da arma.
- Categorias de tarefa, cor da tarefa, trocar a repetição ao editar, "tarefas perdidas" detalhado.
- Troca de cenário/estágio e cerimônia (Fase 5). Hoje a arena usa o cenário padrão.
- Histórico (Fase 4): a virada do dia calcula os registros, mas ainda não os grava.
- Limite de tarefas do plano grátis e paywall (Fase 7).
- Idioma: a interface está só em PT por enquanto (os textos do catálogo e as abas já respeitam o idioma).
- Notificações de vitória em tela cheia, sons e vibração além do toque.

## Atualização: acabamento da aba Tarefas (depois da Fase 2)
Feito: selo "Estágio N em X tarefas" e bolinhas na arena, troca de cenário arrastando (com cadeado e prévia quando trancado),
cerimônia "Estágio concluído" em tela cheia, cor da tarefa (Opções avançadas), e as telas cheias "Nível alcançado", "Você caiu",
"Tarefas perdidas" e resumo do dia vencido (formato `md` do original, em `lib/ui/sheet_md.dart` e `popups_md.dart`).

Achados importantes sobre o app original (play/index.html de hoje):
- **Categorias de tarefa estão desligadas** (`window.CATEGORIAS_ATIVAS = false`, a pedido do dono): sem abas, sem grupos, sem seletor.
  Os dados ficam no save e são ignorados. Não foram portadas de propósito.
- **O dropdown de troca de herói no topo foi removido**; a troca vive em Configurações (Fase 3).

Ainda não portado na aba Tarefas:
- "Golpes variados" (5 estilos de golpe, espada com rastro, corte por raridade da arma, respiração do herói e dos monstros) — padrão ligado no original.
- A cena "monstro escapou" na arena (o monstro do dia perdido bate no herói, uma vez por tarefa largada).
- A dica de arrastar a arena na primeira abertura (a arena "espia" para o lado).
- Linha de sequência no resumo do dia (depende do histórico, Fase 4).

## Atualização final do acabamento
Feitos também: **golpes variados** (`lib/ui/golpes_fx.dart`: 5 estilos, espada girando, corte em pixel art na cor da raridade da
arma, partículas, tremor da arena, flash, golpe crítico no "Terminar dia"; arco/besta usam o golpe simples), a cena **"monstro escapou"**
na arena (uma pancada por tarefa largada, antes do popup de tarefas perdidas) e a **dica de arrastar a arena** na primeira abertura.
Diferenças: a respiração dos monstros por espécie e o rastro-fantasma/rastro da arma (desligados também no original) não foram portados;
a posição do monstro e do herói na cena é calculada pela mesma geometria da arena, não medida na tela.
Ainda depende de fases futuras: linha de sequência no resumo do dia (histórico, Fase 4) e o interruptor "golpes variados" nas
Configurações (Fase 3; a chave \`questlog.golpesVariados.v1\` já é respeitada).
