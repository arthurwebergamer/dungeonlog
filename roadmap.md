## 39. Config reestruturado — status: **[x] pronto** (fechamento desta sessão)

> Retoma o item 39 já registrado no roadmap principal ("Config
> reestruturado: tela principal vira lista enxuta... Ainda não
> iniciado. Não bloqueia lançamento."). Nesta sessão o item não só foi
> implementado como ganhou um redesign visual bem além do escopo
> original (ícones, cards maiores nas sub-telas, vibração, ajuste de
> paleta de temas) — tudo a pedido explícito do usuário, incremental,
> dentro da mesma sessão.

### O que foi implementado

**1. Ícones nas linhas da tela principal de Config**
Cada linha (`Conta`, `Apagar dados`, `Herói`, `Aparência`,
`Preferências`, `Histórico`) ganhou um `<span class="cfgicone">` com
SVG próprio (traço, sem preenchimento, mesmo estilo dos ícones já
usados no app). Layout compacto novo — CSS escopado em
`.cfgOverlay .cfgrow` pra não vazar pra outros usos de `.cfgrow` fora
de Config.

**2. Sub-tela Herói — grid de sprites maior**
`#gradeHeroisConfig`: 4 colunas → 3 colunas, sprites de 47px → 64px.
Escopado por ID pra não afetar `#gradeHerois` (grid do onboarding, que
reaproveita a mesma classe `.grade`/`.opcao`).

**3. Sub-tela Aparência — seletor de tema redesenhado**
Passou por 2 tentativas. **1ª (descartada):** `#temaGrid` virou grid
2 colunas de cards grandes (`aspect-ratio` crescente até 1/1.9,
`border-radius` ajustado de 20px→24px→10px tentando acertar o
tom) — referência trazida pelo usuário (print de outro app) pra
parâmetro de proporção/densidade, não cópia literal. **Resultado:**
usuário não gostou ("quadradão", destoava do resto da tela).
**2ª (aprovada, versão final):** virou **lista de linhas** — bolinha
de cor (30px) + nome do tema + ícone de check que só aparece quando
selecionado (`opacity`/`transform` no `.sel`), com divisória fina
entre linhas e feedback de toque (`:active`) igual ao resto de
Config. Mesmo padrão visual do app em vez de um bloco isolado.
`pintarTemaGrid()` reescrita: markup trocou de `<div class="temaswatch">`
com cor no `background` inline pra `<div class="temalinha">` com
`.temaDot`/`.temaNome`/`.temaCheck` como filhos.

**4. Histórico — botão "Abrir" trocado por seta**
Era o único item da lista com padrão diferente (botão de texto em vez
de linha inteira clicável + seta). Convertido pro mesmo padrão
`cfgrow cfglink` + `cfgseta` das outras 3 linhas (Herói/Aparência/
Preferências) — resolve a inconsistência visual apontada pelo usuário.
`id="cfgHistorico"` migrou do `<button>` pra `<div>` — handler JS
(`abrirHistorico`) não precisou mudar.

**5. Vibração nas linhas/botões que não tinham**
O bloco de vibração já existente no arquivo (item 17 do roadmap)
documenta escopo fechado — em vez de editar aquela lista, foi
adicionado um bloco novo separado: listener delegado em `#cfgOverlay`
cobrindo as 4 linhas `cfglink` (Herói/Aparência/Preferências/
Histórico) e os botões `.cfgbtn` (Sair/Criar conta/Apagar tudo). O
switch de Feedback tátil (`.swch`) fica de fora **de propósito** — já
tem o próprio `feedbackClique()`, disparado só ao *ligar* (não ao
desligar); somar o delegado ali duplicaria/erraria esse comportamento.

**6. Paleta de temas renomeada e com um removido**
Nomes exibidos no seletor:
| id | antes | depois |
|---|---|---|
| `padrao` | Crepúsculo | **Laranja** |
| `meianoite` | Meia-noite | **Azul** |
| `pergaminho` | Pergaminho | **Dourado** |
| `grafite` | Grafite (swatch branco `#FFFFFF`) | **Escuro** (swatch cinza `#8B8B93`) |
| `floresta` | Floresta | *removido da lista* |

Tema **Floresta removido** do array `TEMAS[]` (seletor visual) e do
`CICLO_TEMAS` (botão de ciclo rápido/debug). As variáveis CSS de
`[data-tema="floresta"]` **não foram apagadas** — marcadas como
deprecated via comentário, seguindo o padrão do projeto de nunca
deletar código, só documentar. Zero referência ativa a `'floresta'`
sobrou no JS (confirmado via grep).

**7. Tema padrão voltou a ser Laranja**
Decisão do usuário: laranja é a cor de identidade/marca do app, não
deveria ter deixado de ser o padrão. 3 fallbacks trocados de
`'grafite'` pra `'padrao'`: `temaSalvo()`, resumo do topo de Config
(`cfgAparenciaResumo`), e dentro de `pintarTemaGrid()`.

**8. Fix: switch do Feedback tátil sem contraste no tema Escuro**
No tema Escuro, `--accent` é branco — então o trilho ligado do switch
E a bolinha (`#FFF` fixo) ficavam brancos os dois, sem contraste
("muito branco", reportado com print). Corrigido com uma sombra sutil
fixa na bolinha (`.swch-bolinha`), que garante contraste em qualquer
tema sem depender da cor de `--accent`.

### Onde ficou o código

- `index.html`: ícones (6 `<span class="cfgicone">`), conversão do
  Histórico pra `cfglink`, bloco de vibração novo (script autônomo),
  array `TEMAS[]` e `CICLO_TEMAS` atualizados, 3 fallbacks de tema, id
  novo `cfgTemaCard` no card que envolve `#temaGrid`.
- `style.css`: módulos novos **#21** (ícones + layout compacto da tela
  principal), **#22** (grid maior de Herói + lista de temas — passou
  por uma versão intermediária de grid de cards, substituída na mesma
  sessão pela lista final), **#23** (fix do switch). Comentário de
  deprecated nas duas cópias do bloco `[data-tema="floresta"]` (o
  arquivo tem conteúdo duplicado pré-existente — módulos #1-20 se
  repetem a partir de "Módulo style #1"; ambas as cópias foram
  atualizadas por consistência, embora só a última prevaleça na
  cascata).

### Validado nesta sessão

- Balanceamento de tags (`<div>`/`<span>`/`<svg>`/`<button>`/
  `<script>`) conferido a cada edição, sempre batendo com o delta
  esperado.
- `node --check` em todos os blocos `<script>` (42 blocos, 0 erros).
- `style.css` parseado com a lib `css` do npm (parser real, não regex)
  — 0 erros em todas as passagens.

### Pendências dentro deste item

- **Nada disso foi testado em aparelho real ainda** — só validado
  estruturalmente (sintaxe/balanceamento). Prioridade pro próximo
  ciclo de teste em device.
- Quem tinha `'floresta'` salvo no `localStorage` de teste anterior
  simplesmente não vê mais essa opção — não quebra, só some da lista.
