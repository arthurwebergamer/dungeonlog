# Fase 1 (Núcleo): aba Tarefas

## O que já funciona
- Abertura: carrega o save v3 (`questlog.v1.pj.pj1`), a vida, o descanso e o contador de tarefas concluídas, e roda a virada do dia (dano por tarefa largada, queda, vitória automática) com aviso na tela.
- Topo (herói, nível, moedas), arena (herói x monstro do dia, barra de vida do monstro = fração de tarefas pendentes, tremida ao concluir), barras de vida e XP.
- Lista do dia: concluir (XP, moedas, cura, nível, aviso "+XP · +moedas", pop-up de nível), tarefas com meta (N vezes por dia, ganho dividido), segurar para apagar (recorrente: "só hoje" ou "todas").
- Folha "Nova tarefa": texto, só hoje / dias da semana / todo mês / todo ano, dificuldade, vezes por dia.
- "Terminar dia": derrota o monstro, paga a vitória (16 + 5 por tarefa, até 6), cura 25% da vida e bloqueia novas tarefas até amanhã, como no app atual.
- Barra de navegação com as 5 abas (as outras 4 mostram "Em breve").

## Testes
`flutter test`: 50 de paridade (Fase 0) + 11 do estado do jogo e da tela (`test/estado_jogo_test.dart`).
Rodar a tela no Chrome: compilar a casca web (ver `tools/rodar_emulador.ps1` para o projeto-casca) e abrir `build/web`.

## Fora desta etapa (ainda)
- Baús, loot e chaves (Fase 2) e o efeito de golpe por raridade da arma.
- Categorias de tarefa, cor, reordenar arrastando, editar tarefa, descanso (botão), "tarefas perdidas" detalhado.
- Troca de cenário/estágio e cerimônia (Fase 5). Hoje a arena usa o cenário padrão.
- Histórico (Fase 4): a virada do dia calcula os registros, mas ainda não os grava.
- Limite de tarefas do plano grátis e paywall (Fase 7).
- Idioma: a interface está só em PT por enquanto (os textos do catálogo e as abas já respeitam o idioma).
- Notificações de vitória em tela cheia, sons e vibração além do toque.
