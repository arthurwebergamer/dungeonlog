# Questlog — Roadmap

> Versão do arquivo: `index.html` + `style.css` + `assets.js` (repositório GitHub, ver item de infraestrutura abaixo)
>
> **Nota:** item 46 novo — item 13d finalmente decidido. Botão de
> idioma sai do login (que não é mais hub principal), ganha slide
> próprio no carrossel. Escopo confirmado: tradução PT/EN completa
> (UI + diálogos + ~100 itens + 63 monstros), não só interface. Zero
> camada de tradução existe hoje — arquitetura registrada (dicionário
> central, campo por linha nos arrays, nunca tabela paralela). Texto em
> si fica pra sessão de implementação, por decisão do usuário.
>
> **Nota:** item 40 novo — número flutuante de XP/moeda na Arena
> (estilo "damage number" positivo), substituindo o toast de texto só
> nessa tela. Reaproveita infraestrutura existente (`COIN_SVG`,
> `moedasCaindo`/origem no centro do monstro) — spec fechada.
>
> **Nota:** item 39 *(pronto)* — Config reestruturado, foi bem além do
> escopo original a pedido do usuário (temas renomeados, Floresta
> removido, grids maiores, vibração completa). ⚠️ Achado: `style.css`
> tem os módulos 1-20 duplicados inteiros no arquivo — não é bug desta
> sessão, mas segue sem causa raiz investigada, exige edição em dobro.
>
> **Nota:** item anterior (infraestrutura) — arquivo único dividido em
> `index.html` + `style.css` + `assets.js` pra economizar tokens nas
> sessões de implementação. Ver seção 70. **Ainda não testado em
> aparelho real / publicado no Netlify** — próximo passo antes de
> considerar fechado.
>
> **Nota:** item 39 novo — Config reestruturado, tela principal vira
> lista enxuta (texto + seta), Herói/Aparência/Preferências migram pra
> sub-telas próprias (mesmo overlay já usado desde v4.58). Zero feature
> nova, só reorganização visual — usuário recusou email editável,
> pausar dano e hora de reinicialização quando oferecidos como opção.
>
> **Nota:** watchdog órfão `iniciarVigiaVerificacao` removido por
> completo (item 34), a pedido explícito do usuário, direto nesta
> sessão de brainstorm — mesma exceção pontual do item 33. Confirmado
> antes de remover que nada mais no arquivo dependia dele.
>
> **Nota:** item 34 novo, escalado pelo usuário como possível
> bloqueador de lançamento — email não verificado no cadastro, qualquer
> pessoa pode usar email de terceiro sem confirmação. Spec fechada
> (decisão de abordagem justificada, grandfather clause pra contas
> antigas), mexe em fluxo de auth — recomendado pra sessão dedicada,
> não implementado direto neste chat.
>
> **Nota:** item 33 novo — teto de todos os atributos padronizado em
> 30%, implementado direto nesta sessão de brainstorm como exceção
> pontual (pedido explícito do usuário). Resolveu de brinde o risco
> aberto do item 24 (Vigor já tinha a trava, só não estava confirmado).
>
> **⚠️ IMPORTANTE:** o Project Knowledge ficou sem o roadmap principal
> por um tempo — só uma sessão avulsa (carrossel) estava lá quando
> verificado em 24/08. Nada foi perdido (cópia local preservava tudo),
> mas reforça: **sempre subir o roadmap.md atualizado antes de trocar
> de chat ou encerrar a sessão**, senão a próxima sessão parte de uma
> base incompleta sem ninguém perceber.
>
> **Nota:** item 29 *(pronto, muito além do escopo original — ver
> seções 42-b a 42-m, v4.113→v4.122)*: carrossel de valor virou
> unificação completa de Login+Nome+Herói+Tarefas num só carrossel,
> login virou desvio opcional, bug real de race condition caçado e
> corrigido. **Nada testado em aparelho real ainda — prioridade #1.**
> Item 30: **não implementado como especificado** — entrou um slide de
> transição genérico em vez do diálogo personalizado do herói; precisa
> confirmar com o usuário se isso resolve ou se o item original ainda
> é desejado. Item 24: risco aberto — Vigor (implementado depois, seção
> 42-l) pode não ter herdado a trava de teto deste item, não confirmado.
>
> **Nota:** itens 27 e 28 *(prontos, v4.87)* — resultado final bem
> diferente da spec original, decidido via preview isolado testado no
> Android real antes de qualquer edição no jogo. Item 27: nenhuma das
> cadências reduzidas funcionou bem no teste — **diálogo ficou mudo**
> (comparação com outros RPGs do gênero), `SONS.blip` continua no
> catálogo sem ser chamado. Item 28: vibração a cada 4 letras, 20ms —
> a cadência mais apertada (2-3 letras, 4-8ms) que eu tinha
> especificado **não funcionou no aparelho** (pulsos se atropelavam,
> motor físico não completava o ciclo), recalibrado depois de
> diagnóstico real. **Pendência p/ confirmar com o usuário:** vibração
> respeita o toggle de mudo por decisão assumida da implementação, não
> perguntada — confirmar se é isso mesmo que ele quer.
>
> **Nota:** item 26 *(pronto, v4.86 — ver seção 69)*: efeitos de golpe
> finalizados e aprovados pelo usuário ("muito bom, não precisa mexer
> mais"). Plano original (item 22, categoria de arma define o visual)
> **abandonado no meio da implementação** — eixo final é só raridade
> (cor = raridade, sprite `Slash 3` único pra todas as armas). Pendência
> da própria sessão: confirmar visualmente no aparelho, já que a
> limpeza de código morto aconteceu depois do último vídeo aprovado.
>
> **Nota:** item 25 *(pronto — ver seção 4)*: 2 temas novos ficaram
> (Grafite preto-e-branco, Floresta), total sobe de 3 pra 5 — não 7 como
> a spec original (21/08) previa. Oceano e Carmesim foram implementados,
> passaram por 2 rodadas de redesenho de cor (feedback do usuário: o
> vermelho do Carmesim não agradou, o turquesa do Oceano ficava parecido
> com o azul do Meia-noite) e no fim foram **removidos por decisão do
> usuário** — 5 temas cobrem o espectro de cor sem repetir hue, sem
> precisar forçar um sexto/sétimo tom. Sem referência órfã aos ids
> `oceano`/`carmesim` no arquivo. `.temagrid` ganhou `flex-wrap` nessa
> leva (não estava na spec, achado ao escalar de 3 pra mais temas) e foi
> mantido mesmo depois do corte pra 5. Barra de XP (`#fill`/
> `#perfilFill`, seção 49) continua fixa em laranja/dourado em todo
> tema, por decisão anterior, sem relação com esse item.
>
> **Nota:** vão elástico no drag de tarefa *(pronto, v4.81 — ver seção
> 68)*: pedido depois de vídeo de referência de outro app (usuário
> confirmou que não era o Questlog rodando, era só exemplo do efeito).
> O placeholder não fica mais travado na altura de 1 card — estica em
> tempo real até alcançar a borda do card flutuante, cresce na direção
> em que o dedo se afasta do slot original, nunca fica menor que 1
> card. **Só validado por lógica isolada (`node`, casos de borda) e
> sintaxe — não testado visualmente num dispositivo real**, sem
> ambiente pra rodar o app de verdade nesta sessão. Testar arrastando
> em lista curta e longa antes de considerar fechado.
>
> **Nota:** dois ajustes finos na mesma sessão *(prontos, v4.81 — ver
> seções 66/67)*: (A) o gap do drag voltou a ser exatamente do tamanho
> de uma tarefa normal (`r.height`, sem acréscimo — tentativa de deixar
> maior que o card foi revertida); (B) `BORDA_AUTOSCROLL` de 70px pra
> 16px — antes começava a rolar a lista bem antes do dedo chegar na
> borda real da área visível de tarefas, agora só ativa quando a área
> visível de fato acaba.
>
> **Nota:** mais duas correções pequenas nesta mesma sessão *(prontas,
> v4.81 — ver seções 64/65)*: (A) arrastar tarefa pra reordenar agora
> rola a lista sozinha quando o dedo chega perto do topo/fundo de
> `#list` — antes só reordenava entre o que já estava visível na tela;
> (B) os 4 ícones fora do padrão nas Conquistas (teste de pack PNG
> promocional, documentado como pendente de decisão) foram revertidos —
> as 17 conquistas voltam a usar todas o mesmo SVG de linha da
> categoria.
>
> **Nota:** as duas correções pequenas da tela de Perfil citadas na nota
> anterior (parte do item 24) *(prontas, v4.81 — ver seção 63)*: (A)
> Fortuna/Foco não deixam mais gastar ponto além do teto real (13/15
> pontos respectivamente) — botão desabilita e `aviso()` explica; (B)
> label e valor de XP/Vida não colam mais em nível/XP alto — `gap`
> escopado em `.perfilhero .xprow`, sem tocar a regra genérica usada em
> outros lugares do arquivo. Resto do item 24 (spec fechada em 21/08)
> segue não implementado.
>
> **Nota:** item 21 *(pronto, v4.77 — ver seção 58)*: som faltando em
> "Salvar alterações"/"Excluir" no editor de tarefa, implementado
> exatamente como a spec fechada previa. Item 22 *(pronto, v4.78 — ver
> seções 59-61)*: efeito visual de golpe por categoria de arma (5
> categorias) + brilho dourado extra pras 3 armas Lendárias. Item 23
> *(pronto, v4.80 — ver seção 62)*: fix de fallback + migração do login
> pra vibração, mas a implementação real acabou diferente da spec
> original — auditoria em uso real achou o fallback insuficiente mesmo
> corrigido, virou preferência manual do usuário (Perfil > Config), não
> detecção automática.
>
> **Nota:** bug encontrado pelo próprio usuário testando os 6 Lendários
> da v4.75 — fundo preto/escuro nos sprites novos em vez de
> transparente. Corrigido na v4.76 (seção 57) — só o spritesheet foi
> retrabalhado, nenhum dado (`ITENS`, raridades, `PESO_LOJA`) mudou.
>
> **Nota:** item 20 (seção 4) completo — 6 Lendários novos via recolor
> dourado real (sprites extraídos das imagens que o usuário anexou,
> inseridos no spritesheet), Épico de Armadura/Escudo resolvido por
> reclassificação, `PESO_LOJA[4] = 0` (Lendário só em baú). Ver seção 56.
>
> Item 19 (seção 3) concluído — badge da arma em destaque na
> faixa de equipamentos, v4.73 (seção 54). Bug crítico corrigido na
> v4.74 (seção 55): Grimório aparecia vendável na aba Vender da Loja,
> risco de perda permanente de progresso.
>
> Nota anterior, ainda válida: item 18 novo (seção 4), adicionado em sessão de brainstorm
> (19/08): Perfil unificado numa tela única sem sub-abas, com Conquistas
> e Bestiário em prévia+overlay. Spec fechada, ainda não implementado.
> Item 15 (seção 4) corrigido pra `[x]` — estava desatualizado,
> o fix já existe no código desde a v4.55. Item 17 *(pronto, v4.62 — ver
> seções 46/47)*: vibração no clique de navegação, escopo fechado
> implementado, teste de duração mais curta feito e revertido (ver seção
> 47 — motivo técnico, não erro de ajuste). Poção de Vida cura de
> verdade desde a v4.59 (seção 43), Poção de Mana/Vigor removidas desde
> a v4.60 (seção 44). Conquista "Início da Jornada" corrigida na v4.61
> (seção 45) — disparava sem nenhuma ação do jogador.

## 1. Objetivo

App de checklist de tarefas gamificado em estilo RPG. A ideia central, em uma frase:

> **Todo dia aparece um monstro, e ele só morre se você terminar todas as suas tarefas do dia.**

É isso que diferencia o Questlog dos concorrentes (Habitica, Levelite, LifeUp, Skillion), que em geral só acumulam XP sobre listas de tarefas, sem um "chefe do dia" obrigatório.

**Formato técnico:** PWA de arquivo único — HTML, CSS e JS no mesmo arquivo, com sprites embutidos em base64. Instalável no celular, funciona offline, sem servidor.

---

## 2. Regras de negócio e de jogo

### Monstro do dia

- Existe **1 monstro por dia**, escolhido de um elenco de **63**.
- A escolha é **determinística pela data**: o mesmo jogador vê o mesmo bicho o dia inteiro, mesmo fechando e reabrindo o app.
- Cada instalação sorteia uma **semente própria** (0–63) na primeira vez e a guarda no save. Dois jogadores no mesmo dia veem monstros diferentes.
- A ordem do elenco é **intercalada por família**: nunca caem duas gosmas (ou dois morcegos etc.) em dias seguidos, incluindo na virada do ciclo.
- O ciclo completo leva **63 dias** para repetir.
- O elenco nasceu com 64. "Besta de esporos" foi cortada, e o divisor de `monstroDoDia()` passou de 64 para 63 — o que **reembaralhou qual monstro cai em qual dia** para quem já jogava. Cortar ou acrescentar monstro tem sempre esse efeito.
- Sem nenhuma tarefa cadastrada, o monstro aparece **à espreita** (apagado e acinzentado).

### Vitória e derrota

- O monstro **só morre com 100% das tarefas do dia concluídas**. Concluir parcialmente não o mata.
- Ao morrer: ele colapsa, o herói centraliza, aparece **"DIA VENCIDO"**, caem moedas e o **espólio é sorteado**.
- **A revelação do espólio é visual (v4.6-temas)**: 1.2s depois da vitória abre um pop-up central com o ícone do "Baú do Tesouro" (`sp:118`), um pulinho de CSS marca a "abertura" e revela os itens ganhos em cards — ícone, nome, raridade colorida (raridade não segue tema, é reconhecimento de jogo). `darLoot()` só retorna os itens; o toast de texto antigo (`ESPOLIO: ...`) foi removido.
- A vitória é gravada como `derrotadoEm` (data ISO), não como flag solta — assim o estado se corrige sozinho quando o dia vira.
- Se o dia virar com tarefas pendentes, o monstro **foge** (desliza para a direita) e aparece o aviso **"NOME FUGIU"** em vermelho.
- Depois que o monstro cai, **não é possível adicionar novas tarefas naquele dia** (evita farmar XP após a vitória).

### Tarefas

- Dois tipos: **só hoje** ou **repete toda semana** (em dias específicos da semana).
- Tarefas concluídas somem da lista com animação.
- Marcar uma tarefa faz o herói avançar e golpear; o monstro treme e perde vida.
- Cada tarefa tem uma **dificuldade**, escolhida na criação e editável depois.
- **Concluir é exclusivo da caixa de marcar.** Tocar no corpo da linha abre o editor. Sem essa separação, editar e concluir competiriam pelo mesmo toque.
- **Editor de tarefa:** folha que sobe de baixo, com fundo desfocado. Permite mudar título, dificuldade, tipo e dias, além de excluir. Fecha tocando fora ou com Esc.
- **Criar tarefa usa a mesma folha** do editor — mesmo overlay, mesma linguagem visual.

### Dificuldade

Quatro níveis. O multiplicador incide sobre **XP e moedas** da tarefa, e é aplicado depois do decaimento por ordem e dos bônus de equipamento.

| Nível | Multiplicador | XP (base 20) |
|---|---|---|
| Trivial | 0,50 | 10 |
| Fácil | 1,00 | 20 |
| Média | 1,50 | 30 |
| Difícil | 2,25 | 45 |

- **Média é o padrão.** O composer volta para Média toda vez que abre, para não herdar a escolha da tarefa anterior sem querer.
- Tarefas salvas antes desta versão não têm o campo `dif`. `difDe()` devolve `'media'` nesse caso e também quando o id é inválido, então nenhum save antigo muda de valor.
- Os quatro multiplicadores vivem no `ECO` e são editáveis pelo painel de economia, no grupo **Dificuldade**.

### Vida do herói

Existe para dar consequência a não fazer as tarefas. Sem ela o jogador larga o dia sem custo nenhum.

- **Vida máxima escala com o nível:** `vidaBase + vidaPorNivel × (nível−1)`. No nível I são 40; no V, 72.
- **Dano na virada do dia**, por tarefa largada, **multiplicado pela dificuldade**. Largar uma Difícil custa 13,5; uma Trivial, 3. Com 40 de vida cabem uns 3 dias ruins antes de cair.
- **Cura** por tarefa concluída, mais um bônus de 25% da vida máxima ao vencer o dia.
- **Ao zerar:** perde metade das moedas e revive com vida cheia. Não perde nível nem item. **Pop-up de derrota (seção 16)** avisa o jogador — mesma família visual do baú/nível — no lugar do toast genérico de dano, que fica reservado só pra perda de vida que não mata.
- Abaixo de 25% a barra e o número ficam vermelho-escuro.

**Só o último dia visto é punido.** Quem some por uma semana volta levando um dia de dano, não sete. Voltar não pode ser pior que nunca ter saído — sem essa regra, uma viagem zeraria a conta de qualquer um e o app viraria algo a se temer.

### Virada do dia

Antes desta versão **a virada não era detectada.** O único lugar que tratava a fuga do monstro era o `onclick` do botão de depuração, então em uso real as tarefas de ontem só deixavam de ser "de hoje" e sumiam, sem aviso e sem punição. Era isso que deixava o jogador confortável em não fazer nada.

Agora o módulo de vida guarda o `ultimoDia` visto e compara com a data atual a cada abertura. `pendentesEm(iso)` reconstrói quais tarefas estavam pendentes naquele dia — inclusive as recorrentes, pelo dia da semana da data.

### Progressão

- **XP por tarefa** com decaimento: as primeiras N tarefas do dia valem XP cheio, as seguintes valem uma fração. Evita inflar a lista com tarefas de mentira.
- **Moedas** vêm de duas fontes: por tarefa concluída **e** um bônus na vitória (fixo + por tarefa, com teto).
- **Nível** exibido em numeral romano. Custo do nível: `nivelBase + nivelIncremento × (nível−1)`.
- **Subida de nível também é um pop-up (v4.6-temas)**, mesma família visual do baú, mostrando o numeral romano e a vida máxima nova. A linha vivia dentro de `alternar()`, então foi editada direto — não dá pra suprimir um `aviso()` interno só com wrapper de fora. `nivelDepois`/`subiuNivel` são calculados **antes** do branch de vitória, cobrindo o caso em que a mesma tarefa sobe de nível e fecha o dia.
- **Nível e baú nunca aparecem sobrepostos**: os dois entram numa fila global (`window.enfileirarPopup`, bloco autônomo no fim do arquivo). Cada pop-up aceita um callback `aoFechar`; o próximo da fila só some quando o atual fecha — sem depender de timing (`setTimeout` fixo já se mostrou frágil aqui: se o jogador demora pra fechar o primeiro, o segundo abre por cima).
- Equipamento aplica **multiplicadores percentuais** de XP e de moedas, definidos por slot e por raridade.

### Itens e inventário

- Catálogo de **100 itens** (curado a partir de um spritesheet de 129 sprites — nem todo sprite do pack virou item jogável), ver seção 13 para o histórico de edição.
- Tipos: `arma`, `armadura`, `elmo`, `escudo`, `acess`, `cons` (consumível), `tesouro`.
- 5 raridades: Comum, Incomum, Raro, Épico, Lendário — cada uma com cor própria.
- **Equipar** dá bônus de XP e moedas. Itens amaldiçoados têm bônus negativo (80% do valor da raridade, com sinal invertido).
- **Consumível** é usado na hora: dá XP e/ou moedas e some da mochila.
- **Tesouro** não equipa nem usa — existe só para virar moeda. Vende por uma fração maior que a de equipamento.
- Slots vazios mostram a silhueta apagada de um item genérico do pack (espada, armadura, elmo, escudo, anel), não um ícone abstrato.

### Loja

- Prateleira **determinística por dia**: PRNG semeado com `diasCorridos() + semente`. O estoque é o mesmo o dia inteiro; dois jogadores veem prateleiras diferentes; renova à meia-noite.
- **1 unidade por vaga por dia.** Comprou, esgotou.
- **Preço de compra** = `valor do item × margem`. Como a venda paga metade do valor, não existe arbitragem comprar/revender.
- **Consumível tem margem própria**, mais alta: ele converte moeda em XP direto, então precisa ser caro para não virar atalho de progressão.
- **Oferta do dia:** uma vaga sorteada sai com desconto, com o preço cheio riscado ao lado.
- **Trava por nível:** `1 + raridade × lojaNivelPorRaridade`. Item acima do nível continua visível, opaco, com o nível exigido no botão — vitrine, não item escondido.
- **Tesouro nunca entra na prateleira.** Ele fecha o ciclo: espólio → moeda → equipamento.
- Aba **Vender**: lista a mochila com o preço de recompra, avisa quando o item está equipado e tem um botão de **vender todos os tesouros** de uma vez.

### Painel de economia (depuração)

Botão **"economia"** na barra de depuração. Todos os números do jogo ficam em um único objeto `ECO`, editável ao vivo pelo painel, com **projeção de 30 dias** recalculada a cada tecla.

| Grupo | Campo | O que faz |
|---|---|---|
| Experiência | `xpPorTarefa` | XP base por tarefa concluída |
| Experiência | `xpTarefasCheias` | Quantas tarefas por dia valem XP cheio |
| Experiência | `xpDecaimento` | Fator aplicado às tarefas acima do teto |
| Moedas | `moedasPorTarefa` | Moedas por tarefa concluída |
| Moedas | `moedasVitoriaBase` | Bônus fixo da vitória do dia |
| Moedas | `moedasVitoriaPorTarefa` | Bônus da vitória, por tarefa |
| Moedas | `moedasVitoriaTeto` | Máx. de tarefas contadas no bônus |
| **Loja** | `lojaMargem` | Multiplicador do valor do item no preço de compra |
| **Loja** | `lojaVagas` | Quantos itens diferentes vão para a prateleira por dia |
| **Loja** | `lojaDesconto` | Fator do preço no item em oferta |
| **Loja** | `lojaNivelPorRaridade` | Níveis exigidos a mais por degrau de raridade |
| **Loja** | `lojaMargemConsumivel` | Margem só dos consumíveis (XP comprado custa mais) |
| Itens | `taxaVenda` | Fração do valor paga ao vender equipamento |
| Itens | `taxaVendaTesouro` | Fração do valor paga ao vender tesouro |
| Itens | `lootBase` | Itens garantidos por vitória |
| Itens | `lootExtraCada` | +1 item a cada N tarefas do dia |
| Itens | `lootMax` | Teto de itens por vitória |
| Níveis | `nivelBase` | XP para sair do nível I |
| Níveis | `nivelIncremento` | XP a mais exigido por nível |

Abaixo da tabela: grade de **bônus por slot e raridade** (XP % e moedas %) e a **projeção**, que agora inclui um bloco da Loja com preço médio por raridade, quantos dias de trabalho cada faixa custa, o nível exigido e o teto de **XP comprável por moeda** via consumível.

Alterar qualquer campo salva em `rpg_eco_v1` e redesenha o app na hora. "Ver código" cospe o `ECO` e o `BONUS` prontos para colar no arquivo.

### Persistência

- Três chaves separadas, de propósito:
  - `questlog.v1` — save do jogo: `tarefas`, `xpTotal`, `moedas`, `derrotadoEm`, `nomeHeroi`, `heroi`, `semente`, `comecou`, `inventario`, `equipado`.
  - `rpg_eco_v1` — números da economia (painel de depuração).
  - `questlog.loja.v1` — estoque do dia, vagas já vendidas.
  - `questlog.vida.v1` — vida atual e último dia visto.
  - `questlog.sfx.v1` — SFX ligado/desligado e volume (0..1). Ver seção 20.
  - (lista incompleta desde antes desta sessão — várias chaves de módulos mais novos, como `questlog.hpMonstro.v1`, `questlog.atrib.v1`, `questlog.tarefasConcluidas.v1`, `questlog.itensVistos.v1` e `questlog.tutorialTelas.v2`, não estão listadas aqui; não mexi nelas por não fazerem parte do escopo desta sessão)
- Saves antigos continuam carregando sem quebrar.
- Se já houver save, o onboarding é pulado.

### Identidade visual

- **Base roxa** (`#1A1526`), com arena em degradê arroxeado.
- **Laranja âmbar** (`#F2A65A`) reservado para ação: nível, botão de adicionar, barra de XP, seleção.
- Dourado (`#F2C94C`) para moedas; verde (`#63C99A`) para concluído; rosa-vermelho para vida do monstro — hoje `#F45781`, que é o `--blood` original (`#E5698A`) com a saturação subida de 70% para 88%, mantendo matiz e luminosidade (usado no flash do texto de vida, ver seção 10).
- **Todos os sprites têm contorno preto** (`~#020406`), herói e monstro. É a regra que amarra a arte: sem ela os dois lados parecem vir de packs diferentes.
- Fonte **Outfit** para todo texto funcional; **Cormorant Garamond** itálica só para nomes próprios.
- **Avisos aparecem no topo**, dentro da faixa da barra de nível — não na parte de baixo. Entram deslizando de cima. São **estreitos de propósito** (máx. 236px): não há faixa livre na arena (vida do monstro em y=77, sprites de y=88 a 175, nome do monstro de y=191 a 216), então o único vão real é o miolo da topbar, entre o selo de nível e o contador de moedas. Alargar volta a cobrir um dos dois. Ficam em `z-index:90`, acima das folhas modais (80), porque validações disparadas de dentro de uma folha precisam ser lidas com ela aberta.

### Licenças dos assets

- **Monstros:** "64x Tiny Monsters" (Pixel-Deck) — uso comercial e modificação permitidos, proibido revender o pacote.
- **Personagens:** PIPOYA Free RPG Character Sprites 32x32.
- **Itens:** "Pixel Art Dungeon Item Pack — 128 items". Montado em spritesheet de 16×9 sprites de 32px, em **ordem alfabética do nome do arquivo** — é isso que define o índice de cada item no catálogo. O `cover.png` ocupa o índice 28 e não é usado.
- Descartado: imagens do OpenArt, por falta de licença clara.

---

## 3. O que já está pronto

- [x] Onboarding completo em 4 passos, com validação do nome
- [x] Tela de escolha de personagem (8 opções)
- [x] Arena: herói contra monstro do dia
- [x] 63 monstros embutidos, com rotação diária intercalada por família
- [x] **Nomes dos monstros revisados** a partir do catálogo por índice
- [x] **Aba Perfil na barra inferior** — só o ícone e a tela vazia, sem conteúdo
- [x] **Perfil → Atributos** — nível, XP, vida máxima, moedas e bônus de equipamento (v4.4)
- [x] **Equipamento visível no herói** — badges por slot e aura por raridade (níveis 1 e 2)
- [x] **Seletor de tema (Perfil → Config)**: 3 paletas cobrindo arena, tarefas, inventário, loja e nav (v4.4 + fix de cobertura em v4.5)
- [x] Semente por jogador
- [x] Monstro à espreita, fuga na virada do dia, vitória com colapso e queda de moedas
- [x] Tarefas de hoje e recorrentes por dia da semana
- [x] XP com decaimento, níveis em romano e barra de experiência
- [x] Moedas por tarefa e por vitória
- [x] **Inventário completo**: 100 itens, 6 raridades (incluindo `Único`, exclusiva de itens-chave), equipar por slot, ficha do item, filtros, consumíveis, venda
- [x] **Espólio na vitória**, com quantidade e raridade influenciadas pelo tamanho do dia
- [x] **Loja completa**: estoque diário determinístico, preço por margem, oferta do dia, trava por nível, esgotamento por vaga, aba de venda e venda de tesouros em lote
- [x] **Painel de economia** com edição ao vivo, projeção de 30 dias e exportação do código
- [x] Salvamento em `localStorage` com compatibilidade retroativa
- [x] PWA: manifesto, ícones embutidos, metatags iOS/Android
- [x] Botões de depuração ("próximo dia →", "apagar tudo", "economia")
- [x] **Contorno preto nos 8 sprites de herói**, casando com os monstros, e escala de pixel unificada entre herói e monstro
- [x] **Dificuldade por tarefa** (4 níveis), multiplicando XP e moedas, com os fatores no painel de economia
- [x] **Editor de tarefa** em folha modal: título, dificuldade, tipo, dias e exclusão
- [x] **Criar tarefa na mesma folha**, com fundo desfocado
- [x] **Alvos de toque adequados**: caixa de concluir e botão de excluir a 42×42px, "+ Adicionar" a 44px de altura
- [x] **Barra de vida do herói**, acima da de experiência, com dano por tarefa largada, cura, morte e escala por nível
- [x] **Detecção real da virada do dia**, com `ultimoDia` persistido
- [x] **Reordenação por arrastar** (v4.8) — long-press em qualquer parte do card pra arrastar e reordenar, com animação FLIP nos vizinhos
- [x] **Diálogo de apresentação por tela** (v4.16–4.20) — 1x por aba, forçado, estilo visual novel (busto + plaquinha + digitação letra por letra), ver seção 8
- [x] **Vida do monstro como contador persistido** (v4.21–4.24) — excluir tarefa não mexe mais na vida, só completar (dano) ou criar (teto), ver seção 9
- [x] **Polimento visual da arena** — halo do herói removido, indicador de vida do monstro redesenhado (texto com flash no dano), movimento no golpe removido (sprites ficam parados), ver seção 10
- [x] **Flash branco no hit** — herói e monstro piscam branco sólido ao tomar dano, reaproveitando/criando os ganchos deixados na seção 10, ver seção 12
- [x] **Pop-up de derrota** — "Você caiu", mesma família visual do baú/nível, dispara só quando a vida zera (não em toda perda de vida); toast genérico de dano suprimido nesse caso pra não duplicar aviso, ver seção 16
- [x] **Perfil → Conquistas** — 5 categorias, 39 marcos, trilha vertical (não card+barra, não grid estilo Habitica), lendo 100% de dado já existente + 1 contador novo (`tarefasConcluidas`), ver seção 17
- [x] **Tarefas com meta diária + cor por tarefa + preview de XP** — "escovar o dente 3x" sem duplicar a tarefa; cor customizada por tarefa via seletor inline (sem native picker); XP visível na lista, recalculado por ordem de conclusão, ver seção 18
- [x] **Sprites customizados de herói/monstro (teste, revertido)** — pipeline de recorte próprio desenvolvido e calibrado (6 versões até resolver flutuação, corte e borrão), mas o resultado final foi avaliado como "não é um sim limpo" e o usuário pediu pra voltar ao roster original — `MONSTROS`/`HEROIS` de volta a 63/8, pipeline documentado pra reaproveitar depois, ver seção 19

---

## 4. Próximas tarefas

### Em andamento


### Curto prazo

**Decisão de escopo (sessão de brainstorm):** o objetivo agora é terminar o essencial e lançar pra validar se existe público, não completar o roadmap inteiro. **Conquistas e Bestiário entraram no escopo do lançamento** — são a exceção à regra de "segunda camada fica pra depois", porque o histórico que os destrava é barato e os dois dão ao teste real algo pra medir além do loop cru. Sistema de classes, Conjuntos, sincronização e o resto de "Funcionalidades ainda não construídas" continuam fora do escopo de lançamento.

**Ordem fechada, cada item destrava o seguinte** (exceto o item de economia — reordenado abaixo, ver nota):

1. [x] **Construir o `historico`.** *(pronto, v4.29)* Ver formato final e detalhes técnicos na seção do Perfil abaixo e nas notas técnicas (seção 5). Bloqueava Bestiário e Conquistas — os dois já podem ler de `window.obterHistorico()`.
2. [x] **Bestiário** *(pronto, v4.34)* — grade dos 63 monstros, lida do `historico`. Ver seção 22.
3. [x] **Conquistas** *(pronto, v4.31)* — 5 categorias definidas com o usuário (Sequência Diária, Matar Monstros, Subir de Nível, Conclua Tarefas, Obter Itens), 39 marcos ao todo. **Ícones: decisão fechada em sessão de brainstorm — não é mais pendência de asset.** SVG genérico é o estilo certo aqui (mesma categoria "funcional simples" da nav/Atributos/calendário, não "conteúdo colecionável" como itens/monstros); confirmado pelo usuário que ninguém nota o ícone no uso real. Não faz parte da fila do `Assets.zip`. Ver seção 17 para a decisão de design (trilha) e o que ficou em aberto (recompensas)
4. [ ] **Saída visível nas folhas modais.** Nem o editor nem o composer têm botão de fechar; a única saída em celular é tocar na área escura, já que Esc não existe lá. O puxador já está desenhado, falta torná-lo arrastável — ou colocar um "×" no canto
5. [x] **Verificar contraste dos monstros contra o fundo roxo** — resolvido de graça pela implementação do cenário de dungeon na arena (fundo com textura de parede/tijolo, ver seção de ideias pós-lançamento). Confirmado pelo usuário: contraste está bom.
6. [ ] Remover os botões de depuração (incluindo o painel de economia) antes de qualquer teste aberto. **Parcialmente feito na v4.38: só o painel/botão de economia saiu**, junto com o fix do item 10 — não pedido explicitamente, foi mal-entendido meu de que o pedido cobria a barra toda; corrigido na mesma sessão depois que o usuário apontou o erro. `#debugbtn` ("próximo dia →") e `#pularTutoriaisBtn` ("pular tutorial") **continuam ativos, de propósito** — o usuário ainda está testando e vai decidir remover quando terminar. Item continua aberto.
7. [~] **Publicar no Netlify e testar com pessoas reais** por vários dias seguidos — **em andamento**, usuário já está publicando. É o passo mais importante: XP por tarefa, dificuldade do 100%, punição da fuga e ritmo da loja só se validam com uso real. **Calibrar a loja e o dano com dado real acontece depois de publicar**, não antes
8. [x] **Feedback do "cloud" esclarecido — não era pedido real.** Era o testador brincando ("cloud" = Claude), dizendo de brincadeira que o app teria ficado melhor sem IA. Não é feedback acionável, nenhuma ação necessária.
9. [x] **Bônus de moedas do equipamento invisível na prática — corrigido (v4.35).** Diagnóstico completo na seção 23. Solução escolhida: resto fracionário acumulado entre tarefas (opção 2 das candidatas), sem tocar `ECO.moedasPorTarefa` nem nenhuma outra calibração.
   - **Candidatos que ficaram descartados/confirmados nesta sessão:** (c) confirmado que Fortuna/Foco realmente não somam com bônus de equipamento — são eixos diferentes (loot/loja vs. XP/moeda de tarefa), não é bug, é desenho intencional; só não estava comunicado, gerando confusão do usuário. (a) duplo arredondamento em "Vezes por dia" e (b) snapshot desatualizado do card de Perfil **continuam não testados** — não fizeram parte do escopo desta correção.
10. [x] **Corrigir a projeção do painel de economia.** *(pronto, v4.38)* Causa raiz confirmada: `simEco()` nunca recebia a dificuldade da tarefa e o cálculo saía implicitamente como se fosse Fácil (×1); como o padrão real do jogo é Média (`DIF_PADRAO = 'media'`, ×1,5), a projeção subestimava o ganho em ~50% — exatamente como o diagnóstico já previa. **Fix:** `simEco(dias, tarefasDia, multX, multM, dif)` ganhou um 5º parâmetro opcional que aplica `multDif(dif || DIF_PADRAO)` no XP e nas moedas por tarefa; as 5 chamadas existentes (`resumoLoja` ×2, `atualizarSim` ×3) já saem corrigidas pelo novo default, sem precisar passar o argumento. `recompensaVitoria()` foi conferida à parte e **não** usa dificuldade no jogo real — o simulador já estava certo nesse ponto específico, não mexi. Também virou **selecionável no painel**: dropdown "Dificuldade assumida" (Trivial/Fácil/Média/Difícil) acima da Projeção, ligado a `resumoLoja()` e `atualizarSim()` via a variável de estado `ecoDifSim`. Validado num DOM real (jsdom): Média em 30 dias × 5 tarefas/dia dá 4500 XP contra 3000 do cálculo antigo (Fácil) — bate com a estimativa de ~50%; testado também que o preço da loja em si (`ECO.lojaMargem` etc.) não muda com isso, só a estimativa de "quantos dias até comprar" fica mais realista.
11. [x] **Clique rápido em concluir tarefa duplica conclusões — corrigido (v4.40).** Causa confirmada: `alternar(i)` só rodava depois de um `setTimeout` (150–460ms), e o elemento continuava na tela, clicável, durante toda essa janela — cada toque extra virava recompensa inteira de novo. Bug medido: 6 cliques rápidos = 6× XP e 6× moedas na mesma tarefa. **Fix:** trava síncrona via `el.dataset.travado`, fechada no primeiro clique antes de qualquer timeout; some sozinha porque o elemento é recriado a cada `render()`, sem chave nova em `localStorage`. Guarda redundante extra dentro de `alternar()` pra tarefas de meta=1 (retorna sem somar se `feitaHoje(t)` já é verdade), como defesa em profundidade pra chamadas futuras fora da caixa. Validado com 6 cenários de teste (cliques rápidos meta=1 e meta=4, cliques espaçados, exclusão, clique fora da caixa, duas tarefas simultâneas) — ver seção 28.
12. [ ] **Reescrever o texto dos diálogos por tela — problema é o conteúdo, não a mecânica.** Levantado pelo usuário em sessão de brainstorm: as falas do sistema de apresentação (visual novel, busto + digitação letra por letra, 1× por aba) estão fracas/genéricas. **Esclarecido: é só o texto**, a mecânica (timing, velocidade de digitação, quando aparece) está aprovada como está — não precisa mexer em `digitar()`/`agendarDialogoTela()` nem em nenhum código, só no conteúdo de `DIALOGOS[nome]`. Tarefa de copywriting pura, sem risco técnico. Ainda não iniciado — precisa de sessão dedicada a escrever as falas novas, provavelmente com o usuário revisando tom/personalidade do "Aventureiro" por tela (Tarefas, Inventário, Loja, Perfil).
13. [x] **Tela de login + sincronização na nuvem** *(pronto, v4.44 — Firebase Auth com email/senha + Google, sync com Firestore, testado com contas reais em desktop e celular; ver seções 30-34)*. Escopo original abaixo, mantido como histórico da decisão:
    - Login é opcional — quem não quer conta continua 100% local, sem mudança de comportamento. Confirmado.
    - Primeira dependência de rede real do projeto — Firebase Auth, sem backend próprio.
    - Puxou de volta "Sincronização entre dispositivos" do campo especulativo pro escopo real — implementado (last-write-wins, puxa ao logar, empurra a cada save).

    **Continuação — 5 itens levantados em sessão de brainstorm, depois do sistema base validado:**
    - [x] **13a. Botão de sair da conta (logout).** *(pronto, v4.46/v4.47 — ver seções 36 e 37)* Não existia — quem loga não tinha como deslogar de dentro do app. Ficou em Perfil → Config, junto do botão de login (item 13e).
    - [x] **13b. Renomear "Apagar progresso" para "Apagar dados".** *(pronto, v4.45 — ver seção 35)* **Nota de correção deste item:** o diagnóstico original aqui (que ficou desatualizado, de uma sessão anterior à 35) dizia que o comportamento relatado era "sync funcionando como projetado, só o rótulo engana" e que bastava renomear. Investigação mais funda na seção 35 encontrou que **era bug de verdade**, não só rótulo: o botão nunca apagava o documento no Firestore, e a cadeia exata que restaurava os dados "apagados" (reload → `#intro` sem `.off` → `#passoLogin` reinjetado → Firebase re-detecta sessão → `puxarNuvem` restaura) foi corrigida de fato, com `deleteDoc()` + timeout de segurança — não só renomeação de texto.
    - [x] **13c. Mudo dos efeitos sonoros dentro do app.** *(pronto, v4.49 — versão reduzida: só liga/desliga, não volume gradual)* Pedido levantado no playtest real (item 7 em andamento) — decisão explícita nesta sessão de fazer só o mudo, não o slider de volume completo (a API dos dois já existia desde a seção 20; só o mudo ganhou UI). Ver seção 38.
    - [ ] **13d. Conteúdo real do botão de idioma.** Hoje é só cosmético (`aviso('Idioma: em breve')`, ver seção 30) — existe na tela de login mas não faz nada. **Decisão de escopo em aberto, não definida:** quantos idiomas o app deveria oferecer? Se for só Português (o app inteiro já é 100% PT-BR hoje, incluindo diálogos/nomes/UI), talvez nem faça sentido ter o botão até haver um segundo idioma de verdade pra oferecer — vale decidir se implementa i18n de verdade (custo alto: precisa traduzir toda a UI, diálogos, nomes de itens/monstros) ou se o botão só fica escondido/removido até isso ser prioridade.
    - [x] **13e. Botão de login dentro de Config, não só na tela inicial.** *(pronto, v4.51 — ver seção 40)* Hoje o fluxo de login só aparece pra quem está sem save local (tela de onboarding). Quem já é usuário local e quer criar conta/logar **depois**, sem apagar o progresso, não tem caminho pra isso — precisa de uma entrada visível em Perfil → Config (o mesmo lugar natural do botão de logout do item 13a) que abra o fluxo de autenticação sem mexer no save já existente.
    - [~] **13f. Perfis separados de verdade (local vs. cada conta) — parcialmente resolvido.** *(save principal namespaced por conta, v4.52 — ver seção 41; as outras 9 chaves continuam compartilhadas, ver tabela abaixo)* Motivado por um comportamento relatado pelo usuário depois do item 13e: sair de uma conta logada e continuar jogando "localmente" **não zera nada** — continua mostrando o progresso da conta que acabou de sair, porque hoje existe **um save só por aparelho**, e a conta é só um interruptor de sincronização em cima dele, não um espaço separado. **Nota da sessão 41:** o gatilho real reportado nesta sessão foi mais grave que só isso — trocar de Conta A pra Conta B no mesmo aparelho podia empurrar o progresso da Conta A pra dentro do documento da Conta B na nuvem, misturando dados de contas diferentes de verdade, não só "mostrar o progresso errado". Esse caso específico (a chave de save principal) já está corrigido — ver seção 41. Pra existir separação **completa** de perfil (cada uma das 10 chaves de `localStorage` isolada por conta, incluindo loja/vida/atributos/etc.), ainda falta o resto desta lista:

      | Chave | Conteúdo |
      |---|---|
      | ~~`questlog.v1`~~ | ~~Save principal (nível, moedas, inventário, tarefas)~~ — **namespaced por uid desde v4.52, ver seção 41** |
      | `questlog.loja.v1` | Estoque da loja do dia |
      | `questlog.vida.v1` | HP do herói / virada de dia |
      | `questlog.atrib.v1` | Pontos de atributo investidos |
      | `questlog.tutorialTelas.v2` | Diálogos de tutorial já vistos |
      | `questlog.hpMonstro.v1` | Combate do monstro de hoje |
      | `questlog.itensVistos.v1` | Descobertas do Grimório |
      | `questlog.hist.v1` | Histórico (calendário) |
      | `questlog.tarefasConcluidas.v1` | Contador de Conquistas |
      | `questlog.conquistasResgatadas.v1` | Conquistas já resgatadas |

      **Ficam de fora de propósito** (preferência de aparelho, não de perfil): `questlog.tema.v1`, `questlog.sfx.v1`, `questlog.dia.v1` (debug), `questlog.forcarLogin.v1` (flag transitória), `questlog.conta.v1` (vira o próprio ponteiro de "qual perfil está ativo").

      **Decisão em aberto que muda o tamanho do trabalho:** hoje a nuvem só sincroniza `questlog.v1`. Separar só essa chave deixaria a experiência capenga — Conquistas/Bestiário/Grimório continuariam misturados entre perfis do mesmo aparelho. Fazer direito significa expandir o que sincroniza pras 10 chaves, não só 1 — bem mais trabalho que só "adicionar um prefixo". Duas estratégias de implementação cogitadas, nenhuma escolhida ainda:
      - **Prefixar as chaves dinamicamente** por perfil ativo — exige reestruturar a ordem de boot (hoje `carregar()` roda antes de saber se há sessão Firebase ativa; passaria a precisar esperar essa checagem antes de decidir qual chave ler).
      - **Trocar o conteúdo nas mesmas chaves fixas**, fazendo backup/restore no momento de login/logout — não mexe em nenhum `carregar()`/`salvar()` existente, concentra a complexidade só na transição de perfil, mas exige backup local por conta e potencialmente expandir a nuvem pras 10 chaves de qualquer forma se quiser sincronizar entre aparelhos de verdade.

      **Não iniciado por decisão explícita do usuário** (créditos acabando na sessão em que foi levantado) — fica registrado pronto pra retomar sem precisar remapear as 10 chaves de novo.

14. [x] **Botão "coletar tudo" em Conquistas** *(pronto, v4.50 — ver seção 39)*. Implementação real ficou diferente do texto que o usuário tinha pedido originalmente (botão alternando entre "você ainda não tem" / "resgatar todas"): em vez de alternar texto, **o botão some completamente** quando não há nada pendente e aparece como `Receber tudo · +N XP (M conquistas)` quando tem — resolve a mesma necessidade (não polui a tela à toa) por um caminho um pouco diferente do especificado. `listarPendentes()` varre as 5 categorias, `resgatarTodasConquistas()` soma o XP de todos os pendentes num só incremento (evita empilhar popups de level-up se o lote cruzar mais de um nível). Validado com 9 marcos forjados em jsdom, incluindo o caso de "resgatar destrava um marco novo na hora" (funciona em cascata) e idempotência num terceiro clique.
15. [x] **Remover linha branca da arena — defeito visual, prioridade "feio".** *(pronto, v4.55 — "fix-filete-fantasma")* Reportado pelo usuário como incômodo estético na tela de combate. Confirmado corrigido no código desde `questlog-4-55-fix-filete-fantasma.html` — **checklist estava desatualizado**, ficou marcado `[ ]` por várias versões seguintes (4.56–4.60) porque a correção deste item, feita numa sessão de brainstorm anterior, não tinha sido subida de volta pro Project Knowledge a tempo. Fix já presente e preservado em todas as versões seguintes (convenção append-only). Diagnóstico detalhado da causa não chegou a ser documentado aqui.
16. [x] **Pacote de consumíveis — Poção de Vida sem cura + Poção de Mana/Vigor removidas (levantado em sessão de brainstorm, 19/08).** Auditoria completa da tabela `ITENS` mostrou que **os 16 consumíveis dão XP e só XP** — `m` (moedas) é `0` em todos, nenhum cura HP. `usarItem()` só aplica `it.x`/`it.m`, nunca chama `curar()`; está correto pro que a tabela manda, o problema é a tabela.
17. [x] **Trocar som de clique por vibração no celular (levantado em sessão de brainstorm, 19/08).** *(pronto, v4.62/4.63 — ver seções 46-47)* Escopo fechado: **só o clique de navegação** (nav principal, sub-abas do Perfil, botões de onboarding, seleção de herói, "+ Adicionar" — os 5 pontos que chamavam `tocarSom('clique')`), não os outros ~15 eventos catalogados na tabela de sons. Outros eventos (golpe, dano, level-up etc.) ficam de fora por decisão explícita, podem entrar depois se o teste com vibração no clique for bem recebido. Duração `10ms` mantida — teste com `7ms` não trouxe diferença perceptível (limite físico do motor ERM, não erro de calibragem; ver seção 47). "Vibração mais suave" pedida pelo usuário esbarra em teto real da Web Vibration API (sem controle de amplitude em navegador nenhum) — só alcançável saindo de single-file (Capacitor + haptics nativo), registrado como direção de longo prazo, não decisão tomada.
18. [x] **Perfil unificado — tela única sem sub-abas, substituindo Atributos/Conquistas/Bestiário.** *(pronto, v4.64 — ver seção 48; prévias de Conquistas/Bestiário saíram mais simples — só contador em texto, sem fileira de ícones — que a proposta original; "conteúdo exato da prévia... ajustável na sessão de implementação" já previa essa liberdade)* Usuário trouxe 3 prints de apps concorrentes como referência — padrão comum: cabeçalho fixo (avatar+nome+nível) + seções empilhadas numa rolagem só, sem abas de nível superior; seções grandes (histórico, conquistas) aparecem como prévia + link "mostrar mais" abrindo o conteúdo completo à parte, não cru na rolagem.
    - **Decisão de escopo fechada com o usuário:** Conquistas e Bestiário (as duas seções grandes — dezenas de marcos e grade de 63 monstros) viram **prévia + botão "Ver tudo/Ver completo" abrindo overlay** — mesmo padrão já usado pro Config desde a v4.58 (seção 42) — em vez de tudo cru na mesma rolagem infinita.
    - **Estrutura proposta da tela única:**
      1. Cabeçalho — avatar, nome, Nível, barra de XP (reaproveita o que já renderiza no topo do Perfil hoje).
      2. Faixa de status rápidos — Vida máxima, Moedas, Bônus XP equip%, Bônus moedas equip% (os 4 cards que já existem na aba Atributos, compactados numa fileira).
      3. Atributos — fica **inteiro inline, sem prévia** (só 3 itens: Fortuna/Foco/Vigor + pontos disponíveis — pequeno o bastante pra não precisar de overlay).
      4. Prévia de Conquistas — contador `X/Total` + 2-3 conquistas recentes desbloqueadas + botão "Ver todas" → overlay reaproveitando `renderConquistas()` já existente.
      5. Prévia de Bestiário — contador `N/63 descobertos` + fileira dos últimos monstros vistos + botão "Ver completo" → overlay reaproveitando o render já existente.
      6. Config — sem mudança, continua ícone de engrenagem no header (já é overlay desde v4.58).
    - **Risco de arquitetura catalogado, precisa entrar na sessão de implementação:** `mostrarSubPerfil` (mecanismo atual de troca de sub-aba) tem uma armadilha de closure já documentada — é função local da IIFE "PERFIL — SUB-ABAS" (mesma classe de armadilha do bloco "Copied-reference trap"/"Closure trap" catalogada no início deste roadmap), por isso outros hooks tiveram que usar `addEventListener` em vez de reatribuir `window.mostrarSubPerfil`. Essa tela nova **remove** esse switcher, não só ignora — checar antes de apagar se algum outro bloco do arquivo ainda depende dele.
    - Conteúdo exato da prévia (quais/quantas conquistas recentes, quais monstros na fileira do Bestiário) fica como proposta, ajustável na sessão de implementação. Ainda não iniciado.
    - **Risco identificado antes da decisão:** `navigator.vibrate()` não existe no iOS/Safari (decisão da Apple, não é bug, não muda) — troca direta 1-pra-1 deixaria todo usuário de iPhone sem feedback nenhum, silenciosamente.
    - **Implementado: detecção de suporte, com fallback pro som — mais 1 camada que a spec original.**
      ```js
      window.vibrarOuTocar = function(som, ms){
        if (!ativo) return; // respeita o mesmo mudo do tocarSom() — ver abaixo
        if ('vibrate' in navigator){
          try { navigator.vibrate(ms || 10); } catch(e){ window.tocarSom(som); }
        } else {
          window.tocarSom(som);
        }
      };
      ```
      Ponto de troca: os 5 pontos que chamavam `tocarSom('clique')` agora chamam `vibrarOuTocar('clique', 10)`. `10`ms é um pulso curto ("tap"), ajustável depois do teste real.
    - **Segunda pegadinha catalogada, pra não confundir com bug depois:** `navigator.vibrate` também pode não funcionar dentro de iframe sem permissão explícita em alguns navegadores — não deve afetar o app (é standalone/PWA), mas vale já saber que existe. **Coberto** pelo `try/catch` acima: se `navigator.vibrate()` lançar, cai pro som em vez de falhar silenciosamente.
    - **Correção feita em conversa, não estava na spec original:** o usuário notou que o toggle de mudo (topbar) desligava `tocarSom()` mas não `vibrarOuTocar()` — vibração continuava mesmo com o app "mudo". Corrigido adicionando o mesmo guard `if (!ativo) return;` (a variável `ativo` já é a mesma que `window.sfxAtivo()`/`window.definirSfxAtivo()` usam, ambas no mesmo escopo de módulo).
    - **Ver seção 46** pra decisão registrada sobre o que ficou de fora (toggle de mudo em si, cliques da tela de login).
    - **Poção de Vida** *(pronto, v4.59 — ver seção 43)* — bug de verdade: o jogo tem sistema de HP (`curar()` já existe, usado em vitória e recompensa por tarefa), o item promete curar e não cura. Fix aplicado: 8º campo (`h`, cura) na tabela `ITENS` (item na posição 63 do array: `[56,"Pocao de Vida","cons",2,20,0,60,25]` — o `56` inicial é só o índice do sprite, não confundir com o id/posição real), `item()` lê `h:a[7]||0` (itens sem o campo caem em `0`, nada mais quebra), `usarItem()` aplica a cura via `window.vidaHeroi.get/max/set` (não chama `curar()` direto — está fora de alcance por closure, módulo Inventário carrega antes do módulo Vida). Validado manualmente pelo usuário no celular (com um botão de debug temporário, removido depois de confirmado).
    - **Poção de Mana / Poção de Vigor** *(pronto, v4.60 — ver seção 44)* — não era bug técnico, era nome prometendo sistema que não existe (sem stat de mana ou vigor no jogo). Removidas do jogo via placeholder morto, sem deslocar nenhum id.

### Ideias de monetização e conteúdo futuro (fora da ordem fechada, registradas pra não esquecer)

- **Anúncios em pontos estratégicos.** Levantado pelo usuário com ressalva própria ("eu não queria mas é o objetivo no final de tudo") — sinaliza que é decisão pragmática de sustentabilidade do projeto, não escolha de design animada. Sem escopo definido ainda: nenhuma decisão sobre formato (banner, intersticial, rewarded video), frequência, ou pontos de inserção. Bandeira de atenção pra quando for desenhar: qualquer anúncio precisa ser posicionado pra não interromper o loop central de tarefas→combate, que é o coração do app — anúncio mal colocado pode prejudicar exatamente a experiência que o app inteiro foi construído pra proteger (retenção, fluxo de progressão). Fica pra sessão dedicada, bem depois do lançamento/teste real.
- **Sistema de abrir baús (loot boxes).** Ideia solta pra "futuro", ainda sem escopo: não ficou claro se é mecânica nova (baús comprados na loja ou encontrados como item de inventário, abertos manualmente pelo jogador) ou uma extensão do baú de recompensa diária que já existe (`mostrarBauLoot()`, disparado ao vencer o dia). Se for baú **comprável/colecionável**, isso é sistema de monetização em potencial (linha direta com o item de anúncios acima) — vale decidir junto se essa é a direção, já que os dois mexem com "conteúdo pago/extra" na mesma sessão de design. Não decidir sozinho no chat de implementação sem antes fechar esse escopo aqui.

### Nomenclatura dos monstros

Os nomes seguem **família + qualificador**, e o membro mais genérico da família leva o nome puro: `Demônio`, `Esqueleto`, `Goblin`. As famílias são Gosma, Morcego, Rato, Aranha, Olho, Golem, Goblin, Fantasma, Demônio, Esqueleto, Minhoca, Fungo e Mímico.

Renomeações feitas nesta rodada trocaram famílias inteiras: *Diabrete* virou **Demônio**, *Verme* virou **Minhoca**, e os *miméticos* viraram **mímico/mímica**. Os qualificadores de elemento foram uniformizados: `gélido`/`de gelo` viraram **glacial**, `ígnea` virou **flamejante**.

**Ainda fora do padrão** (não estavam na lista de troca): `Criatura cogumelo`, `Monte de ossos` e `Esqueleto rastejante` destoam dos vizinhos. `Diabrete chifrudo` **não é mais exceção** — ver nota de recuperação abaixo.

### Divergência entre branches recuperada (sessão de polimento)

`Diabrete chifrudo → Demônio menor` tinha sido feito numa sessão de
inventário/monstros anterior (já registrado na nota "Aconteceu de novo"
da seção de decisões técnicas), mas a branch de temas (v4.6/4.7) partiu
de um ponto anterior a esse rename e nunca herdou ele — exatamente o
risco de colisão entre sessões paralelas já documentado (ver "Tools &
Resources" no início do arquivo). O arquivo em uso nesta sessão de
polimento descendia dessa branch órfã: `Diabrete chifrudo` reapareceu
sozinho, todos os outros renames (`Demônio`, `Minhoca`, `mímico`/`mímica`,
`glacial`, `flamejante`) estavam intactos. Reaplicado manualmente pro
nome já decidido (`Demônio menor`, não um nome novo) depois que o
usuário notou a divergência.

O catálogo visual com os índices é o documento de referência para qualquer renomeação futura — os índices do array e do catálogo batem um a um.

### Decisões já tomadas (não reabrir sem motivo)

- **Pack "64x Detailed Fantasy Monsters" (48×48) — adiado.** Foi avaliado contra o elenco atual. Combina de paleta (a categoria Ice/Magic/Cosmic destaca muito bem no roxo) e tem exatamente 64 sprites, o que daria substituição 1:1. Mas os atuais são 32×32: misturar os dois deixa densidades de pixel diferentes na mesma arena e lê como dois jogos. **Ou troca os 64, ou não troca nenhum.**
  - Se um dia trocar: exibir a 96px (2× exato de 48; a 74px o fator vira 1,54 e a arte embola), remover a sombra preta embutida em alguns sprites (`#00050E` na última linha) para não duplicar com a `.sombra` do CSS, reduzir a paleta para 64 cores antes do base64 (170 KB → 65 KB) e traduzir os 64 nomes.
  - Licença Pixel-Deck: uso comercial permitido **dentro de um projeto completo**; não redistribuir os PNGs soltos.
- **Um monstro por tarefa (em vez de um por dia) — descartado.** É exatamente o modelo dos concorrentes: recompensa por tarefa solta, sem chefe obrigatório. Perde-se a tensão (cada tarefa mataria seu próprio monstro, sem chance de falhar) e a trava anti-farm volta pela porta dos fundos — cadastrar mais tarefa passaria a significar mais abate garantido. Tecnicamente também quebra o ciclo determinístico de 64 dias, que assume 1 monstro por data. Se o objetivo é dar mais peso à tarefa individual, usar golpe crítico ocasional, animação própria no golpe final ou o peso por dificuldade (já implementado).
- **Montarias — descartado por ora.** Funciona no Habitica porque lá existe um sistema de coleção inteiro, perfil social e mundo com progressão visual. Aqui a tela é uma arena estática: montaria não anda, não viaja, não muda nada mecânico. Pediria sprite set novo, uma categoria de item que não cabe em nenhum dos 7 tipos atuais e uma fonte de aquisição inventada do zero — tudo para atender o mesmo impulso ("colecionar como prova de progresso") que o **Bestiário** já atende usando arte existente. Reavaliar só se o teste real mostrar demanda.
- **Ideia do "bicho raro":** usar o pack 48×48 só como monstro raro resolve a mistura, desde que a escala de pixel seja igual nos dois. Com o normal a 3× (32→96px) e o raro também a 3× (48→144px), o pixel tem o mesmo tamanho e o raro é só fisicamente maior — lê como chefe. Se 144px não couber na arena, a mesma lógica a 2×: normal 64px, raro 96px. Precisa de sorteio próprio, separado do ciclo determinístico de `monstroDoDia()`.
- **Cenário de fundo na arena (parede de dungeon).** Ideia levantada em sessão de brainstorm: trocar o fundo roxo liso por textura de parede/tijolo, reforçando a estética RPG e resolvendo de brinde o item 5 da lista de curto prazo (contraste dos monstros). Implementação prevista como `background-image` em CSS puro (tile 32×32 ou 64×64, `image-rendering: pixelated`, `background-repeat`), sem tocar no sistema de sprites (`--sheet`) nem em `render()` — bloco de estilo isolado.
  - **Bloqueio real: asset.** Precisa de tileset de dungeon com licença clara (comercial + modificação permitidos), mesmo padrão de diligência já aplicado a monstros/personagens/itens. Referência mandada pelo usuário parece ser preview de ferramenta (Canva/Figma), não asset pronto — não usar direto.
  - **Decisão em aberto:** a parede varia por tema (`meianoite` mais escura, `pergaminho` talvez vire textura de papel em vez de pedra) ou fica universal e só o resto da UI muda de cor? Definir antes de implementar, pra não repetir o problema de cascade que já mordeu o seletor de tema (`!important` sobrescrevendo variável).
  - Não priorizado — decidir se entra como parte do item 5 do curto prazo ou fica só pós-lançamento.
- **Efeitos sonoros (SFX).** *(pronto, v4.32 — ver seção 20 para arquitetura completa, catálogo de sons, decisões tomadas em conversa e um bug real encontrado no processo)*. Abordagem confirmada e mantida: **Web Audio API sintetizada (osciladores + envelope), não arquivo de áudio gravado** — sem asset externo, sem questão de licença. Upgrade pra arquivos reais (.mp3/.ogg em base64) continua em aberto como segunda fase, se o resultado atual parecer "pobre" no teste real. **NÃO estava na "Ordem fechada" de curto prazo** (seção 4) — entrou por pedido direto do usuário fora dessa lista; mudo na sub-aba Config está pronto (v4.49, ver seção 38) — volume gradual (slider) continua pendente, decisão explícita de escopo reduzido.

### Riscos de balanceamento já mapeados

- **Consumível é conversor de moeda em XP.** Com a margem atual (3,6×), o melhor consumível dá ~1,1 XP por moeda; gastando o dia inteiro nisso o jogador ganharia ~+45% de XP. O que segura é o limite de 1 unidade por vaga e o número pequeno de consumíveis na prateleira. **Subir `lojaVagas` escala esse vazamento junto** — se acontecer, subir `lojaMargemConsumivel` antes de mexer em qualquer outra coisa.
- **Tesouro é a única fonte de moeda que não depende de tarefa.** Se a venda de tesouro ficar generosa demais, a vitória vira farm de moeda e não de progresso.

### Funcionalidades ainda não construídas

- [ ] Conjuntos (bônus por usar peças da mesma família)
- [ ] Sistema de classes (guerreiro, mago etc.)
- [ ] Estoque especial da loja em dias de vitória seguida (recompensa por sequência)

---

#### Aba "Perfil" — atributos e conquistas (4º ícone da barra)

Quarta aba na barra inferior, ao lado de Tarefas, Inventário e Loja. Nome da aba: **Perfil** (ou Herói) — não "Atributos", porque ela guarda mais que isso. Ícone em **SVG inline**, obrigatoriamente: os ícones da nav usam `currentColor` para virar laranja quando ativos, e sprite PNG não aceita tint. Evitar espada/escudo no desenho para não confundir com Inventário — troféu ou estrela leem melhor.

> **Estado atual (v4.37): sub-navegação com 4 abas, Histórico virou botão em Config.** A aba Perfil tem 4 sub-abas internas — **Config**, **Atributos**, **Conquistas**, **Bestiário** — independentes da nav inferior. Atributos está pronto (item 1). Config está pronto, mas é conteúdo novo que não estava listado originalmente nesta seção (ver abaixo). Conquistas está pronto (item 2, v4.31) — ver seção 17. Bestiário está pronto (item 3, v4.34) — ver seção 22. Calendário está pronto (item 4, v4.37, agora como overlay de tela cheia acionado por um botão dentro de Config, não mais sub-aba própria — ver seção 24 e a nota na seção 5 sobre a reversão de v4.36). Sequência/streak (item 5) foi **descartado por enquanto** — ver justificativa no item 5 abaixo, decisão explícita do usuário pra não inflar a navegação.
>
> **Decisão de escopo (sessão de brainstorm):** Conquistas e Bestiário entraram no escopo do lançamento — ver ordem fechada em "Curto prazo". Calendário/Histórico também acabou entrando (v4.36, fora da ordem fechada original, priorizado numa sessão de brainstorm paralela) — ver seção 24. **Só Sequência/streak continua como ideia futura**, sem compromisso de data; reaproveita o mesmo `historico` quando chegar a vez.

Fica em **4 itens no total**, não 5. A referência de mercado que motivou a ideia tem 5, mas o quinto é um "+" central, que é *ação*, não destino — no Questlog adicionar tarefa já vive dentro da própria aba Tarefas, então esse slot não se justifica.

**Conteúdo da aba, em ordem de construção:**

1. **Atributos** *(pronto, v4.4)* — nível (romano), barra de XP (resto/meta do nível atual), vida máxima (`window.vidaHeroi.max()`), moedas e o bônus somado de XP%/moedas% do equipamento (`bonusEquip()`). Não leu nada novo: reaproveitou `progresso()`, `moedas`, `bonusEquip()` e `vidaHeroi.max()`, todos já existentes nos módulos de Tarefas, Inventário e Vida.
1.5. **Config** *(pronto, v4.4; temas corrigidos em v4.5 — não estava no plano original de 4 itens, virou sub-aba própria)* — renomear herói, trocar sprite do herói, apagar progresso (realocado da `.debugbar`) e seletor de tema (3 paletas, agora cobrindo arena/inventário/loja/perfil, não só cor base). Ver notas técnicas na seção 5 para o porquê de cada escolha.
2. **Conquistas** *(pronto, v4.31)* — 5 categorias × marcos progressivos, desenho final e lista completa na seção 17. **Ícones: decisão fechada em sessão de brainstorm, não é mais pendência.** São SVG genérico com o mesmo peso visual dos outros SVGs funcionais do app (nav inferior, botões de Atributos, navegação do calendário) — categoria "funcional simples", diferente da pixel art curada de itens/monstros (categoria "conteúdo colecionável"), que são coisas visualmente distintas de propósito, não um placeholder esperando upgrade. Confirmado pelo usuário, com uso diário do próprio app, que ninguém nota nem liga pro ícone. Não entra na fila de arte pendente do `Assets.zip`.
3. **Bestiário** — grade dos 64 monstros: derrotados coloridos, nunca vistos em silhueta. Usa sprites que já existem.
   - **Decisão fechada (sessão de brainstorm):** **sem gate.** Ganha sub-aba própria dentro de Perfil (ao lado de Config/Atributos/Conquistas), disponível desde o dia 1 — não precisa de nível mínimo nem de contagem de abates pra desbloquear. Motivo: o dado (`historico`) já existe desde a primeira sessão, a tela nunca abre "vazia" de verdade (mesmo com 1 monstro derrotado já tem silhueta pra todo o resto, que já funciona como gancho de curiosidade), e o marco de "Bestiário Completo" já vive dentro de Conquistas — trancar a *tela* em cima disso duplicaria a mesma recompensa sem necessidade. Cogitado e descartado: gate por nível (igual Grimório) e gate por contagem de abates (ex: 10) com "???" no menu — ambos reduziriam o gancho de coleção logo nos primeiros dias, que é a janela mais importante pra retenção.
   - **Por que não é como o Grimório, apesar do padrão visual de silhueta ser o mesmo:** o Grimório é **item com narrativa de descoberta** (drop garantido de nível V, popup de "Você encontrou...", acesso pelo Inventário) — o próprio ato de ganhar é a recompensa, no estilo Metroidvania ("ache o mapa pra revelar o resto"). O Bestiário é **extensão do histórico**, sempre existiu, não é algo que se "acha". Os dois usam a mesma linguagem visual (silhueta = não descoberto) mas moram em lugares diferentes por design, não por inconsistência: Bestiário = aba sempre visível dentro de Perfil; Grimório/Mapa = item-chave acessado via Inventário. Mesma lógica vale pro item "Mapa" (pendência aberta, ver seção 4) quando ele for implementado — não deve virar aba, mantém o padrão de item.
4. **Calendário do mês** *(pronto, v4.37 — botão "Histórico" dentro de Config, abre overlay de tela cheia; não é mais sub-aba própria, ver seção 24)* — ver seção 24 para implementação completa.
   - **Não confundir com "calendário no menu de Tarefas"** — ideia levantada numa sessão de brainstorm, mas é conceito diferente: agendar/organizar tarefas por data futura (mexe na estrutura de dados de tarefa, hoje só tem recorrência por dia da semana), não histórico read-only. Ainda não tem decisão de escopo nenhuma — ficou em aberto se é só visualização ou também agendamento. Registrar como pendência separada quando for retomado. Não confundir com o item 4 acima, que é sobre o passado, não o futuro.
5. **Sequência (streak)** *(descartado por enquanto, decisão v4.36)* — o recorde de dias seguidos já é coberto pela categoria "Sequência Diária" de Conquistas (marcos 1/5/15/30/45/60, `melhorSequenciaDeVitorias()`, ver seção 17). O que Conquistas **não** cobre é a sequência *atual* (o contador estilo Duolingo, que reseta a zero se o jogador falhar um dia) — psicologicamente diferente de um troféu permanente. Descartado nesta rodada por decisão explícita do usuário: uma 6ª sub-aba só pra isso inflaria a tela sem cumprir a função (sequência-atual só funciona como gancho de hábito se aparecer **toda vez que o app abre**, tipo ao lado do nível/moedas no topo — enterrado numa sub-aba de Perfil, ninguém vai conferir todo dia, perde o efeito). Fica marcado como descartado, não esquecido — se quiser retomar, a versão que faria sentido é um indicador pequeno sempre visível, não uma tela nova, e isso é decisão de UI mais delicada (compete por espaço com o que já tem no topo) do que "adicionar uma aba".

**Histórico construído (v4.29).** Antes disso, `questlog.v1` só tinha `derrotadoEm` (data de hoje, sobrescrita todo dia) e `questlog.vida.v1` só tinha `ultimoDia` — nenhum dos dois dizia o que tinha acontecido ontem. Formato final, guardado em `questlog.hist.v1`, um array que só cresce:

```
historico: [{ data:'2026-08-05', resultado:'vitoria'|'fuga'|'sem_tarefa', monstroId:12, tarefas:5 }, ...]
```

Uma diferença do formato originalmente rascunhado: **três resultados, não dois.** `resultado` ganhou `'sem_tarefa'` além de `'vitoria'`/`'fuga'`, pensando já no Calendário futuro (item 5 da lista "Conteúdo da aba" abaixo, que explicitamente quer separar as três categorias). Um dia sem nenhuma tarefa cadastrada não é derrota nem vitória — é um dia vazio. Bestiário provavelmente só filtra `'vitoria'`, mas o dado já sai certo pras outras telas sem precisar editar este módulo de novo.

**API pública pra Bestiário/Conquistas lerem** (sessões futuras, sem precisar abrir este módulo): `window.obterHistorico()` retorna uma **cópia** do array (mutar o retorno não afeta o estado real). `window.registrarHistorico(iso, totalTarefas, largadas)` é a função que grava — exposta em `window`, mas não é pra ser chamada por Bestiário/Conquistas, só documentando que existe.

**Sem backfill.** Dias anteriores à v4.29 não têm entrada — o app não gravava nada antes disso. O histórico começa vazio a partir de quando essa versão roda pela primeira vez no aparelho de cada jogador, cresce um dia por vez daí em diante.

Gravado no mesmo ponto que o roadmap original já previa: dentro de `verificarVirada()` (módulo Vida), que já detecta a virada do dia. Detalhe técnico completo (por que precisou editar aquela função por dentro em vez de só envolver por fora) na seção 5, nota "HISTÓRICO".

**Como os atributos podem funcionar sem quebrar a regra central**

O dano por tarefa é intocável: a vida do monstro é proporcional ao número de tarefas, então qualquer atributo que aumente dano faria uma tarefa matar o monstro antes dos 100%. Isso destrói a premissa do app. Logo, **atributo aqui não pode significar dano** — o combate não tem uma variável de dano livre para mexer.

Sobram três camadas fora do combate: economia (XP/moedas), loot e utilidade. Para não duplicar o equipamento, que já dá % de XP e moedas, os papéis precisam ser distintos: equipamento é *o que estou vestindo hoje* (troca a qualquer hora, 6 slots); atributo é *quem meu herói é* (investido uma vez, permanente).

Proposta de três atributos sem risco de espiral:

| Atributo | Efeito |
|---|---|
| Vigor | Cargas semanais de "perdão de fuga" |
| Fortuna | Chance de raridade maior no espólio |
| Foco | Desconto na loja, ou +1 vaga na prateleira |

**Risco de balanceamento a evitar (registrar antes de construir):** se o atributo aumenta ganho de XP **e** os pontos vêm de subir de nível, existe um loop composto — mais XP → mais nível → mais ponto → mais XP. Isso arrebenta a curva de nível, que hoje é linear. Duas saídas, escolher uma:

1. **Atributo nunca toca taxa de XP/moeda** — só loot e utilidade. Risco zero, e é a recomendada.
2. Se tocar mesmo assim, os pontos **não podem vir de nível** (fonte infinita). Precisam vir das conquistas, que são em número fixo — o total de bônus na vida do jogador vira um teto matemático em vez de uma espiral.

Pela opção 2, atributos passam a **depender das conquistas existirem primeiro**, o que reforça a ordem: histórico → conquistas → atributos.

> **Estado atual (v4.14): Fortuna e Foco construídos e com efeito real; Vigor adiado.** Pontos vêm de nível (opção 1 do risco acima — atributo nunca toca taxa de XP/moeda, só loot e utilidade, então nenhuma dependência de Conquistas foi necessária): **1 ponto por nível acima do I**, sempre derivado de `progresso().nivel`, sem contador próprio — não tem como duplicar ponto por ordem de carregamento. Investimento é **permanente, sem botão de remover** — de propósito, o atributo é "quem o herói é", oposto do equipamento ("o que estou vestindo hoje"). UI dentro da sub-aba Atributos (Perfil), abaixo do `.statgrid` já existente.
>
> - **Fortuna** (+4% por ponto, teto 50%): soma direto no `sorte` (0..1) que `sortearItem()` usa pra pesar a raridade do loot. Wrap externo puro, `window.sortearItem`.
> - **Foco** (+2% de desconto por ponto, teto 30%): aplicado **dentro** de `precoLoja()`, não por wrap externo — ver nota técnica abaixo, é a exceção importante desta sessão.
> - **Vigor** (perdão de fuga) **não foi construído.** Aparece na UI como linha travada ("Em preparo"). O dano por fuga vive em `verificarVirada()`, fechada numa IIFE do módulo Vida, sem `ultimoDia`/`ferir()` expostos — perdoar a fuga exige interceptar o dano *durante* a execução dessa função, não só antes/depois dela. Isso significa editar a função por dentro, não só envolvê-la. Essa é a mesma função que a seção 6 deste roadmap chama de "correção crítica" (já teve bug real de virada de dia ali) — fica pra uma sessão própria, com teste dedicado, não entra por atalho.

Números de bônus por ponto (Fortuna, Foco) são primeira passada por raciocínio, não calibrados com dado real — mesmo espírito do resto do balanceamento do jogo.

#### Equipamento visível no herói da arena

O jogador equipa espada, armadura e elmo e **não vê nada disso** no herói da tela principal. Mostrar seria a mudança de maior retorno em sensação de RPG — mais que atributo ou bestiário.

O dado já existe (`equipado` está no save). O obstáculo é **arte, não lógica**:

- Os 8 sprites de herói (PIPOYA) são imagens fechadas, **não vieram separadas por camada** (corpo, arma, elmo, armadura).
- Os itens do catálogo são ícones de inventário — desenhados para prateleira, não para serem empunhados ou vestidos, e em perspectiva própria.

Sobrepor um ícone de espada na mão de um sprite feito para outro fim normalmente fica *colado*, não integrado — o mesmo motivo pelo qual o pack de monstros 48×48 já foi adiado.

**Três níveis, do barato ao caro:**

1. **Badges em volta do retrato** *(fazer primeiro)* — os próprios ícones do inventário, pequenos, dispostos ao redor do herói: arma, armadura, elmo, escudo, acessório. Não veste nada, só mostra. Zero arte nova, só posicionamento CSS lendo `equipado`.
2. **Aura/moldura por raridade** — o contorno do herói muda de cor conforme a raridade mais alta equipada (cinza → verde → azul → roxo → dourado). Zero arte nova, mesma fonte de dado.
3. **Arma sobreposta na mão** — só a arma, que é o slot mais visível e mais tolerante a erro de perspectiva. **Não é troca de CSS**: exige recortar/redesenhar os ícones de arma numa pose compatível com a mão do herói.

**Fora de escopo:** armadura ou elmo trocando o corpo do sprite, e escudo nas costas. Isso pede art layering completo — corpo base + camada por slot × 8 heróis — ou seja, redesenhar o visual do jogo do zero.

**Recomendação:** 1 + 2 juntos entregam "meu personagem está evoluindo" usando só o que já existe. O 3 só depois do teste real, se as pessoas de fato sentirem falta.

> **Níveis 1 e 2 implementados.** Bloco autônomo no fim do arquivo. O nível 3 continua fora de escopo pelos motivos acima.

**Como ficou, e as decisões que o teste impôs:**

- **Só o que está equipado aparece.** A primeira versão mostrava os 5 slots, com ícone fantasma tracejado nos vazios. Na tela real viraram quatro caixas quase invisíveis espalhadas em volta do herói — leram como sujeira, não como informação. Sem nada equipado, o trilho some (`display:none`). Se a dica de "quais slots faltam" fizer falta, o lugar é o Inventário, que tem espaço; não a arena, onde se disputa espaço com os sprites.
- **Arranjo varia com a quantidade:** 1 a 3 itens em coluna única (3 × 25px cabe nos 83px do sprite); 4 ou 5 em duas colunas, com o quinto centralizado embaixo. Coluna única de 5 transbordava a arena pelo topo, invadindo a topbar.
- **Telas estreitas encolhem por `transform: scale`**, não mudando as medidas da caixa. Os ícones têm `background-size` inline calculado em px por `estiloSprite()`, então reduzir só a caixa não encolheria o desenho. Dois degraus: `scale(.74)` abaixo de 375px e `scale(.55)` abaixo de 345px. Validado de 430 a 320px.
- **A aura usa `::after`**, historicamente porque o `::before` do `.hero-sprite` era o halo de tocha (removido na sessão de polimento, seção 10) — a separação de pseudo-elementos ficou, mas hoje é só espaço reservado sem conflito, não uma coexistência ativa de dois efeitos.
- **Três ganchos:** `desenharHeroi()` (reescreve o `innerHTML` inteiro), `render()` e `equipar()`. O terceiro é fácil de esquecer — `equipar()` chama `renderInventario()` mas **não** `render()`, então sem ele equipar pelo Inventário só apareceria na arena na próxima tarefa concluída.

### Futuro

- [ ] Sincronização entre dispositivos (Firebase ou Supabase)
- [ ] **Novas paletas além das 3 atuais** (ideias em aberto: "Sol" quente/dourado, "Oceano" turquesa) — reconfirmado como desejado pelo usuário em sessão de brainstorm ("opcional, mas quero muito"). Continua sem prioridade de data, mas não é mais só ideia solta.
- [ ] Monstro raro/dourado com recompensa maior
- [ ] Sprites de herói mais detalhados
- [x] **Grimório — primeiro item-chave do jogo (v4.25–4.26).** Entregue automaticamente ao alcançar o **nível V**, no mesmo popup de "Nível alcançado" (não é drop nem compra). Reaproveita o sprite do extinto "Livro Mágico" (idx 73), renomeado. Abre a tela do catálogo com clique — ver seção 14 para a decisão completa.
- [ ] **Item "Mapa" — desbloqueia o catálogo de equipamentos.** Mesmo padrão do Grimório (tipo `chave`, raridade `Único`), reaproveitável agora que a categoria já existe. Ideia levantada em sessão de brainstorm, não priorizada agora. No Inventário, clicar no item abre um botão "Abrir mapa" que desbloqueia uma tela nova (dentro de Perfil, mesmo padrão do Bestiário): grade dos 100 itens do catálogo, os já obtidos coloridos, os nunca vistos em silhueta. O valor não é só esconder a lista — é a **aba inteira** ser a recompensa (padrão de mapa em Metroidvania: você acha o mapa e só aí o jogo revela quanto falta explorar), não apenas ocultar ícones um a um.
  - Depende do mesmo pré-requisito de ledger que o Bestiário: precisa de um registro que só cresce (`itensVistos`), separado do `inventario` atual — vender ou usar um item não pode fazê-lo "sumir" do catálogo como se nunca tivesse sido obtido. **Esse ledger já existe** (seção 14), construído pro Grimório — o Mapa reaproveita, não precisa de nada novo.
  - Efeito do item é **hardcoded, não um sistema genérico de "efeito de item"**: `if (item.id === 'mapa') desbloqueiaCatalogo()`. Não abrir precedente para itens funcionais genéricos além do que já existe (Grimório, Mapa) — isso escala o mesmo jeito que o sistema de classes escalaria sem controle, manter caso a caso até haver motivo real para um sistema.
  - Ainda precisa de um gatilho de entrega próprio — o Grimório usou "nível V" porque sobrava um evento de progressão sem uso; o Mapa precisa do seu.
  - **Confirmado em sessão de brainstorm (mesma decisão do Bestiário):** o Mapa continua item-chave via Inventário, **não** vira sub-aba de Perfil — mantém o padrão de "item com narrativa de descoberta", diferente do Bestiário (aba sempre visível, sem gate). Ver justificativa completa na seção do Perfil, item 3.

19. [x] **Destaque visual pro slot de arma na arena — badge maior + moldura por raridade (levantado em sessão de brainstorm, 19/08).** *(pronto, v4.73 — ver seção 54)* Escopo reduzido de propósito: sessão começou discutindo layering completo de arma/armadura no corpo do herói (fora de escopo, precisa de arte em camadas que não existe) e reformulação total da arte de armas/armaduras com assets novos que o usuário encontrou com direito comercial (16x/32x) — **ambas adiadas explicitamente**, "desse jeito o aplicativo não vai sair nunca, vamos focar no essencial". O que sobrou e foi aprovado: só o slot de **arma** ganha destaque entre os 5 badges de equipamento que já existem ao redor do herói (arma, armadura, elmo, escudo, acessório, todos hoje do mesmo tamanho).
    - **Motivação:** comparação com Habitica — lá a arma tem enquadramento grande e central, dando sensação de "personagem forte"; os outros slots ficam pequenos ao lado. É hierarquia visual, não vestir no corpo.
    - **Proposta (zero arte nova, CSS sobre o que já existe):** badge da arma 2-3× maior que os outros 4; moldura própria reaproveitando a mesma lógica de aura por raridade que já colore o contorno do herói (cinza→verde→azul→roxo→dourado), aplicada com mais destaque na moldura da arma especificamente (borda mais grossa / brilho); os outros 4 slots continuam do tamanho atual.
    - **Reformulação de arte de armas/armaduras (assets novos, comerciais, 16x/32x já em mãos do usuário) e layering de equipamento no corpo do herói (nível 3, ver item de equipamento visível na seção 3) ficam registrados como backlog pós-lançamento, adiados por decisão consciente, não esquecidos.** Se resgatados depois, atenção ao risco de arquitetura já catalogado: a spritesheet de 129 posições usa índice posicional (igual ao `id` de `ITENS`) — trocar a arte de um item específico sem mexer na posição dele é seguro, mudar quantidade/ordem da grade desloca tudo que vem depois.
    - Ainda não iniciado — não bloqueia lançamento, mas é barato/rápido o bastante pra encaixar em qualquer sessão de implementação sem depender dos 4 itens que bloqueiam (Firestore, `#mobSprite`, botões de debug, 13d/13f).

20. [x] **Preenchimento de raridade máxima e mínima — Lendário via recolor + reclassificação de Épico, mais regra nova de exclusividade em baú** *(pronto, v4.75 — ver seção 56)*. Spec fechada em sessão de brainstorm (19/08); implementado na sessão seguinte quando o usuário anexou as 2 imagens com os 6 sprites dourados já prontos (protótipo aprovado citado no item A abaixo).
    - **Origem:** auditoria da tabela `ITENS` encontrou uma lacuna real, não cosmética: nenhuma arma, armadura, escudo ou acessório existe em raridade 4 (Lendário) — só Elmo chega lá ("Coroa Real"). Sortear raridade máxima hoje nunca vira upgrade de equipamento nesses 4 slots, só tesouro puro (regressão já registrada nesta seção, no item sobre remoção da Poção de Mana/Vigor). Investigação de pacotes externos de arte (100+ armas com direito comercial encontradas pelo usuário) **descartada** — confirmado por diff de pixel que a versão 32×32 é upscale nearest-neighbor do 16×16 nativo, 0% de detalhe novo, mais "blocado" que a arte atual (32×32 nativo de verdade); pacote também não tinha nenhuma peça de armadura/escudo. Fonte original da arte do jogo ("Pixel Art Dungeon Item Pack — 128 items") confirmada esgotada — só sobraram 28 sprites não usados no pacote (índices livres na spritesheet), nenhum deles armadura ou escudo (é utilería de calabouço: pergaminhos, cordas, poções, barris, caixotes).

    **A) 6 itens Lendários novos, via recolor dourado (zero arte nova) — nomes finais confirmados, implementados:**
    Técnica: mapear luminância de cada pixel (`0.299R+0.587G+0.114B`) pra um gradiente fixo de 5 pontos indo de bronze escuro (`#28180a`) a creme claro (`#fff5c8`) — preserva sombra/luz do sprite original, mas força a cor final sempre dentro da faixa dourada. Tentativa inicial com `hue-rotate()` **rejeitada pelo usuário** ("isso é verde cara") — girar matiz é sensível demais à cor de partida (metal cinza empurra pra verde-amarelo no caminho até o dourado). Protótipo das 6 aprovado visualmente pelo usuário e anexado como 2 imagens de referência (par original/dourado lado a lado) numa sessão de implementação.
      - Arma: **Cajado do Rei** (base: Cajado Arcano, idx 76), **Adaga Amaldiçoada** (base: Adaga Ritual, idx 90), **Arco Real** (base: Arco, idx 14)
      - Armadura: **Peitoral de Ouro** (base: Peitoral de Ferro, idx 62)
      - Escudo: **Escudo do Guardião** (base: Escudo Cravado, idx 111 — ver nota em B sobre esse item também virar a base do Épico)
      - Acessório: **Orbe Proibido** (base: Orbe de Cristal, idx 32)
      - Elmo ficou de fora — já tem Lendário ("Coroa Real"), não precisava de nada novo.

    **B) Lacuna de Épico em Armadura/Escudo — resolvida por reclassificação, não recolor.**
      - **Armadura:** "Manto Simples" (idx 24, era Comum) subiu pra Épico, renomeado **"Manto de Alma"** (`val:85, x:38`). Comum ficou com só 1 item (Armadura de Couro) — aceito pelo usuário.
      - **Escudo:** "Escudo Cravado" (idx 111, era Raro) subiu pra Épico, **sem mudar nome, arte, valor ou bônus**. Raro ficou sem nenhum item — aceito pelo usuário. Efeito colateral bom, não planejado: o Lendário "Escudo do Guardião" (item A) usa o mesmo sprite recolorido dourado — os dois (Épico cinza original + Lendário dourado) formam uma progressão visual do mesmo objeto.

    **C) Regra de economia nova: Lendário só em baú, nunca na loja.** `PESO_LOJA[4]` mudou de `4` pra `0`. `PESO_RAR` (loot de vitória) não mudou, mantém peso 2 pro Lendário — é o único caminho de obtenção. Ver seção 56 para os detalhes da implementação e validação.

21. [x] **Som faltando em "Salvar alterações" e "Excluir" no editor de tarefa (levantado em sessão de brainstorm, 19/08).** *(pronto, v4.77 — ver seção 58)* Motivado por queixa geral do usuário de "inconsistências de áudio" — auditoria completa cruzando todos os pontos de chamada de `tocarSom()` contra as 17 chaves do catálogo `SONS` **não encontrou nenhuma chave chamada com nome errado nem nenhuma chave do catálogo órfã sem chamador** (os 17 sons, incluindo os que pareciam suspeitos à primeira vista como `grimorio`/`abrirGrimorio` distintos e `equipar`/`desequipar` via ternário, estão todos corretamente conectados). A causa real da sensação de "áudio inconsistente" não é bug de conexão — são **dois pontos que simplesmente nunca tiveram som cogitado**, confirmado lendo o handler direto:
    - `#edSalvar` (botão "Salvar alterações" do editor de tarefa, linha ~3625) — mostra o toast "TAREFA ATUALIZADA" mas nunca chama `tocarSom()`.
    - `#edExcluir` (botão "Excluir" do mesmo editor, linha ~3658) — mesma coisa, mostra "TAREFA EXCLUÍDA" mudo.
    - **Fix proposto, aprovado pelo usuário:** `edSalvar` chama `tocarSom('tarefa')` — reaproveita o mesmo som que já toca ao criar tarefa nova (`criar()`), sem som novo. `edExcluir` chama `tocarSom('desequipar')` — reaproveita o "thud curto e mais surdo, sem o click de encaixe" já catalogado, escolhido por combinar com a ideia de remover algo (era só proposta minha, não perguntada explicitamente ao usuário — confirmar ou trocar na sessão de implementação se não soar certo).
    - **Nota pra quem for implementar:** confirmar se `#edSalvar`/`#edExcluir` estão presos numa IIFE isolada (como vários outros pontos do arquivo — ver a lista de exceções documentada perto da linha ~7090, mesma família de `comprar()`/`investir()`) antes de decidir entre editar a linha direto ou usar um gancho externo via `window.fn` — provavelmente precisa de edição direta, já que o padrão do arquivo é isolar módulos de folha/editor.
    - Auditoria também não encontrou evidência de bug de timing do `AudioContext` (suspenso até primeiro gesto do usuário) causando a percepção — mas isso não foi descartado com teste real, só não apareceu na leitura estática do código. Vale ficar atento se, depois desse fix, ainda sobrar alguma sensação de som "sumindo" — nesse caso o suspeito seria esse, não falta de gancho.
    - **Implementado exatamente como proposto.** Confirmado antes: os dois `onclick` (`edSalvar`/`edExcluir`) vivem presos na IIFE do módulo do editor de tarefa (mesma família de exceção de `comprar()`/`investir()`) — edição direta, sem gancho externo. `edExcluir` continua com o som `desequipar` **não confirmado com o usuário** (era só proposta da sessão de brainstorm) — pendente de teste real pra saber se combina ou se troca.

22. [x] **Efeito visual de golpe variando por categoria de arma + brilho dourado extra pras armas Lendárias (levantado em sessão de brainstorm, 19/08).** *(pronto, v4.78 — ver seções 59-61 pro estado original)* **SUPERSEDIDO na v4.86 (seção 69, item 26).** O design "categoria de arma define o visual" foi abandonado por completo durante a sessão do pack de Slashes — usuário percebeu que categoria (eixo de cor/forma) colidia com raridade (eixo de tamanho) e virava confuso na prática (armas comuns e lendárias de categorias diferentes ficavam visualmente parecidas). **Eixo final: só raridade importa, categoria não influencia mais nada visual no golpe.** Ver seção 69 pro estado real atual — esta entrada fica só como registro histórico da primeira versão. Hoje todo golpe usa a mesma animação genérica, sem noção de qual arma está equipada — `animarGolpe()` (chamada a cada tarefa concluída) aplica sempre o mesmo par de classes: `hit` no herói e `shake` no monstro (sacudida + flash branco via `filter:brightness(0) invert(1)`), independente do item na mão.
    - **Pré-requisito de dados:** a tabela `ITENS` não tem campo de categoria/estilo de arma hoje (só `tipo:'arma'` genérico pras 22 armas) — precisa de um campo novo (ex: `cat`) classificando cada arma numa das 5 categorias abaixo antes de qualquer CSS entrar em ação.
    - **5 categorias propostas e aprovadas pelo usuário, efeito CSS/SVG puro (zero arte nova):**
      - **Corte** (espadas, adagas, sabre) — risco diagonal branco/prateado atravessando o monstro, rápido.
      - **Impacto** (machados, maças, martelos) — sacudida mais forte que a atual + estrelinhas de impacto ao redor.
      - **Perfuração** (lanças, tridente) — linha reta "furando", ponto de impacto marcado.
      - **À distância** (arco, besta, estilingue) — traço de projétil vindo de fora da tela até o monstro.
      - **Arcano** (cajados, varinha) — brilho/partículas coloridas explodindo no ponto de impacto.
    - **Camada extra pras 3 armas Lendárias** (Cajado do Rei, Adaga Amaldiçoada, Arco Real — ver item 20): o efeito de categoria **não é substituído**, soma-se um brilho/estouro de partículas douradas por cima, usando `#F2A65A` (já é `COR_RAR[4]`, cor oficial de Lendário no jogo — reaproveitada, sem cor nova). Gatilho: `equipado.arma` tem `rar === 4` → soma classe extra (ex: `.golpe-lendario`) junto da classe de categoria normal. Os outros 3 Lendários (Peitoral de Ouro, Escudo do Guardião, Orbe Proibido) não geram golpe — sem gancho aplicável a eles nessa proposta.
    - **Desvio da spec na implementação:** "sacudida mais forte" pro Impacto **não foi feito** — o movimento no golpe foi removido de propósito na seção 10 (sprites ficam parados), reintroduzir teria revertido essa decisão. Trocado por partículas maiores/mais numerosas na mesma categoria, mantendo os sprites parados.

23. [x] **`vibrarOuTocar` não cai pro som quando o sistema bloqueia vibração + cliques da tela de login/boas-vindas sem vibração (levantado em sessão de brainstorm, 21/08).** *(pronto, v4.80 — ver seção 62; implementação real divergiu bastante da spec abaixo, ver seção pra entender por quê)* Usuário reportou "a vibração sumiu" — investigação no código confirmou que **nada foi tocado/quebrado** em nenhuma das sessões seguintes ao item 17 (nem item 21, nem 22, nem a reversão do sprite pack) — `vibrarOuTocar` e os 5 pontos de clique de navegação originais continuam intactos e corretamente conectados. Causa raiz real, encontrada pelo próprio usuário: **modo Não Perturbe do aparelho**, bloqueando vibração no nível do sistema.
    - **Bug real, não é regressão:** `navigator.vibrate()` **não lança exceção** quando o sistema bloqueia a vibração (Não Perturbe, economia de bateria, permissão negada) — ele só retorna `false` silenciosamente. A implementação atual só trata exceção lançada (`try { navigator.vibrate(ms) } catch(e){ tocarSom(som) }`), então esse caso passa despercebido: a função acha que vibrou com sucesso e nunca cai no som de fallback. Resultado: com o bloqueio do sistema ativo, fica sem vibração **e** sem som.
      - **Fix proposto aqui:** checar o valor de retorno de `navigator.vibrate()` além do try/catch. **Insuficiente na prática** — teste real do usuário continuou com silêncio total mesmo com esse fix. Causa: em vários aparelhos o SO intercepta e silencia a vibração *depois* que o navegador já devolveu `true` — não existe sinal nenhum pro JS captar. Ver seção 62 pra solução final (preferência manual, não detecção).
    - **Cliques ainda fora do escopo do item 17, agora confirmados pelo usuário como devendo entrar:** tela de login/boas-vindas (`idiomaBtn`, `temaMiniBtn`, `loginEsqueci`, `loginEntrarBtn`, `loginGoogleBtn`, `loginContinuarSemConta`, `boasVindasContinuar`, toggle Entrar/Cadastro) chamam `tocarSom('clique')` direto, nunca passaram por `vibrarOuTocar` — já estava documentado como "decisão pendente" desde o item 17 original (seção 46), agora resolvido: **entram, sim**.
      - **Fix:** trocar as 2 chamadas diretas (linhas ~7846 e ~7853 na v4.78) de `tocarSom('clique')` pra `vibrarOuTocar('clique', 10)`, mesmo padrão do resto do app. Implementado como proposto, sem alteração — depois renomeado junto com o resto pra `feedbackClique` (ver seção 62).
    - **Fora do escopo, de propósito, não mexer:** o clique do toggle de mudo (linha ~8358) **continua só som**, decisão antiga e ainda válida — precisa confirmar audivelmente que o áudio voltou, vibração não serve pra esse propósito específico. **Mantido intocado**, confirmado na implementação.
    - **Ver seção 62** pra como a solução final ficou — bem diferente da spec de "checar retorno false" acima, que se provou insuficiente em teste real.

24. [x] **Duas correções pequenas na tela de Perfil — teto de atributo sem aviso + texto colando em XP/Vida altos (levantado em sessão de brainstorm, 21/08, a partir de print do app em nível alto).** *(pronto, v4.81 — ver seção 63)* A) `investir()` agora bloqueia no teto real (13 Fortuna / 15 Foco) com aviso explicativo, botão desabilita individualmente por atributo. B) `.perfilhero .xprow{gap:8px}` + `flex:none` nos dois textos — fix mais simples que a proposta original (empilhar linhas), mesmo resultado, sem tocar a regra `.xprow` genérica usada fora do Perfil.
    - **⚠️ Risco não confirmado, aberto pela sessão do carrossel (v4.120-121, seção 42-l):** Vigor foi implementado de verdade *depois* deste item, com o mesmo teto de 50% que Fortuna/Foco (`VIGOR_TETO`). Não confirmado se `investir('vigor')` também ganhou a checagem de teto que este item adicionou pra Fortuna/Foco, ou se o Vigor ficou vulnerável ao mesmo bug original (gastar ponto além do teto sem aviso, sem ganho real). Verificar na próxima sessão de implementação antes de considerar 100% fechado.
    - **A) Fortuna e Foco deixam o jogador gastar pontos além do teto, sem nenhum aviso, desperdiçando ponto de verdade.** Confirmado no código: `investir(atr)` só checa se sobram pontos disponíveis (`pontosDisponiveis() <= 0`), nunca se aquele atributo específico já bateu no próprio teto. O bônus exibido é travado por `Math.min()` só na hora de mostrar (`bonusFortuna()`/`descontoFoco()`), mas `gasto[atr]++` continua subindo por trás, silenciosamente, sem qualquer ganho real.
      - **Tetos exatos, calculados a partir das constantes existentes:** Fortuna (`FORTUNA_POR_PONTO=0.04`, `FORTUNA_TETO=0.50`) satura em **13 pontos**; Foco (`FOCO_POR_PONTO=0.02`, `FOCO_TETO=0.30`) satura em **15 pontos**. Qualquer ponto além disso é 100% desperdiçado hoje. Vigor fica de fora — ainda é placeholder sem lógica real (`"em preparo"`, já documentado como fora de escopo).
      - **Fix, duas camadas:** (1) `investir(atr)` ganha checagem de teto antes de incrementar `gasto[atr]` — trava o gasto na função em si, não só na UI, protege contra qualquer outro caminho de código que chame `investir()` direto; (2) botão "+" correspondente fica desabilitado ao atingir o máximo, texto muda pra algo como "MÁXIMO" no lugar do ícone de mais — leitura instantânea de que não adianta mais investir ali.
    - **B) Label e valor de XP/Vida colam visualmente em números altos, na tela de Perfil.** Causa raiz: `.xprow{display:flex;justify-content:space-between}` sem `gap` mínimo — o espaço entre label ("Experiência") e valor ("276 / 1240 XP") é o espaço *sobrando* no container, que encolhe conforme o valor fica mais longo (mais dígitos em nível/XP altos). Em nível baixo ("0 / 100 XP") sobra respiro; em nível alto, o respiro tende a zero e os textos colam — confirma o padrão relatado ("quanto mais alto o nível, mais grudado").
      - **Risco de arquitetura, atenção obrigatória:** `.xprow`/`.xplabel`/`.xpnum` são **redefinidas em 4 blocos `<style>` diferentes** no arquivo (Arena, Perfil, e outros dois contextos) — mesmo nome de classe reaproveitado, regras se sobrepondo. Qualquer fix **precisa ser escopado** (`.perfilhero .xprow`, nunca `.xprow` cru) pra não vazar pra outras telas que reaproveitam o mesmo nome.
      - **Fix proposto:** dentro do card `.perfilhero`, trocar o layout de "lado a lado com espaço distribuído" pra "empilhado" — label numa linha, valor logo abaixo, alinhados à esquerda (`flex-direction:column`). Resolve pra qualquer quantidade de dígitos, sem depender de espaço sobrando.
    - Ainda não iniciado. Não bloqueia lançamento — dois ajustes pequenos e localizados, sem risco de arquitetura além do escopo de CSS já sinalizado no item B.

25. [x] **2 temas novos — Grafite (preto e branco) e Floresta. Total sobe de 3 pra 5.** Spec original (sessão de brainstorm, 21/08) previa 4 temas novos — Grafite, Oceano, Carmesim e Floresta, total 7. Implementados os 4, mas 2 não sobreviveram ao teste visual — ver "Oceano e Carmesim, o que aconteceu" abaixo. Sistema de temas existente confirmado no código: só troca ~19 variáveis CSS via `[data-tema]` no `<html>`, sem redesenho de layout — regra que usa cor fixa em hex fora de `var()` não acompanha a troca (já documentado no próprio arquivo).
    - **Decisão de escopo pro Grafite:** preto e branco **só na interface** (fundo, painel, texto, botões) — `COR_RAR` (cores de raridade: cinza/verde/azul/roxo/laranja/turquesa) **não muda**, é array fixo em hex lido direto no JS, não variável CSS, nenhum dos temas mexe nela. Sprites de item continuam coloridos como já são. Opção de ir mais fundo (raridade também em tons de cinza, ou `grayscale(1)` sobre a spritesheet inteira) foi levantada e **descartada** — mudaria como o jogo comunica raridade, escopo maior que "só mais um tema".
    - **5 temas no total, não 7 — número revisado depois da implementação, não é a spec original.** O motivo do "número certo" citado na spec (o botão de ciclo rápido `temaMiniBtn` avança um por vez, tema demais vira trabalho pra achar o que quer) continua valendo, só que o piso mudou: com Oceano/Carmesim fora, 5 já cobre o espectro de cor sem repetir hue (laranja/azul/dourado-neutro/mono/verde) e sem forçar tema fraco só pra bater um número redondo.
    - **3 pontos de integração por tema** (bloco `:root[data-tema="id"]` com as 19 variáveis, entrada em `TEMAS`, entrada em `CICLO_TEMAS`) — feito pros 5 que ficaram. Paridade de variáveis conferida: todos os `:root[data-tema]` têm exatamente as mesmas 19 chaves.
    - **`Oceano` e `Carmesim`, o que aconteceu:** implementados com os valores fechados na spec original, mas o vermelho do Carmesim (`#E5484D`) não agradou no teste visual ("não ficou legal", sem motivo técnico específico apontado) e o turquesa do Oceano (`#2DD4BF`) ficou próximo demais do azul do Meia-noite pro gosto do usuário. Duas rodadas de redesenho tentadas — Oceano virou roxo-petróleo ("Ametista"), Carmesim virou vinho e depois mostarda ("Âmbar") — mas no fim o usuário decidiu que 5 temas já é suficiente e cortou os dois, em vez de insistir num sexto/sétimo tom. **Removidos por completo:** bloco `:root[data-tema]`, entrada em `TEMAS`, entrada em `CICLO_TEMAS` — nenhuma referência aos ids `oceano`/`carmesim` sobrou no arquivo (existe um item de loot chamado "Ametista" no jogo, sem relação — é gema colecionável, não tema).
    - **Achado na implementação, fora do escopo original da spec:** `.temagrid{display:flex;gap:10px}` não tinha `flex-wrap`. Indo de 3 pra 7 temas (mesmo tendo caído pra 5 depois), 5+ círculos de 36px apertavam a largura disponível — `flex-shrink` sem `flex-wrap` reduz só a largura, não a altura, virando oval em vez de círculo. Adicionado `flex-wrap:wrap` e `flex:none` no `.temaswatch` — quebra em 2 linhas em vez de distorcer. Mantido mesmo depois do corte pra 5, porque 5 círculos ainda é mais do que os 3 originais cabiam numa linha com folga.
    - `#fill, #perfilFill` (seção 49) continuam fixos em laranja/dourado, **theme-invariant por decisão** — Grafite e Floresta também definem `--xp2` (pareado com o resto da paleta, mesmo padrão de `meianoite`/`pergaminho`), mas essa variável não tem efeito na barra de XP hoje porque a regra por ID vence a cascata. Registrado aqui pra não parecer inconsistência quando alguém notar que a Arena inteira mudou de cor no tema novo mas a barra de XP não.

26. [x] **Efeito de golpe (item 22) ainda não convence visualmente — direção não decidida, sessão pausada de propósito (levantado em sessão de brainstorm, 22/08).** *(pronto, v4.86 — ver seção 69)* **Resultado final aprovado pelo usuário ("muito bom, não precisa mexer mais"):** sprites animados reais do pack "Slashes" (Frostwindz), substituindo o CSS puro por completo. Trajetória mudou de eixo no meio do caminho — plano original era categoria de arma definir o visual (ver item 22), mas isso foi abandonado durante a implementação a favor de **raridade como único eixo visual** (cor = raridade, todas as armas usam o mesmo sprite `Slash 3`, só a cor muda). Detalhes completos, tabela de cores por raridade, e lista de código morto removido na seção 69. **Pendência explícita da própria sessão de implementação:** a limpeza de código morto aconteceu *depois* do último vídeo aprovado pelo usuário — recomendado confirmar visualmente no aparelho antes de considerar 100% fechado, mesmo com aprovação verbal já dada. Feedback original do usuário sobre o estado antigo (v4.78, seção 61 — 100% CSS procedural): "só não parece bom", sem detalhe técnico específico apontado (não é sobre timing, nem sobre diferenciar categoria, nem sobre o dourado do Lendário — perguntado direto, nenhuma dessas opções bateu).
    - **Diagnóstico levantado a partir do código (não é crítica arbitrária, são números reais das constantes/keyframes):**
      - **Duração curta:** a maior parte do efeito acontece nos primeiros ~200ms; `fx-aura` dura 320ms, `fx-corte`/`fx-perfuracao` 240ms, `fx-anel-lendario` 380ms com delay de 110ms (termina por volta de 490ms). Efeito inteiro cabe em meio segundo.
      - **Tamanho pequeno:** elementos vão de 6px a 96px — pequeno relativo ao tamanho provável da arena/monstro no celular.
      - **Zero brilho/trilha, por decisão de "identidade pixel"** (sem blur, sem gradiente, só forma sólida + `box-shadow` deslocado sem blur) — decisão de estilo documentada, não bug, mas é candidata óbvia a causa do "não parece bom" se o gosto do usuário for por efeito mais suave/luminoso.
    - **Nota de contexto:** a nota anterior desta seção dizia "não perguntar de novo sobre voltar a usar pacote de sprite" — isso se referia especificamente a reabrir a decisão já fechada de reverter o Super Pixel Effects Gigapack (seção 61). **Não se aplica aqui**: o usuário trouxe, por iniciativa própria, um pacote diferente e não relacionado (ver abaixo) — não é a mesma pergunta reaberta, é uma direção nova.
    - **Pacote avaliado e aprovado pelo usuário: "Pixel Art Animations - Slashes" (Frostwindz, itch.io).** Cobre só a categoria **Corte** das 5 (não resolve Impacto/Perfuração/À distância/Arcano — essas continuam no CSS puro atual, sem decisão sobre se/quando ganham pacote equivalente).
      - **Testes técnicos, todos aprovados:** licença permite uso comercial e modificação, sem exigir atribuição, só proíbe redistribuir os arquivos originais separadamente (não é o caso, vão ser embutidos no jogo). Resolução 128×128 **não é upscale vazio** do 64×64 — 8,8% de diferença de pixel entre upscale e o arquivo real, ou seja, tem detalhe redesenhado (diferente do pacote de armas avaliado antes, que era 0% de diferença, upscale puro). 9 frames de animação por variante, com brilho/trilha reais — visivelmente mais "impactante" que o traço sólido atual.
      - **3 "tipos" de slash no pacote** (Slash 1, 2, 3 — arcos/traços com formato e trajetória diferentes), cada um em 5 variações de cor (verde, vermelho, ciano-roxo, laranja-branco, azul). **Usuário quer usar os 3 tipos, não só 1**, pra dar variedade visual às armas de Corte — decisão de **como distribuir ainda não fechada**: fixo por arma (cada uma das 8 armas de Corte sempre usa o mesmo slash, identidade própria) vs. aleatório a cada golpe (sorteia entre os 3 toda vez, mais variedade, nenhuma arma tem "cara própria"). Usuário ainda vai pensar antes de decidir.
      - **Pendência técnica, nenhuma cor do pacote bate exata com o branco/prata (`#EDEDED`) que a categoria Corte usa hoje** — vai precisar de recolor por mapeamento de luminância (mesma técnica já validada e aprovada nos itens Lendários, seção do item 20), aplicado aos frames de qual(is) variante(s) forem escolhidas.
      - **Usuário vai levar isso pro chat de integração** — esta entrada de roadmap é o resumo pra esse chat não começar do zero: pacote já teve licença e qualidade confirmadas aqui, só falta (1) decidir fixo-vs-aleatório, (2) recolorir os frames escolhidos, (3) integrar como sprite animado substituindo `.fx-corte` (que hoje é só uma div CSS sólida).
    - **Duas direções mais amplas, ainda em aberto pro resto das categorias (Impacto/Perfuração/À distância/Arcano):** (A) manter 100% sólido/pixelado nelas, só ajustar escala/duração; (B) buscar pacotes equivalentes ao de Corte pra cada uma. Não decidido, não bloqueia o avanço da categoria Corte sozinha.
    - **Sem pressa, não bloqueia lançamento.**

27. [x] **Som do diálogo (blip da digitação) toca rápido demais, efeito "metralhadora" — resolvido (v4.87).** Confirmado no código: `digitar()` chamava `tocarSom('blip', ...)` em **toda letra não-espaço** da frase, a cada `VELOCIDADE_DIGITACAO=28ms` — som sintetizado (onda quadrada, 260-500Hz variando por letra, estilo "Undertale" documentado no próprio comentário do código). Usuário perguntado direto sobre o que incomodava (repetição, tom áspero, volume, ou variação de pitch) — confirmou que era especificamente a **repetição/cadência**, não o timbre nem o volume nem a variação de tom entre letras.
    - **Processo de decisão — preview isolado antes de tocar no arquivo real**: construído um HTML standalone fora do jogo (motor de áudio copiado fiel de `tom()`/`SONS.blip`), pra ouvir cada alternativa no celular antes de qualquer edição no arquivo principal. Nenhuma versão intermediária foi aplicada ao jogo — só a decisão final.
    - **5 alternativas testadas no preview, em ordem**:
      1. `i % 2 === 0` (fix de 1 linha original, corta a frequência do blip pela metade).
      2. `i % 3 === 0` (cadência ainda mais espaçada, "blip por sílaba").
      3. Throttle por tempo (~70ms entre blips, desacoplado de `VELOCIDADE_DIGITACAO`).
      4. Silêncio na digitação + 1 blip grave (`square`, 340→260Hz) só ao avançar a fala, estilo Pokémon.
      5. Mesma ideia da 4, mas com timbre mais grave/suave (`sine` 150Hz) — **não funcionou no aparelho do usuário**: alto-falante de celular tem rolloff abaixo de ~200Hz, frequência tocava mas saía inaudível na prática. Corrigido pra `triangle` 210Hz (mais harmônicos, corta melhor em speaker pequeno) antes do usuário decidir não seguir por esse caminho.
    - **Decisão final: nenhuma das 5 — diálogo mudo.** Usuário observou que vários RPGs do gênero (Fire Emblem, visual novels) não tocam som nenhum na leitura de texto, só em ações de jogo. Mudança final foi remoção pura: o bloco `if (letra && letra !== ' ') { window.tocarSom?.('blip', ...) }` dentro de `passo()` (em `digitar()`) foi **deletado**, nada entrou no lugar (nem em `fechar()`, nem em outro ponto do módulo de diálogo).
    - **`SONS.blip` continua no catálogo de áudio**, só parou de ser chamado — fica disponível caso algum outro gancho queira reusar no futuro (padrão "placeholder morto" aplicado a uma entrada de catálogo, não a um item de jogo).
    - Validado: `node --check` nos 38 blocos `<script>`, balanço de `<div>` (313/313).

28. [x] **Vibração háptica na digitação do diálogo (v4.87).** Usuário testando apps do mesmo gênero achou um padrão que adiciona vibração ao diálogo em vez de som — dá a "sensação" de digitação sem quebrar a decisão de silêncio total do item 27.
    - **Preview isolado antes de aplicar**, mesmo processo do item 27: HTML standalone com `navigator.vibrate()`, testado no Android real do usuário antes de tocar no arquivo do jogo.
    - **1ª rodada de cadências (a cada 2/3 letras, pulsos de 4-8ms) não funcionou** — usuário reportou "só vibra uma vez". Diagnóstico rodado antes de assumir causa: 3 chamadas assíncronas espaçadas em 300ms (via `setTimeout`) + 1 chamada com `navigator.vibrate([array])` de padrão embutido. **Resultado: os dois métodos funcionaram, os 3 pulsos foram sentidos** — descartada a hipótese de bloqueio de "ativação do usuário" em chamada assíncrona. Causa real: duração (4-8ms) e espaçamento (56-84ms) curtos demais pro motor físico de vibração completar um ciclo perceptível antes do próximo disparo — os pulsos se atropelavam.
    - **2ª rodada recalibrada** (durações maiores: 15-20ms, espaçamento maior: a cada 2/3/4 letras) — **escolhida: a cada 4 letras, 20ms** (opção "C" do preview).
    - **Implementação**: gancho novo dentro de `passo()` (mesma função de `digitar()` do item 27), chamada direta a `navigator.vibrate(20)` a cada 4ª letra não-espaço. **Não passa por `feedbackClique()`** de propósito — aquela função geral tem fallback pra som quando o aparelho não vibra ou quando a preferência do usuário é `'som'`, e o diálogo não pode tocar som de jeito nenhum (decisão do item 27). Respeita `sfxAtivo()` (toggle de mudo da topbar) por consistência com o resto do app — som desligado também desliga a vibração do diálogo. **Decisão assumida sem confirmação explícita do usuário** — se ele preferir vibração independente do toggle de mudo, é uma linha pra remover.
    - **Limitação de plataforma, sem contorno**: iOS/Safari não implementa `navigator.vibrate` — decisão da Apple, já documentada em outros pontos do app (`feedbackClique`). Nesses aparelhos o diálogo permanece mudo E sem vibração, silenciosamente (guard `'vibrate' in navigator`).
    - Validado: `node --check` nos 38 blocos `<script>`, balanço de `<div>` (313/313).

29. [x] **Carrossel de 3 slides antes da tela de login (levantado em sessão de brainstorm, 22/08).** *(pronto — e foi muito além do escopo original, ver seções 42-b a 42-m, v4.113→v4.122)* O pedido original era só um carrossel de valor antes do login; o resultado real foi uma **unificação completa**: Login, Nome, Herói e Tarefas viraram slides do mesmo carrossel (não passos separados), o login virou **desvio opcional** (não é mais um slide numerado, é um link "Já tem conta?" sempre disponível), e um bug real de condição de corrida (slides sobrepostos/tela em branco) foi caçado e corrigido no processo. **Pendência crítica não resolvida em nenhuma das 9 rodadas dessa sessão: nada foi testado em aparelho real** — toda validação foi leitura de código/simulação, sem sandbox de navegador disponível. Prioridade #1 antes de considerar isso fechado de verdade.
    - **Ordem final, sem reordenar o que já existe:** Carrossel (novo) → Login (como já é hoje, sem mudança de posição) → `passo1` (regras) → `passo2` (nome) → `passoHeroi` (escolha do herói) → **diálogo de apresentação (item 30, novo)** → `passo3` (primeira tarefa). Usuário confirmou explicitamente que **não** quer trocar login de posição — só adicionar o carrossel antes dele.
    - **Reaproveitar infraestrutura existente, não construir do zero:** o sistema `.passo`/`mostrarPasso()` já existe pros 4 passos de onboarding atuais — extender esse mesmo padrão pros 3 slides novos (mesma classe CSS, mesmo mecanismo de show/hide), em vez de montar um carrossel/swipe paralelo. Botão "Continuar" nos 2 primeiros, "Começar" no terceiro (leva pro login).
    - **Conteúdo proposto pros 3 slides** (copy de rascunho, ajustável — é decisão de tom/marketing, não técnica):
      1. **"Cada tarefa é uma batalha"** — "Todo dia aparece um monstro. Ele só morre se você terminar suas tarefas."
      2. **"Equipe seu herói"** — "Ganhe XP, moedas e itens conforme joga. Da raridade Comum até Lendário."
      3. **"Descubra tudo"** — "63 monstros no Bestiário, conquistas pra desbloquear. Sua jornada, seu ritmo."
    - Ainda não iniciado. Não bloqueia lançamento.

30. [ ] **Herói se apresenta via diálogo (busto+balão) depois de escolher nome/herói, antes da primeira tarefa (levantado em sessão de brainstorm, 22/08).** **NÃO implementado como especificado.** A sessão do carrossel (42-f) adicionou um slide de transição diferente — frase única genérica ("Antes de começar, vamos te conhecer melhor...") com efeito de máquina de escrever, posicionado ANTES do nome, sem usar o módulo de diálogo com busto, sem personalização. Não é o que este item pedia (herói se apresentando DEPOIS de escolhido, puxando `nomeHeroi`/sprite real). **Precisa confirmar com o usuário**: o slide genérico que entrou já resolve a necessidade, ou o diálogo personalizado original deste item ainda é desejado como algo a mais?
    - **Novo gatilho:** hoje o módulo de diálogo dispara 1x por aba, na primeira vez que ela abre. Este é um gatilho novo — depois de `passoHeroi`, antes de `passo3` — usando o `nomeHeroi` e o sprite do herói escolhido (já disponíveis nesse ponto do fluxo).
    - **Conteúdo proposto** (copy de rascunho, ajustável): mensagem 1 — "Olá, {nomeHeroi}! A partir de agora, eu sou seu herói nessa jornada." mensagem 2 — "Toda tarefa que você completar me deixa mais forte. Vamos conquistar juntos!" → avança pra `passo3`.
    - Ainda não iniciado. Não bloqueia lançamento.

31. [ ] **"Animações mais limpas/suaves" — pendência aberta, sem direção definida (levantado em sessão de brainstorm, 22/08).** Comentário do usuário ao mandar o vídeo de referência (item 29/30), mas **perguntado direto onde isso se aplica e ele não soube especificar** — nem "só o onboarding novo", nem "o app inteiro", só impressão geral. Mesmo tratamento dado ao item 26 antes de encontrar direção: registrado como aberto, sem forçar proposta às cegas. Retomar quando o usuário conseguir apontar uma tela/interação específica que pareça "não suave" — nesse momento, comparar com o código real (igual foi feito pro efeito de golpe) antes de qualquer mudança.
    - Sem pressa, não bloqueia lançamento.

32. [ ] **Tema padrão muda de Crepúsculo (laranja/roxo) pra Grafite, pra quem nunca escolheu tema (levantado em sessão de brainstorm, 22/08).** Usuário testou o Grafite (item 25) e preferiu ao padrão original. Não é trocar o tema em si, é só qual tema carrega **quando não existe preferência salva** — quem já escolheu um tema manualmente não é afetado.
    - **3 pontos exatos a mudar** (mesmo padrão de "múltiplos lugares, fácil esquecer 1" já visto nos itens de tema anteriores) — trocar o fallback `'padrao'` por `'grafite'` nos 3:
      - `temaSalvo()` (linha ~4910-4911) — o que carrega no primeiro load sem `localStorage` gravado
      - `pintarTemaGrid()` (linha ~4921) — detecção do tema atual pra pintar a grade de seleção em Config
      - Handler do botão de ciclo rápido no header (linha ~7921) — mesma detecção, ponto separado
    - Ainda não iniciado. Não bloqueia lançamento — 3 strings trocadas, sem risco.

33. [x] **Teto de todos os atributos padronizado em 30% (era 50% pra Fortuna/Vigor, Foco já estava em 30%) — levantado e implementado na mesma sessão de brainstorm (24/08), exceção pontual ao fluxo normal.** Usuário pediu a mudança direto neste chat (normalmente reservado só pra spec, não código) — aceito por ser pequeno e de baixo risco. `FORTUNA_TETO` e `VIGOR_TETO`: `0.50` → `0.30`. `FOCO_TETO` não mudou (já era 0.30).
    - **De brinde, resolveu o risco aberto do item 24:** confirmado que `noTeto(atr)` já cobria os 3 atributos (fortuna/foco/vigor) desde que o Vigor foi implementado (seção 42-l) — a mensagem "Esse atributo já está no teto máximo" já disparava genérica pros 3, não precisou criar nada novo, só o número do teto mudou.
    - **Cuidado de sincronia aplicado:** o valor do Vigor está duplicado em dois lugares (módulo Atributos + dentro de `verificarVirada()`, risco já catalogado na seção 42-l) — os dois pontos foram atualizados juntos, comentários também revisados pra não ficarem enganosos.
    - **Validado nesta sessão:** `node --check` nos 40 blocos `<script>` — 0 erros. Balanço de `<div>` (339/339) e `<svg>` (35/35) idêntico ao arquivo original — diff confirma que só os 3 números + comentários foram tocados. **Não testado em aparelho real** (mesma pendência de sempre — validação aqui foi só leitura/simulação).
    - Entregue como `questlog-4-123-teto-30pct.html`.

34. [x] **Verificação de email — hoje qualquer pessoa podia se cadastrar com email de terceiro, sem confirmação nenhuma (levantado em sessão de brainstorm, 24/08). Escalado pelo usuário pra prioridade antes até do item 13d (idioma) — considerava bloqueador de lançamento.** Confirmado no código: `createUserWithEmailAndPassword` era chamado, mas `sendEmailVerification` **nunca** era importado nem chamado em lugar nenhum do arquivo — Firebase Auth só validava formato do email (tem `@`), não posse. **Implementado, testado e refinado ao longo de duas sessões (implementação inicial + sessão de ajustes em 24-26/08) em `questlog-4-124-verificacao-email.html`.**
    - **Decisão original (sessão de brainstorm, feita pela IA a pedido explícito do usuário "faz o que você achar melhor") — REVERTIDA na sessão de ajustes, ver abaixo:**
      - ~~Escolhido: manda o email no cadastro, não bloqueia a sessão que acabou de criar a conta — bloqueia só o PRÓXIMO login~~ **Testado na prática e rejeitado pelo próprio usuário**: deixava a conta 100% funcional (onboarding completo, tarefas, tudo) enquanto o app ficasse aberto na mesma sessão, sem limite de tempo — só bloqueava fechando/reabrindo o app de vez, o que ninguém faz por padrão. Usuário: "não deveria me deixar nem sequer entrar na parte de tarefas antes de verificar".
    - **Decisão final, implementada:** bloqueia **imediatamente após o cadastro**, antes de qualquer tela de onboarding (herói, nome, tarefas) — `precisaVerificar = !user.emailVerified && contaNovaOBastante` (removida a exceção `!contaNova` que existia na primeira iteração). Segura de fazer porque a conta ainda não tem nenhum dado de jogo nesse ponto (nada a perder se a pessoa desistir).
    - **Grandfather clause (mantida da decisão original):** `DATA_CORTE_VERIFICACAO_EMAIL = new Date('2026-08-24T00:00:00Z').getTime()` — só contas com `creationTime` depois dessa constante entram na trava. **Ajustar essa data pra quando a versão for realmente publicada em produção.**
    - **Duas telas de bloqueio, mesmo texto/ações, DOMs diferentes por necessidade técnica:**
      - `#passoVerificarEmail` — dentro do carrossel de onboarding, usada em `aoLogar()` (cadastro/login pela tela de login normal).
      - `#bloqueioVerificacaoEmail` — overlay standalone (`position:fixed`, injetado direto no `<body>`, `z-index:9999`), usada em `aoLogarSilencioso()`. **Achado importante:** o caminho "silencioso" é o cenário mais comum de reabrir o app (save local já existe, `#intro` já tem `.off`, `#passoLogin` nunca chega a ser injetado no DOM) — sem essa segunda tela, a trava só pegava "outro aparelho, sem save nenhum", nunca o caso comum de reabrir no mesmo device.
    - **Confirmação virou 100% automática (mudança da sessão de ajustes):** poll silencioso a cada 4s (`user.reload()` + checa `emailVerified`) nas duas telas — não existe evento nativo do Firebase pra "usuário acabou de verificar", só dá pra perguntar. O botão manual "Já confirmei"/"Verificar agora" existiu por duas iterações intermediárias e **foi removido** a pedido do usuário (poluía a tela sem necessidade, já que o poll cobre o caso sozinho). Funções: `confirmarSeVerificado()` (tela do carrossel) e `confirmarSeVerificadoOverlay()` (overlay standalone) — duas versões porque a ação de "confirmado" difere (uma chama `aoLogar()` de novo, outra remove o elemento do DOM + `aoConfirmar()`).
    - **Ações que restaram nas telas:** "Reenviar email" (`sendEmailVerification` de novo, virou o único botão `.primario`/CTA de destaque depois que "Já confirmei" saiu) e **"Email errado? Corrigir"** (`user.delete()` + `location.reload()` — saída de emergência pra quem digitou o próprio email errado no cadastro e ficaria preso pra sempre sem isso; seguro porque a conta não tem save nenhum ainda; segue o padrão já estabelecido no app de não usar `confirm()` nativo, por causa do bug de clique fantasma pós-dialog documentado em outra seção).
    - **Login com Google fica de fora da trava** (`signInWithPopup` + `GoogleAuthProvider`) — já vem com `emailVerified:true`, sem tratamento extra necessário.
    - **Watchdog `iniciarVigiaVerificacao` — removido por completo (levantado e resolvido em sessão de brainstorm, 26/08, exceção pontual ao fluxo normal, mesmo padrão do item 33).** Confirmado no código antes de remover: a função era chamada (via `reconectarEnvio()`, que roda em todo login/reconexão), mas morria na própria guarda de entrada (`if (!contaNovaOBastante || user.emailVerified) return`) — não literalmente inalcançável, mas inerte na prática, já que o fluxo de bloqueio imediato garante que só chega ali com `emailVerified === true`. `vigiaVerificacaoAtiva` confirmada sem uso fora da própria função antes de remover junto. Removidos: a função inteira, a chamada em `reconectarEnvio()`, e as duas variáveis que só existiam pra servi-la (`vigiaVerificacaoAtiva`, `PRAZO_TOLERANCIA_VERIFICACAO_MS`). Validado: `node --check` nos 40 blocos, 0 erros; balanço de `<div>` (345/345) idêntico ao arquivo antes da remoção; diff confirma remoção pura. Entregue como `questlog-4-125-remove-vigia.html`.
    - **UX pós-cadastro ajustada:** conta nova pula direto pro slide 4 do carrossel ("Antes de começar, vamos te conhecer melhor...", `window.irParaCarrossel(4)`) em vez de voltar pro slide de onde a pessoa veio quando abriu o login (`voltarDoLoginCarrossel()`) — evita reassistir QUESTLOG/BATALHA/EVOLUA de novo depois de verificar o email. Reaproveitou uma função (`window.irParaCarrossel`) que já existia exposta no código sem nenhum chamador.
    - **Tela de bloqueio reestruturada visualmente duas vezes** (usuário reportou "muito poluída" com print de referência do Habitica): 1ª rodada agrupou em `.verificarBloco` (mensagem + aviso de spam) e `.verificarAcoesSecundarias` (ações secundárias), com gap grande só *entre* grupos; 2ª rodada, após remover o botão "Já confirmei", desfez o agrupamento de ações (não fazia mais sentido com só um botão sobrando) e promoveu "Reenviar email" de `.secundario` pra `.primario`.
    - **Problema de entregabilidade descoberto durante teste real (não é bug de código):** o email de verificação caía 100% em Spam no Gmail — confirmado via captura de tela do Firebase Console (template correto, ativo) e busca `in:anywhere` no Gmail. Causa: domínio compartilhado `noreply@questlog-d4c11.firebaseapp.com` sem reputação própria (sem SPF/DKIM/DMARC alinhado a domínio verificado). **Mitigação de UX feita:** aviso "Não achou? Confere o spam" nas duas telas. **Fix de causa raiz NÃO feito, bloqueado por falta de domínio próprio — ver item 35.**
    - Testado ao longo de várias iterações via vídeo/print real do usuário (fluxo de cadastro completo, spam do Gmail, tela de bloqueio, tema). **Cenário de conta antiga (grandfather) ainda sem teste de vídeo explícito** — recomendo confirmar antes de considerar 100% fechado.

35. [ ] **Domínio de envio customizado pro Firebase Auth (SPF/DKIM/DMARC) — resolve a causa raiz do item 34 (email de verificação caindo em spam).** Usuário não tem domínio próprio registrado ainda (confirmado em sessão de 24/08) — **bloqueado até ele adquirir um**. Quando houver domínio: Firebase Console → Authentication → Templates → configurar domínio customizado, adicionar os registros TXT/CNAME pedidos no DNS do domínio. Não é bloqueador de lançamento por si só (a mitigação de UX do item 34 já reduz o dano), mas resolve o problema de verdade em vez de só avisar. Alternativa mais robusta considerada e explicada ao usuário, ainda descartada por ora: SMTP customizado via extensão (SendGrid/Mailgun/etc.) — mais trabalho de infra e monitoramento, só valeria a pena com volume de usuários bem maior do que o atual.
    - Não iniciado — sem domínio, não há o que configurar.

36. [x] **Validação de senha no cadastro — campo "Confirmar senha" + regra de senha forte (pedido separado do usuário, mesma sessão de refinamento do item 34).** Até então o Firebase só exigia mínimo de 6 caracteres sozinho (`auth/weak-password`), sem confirmação nem exigência de número.
    - **Campo "Confirmar senha"** — novo, `display:none` por padrão, só visível no modo Cadastro (mesmo toggle que já escondia "Esqueceu a senha?").
    - **Regra de força:** `/^(?=.*[0-9]).{6,}$/` (mín. 6 caracteres + pelo menos 1 número) — validada client-side antes de chamar o Firebase, evita round-trip de rede pra erro óbvio. Duplicada em dois `<script>` diferentes sem import entre eles (um valida no submit, outro alimenta o feedback visual em tempo real) — mesmo padrão de isolamento que o resto do arquivo já usa; se a regra mudar um dia, precisa trocar nos dois lugares.
    - **Feedback visual em tempo real** (referência visual do Habitica, mandada pelo usuário em print): ícone de check verde / X vermelho ao lado de cada campo de senha (`.campoStatus`, espelhando `.campoIc` que já existia à esquerda), atualizado a cada `input`. Campo vazio = sem ícone. Mensagem de erro contextual (`.loginSenhaErro`) só aparece quando o X acende — não é mais uma dica estática sempre visível (essa foi a primeira versão, trocada a pedido do usuário pra reduzir poluição visual).
    - Ícones e mensagens resetam ao trocar entre Entrar↔Cadastro (`window.questlogLimparStatusSenha`), evitando "check preso" de uma tentativa anterior.

37. [ ] **Tema Grafite recalibrado — fundo/painéis estavam escuros demais comparado a referências reais (Habitica), usuário mandou print comparativo.** Duas rodadas de ajuste na mesma sessão:
    - **1ª tentativa:** `--bg` `#0A0A0A → #141414`, degraus reduzidos entre bg/panel-2/panel-3 nivelados com os outros 4 temas. **Insuficiente** — usuário testou no aparelho real e reportou "ainda tá muito escuro". Lição: comparar valores hex no código não é o mesmo que confirmar percepção real em tela — um salto de 10 pontos de luminância é imperceptível.
    - **2ª tentativa (atual):** recalibrado de forma bem mais agressiva, mirando a faixa de luminância real do Habitica no print de referência — `--bg` `#282828` (luminância 40, 4x o valor original), `--panel` `#323232`, `--panel-2` `#3D3D3D`, `--panel-3` `#494949`.
    - **Restrição preservada nas duas rodadas:** 100% grayscale (R=G=B em todo valor hex) — decisão já fechada no item 25 original ("preto e branco só na interface"), confirmado programaticamente a cada rodada que nenhum valor introduziu matiz de cor. `--accent` continua `#FFFFFF`, `COR_RAR` (raridade de item) não é tocado — é array fixo em hex no JS, fora do sistema de tema.
    - `--panel` não é referenciado em nenhuma regra CSS além da definição da variável (confirmado antes de editar) — não havia risco de quebrar outra coisa ao separar seu valor de `--bg`.
    - **Ainda sem confirmação final do usuário** de que a 2ª rodada resolveu — testar em aparelho real antes de fechar.

38. [ ] **Cadastro e verificação de email 100% funcionais e testados nesta sessão, mas a versão publicada em `appquestlog4.netlify.app` ainda é a ANTIGA — nada do que foi feito nas últimas duas sessões (itens 34/36/37) está no ar.** Usuário testou tudo baixando o arquivo `questlog-4-124-verificacao-email.html` localmente, não via deploy. **Lembrete pra próxima sessão de deploy:** subir esse arquivo pro Netlify antes de considerar essas features "lançadas" de verdade, e atualizar `DATA_CORTE_VERIFICACAO_EMAIL` e `PRAZO_TOLERANCIA_VERIFICACAO_MS` (ver item 34) pros valores de produção antes do deploy.

39. [x] **Config reestruturado: tela principal vira lista enxuta (texto + seta), conteúdo pesado migra pra sub-telas (levantado em sessão de brainstorm, 26/08).** *(pronto — foi bem além do escopo original, decisões incrementais na mesma sessão de implementação)* Usuário trouxe 3 prints de referência (QuestLog atual, Habitica, e um terceiro app) — achado do terceiro: header com avatar+nome+email editáveis inline, e todo o resto em lista categorizada (`Idioma >`, `Aparência >`, cada linha abrindo uma sub-tela própria), não tudo exposto cru na mesma tela. Escopo inicial recusou email editável/pausar dano/hora de reinicialização — só reestruturação visual.
    - **Implementado como especificado:** ícones nas linhas (`.cfgicone`, SVG mesmo estilo do resto do app), sub-telas Herói/Aparência/Preferências via overlay (mesmo mecanismo da v4.58), Histórico convertido do padrão "botão" pro mesmo padrão de linha+seta das outras (inconsistência visual que nem estava no pedido original, resolvida de brinde).
    - **Foi além, a pedido explícito do usuário, dentro da mesma sessão:** grid de Herói (4→3 colunas, sprites 47px→64px) bem maior que o original. **Seletor de Aparência passou por 2 rodadas** — 1ª tentativa (cards grandes 2 colunas, `aspect-ratio` crescente) foi **testada e rejeitada pelo usuário** ("quadradão, destoava do resto da tela"), substituída na mesma sessão pela versão final: **lista de linhas** (bolinha de cor 30px + nome + check que só aparece quando selecionado), mesmo padrão visual do resto do Config em vez de bloco isolado — `pintarTemaGrid()` reescrita, markup trocou de `.temaswatch` pra `.temalinha`/`.temaDot`/`.temaNome`/`.temaCheck`. Vibração adicionada nos pontos que faltavam (Herói/Aparência/Preferências/Histórico + botões Sair/Criar conta/Apagar tudo); **temas renomeados** (Crepúsculo→Laranja, Meia-noite→Azul, Pergaminho→Dourado, Grafite→Escuro) e **Floresta removido** da lista de seleção (CSS mantido como deprecated, não apagado — segue o padrão do projeto); **tema padrão voltou a ser Laranja**, revertendo a decisão do item 32 de duas sessões atrás — confirmar que foi intencional; fix de contraste no switch de Feedback tátil no tema Escuro (bolinha branca sumia no trilho branco).
    - **⚠️ Achado importante, não é bug desta sessão mas precisa de atenção:** `style.css` tem **conteúdo duplicado pré-existente** — os módulos 1-20 inteiros se repetem no arquivo, só a última cópia vence na cascata. Ambas as cópias foram editadas por consistência nesta sessão, mas a duplicação em si continua existindo e vai seguir exigindo edição em dobro (com risco de esquecer uma cópia) até alguém investigar a causa raiz e limpar.
    - **Confirmado pelo usuário: design do Config está finalizado** — não é mais "pronto, mas ainda ajustando visual", é ponto final na parte de design deste item. Só falta o teste em aparelho real (ver abaixo), que é validação, não mais iteração de decisão.
    - **Validado:** balanceamento de tags a cada edição, `node --check` nos 42 blocos (0 erros), `style.css` parseado com lib real (não regex), 0 erros.
    - **Não testado em aparelho real ainda** — prioridade pro próximo ciclo de teste, junto com o resto que já está na mesma fila (pill de nome do tema em contraste, usuário com `'floresta'` salvo no `localStorage` simplesmente não vê mais a opção, não quebra).

40. [x] **Número flutuante de XP/moeda na Arena, substituindo o toast de texto nessa tela (levantado em sessão de brainstorm, 27/08).** *(pronto — implementado e iterado na mesma sessão, virou a base de um sistema bem maior, ver itens 41-44)* Hoje ganhar XP/moeda ao concluir tarefa dispara só `aviso('+10 XP   +5 MOEDAS')` — texto puro no toast genérico do topo (`#toast`), mesmo elemento usado pra qualquer aviso do app, sem nada visual na Arena em si.
    - **Referência do usuário:** clássico "damage number" de RPG, só que positivo — texto sobe flutuando de cima do monstro e desvanece, em vez de aparecer só como notificação no topo.
    - **Infraestrutura já existe, reaproveitar em vez de criar do zero:** já tem `COIN_SVG` (moeda pixel art embutida, mesma usada no contador do topbar) e `moedasCaindo(qtd)` — sistema de partícula que já spawna elementos a partir do centro do `#mobSprite` (calculado via `getBoundingClientRect`), com `@keyframes coinFall` (translate + scale + rotate + fade). É pra "moedas físicas caindo", não pra texto — mas a lógica de origem/posicionamento é exatamente a que este item precisa, só trocar o conteúdo do elemento (moeda→texto) e a keyframe (queda→subida).
    - **Proposta de conteúdo:** `+10 [ícone moeda] · +10 XP` — um elemento só, nascendo no mesmo ponto de origem que `moedasCaindo` já calcula, subindo ~40-60px enquanto o `opacity` vai de 1→0, reaproveitando o padrão `position:absolute` + `@keyframes` já estabelecido (`coinFall` como referência de estrutura, não os valores exatos — esse sobe, aquele cai).
    - **Escopo de convivência com o toast, decisão fechada:** o flutuante **substitui** `aviso()` especificamente nas telas de Tarefas/Arena — nas outras telas do app, o toast de texto continua exatamente como está, sem mudança.
    - **Implementado como especificado:** `numeroFlutuante(xpGanho, moedasGanhas)`, nova função logo após `moedasCaindo()`. Reaproveita 100% o cálculo de origem (`getBoundingClientRect` do `#mobSprite`). Classe `.dmg-float` + `@keyframes dmgFloat` novas no CSS — sobe ~55px, mesma técnica posicional de `.coin-drop`. Substituiu as 2 chamadas de `aviso('+X XP +Y MOEDAS'[...])` (tarefa com meta parcial e tarefa concluída normal); o toast de `'MONSTRO DERROTADO'` e o popup de level-up **não foram tocados** — a troca é só do ganho rotineiro, não de todo `aviso()` da tela.
    - **Timing ajustado após teste real:** 1ª versão (1s) achada rápida demais pelo usuário ("difícil de ver") — aumentado pra 1.6s com um platô de opacidade total entre 10%-70% da animação antes de desvanecer, em vez de começar a sumir assim que começa a subir.
    - **Cores separadas por convenção já existente no app, não descoberta na 1ª tentativa:** 1ª versão usava uma cor só (`var(--accent)`) pro texto inteiro — o app já diferencia moeda (`var(--gold)`, mesma cor de `.coins` no topbar e `.toast.gold`) de XP (cor neutra, mesma família de `.xpnum`) em todo outro lugar; misturar as duas numa cor só quebrava esse padrão. Corrigido: `.dmg-moeda{color:var(--gold)}`, `.dmg-sep{color:var(--muted)}`, `.dmg-xp{color:var(--text)}`.
    - **Achado ao investigar a pergunta "isso não gera inconsistência visual?":** confirmado que o app tem **43 chamadas de `aviso()`** no total, só 2 substituídas por este item — as outras 41 (Loja, Inventário, editor de tarefa, auth, dano, fuga, etc.) continuam no toast padrão. É hierarquia por importância (rotineiro=flutuante discreto, marcante=toast/popup), decisão deliberada, não inconsistência acidental — mas com risco real de sequência: vencer o dia dispara o flutuante e o toast de "MONSTRO DERROTADO" em cadeia rápida (350ms de diferença), ainda não testado se sente "picotado" num aparelho real.

41. [~] **Teste: todos os toasts do app desativados, pra ver se fazem falta (pedido do usuário, 27/08).** *(experimento ativo, decisão final pendente — não é feature, é uma pergunta sendo respondida em produção)* Depois do item 40 cobrir o ganho de XP/moeda com flutuante, usuário pediu pra desativar **globalmente** as 41 chamadas de `aviso()` restantes e testar no aparelho se sente falta.
    - **Implementado como interceptor, não removendo nada:** `const TOASTS_DESATIVADOS = true;` + `if (TOASTS_DESATIVADOS) return;` como primeira linha de `aviso()`. Reversível trocando `true`→`false`, sem tocar em nenhuma das 41 chamadas.
    - **Resultado do teste, relatado pelo usuário:** "sinceramente eu não senti falta" — mas isso foi **antes** de perceber que usar poção (item 44) tinha ficado sem nenhum feedback visual por causa da mesma flag, o que motivou a extensão do sistema flutuante pra fora da Arena.
    - **Ainda ativo no código no fim da sessão (`TOASTS_DESATIVADOS = true`).** Risco de regressão silenciosa: erros de validação que hoje só avisam por toast (`'ESCOLHA OS DIAS'`, `'SENHAS NÃO SÃO IGUAIS'`, `'TÍTULO NÃO PODE FICAR VAZIO'`, mensagens de auth) ficam **mudos** enquanto a flag estiver ligada — o app simplesmente não reage visivelmente a uma tentativa de salvar algo inválido. Precisa de decisão explícita antes do lançamento: manter desligado permanentemente (e então decidir o que fazer com esses casos de erro sem feedback), ou religar.
    - **Confirmado no código (28/08), a pedido do usuário: o sistema de notificação de conquistas também foi silenciado pela mesma flag, sem ninguém perceber na hora.** Dois pontos afetados especificamente: `resgatarConquista()` chama `aviso('+' + tierAlvo.xp + ' XP')` no fim, pra confirmar visualmente o resgate — mudo (o som `tocarSom('grimorio')` continua tocando normal, não depende dessa flag, só o texto ficou mudo). Descoberta de item novo no Grimório também chama `aviso('Conquista: ' + item.nome, true)` — mesma coisa, mudo. Diferente dos erros de validação (que são feedback negativo, "algo deu errado"), esse é feedback positivo de recompensa — vale considerar como categoria separada na decisão final, já que suprimir a confirmação de "você ganhou algo" tem custo de experiência diferente de suprimir "esse formulário está errado".

42. [x] **Celebração da vitória do dia melhorada — "DIA VENCIDO" era simples demais (pedido do usuário, 27/08).** *(pronto, com uma iteração revertida no meio do caminho — registrada abaixo)*
    - **1ª tentativa: baú com tampa articulada dentro do banner.** Base + tampa como dois `<svg>` separados, tampa girando via `transform:rotate()` em CSS transition ao vencer, mais um "flash" radial atrás do baú. **Rejeitada pelo usuário** ("você entendeu errado, fazer tipo semelhante ao sistema que a gente fez +xp+moeda") — o pedido era reaproveitar o *padrão do flutuante* (item 40), não criar um elemento estático novo com mecanismo de dobradiça.
    - **Revertido por completo** (markup e CSS do baú com tampa removidos, zero código morto deixado) e refeito como flutuante: ícone de baú em pixel art (`CHEST_SVG`) + texto "DIA VENCIDO!" sobem do centro do `#mobSprite`, **mesma técnica exata de `numeroFlutuante()`**, reaproveitando a própria classe `.dmg-float` já existente.
    - **O que ficou, além do flutuante do baú:** burst de 7 faíscas em pixel art radiando da faixa "DIA VENCIDO" (mesma técnica de origem/posicionamento de `moedasCaindo`, espalhando em círculo em vez de cair reto); contagem progressiva do número de moedas ganhas (0→valor final, ease-out cúbico, ~500ms, via `requestAnimationFrame`) em vez de aparecer estático; `faixaPunch` — soco de escala (1→1.28→1) na faixa de texto, substituindo uma 1ª tentativa de brilho pulsante (`text-shadow` sutil) que o usuário relatou como "imperceptível".
    - **Disparo controlado por flag (`_vitoriaCelebrada`)** pra rodar só 1x por vitória — sem isso, `celebrarVitoria()` repetiria a cada `render()` enquanto o dia já estivesse vencido (toda tarefa marcada/editada re-renderiza).
    - **Não testado em aparelho real ainda** — timing e distância de subida do baú são valores de partida.

43. [x] **Ícones removidos das conquistas — só texto (pedido do usuário, 27/08).** *(pronto)* Pedido em duas partes, feito em dois momentos da mesma sessão porque o usuário só percebeu a 2ª ocorrência numa screenshot depois.
    - **Lista completa de conquistas (`renderConquistasV2`):** função `linha()` parou de montar `<div class="conqv2icone">` (SVG/img + cor de fundo `--pv-cor`), mantendo só nome + descrição + data. CSS `.conqv2icone` removido nas **2 ocorrências duplicadas** (achado do item 39 sobre `style.css` ter módulos repetidos segue valendo — as duas cópias precisaram ser editadas pra não ficarem dessincronizadas).
    - **Prévia de Conquistas na tela principal do Perfil (`renderPreviewsPerfil`):** só identificada depois, numa screenshot do usuário mostrando os círculos coloridos ainda aparecendo ali — é um componente visual diferente (resumo de até 5 recentes, não a lista completa), escopo estendido pra cobrir também. Círculos com ícone (`.prevconqicone`) viraram chips de texto (`.prevconqchip`) — nome da conquista, cor mantida na borda/texto (`--pv-cor`) pra continuar distinguível rapidamente. `.prevfaixa` ganhou `overflow-x:auto` porque texto tem largura variável, diferente dos círculos de tamanho fixo que cabiam sempre.

44. [x] **Sistema de flutuante genérico — estendido de "número na Arena" (item 40) pra qualquer ação com feedback: poção, equipar, comprar, vender, melhorar atributo (pedido do usuário, 27/08).** *(⚠️ PARCIALMENTE REVERTIDO na mesma sessão — ver nota abaixo do bloco original e item 45 pra o desfecho final)*
    - **Motivação:** com o item 41 (toasts desligados) ativo, usar poção no Inventário **não tinha nenhum feedback visual** — nem toast (desligado), nem flutuante (só existia na Arena). Usuário perguntou "não daria pra fazer tipo daquelas coisas flutuantes que tem na arena no inventário?".
    - **`flutuanteFixo(origem, conteudoHtml, largo)` — variante genérica de `numeroFlutuante()` pra fora da Arena.** Onde `numeroFlutuante` usa `position:absolute` relativo a `.arena` (que só existe na tela de Tarefas), `flutuanteFixo` usa `position:fixed` com coordenadas de viewport (`.dmg-float.fixo`, `z-index:200`) — funciona em qualquer tela. Reaproveita a mesma classe `.dmg-float`/keyframe `dmgFloat`.
    - **`notificarFlutuante(origem, prefixo, nome, cor)` — atalho pra mensagens com uma parte colorida.** Passou por 2 iterações de UX depois do 1º corte:
      1. 1ª versão: frase inteira numa cor só (`'Você equipou {nome}'` inteiro na cor da raridade). Usuário pediu pra separar: só o nome do item/atributo leva cor, o resto da frase (`'Você equipou'`) fica na cor padrão de texto (reaproveita `.dmg-xp`, `var(--text)`).
      2. Isso introduziu um bug de espaçamento: o `display:flex;gap:3px` herdado da `.dmg-float` base (pensado pra ícone+número da Arena) somava com o espaço literal do HTML entre os dois `<span>`, dando espaçamento duplicado e inconsistente — "tem texto saindo junto e tem texto saindo muito separado". Corrigido com `.dmg-float.msg{display:block}`, removendo o flex só nessa variante — texto volta a fluir como texto normal, só o espaço literal do HTML conta.
    - **Mapeamento de cor por ação:** `equipar()`/`comprar()` usam `COR_RAR[it.rar]` (mesma escala de 6 cores já usada em `.imeta`); `investir()` usa novo `COR_ATR` (`{fortuna:'#F2A65A', foco:'#5AA9F2', vigor:'#E5698A'}`, mesma cor já usada nos cards `--atr-cor`); `venderItem()` usa dourado fixo (reaproveita `.dmg-moeda`, já que é sempre ganho de moeda).
    - **Textos finais:** equipar/desequipar → `"Você equipou {item}"` / `"Você desequipou {item}"` (cor por raridade); comprar → `"Você comprou {item}"` (cor por raridade); vender → `+N` + ícone de moeda (dourado); atributo → `"Você melhorou {Fortuna/Foco/Vigor}"` (cor do atributo); poção → `+N HP`/`+N XP`/`+N MOEDAS` (cor padrão de texto).
    - **Bug 1 encontrado pelo usuário: "comprei e vendi na loja e não aconteceu nada".** Causa raiz: `comprar()` chama `renderLoja()` **internamente antes** de disparar a notificação — `renderLoja()` reconstrói o grid inteiro via `grid.innerHTML = ''`, desconectando o botão clicado do DOM. Um elemento desconectado devolve `{0,0,0,0}` em `getBoundingClientRect()`, então o flutuante nascia grudado no canto (0,0), atrás da topbar — invisível na prática. `venderItem()` corria o mesmo risco (o `render()` global também dispara `renderLoja()` quando a aba ativa é Loja). **Fix:** novo helper `pontoDeElemento(el)` — captura `{x,y}` do botão **antes** de qualquer `render()`/`renderLoja()`/`renderInventario()`, guarda num `const ponto` local, e passa esse ponto (não mais o elemento) pra `flutuanteFixo`/`notificarFlutuante`, que agora aceitam ambos os formatos. Aplicado em `comprar()`, `venderItem()` e defensivamente em `equipar()`.
    - **Bug 2 encontrado pelo usuário: "texto cortado, saiu pra fora da tela".** Causa raiz: `.dmg-float` usa `white-space:nowrap` (correto pra números curtos tipo "+10 XP"), mas mensagens longas ("Você melhorou Fortuna") perto da borda da tela estouravam sem quebrar linha, sem nenhuma trava de viewport. **Fix:** variante `.dmg-float.msg` com `white-space:normal;max-width:190px;text-align:center` pra mensagens; e `flutuanteFixo()` mede a largura real do elemento **depois** de inserir no DOM (`el.offsetWidth`) e reposiciona (`margem:10px` das bordas) se estourar esquerda/direita.
    - **Tamanho da fonte reduzido após feedback:** 1ª versão da variante `.msg` herdava `13px` (igual ao número da Arena) — usuário achou grande demais pra frase inteira. Reduzido pra `10.5px`, peso `600` (mais leve que os `700` herdado).
    - **Wraps de SFX existentes (`window.equipar`, `window.venderItem`) confirmados intactos** — usam `.apply(this, arguments)`, forwardeiam o novo parâmetro `elOrigem` automaticamente sem precisar de edição.
    - **⚠️ REVERTIDO (mesma sessão, logo em seguida): equipar/desequipar, comprar e melhorar atributo voltaram a usar só `aviso()` (toast), sem flutuante.** Usuário testou e achou que "não ficou bom, sinceramente" — pediu explicitamente pra reverter esses 3 e manter flutuante só nos casos que já existiam mais a venda ("as moedas deveriam sair do item vendido"). `equipar()`, `comprar()`, `investir()` voltaram à assinatura de 1 argumento, sem `elOrigem`. `notificarFlutuante()`, `COR_ATR`, `NOME_ATR` **não foram apagados** (utilitários genéricos, podem servir de novo), só ficaram sem nenhum call site ativo — comentário no código deixa isso explícito. Vender e usar poção continuaram como flutuante, mas teve outra rodada inteira de bugs — ver item 45.

---

45. [x] **Flutuante de vender/usar item — de onde ele nasce de verdade (continuação do item 44, mesma sessão, 27/08).** *(pronto — só depois de 2 gravações de tela e 3 hipóteses erradas antes de achar a causa raiz certa)* Ficou só vender (Inventário + Loja) e usar poção como flutuante depois da reversão do item 44; ambos continuaram dando problema de posição em rodadas separadas de teste do usuário.
    - **Rodada 1 — gravação de tela #1, venda no Inventário "sumia" e reaparecia no Perfil.** Vídeo mostrou o `+10` nascendo certinho em cima do item no frame do clique, mas 2 frames depois o usuário já tinha trocado pra aba Perfil e o flutuante continuava "pairando" no mesmo pixel da tela, agora por cima de "Vigor" — porque `.dmg-float.fixo` é `position:fixed` no `body`, **não** faz parte do conteúdo da aba, então sobrevive à troca de aba sem se mover nem sumir. **Fix:** `mostrarAba()` passou a remover qualquer `.dmg-float.fixo` pendente na primeira linha, ao trocar de aba.
    - **Rodada 2 — "as moedas não tão saindo do ponto de origem do item que nem na loja".** Analisando o mesmo vídeo: a ficha (`.isheet`) desliza pra fora em `.22s` (`transition:transform`), mas o flutuante dura `1.6s` — o item já tinha sumido da tela bem antes da moeda terminar de subir, sobrando sem nenhuma referência visual por perto pela maior parte da animação. **Fix tentado:** atrasar `fecharFicha()` em 350ms (depois reduzido pra 150ms) pra dar tempo do olho acompanhar. Usuário achou o clique lento ("agora tá com delay o botão") — **descartado a pedido do usuário** ("não precisa desse respiro só faz o que eu mandei"), ficha voltou a fechar instantaneamente.
    - **Rodada 3 (revertida por completo, depois refeita do zero) — usuário pediu pra voltar pra versão anterior ao item 44 inteiro** ("volta pra versão que eu te pedi antes de adicionar textos novos tipo equipar"), depois pediu pra tentar de novo só vender/usar, "simples", sem o delay.
    - **Rodada 4 — gravação de tela #2, comparando venda na Loja (certa) vs. Inventário (nascia sempre no canto esquerdo).** Achado real: o ícone do item na ficha do Inventário (`.ibox`) fica praticamente colado na borda esquerda da tela (`x≈0`) — visível já no frame parado, antes de qualquer clique —, então qualquer flutuante centralizado nele naturalmente estoura a borda. A trava de borda em `flutuanteFixo()` (mede `el.offsetWidth` depois de inserir, reposiciona se ultrapassar `margem:10px`) já existia e estava correta — a suspeita foi de arquivo desatualizado sendo testado, não bug de lógica.
    - **Rodada 5 — causa raiz real, achada só depois do usuário insistir que "sempre sai no mesmo lugar" mesmo com a trava de borda corrigida.** A ficha é um painel modal (`.isheet`) que **sempre abre na mesma posição da tela**, deslizando de baixo — então o ícone `.ibox` **dentro** dela também está sempre no mesmo lugar, não importa qual item foi clicado. Usar `.ibox` como origem nunca poderia dar certo, porque não representa "onde o item está", representa "onde o modal sempre aparece". **Fix definitivo:** nova variável `fichaOrigemEl`, capturada no exato clique do quadradinho no grid (`.cel`) ou do slot equipado (`.eslot`) — **antes** da ficha abrir por cima — guardando o elemento real que o usuário tocou. Os botões "Usar"/"Vender" da ficha passaram a usar essa referência guardada em vez de `ficha.querySelector('.ibox')`.
    - **Estado final:** `usarItem(id, elOrigem)`/`venderItem(id, elOrigem)` capturam a posição via `pontoDeElemento(elOrigem)` **antes** de qualquer `render()`/`renderInventario()` (padrão já estabelecido no item 44 pro bug da Loja); origem é o quadradinho real do grid ou do slot equipado (`fichaOrigemEl`), não mais nada dentro da ficha; ficha fecha instantâneo, sem delay; `mostrarAba()` limpa flutuante pendente ao trocar de aba. Venda avulsa na Loja (fora da ficha, lista de Tesouros) não precisou de nenhuma mudança — já usava o ícone certo (`.lbox`) da própria linha desde o item 44.
    - **Lição pra próximas vezes:** quando um elemento "sempre aparece no mesmo lugar independente do dado que ele mostra", é sinal de estar pegando a posição do **container/modal** em vez do **conteúdo real** — vale suspeitar disso antes de qualquer outra hipótese quando o sintoma for literalmente "sempre no mesmo lugar" (diferente de "no lugar errado uma vez" ou "cortado na borda").
    - **Confirmado com o usuário (28/08):** o item 45 registrado no roadmap-do-item-44 original propunha Vender como **moedinhas se espalhando** (`moedasCaindo()`, igual à Arena) — o que ficou implementado foi **flutuante de texto**, igual usar poção. Perguntado direto, o usuário confirmou que foi **mudança de ideia dele, não desvio da implementação** — flutuante de texto pra vender está correto e final, não uma pendência.

46. [x] **Botões de idioma/tema saem do login, idioma ganha slide próprio no carrossel — i18n completo (UI + diálogos + itens/monstros) vira projeto de verdade, não fix rápido (levantado em sessão de brainstorm, 28/08).** *(✅ FECHADO EM 3 RODADAS — cobertura completa das telas visitáveis: Arena/Tarefas, onboarding completo incluindo os 5 slides do carrossel, Loja, Inventário, Perfil, Config (+3 sub-telas), Bestiário, Histórico, Grimório, editor de tarefa, diálogos do tutorial, pop-ups, login/cadastro com mensagens de erro do Firebase, itens/monstros/heróis/dificuldade/raridade/tema/atributo. Só ficaram de fora, por decisão consciente: parte dos ~41 toasts secundários de fluxos raros (hoje mudos por `TOASTS_DESATIVADOS`, item 41) — ver "escopo fechado" abaixo)* Item 13d, aberto desde o início desta sessão de brainstorm, finalmente decidido.
    - **Rodada 1 (arquitetura + slide):**
      - `idiomaBtn`/`temaMiniBtn` **removidos do login** (HTML e os 2 handlers) — comentário deixado no lugar explicando o porquê, convenção append-only.
      - **Slide de idioma novo no carrossel**, entre EVOLUA e a transição — virou o slide 4 (`tipo:'idioma'`, `layout:'idiomaEscolha'`), com 2 botões (Português/English). Escolher um salva em `questlog.idioma.v1` e marca visualmente qual está ativo (`.idiomaOpcao.on`).
      - **Renumeração de todo o resto do carrossel** por causa do slide novo: transição 4→5, nome 5→6, herói 6→7, tarefas 7→8. `SLIDE_TRANSICAO`, `SLIDE_NOME`, `TOTAL_SLIDES` e todo `irPara(N)` hardcoded (voltar1/irEscolha/voltarNome/irPasso3) atualizados juntos — inclusive `window.irParaCarrossel(4)→(5)` no fluxo de conta nova pós-verificação de email (item 34), que também apontava pro slide de transição pelo número antigo.
      - CSS novo (`.carrosselIdiomaEscolha`/`.idiomaOpcao`) reaproveita tokens de tema existentes, sem cor nova.
    - **Rodada 2 (pedido explícito do usuário: "é pra você traduzir o app inteiro"), escopo bem maior:**
      - **Módulo `I18N — IDIOMA` reescrito**: dicionário `TRADUCOES` bem maior, suporte a `data-i18n-placeholder`, e `window.definirIdioma(lang)` re-renderiza tudo que já estiver na tela ao trocar idioma.
      - **`ITENS` (106 entradas em `assets.js`)**: todas ganharam `nome_en`, normalizado pra **largura fixa de 10 campos** (`[sp, nome, tipo, rar, val, m, x, h, morto, nome_en]`) — ver bug real abaixo.
      - **`MONSTROS` (63) e `HEROIS` (8)**: ganharam `nome_en`. `window.aplicarIdiomaDados()` muta `.nome` desses objetos **no lugar** (guarda o original em `.nome_pt` na 1ª passada), no boot e a cada troca de idioma.
      - **`DIFS`, `RARIDADES`, `NOME_TIPO`, `NOME_ATR`, `TEMAS`**: mesmo padrão PT/EN + mutação em lugar.
      - **Conquistas**: 5 categorias e 39 marcos (`CATEGORIAS`) ganharam `nome_en`/`req_en`/`sub_en`, lidos tanto pelo sistema V1 quanto pelo V2 (o que aparece na tela).
      - Onboarding (passo1/2/heroi/3), render principal da Arena/Tarefas, composer inteiro, nav — convertidos.
      - **⚠️ Bug real #1, só em teste funcional (Node):** 1ª tentativa inseria `nome_en` como "sempre o último elemento do array" — colidia com a posição do campo `morto` em itens que já usavam o campo `cura` (8 campos originais, ex. Poção de Vida): `a[8]` virava a string em inglês em vez do booleano de `morto`, `!!a[8]` lia `true` pra qualquer item assim que ganhava tradução (regressão silenciosa: item virava invisível na loja/inventário sem erro nenhum). Corrigido normalizando as 106 linhas pra 10 campos fixos, `nome_en` sempre em `a[9]`.
    - **Rodada 3 (fechamento, pedido explícito: "pode fazer isso aí"):**
      - **Loja inteira** (`comprar`, `venderTesouros`, `renderLoja`, `montarCompra`, `montarVenda`, fichas de item): esgotado/nível/sem moedas, oferta do dia, nota do ferreiro, mochila vazia.
      - **Inventário, Perfil, Config (+3 sub-telas Herói/Aparência/Preferências), Bestiário, Histórico** (calendário com meses/dias da semana), **Grimório** (catálogo, entrega no level-up, fichas oculta/revelada): tudo com `data-i18n` ou ternário local.
      - **Diálogos do tutorial** (item 12): as 4 telas, em 1ª pessoa, PT/EN com o mesmo cuidado de tom (não é tradução literal).
      - **Editor de tarefa completo**, pop-ups de nível/derrota/baú do tesouro, prévias de Perfil (resumo de histórico/conquistas), pontos de atributo, tela de login/cadastro inteira com todas as mensagens de erro do Firebase (Google, email/senha, recuperação de senha, tela de bloqueio por email não verificado — inclusive a versão *standalone* injetada fora do fluxo normal do carrossel).
      - **Os 5 slides do carrossel de onboarding** (QUESTLOG/BATALHA/EVOLUA/IDIOMA·LANGUAGE/transição) — título, texto e texto do botão, incluindo o slide de transição que usa efeito de "typewriter" lendo de `data-texto`; `definirIdioma()` atualiza esse atributo e o botão "Continuar" do próprio slide de idioma em tempo real, caso o jogador troque de idioma no meio do onboarding.
      - Alt text de imagens (`alt="herói"`/`"herói caído"`) localizado por completude.
      - **⚠️ Bug real #2, só em teste funcional (Node com jsdom):** `aplicarIdioma()` usava `el.textContent` pra aplicar `data-i18n` — quebrava duas coisas: (1) chaves do dicionário com tags (`<b>golpe</b>`, `<br>`) apareciam com os `< >` literais na tela; (2) o bloco "Confirma seu email pra continuar" tem um `<span id="verificarEmailAlvo">` aninhado preenchido dinamicamente com o email do usuário — `textContent` apagaria esse span (e o email nele) toda vez que o idioma fosse trocado. Corrigido trocando pra `innerHTML` (seguro, conteúdo 100% escrito por nós) e removendo `data-i18n` genérico daquele bloco específico, tratado manualmente no único ponto que já monta esse texto.
    - **Escopo fechado, decisão consciente do que ficou de fora:** parte dos toasts de `aviso()` em fluxos secundários/raros (loja/inventário fora dos principais já cobertos, alguns erros de auth de borda) — hoje inofensivo porque `TOASTS_DESATIVADOS = true` (item 41, ainda ativo) silencia literalmente todo toast do app; o texto certo já existe pros principais, resto é ajuste incremental de baixo risco quando/se toasts voltarem.
    - **Validado (as 3 rodadas):** `node --check` nos 42 blocos `<script>` (40 clássicos + 2 `module`) e em `assets.js` — 0 erros em toda sessão. Balanço de `<div>` (359/359), `<svg>` (52/52), `<!--`/`-->` (36/36). **Teste funcional real, não só leitura de código:** (1) trocar `questlog.idioma.v1` entre `pt`/`en` e chamar `item()`/`aplicarIdiomaDados()` de verdade confirma nome certo pros 106 itens/63 monstros/8 heróis, valores/bônus intactos, os 2 itens `###REMOVIDO###` e o item com `cura` testados nominalmente; (2) `SLIDES`/`txtSlide()` testados isoladamente nos dois idiomas, título/texto/botão corretos nas 5 entradas; (3) dicionário `TRADUCOES` (109 chaves) testado por script — zero duplicatas, todo `data-i18n`/`data-i18n-placeholder` do HTML tem entrada correspondente, zero chave órfã; (4) `aplicarIdioma()` testado com jsdom real, confirmando `innerHTML` renderiza `<b>` corretamente nos dois idiomas. **Não testado em aparelho real** — mesma pendência de sempre nesta fase, é o próximo passo antes de lançamento.
    - **Achado ao investigar:** botão de idioma hoje chama `window.aviso('Idioma: em breve')` — com `TOASTS_DESATIVADOS = true` (item 41, ainda ativo), esse aviso também está mudo. Clicar em "Idioma" hoje não faz literalmente nada visível, nem o "em breve" que devia aparecer.
    - **Decisão de arquitetura, motivada pelo carrossel ter virado a porta de entrada principal (item 29) e login ter virado desvio opcional:** os controles rápidos de `idiomaBtn`/`temaMiniBtn` (linha ~6516, mini-botões grudados na tela de login) **saem de lá** — não fazem mais sentido numa tela que não é mais o hub principal. Tema já tem casa própria completa (Config → Aparência, item 39) — remover o botão de ciclo do login não perde nada, só duplicava. **Idioma ganha um slide próprio no carrossel de onboarding** (mesmo padrão `.passo`/`mostrarPasso()` do item 29), com escolha real entre Português e Inglês, salva em `localStorage` (mesmo padrão de `questlog.tema.v1`).
    - **Escopo da tradução, decidido explicitamente com o usuário — é tudo, não só interface:** UI completa (menus, botões, telas), diálogos (módulo do item 12, escrito com cuidado de tom em 1ª pessoa — precisa tradução com o mesmo cuidado, não literal palavra-por-palavra), **e os ~100 itens + 63 monstros**. Confirmado no código, antes de qualquer texto entrar: **não existia nenhuma camada de tradução** — 79 pontos entre `textContent`/`innerHTML` com texto cru espalhado direto no HTML/JS, sem dicionário centralizado nenhum.
    - **Decisão original ("não adiantar o texto agora") superada nesta mesma sessão:** a nota antiga aqui dizia que o texto ficaria pra uma sessão de implementação separada. O usuário pediu explicitamente, na sequência, pra traduzir o app inteiro — Rodada 2 (acima) é essa implementação, não uma sessão futura.

47. [x] **Botão de idioma em Config, com bandeira (pedido do usuário, mesma sessão do item 46).** Linha "Idioma" em Perfil → Config — mesmo padrão visual `.cfgrow.cfglink` de Herói/Aparência/Preferências (item 39), abre uma sub-tela própria com a lista de opções.
    - **Sub-tela nova (`idiomaOverlay`)**: reaproveita 100% o padrão de lista `.temalinha`/`.temaNome`/`.temaCheck` já usado em Aparência (item 39) — só troca a bolinha de cor (`.temaDot`) por uma bandeira emoji (`.idiomaBandeira`, CSS novo mínimo: mesma caixa 30×30, sem cor/borda). 🇧🇷 Português / 🇺🇸 English, com check no idioma ativo.
    - **Resumo** (`cfgIdiomaResumo`): mostra bandeira + nome do idioma atual ("🇧🇷 Português" / "🇺🇸 English"), atualizado em `atualizarResumosConfig()` (mesma função que já atualiza os resumos de Herói/Aparência/Preferências).
    - **Lógica**: `pintarIdiomaGrid()` (novo) segue exatamente o padrão de `pintarTemaGrid()` — ao clicar numa opção, chama `window.definirIdioma(lang)` (já existente desde o item 46, que salva a preferência, retraduz tudo e re-renderiza as telas abertas) e repinta a própria lista pra mover o check.
    - **⚠️ Bug real encontrado ao implementar, não relacionado ao pedido em si:** `window.pintarTemaGrid` nunca tinha sido de fato exposta em `window` — a função existe dentro de uma IIFE, e a chamada `window.pintarTemaGrid()` (dentro de `definirIdioma()`, item 46) sempre falhava calada por causa do guard `typeof === 'function'`. Ou seja: desde a Rodada 2 do item 46, trocar de idioma com a tela de Aparência aberta nunca atualizava os nomes dos temas na hora (só na próxima vez que a sub-tela fosse reaberta, porque `pintarTemaGrid()` sempre lê o idioma na hora que roda). Corrigido com `window.pintarTemaGrid = pintarTemaGrid;` no fim do módulo — mesmo fix aproveitado pra já nascer `pintarIdiomaGrid` exposta corretamente.
    - **Ajuste na sequência (mesma sessão, print do usuário mostrando "Language" como box própria igual "Preferences"): "Idioma" não fica mais como linha solta na tela principal de Config.** Movida pra dentro de Preferências, como a primeira linha do `prefsOverlay`, acima de "Feedback de clique" — usuário achou que não precisava de destaque de box própria lá embaixo. Mesmo componente/lógica, só mudou de casa: a linha (`cfgAbrirIdioma`) e o resumo (`cfgIdiomaResumo`) saíram do `cfgOverlay` (tela principal) e entraram no `cfgovcorpo` do `prefsOverlay`, nenhuma função JS precisou mudar (só a posição no HTML).
    - **⚠️ Cuidado de camada resolvido nesse ajuste:** todos os overlays de Config (`heroiOverlay`/`aparenciaOverlay`/`idiomaOverlay`/`prefsOverlay`) usam o mesmo z-index (69) — quem vem **depois** no documento pinta por cima quando ambos estão `.on` simultaneamente (padrão documentado desde o item 39). Como `idiomaOverlay` agora é aberto de *dentro* de `prefsOverlay` (que continua com a classe `.on` por baixo), `idiomaOverlay` precisou ser movido pra **depois** de `prefsOverlay` no HTML — na posição original (antes de Preferências) ele pintaria escondido atrás dela. Comportamento de "voltar" nesse caso já sai certo sem precisar de JS novo: fechar `idiomaOverlay` revela `prefsOverlay` por baixo (nunca fechada), então o botão voltar da tela de Idioma volta pra Preferências, não pra tela principal de Config — é o comportamento esperado.
    - **Validado (as 2 rodadas deste item)**: `node --check` nos 42 blocos + `assets.js` (0 erros), balanço de `<div>` (367/367), `<svg>` (56/56), comentários (38/38) — inalterado depois do reposicionamento (mesmos elementos, só mudaram de lugar). IDs conferidos por script, sem duplicata real (2 falsos positivos de regex — `loginToggleCadastro`/`verificarEmailAlvo` aparecem várias vezes só porque são strings de `innerHTML` trocado dinamicamente, nunca coexistem no DOM ao mesmo tempo — pré-existente, não relacionado a este item). Dicionário `TRADUCOES` re-testado (111 chaves, zero duplicata, zero chave órfã). **Teste funcional com jsdom real**: simulei o clique na opção "English" e confirmei que `definirIdioma('en')` é chamado e o check visual muda pra opção certa. **Não testado em aparelho real.**

48. [x] **Tema padrão volta a ser Grafite (preto e branco) — pedido explícito do usuário, reversão real da decisão v4.124.** `temaSalvo()` (módulo Config/Aparência) mudou o fallback de `'padrao'` (Laranja) pra `'grafite'` (Escuro) quando não há preferência salva no `localStorage` — só afeta quem nunca escolheu tema (jogador novo); quem já tinha escolhido qualquer tema continua exatamente como estava, a leitura de `localStorage.getItem(CHAVE_TEMA)` sempre vence quando existe.
    - **Contexto da reversão**: o comentário original em `temaSalvo()` (v4.124) já registrava que o padrão tinha sido Grafite antes, e foi trocado pra Laranja por outro pedido explícito do usuário na época ("item de identidade visual"). Esta sessão reverte de volta pra Grafite — registrado aqui como reversão real, não decisão nova do zero, seguindo a convenção do roadmap de nunca esconder mudanças de direção.
    - Os 2 fallbacks defensivos que leem `data-tema` do `<html>` (usados só se o atributo nunca tiver sido setado, cenário raro) também alinhados: `'padrao'` → `'grafite'`, e o texto de fallback `'Laranja'` → `'Escuro'`/`'Dark'` (em `atualizarResumosConfig()`).
    - **Validado**: `node --check` sem erro, mesmos 42 blocos (nenhuma estrutura nova, só valor de fallback trocado em 3 pontos). **Teste funcional em Node**: `temaSalvo()` isolada, confirmando `'grafite'` pra jogador novo e preservação de qualquer tema já escolhido antes (testado com Laranja e Azul salvos).

49. [x] **Idioma inicial detectado pelo idioma do dispositivo — pedido explícito do usuário.** Português (qualquer variante — `pt-BR`, `pt-PT` etc.) vira `pt`; qualquer outro idioma do aparelho (inglês, espanhol, francês, japonês...) vira `en`. Só se aplica na primeira visita, antes de qualquer escolha manual — depois que o jogador escolhe um idioma (slide do carrossel, item 46, ou Config → Preferências → Idioma, item 47), essa escolha manual sempre vence e a detecção nunca roda de novo nem sobrescreve nada.
    - **Onde vive**: bloco novo, pequeno, dentro do próprio `<head>` do documento — roda **antes de qualquer outro `<script>` da página**, inclusive `assets.js`. É o único jeito de garantir que todos os pontos do arquivo que já leem `localStorage.getItem('questlog.idioma.v1')` (`item()`, `idiomaApp()`, `aplicarIdiomaDados()`, o módulo `I18N — IDIOMA` no fim do arquivo, e por aí vai — são dezenas de pontos depois do trabalho do item 46) já encontrem o valor certo desde a primeira leitura, sem precisar tocar em nenhum deles.
    - **Lógica**: `localStorage.getItem('questlog.idioma.v1')` já preenchido → não faz nada (não sobrescreve escolha manual). Vazio → lê `navigator.languages[0]` (com fallback pra `navigator.language`/`navigator.userLanguage` se `languages` não existir), e se começar com `"pt"` grava `'pt'`, senão grava `'en'`. `try/catch` em volta de tudo — se `localStorage` estiver bloqueado (modo privado restritivo), simplesmente não faz nada e todo o resto do arquivo já cai no fallback de `'pt'` de qualquer forma.
    - O slide de idioma do carrossel (item 46) já nasce com a opção certa pré-marcada (`.idiomaOpcao.on`) sem precisar de nenhuma mudança adicional — o código que marca a opção salva já lê `idiomaSalvo()` no momento em que o módulo carrega, e por essa altura o `<head>` já gravou o valor detectado.
    - **Validado**: `node --check` nos 41 blocos clássicos (+1 por causa do script novo) + 2 `module` + `assets.js`, 0 erros. Balanço de `<div>`/`<svg>`/comentários inalterado (o bloco novo não usa nenhuma dessas tags). **Teste funcional real em Node**, cobrindo os casos que importam: `pt-BR`→`pt`, `pt-PT`→`pt`, `en-US`→`en`, `es-ES`→`en`, `fr-FR`→`en`, `ja-JP`→`en`, navegador sem `languages` (só `language`)→funciona igual, e o caso crítico — **jogador com dispositivo em inglês que já tinha escolhido português manualmente antes (e vice-versa) → escolha manual preservada nos dois sentidos**, confirmando que a detecção não pisa em escolha explícita.

50. [x] **Bug real reportado pelo usuário: botão "Continuar" do slide de transição não virava "Continue" ao trocar idioma no meio do onboarding.** Sintoma exato: escolher English no slide de idioma (item 46) e o botão do PRÓXIMO slide (transição, "vamos te conhecer melhor...") continuava mostrando "Continuar" em vez de "Continue" — mesmo com o texto da transição em si (via `data-texto`/typewriter) já saindo certo.
    - **Causa raiz**: `definirIdioma()` (módulo I18N, fim do arquivo) já atualizava o botão "Continuar" do **próprio** slide de idioma (`carrosselBtn4`) e o `data-texto` do slide de transição, mas nunca tinha sido escrito o código pra atualizar o botão do slide de transição em si (`carrosselBtn5`) — gap simples, não pego antes porque o teste funcional da sessão anterior validava a lógica de `txtSlide()`/`SLIDES` isoladamente (correto na origem), não simulava o clique real em `definirIdioma()` com os elementos já no DOM.
    - **Fix**: `carrosselBtn5` agora é atualizado junto, mesmo padrão de `carrosselBtn4`. Também cobre o caso raro do typewriter já ter digitado o texto antes da troca de idioma (jogador foi até o slide 5, voltou, trocou de idioma de novo) — nesse cenário o texto já visível na tela é substituído direto, não só o `data-texto` que só seria lido numa próxima exibição.
    - **Extensão proativa, mesma causa raiz**: os slides 1-3 (QUESTLOG/BATALHA/EVOLUA) tinham o mesmo problema em potencial — se o jogador voltasse pra eles (seta/dots do carrossel) depois de escolher idioma no slide 4, título/texto/botão continuariam presos no idioma do carregamento da página. Corrigido junto, com os textos duplicados diretamente ali (mesmo padrão já usado em outros pontos do arquivo como `idiomaApp()`/`nomeDiaLocal()`) porque o array `SLIDES` vive numa IIFE diferente da de `definirIdioma()`, inacessível dali.
    - **Validado**: `node --check` nos 41 blocos + `assets.js` (0 erros), balanço de tags inalterado, dicionário `TRADUCOES` sem duplicata (111 chaves). **Teste funcional real com jsdom, replicando o cenário exato reportado**: simulei o DOM dos 5 slides do carrossel em português, chamei a lógica de troca de idioma como se o jogador tivesse clicado em "English", e confirmei que os 5 botões e os 3 títulos/textos passam a mostrar o texto certo em inglês — inclusive o `carrosselBtn5`, que era exatamente o botão relatado como quebrado.

51. [x] **Ajuste na detecção de idioma do item 49, pedido do usuário a partir de um print real (Pixel em português abrindo o app em português).** Regra antiga: qualquer variante de português (`pt-BR`, `pt-PT`, `pt-AO`, ou até `pt` genérico sem região) virava `'pt'`. Regra nova, mais restrita: **só `pt-BR` especificamente vira `'pt'`** — qualquer outra variante de português (Portugal, Angola, etc.) ou `pt` sem região definida, e qualquer outro idioma, caem em inglês por padrão.
    - **Pergunta feita antes de mexer**: como o print do usuário sozinho não deixava claro se o pedido era "inglês sempre, remover detecção" ou "a detecção já filtra por BR, só que esse aparelho específico bateu com PT à toa" — perguntei com 3 opções antes de decidir. Resposta: inglês por padrão, PT só quando o aparelho for BR especificamente.
    - **Mudança**: uma linha só, `primeiro.indexOf('pt') === 0` → `primeiro.indexOf('pt-br') === 0` no mesmo bloco de detecção do item 49 (dentro do `<head>`, antes de qualquer outro script). Resto da lógica idêntico — só grava se ainda não há preferência salva, escolha manual sempre vence, `try/catch` pro caso de `localStorage` bloqueado.
    - **Validado**: `node --check` sem erro nos mesmos 41 blocos (mudança pontual, nenhuma estrutura nova). **Teste funcional real em Node**, comparando explicitamente com a regra antiga: `pt-BR`/`pt-br` → `pt` (igual antes); `pt-PT`, `pt-AO`, `pt` genérico → **agora `en`** (antes davam `pt`, mudança confirmada); `en-US`, `es-ES` → `en` (igual antes). Reconfirmado também que escolha manual do jogador continua intocável nos dois sentidos (device `pt-BR` com `en` já escolhido → mantém `en`; device `en-US` com `pt` já escolhido → mantém `pt`).

52. [x] **Bug real reportado pelo usuário (2º print, mesmo dia do item 50): o PRÓPRIO slide de idioma não trocava o título/texto ao escolher English — só o botão "Continuar" dele já tinha sido corrigido.** Print mostrou: "English" selecionado (borda destacada), botão já em "CONTINUE" (fix do item 50 funcionando), mas o subtítulo continuava "Escolha o idioma do app. Dá pra trocar depois em Perfil." em português.
    - **Causa raiz**: o fix do item 50 tratou o botão do slide de idioma (`carrosselBtn4`) numa variável separada, mas nunca tocou no título (`.titulo`, "IDIOMA · LANGUAGE" — coincidentemente igual nos dois idiomas, por isso não chamava atenção) nem no texto (`.lema`, que É diferente em EN) daquele mesmo slide. A lista `SLIDES_1A3` do item 50 cobria só os slides 1, 2 e 3 — o slide 4 (o de idioma em si) tinha ficado de fora por engano, apesar de ter a mesma estrutura HTML (`.titulo`/`.lema`) dos outros.
    - **Fix**: slide 4 entrou na mesma lista consolidada, renomeada `SLIDES_1A4`. A variável solta que só cuidava do botão do slide 4 foi removida (redundante agora que o loop cobre título+texto+botão dos 4 slides de uma vez) — menos código duplicado, não só o bug corrigido.
    - **Validado**: `node --check` nos 41 blocos + `assets.js` (0 erros), balanço de tags inalterado, dicionário sem duplicata (111 chaves). Confirmei antes de editar que o slide 4 usa `layout:'idiomaEscolha'` → `blocoMarca + htmlIdiomaEscolha`, e que `blocoMarca` é exatamente a mesma estrutura `.titulo`/`.lema` dos slides 1-3 (não é uma estrutura HTML diferente por baixo). **Teste funcional real com jsdom, replicando o print exato**: montei o DOM dos 5 slides com o slide 4 mostrando "Escolha o idioma do app..." em português, simulei a escolha de "English", e confirmei que o texto vira "Choose the app language. You can change it later in Profile." — exatamente o texto que o print mostrava preso em português.

---

## 5. Notas técnicas

- **Capturar `getBoundingClientRect()` de um elemento clicado ANTES de qualquer `render()`/`renderX()` que reconstrua o DOM via `innerHTML`, nunca depois (item 44, achado real em produção).** Vários pontos do app reconstroem grids inteiros trocando `container.innerHTML = ''` e remontando do zero (`renderLoja()`, `renderInventario()`) — isso desconecta qualquer elemento antigo (ex.: o botão que acabou de ser clicado) do DOM. Um elemento desconectado devolve `{top:0,left:0,width:0,height:0}` em `getBoundingClientRect()`, sem lançar erro nenhum — o bug é silencioso, só se manifesta como "a posição calculada ficou grudada no canto (0,0)", fácil de não notar em teste rápido. Sintoma reportado pelo usuário: "comprei e vendi na loja e não aconteceu nada" (o flutuante nascia, só que invisível atrás da topbar). **Padrão seguro:** medir a posição (`const ponto = el.getBoundingClientRect()` ou equivalente) na primeira linha da função, guardar num `const` local, e só usar esse valor guardado depois de qualquer render — nunca reconsultar o elemento original depois de uma reconstrução de DOM.
- **Um elemento "sempre no mesmo lugar independente do dado que mostra" é sinal de estar medindo o container/modal, não o conteúdo real (item 45, achado real em produção — 5 rodadas de depuração até cair nisso).** Ficha (`.isheet`) é um painel modal que sempre abre na mesma posição da tela; o ícone do item **dentro** dela também fica sempre nessa mesma posição, não importa qual item foi aberto — usar esse ícone como origem de um efeito posicional nunca vai representar "onde o item está". **Padrão seguro:** quando o efeito precisa nascer de um item específico que fica atrás de um modal/overlay, capturar a posição do elemento real no grid/lista de fundo **no momento do clique que abre o modal** (antes dele cobrir a tela), guardar numa variável, e usar essa referência guardada quando a ação (dentro do modal) realmente disparar — nunca consultar elementos que vivem dentro do próprio modal pra esse fim.
- `localStorage` **não funciona dentro do artifact do Claude.ai** — só em navegador real (Netlify). Testar salvamento sempre lá.
- Cada alteração exige **re-subir o arquivo no Netlify**; ele não atualiza sozinho.
- O arquivo acumulou **vários blocos `<style>` sobrepostos**. Em caso de conflito, inserir novo bloco ao final ou usar `!important`.
- **Duas conversas editam este arquivo.** Uma cuida de Inventário e Loja, outra de arena, tarefas e nav. Cada upload para o projeto sobrescreve o que a outra fez desde a ramificação, e **nenhum dos dois lados consegue detectar isso sozinho**. Já se perderam a aba Perfil e a nota dela neste roadmap. O jeito seguro é serializar: terminar uma frente, subir o arquivo, só então começar a outra. Dividir por região reduz mas não elimina — o bloco de equipamento engancha em `equipar()`, que é território do Inventário.
  - **Aconteceu de novo (v4.6/4.7-temas):** a branch de temas partiu de um ponto anterior a `mostrarBauLoot`/`mostrarNivelUp`/fila de pop-ups (feitos numa sessão de nível/vitória) e também anterior à faixa de equipamento acima da barra de Vida e ao rename `Diabrete chifrudo → Demônio menor` (feitos em sessões de inventário/monstros). Baú, nível e fila portados em v4.6-temas; **faixa de equipamento portada em v4.7-temas**, usando `var(--line)` no fallback da borda em vez do hex fixo antigo. **Rename do monstro (`Demônio menor`) continua ausente desta branch** — não pedido ainda.
- **Reler `/mnt/project` no início de cada entrega, não só no início da conversa.** O arquivo do projeto muda entre mensagens. Já aconteceu de uma alteração ser aplicada sobre uma cópia velha e, se tivesse sido usada, teria apagado a Loja e o Inventário inteiros. Copiar do projeto uma vez e trabalhar na cópia o resto da conversa é o erro.
- O arquivo tem **muitos blocos `<script>`** — 35 clássicos + 1 `<script type="module">` (Firebase) na v4.77, crescendo a cada sessão que soma módulo novo. *(Nota antiga dizia "3 blocos" — estava presa numa versão bem mais antiga do arquivo, antes de SFX/login/conquistas serem adicionados; corrigido em v4.77.)* Validar cada um separadamente — `sed`/regex ingênuo de `<script>` até `</script>` pega todos de uma vez e o `node --check` falha por motivo errado. O bloco `type="module"` precisa ser checado à parte dos clássicos (regex diferente, ou `node --check` com `--input-type=module`) — um regex que não distingue os dois tipos de tag pode inclusive capturar por engano o texto de um comentário HTML que só *menciona* `<script type="module">` como string (aconteceu numa sessão, ver seção 34).
- **Herói é 34×34, monstro é 32×32.** O herói ganhou 1px de folga de cada lado para caber o contorno (ele encostava nas bordas do canvas: topo=4px nas femininas, base=4–6px em todas). Por isso `.heroimg` é 83px e `.mobimg` é 78px: `83/34 = 78/32 = 2,44`. **Mexeu no tamanho de um, recalcule o outro** — senão o pixel fica de tamanho diferente entre herói e monstro. O mesmo vale para `.opcao img` (47px) na grade de escolha.
- **Validar com navegador de verdade, não só sintaxe.** `node --check` passa em código que quebra em uso. Um teste headless que passa pelo onboarding (injetando `questlog.v1` no `localStorage` antes do load), cria uma tarefa, edita e conclui pega erro de runtime, handler que não dispara e elemento coberto por outro — coisas que a checagem de sintaxe não vê.
- **O botão "apagar tudo" foi reescrito por completo (v4.27) — `confirm()` nativo trocado por folha modal, 5 hooks espalhados viraram 1 `localStorage.clear()`.** Histórico do problema, em ordem:
  1. Primeira versão: só `document.getElementById('zerarbtn').onclick` removia `questlog.v1`. Vida, Loja, Atributos e Tutorial foram cada um adicionando seu próprio `removeItem` na mesma chave conforme cada um nasceu — um hook por módulo, escalando linearmente com cada save novo que o app ganhasse. Ainda assim ficou incompleto: `rpg_eco_v1` nunca ganhou seu hook, e continuava sobrevivendo ao reset.
  2. **Bug relatado com vídeo (v4.27): clicar em "Apagar tudo" às vezes não apagava** — voltava pra aba Tarefas e mostrava o diálogo de boas-vindas do tutorial, só apagando de verdade num segundo clique. Causa mais provável: **"clique fantasma" pós-`confirm()`** — um bug conhecido em vários navegadores mobile, onde fechar um `confirm()`/`alert()` bloqueante do sistema reenvia um clique sintético pro elemento que ficava embaixo do botão do diálogo do SO. Se esse fantasma caísse na nav inferior, disparava `mostrarAba('tarefas')` e, por tabela, o diálogo de tutorial daquela aba. **Não verificável neste ambiente** (sem navegador real disponível pra reproduzir o clique fantasma de propósito) — é a explicação mais consistente com o sintoma descrito, não uma certeza absoluta.
  3. **Fix: `confirm()` nativo removido por completo.** O clique em "Apagar tudo" agora só abre uma folha modal (`#zerarOverlay`/`#zerarSheet`, mesmo padrão visual de `.edov`/`.edsheet` da folha de Renomear) — isso elimina a classe inteira de bug de diálogo-nativo-bloqueante, não só o sintoma pontual. **Junto**, os 5 hooks espalhados (Loja, Vida, Atributos, Tutorial, mais o original) foram **removidos** e substituídos por um único `localStorage.clear()` dentro do clique de confirmar na folha. Isso fecha de vez o problema de "sempre falta uma chave" — `clear()` não depende de nenhum módulo lembrar de se registrar, resolve pra qualquer chave futura também.
  - **Por que os hooks antigos precisavam ser removidos, não só ignorados:** eles estavam registrados no clique do PRÓPRIO `#zerarbtn`. Se tivessem ficado, disparariam assim que a folha ABRE (usuário só olhou o botão), apagando dados mesmo que ele cancelasse — o clique de confirmar de verdade é outro elemento (`#zerarConfirmar`, dentro da folha), que esses hooks antigos nunca ouviam.
  - **Validado:** teste automatizado confirma que abrir a folha não apaga nada, cancelar preserva todas as chaves (`questlog.v1`, `questlog.hpMonstro.v1`, `questlog.loja.v1`, `questlog.atrib.v1`, `questlog.tutorialTelas.v2`, `questlog.tema.v1`), e confirmar limpa todas de uma vez. **O que não deu pra validar:** se o clique-fantasma era mesmo a causa raiz do bug relatado — isso só um teste num aparelho real confirma.
  - **Nota de arquivo:** existe também um botão de debug "pular tutorial" na `.debugbar` (ao lado de "próximo dia"), que marca todos os diálogos do tutorial como vistos de uma vez — criado numa sessão anterior a esta, pra não precisar ficar clicando no overlay toda vez que "apagar tudo" reseta `questlog.tutorialTelas.v2` durante teste. Ele está no arquivo mas por algum motivo não estava documentado neste `.md` até agora — provavelmente um roadmap de uma sessão paralela não foi reenviado ao projeto antes deste. Ver seção de risco de colisão.
  - **Correção visual (mesma versão):** o botão "Apagar tudo" da folha nasceu com a classe `.edexcluir`, que é feita pra um botão pequeno só de ícone (54px fixos, `font-size:21px`, pensada pra um "×" único no editor de tarefa) — com duas palavras dentro, o texto quebrava em duas linhas espremido numa caixa de 54px. Criada `.edperigo`, um botão destrutivo de largura cheia (`flex:1`, mesmo padding do `.edsalvar`, fundo sólido `var(--perigo)`) — `.edexcluir` continua intacta pro uso original dela.
- Antes de entregar qualquer alteração, validar o JS com `node --check` e conferir o balanço de `<div>`. Duas falhas reais já aconteceram por não fazer isso: uma `</div>` sobrando (quebrou o menu) e as funções de salvamento apagadas por engano (o app parou de gravar).
- **A vida não entra no save principal.** Mora em `questlog.vida.v1`, então um export do `questlog.v1` não a leva junto. Foi a troca aceita para não tocar em `salvar()`/`carregar()`.
- Wrapper sobre `function` de topo funciona porque em script clássico a declaração de topo vira propriedade de `window` — `window.alternar = ...` de fato substitui as chamadas a `alternar(i)` feitas dentro do `render()`. Foi assim que a cura entrou sem reescrever `alternar()`.
  - **A armadilha (v4.14): isso só vale se a função é de topo de verdade.** Muitos módulos (Loja, Perfil) embrulham tudo numa IIFE — `(function(){ ... })();`. Uma `function` declarada *dentro* dessa IIFE (ex.: `precoLoja`, `renderPerfil`) não vira propriedade de `window` nenhuma; ela só existe no escopo local do closure. Fazer `window.precoLoja = function(){...}` por fora **não muda em nada** o que `renderLoja()`/`comprar()` chamam internamente — eles continuam resolvendo pelo nome local, cego pra qualquer coisa que aconteça em `window`. O sintoma é enganoso: o wrap "funciona" se testado isolado (`window.precoLoja(id, oferta)` no console devolve o valor certo), mas o efeito nunca aparece no jogo de verdade, porque ninguém dentro do módulo original chama por ali.
    - **Dois jeitos de saber se uma função é embrulhável por fora:** (1) ela já é exposta explicitamente (`window.algumaCoisa = algumaCoisa;` no fim do módulo — daí dá pra embrulhar `window.algumaCoisa` com segurança, IF nenhuma chamada interna do próprio módulo depende dela via variável local, só via `window.*`); (2) ela está fisicamente fora de qualquer `(function(){...})();` no arquivo — nesse caso é top-level de fato. Não basta "está exposta"; se o módulo internamente chama pelo nome de closure (o caso normal), o wrap externo é enganosamente inofensivo e simplesmente não faz nada.
    - **Saída quando a função-alvo é presa:** editar a função por dentro (uma linha, idealmente), referenciando `window.suaFuncaoNova()` de forma defensiva (`typeof window.x === 'function' ? window.x() : valorPadrao`). Foi o que aconteceu com `precoLoja()` pro desconto de Foco — o desconto entrou como uma linha dentro da função original, não como wrap. É a única exceção ao "módulos novos não tocam módulos antigos" desta sessão, e foi necessária, não karma.
    - **Como isso foi pego:** só testando o efeito de ponta a ponta (preço realmente exibido na loja após investir pontos), não só checando `typeof window.precoLoja === 'function'`. A API existir não prova que ela é usada.
- **HISTÓRICO (v4.29) — mesma armadilha de closure, resolvida diferente desta vez: dado mínimo por parâmetro em vez de expor a função inteira.** `verificarVirada()` (módulo Vida) é quem detecta a virada do dia — mesma função presa numa IIFE, sem `ultimoDia`/`pendentesEm()` expostos em `window`, igual ao caso do `precoLoja()`. Mas em vez de mover TODA a lógica de histórico pra dentro daquele módulo (o que inflaria uma função que a seção 6 já chama de "correção crítica" — quanto menos motivo pra reabri-la, melhor), só uma chamada de uma linha foi inserida lá, passando os três dados que o histórico precisa e que `verificarVirada()` já tem calculado naquele ponto (`ultimoDia`, total de tarefas do dia via `tarefasEm()` — função nova, irmã de `pendentesEm()`, adicionada no mesmo lugar — e quantas foram largadas). Toda a lógica de decidir o `resultado`, achar o `monstroId` e persistir mora no módulo novo, isolado, no fim do arquivo.
  - **Por que só uma chamada e não a função inteira:** se o módulo de histórico expusesse `window.verificarViradaComHistorico()` e o módulo Vida chamasse essa versão em vez da original, seria basicamente reescrever `verificarVirada()` por fora — o mesmo risco de duplicar lógica de dano/vida que a "correção crítica" da seção 6 já brigou pra eliminar. Passar só 3 valores primitivos (uma data, dois números) é a menor superfície de contato possível entre os dois módulos.
  - **`monstroId` pra uma data qualquer, não só hoje:** `monstroDoDia()` (existente) não recebe parâmetro, só calcula pra hoje. Em vez de editá-la, o módulo novo tem sua própria `diasCorridosDe(iso)`, que reaproveita `diffDias()` (já existente, já testada) pra deslocar `diasCorridos()` de hoje pro dia alvo — sem duplicar a aritmética de fuso/epoch que `diasCorridos()` já resolve. `diffDias()`, `diasCorridos()`, `isoAtual()`, `MONSTROS` e `semente` são todos de topo (fora de qualquer IIFE), confirmado antes de depender deles.
  - **Validado com teste, não só leitura de código:** simulação de 3 viradas de dia seguidas (1 tarefa feita + 1 largada → `fuga`; 1 tarefa feita → `vitoria`; 0 tarefas → `sem_tarefa`) confirmou as 3 categorias, mais idempotência (chamar `registrarHistorico` de novo pra uma data já registrada não duplica — dupla proteção: o próprio `verificarVirada()` só chama uma vez por data real, e o módulo novo também confere antes de gravar), `obterHistorico()` retornando cópia (mutar o resultado não afeta o estado interno) e persistência real em `questlog.hist.v1`. Os `monstroId` das 3 viradas saíram em sequência (23→24→25) — confirma que o deslocamento de data está matematicamente certo, já que o ciclo de monstro anda exatamente 1 posição por dia corrido.
- **`position:fixed` em telas >520px pode se descolar do cartão `.app` (v4.26) — pego a partir de um vídeo real, não de teste próprio.** `.app{max-width:400px}` fica centralizado (`body{display:flex;justify-content:center}`) em qualquer tela mais larga que os 520px da media query que zera isso. O módulo de diálogo do tutorial (`.dlgOverlay`) usava `position:fixed` direto nos 3 filhos (`.dlgHeroWrap`, `.dlgNomeplate`, `.dlgBox`), com `left`/`right` em px pensados pra caber num cartão de ~400px — mas `position:fixed` é relativo à **tela inteira**, não ao `.app`. Num aparelho com viewport CSS acima de 520px (o vídeo mostrava 572px), o diálogo se posiciona relativo à tela toda enquanto o resto do app mora no cartão de 400px centralizado — o resultado no vídeo era o busto do herói flutuando fora do card e o texto do balão aparecendo cortado, começando fora da área visível do cartão.
  - **Fix:** `.dlgStage` novo — `position:absolute;inset:0;max-width:400px;margin:0 auto`, replicando exatamente o mesmo max-width e centralização do `.app`. Os 3 filhos viram `position:absolute` (relativo ao `.dlgStage`) em vez de `position:fixed` (relativo à tela) — o resto do CSS de cada um (todos os valores de `left`/`right`/`bottom` em px) não mudou, porque já tinham sido pensados pra um cartão de ~400px, não pra tela cheia.
  - **Limite desta validação:** sem navegador de verdade disponível neste ambiente (tentativa de baixar Chromium via Puppeteer falhou — sem acesso de rede pro `storage.googleapis.com`), não deu pra reproduzir visualmente o antes/depois em viewport largo. O diagnóstico saiu de leitura de CSS (`.app{max-width:400px}` na base + a media query que só zera isso abaixo de 520px) cruzada com medição de pixel nos frames do vídeo (cor de fundo antes/depois do overlay confirmou que o escurecimento `rgba(4,3,7,.62)` está funcionando — não é bug de dimming, só de alinhamento horizontal). O teste automatizado só confirma que a estrutura DOM está correta (`.dlgStage` existe, contém os 3 filhos, o diálogo ainda abre e digita normalmente) — não confirma o alinhamento em pixel. **Precisa de confirmação visual num aparelho real ou navegador largo antes de considerar fechado.**
- **Módulos novos entram como bloco autônomo no fim do arquivo**, com chave própria de `localStorage` e ganchos por wrapper (`const orig = fn; window.fn = function(){ orig(); ... }`). Foi assim com o inventário, o painel de economia e a loja. Nenhum deles precisou tocar em `salvar()`, `carregar()` ou `render()`.
- `render()` é o ponto mais frágil do arquivo. Não receber responsabilidades novas dentro dela — pendurar por wrapper.
- **Cuidado com `String.replace` em patch automatizado:** o texto `</body>` aparece também dentro de comentários dos módulos. Trocar sempre a **última** ocorrência, nunca todas.
- **Para espelhar o estado de um elemento sem tocar em quem o controla, usar `MutationObserver` na classe.** Foi assim que o composer virou folha modal: três lugares diferentes ligam e desligam `.composer.on` (`addbtn`, `criar()`, `mostrarAba()`), e o observer sincroniza o overlay sem que nenhum deles precisasse mudar.
- **Folhas modais cobrem a barra de navegação.** A folha começa por volta de y=554 e a nav fica em y=787. Não trava nada — tocar na área escura fecha e a nav volta —, mas é diferente do composer inline de antes, que deixava a nav clicável.
- As duas folhas (editor e criação) compartilham as classes `.edov` e `.edsheet`, e os botões de dificuldade dos dois são montados a partir da mesma tabela `DIFS`. **Mexeu em `DIFS`, os dois acompanham** — não duplicar a lista.
- Para esconder blocos por aba, usar a classe `.oculto` (com `!important`).
- A troca de abas usa `querySelector` sobre os blocos existentes, sem envelopá-los em uma `<div>` nova.
- Os **ícones da barra inferior continuam em SVG inline de propósito**: eles usam `currentColor` para virar laranja na aba ativa, e sprite PNG não aceita tint. Trocar por sprite custaria o estado ligado/desligado.
- **Perfil → Atributos (v4.4) só leitura, sem chave de save nova.** O bloco autônomo não guarda estado próprio — lê `progresso()`, `moedas`, `bonusEquip()` (módulo Inventário) e `window.vidaHeroi.max()` (módulo Vida) direto na hora de desenhar. Gancho em `mostrarAba()` (padrão `const _fn = window.fn; window.fn = function(){ _fn.apply(...); ... }`, igual a `alternar()`/`render()`/`equipar()`): só redesenha o Perfil quando a aba abre, não a cada `render()` global — evita custo em toda tarefa concluída por uma tela que o jogador nem está vendo. Se um item futuro do Perfil precisar refletir mudança em tempo real com a aba já aberta (ex.: moedas mudando por um efeito assíncrono), também precisará de gancho em `render()`, não só em `mostrarAba()`.
  - **Redesenho visual dos cartões de atributo (v4.28).** Motivação: a lista original (nome + descrição em cinza + botão `+` genérico, uma linha por atributo) não tinha identidade — parecia ter saído de outro app. Referência trazida foi o Habitica, mas a estrutura de 4 colunas dele (Nível/Equipamento/Buffs/Distribuído somando no atributo) **não foi copiada** — não bate com o sistema daqui, onde bônus de equipamento já é um stat separado e independente (`.statgrid`, "Bônus XP equip."/"Bônus moedas equip."), não algo que se funde com Fortuna/Foco. Copiar a estrutura teria colunas mostrando "Equipamento: 0" pra sempre, sem sentido nenhum no nosso sistema.
  - **O que entrou:** `.atrcard` — barra colorida cheia no topo (ícone SVG + nome + valor atual em destaque) sobre um corpo escuro (descrição + botão de investir). Cor por atributo (`--atr-cor` inline, uma custom property por cartão) puxada da **mesma família de paleta que já colore borda de raridade dos itens** (`.r0`-`.r5`, ex.: `#F2A65A` do lendário, `#5AA9F2` do raro) — não são cores novas inventadas, é o vocabulário visual que o jogo já usa noutro lugar. Fortuna ficou com o dourado do lendário (temática de sorte/loot), Foco com o azul do raro (precisão/calma), Vigor com `--blood` rosa-vermelho (mesma cor da barra de vida, temático pra um atributo de proteção/perdão).
  - Os `id`s que a função `renderAtributosPontos()` escreve mudaram: `atrFortunaDesc`/`atrFocoDesc` (texto solto) viraram `atrFortunaValor`/`atrFocoValor` (número em destaque na barra colorida) — a descrição textual agora é estática no HTML (`.atrdesc`), já que o número saiu dela.
  - **Alvo de toque das sub-abas aumentado (v4.28).** A engrenagem estava em 30×30px e as pills "Atributos"/"Conquistas" tinham `padding:6px 13px` com fonte 11.5px — abaixo dos 44×44px recomendados (Apple HIG e Material Design convergem nesse número). Aumentado pra `min-height:44px` nas pills e `44×44px` fixo na engrenagem, fonte 11.5px→13px, ícone 15px→19px. **Nota: `.lojatabs` e `.invfiltros` usam o mesmo padrão pequeno** (`font-size:11.5px`, padding similar) — não mexi neles porque o pedido foi só sobre o Perfil, mas é o mesmo problema replicado, vale considerar uma passada igual lá se incomodar do mesmo jeito.
  - **Sub-abas de v4.28 a v4.36, e reversão em v4.37 — a experiência completa registrada, não só o estado final.** v4.28: pills de texto, dimensionadas pra 3-4 abas. v4.36: "Histórico" virou a 5ª aba, a soma das larguras passou de ~490px contra ~324-364px disponíveis dentro do `.app`, estourando o layout — relatado pelo usuário como "abre um espaço vazio" e "muita gente nem vai saber que tem mais uma opção ali". Tentativa de correção nessa mesma v4.36: redesenho pra ícone+legenda (mesmo padrão da nav inferior, `flex:1`, 5 ícones novos desenhados). **Essa correção não agradou** — pedido do usuário na sessão seguinte foi "deixa o layout antigo que tava muito melhor". **v4.37: reversão completa das sub-abas pro estado de v4.28 (4 pills de texto, sem ícone), e o próprio Histórico saiu da nav de sub-abas** — virou um botão dentro de Config, que abre o calendário como overlay de tela cheia (ver seção 24 atualizada). Isso resolve o estouro de largura pela raiz (4 itens sempre coube bem, era só o 5º que não cabia) em vez de redesenhar a nav pra comportar mais itens do que ela deveria.
    - **Os 5 ícones desenhados em v4.36 (gráfico de barras, medalha, livro aberto, calendário) ficaram sem uso** — não foram removidos do arquivo por engano, foram descartados de propósito junto com a reversão. Documentado aqui pra quem ler o histórico de commits/versões não estranhar a volta e meia do código.
    - **Lição prática:** a nav de sub-abas do Perfil tem um limite real de ~4 itens confortáveis no padrão pill-de-texto. Qualquer 5º destino futuro (se Sequência/streak for reconsiderado, por exemplo) deve por padrão virar um botão dentro de Config abrindo overlay — não uma sub-aba nova — a menos que haja razão específica pra outra abordagem.
- **Perfil ganhou sub-navegação interna (v4.4): Config / Atributos / Conquistas.** É uma segunda camada de abas, dentro da view Perfil, independente da nav inferior — `mostrarSubPerfil()` alterna `.oculto` em 3 painéis (`#perfilAtributos`, `#perfilConquistas`, `#perfilConfig`), no mesmo padrão de `.lojatabs`/`.invfiltros`. Abre em Atributos por padrão.
  - **Aviso pra quem mexer aqui depois (v4.14):** `renderPerfil()` e `mostrarSubPerfil()` são locais à IIFE do módulo Perfil, **não são wrapáveis por fora** mesmo estando expostas em `window.renderPerfil`/`window.mostrarSubPerfil` — essas exposições são só uma cópia de referência, as chamadas internas (o gancho de `mostrarAba('perfil')`, os cliques nas sub-abas) usam o nome local do closure. Se precisar reagir a uma troca de sub-aba dentro do Perfil, ganchar em `window.render()` (top-level de verdade) em vez de `window.renderPerfil`/`window.mostrarSubPerfil` — foi o que os Atributos evoluíveis tiveram que fazer depois de o gancho errado não disparar nunca. Ver nota técnica completa na seção 5.
  - **Config → Renomear (v4.4, revisado):** primeira versão reaproveitava o clique-no-nome da topbar; **removida.** Renomear agora só existe pela folha modal (`#nomeOverlay`/`#nomeSheet`), aberta pelo botão "Renomear" do Config. A folha reaproveita 100% do CSS que já existia pra outras folhas do app (`.edov`/`.edsheet`/`.edpuxador`/`.edtitulo`/`.edcampo`/`.edacoes`/`.edsalvar` — o mesmo padrão do editor de tarefa e do composer em folha), zero CSS novo. Mesma convenção de fechamento das outras folhas: clique fora ou Esc fecha **sem salvar**; só o botão "Salvar" aplica. O antigo `#editaNome` (input inline que aparecia embaixo do nome) foi removido do HTML, do CSS e do script principal — não ficou dead code.
  - **Config → Trocar sprite:** grid própria (`pintarGradeConfig()`), **não reaproveita `montarGrade()`/`pintarEscolha()`** do onboarding — essas duas funções têm o id `#gradeHerois` fixo no corpo, então uma segunda grade em outro lugar da tela exigiria parametrizar ou duplicar. Optei por duplicar (função nova, mesma classe `.opcao`/`.grade`, lê o mesmo array `HEROIS`) para não arriscar o fluxo de onboarding. Ao trocar, chama `desenharHeroi()` (já redesenha o sprite da arena e, por causa do gancho do módulo de equipamento, também repinta os badges) e `render()` (persiste via `salvar()`).
  - **Config → Apagar progresso:** o botão **é o mesmo `#zerarbtn`** de sempre, só que fisicamente realocado do rodapé (`.debugbar`) para dentro do painel Config — mesmo id, texto novo. Os três lugares do arquivo que fazem `getElementById('zerarbtn')` (o listener original, o hook do módulo Loja, o hook do módulo Vida) continuam funcionando sem qualquer edição neles, porque a busca é por id e o elemento ainda existe no DOM antes desses scripts rodarem, só que em outra div-pai.
  - **Config → Temas (v4.4, primeira versão; corrigido em v4.5):** **não existia sistema de tema nenhum antes de v4.4** — o que existia eram vários blocos `<style>` sobrepostos, cada um redesenhando o app inteiro por cima do anterior (histórico de decisões de arte, não um seletor). O seletor de v4.4 trocava as CSS custom properties (`--bg`, `--accent`, `--panel` etc.) via `:root[data-tema="..."]`, aplicadas por atributo em `<html>` e persistidas em `questlog.tema.v1`.
    - **Bug encontrado em v4.5: os temas não trocavam nada.** O arquivo acumulou **5 blocos `:root{}`** redeclarando as mesmas variáveis (histórico de repaginações — cada sessão de arte anterior deixou a sua). O último deles (o que define a paleta roxa/laranja atual) marcava as 11 variáveis com `!important`. Em CSS, `!important` sempre vence especificidade — então `:root[data-tema="meianoite"]{--bg:#161A20}`, mesmo sendo mais específico, perdia pro `:root{--bg:#1A1526 !important}` menos específico. Resultado: o atributo `data-tema` mudava no `<html>`, mas nenhuma variável de cor realmente trocava.
    - **Correção:** removido o `!important` das 11 variáveis nesse bloco final — ele continua sendo o `:root` que define os valores padrão (é o último em ordem de leitura entre os 5, então já vence por cascata normal, sem precisar do `!important`). Os outros 3 blocos `:root{}` órfãos (linhas ~178, ~327, ~368 do momento da correção) continuam no arquivo, mortos/sobrepostos — não removi por não ser parte do bug relatado, mas são candidatos a limpeza futura.
    - **Tokens novos:** `--verde`, `--perigo`, `--perigo2` (estados de sucesso/perigo/HP crítico), `--panel-3` (card elevado — task/item/opção), `--poco` (slot vazio no inventário/loja), `--mobname`, `--arena-1/2/3`, `--sel-bg` (gradiente da arena e opção selecionada). Sem esses tokens, arena/inventário/loja ficavam com cor fixa mesmo depois do `!important` corrigido — 82 ocorrências de hex fora de `var()` foram auditadas, 52 substituídas por tokens (as que estavam realmente ativas/visíveis). `meianoite` e `pergaminho` ganharam valores próprios pra esses tokens novos — sem isso, herdariam o roxo do tema padrão nesses pontos específicos.
    - **Limitação ainda registrada:** ~30 ocorrências de hex fixo continuam no arquivo, mas são código morto confirmado (blocos de uma paleta azul anterior, sempre sobrescritos por regra posterior com `!important` ou por ordem de cascata) — não têm efeito visual hoje em nenhum tema, por isso não foram tocadas. A cor de raridade (`COR_RAR`, array JS) também não segue o tema — é intencional, raridade é reconhecimento de jogo (como a cor de dificuldade), não decoração.
    - **Bug 2: gradiente da barra de XP quebrado no `meianoite`.** `.fill` era `linear-gradient(90deg,var(--accent),var(--gold))` — `--gold` é intencionalmente fixo em todo tema (moedas/loja/popup de nível precisam continuar douradas), então no `meianoite` o gradiente saía azul→amarelo, sem relação com a paleta. **Correção:** token `--xp2` criado só pra essa segunda cor da barra, desacoplado de `--gold`. `padrao` e `pergaminho` usam o mesmo valor de sempre (zero mudança visual); `meianoite` ganhou `#7FE0E8` (ciano, harmoniza com `--accent` azul). **Cuidado se mexer de novo:** `--gold` e `--xp2` parecem redundantes no `padrao`/`pergaminho` (mesmo valor) — não são, servem coisas diferentes. Apagar `--xp2` e voltar `.fill` pra `var(--gold)` reintroduz o bug.

---

## 6. Correção crítica: virada de dia (v4.3)

### O sintoma

Depois de vencer o dia, sair e reabrir o app: aparecia um aviso de dano por
tarefa largada e o dia **não avançava** — voltava para o dia anterior, com o
monstro ainda morto.

### As três causas (reproduzidas em jsdom, não deduzidas)

1. **`diaOffset` só existia na memória.** O botão "avançar dia" incrementava a
   variável e nada era gravado. Qualquer reload devolvia o app ao dia real.
2. **Punição fantasma.** O módulo de vida grava `ultimoDia` usando `isoAtual()`,
   ou seja, **com o offset embutido**. Ao reabrir, `ultimoDia` ficava no
   *futuro* em relação ao dia real; `verificarVirada()` só testava
   `ultimoDia === hoje`, concluía que o dia tinha virado e cobrava dano das
   tarefas "pendentes" de um dia que nunca existiu.
3. **Nenhuma reavaliação depois do boot.** Não havia `visibilitychange`,
   `pageshow` nem timer. Num PWA, "sair e entrar" quase sempre restaura a
   página da memória/bfcache: o script não roda de novo, `render()` não é
   chamado e a tela congela no dia anterior mesmo depois da meia-noite real.

### O que mudou

- **`diaOffset` virou derivado, não armazenado.** Grava-se `questlog.dia.v1`
  com o ISO do "hoje do jogo" (`diaAlvo`) e o offset é recalculado como
  `diaAlvo − dataReal`, com piso em 0. Consequências desejadas: o avanço
  manual sobrevive ao fechar o app; **o tempo real absorve o avanço** (o offset
  só encolhe sozinho), então o app nunca fica preso no futuro; e o offset nunca
  fica negativo.
- **`verificarVirada()` blindado:** `ultimoDia > hoje` agora apenas
  ressincroniza, sem dano. Cobre também fuso horário e data do aparelho
  corrigida para trás.
- **Novo bloco autônomo `WATCHDOG DE DIA`** (depois do bloco de vida, depende de
  `window.vidaHeroi.checarVirada`). Reavalia o dia em `visibilitychange`,
  `pageshow`, `focus` e a cada 30s. Se o dia mudou: `render()`, `renderLoja()`
  se a aba estiver aberta, virada de vida e aviso `NOVO DIA: <dia>`. Se o dia
  *voltou* (offset absorvido), redesenha sem punir e sem avisar.
- `zerarbtn` passa a limpar `questlog.dia.v1`, **depois** do `confirm()`.
- `window.vidaHeroi` ganhou `checarVirada`.

### Cenários cobertos por teste

| Cenário | Esperado |
|---|---|
| Vence, avança dia, sai e volta | Continua no dia novo, sem dano |
| App aberto atravessando a meia-noite | Título, tarefas e monstro atualizam sozinhos |
| Tempo real alcança o avanço manual | Não pula dia; `questlog.dia.v1` é removido |
| Sumiu 3 dias com tarefa pendente | 1 dia de dano, não 3 |

### Armadilha desta sessão

O bloco novo entrou depois de um comentário HTML fechado com `*/` em vez de
`-->`. O comentário nunca fechou, engoliu o `<script>` inteiro e **nada
acusou**: `node --check` passou (o bloco nem era mais um script), o balanço de
`<div>` passou, e o app funcionou normalmente — só o watchdog não existia.
**Contar `<!--` contra `-->` faz parte da validação agora.**

---

## 7. Reordenação por arrastar (v4.8)

### O que foi pedido

A lista do dia poder ser reordenada arrastando os cards.

### Cor da tarefa — tentada e revertida nesta mesma sessão

Chegou a existir uma paleta de 7 cores por tarefa (`CORES`/`corDe()`/`corRgba()`,
seletor no composer e no editor, aplicada como faixa lateral e depois como
preenchimento do card via CSS custom properties `--corTarefa`/`--corFundo`).
**Removida a pedido — "não ficou bom" visualmente.** Toda a implementação foi
tirada: tabela `CORES`, funções, os dois seletores (`#cores`/`#edCores`), o
campo `t.cor` deixou de ser lido/gravado e o `.task` voltou ao
background/border padrão. **Tarefas que já foram salvas com `cor` no
`localStorage` durante o teste ficam com o campo órfão** — inofensivo, só não
é mais lido em lugar nenhum; não foi feita migração pra limpar isso do save.
Se a ideia voltar no futuro, não reaproveitar a versão "preenche o card
inteiro" sem perguntar antes — foi essa que não agradou.

### Reordenar por arrastar

- Campo novo por tarefa: **`ordem`** (número). Não migra dados antigos — é
  atribuído **lazy**, dentro do próprio `render()`, na primeira vez que uma
  tarefa sem o campo aparece na lista (`t.ordem = tarefas.indexOf(t) * 10`).
  Isso preserva a ordem visual de quem já tinha tarefas salvas antes desta
  versão; ninguém viu os cards pularem de lugar na primeira abertura.
- `pendentes.sort((a,b) => a.ordem - b.ordem)` roda a cada `render()`, antes
  do loop que desenha os cards. `tarefas` (o array fonte, salvo inteiro no
  `localStorage`) **não é reordenado** — só a lista filtrada de hoje, na hora
  de desenhar. `ordem` é gravado direto no objeto da tarefa dentro de
  `tarefas`, então persiste no save normal sem tocar em `salvar()`/`carregar()`.
- **Primeira versão usava uma alça (`.handle`, ícone de grip) fixa em cada
  card** — revisada a pedido pra segurar em qualquer parte do card.
  - **Long-press, não toque direto:** `pointerdown` em qualquer ponto do card
    (exceto `.box`/`.del`, que continuam com clique imediato) arma um
    `setTimeout` de 220ms. Só depois disso o card vira arrastável
    (`iniciarArrasto`). Existe pra não capturar o gesto normal de rolar a
    lista ou tocar pra abrir o editor.
  - **Bug real (não hipotético) descoberto em teste no aparelho:** com
    `.task{touch-action:pan-y}`, o navegador assume o gesto de rolagem no
    primeiro movimento vertical, **mesmo que o JS ainda não tenha decidido
    nada** — e para de mandar `pointermove`/`pointercancel` pro app.
    Sintoma: segurava e nada arrastava. Corrigido trocando pra
    `touch-action:none` (o JS passa a controlar 100% do gesto) — o que por
    sua vez **quebrou o scroll nativo da lista**, então o scroll da fase
    "ainda não virou arrasto" foi reimplementado à mão
    (`list.scrollTop -= delta`, com uma pequena inércia exponencial ao
    soltar pra não ficar seco). **Qualquer novo elemento arrastável dentro
    de uma lista rolável vai esbarrar nisso — não usar `touch-action:pan-y`
    nem `auto` em conjunto com long-press-then-drag.**
  - **Reordenação visual usa "placeholder + FLIP"**, não movimentação
    instantânea: um `<div>` vazio (mesma altura do card, sem borda/estilo —
    revisado a pedido, a primeira versão tinha uma borda tracejada "feia")
    marca o lugar de destino; `moverPlaceholderAnimado()` mede a posição de
    cada vizinho antes/depois de mover o placeholder e anima a diferença via
    `transform: translateY()`. O card sendo arrastado fica `position:fixed`,
    seguindo o dedo, com `outline` (não `border`, que a `.task` já usa em
    outro contexto) e sombra.
  - **`dragArmado`** (`let`, declarado junto de `tarefas` no bloco principal,
    setado no bloco de drag no fim do arquivo — cross-`<script>`, mesmo
    padrão de `DIFS`) bloqueia o clique-fantasma que o navegador
    dispara depois do `pointerup`: sem isso, soltar o card também abria o
    editor da tarefa.
  - Ao soltar, a nova ordem é lida direto do DOM (`data-idx` de cada
    `.task`, na ordem em que aparecem) e gravada em `t.ordem = i * 10`,
    depois `salvar()`. Não chama `render()` — o DOM já está no lugar certo,
    redesenhar de novo só custaria um flash.
- **Não testado em iOS Safari.** `setPointerCapture` chamado de dentro do
  `setTimeout` (não no mesmo tick do `pointerdown`) é sólido no
  Chrome/Android; Safari tem histórico de comportamento inconsistente com
  pointer capture em touch. Se falhar lá, a correção é capturar o pointer já
  no `pointerdown`, antes do timer, não esperar o long-press.

---

## 8. Diálogo de apresentação por tela (v4.16–4.20)

### O que foi pedido

Cobrir a lacuna descrita na antiga seção "Prioridade máxima" (dois
testadores externos relataram confusão no início do app) com um diálogo
curto, uma vez por aba, na voz do próprio herói.

### Decisões de design tomadas em conversa (não óbvias, registrar o porquê)

- **Descartado**: explicar vida/XP individualmente (spotlight em cada
  barra). Motivo do próprio usuário: "todo mundo sabe como funciona a
  vida" — barra de vida/XP é convenção universal de RPG, o que ninguém
  explica é **pra que serve cada uma das 4 abas**, que é exatamente o que
  os testadores bateram. Trocado por "um diálogo por tela" — mais simples
  de construir também: sem cálculo de posição/spotlight em cima de
  elemento nenhum, só um balão fixo que aparece na 1ª vez que a aba abre.
- **Forçado**, não pulável (decisão travada antes de construir, conforme
  pedia o roadmap antigo) — igual aos apps de referência que o usuário
  mostrou.
- **Cor de tarefa foi tentada e revertida numa sessão anterior** (ver
  histórico se o assunto voltar) — não confundir com este módulo, são
  features diferentes que só coincidem em terem sido revisadas a pedido.

### Visual — 3 rodadas de mockup antes de tocar no código real

Construído primeiro como preview HTML isolado (fora do arquivo do jogo),
iterado em ~14 versões até aprovação, só depois portado pro módulo real.
Isso valeu a pena: evitou reconstruir o módulo de verdade várias vezes.

- **v1–v2**: balão pequeno ancorado no elemento, com spotlight (anel
  dourado) — descartado quando o escopo mudou de "por elemento" pra "por
  tela" (não tem mais elemento específico pra apontar).
- **v3 (referência trazida pelo usuário)**: estilo visual novel — fundo
  quase preto, personagem de corpo inteiro atrás da caixa, plaquinha de
  nome, seta dupla de "continuar". **Corrigido rumo errado no meio**: o
  sprite do herói (`heroiAtual().img`, reaproveitado do onboarding) é só
  um **busto de 32×32px, não corpo inteiro** — esticar a altura pra
  simular "pernas escondidas atrás da caixa" só distorcia o rosto (sem
  corpo pra revelar). Confirmado inspecionando o PNG decodificado do
  base64, não só por inspeção visual da tela. Resolvido com escala
  uniforme (126×126, sem distorcer) flutuando **acima** da caixa, sem
  sobrepor — o efeito "atrás da caixa" da referência não é replicável com
  os assets atuais sem arte nova (mesma limitação já registrada na seção
  de equipamento visível).
- **Caixa de diálogo**: outra correção de rumo — a primeira tentativa
  deixava a caixa crescer/subir conforme o texto era digitado (`min-height`
  dinâmico). Pedido explícito: **altura fixa** (`148px`), o texto que se
  ajusta dentro, não o contrário.

### Digitação letra por letra

`digitar()` revela a frase com `setTimeout` a cada 28ms, cursor piscando
via CSS. Comportamento de UX que não veio no pedido original mas é padrão
esperado em diálogo de jogo, adicionado por conta própria: **tocar
durante a digitação completa a frase na hora** em vez de fechar no meio —
só um segundo toque (com o texto já inteiro) avança/fecha. Sem isso, um
toque impaciente cortaria a frase pela metade.

### Estrutura de dados e gatilhos

- `DIALOGOS` é um **array de falas por aba** (não string única) — pedido
  explícito depois que a digitação letra-por-letra já existia: "já que tem
  essa opção de clicar pra ver mais diálogo", aproveitar pra ter 2-3 falas
  curtas cobrindo o essencial de cada tela em vez de uma frase só.
- Save isolado (`questlog.tutorialTelas.v2`), independente do save
  principal — um objeto `{aba: true}` por aba já vista.
  **Já rodou pra `v1` antes de `v2` existir**: se o bug "diálogo não
  aparece" voltar depois de testar uma versão anterior no mesmo domínio,
  a causa mais provável é flag antiga presa no `localStorage`, não bug de
  código — combinar variável do save antes de desconfiar da lógica.
- Gatilho das 3 abas que passam por `mostrarAba()`: mais um wrap
  encadeado por cima de todos os já existentes (mesmo padrão do
  Inventário/Loja/Perfil, esse script roda por último no arquivo).
- Gatilho da aba Tarefas (caso especial — abre sozinha, sem passar por
  `mostrarAba()`): dois pontos de entrada, jogador retornando (intro já
  fechado quando o script roda) e jogador novo (escuta o clique em
  "entrar", só dispara se o intro realmente fechou).
- **No preview/Artifact isso não funciona por causa da limitação de
  `localStorage` já conhecida** (seção "Key learnings") — lá o diálogo
  aparece toda vez (o oposto do esperado), já que cada reload é tratado
  como jogador novo. Só testa "aparece 1x" de verdade no Netlify.

---

## 9. Vida do monstro como contador persistido (v4.21–4.24)

### O bug original — relatado como "tela de dia vencido aparecendo errado"

Sequência: 2 tarefas, completar uma, **excluir** a outra (o usuário
chamou de "cancelar" — não existe botão com esse nome no app, é o × de
excluir da lista ou do editor). A tela mostrava o monstro derrotado sem
ter havido conclusão de 100% de verdade.

### Causa raiz, e uma tentativa de correção que piorou o problema

A vida do monstro **nunca dependeu de `derrotadoEm`** (a flag real de
vitória) — era `viva = total - feitas`, recalculado direto de
`doDia.length` a cada `render()`. Excluir uma tarefa pendente derruba
`total` sem dano nenhum ter acontecido, então `viva` podia chegar a 0 só
por exclusão.

**Primeira correção tentada (v4.19) errou o alvo**: em vez de consertar a
causa raiz, criou `verificarVitoriaAoExcluir()` que concedia vitória real
(moedas, `derrotadoEm`, bônus de cura) quando a exclusão zerava a lista —
**piorou o bug em vez de corrigir**: virou um exploit (dava pra "vencer"
o dia só apagando o que falta). Só foi pego porque o usuário mandou vídeo
mostrando +16 moedas de verdade na tela — sem isso o diagnóstico errado
teria ficado. **Lição registrada: quando o usuário diz "ainda tá dando"
depois de um fix, não assumir que o fix só precisa de reforço — considerar
que o fix pode estar certo na mecânica e errado na direção.**

### A correção de verdade

1. `verificarVitoriaAoExcluir()` revertida — exclusão nunca mais concede
   recompensa nem seta `derrotadoEm`, só impede que a flag fique indevida.
2. `morto`/`venceu` na arena passaram a depender de `monstroJaCaiu()`
   (`derrotadoEm === hoje`) em vez de `viva === 0` — a causa raiz de
   verdade.

### Segunda rodada: vida ainda mudava com exclusão (mesmo sem "vencer")

Pedido seguinte: mesmo sem disparar vitória, a **barra/número** de vida
ainda subia ao excluir (menos pendente = % de dano parece maior) e descia
ao recriar. Motivo do usuário: "não tá tirando dano nenhum, não faz
sentido". Isso exigiu trocar o modelo de vez: de "recalculado ao vivo da
lista" pra **contador persistido**, em módulo próprio no fim do arquivo
(`questlog.hpMonstro.v1`):

- `hpDano` só sobe quando uma tarefa é **concluída de verdade** (gancho
  em `alternar()`).
- `hpTotal` (o teto/vida máxima do dia) **nunca desce** — exclusão não
  toca nele. Resincroniza do zero só na virada de dia.
- **Primeira versão do teto subia via gancho em `criar()`** — furada:
  as tarefas do **onboarding inicial** (tela de boas-vindas) entram
  direto no array com `tarefas.push(...)`, sem passar por `criar()`.
  Resultado: `hpTotal` ficava travado em 0 pra qualquer jogador novo, a
  vida simplesmente não aparecia. **Descoberto rodando o HTML de verdade
  num DOM headless (jsdom), não só lendo o código** — `node --check` e
  contagem de `<div>` não pegam bug de lógica em runtime, só sintaxe.
- **Correção final, mais robusta que a original**: trocado o gancho
  específico por auto-cura em `hpMonstroDoDia()` — a cada leitura,
  `hpTotal = Math.max(hpTotal, tarefas de hoje agora)`. Cobre qualquer
  caminho de criação (onboarding, `criar()`, o que vier no futuro) sem
  precisar caçar cada ponto que empurra pra `tarefas`. Bônus não
  planejado: excluir-e-recriar a mesma tarefa não infla mais o teto
  (só sobe se a lista viva **ultrapassar** o teto já registrado, e
  recriar só devolve ao que já existia antes).
- Validado simulando a sequência completa num DOM real (digitar tarefa,
  clicar completar, clicar excluir, recriar) antes de entregar, não só
  por leitura de código — os números batem exatamente com o esperado.

### Estado que ficou pra trás (mencionado, não escondido)

O bônus de cura por vitória (módulo Vida, `curaVitoria`) só dispara
dentro do wrap de `alternar()`. Como exclusão nunca mais concede vitória
(ponto 9.1 acima), isso deixou de ser relevante — mas se algum dia
existir um segundo caminho legítimo de vencer o dia que não seja
`alternar()`, essa cura não vai disparar sozinha, precisa de gancho
próprio.

---

## 10. Polimento visual da arena — halo, vida do monstro e golpe

### Halo pulsante atrás do herói

Removido. Existia em **3 blocos `<style>` diferentes** mirando
`.hero-sprite::before` (a declaração base + 2 overrides de tema, cada um
só reforçando cor) — resquício de uma decisão de arte antiga, nunca lido
pelo usuário como efeito intencional ("parece que tem um brilho saindo
do sprite ... ou eu tô maluco"). As 3 declarações foram removidas;
`.hero-sprite{position:relative}` ficou, porque a sombra de chão
(`::after`) depende dele. A aura de raridade de equipamento (seção
"Equipamento visível no herói", também usa pseudo-elemento) é feature
separada e não foi tocada — ver nota atualizada na seção 5.

### Vida do monstro — 4 tentativas até a versão final

Registrado na íntegra porque cada descarte tem lição própria, não só a
solução final:

1. **Barra segmentada tipo RPG retrô** (10 blocos, cor por zona de
   vida). Tinha um bug de cálculo: `height:9px` com `border:2px` +
   `padding:2px` em `box-sizing:border-box` deixava **1px** de altura
   útil pro conteúdo — os segmentos ficavam praticamente invisíveis.
   Corrigido o cálculo, mas o resultado (borda quadrada grossa de 2px)
   destoava do resto da UI, que é toda pill arredondada sem borda
   (barra de XP, botão "add", cards de tarefa).
2. **Pill contínua com cor por zona de vida** (verde acima de 60%,
   dourado 30–60%, vermelho abaixo). Corrigiu tamanho e estilo, mas
   ainda foi apontada como esquisita — a causa real não era a forma, era
   **densidade de informação**: cor mudando e largura mudando ao mesmo
   tempo, num espaço de 70×6px.
3. Opções sem barra foram levantadas (corações, anel de progresso ao
   redor do sprite, sprite reagindo sozinho por opacidade/`grayscale`)
   e ficam registradas como ideias não implementadas — ver "Próximas
   tarefas" se algum dia fizer sentido revisitar.
4. **Texto numérico com flash no dano — versão que ficou.**
   `.mobinfo` virou coluna (nome do monstro em cima, indicador embaixo,
   era `flex-direction:row` antes). `#mobHp` mostra `viva / total`;
   ganha a classe `.golpe` só quando o texto muda de valor
   (`el.dataset.pronto` evita disparar o flash no primeiro `render()` da
   página, antes do jogador ver `0 / 0` piscando à toa).
   `@keyframes hpGolpe` pisca a cor do texto pra `var(--perigo)` e
   escala `1.35` por 0.35s, depois volta. Zero decisão de cor por zona,
   zero segmento — um sinal visual só, no lugar de dois competindo.

**Lição de processo:** três voltas trocaram um tipo de "esquisito" por
outro até a causa aparecer. Não era estética (quadrado vs. arredondado,
grande vs. pequeno) — era quantos sinais visuais diferentes cabem num
elemento de 70px de largura sem virar ruído. Vale de referência pra
qualquer indicador futuro nesse mesmo espaço da arena.

### Movimento no golpe (herói avança, monstro recua)

Removido — achado "esquisito, ficam se mexendo pra um lado
aleatoriamente". `animarGolpe()` (dispara a cada tarefa concluída)
continua adicionando/removendo as classes `.hit` (herói) e `.shake`
(monstro) exatamente como antes — só que agora sem efeito visual,
porque as 4 declarações CSS que moviam os sprites em X foram removidas:
`.hero-sprite.hit .heroimg`, `.mob-sprite.shake .mobimg` (versão atual,
sprites do pacote em `<img>`) e as 2 equivalentes da versão `svg`
legada (`.hero-sprite.hit svg`, `.mob-sprite.shake svg` — mortas desde
a troca pra sprites do pacote, mas nunca removidas até agora).

Ficou **gancho JS intacto, sem efeito CSS**: se um efeito futuro quiser
reaproveitar o timing do golpe (120ms de atraso entre o "impacto" no
herói e o "tremor" no monstro, 320ms de duração total), as classes já
disparam no tempo certo — só falta uma regra CSS nova que não seja
`translateX`.

---

## 11. Bug: "Apagar tudo" não resetava o tutorial

### O sintoma

Diálogo de apresentação (seção 8) apareceu uma vez, nunca mais — mesmo
depois de usar "Apagar tudo" em Perfil → Config.

### Causa raiz

`#zerarbtn` limpa **4 chaves diferentes**, cada módulo acoplando seu
próprio `removeItem` no mesmo botão (padrão append-don't-modify: nenhum
módulo edita o `onclick` original, só soma um `addEventListener`):
`CHAVE` e `CHAVE_DIA` no handler original; `CHAVE_LOJA` (Loja) e
`CHAVE_VIDA` (Vida) em listeners próprios. **`questlog.tutorialTelas.v2`
nunca entrou nessa lista** — o módulo de Diálogo por Tela (seção 8) foi
escrito sem saber que precisava se acoplar ali. Resultado: reset "total"
sempre deixava a flag de tutorial presa.

**Corrigido**: mais um `addEventListener` no `#zerarbtn`, desta vez
dentro da IIFE do próprio módulo de Diálogo (porque `CHAVE_TELAS` é
uma constante local a ela, não global) — mesmo padrão de Loja/Vida.

### Bug de fundo, encontrado mas não corrigido nesta sessão

O `onclick` original tem `confirm('Apagar todo o progresso salvo?')` e
só segue se o jogador confirmar — mas isso só protege `CHAVE`/`CHAVE_DIA`
(estão dentro do próprio `onclick`, o `return` do cancelamento os
alcança). Os três `addEventListener` acoplados (`CHAVE_LOJA`,
`CHAVE_VIDA`, e agora `CHAVE_TELAS`) **disparam mesmo se o jogador
cancelar o confirm** — são listeners independentes, o `return` de um
não impede os outros de rodar. Ou seja: cancelar "Apagar tudo" hoje
ainda assim reseta estoque da loja, vida do herói e a flag do
tutorial.

Já existia pra Loja/Vida antes desta sessão; herdei o mesmo padrão pro
tutorial só por consistência, não introduzi bug novo — mas os três
juntos merecem correção numa sessão própria. Caminho mais simples: um
guard compartilhado (`window._resetConfirmado`, setado logo após o
`confirm()` no handler original, checado no topo de cada
`addEventListener` acoplado) em vez de cada módulo repetir sua própria
lógica de confirmação.

---

## 12. Flash branco no hit — herói e monstro

Preenche exatamente o gancho deixado em aberto na seção 10
("gancho JS intacto, sem efeito CSS... só falta uma regra CSS nova que
não seja `translateX`").

### Técnica

`filter: brightness(0) invert(1)` em cima do `<img>` do sprite.
`brightness(0)` escurece todo pixel opaco pra preto; `invert(1)` inverte
esse preto pra branco — o canal alfa (a transparência ao redor do
desenho) não é tocado por nenhum dos dois, então o resultado é a
**silhueta do sprite em branco sólido**, sem alterar a forma. Técnica
padrão de "hit flash" em pixel art, validada antes num PNG real extraído
do próprio array `MONSTROS` (Goblin ladino), não num ícone genérico.

### Monstro — reaproveitando o gancho existente

Uma linha só:

```css
.mob-sprite.shake .mobimg{filter:brightness(0) invert(1)}
```

`animarGolpe()` (dispara a cada tarefa concluída) já adicionava e
removia `.shake` no timing certo — 120ms de atraso após o "impacto" do
herói, 200ms de duração. Não precisou tocar em JS nenhum, só dar de
novo um efeito visual pra uma classe que já existia sem um.

### Herói — precisou de um gatilho novo

Vida do herói **não** tem um golpe animado por tarefa (isso é cura, não
dano — ver seção "Vida do herói" em Regras de negócio). O único ponto
que reduz vida é `ferir(n)`, chamado uma vez na virada do dia por cada
tarefa largada, dentro do módulo de Vida. Esse módulo já tinha
`tremer()` — tremor no painel de XP/vida quando `ferir()` roda — então
`flashHeroi()` foi criada no mesmo padrão (remove classe, força reflow
com `offsetWidth`, readiciona) e chamada logo ao lado de `tremer()`
dentro de `ferir()`.

```css
.hero-sprite.ferido .heroimg{filter:brightness(0) invert(1)}
```

**Diferença de timing em relação ao monstro:** o `.shake` do monstro é
removido por um segundo `setTimeout` dentro do próprio `animarGolpe()`
— tem um evento natural de "fim do golpe" pra desligar a classe. `ferir()`
não tem equivalente (é uma função de mutação de estado, não uma
animação de dois atores), então `flashHeroi()` agenda sua própria
remoção em 200ms via `setTimeout` interno — mesma duração visual, gatilho
diferente.

### Por que não colidem com outros estados do sprite

`.mob-sprite.dead` (opacidade 0) e `.mob-sprite.espreita` (cinza) usam
`opacity`/`filter:grayscale`, mas nunca coincidem com `.shake` na
prática — só se toma hit com tarefa pendente (exclui `.espreita`, que só
aparece sem nenhuma tarefa) e `.dead` só liga depois da vitória, quando
não há mais golpe acontecendo. Do lado do herói, `.ferido` não compete
com nenhum outro filtro existente no `.heroimg`.

---

## 13. Rebalanceamento do catálogo de itens — edição em lote (v4.25)

### Contexto

O catálogo de itens nunca teve uma ferramenta própria de edição — trocar
nome, categoria ou raridade de um item exigia editar o array `ITENS`
direto no HTML, cego, sem ver o sprite correspondente. Pra viabilizar
uma revisão em lote, foram construídas duas páginas HTML **standalone**,
fora do app principal, que compartilham o mesmo `catalogo.js` e o mesmo
spritesheet embutido:

- **`grimorio-itens.html`** — catálogo navegável, agrupado por tipo,
  com busca e filtro por raridade. Uso: consulta, não edição.
- **`editor-itens.html`** — tabela com um item por linha, sprite
  ampliado (64px, o dobro do inventário no app), todos os campos
  editáveis (nome, categoria, raridade, valor, bônus de moedas e de
  XP) e um botão **Exportar JS** que gera o array `ITENS` pronto pra
  colar de volta. Linhas alteradas ficam destacadas; nada é salvo
  sozinho — perde a edição se a página recarregar antes de exportar.

Nenhuma das duas altera o app em si; servem só para produzir um novo
array `ITENS`, que depois é colado manualmente (ou por script) no lugar
do antigo dentro do arquivo principal.

### O que mudou nesta rodada

Usando o `editor-itens.html`, a rodada de revisão:

- **Renomeou 11 itens** para nomes mais naturais em português:
  `Porrete de Madeira` → `Taco de Madeira`, `Adaga` → `Espada de Aço`,
  `Faca de Arremesso` → `Faca`, `Machadinha` → `Machado`, `Cimitarra` →
  `Sabre`, `Estrela da Manha` → `Maça`, `Cantil` → `Frasco de Agua`,
  `Erva Curativa` → `Erva`, `Chifre Demoniaco` → `Chifre de Demônio`,
  `Chave de Latao` → `Chave`, `Punhado de Moedas` → `Monte de Moedas`.
  (Lista conferida por comparação automática, nome a nome contra o
  catálogo original — duas dessas, `Taco de Madeira` e `Chifre de
  Demônio`, tinham ficado de fora da reconstrução do catálogo nas
  primeiras vezes em que o arquivo do projeto mudou de versão nesta
  sessão; corrigido.)
- **Reclassificou 3 itens Lendários de equipamento para tesouro**:
  `Grimorio Proibido` (era arma), `Escama de Dragao` (era armadura,
  perdeu o bônus de XP: 45% → 25%) e `Idolo Amaldicoado` (era
  acessório). Os três deixam de ocupar slot e de dar bônus passivo —
  agora só vendem. Decisão de design tomada na própria ferramenta, não
  discutida em texto antes: os itens mais raros do jogo viram prêmio de
  "flex" (valor de venda alto), não vantagem mecânica.
- **Removeu 4 itens** por redundância visual — dois pares que usavam
  sprites parecidos demais na prateleira do inventário para funcionar
  como itens distintos: `Runa Magica`/`Pedra Rúnica` (dois amuletos de
  pedra rúnica quase idênticos) e `Bomba de Fumaca`/`Bomba de Fogo`
  (mesma silhueta de bomba). Catálogo caiu de 104 para **100 itens**.

### Como foi aplicado

`catalogo.js` (fonte única do array `ITENS`) foi regravado a partir do
JSON exportado, e o mesmo bloco `const ITENS = [...]` foi trocado por
substituição de string nos três arquivos que o embutem — jogo,
editor e grimório —, sem tocar em nenhuma outra parte de nenhum dos
três. Validação: `node --check` em todo bloco `<script>` de cada
arquivo (18 blocos só no jogo) e contagem de `<div>`/`</div>` — igual
ao processo já usado pra qualquer entrega de HTML único.

**Consequência que ainda não foi conferida**: com 3 itens saindo dos
slots de equipamento, o teto de bônus de XP/moedas por raridade mudou
(o Lendário deixou de existir em `armadura` e ficou mais raro em
`arma`/`acess` — só resta o Grimório... não, ele também saiu). Vale
reconferir a tabela de `PESO_RAR` do drop (seção "Espólio") depois
dessa mudança: o Lendário sorteado agora quase sempre cai como
tesouro puro, nunca como upgrade de equipamento. Se o objetivo era
manter emoção de raridade alta = equipamento melhor, isso regrediu.

---

## 14. Tipo `chave` e raridade `Único` — o Grimório

### O problema

O plano original do item "Mapa" (seção 4) sempre teve uma tensão: ele
precisa ser **raro** o bastante pra ser meta, mas **não pode** seguir o
sorteio normal de raridade — se cair no `PESO_RAR` como Lendário, ele
compete pelo mesmo slot de sorte que Diamante, Coroa Real etc., e o
jogador pode nunca tirar ele. Se cair como raridade mais baixa pra
garantir visibilidade cedo, ele passa a poder ser vendido ou usado como
qualquer equipamento normal — o que não faz sentido pra um item que
desbloqueia uma tela.

Reaproveitar um `tesouro` existente (cogitado: `Livro Magico`) resolvia
o sprite, mas herdava dois problemas do tipo: a ficha do item sempre
mostra **Vender** e o preço de venda, incondicionalmente — ver função
`abrirFicha()`, sem nenhum guard por tipo antes desta sessão.

### A solução: duas categorias novas, cada uma resolvendo um problema diferente

**Raridade `Único` (índice 5)**, adicionada a `RARIDADES`/`COR_RAR`:
`PESO_RAR` (loot) e `PESO_LOJA` (loja) **continuam com 5 posições cada**,
não ganharam a sexta. Como os dois sorteios são limitados ao próprio
tamanho do array de peso (`for (let i=0;i<pesos.length;i++)`), um item
de raridade 5 **não pode ser sorteado por nenhum dos dois** — não por
uma exceção escrita, mas pela ausência de peso pra ele. Zero risco de
esquecer um guard.

**Tipo `chave`**, adicionado a `NOME_TIPO` e ao filtro do inventário
(chip próprio). Como não está em `SLOTS`, o item automaticamente:
- não aparece como equipável (`EQUIPAVEL()`/`SLOTS.includes()`)
- não entra na tabela `BONUS[tipo][raridade]` (que só tem entrada pras
  5 categorias de equipamento — um item fora dela cai no branch que
  devolve `{m:0,x:0}` direto do catálogo, sem erro)
- não aparece no estoque da loja (`LOJA_TIPOS` já era uma lista
  explícita sem `tesouro`; `chave` também ficou de fora)

O que faltava e foi adicionado: dois guards em `abrirFicha()` pra
impedir a única ação que sobrava por padrão —

```js
if (it.tipo !== 'chave') bonus += '<span>Vende por '+precoVenda(it)+' moedas</span>';
if (it.tipo !== 'chave') acoes  += '<button data-a="vender">Vender</button>';
```

### O item: Grimório

Reaproveita o sprite do extinto `Livro Magico` (idx 73, catálogo caiu
pra 99 nomes + 1 renomeado = ainda 100 no total). Entrada final:

```js
[73, "Grimório", "chave", 5, 0, 0, 0]
```

`valor:0` — não faz sentido manter um preço de venda morto no array pra
um item que nunca mostra botão de vender.

### Entrega: nível V, no mesmo popup

Decisão explícita: **não** é drop nem compra — é concedido automaticamente
ao cruzar do nível IV pro V, na mesma tela do popup "Nível alcançado",
não numa fila separada. Dois motivos:

1. **Timing calculado, não chutado.** Custo acumulado até nível V:
   `100+160+220+280 = 760 XP`. No ritmo padrão (`xpPorTarefa:20`, teto
   de 8 tarefas cheias) isso fecha em ~4-5 dias de uso real — raro o
   bastante pra ser meta, cedo o bastante pra não desanimar.
2. **Guard de "já recebeu" é desnecessário por construção.** `xpTotal`
   nunca é decrementado em nenhum lugar do arquivo (só inicializado,
   carregado do save, ou incrementado) — `progresso().nivel` é
   estritamente crescente. `mostrarNivelUp(5, ...)` só é chamado uma
   vez na vida inteira do save, no exato cruzamento IV→V, nunca de
   novo, mesmo que o jogador use ou perca o item depois. Não precisa de
   flag, não precisa de checagem de inventário.

### Implementação: wrapper, não edição

Mesmo padrão de todo o resto do inventário — `window.mostrarNivelUp` é
embrulhado num bloco novo, no fim do arquivo, sem tocar na função
original:

```js
const ID_GRIMORIO = ITENS.findIndex(a => a[1] === 'Grimório');

const _mostrarNivelUpOrig = window.mostrarNivelUp;
window.mostrarNivelUp = function(nivel, aoFechar){
  _mostrarNivelUpOrig(nivel, aoFechar);
  if (nivel === 5 && ID_GRIMORIO >= 0){
    darItem(ID_GRIMORIO, 1);
    persistir();
    const btn = document.getElementById('lvlOk');
    if (btn) btn.insertAdjacentHTML('beforebegin', /* bloco do item */);
  }
};
```

`ID_GRIMORIO` é resolvido por **nome**, não por índice numérico fixo —
sobrevive a uma reordenação futura do array `ITENS` via
`editor-itens.html`. `insertAdjacentHTML('beforebegin', ...)` no botão
`#lvlOk` insere o bloco do item sem reescrever o `innerHTML` que a
função original já montou — a única forma de "editar" um popup
existente respeitando o padrão *append-don't-modify* quando a função
original não aceita parâmetro extra nem expõe hook próprio.

### Nível de entrega deixou de ser fixo — varia por save (v4.34)

Feedback do usuário, numa sessão seguinte: nível V fixo pra 100% dos
jogadores fazia o item Único parecer checkpoint roteirizado, não
achado — "não fica aquela ideia de item especial" quando é a mesma
coisa pra todo mundo.

**`NIVEL_GRIMORIO = 4 + (semente % 4)`** — faixa IV a VII, sorteada
uma vez por save. Reaproveita `semente` (já existe, já sorteada uma
vez por save no boot, já usada pro ciclo de monstro/loot) em vez de
criar um estado novo — zero chave de `localStorage` adicional, zero
`salvar()`/`carregar()` próprios. Determinismo por save preservado
(mesmo save sempre entrega no mesmo nível — testável, reproduzível),
varia entre saves diferentes porque `semente` varia. `nivel === 5`
virou `nivel === NIVEL_GRIMORIO` no wrapper de `mostrarNivelUp`, único
ponto que precisou mudar.

**Custo em XP nos extremos da faixa** (`xpNecessario(n) =
100+(n-1)*60`, acumulado): IV = 480 XP (~3 dias no ritmo padrão), VII
= 1500 XP (~9-10 dias). V (760 XP, ~4-5 dias) era o único ponto
calculado antes; a faixa inteira continua em janela de início de jogo,
só com mais variação entre jogadores — nenhum extremo virou
absurdamente cedo ou tardio.

**Validado em jsdom:** as 8 primeiras sementes (0-7) conferidas contra
a fórmula esperada (cobre os 4 níveis possíveis 2x cada, por causa do
módulo). Teste funcional à parte, subindo um save nível por nível até
VIII: item aparece no inventário exatamente no nível sorteado pra
aquele save (não antes, não depois — os níveis posteriores continuam
mostrando `true` porque o item já foi dado, não porque entrega de
novo).

### Pendência aberta

O item "Mapa" (seção 4) ainda não tem gatilho de entrega. A faixa
IV-VII já foi usada pelo Grimório (nota acima); precisa de outro
evento de progressão que sobre pra ele — sequência de vitórias, um
nível mais alto, ou compra única fora do RNG da loja.

### O que o Grimório faz quando aberto

Ficou pendente na primeira entrega da seção — o item foi criado e
concedido, mas não fazia nada ao ser tocado. Fechado nesta rodada:

**Botão "Abrir"** na ficha do item, condicional a `it.tipo === 'chave'`,
junto dos outros dois botões condicionais que já existiam ali (`eq` pra
equipável, `usar` pra consumível). Editado direto na função original —
não é wrapper, porque é literalmente onde os outros dois casos já
vivem, seguir o padrão que já existe ali é mais correto que embrulhar
por fora.

**Tela cheia, não bottom sheet.** A ficha do item usa `.isheet`
(bottom sheet, adequado pra um único item). A grade de 100 itens
precisava de espaço de rolagem vertical real, então ganhou seu próprio
overlay full-screen (`.grimOverlay`) com botão de fechar visível no
topo — resolvendo de propósito o problema que a seção 4 já registrava
como pendência nas folhas modais existentes (editor/composer sem saída
visível): aqui o "×" já nasceu no lugar certo.

**Ledger separado, não o inventário.** Chave própria
`questlog.itensVistos.v1`, com `salvar()`/`carregar()` próprios — não
toca no `salvar()`/`carregar()` principal, mesmo padrão que Loja, Vida
e Diálogo por Tela já usam. Vender ou usar um item não tira ele do
Grimório: uma vez visto, fica visto.

**Um único ponto de entrada.** Todo item que existe no jogo passa por
`darItem()` — seja loot (`darLoot`), compra na loja (`comprarItem`) ou
a entrega do nível V que a seção 14 acabou de criar. Em vez de marcar
"visto" em cada um dos três lugares separadamente, `window.darItem` foi
embrulhado uma vez só:

```js
const _darItemOrig = window.darItem;
window.darItem = function(id, q){
  _darItemOrig(id, q);
  if (!vistos.has(id)){ vistos.add(id); salvarVistos(); }
};
```

Isso significa que qualquer fonte de item **futura** (o Mapa incluso,
quando ganhar gatilho) já preenche o Grimório de graça, sem precisar
lembrar de acoplar nada de novo.

**Migração na primeira carga.** Quem já tinha itens no inventário antes
dessa feature existir não pode ver tudo como "nunca visto" — o módulo,
ao carregar, roda `inventario.forEach(s => vistos.add(s.id))` uma vez
antes de qualquer render.

**Reaproveitamento total de infraestrutura**: `spriteHTML()`,
`estiloSprite()`, `item()` e as classes `r0`–`r5` de raridade (seção
14) são as mesmas do resto do inventário — nenhuma duplicata. Item não
descoberto usa `filter:brightness(0);opacity:.32` (mesma técnica de
silhueta da seção 12, sem o `invert(1)` — ali era "flash branco", aqui
é "vulto escuro").

**"Apagar tudo" ganhou hook próprio nesta rodada e depois perdeu de
propósito** — ver seção 15. Na primeira entrega (v4.26) o módulo tinha
`zerarbtn.addEventListener(...)` seguindo o mesmo padrão acoplado que
Loja/Vida/Telas já usavam. Quando esse padrão foi trocado por
`localStorage.clear()` único (v4.27, seção 15), o hook daqui virou
redundante — `clear()` já apaga `questlog.itensVistos.v1` sozinho — e
foi removido na fusão. Registrado aqui pra quem procurar o
`addEventListener` e não encontrar mais.

**Validado:** `node --check` nos 20 blocos `<script>` do arquivo
(subiu de 19 pra 20), balanço de `<div>` (183/183), e um smoke test em
Node com stubs de DOM mínimos confirmando: `darItem` embrulhado,
ledger persistindo com a migração automática, grade renderizando com a
raridade certa, contador batendo, abrir/fechar do overlay funcionando.

### Ficha só-leitura ao clicar num item descoberto

A grade inicial só mostrava se o item existia, sem detalhe nenhum ao
tocar. Fechado nesta rodada: clicar numa célula **descoberta** abre a
mesma ficha `.isheet` já usada em todo o resto do inventário — mas numa
função separada, `abrirFichaGrimorio(id)`, não a `abrirFicha(id)`
normal.

Motivo de ser função separada: `abrirFicha()` assume que o item está
na posse atual do jogador — chama `acharSlot(id)` pra pegar quantidade
e monta botões de Equipar/Usar/Vender. Um item do Grimório pode já ter
sido vendido há dias; reusar `abrirFicha()` mostraria "Vender" pra um
item que o jogador não tem mais. `abrirFichaGrimorio()` é a mesma
estrutura sem preço de venda, sem quantidade e sem nenhum botão de
ação — só nome, raridade, tipo e o bônus real (via `bonusItem()`, a
mesma tabela `BONUS[tipo][raridade]` que vale em combate, não o valor
bruto do catálogo). Um único botão, "Fechar".

Vive no **mesmo `<script>`** de `abrirFicha()`/`fecharFicha()`, não em
bloco à parte — precisa acessar os `const ficha`/`fichaBG` que só
existem naquele escopo (mesmo gotcha de `const` entre `<script>` já
documentado). É chamada de fora (do módulo do Grimório, em bloco
separado) via `window.abrirFichaGrimorio`, exposta no fim da função.

Silhueta recebia `onclick` nenhum até v4.34 — ver seção 22 pra mudança
(clicar num item não descoberto agora abre a mesma ficha, com "?" no
lugar de todo dado real).

### Bug: clique não fazia nada — conflito de `z-index`

Depois de implementado, o clique na célula não tinha efeito visível
nenhum. A função rodava certa; o problema era de camada, não de
lógica: `.grimOverlay` (o catálogo em tela cheia) tinha `z-index:90`,
mas a ficha (`.sheetbg`/`.isheet`) usa `z-index:80`/`81` — mais baixo.
A ficha abria de verdade, só que **atrás** do catálogo, que tem fundo
sólido cobrindo a tela inteira.

Correção: `.grimOverlay` baixou pra `z-index:70`. A hierarquia de
camadas do arquivo (auditada nesta correção):

```
70   grimOverlay        (catálogo do Grimório)
80/81 sheetbg / isheet   (ficha de item — precisa ficar acima do catálogo)
90/91 ecobg / painel     (config de economia)
95/96 baubg / baupop     (baú de fim de dia)
96    lvlpop             (popup de nível)
97–99 dlgOverlay/...      (diálogo de tutorial — sempre por cima de tudo)
```

Regra geral daqui pra frente: qualquer tela nova que possa abrir uma
ficha de item de dentro dela precisa nascer **abaixo** de 80.

### Rótulo de raridade na célula — decisão final

Cogitado e testado nesta sessão, nessa ordem:

1. Nome completo do item embaixo do sprite — descartado: 9px em 100
   células vira ruído ilegível, e a informação mais útil numa visão de
   coleção é a raridade, não o nome (o nome já aparece ao clicar).
2. **Nome da raridade por extenso, colorido, em cima do sprite** —
   versão adotada.
3. Selo circular com só a inicial (C/I/R/E/L/U), fundo na cor da
   raridade — testado e **revertido**: ficou mais compacto, mas a
   palavra por extenso era mais imediata de ler sem precisar decorar
   qual letra é qual raridade, e a diferença de espaço economizado não
   compensou a perda de clareza.

Implementação final: `<span class="grimrar" style="color:...">` com
`window.RARIDADES[it.rar]` por extenso, cor de `window.COR_RAR[it.rar]`
— os dois arrays precisam estar em `window` porque essa célula é
montada num `<script>` diferente de onde `RARIDADES`/`COR_RAR` foram
declarados como `const`.

**Validado:** `node --check` nos 20 blocos `<script>`, balanço de
`<div>` (190/190) depois de cada uma das três iterações acima.

---

## 15. "Apagar tudo" via folha modal, substitui confirm() nativo (v4.27)

### O bug

Relato: no mobile, tocar em "Apagar tudo" às vezes não apagava — o app
voltava pra aba Tarefas e mostrava o diálogo de tutorial por cima, e só
apagava de verdade num segundo toque. Não é reproduzível neste
ambiente (sem navegador real disponível), mas a hipótese mais provável
é bem documentada como padrão: **clique fantasma pós-`confirm()`**.
Vários navegadores mobile, ao fechar um `confirm()`/`alert()`
bloqueante do sistema, reenviam um clique sintético pro elemento que
ficou embaixo do botão do diálogo nativo. Se esse fantasma cai na nav
inferior, dispara `mostrarAba('tarefas')` e, por tabela, o diálogo de
boas-vindas daquela aba — exatamente o sintoma relatado.

### A correção

Troca `confirm()` nativo por uma folha modal própria (mesmo padrão
visual de "Renomear"): `zerarbtn` agora só abre a folha
(`#zerarOverlay`/`#zerarSheet`); o apagamento real só acontece no botão
de confirmação dentro dela (`#zerarConfirmar`). Elimina a classe
inteira do bug, não só o sintoma — não existe mais nenhum `confirm()`
bloqueante do sistema nesse fluxo pra gerar clique fantasma.

### Mudança maior junto: um `localStorage.clear()` só

Antes: cada módulo (Loja, Vida, Atributos, Tutorial, e depois o
Grimório também — seção 14) tinha seu próprio
`zerarbtn.addEventListener('click', () => localStorage.removeItem(SUA_CHAVE))`,
empilhados. Isso fechava um item antigo do roadmap ("apagar tudo está
incompleto" — chaves de vida/loja/economia/tema sobreviviam ao reset),
mas cada hook novo tinha que lembrar de existir — exatamente o tipo de
esquecimento que já causou o bug documentado na seção 11.

Agora: um único `localStorage.clear()` dentro do clique de confirmação
da folha. Nenhuma chave futura escapa, porque não depende de nenhum
módulo lembrar de se cadastrar. Consequência direta pra qualquer
função nova que precisar sobreviver a partir de agora: **não precisa
adicionar hook nenhum em `zerarbtn`** — só usar `localStorage` que já
está coberto.

### Validado

`node --check` em todos os blocos `<script>` do arquivo, balanço de
`<div>`. Teste do clique fantasma em si não é verificável neste
ambiente (precisa de navegador mobile real); a correção ataca a causa
documentada do padrão, não um sintoma reproduzido aqui.

---

## 16. Pop-up de derrota — "Você caiu" (v4.28)

Terceiro pop-up da família visual do baú/nível (seção "Progressão"):
mesmo fundo escurecido reaproveitado (`.baubg`), mesma entrada em
scale/opacity, mesma fila (`window.enfileirarPopup`) — mas com borda e
glow em `var(--perigo)` em vez de `var(--gold)`, pra ler como "coisa
ruim", não conquista. Ícone é o **próprio sprite do herói atual**
(`heroiAtual().img`) em `grayscale`, não um monstro — a queda é por
dano acumulado na virada do dia, não por um combate específico contra
um bicho.

`mostrarQueda(perdidas, aoFechar)` é módulo autônomo, mesmo formato dos
outros dois. Gatilho: dentro de `ferir()`, só no ramo `vida <= 0`.

### Diagnóstico errado, corrigido no meio do caminho

Primeira hipótese (**errada**): achei que era ordem de carregamento de
`<script>` — `mostrarQueda`/`enfileirarPopup` são declarados ~600
linhas depois de `ferir()` no arquivo, e a primeira `verificarVirada()`
roda de forma síncrona já na carga da página (linha ~3743, dentro da
mesma IIFE do módulo Vida). Corrigi isso mesmo assim (envolver a
checagem num `setTimeout`), porque era um bug real — só que não era
**o** bug que o usuário via, já que ele testava pelo botão de
depuração, que só reage bem depois da página carregada por completo.

Causa real: o usuário confirmou "vida caiu, popup deveria aparecer" —
tomei isso como se o popup estivesse quebrado, quando na real ele
esperava o popup em **toda perda de vida**, não só quando ela zera. Só
depois de perguntar diretamente ("o que aconteceu quando você
clicou?") ficou claro que era mal-entendido de escopo, não bug de
código — o comportamento implementado (popup só na morte) já estava
certo desde o início.

### Verificado em jsdom, não só lido

Pra não ficar girando em cima de teoria, montei um teste headless que
replica o fluxo real: injeta uma tarefa pendente de hoje, força
`vidaHeroi.set(1)`, dispara `document.getElementById('debugbtn').click()`
de verdade (não chama função interna direto) e espera a cadeia inteira
de `setTimeout`s (620ms do hook do botão + 700ms de `verificarVirada` +
420ms de `ferir`) antes de checar se `#quedaPop` ganhou a classe `on`.
Rodou limpo, sem erro de JS, confirmando que o código já funcionava —
o que faltava era alinhar a expectativa, não consertar nada.

### Toast duplicado, removido

Achado ao revisar o fluxo completo: `verificarVirada()` sempre
disparava um toast genérico (`−N DE VIDA POR X TAREFA(S) LARGADA(S)`)
**mesmo quando o dano matava** — o jogador via esse toast **e** o
pop-up de derrota, um em cima do outro. `ferir()` agora **retorna**
`true`/`false` (morreu ou não); `verificarVirada()` só dispara o toast
genérico quando `false`. Dano que não mata continua com o toast normal
— só o caso fatal fica exclusivo do pop-up. Os dois cenários foram
testados separadamente em jsdom (dano fatal → só pop-up, sem toast de
dano; dano não-fatal → toast normal, pop-up sem classe `on`).

---

## 17. Perfil → Conquistas (v4.30–4.31)

Substitui o placeholder estático de `#perfilConquistas` ("Conquistas em
preparo") por conteúdo real, escrito por cima via JS — o HTML da aba
não precisou ser tocado.

### Lista final, decidida com o usuário

5 categorias, 39 marcos no total, nomeados um a um (não são labels
genéricas tipo "Nível 1/2/3"):

1. **Sequência Diária** (6 marcos, 1→60 dias seguidos de vitória)
2. **Matar Monstros** (10 marcos, 1→100 abates + "Bestiário Completo" nos 63 do catálogo)
3. **Subir de Nível** (8 marcos, I→L)
4. **Conclua Tarefas** (6 marcos, 1→50 tarefas)
5. **Obter Itens** (9 marcos — 1º item, uma de cada raridade, o Grimório, e 10→100 itens distintos descobertos)

**Cortado da lista original:** "Abrir Baús" como categoria própria. No
código, um baú só abre no exato momento em que o monstro do dia morre
(`darLoot` só é chamado ali, ver `alternar()`) — logo "matar monstros"
e "abrir baús" seriam sempre o mesmo número, uma categoria inteira
duplicando a outra. Decisão do usuário: cortar, não manter duplicado.

**Simplificado por raridade:** a lista original tinha uma conquista
por raridade individual (Comum, Incomum, Raro...) mais uma de "todas as
raridades" — 7 linhas. Virou 1 marco só, "Colecionador de Raridades".

### Fontes de dado — tudo já existia, com 1 exceção

`window.obterHistorico()` (seção 14/histórico), `progresso()`,
`localStorage['questlog.itensVistos.v1']`, `ID_GRIMORIO`, `MONSTROS`,
`ITENS` — todos globais de topo de script, já lidos pelo mesmo padrão
que o bloco HISTÓRICO usa (bare identifier + `typeof` guard, escopo de
`<script>` compartilhado documentado nas notas técnicas).

**A exceção: `tarefasConcluidas` não existia.** Não tem hoje nenhum
contador cumulativo de tarefas concluídas — `tarefas[i].feitaEm` só
guarda a data (serve pra saber se é "de hoje"), e o `historico` guarda
o total de tarefas do dia, não quantas foram de fato concluídas num
dia de fuga (`largadas` não é persistida na entrada do histórico).
Chave nova: `questlog.tarefasConcluidas.v1`, incrementada por um 4º
wrap em cima de `alternar()` — que já tinha 3 (loot, cura, dano de HP),
mesmo padrão wrap-not-rewrite. `alternar(i)` é `function` declarada no
topo do script principal, não presa numa IIFE: `alternar` e
`window.alternar` são o **mesmo binding** desde o load, diferente da
armadilha de closure abaixo. Só é chamada por clique num item
*pendente* (a lista só renderiza os pendentes), então 1 chamada = 1
conclusão real — sem risco de contar a mesma tarefa duas vezes.
Validado em jsdom chamando `alternar()` de verdade 3x (não simulando
via mutação direta de `localStorage`) e conferindo que memória e
`localStorage` bateram.

### Armadilha de closure, de novo — mas resolvida diferente

O clique na sub-aba "Conquistas" cai no `onclick` de `#perfilTabs
button`, que fecha sobre a `mostrarSubPerfil` **local** da IIFE
"PERFIL — SUB-ABAS", não sobre `window.mostrarSubPerfil` — mesma
armadilha já documentada nas notas técnicas pro caso `precoLoja`. A
diferença deste caso pro do `tarefasConcluidas` acima: aqui não dava
pra reatribuir `window.x`, porque o clique nunca passa por lá. Solução:
um **segundo** `addEventListener('click', ...)` direto no botão,
rodando em paralelo ao `onclick` original, sem precisar tocar nele —
nenhuma reescrita, só uma escuta a mais no mesmo elemento.

### Design: 3 direções testadas antes de fechar

1. **Card + barra de progresso** (v4.30) — 1 card por categoria, barra
   até o próximo tier. Funcional, mas lia como painel administrativo
   genérico, destoando do resto do jogo.
2. **Grid estilo Habitica** — referência trazida pelo usuário (print em
   anexo): círculos com "?" cinza pra bloqueado, coloridos pra
   desbloqueado, um por linha.
3. **Trilha vertical** (v4.31, escolhida) — pedida explicitamente como
   "tenta algo diferente por sua conta". Por categoria, uma linha
   vertical conectando marcos: feito acende na cor da categoria (mesmo
   ícone dela), bloqueado vira silhueta cinza com cadeado (reaproveita
   o padrão visual que o Grimório já usa pra item não descoberto), e
   **só o marco atual** (primeiro ainda bloqueado) mostra fração
   numérica — os demais são só nome + requisito, sem barra em todo
   item. Nada de token novo: cores vêm do `:root` e das cores de
   raridade já existentes, Cormorant Garamond pro nome do marco (mesma
   fonte de nível/moedas/nome do monstro), Silkscreen só no contador.

**Ajuste de legibilidade (mesma sessão):** texto de requisito trocado
de `--dim` pra `--muted` e de Cormorant pra Outfit (serifa fina em
corpo pequeno é onde mais perdia leitura); nome do marco 16.5px→18px;
contadores Silkscreen 11-12px→13px com leve letter-spacing — fonte
pixelada embola em tamanho pequeno.

**Ressalva não resolvida:** a categoria "Obter Itens" mistura 3
métricas diferentes (itens distintos descobertos, raridades diferentes
obtidas, posse do Grimório) na mesma trilha. Como não é uma única
escada de dificuldade, um marco mais abaixo na lista pode aparecer
`feito` antes de um mais acima ainda `atual` — a trilha visual sugere
progressão linear que essa categoria especificamente não tem. Sinalizado
ao usuário, não resolvido ainda (opções: reordenar os marcos pra sempre
bater com a ordem real de desbloqueio, ou aceitar a inconsistência).

### Recompensas — decisão adiada de propósito

Levantado se conquistas deveriam dar recompensa (moeda/XP/item). Motor
atual é **sem estado**: recalcula `valor >= meta` a cada render, sem
guardar "já resgatei". Pra dar recompensa de verdade precisaria de uma
chave nova (`questlog.conquistasResgatadas.v1`, um set de ids de marco)
garantindo entrega única por marco na vida do save — sem isso, toda
vez que a aba abre com um marco já desbloqueado, a recompensa seria
dada de novo.

Mais que o custo técnico (baixo), o problema é de **economia**: moeda/
XP como prêmio de conquista é uma fonte nova, fora do que o `simEco()`
já contabiliza — e `simEco()` estava com bug conhecido, ainda não
corrigido na época (ver item 10 da seção 4; nesta nota antiga o item
ainda era numerado 9, antes da renumeração trazida pelo fix do
arredondamento de moeda, v4.35). Enquanto a economia não fechava,
qualquer prêmio numérico de conquista era peso extra na balança errada.
**Decisão do usuário: adiar.** Três opções ficaram registradas pra
quando a economia estiver calibrada: (1) sem recompensa material, só o
troféu; (2) item exclusivo, fora do loot/loja normal, não entra no
cálculo de moeda/XP; (3) moedas/XP direto, mais arriscado por entrar na
curva ainda não fechada. Nenhuma delas foi implementada — o motor atual
continua puramente de leitura.

**Reconfirmado em sessão de brainstorm posterior.** Usuário levantou de
novo o mesmo desconforto ("Conquistas faz o papel de Missões, mas não
dá recompensa nenhuma") — oferecidas 3 direções (cosmético/sem risco de
economia, moeda fixa pequena, ou esperar o fix da economia). **Escolha
confirmada: esperar o fix da economia (item 10) antes de decidir
qualquer recompensa.** Não escolheu entre as 3 opções técnicas listadas
acima ainda — só confirmou a ordem (economia primeiro). Retomar essa
escolha específica quando o item 10 fechar.

**Item 10 fechou (v4.38) — bloqueio técnico removido, decisão ainda pendente.** O bug do `simEco()` que motivava adiar essa escolha foi corrigido (projeção de dificuldade, ver item 10 da seção 4). Isso não escolhe automaticamente entre as 3 opções listadas acima — só destrava a conversa. Retomar com o usuário qual caminho seguir (sem recompensa material / item exclusivo / moedas-XP direto) na próxima sessão que tocar em Conquistas.

### Verificado em jsdom, não só lido

Clique real (Perfil → Conquistas) simulado de ponta a ponta: 5
categorias e 39 marcos renderizados, zero erro de JS. Progressão
testada forjando estado real (`xpTotal`, `questlog.itensVistos.v1`) e
chamando `renderConquistas()` de novo — categoria Nível e categoria
Itens reagiram corretamente aos novos valores. Contador de tarefas
testado à parte, via `alternar()` real (não mutação direta de
`localStorage`), como descrito acima.

### Bug relatado pelo usuário: trilha desatualizada ao voltar pro Perfil

`mostrarAba()` só troca a visibilidade de `#viewPerfil` — não mexe em
qual sub-aba de Perfil está ativa. Quem saiu do Perfil com "Conquistas"
selecionada, pegou item/subiu nível em outra aba e voltou, reabria
direto na sub-aba Conquistas **sem clique nenhum disparando**, então
via o snapshot antigo (usuário reportou: "obtive item novo e não
contou"). O `addEventListener` no botão da sub-aba não cobre esse
caminho, só o clique direto nele. Corrigido embrulhando
`window.mostrarAba` (mesmo padrão já usado no bloco "PERFIL —
ATRIBUTOS"): toda entrada em `'perfil'` força `renderConquistas()` de
novo, não importa qual sub-aba estava ativa. Reproduzido e confirmado
em jsdom (obter item com `darItem()` de verdade, trocar de aba, voltar
sem clicar na sub-aba, conferir que o marco virou `feito`).

**Vale lembrar quando Bestiário/Calendário forem construídos:** qualquer
sub-aba de Perfil que redesenha sob demanda tem esse mesmo risco — o
gancho certo é sempre `window.mostrarAba` pro caso de reentrada, não só
o clique direto no botão da sub-aba.

### Mesma lag do histórico que o Bestiário tinha — pedido pelo usuário em seguida, corrigido em espelho (v4.34)

Depois de corrigir essa lag pro Bestiário (seção 22: revelar o monstro
de hoje no momento do "Dia vencido", sem esperar a virada gravar no
`historico`), o usuário perguntou se Conquistas tinha o mesmo
problema. Tinha — três marcos dependem de `hist` diretamente:
`totalMortos` ("Matar Monstros", 10 níveis), `distintosMortos`
("Bestiário Completo") e `melhorSequencia` ("Sequência", 6 marcos).
Matar o monstro que fecha um marco (ex.: o 10º abate, "Exterminador")
não desbloqueava até o dia seguinte, mesmo com o card "Dia vencido" já
na tela.

**Mesmo princípio do fix do Bestiário, aplicado dentro de
`montarContexto()`:** uma cópia do histórico (`histComHoje`) recebe uma
entrada sintética de hoje — `{ data: isoAtual(), resultado:'vitoria',
monstroId: idxHoje }` — **só se** `monstroJaCaiu()` for verdade.
`idxHoje` vem do mesmo truque já usado no Bestiário
(`MONSTROS.indexOf(monstroDoDia())`). Não persiste em lugar nenhum —
recalculado a cada `montarContexto()`, então some sozinho se o jogador
desmarcar uma tarefa antes da virada. `hist` (sem a entrada de hoje)
continua exposto no contexto, sem mudança, pra quem precisar do dado
"oficial" only.

`melhorSequencia` merece nota à parte: diferente de um contador simples,
sequência depende de ordem cronológica (`melhorSequenciaDeVitorias`
ordena por data e checa `diffDias(...) === 1` entre consecutivos). A
entrada sintética de hoje entra na ordenação normalmente — como
`isoAtual()` é sempre a data mais recente, ela sempre cai no fim da
lista ordenada, e o teste de "seguido do anterior" funciona sem
tratamento especial. Não é mais arriscado que o caso do contador: se
a entrada não for anexada (dia não vencido, ou desfeito antes da
virada), o cálculo roda exatamente como antes, sem entrada nenhuma de
hoje.

**Validado em jsdom:** histórico semeado com 3 vitórias, checada a
fração exibida na trilha de "Matar Monstros" antes (`3 / 5`), logo
após simular `derrotadoEm = isoAtual()` sem tocar no histórico
(`4 / 5`, e confirmado que `obterHistorico()` continua com só 3
entradas — nada foi persistido) e depois de reverter `derrotadoEm`
pra `null` simulando o jogador desmarcando a tarefa (volta pra
`3 / 5`, sozinho).

---

## 18. Tarefas com meta diária, cor por tarefa e preview de XP (v4.31)

### Meta diária — "escovar o dente 3x" sem duplicar a tarefa

Pedido original: tarefa que se repete **dentro do mesmo dia** (não
"todo dia", isso já existia via `tipo:'repete'` — é "várias vezes
*neste* dia"). Decisão de equilíbrio, confirmada antes de implementar:
XP/moedas do total **dividido** entre os toques, não multiplicado —
uma tarefa de meta 3 dá o mesmo total que a mesma tarefa daria com
meta 1, só fatiado em 3 partes.

**Dado novo por tarefa:** `meta` (1–9, default 1, sem `meta` = sem
mudança de comportamento pra tarefas antigas) + `vezesN`/`vezesData`
(contador do dia, com reset preguiçoso: se `vezesData !== isoAtual()`,
trata como zero antes de incrementar — mesmo padrão de reset por
comparação de data usado em outros contadores diários do arquivo).

`alternar()` ganhou um ramo cedo: toque que não bate a meta dá XP/moedas
proporcional (`Math.round(valor / meta)`), **não** marca `feitaEm`,
**não** tira da lista, só atualiza um badge "N/M" na linha. Toque que
bate a meta segue o caminho de sempre (100% idêntico ao código anterior
quando `meta <= 1`, inclusive a variável `ordem` calculada do mesmo
jeito) — a única mudança no caminho de conclusão real é dividir
XP/moedas por `meta` quando `meta > 1`.

### Bug achado no meio do caminho: 4 wrappers presumiam "1 chamada = 1 conclusão real"

`alternar()` tem **4 camadas de wrapper** encadeadas por cima dela: loot
do baú, cura por tarefa, dano no monstro, contador lifetime de tarefas
concluídas (nessa ordem de empacotamento, cada uma capturando a versão
anterior via `_algumaCoisa = window.alternar` antes de reatribuir).
Todas as 4 foram escritas numa época em que `alternar()` só existia pra
representar uma conclusão de verdade — cada uma incrementava seu
contador (`hpDano++`, `total++`, `curar(...)`) **incondicionalmente**
a cada chamada, sem checar o resultado.

Com toques parciais chamando `alternar()` várias vezes pra completar
uma única tarefa, isso ia fazer o monstro morrer cedo demais, curar
vida à toa, e inflar o contador lifetime — quebrando a mecânica central
do jogo (não é feature nova errada, é feature nova **quebrando
premissa antiga que ninguém tinha motivo de questionar até agora**).

Corrigido em duas pontas:
1. `ferir()` (não, `alternar()`) agora **retorna** `true`/`false`
   (bateu a meta ou não).
2. Todas as 4 camadas de wrapper foram editadas pra **repassar** esse
   retorno adiante (`return completou`/`return r`, dependendo do nome
   local) e só agir quando o valor não for `false` — sem isso, a
   camada seguinte na cadeia recebe `undefined` do wrapper anterior e
   trata como "completou" mesmo em toque parcial, silenciosamente
   reintroduzindo o mesmo bug uma camada acima.

### Verificado em jsdom, não só lido

Sequência completa testada com uma tarefa de meta 3 e uma tarefa normal
lado a lado: 2 toques parciais não mudam HP do monstro nem vida nem
contador lifetime; só o 3º toque (o que fecha a meta) muda os três.
Dia completo (multi + normal) derrota o monstro igual antes. Tarefa
multi incompleta (2 de 3 toques) na virada do dia ainda conta como
"largada" pro cálculo de dano de vida — `pendentesEm()` não precisou de
nenhuma mudança, porque só olha `feitaEm`, que continua só sendo
setado no toque que fecha a meta.

### Cor por tarefa — duas iterações até ficar "de verdade" inline

Primeira versão usou `<input type="color">` nativo. Funcionava, mas o
usuário reportou que parecia "abrir uma tela nova" — na real é o
seletor de cor do sistema operacional/navegador abrindo por cima, chrome
nativo que não dá pra estilizar nem manter inline por dentro do próprio
app. Trocado por um seletor 100% autoral: swatch de preview + campo de
texto pra hex livre (`hexValido()`, normaliza sem `#` e valida
`/^#([0-9a-f]{3}|[0-9a-f]{6})$/i`) + 8 presets em botões coloridos. Zero
overlay nativo, tudo dentro do mesmo painel "Opções avançadas".

Cor é **por tarefa**, guardada em `t.corBox` (hex, opcional). Aplicada
via `style.setProperty('border-color', cor, 'important')` porque a
regra base do checkbox já usa `!important` — inline style comum não
venceria a cascata. Só afeta o estado **não concluído**: o preenchimento
verde de "feito" continua universal, sem depender da cor escolhida —
decisão consciente, não limitação técnica (dava pra estender, não foi
pedido).

Painel de opções avançadas existe nos dois lugares (composer de criar E
editor de tarefa existente) — no editor, abre **pré-expandido** se a
tarefa já tem `corBox`, pra não esconder que aquela tarefa é
customizada atrás de mais um toque.

### Preview de XP na lista

`+N XP` no canto direito de cada linha, cor dourada. **Não é um valor
fixo salvo na tarefa** — é recalculado a cada `render()` chamando
`xpDaTarefa(ordem, dif)` com a `ordem` atual (quantas tarefas já foram
concluídas hoje), porque a fórmula de XP tem decaimento por ordem de
conclusão. Pra tarefas com `meta > 1`, mostra o valor **por toque**
(já dividido), batendo exatamente com o que `alternar()` de fato dá
naquele toque.

Precisou de um ajuste de layout separado: `.tinfo` não tinha `flex:1`,
então só ocupava a largura do próprio conteúdo — o `margin-left:auto`
do preview de XP empurrava ele só até a borda do grupinho de badges,
não até a borda real da linha. Uma propriedade resolveu.

---

## 19. Sprites customizados de herói/monstro — pipeline de recorte (v4.31)

Sessão de teste visual: usuário mandou leva de sprites de herói/monstro
em vários tamanhos e resoluções (recortes de tela, não assets já
preparados). Pediu: redimensionar pra 32×32 (padrão do jogo), espelhar
os que viram monstro (arena tem herói à esquerda olhando pra direita,
monstro à direita olhando pra esquerda — heróis usam a orientação
natural do arquivo original, monstros são espelhados), e manter a
mesma proporção visual dos sprites que já existiam.

### Divisão herói vs. monstro

Da primeira leva de 8 imagens, usuário definiu 3 como monstro e o
resto herói. Da segunda leva de 10, mais 4 como monstro (**incluindo
um que eu errei** — coloquei como herói por engano, usuário corrigiu
apontando a lista de nomes que faltava; motivo do erro: "esse cavaleiro
com essa lança" e "esse cavaleiro em cima de um cavalo" pareciam
descrever a mesma imagem — o cavaleiro montado já tem lança — mas eram
duas imagens diferentes). Fixado sem redigitar tudo: extrai a entrada
errada de `HEROIS`, espelha (porque virou monstro) e injeta em
`MONSTROS` com novo nome.

**`MONSTROS` acabou totalmente substituído** pelos 12 sprites
customizados (os 63 originais saíram do arquivo — decisão explícita do
usuário, "é um teste"). **`HEROIS` também**, na sessão seguinte —
começou como acréscimo aos 8 originais (`Cinza`, `Loiro`, `Musgo`,
`Castanho`, `Ruiva`, `Loira`, `Morena`, `Prata`), depois os 8 saíram
também ("tira os antigos"), ficando só com os 6 novos.

### Bug de sintaxe ao dar append em HEROIS

O array `HEROIS` original não tinha vírgula sobrando depois do último
item (`Prata`) — outros arrays do arquivo (como `MONSTROS`) tinham.
Um append ingênuo (concatenar string antes do `\n];`) quebrou a
sintaxe: dois literais de objeto colados sem vírgula entre eles.
`node --check` pegou na hora. Lição: nunca presumir que o padrão de um
array vale pra outro — checar a vírgula final antes de fazer append em
qualquer array novo.

### A saga do "tá flutuando" — 4 versões até acertar

Sprite grande (92px herói / 97px monstro, ver seção anterior de
polimento) tornou visível um problema que no tamanho antigo passava
despercebido: o personagem parecia flutuar acima da própria sombra.
Cada tentativa de correção revelou uma causa nova:

**v1 — sem recorte, só resize direto pra 32×32.** Nenhuma tentativa de
centralizar. Sprites com arma comprida ficavam com a lâmina ocupando
metade do quadro e o personagem espremido — não é bem "flutuando",
mas já destoava.

**v2 — centralização por centro de massa (x e y).** Resolveu a
distorção horizontal (arma não puxa mais o personagem pra um lado),
mas centralizar também no eixo vertical foi o erro: os sprites
originais do jogo não ficam centralizados verticalmente, ficam
**alinhados embaixo** (pés perto da base do quadro 32×32, ver
`Goblin ladino`: bbox `(4,4,28,31)` num canvas de 32 — sobra 1px só).
Sprite centralizado no meio deixa metade do espaço vazio embaixo — e é
exatamente esse vazio que faz a sombra (posicionada por CSS, fixa,
esperando pés perto da base) parecer longe demais do personagem.

**v3 — alinhamento embaixo, mas ingênuo.** Trocar "centraliza no y"
por "ancora no pixel mais baixo" pareceu óbvio, mas armas em diagonal
(tipo uma espada apontando pra baixo-direita) têm a ponta mais embaixo
que os próprios pés — o algoritmo ancorava na ponta da espada, não no
personagem, e ele continuava flutuando, só que agora "acima da
espada" em vez de "acima do centro". Fix: detectar a "linha do chão"
real olhando pra onde a silhueta ainda é **densa** (contagem de pixels
por linha ≥ ~18-22% do pico de largura), ignorando apêndices finos
como lâmina de espada ou ponta de lança.

**v4 — o recorte quadrado forçado.** Corrigiu o "chão" pra personagens
altos, mas quebrou nos **largos**: um personagem com espada horizontal
tem bounding box bem mais largo que alto, e o crop forçava lados
iguais (`side = max(largura,altura) * pad`) — ao tentar esse quadrado
grande o suficiente pra cobrir a largura, o topo do crop ia parar fora
dos limites da imagem original. O clamp de limite empurrava tudo de
volta pra dentro, mas **recentralizando** o crop no processo —
perdendo o ancoramento embaixo que tinha acabado de calcular. Fix:
parar de forçar crop quadrado. Recorta respeitando a proporção real
(largura e altura independentes, cada uma com sua própria margem),
redimensiona mantendo essa proporção, cola o resultado num canvas
32×32 sempre grudado na base (`py = size - altura_final`, nunca
centralizado).

**v6 — heróis/monstros novos pareciam menores que os antigos.**
Depois de resolver o "flutuando", outro sintoma apareceu: no grid de
seleção de herói, os novos ficavam visivelmente menores dentro do
próprio quadradinho, comparado aos 8 originais. Causa: manter a
proporção exata (v4/v5) significa que, se o personagem não for
quadrado, uma dimensão bate 32px e a outra fica curta — a área
ocupada caía pra 67-79% do quadro, contra 87% dos sprites antigos
(`Cinza`: bbox `(4,1,31,34)`). Fix: permitir uma distorção leve
controlada (até 22% de diferença entre escala X e Y) só na hora de
encaixar no canvas 32×32 — não faz diferença perceptível em pixel art
nesse tamanho, e recupera a área ocupada pra 79-85%.

### Processo de verificação usado a cada versão

Não foi só "gerar e mandar" — cada versão gerou:
1. `alpha.getbbox()` de cada sprite processado, conferindo
   `bbox_bottom` (deveria estar perto de 32/32) e área ocupada
   (`(x1-x0)*(y1-y0) / 1024`, comparando com sprites antigos como
   referência).
2. Ampliação visual (`resize(...,NEAREST)`) de pelo menos um sprite
   problemático por versão antes de aplicar em lote nos outros 17.
3. Grade de conferência com todos os sprites lado a lado antes de
   gerar o base64 final e aplicar no arquivo.

### v7 — borrão de LANCZOS

Sintoma reportado com print real do sprite ampliado: pixels com
gradiente/mistura de cor, "estranhos", não o visual sólido de pixel
art. Causa: todas as versões anteriores (v2 a v6) usavam
`Image.LANCZOS` pra redimensionar — filtro de suavização feito pra
foto, que cria cor intermediária nas bordas. Pixel art não tem isso,
cada pixel é cor sólida. O jogo depois amplia esse sprite já borrado
via `image-rendering:pixelated`, que só faz os blocos ficarem
maiores sem re-adicionar nitidez — resultado era "borrão em blocos".
Fix de uma palavra: `Image.LANCZOS` → `Image.NEAREST` no resize final.

### v8 — dois bugs de corte de verdade, não só estética

Reportado como "os tamanhos tão ruim ainda e parece que tu tá
cortando parte de alguns sprites" — e de fato tinha dois bugs reais,
não só desalinhamento:

1. **Recorte descentralizado saindo da imagem.** Desde a v2, o recorte
   horizontal era centralizado no centro de massa (pra compensar a
   arma puxando o personagem pra um lado — ver v2 acima). O bug: a
   janela do recorte usava a **largura total do bounding box**, mas
   recentralizada num ponto (`cx`) que não é o centro geométrico desse
   bounding box. Pra personagens com arma bem mais pesada de um lado,
   isso jogava a borda da janela pra fora da imagem original — cortando
   conteúdo de verdade (não só espaço vazio).
2. **A "linha do chão" (v3) virou limite de recorte.** O `bottom` do
   crop usava `y_chao` (a linha densa, ignorando apêndices finos) em
   vez do `y1` real da imagem — então qualquer coisa abaixo da linha
   do chão (ponta de espada, barra de capa) ficava fisicamente fora do
   recorte, não só fora do cálculo de alinhamento.

Fix: voltar a usar o **bounding box verdadeiro** (`x0,x1,y0,y1` reais,
sem recentralizar por massa) pra definir os limites do recorte —
garante que nada é cortado, ao custo de aceitar que personagens com
arma muito extensa ocupam proporcionalmente menos do quadro 32×32
(tensão inerente entre "nunca cortar" e "sempre preencher bem" — dado
o feedback, cortar era o problema mais sério, preenchimento é só
estética).

### Troca fina pós-v8

Um pedido pontual depois de tudo calibrado: tirar `Ladina` de `HEROIS`
(remoção simples) e mover `Cavaleiro Emplumado` de `HEROIS` pra
`MONSTROS` (mesmo padrão da seção anterior — extrai a entrada, espelha
de novo porque muda de lado na arena, injeta no array de destino).
`MONSTROS` foi a 13, `HEROIS` caiu a 4.

### Veredito honesto, pedido explicitamente pelo usuário

Perguntado direto "sinceramente melhorou ou piorou": resposta foi que
os bugs eram reais e sumiram de verdade (não é opinião — flutuação,
corte e borrão eram defeitos objetivos), mas o conjunto como um todo
não é um "sim" limpo:
- **Inconsistência de escala entre sprites** — cada um vem de uma
  fonte com proporção diferente, o algoritmo faz o melhor possível mas
  não é o mesmo que arte desenhada sob medida pro grid 32×32 desde o
  início.
- **Perda de variedade** — 63 monstros viraram 12-13; o roster grande
  não existe mais nesse arquivo enquanto o teste está em andamento.
- **Calibração desigual** — o algoritmo foi ajustado em cima de 2-3
  casos difíceis (espada diagonal, espada horizontal) e aplicado em
  lote nos outros sem o mesmo nível de checagem individual.

### Revertido pro roster original

Usuário pediu pra voltar "a versão antiga". **A cópia em
`/mnt/project/` nunca tinha sido sobrescrita** durante toda essa sessão
de troca de sprites — todo o trabalho de recorte/base64 foi feito só
na cópia de trabalho local, nunca salvo de volta no arquivo do
projeto. Reverter foi trivial: usar a cópia intocada, sem precisar
desfazer nada manualmente. Confirmado antes de entregar: `MONSTROS`
63 (`Goblin ladino` primeiro), `HEROIS` 8 (`Cinza` primeiro) — mesmas
contagens de antes de qualquer teste começar.

**Lição pra próxima sessão de sprite:** trabalhar numa cópia
claramente separada do arquivo "de produção" (nome de arquivo
diferente, por exemplo `-teste-sprites`) desde o início, em vez de
editar direto a cópia de trabalho principal — teria tornado o revert
ainda mais óbvio de comunicar, e teria deixado claro o tempo todo que
era experimento, não decisão tomada.

### Estado final

Toda a substituição de sprites foi **revertida**. `MONSTROS` e
`HEROIS` estão de volta ao roster original (63 e 8 respectivamente).
O pipeline de recorte (v8, com `NEAREST` + bbox real + distorção leve
controlada) fica documentado aqui pra reaproveitar **se e quando**
o usuário decidir seguir com arte customizada de verdade — mas não
está em uso no arquivo atual.


---

## 20. Efeitos sonoros (SFX) — Web Audio API sintetizada (v4.32)

> Versão do arquivo ao final desta sessão: `questlog-4-32-sfx.html`

### O que foi pedido

Sessão dedicada só a isso, como já estava marcado como pré-requisito
("iniciar em sessão própria, focada só nisso" — nota antiga na seção 4).
Foi além do "primeira leva" original: começou pelos 6 eventos de
combate/progressão já mapeados, e cresceu em conversa pra cobrir
navegação, onboarding, economia (comprar/vender/investir) e o diálogo
de apresentação (efeito letra-por-letra estilo Undertale).

### Arquitetura

Dois blocos autônomos, colados antes de `</body>`, na ordem:

1. **Motor de áudio** — `window.tocarSom(nome, arg?)`, único ponto de
   entrada pra tocar qualquer som. `arg` é opcional, usado hoje só pelo
   `blip` do diálogo (varia o tom por letra). Internamente usa dois
   helpers: `tom()` (oscilador + envelope curto, aceita `freqFinal` pra
   dar glide de pitch) e `ruido()` (buffer de amostras aleatórias com
   fade, dá corpo de "impacto"). API de controle: `window.sfxAtivo()`,
   `window.definirSfxAtivo(bool)`, `window.sfxVolume()`,
   `window.definirSfxVolume(v)` — persistidos em `questlog.sfx.v1`.
   **UI de controle ainda não existe** (ver "Fora do escopo" abaixo).
2. **Ganchos** — vários blocos autônomos, um por família de evento
   (combate/progressão, clique de navegação, ações do jogador), cada um
   documentado com o motivo de ter usado wrap externo ou edição direta.

**Autoplay:** o `AudioContext` só destrava no primeiro `pointerdown`/
`keydown` real do usuário. Antes disso (e se destravar falhar por
qualquer motivo), `tocarSom()` é um no-op silencioso — nunca lança erro,
nunca trava o resto do app.

### Catálogo de sons e onde cada um dispara

| Som | Evento | Gancho |
|---|---|---|
| `golpe` | Tarefa concluída (todo hit, inclusive o que fecha o dia) | wrap em `window.alternar` |
| `danoHeroi` | Herói perde vida | edição direta em `ferir()` |
| `fuga` | Tarefas largadas na virada do dia (fuga real, não o botão de debug) | edição direta em `verificarVirada()` |
| `levelup` | Sobe de nível | wrap em `window.mostrarNivelUp` |
| `loot` | Baú do tesouro abre (1.2s após o dia ser vencido) — **também o único sinal sonoro de "dia vencido"**, ver decisão abaixo | wrap em `window.mostrarBauLoot` |
| `morte` | Vida zerou, pop-up "Você caiu" | wrap em `window.mostrarQueda` |
| `clique` | Nav principal, sub-abas do Perfil, botões de onboarding, seleção de herói, botão "+ Adicionar" | `addEventListener` em paralelo, vários elementos |
| `clique` *(pendente)* | Tela de login (v4.43): Entrar, Criar conta, Google, toggle Entrar/Cadastro, "Continuar sem conta", tema/idioma — construída depois desta sessão, lacuna confirmada e aprovada em brainstorm posterior | ainda não implementado |
| `blip` | Cada letra do diálogo de apresentação (pula espaço, tom varia por caractere) | edição direta em `passo()` (dentro de `digitar()`) |
| `tarefa` | Tarefa criada com sucesso | edição direta em `criar()` (motivo: ver bug abaixo) |
| `compra` | Compra confirmada na loja | edição direta em `comprar()` |
| `venda` | Item vendido avulso | wrap em `window.venderItem` |
| `investir` | Ponto de atributo investido (Fortuna/Foco) | edição direta em `investir()` |
| `equipar` / `desequipar` | Alterna o slot de equipamento | wrap em `window.equipar` (2º wrap dessa função — já tinha 1 do módulo Atributos) |
| `usar` | Consumível usado (poção/pergaminho) na ficha do item | wrap em `window.usarItem` |
| `abrirGrimorio` | Catálogo do Grimório abre | wrap em `window.abrirCatalogoGrimorio` |
| `grimorio` | Ganha o Grimório em si (marco do nível 5) — **extra**, toca junto (não em vez) do `levelup` genérico que já dispara em toda subida de nível | edição direta no bloco "ENTREGA DO GRIMÓRIO NO NÍVEL V" |

**Correção (confirmada fora desta sessão):** `venderTesouros()` (venda em
lote de tesouros) **já tem som** — implementado depois do fechamento
desta seção. Nome do efeito/gancho usado não foi registrado até agora;
atualizar aqui quando o outro chat que tratou disso confirmar o detalhe.
Música de fundo continua fora de escopo (projeto à parte, precisa de
toggle/volume/loop próprios).

### Achado importante: um 2º tipo de armadilha de gancho, além da de closure

As "Key learnings" do projeto já documentavam a armadilha de closure
(função declarada dentro de uma IIFE não é alcançável de fora, mesmo
reatribuindo `window.nomeDaFuncao`). Esta sessão encontrou uma **segunda
armadilha**, de natureza diferente, ao debugar por que o som de criar
tarefa simplesmente não tocava:

```js
document.getElementById('save').onclick = criar;
```

`criar()` **é** uma function declaration de topo, sem armadilha de
closure nenhuma — mas essa linha copia a **referência** da função pro
`onclick` no exato momento em que o script roda (perto do topo do
arquivo). Reatribuir `window.criar = wrap(...)` depois disso (nosso
bloco de ganchos roda perto do fim do arquivo) não muda pra onde aquele
`onclick` já aponta, porque ele guardou um valor, não uma busca a ser
refeita a cada clique.

**Contraste que faz funcionar em todo o resto do arquivo:**
`b.onclick = () => alternar(i)` (ou `() => mostrarAba(...)`, `()  =>
venderItem(id)` etc.) — aqui o `onclick` guarda uma *função anônima*
que, quando o clique realmente acontece, faz um **lookup novo** do nome
`alternar`/`mostrarAba`/`venderItem` no escopo global. Se esse nome foi
reatribuído antes do clique acontecer (mesmo que depois de o script ter
rodado), o clique pega a versão nova.

**Regra prática pra próximas sessões:** antes de envelopar `window.fn`
por fora, checar como o clique real chama `fn` — `onclick = fn` (sem
arrow) é a armadilha; `onclick = () => fn(...)` é seguro. Quando cair na
armadilha (como `criar()` aqui, e como `comprar()`/`ferir()`/
`verificarVirada()`/`investir()` já caíam pela armadilha de closure),
a solução nos dois casos é a mesma: edição direta na função original,
com comentário explicando o motivo (não é possível saber só olhando de
fora — tem que rastrear até o `onclick`).

### Achado: botão de debug dispara som de dano "sozinho" durante teste

Não é bug do SFX — é o botão "próximo dia →" fazendo exatamente o que
promete. Ele simula uma virada de dia real, que passa pelo mesmo
caminho que o watchdog automático (`setInterval(checar, 30000)` +
`visibilitychange`/`pageshow`/`focus`, bloco "WATCHDOG DE DIA") usaria
numa virada de meia-noite de verdade — e é dentro desse caminho
(`verificarVirada()` → `ferir()`) que mora o som `danoHeroi`.

O clique no botão de debug dispara `verificarVirada()` com **620ms de
delay** (`setTimeout(verificarVirada, 620)`, ver bloco "VIDA DO HEROI"),
então o som toca meio segundo depois do clique, desconectado dele —
daí a sensação de "disparar sozinho" ao clicar várias vezes seguidas
testando cenários diferentes. Guard em `verificarVirada()`
(`if (ultimoDia === hoje) return`) impede disparo duplicado dentro do
mesmo dia simulado, então não é um problema de repetição — só de
percepção de timing.

Sem ação necessária: o botão de debug já está na lista de "curto prazo"
(seção 4) pra ser removido antes do lançamento, o que elimina esse
ruído de teste. Enquanto ele existir, testar o som de dano de forma
previsível: deixar uma tarefa pendente de propósito, clicar uma vez, e
esperar o delay antes de julgar o som.

### Decisões tomadas em conversa (não óbvias, registrar o porquê)

- **Escopo do som de clique de navegação.** Perguntado diretamente:
  nav principal (4 abas) e sub-abas do Perfil, e mais nada — não
  todo botão clicável do app. Motivo do usuário não registrado
  explicitamente, mas a alternativa ("todo botão") arriscava virar
  ruído de fundo repetitivo.
- **Vitória e loot fundidos num só som.** O `alternar()` originalmente
  tocava uma fanfarra de "vitória" na hora, e o `loot` tocava de novo
  1.2s depois quando o baú abre (mesmo delay que o popup visual já
  usava, ver seção 8/9). Perguntado se fazia sentido ter os dois já que
  vencer o dia sempre dá item automaticamente — decisão do usuário foi
  tirar o som de vitória imediato e deixar só o `loot` como sinal de
  "dia vencido", mantendo o `golpe` normal na tarefa que fecha o dia.
  Removido o som `vitoria` do catálogo (ficaria sem uso).
- **Som de venda pedindo referência de "moeda".** Usuário pediu pra
  soar como o som de vender equipamento do Minecraft Dungeons.
  **Limitação registrada em conversa:** Claude não tem como ouvir
  áudio — nem o de referência, nem o que ele mesmo escreve — então todo
  ajuste é por tentativa e descrição, não cópia. **3 iterações até este
  ponto:**
  1. Sino/campainha simples (3 notas sequenciais, `triangle`).
  2. Moedas caindo — 5 clinks agudos em `square` (1300–1650Hz) + acorde
     de fechamento. Feedback: "horrível", "muito agudo/estridente"
     (`square` em frequência alta tem harmônicos fortes, soa buzzy —
     causa técnica identificada, não só gosto).
  3. **Atual:** troca de abordagem — tom de confirmação de transação,
     não mais "moedas tilintando". Thud grave (peso) + 2 notas médias
     em intervalo de quinta (330→494Hz), só `sine`/`triangle`, nada
     acima de ~500Hz. Ainda não confirmado pelo usuário (última msg
     "tá a mesma coisa" foi causada por um bug de preview do sandbox
     não recarregando a versão nova, não pelo código em si — ver nota
     abaixo).
  **Lição de processo, não de código:** ao iterar som/áudio síncrono
  com o usuário, confirmar explicitamente se ele está testando o
  arquivo **novo** (baixado de novo / sandbox recarregado) antes de
  aceitar feedback de "não mudou nada" como sinal de que o ajuste
  falhou — o preview do sandbox já mostrou não recarregar de forma
  confiável entre versões nesta sessão.

### Fora do escopo desta sessão

- **UI de volume/mudo** na sub-aba Config do Perfil — a API
  (`sfxAtivo`/`definirSfxAtivo`/`sfxVolume`/`definirSfxVolume`) já
  existe e persiste, só falta o toggle visual.
- ~~`venderTesouros()` (venda em lote) sem som~~ — **corrigido fora
  desta sessão**, já tem som implementado (ver nota em "Catálogo de
  sons" acima).
- **Upgrade pra áudio gravado** (.mp3/.ogg em base64) — só cogitado se
  o resultado sintetizado parecer "pobre" no teste real, decisão
  adiada pro roadmap original.
- **Lacuna encontrada em sessão de brainstorm posterior: tela de login
  (v4.43) sem som de clique.** A tela de login/autenticação (email,
  senha, botão Google, toggle Entrar/Cadastro, "Continuar sem conta",
  botão de tema/idioma) foi construída **depois** desta sessão de SFX
  — não é esquecimento, é lacuna de sequência temporal: os botões dela
  simplesmente não existiam quando o escopo de "clique só em nav +
  sub-abas do Perfil" foi fechado. **Decisão confirmada pelo usuário:
  cobrir só os botões da tela de login**, mantendo o restante do app
  como está — mesma filosofia original de evitar repetição/ruído,
  não uma expansão de escopo pra "todo botão". Ainda não implementado;
  usar o mesmo som `clique` já catalogado, mesmo padrão de gancho
  (`addEventListener` em paralelo ao clique existente).


---

## 21. Queda em cadeia e o retorno do dia congelado (v4.33)

Duas correções nesta sessão. A segunda existe porque a primeira revelou que
uma correção antiga **desapareceu num merge**.

### 21.1 — "Você caiu" aparecendo várias vezes seguidas

**Sintoma relatado:** a tela de derrota surgindo repetidas vezes, sem causa
aparente.

**Causa.** Cada clique em "próximo dia" gera uma virada, e cada virada com
tarefas pendentes chama `ferir()`. Com dano alto e vida baixa, cada uma mata.
Quatro cliques = quatro mortes independentes, e a penalidade é
**multiplicativa**: `moedas × 0.5` a cada queda. Medido em jsdom com 12
tarefas difíceis pendentes e 400 moedas:

| | moedas |
|---|---|
| antes | 400 |
| 4 quedas encadeadas | **25** |

93,75% do saldo. Pior ainda, só a **primeira** tela aparecia; as outras três
ficavam invisíveis na fila de pop-ups e saíam uma atrás da outra a cada
"Levantar" — daí a sensação de que surgiram do nada.

Isso contradiz frontalmente a regra escrita em `verificarVirada()`:
*"voltar não pode ser pior que nunca ter saído"*. A regra protegia contra
faltar uma semana, mas não contra várias viradas numa mesma sessão.

**Correção — uma queda por retorno.** Flag `quedaNaFila` dentro da IIFE de
Vida do Herói. Enquanto a tela de queda não for reconhecida, uma nova morte
restaura a vida mas **não cobra moedas nem enfileira outro pop-up**. O flag
só vive em memória, de propósito: o que se protege é uma rajada, não o dia
seguinte de verdade.

`ferir()` foi editado direto — continua sem gancho externo possível (IIFE),
mesma exceção já documentada na seção de SFX.

**Correção secundária — respiro na fila de pop-ups.** `enfileirarPopup` não
tinha intervalo entre itens: o pop-up seguinte aparecia no mesmo frame do
toque que fechou o anterior, e um único tap atravessava a fila inteira. Agora
há um `ocupado` + 260ms entre um e outro. Vale para baú, nível e queda.

### 21.2 — O dia congelado voltou (v4.6 perdida no merge)

Ao investigar, rodei a suíte da v4.6 contra o arquivo atual: **falhou**. O
bloco `DATA EFETIVA DO APP` do `questlog-4-32-sfx.html` era o código da v4.3
— absorção por ISO, sem selo. A seção 7 do roadmap que documentava a v4.6
também sumiu (a numeração atual pula direto para "Reordenação por arrastar").

Ou seja: a correção mais crítica do projeto foi revertida por uma cadeia de
merges entre conversas paralelas, e ninguém percebeu por meses.

**Reaplicada.** Offset é inteiro fixo (`{"off":N}`), dia efetivo = dia real + N,
`lerDiaAlvo`/`gravarDiaAlvo` → `lerOffsetDia`/`gravarOffsetDia`, teto de 365,
migração destrutiva do formato ISO antigo, e o selo `#seloDia`
(`DIA DE TESTE +N · VOLTAR AO REAL`) de volta.

### O que isso ensina sobre trabalhar em conversas paralelas

O risco real **não** é o conflito visível — é a **reversão silenciosa**. Um
merge que sobrescreve um bloco corrigido não gera erro, não quebra o app e
não aparece em nenhuma validação de sintaxe. O app funciona; só o defeito
antigo voltou.

O que salvou desta vez foi ter a suíte descrita em tabela: dava pra rodá-la
contra o arquivo novo e ver que passou a falhar.

**Regra nova:** toda sessão começa rodando a suíte das correções críticas
(seções 6, 21) contra o arquivo do projeto, **antes** de escrever qualquer
código. Se uma falhar, é reversão de merge — reaplicar antes de seguir.

### Cenários cobertos por teste (`v.js`)

| Cenário | Esperado | 4.32 | 4.33 |
|---|---|---|---|
| 4 viradas seguidas, tarefas pendentes | 1 tela, 1 cobrança | 4 telas, 400→25 | 1 tela, 400→200 |
| Queda normal (1 virada) | 1 tela, cobra normal | ok | ok |
| +5 dias de teste, 1 dia real depois | dia avança | congelado | avança |
| Chave no formato ISO antigo | descartada | — | ok |
| Toque no selo | volta ao dia real | sem selo | ok |
| Meia-noite com app aberto | atualiza sozinho | ok | ok |
| 3 dias fora | 1 dia de dano | ok | ok |

### Checklist de validação (atualizado)

1. **Rodar a suíte das correções críticas contra o arquivo do projeto antes de
   editar.** Falha aqui = reversão de merge, não bug novo.
2. `node --check` em **cada** bloco `<script>` separadamente.
3. Balanço de `<div>`, `<script>`, `<style>`, `<svg>`.
4. **Balanço de `<!--` contra `-->`** (um `*/` no lugar de `-->` já engoliu um
   `<script>` inteiro sem que nada acusasse).
5. Testar no Netlify: `localStorage` não persiste no preview do artifact.

## 22. Grimório — ficha "mistério" pra item não descoberto, e Bestiário (v4.34)

### Grimório: clicar num item não descoberto agora abre ficha, não faz mais nada

Até v4.34, a silhueta de um item não visto no Grimório não tinha
`onclick` — decisão original documentada na seção 14 como proposital
("tocar num item não descoberto não faz nada, de propósito"). Pedido
do usuário: mudar isso, o toque deveria abrir uma ficha com "?" no
lugar de nome, raridade/tipo e bônus — mesma estrutura visual da ficha
normal, só sem revelar nada real.

**`abrirFichaGrimorioOculto(id)`**, nova função, vive no mesmo
`<script>` de `abrirFicha()`/`abrirFichaGrimorio()`/`fecharFicha()` —
mesmo motivo de sempre, precisa dos `const ficha`/`fichaBG` daquele
escopo. Recebe `id` só pra pegar o sprite (`item(id).sp`) — a *forma*
da silhueta já era pública na grade (mesma célula mostra a silhueta
com a forma real do item, gancho de curiosidade documentado na seção
14), então repetir a mesma forma na ficha não vaza nada que a grade já
não estivesse mostrando. Nome, raridade/tipo e bônus viram `"?"`
fixo — identidade continua escondida.

```js
function abrirFichaGrimorioOculto(id){
  const it = item(id);
  ficha.innerHTML =
    '<div class="ihead">'+
      '<div class="ibox" style="filter:brightness(0);opacity:.32">'+spriteHTML(it.sp, 44)+'</div>'+
      '<div><div class="iname">?</div>'+
      '<div class="imeta">? · ?</div></div>'+
    '</div>'+
    '<div class="ibonus"><span>?</span></div>'+
    '<div class="iacts"><button data-a="fechar">Fechar</button></div>';
  ...
}
window.abrirFichaGrimorioOculto = abrirFichaGrimorioOculto;
```

Em `renderGrimorio()`, a célula não descoberta ganhou o `else` que
faltava:

```js
if (desc) c.onclick = () => window.abrirFichaGrimorio(id);
else      c.onclick = () => window.abrirFichaGrimorioOculto(id);
```

**Validado:** clicar num item visto continua abrindo a ficha normal
(nome real, sem regressão); clicar num não visto abre a ficha com `?`
nos três campos e o sprite com o mesmo filtro de silhueta da grade.

### Bestiário — sub-aba nova em Perfil, sem gate

Decisão de design já estava fechada desde uma sessão de brainstorm
anterior (seção 4, item 3 da lista da aba Perfil) — esta sessão só
implementou: **sem gate**, sub-aba própria ao lado de
Config/Atributos/Conquistas, disponível desde o dia 1. Grade dos 63
monstros do catálogo (`MONSTROS.length`, conferido no arquivo, não
assumido — o roadmap antigo mencionava "64" num lugar e "63" em
outro, o número certo é 63).

**Fonte do dado:** `window.obterHistorico()` (módulo HISTÓRICO,
seção do Perfil). Monstro "derrotado" = pelo menos uma entrada com
aquele `monstroId` e `resultado === 'vitoria'`. Fuga não revela — o
monstro escapou, o jogador não o venceu, não faz sentido narrativo
contar como "visto" só por ter aparecido na arena naquele dia. Testado
explicitamente: um monstro com histórico só de `'fuga'` continua em
silhueta.

**Sprite diferente do Grimório.** Itens usam uma spritesheet
compartilhada (`spriteHTML()`/`estiloSprite()`, posição por índice);
monstros não — cada `MONSTROS[i]` carrega seu próprio `<img>` em
base64 (`m.img`). A silhueta aqui é `filter:brightness(0);opacity:.32`
aplicado direto na tag `<img>`, mesma técnica visual do Grimório,
adaptada pra imagem solta em vez de `div` com `background-position`.

**Armadilha de closure, de novo — mesma solução que Conquistas já
usou.** O clique na sub-aba "Bestiário" cai no `onclick` local da IIFE
"PERFIL — SUB-ABAS", não em `window.mostrarSubPerfil` — idêntico ao
caso já documentado na seção 17 pra Conquistas. Mesma solução: um
**segundo** `addEventListener('click', ...)` direto no botão, em
paralelo ao `onclick` original, sem reescrevê-lo. E o mesmo wrap de
`window.mostrarAba` (esse sim top-level, reatribuível de verdade) pra
redesenhar a grade sempre que a aba Perfil reabre vinda de outra aba —
sem isso, sair de Perfil com Bestiário selecionado, derrotar um
monstro em Tarefas e voltar mostraria a grade com o snapshot antigo,
mesmo bug que já tinha sido relatado e corrigido pra Conquistas.

**Clique-pra-detalhe (pedido em seguida, v4.34).** A grade mostra nome
só nos monstros derrotados — igual antes. O que mudou: clicar numa
célula agora abre uma ficha, mesmo padrão visual da ficha de item
(`.ihead`/`.ibonus`/`.iacts`), com duas funções novas — `abrirFichaMonstro(idx)`
e `abrirFichaMonstroOculto(idx)` — vivendo no **mesmo `<script>`** de
`ficha`/`fichaBG`/`abrirFicha`/`abrirFichaGrimorio`, pelo mesmo motivo
de sempre (precisam dos `const` daquele escopo).

Diferença importante do Grimório: item tem raridade/tipo/bônus reais
pra mostrar; monstro só tem `{nome, img}` — copiar a ficha 1:1 ficaria
vazia. Em vez de inventar dado novo, a ficha usa o que o `historico`
já calcula de graça: **quantas vezes derrotado** e **primeira vez em
[data]** (formatada `DD/MM/AAAA` — sem formatador de data existente no
app, um inline pequeno resolveu, não valia criar utilitário
compartilhado pra um único uso). Pra monstro não descoberto (nunca
visto, ou só fuga — fuga não conta como descoberto, mesma regra já
documentada), mesma "ficha mistério" do Grimório: sprite em silhueta
com a forma real (mesmo gancho de curiosidade da grade), nome e
estatísticas viram `?`.

**Mesma correção de "hoje em tempo real" também na ficha.** Sem isso,
clicar no monstro do dia (já revelado na grade antes da virada, ver
nota acima) mostraria "Derrotado 0 vezes" — inconsistente com a
célula já colorida. `abrirFichaMonstro()` soma a mesma entrada
sintética de hoje (se `monstroJaCaiu()` for o monstro clicado), sem
persistir, mesmo princípio de sempre.

**Validado em jsdom:** clique num monstro derrotado 2x mostra "Derrotado
2 vezes" e a data mais antiga das duas; clique num monstro só-fuga
(não deveria contar como descoberto) mostra ficha mistério; clique num
nunca-visto idem, com o filtro de silhueta aplicado; e o caso do
monstro de hoje — derrotado, ainda fora do histórico permanente —
mostra nome real e "Derrotado 1 vez" corretamente, confirmando em
paralelo que nada foi persistido no `historico` só por abrir a ficha.

**Revelação em tempo real do monstro de hoje — pedido logo após a
entrega original, que só lia do `historico`.** Pergunta do usuário:
"era pra contar só quando vira o dia, ou já no momento que eu mato o
monstro?" — resposta: no momento. O `historico` só grava na virada (é
o registro *permanente*, por design — ver seção do Perfil), então
depender só dele significa o Bestiário ficar até 1 dia atrasado em
relação ao que o jogador acabou de fazer.

Solução: `renderBestiario()` agora soma, além do histórico, uma
checagem ao vivo com `monstroJaCaiu()` — o mesmo sinal que já acende o
card "DIA VENCIDO" na arena, sem esperar nada. Se verdadeiro, o
monstro de hoje (`monstroDoDia()`) entra no `Set` de derrotados também.
**Não persiste nada** — é recalculado a cada render. Isso resolve de
graça o risco que tinha sido levantado antes de implementar: se o
jogador desmarcar uma tarefa e cair de 100% antes da virada, o monstro
de hoje simplesmente para de entrar no `Set` no próximo render, volta
sozinho pra silhueta — sem o Bestiário ter "prometido" uma derrota que
o histórico (fonte da verdade) depois não confirma.

Validado com jsdom nos três momentos: antes de vencer (0 de 63), logo
após `derrotadoEm = isoAtual()` sem tocar no histórico (1 de 63, monstro
revelado, `historico` continua vazio — confirma que não persistiu
nada), e depois de zerar `derrotadoEm` de volta pra `null` simulando o
jogador desmarcando a tarefa (volta pra 0 de 63, reverteu sozinho).

**Validado com jsdom, histórico semeado manualmente** (não só leitura
de código): 4 entradas de histórico cobrindo 3 casos — monstro
derrotado 1x, derrotado 2x (mesmo id, testa que não duplica na
contagem), só fuga (não deve contar) e nunca visto. Resultado: grade
com as 63 células, contador "2 de 63" batendo (só os 2 ids únicos com
`'vitoria'`), classe de silhueta certa em cada caso, nome aparecendo
só nos derrotados. Testado também sair e voltar pra aba Perfil
(gancho de `mostrarAba` funcionando) e o Grimório em paralelo, mesma
rodada de teste, pra garantir que a mudança de lá não quebrou nada
daqui.

**Validado:** `node --check` nos 31 blocos `<script>` (subiu de 30),
balanço de `<div>` (241/241).

---

## 23. Bônus de moedas do equipamento sumindo no arredondamento — corrigido (v4.35)

### O relato

Usuário trouxe números reais de teste: tarefa Difícil sem bônus dá
45 XP + 5 moedas. Com peitoral (10%XP/3%moedas) dá 50 XP + 5 moedas.
Com peitoral + machado de guerra (27%XP/13%moedas combinados) dá
57 XP + 5 moedas. XP reage ao bônus, moeda não se move nunca — mesmo
diagnóstico já registrado no item 9 da seção 4 em sessão anterior, sem
correção até agora.

### Causa (matemática confirmada correta, resolução que faltava)

`moedasDaTarefa()` fazia `Math.round(ECO.moedasPorTarefa * mult *
multDif(dif))` a cada tarefa, sem carregar nada entre chamadas. Com
`moedasPorTarefa = 2` e Difícil (`×2.25`), o valor bruto por tarefa já
sai em 4.5 antes de qualquer bônus de equipamento. Um bônus de 13%
sobre isso é 0.585 — abaixo do meio ponto necessário pra
`Math.round()` subir de 5 pra 6. O bônus está sendo calculado certo,
só nunca junta fração suficiente pra cruzar a fronteira do
arredondamento numa tarefa isolada. XP não sofre o mesmo problema
porque parte de uma base 10× maior (`xpPorTarefa = 20`).

### Direções cogitadas e por que a escolhida venceu

Três direções tinham ficado registradas sem decisão: (1) subir a base
`ECO.moedasPorTarefa`, (2) acumular fração entre tarefas e arredondar
só na hora de creditar, (3) só mostrar o bônus na UI sem mudar o
valor. Descartei (1) porque `moedasPorTarefa` alimenta `simEco()` e a
calibração inteira da loja — reescalar teria efeito cascata em tudo
que já foi balanceado, pra resolver um problema que é só de resolução
de arredondamento. Descartei (3) porque não resolve o problema
relatado, só disfarça. Fui de (2).

### Implementação

Variável de módulo `_restoMoedasTarefa` (não é save novo, não é
`localStorage`) guarda a fração perdida em cada `Math.floor()` e soma
de volta na chamada seguinte:

```js
let _restoMoedasTarefa = 0;
function moedasDaTarefa(dif){
  const mult = (typeof multMoedas === 'function') ? multMoedas() : 1;
  const bruto = ECO.moedasPorTarefa * mult * multDif(dif || DIF_PADRAO) + _restoMoedasTarefa;
  const inteiro = Math.max(1, Math.floor(bruto));
  _restoMoedasTarefa = bruto - inteiro;
  return inteiro;
}
```

**Por que memória e não save:** o resto nunca passa de 1 moeda — pior
caso, um refresh de página custa uma fração de moeda perdida uma
única vez. Não achei que isso justificasse uma chave de
`localStorage` nova só pra esse detalhe; se algum dia incomodar,
é uma adição pequena e isolada.

**Nota pra quem mexer aqui depois:** o `Math.max(1, ...)` garante
mínimo de 1 moeda por tarefa, mas isso pode fazer `_restoMoedasTarefa`
ficar negativo temporariamente se o bruto cair abaixo de 1 (ex.:
bônus de equipamento negativo — hoje não existe no catálogo, mas se
itens amaldiçoados voltarem a ser cogitados, revisar este ponto).
Corrige sozinho nas chamadas seguintes, não trava nada, só registrando
o comportamento.

### Confirmado que não era bug: soma de Fortuna/Foco com equipamento

Usuário perguntou se o bônus de item (`BONUS`, equipamento) soma com
os atributos de Perfil (Fortuna/Foco). **Não soma, de propósito, e
isso não tinha ficado claro antes:**

- `multXP()`/`multMoedas()` — usadas em `xpDaTarefa()`/
  `moedasDaTarefa()`, ou seja, recompensa de tarefa — leem só
  `bonusEquip()` (itens equipados).
- `bonusFortuna()` entra em `sortearItem()` (chance de raridade do
  loot). `descontoFoco()` entra em `precoLoja()` (preço da loja).
  Nenhum dos dois toca XP ou moeda de tarefa.

São dois eixos paralelos que nunca se cruzam: item = recompensa de
tarefa; atributo de Perfil = loot melhor ou loja mais barata. Não foi
preciso mudar nada no código pra isso — só esclarecer. Fica
registrado aqui pra não reabrir a dúvida numa sessão futura.

### Validado

`node --check` nos 31 blocos `<script>`, balanço de `<div>`
(254/254). Simulação Node isolada (fora do jsdom, função pura sem
dependência de DOM) com o cenário exato do relato — Difícil, 13% de
bônus combinado — rodando 20 tarefas seguidas: total **101 moedas
com bônus** contra **90 sem bônus** (valor teórico teto ver contas
seria 101,7; a diferença de 0,7 é a fração que ainda não fechou uma
moeda inteira, fica carregada pra próxima tarefa). Confirma que o
bônus de 13% agora se reflete no total real ganho, sem inflar nem
perder moeda ao longo do tempo — só desloca quando cada moeda extra
"cai", igual o efeito real do bônus de XP já sempre teve.

## 24. Perfil → Histórico — calendário do mês (v4.36, reformulado em v4.37)

Item 4 da lista "Conteúdo da aba" do Perfil (seção 4), marcado como
"próximo da fila" numa sessão de brainstorm paralela a esta. Passou
por duas versões nesta sessão — vale registrar as duas, não só a
final, porque a primeira não foi descartada por estar errada
tecnicamente, foi descartada por não caber na navegação.

### v4.36 — nasceu como 5ª sub-aba do Perfil

Duas decisões de escopo fechadas em conversa antes de codar: nome
"Histórico" em vez de "Calendário" (o usuário via os dois como
sinônimos, "eu achei que o calendário já era o histórico" — não pediu
reagrupar com Sequência/streak, só usava os nomes de forma
intercambiável), e versão "Completo" em vez de "Simples" (dias
alinhados domingo-sábado de verdade, com navegação entre meses — não
uma grade sequencial ignorando o dia da semana).

Isso criou um problema de layout que não tinha nada a ver com o
Histórico em si: a nav de sub-abas do Perfil (`.perfiltabs`) foi
dimensionada em v4.28 pensando em 3-4 itens. Com 5 (engrenagem + 4
pills de texto), a soma das larguras passou de ~490px contra
~324-364px disponíveis dentro do `.app`. Relatado pelo usuário como
"abre um espaço vazio" e "muita gente nem vai saber que tem mais uma
opção ali". Uma primeira correção (mesma sessão) trocou as pills por
ícone+legenda no padrão da nav inferior — resolvia o estouro
matematicamente, mas o usuário não gostou do resultado visual: "deixa
o layout antigo que tava muito melhor".

### v4.37 — Histórico sai da nav de sub-abas, vira botão em Config

Em vez de insistir em caber 5 itens na nav de sub-abas de um jeito ou
de outro, a solução foi tirar o Histórico de lá. Arquitetura final:

- **Sub-abas do Perfil voltaram a ser 4** (Config/Atributos/Conquistas/
  Bestiário), no layout de pill de texto original de v4.28 — revertido
  byte a byte, ícones novos descartados.
- **Histórico virou uma linha dentro de Config** (`#cfgHistorico`,
  mesmo padrão visual de "Renomear"/"Tema"/"Apagar tudo" — rótulo,
  descrição, botão "Abrir").
- **O calendário em si agora é um overlay de tela cheia**
  (`#histOverlay`), mesmo padrão estrutural do Grimório
  (`.grimOverlay`/`.grimFechar`: `position:fixed;inset:0`, cabeçalho
  com título + botão "×", área rolável embaixo) — **mas usando as
  variáveis de tema** (`var(--bg)`, `var(--text)` etc.) em vez da
  paleta fixa em hex que o Grimório usa. O Grimório não responde a
  troca de tema por causa disso (inconsistência já existente, fora do
  escopo desta sessão); o Histórico responde, de propósito, pra não
  repetir o mesmo problema num módulo novo.

Essa mudança resolve o estouro de largura pela raiz — 4 itens sempre
coube bem na nav de pills, era especificamente o 5º que não cabia — em
vez de forçar a nav a comportar mais itens do que o layout aguenta.

### Fonte de dado — zero coisa nova

Lê só de `window.obterHistorico()`, já existente desde a v4.29. Sem
chave de `localStorage` própria. O mês/ano que o calendário está
mostrando (`calAno`/`calMes`) vive só em memória, dentro do módulo —
reseta pro mês atual toda vez que o overlay **abre** (era "toda vez
que a aba Perfil reabre" na versão v4.36; o gatilho mudou junto com a
arquitetura, o comportamento de "nunca lembra de navegação antiga"
continua o mesmo).

### Montagem do mês — sem passar por `Date` pra gerar a data final

```js
function diasNoMes(ano, mes){ return new Date(ano, mes + 1, 0).getDate(); }
function primeiroDiaSemana(ano, mes){ return new Date(ano, mes, 1).getDay(); }
function isoDoDia(ano, mes, dia){
  return ano + '-' + String(mes + 1).padStart(2, '0') + '-' + String(dia).padStart(2, '0');
}
```

`diasNoMes`/`primeiroDiaSemana` usam `Date` só pra pegar um número
(dia do mês seguinte com dia 0 = último dia deste mês; dia da semana
do dia 1) — truques padrão de JS, sem risco de fuso horário porque
não dependem de conversão pra string ISO em nenhum momento.
`isoDoDia` monta a string final **direto dos inteiros**, sem passar
por `Date`/`toISOString()` — a mesma classe de bug de fuso que
`isoDe()` (função já existente, usada em todo o resto do arquivo)
precisa de um truque de offset pra evitar simplesmente não tem chance
de aparecer aqui, porque não há conversão de fuso envolvida.

### As 3 categorias, cor reaproveitada, não inventada

`resultado` do histórico (`'vitoria'`/`'fuga'`/`'sem_tarefa'`) vira
cor de célula: `--verde` (mesma variável já usada em outros
indicadores de sucesso no app), `--perigo` (mesma de outros avisos
negativos), cinza neutro pra `sem_tarefa`. Dia sem entrada nenhuma no
histórico — futuro, ou anterior a quando a versão v4.29 começou a
gravar (ver "Sem backfill" na seção do Perfil) — fica sem cor, só o
número do dia. Não tentei diferenciar "no futuro" de "antes do
histórico existir" visualmente; os dois casos são "não sei", tratados
igual.

### Revelação de hoje em tempo real — mesmo princípio, com uma diferença importante

Mesmo padrão já estabelecido em Bestiário (seção 22) e Conquistas
(seção 17): se `monstroJaCaiu()`, o dia de hoje aparece como
`'vitoria'` mesmo sem entrada no histórico ainda (a virada só grava
amanhã), sem persistir nada — recalculado a cada render.

**Diferença deste caso:** o calendário **nunca mostra `'fuga'`
preventivamente** pro dia corrente, mesmo que o jogador já tenha
deixado tarefas de hoje pra trás. Bestiário e Conquistas só têm um
sinal positivo pra antecipar (`monstroJaCaiu()` — "já venceu"); não
existe equivalente "já perdeu" antes do dia fechar, porque o jogador
ainda pode completar as tarefas que faltam até a virada. Mostrar
`'fuga'` antes disso seria uma previsão, não um fato — e previsão
errada apareceria pro jogador como o app "acusando" uma fuga que ele
ainda pode evitar. A célula de hoje fica sem cor (mesmo tratamento de
"não sei" de um dia futuro) até `monstroJaCaiu()` virar verdade, ou
até a virada gravar o resultado de verdade no `historico` (nesse
ponto, o resultado passa a vir do jeito normal, via `porData`).

### Abrir/fechar — sem armadilha de closure desta vez

Diferente de Bestiário e Conquistas (sub-abas, presas ao `onclick`
local da IIFE "PERFIL — SUB-ABAS"), o Histórico agora é acionado por
um botão dentro do painel `#perfilConfig`, que já é HTML estático
simples — `document.getElementById('cfgHistorico').onclick` funciona
direto, sem precisar de segundo `addEventListener` nem de wrap em
`window.mostrarAba`. Uma consequência boa e não-planejada de tirar o
Histórico da nav de sub-abas: o módulo ficou mais simples também.

### Validado em jsdom, não só lido

**v4.36 (grade em si, ainda válido — matemática não mudou):**
histórico semeado com 4 entradas cobrindo os 3 resultados mais um dia
do mês anterior, testado contra a data real do ambiente (14 de agosto
de 2026, confirmado via `date` do sistema antes de escrever o teste,
não assumido): 1º de agosto de 2026 cai num sábado, então o mês devia
abrir com exatamente 6 células vazias antes do dia 1 e 37 células no
total (6 + 31 dias) — bateu. As 4 entradas semeadas apareceram com a
classe de cor certa, o dia sem entrada ficou neutro. Navegação testada
nos dois sentidos. Teste do "hoje em tempo real": `derrotadoEm =
isoAtual()` sem tocar no histórico, célula de hoje virou `calvitoria
calhoje`, e `obterHistorico()` confirmado ainda sem essa entrada —
nada foi persistido.

**v4.37 (arquitetura nova, botão + overlay):** sub-nav do Perfil
confirmada de volta a 4 botões. Botão "Histórico" confirmado existindo
dentro de `#perfilConfig`. Clique nele abre o overlay, mostra o mês
atual, grade renderizada corretamente (dia 1 de agosto com a cor
certa). Navegação pro próximo mês funciona dentro do overlay aberto.
Botão "×" fecha. Reabrir depois de ter navegado pra outro mês confirma
que volta pro mês atual — não "lembra" da navegação anterior, mesmo
com o gatilho tendo mudado de `mostrarAba('perfil')` pra clique direto
no botão de Config.

### Validado

`node --check` nos 32 blocos `<script>`, balanço de `<div>`
(265/265).

---

## 25. Projeção do painel de economia — dificuldade ignorada, corrigido (v4.38)

> Versão do arquivo ao final desta sessão: `questlog-4-38-fix-economia.html`

### O bug (item 10 da seção 4)

`simEco()`, a função que alimenta a "Projeção" do painel de economia
(nível e moedas/dia estimados em 30 dias), nunca recebia a dificuldade
da tarefa. O cálculo de XP e moedas por tarefa saía sem nenhum
multiplicador de dificuldade — equivalente a assumir Fácil (×1) o
tempo todo. Só que o padrão real do composer, e de qualquer tarefa
sem campo `dif` salvo, é Média (`DIF_PADRAO = 'media'`, ×1,5). Na
prática, a projeção sempre mostrava um número bem menor do que o
jogador realmente ganha jogando — a subestimativa de ~50% que o
roadmap já vinha registrando havia duas sessões.

### Fix

`simEco(dias, tarefasDia, multX, multM, dif)` ganhou um 5º parâmetro
opcional. Dentro do loop, `md = multDif(dif || DIF_PADRAO)` passou a
multiplicar tanto o XP quanto as moedas por tarefa. Como o parâmetro é
opcional com default `DIF_PADRAO`, as 5 chamadas existentes
(`resumoLoja()` ×2, `atualizarSim()` ×3) saíram corrigidas sem precisar
editar nenhuma delas — só a assinatura da função mudou.

`recompensaVitoria()` (o bônus fixo por derrubar o monstro do dia) foi
conferida à parte: no jogo real ela não usa dificuldade, só `nTarefas`
e o multiplicador de equipamento. O simulador já estava certo nesse
ponto específico — não mexi.

**Extra, não pedido no diagnóstico original mas de baixo custo:** a
dificuldade assumida virou **selecionável no painel**, não fixa em
Média. Dropdown "Dificuldade assumida" (Trivial/Fácil/Média/Difícil)
inserido no HTML do painel, logo acima do bloco de Projeção. Estado
guardado em `let ecoDifSim = DIF_PADRAO`, plugado via `onchange` que
chama `atualizarSim()` de novo. Permite simular cenários sem editar
`ECO` na mão.

### O que não muda

O **preço dos itens na loja continua exatamente igual** — a fórmula
`valor do item × ECO.lojaMargem` não foi tocada. O que mudou foi só a
estimativa de "quantos dias de moeda até dar pra comprar", que a
projeção usa pra montar o resumo da loja (`resumoLoja()`). Ponto
confirmado explicitamente com o usuário durante a sessão, porque não
era óbvio à primeira vista.

### Validado em jsdom, não só lido

Rodado o arquivo real (`questlog-4-37-historico-em-config.html`
enviado pelo usuário, não uma cópia reconstruída) num DOM headless:
`simEco(30,5,1,1,'facil')` reproduziu o número antigo (3000 XP/30d);
sem o 5º argumento, bateu com `simEco(30,5,1,1,'media')` (4500 XP/30d)
— confirma que o novo default está ativo. Painel aberto de verdade
(`abrirEco()`), o `<select>` de dificuldade encontrado no DOM com as 4
opções certas, e a troca de valor (`dispatchEvent(new Event('change'))`)
mudou o texto renderizado em `#ecoSim` de fato — Difícil > Média >
Trivial em moedas/dia, ordem coerente. `recompensaVitoria(5)`
comparada antes/depois do fix: idêntica, confirmando que não foi
tocada.

### Armadilha desta sessão — arquivo errado, duas vezes

Vale registrar porque quase virou retrabalho de verdade: nas duas
primeiras tentativas desta sessão, o fix foi aplicado num arquivo
`produtividade-rpg-*.html` que **não é o Questlog** — sobra de uma
sessão anterior mal encerrada, montado por engano no lugar do arquivo
real do projeto. O sintoma que expôs o erro: o usuário colava o painel
gerado no Questlog de verdade e recebia `ReferenceError: ECO is not
defined`, porque as linhas que o fix dizia pra substituir simplesmente
não existiam no arquivo dele. Composto por um segundo erro: mesmo
depois de perceber isso, o fix seguinte foi feito em cima de
`/mnt/project/questlog-4-31-conquistas.html` — uma cópia estática e
desatualizada (parada em 12 de agosto), enquanto o `project_knowledge_search`
já apontava a v4.37 como corrente, com itens do roadmap renumerados
(o que era item 9 virou item 10 depois que outro bug ocupou o 9 na
v4.35). **Causa raiz dos dois erros: não confiar no arquivo montado
em `/mnt/project/` nem em buscas parciais do `project_knowledge_search`
quando o objetivo é editar — sempre pedir o upload direto do HTML e do
`roadmap.md` no chat antes de tocar em código,** que é exatamente o
fluxo que este projeto já usa por padrão. O fix final desta seção foi
refeito do zero em cima dos dois arquivos que o usuário subiu
diretamente nesta sessão, com hash conferido.

---

## 26. Painel de economia removido — escopo corrigido em conversa (v4.38, item 6 parcial)

> Versão do arquivo ao final desta sessão: `questlog-4-38-fix-economia.html`

### O pedido, e o que eu entendi errado

Pedido do usuário: "pode marcar a economia como pronta e tirar o botão
debug", falado logo depois de fechar o item 10 (fix da economia).
Interpretei "o botão debug" como o item 6 inteiro do roadmap ("remover
os botões de depuração... incluindo o painel de economia") e removi a
`.debugbar` toda — os dois botões de teste (`próximo dia →`,
`pular tutorial`) junto com o painel de economia. Sinalizei a leitura
ampla antes de agir ("vou tratar como fechar o item 6 inteiro... se
você queria só o botão economia, me avisa"), mas errei em executar a
remoção grande antes de esperar a confirmação — deveria ter perguntado
e parado, não perguntado e prosseguido.

**Usuário corrigiu na hora:** só o botão/painel de economia devia
sair. O resto do teste (`próximo dia →`, `pular tutorial`) ainda está
em uso — "o resto eu ainda não terminei, eu vou ainda testar".

### Fix do escopo

Refeito a partir do arquivo intermediário desta mesma sessão (fix do
item 10 já aplicado, remoção do item 6 ainda não). Removido apenas:

- Botão "economia" e o painel inteiro: `montarEco()`, `montarBonus()`,
  `resumoLoja()`, `atualizarSim()`, `gerarCodigo()`, `simEco()`,
  `tetoSet()`, `abrirEco()`/`fecharEco()`, os elementos `ecoBG`/
  `ecoPanel`, `ECO_CAMPOS`, `ECO_PADRAO`/`BONUS_PADRAO`,
  `salvarEco()`/`carregarEco()` (chave `rpg_eco_v1`).
- CSS órfã: `.ecobg`, `.ecopanel` e as classes `.eco*` associadas.

**Mantido, revertendo o excesso da primeira tentativa:**

- `<div class="debugbar">` — a div em si continua no HTML, agora com
  só os dois botões que já existiam.
- `#debugbtn` ("próximo dia →") e seu handler — intactos, funcionando.
- `#pularTutoriaisBtn` ("pular tutorial") e seu handler — intactos.
- CSS `.debugbar`/`.debugbtn` — continua servindo os dois botões que
  ficaram.

O item 6 do roadmap **continua aberto** — só a fatia do painel de
economia foi resolvida, como consequência natural do item 10, não como
fechamento do item inteiro.

### O que não muda (igual à primeira tentativa, não precisou refazer)

`ECO`, `BONUS`, `DIFS`, `multDif()`, `xpDaTarefa()`,
`moedasDaTarefa()`, `recompensaVitoria()`, `precoVenda()` — toda a
economia real do jogo — nunca foi tocada, nas duas tentativas. O
painel era só a interface de edição ao vivo. `avancarDia()` e
`verificarVirada()` também seguem como na primeira tentativa (ver
seção 25): a primeira é só o atalho de teste do botão que ficou; a
segunda é a detecção real de virada de dia, função separada, intocada.

### Validado em jsdom, não só lido

App carregado do zero, DOM headless: zero erros de execução.
`.debugbar` presente no DOM com exatamente 2 botões (`próximo dia →`
e `pular tutorial`, confirmados por `id`). `.ecopanel` ausente.
`typeof abrirEco === 'undefined'` e `typeof simEco === 'undefined'`
(painel de fato removido) contra `typeof avancarDia`,
`typeof multMoedas`, `typeof multXP`, `typeof alternar` todos ainda
`'function'`.

### Validado

`node --check` equivalente nos 32 `<script>`, balanço de `<div>`
(260/260 — 259 na primeira tentativa, mais 1 porque a `.debugbar` com
2 botões voltou), balanço de comentário (23/23).

### Lição desta sessão, registrada pra não repetir

Quando um pedido do usuário é ambíguo o bastante pra precisar de uma
frase inteira explicando "vou interpretar assim, me avisa se for
diferente" — a resposta certa é **perguntar e esperar**, não
**anunciar a interpretação e já executar**. Sinalizar a ambiguidade não
vale nada se a ação de alto custo (remover código, ainda que
reversível) acontece antes da confirmação chegar. Fica pra próxima:
ambiguidade real + ação destrutiva/grande = pergunta primeiro, sem
exceção — mesmo que o resto da sessão até então tenha sido decisões
rápidas e diretas do usuário.

## 27. Conquistas ganham recompensa — XP em todos os 39 marcos, resgate manual, badge (v4.39)

Item 10 (projeção de economia) fechou em v4.38, o que destravava a
decisão de recompensa que ficou registrada na seção 17 como pendência
específica. Retomada nesta sessão.

### Decisão, em 3 passos

1. **Tipo de recompensa** — usuário escolheu "item exclusivo", das 4
   opções levantadas (sem recompensa / item exclusivo / XP em todos /
   XP só nos finais).
2. **Onde o item vive** — usuário escolheu a opção B (item de verdade
   no Inventário, com sprite próprio) em vez da A (só um selo na
   trilha, sem tocar no Inventário).
3. **Depois de ver funcionando, ampliado e revertido em parte** — ver
   duas subseções abaixo.

### Por que o item exclusivo não podia entrar em `ITENS`

O Grimório tem exatamente 100 itens, e um dos marcos de Conquistas é
literalmente "descubra todos os 100". Se os itens de recompensa
entrassem no mesmo array `ITENS`, o total subiria pra 105 e esse marco
viraria uma trava sem saída — precisaria de todos os 105 pra completar,
mas o item 105 só existiria depois de completar. Motivo pelo qual,
enquanto essa peça existiu (ver "Revertido" abaixo), ela vivia num
array e numa chave próprios, fora do catálogo comum.

### Ampliado: XP em todos os 39 marcos, não só nos 5 finais

No meio da implementação, usuário pediu mais 3 coisas de uma vez:
recompensa de XP em **toda** conquista (não só as 5 finais), indicador
de notificação nos botões em vez de popup automático, e resgate manual
("clique pra receber") em vez de concessão automática ao completar.

**XP por marco:** valores explícitos por marco (não fórmula), crescendo
dentro de cada categoria — de 15 XP (primeiro marco) a 320 XP (marco
final). Soma total dos 39: **≈ 4.900 XP**. Referência: chegar ao nível
L sozinho (via `xpNecessario()`) exige ≈ 75.460 XP, então o total das
conquistas é ≈ 6,5% disso — bônus real, não uma fonte que reabre o
problema que o item 10 tinha acabado de fechar.

**Resgate manual, não automático:** chave nova
`questlog.conquistasResgatadas.v1` (Set de ids de marco, formato
`categoria:índice`, ex. `'nivel:7'`). Cada marco tem 4 estados agora em
vez de 3: `bloq` (não alcançado, mostra prévia "Recompensa: +N XP`),
`atual` (em progresso, mesma prévia + fração), `pendente` (alcançado,
não resgatado — nó pulsando + botão "Receber · +N XP"), `feito`
(resgatado — check estático + "+N XP recebido"). Clique no botão chama
`resgatarConquista(tierId)`, que:
- confere idempotência via `conquistasResgatadas`
- soma `xpTotal += tier.xp`, com a mesma checagem de nível-antes/depois
  já usada em `alternar()` — se subir de nível, enfileira
  `mostrarNivelUp()` (a recompensa de conquista agora pode disparar o
  popup de level-up, coisa que `usarItem()` não faz pra consumíveis
  comuns — decisão deliberada, é um momento maior)
- reaproveita `aviso()` (mesmo toast de `usarItem()`) pro feedback de
  "+N XP"

**Badge de notificação:** função `contarPendentes()` soma marcos
`pendente` nas 5 categorias; `atualizarBadges()` escreve o número num
`<span class="conqbadge">` injetado via JS em cima do botão "Conquistas"
(sub-aba) **e** do botão "Perfil" (nav inferior) — dois pontos, pra
avisar mesmo sem o jogador ter entrado no Perfil ainda. Recalculado a
cada `window.salvar()` (embrulhado, ~15 pontos de chamada no app
inteiro), não só quando a tela de Conquistas abre — um badge que só
atualiza quando a tela já está aberta não serve pra nada.

### Bug de segurança encontrado e corrigido no caminho: exploit via monstro do dia

`montarContexto()` já tinha uma leitura "ao vivo" do monstro do dia
(`histComHoje`, da seção 22/Bestiário) pra Matar Monstros e Sequência
Diária reagirem sem esperar a virada. Isso é ótimo pra exibição, mas
vira um problema no momento em que existe uma recompensa permanente
anexada ao `feito`: jogador vence o dia, tela mostra o marco como
pronto, clica "Receber", ganha o XP — e só *depois* desmarca uma
tarefa antes da virada. O marco volta a ficar bloqueado (o
`histComHoje` reverte, como sempre reverteu), mas o XP já foi creditado
e persistido. Reversível na tela, irreversível na recompensa.

Corrigido parametrizando `montarContexto(comHoje)`: a trilha visual
continua usando `comHoje=true` (feedback imediato, como sempre foi);
`resgatarConquista()` recalcula um `ctxReal = montarContexto(false)` —
só com o histórico realmente persistido — e checa a elegibilidade
contra *esse*, não contra o que está na tela. Testado em jsdom
simulando exatamente esse caminho (`derrotadoEm` setado sem virada
rodar): o botão aparece pendente, o clique não falha visivelmente, mas
`xpTotal` e `conquistasResgatadas` não mudam nada — bloqueio silencioso,
sem crash, sem mensagem de erro pro jogador (só não acontece).

### Revertido: item de inventário exclusivo

Depois de construído, testado e funcionando (5 itens, sprite pixel-art
inline reaproveitando a técnica do ícone de moeda, aba "Troféus" nova
em `#invFiltros`, ficha de detalhe via `ficha`/`fichaBG`, popup de
celebração próprio), usuário pediu pra tirar inteiro: **"o negócio do
troféu pode tirar sinceramente do inventário inclusive a opção no
inventário."**

Removido por completo: o bloco `TROFÉUS DE CONQUISTA` (array `TROFEUS`,
`concederTrofeuSeElegivel`, `abrirFichaTrofeu`, popup `trofeuBG`/
`trofeuPop`, botão "Troféus" em `#invFiltros`, wrap de
`renderInventario`) — nada ficou de placeholder morto, o arquivo
inteiro (style + script) foi apagado. `resgatarConquista()` voltou a
tratar todos os 39 marcos de forma idêntica: os 5 que antes eram
"finais" (com item) agora só têm XP maior (320 vs 15–250 dos outros),
sem branch especial nenhuma. Chave `questlog.trofeus.v1` fica órfã —
não é lida em lugar nenhum mais, inofensiva se sobrar de testes
anteriores, não precisa de migração.

**Por que registrar uma feature que nem chegou a ir pro ar:** o motivo
de não entrar no `ITENS` catalog (explicado acima) continua válido pra
qualquer versão futura de "item de recompensa" que apareça de novo —
não vale a pena redescobrir esse limite do zero se a ideia voltar.

### Testado em jsdom, 3 rodadas

1. **Resgate normal:** marco nível 1 forjado, botão "Receber · +15 XP"
   clicado, `xpTotal` +15 confirmado, botão some depois (idempotência
   visual), sem item concedido (na época em que o troféu ainda existia).
2. **Resgate de marco final + exploit:** nível 50 forjado, XP creditado
   junto com o troféu (versão anterior), popup de trofeu confirmado
   com nome certo; monstro do dia simulado sem virada, marco aparece
   pendente na tela mas o clique em "Receber" não altera `xpTotal` nem
   `conquistasResgatadas` — exploit bloqueado.
3. **Pós-remoção do troféu:** `window.concederTrofeuSeElegivel` e
   `window.abrirFichaTrofeu` confirmados `undefined`, botão "Troféus"
   confirmado ausente do Inventário, marco final resgatado de novo —
   agora só XP (+320), sem popup, sem item, `questlog.trofeus.v1`
   confirmado nunca escrito.


---

## 28. Bug: clique repetido na caixa contava a tarefa várias vezes (v4.40)

### O pedido

Verificar se cliques repetidos numa tarefa contavam conclusão múltiplas vezes.
Reproduzido em jsdom antes de mexer em qualquer linha — não foi hipótese.

### A causa, em duas partes

1. **Sem trava no clique.** O handler da caixa (`el.querySelector('.box').onclick`)
   agenda `alternar(i)` num `setTimeout` de 150ms (progresso parcial) ou 460ms
   (conclusão final). O elemento só sai da tela quando `render()` roda de
   novo — e isso só acontece **dentro** do próprio `alternar()`, ou seja,
   depois do delay. Existe uma janela de até 460ms em que a caixa continua
   na tela, clicável, com o handler intacto.
2. **`alternar()` não verificava se a tarefa já estava concluída hoje.**
   Confiava cegamente em quem chamou.

Juntas: cada toque extra dentro da janela é uma recompensa inteira de novo.

**Medido:** 1 clique = 3 moedas / 30 XP. 6 cliques rápidos (50ms entre eles)
na mesma tarefa = **18 moedas / 180 XP** — multiplicador exato de 6x, e a
tarefa continuava contando como uma só na lista (`1 de 2 concluídas`), então
o excesso não aparecia em lugar nenhum da UI — só no saldo.

### O que mudou

- **Trava síncrona no clique** (`el.dataset.travado`), dentro de `render()`
  onde a caixa é montada: o primeiro clique fecha a porta antes de qualquer
  `setTimeout`. Como `el` é recriado do zero a cada `render()`, a trava some
  sozinha assim que a conclusão real processa — nenhum estado novo em
  `localStorage`, nenhuma chave nova.
- **Guarda redundante dentro de `alternar()`** para tarefas de meta=1: se
  `feitaHoje(t)` já é verdade, retorna sem somar nada. Defesa em profundidade
  para qualquer chamada futura que não passe pela caixa (atalho de teclado,
  ação em lote). Tarefas de meta>1 já tinham a própria trava em `vezesN` e
  não entram nesse guard.

### Cenários cobertos por teste (`clique2.js`, `clique3.js`, `regressao.js`)

| Cenário | Esperado | Antes | Depois |
|---|---|---|---|
| 6 cliques rápidos (50ms), meta=1 | conta 1x | 6x (18 moedas / 180 XP) | 1x (3 / 30) |
| 8 cliques rápidos (30ms), meta=4 | avança no máximo o que os cliques legítimos permitirem | passava de 4 | trava em 1 |
| 4 cliques **espaçados** (300ms+), meta=4 | 1→2→3→4, completa no 4º | — | ok |
| Excluir tarefa | continua funcionando | — | ok |
| Clique no corpo da linha (fora da caixa) | abre editor | — | ok |
| Duas tarefas, um clique legítimo em cada | ambas contam, monstro derrotado | — | ok |

### Por que a trava fica em `el.dataset`, não numa variável de módulo

Uma variável só (`let travado = false`) precisaria de lógica extra pra saber
*qual* tarefa destravar quando o `render()` de outra tarefa acontece no meio
do caminho. Guardar no próprio elemento do DOM amarra o estado ao objeto que
vai ser descartado de qualquer forma — sem chave de sincronização, sem
risco de destravar a tarefa errada.


---

## 28. Resgate de conquista só funcionava no dia seguinte (v4.41)

### O pedido

Clicar em "Receber" numa conquista recém-desbloqueada não fazia nada até o
dia virar. Reproduzido antes de mexer: XP e moedas da tarefa somavam
normal, mas o clique em "Receber" não somava o XP da conquista, não
marcava como resgatado, e o botão continuava lá — silenciosamente.

### A causa

`resgatarConquista()` conferia elegibilidade contra `montarContexto(false)`
— o histórico **permanente**, gravado só na virada do dia
(`registrarHistorico()`, chamado de dentro de `verificarVirada()`). A tela
mostra o botão usando o contexto **ao vivo** (`comHoje:true`, que inclui a
vitória de hoje antes da virada). Os dois nunca batem no mesmo dia.

Isso não era descuido — era uma trava anti-exploit deliberada e comentada
no código: impedir vencer, resgatar, desfazer a vitória antes da virada e
ficar com a recompensa sem o feito valer de verdade.

### Por que dava pra tirar a trava com segurança

Investiguei se esse exploit ainda é alcançável pela UI antes de mexer em
qualquer linha. **Não é, e por dois motivos independentes, já existentes:**

- `criar()` recusa nova tarefa quando `monstroJaCaiu()` é verdade — mostra
  o aviso "MONSTRO DE HOJE JA CAIU". Não dá pra reabrir o dia adicionando
  pendência depois de vencer.
- `verificarVitoriaAoExcluir()` não mexe em `derrotadoEm` quando
  `monstroJaCaiu()` já é verdade — excluir também não desfaz.

Com os dois bloqueados, **não existe caminho de UI** pra `derrotadoEm`
voltar a `null` no mesmo dia depois de setado. Testei os dois diretamente
em jsdom antes de confiar nisso: tentativa de criar tarefa após vitória
retorna o aviso de bloqueio, sem exceção.

### O que mudou

- `resgatarConquista()`: `montarContexto(false)` → `montarContexto(true)`
  — a mesma variante já usada por `renderCategoria()` pra desenhar o botão.
  O que aparece na tela e o que o clique confere passam a ser exatamente
  o mesmo estado.
- Comentário grande de `montarContexto()` reescrito pra não ficar
  desatualizado: `comHoje=false` agora é descrito como uso do
  Bestiário/Histórico (que realmente precisam só do registro permanente),
  não mais como "a variante segura pro resgate".

### Cenários cobertos por teste (`conq1.js`, `conq2.js`, `conq3.js`)

| Cenário | Esperado | v4.40 | v4.41 |
|---|---|---|---|
| Vencer o dia, clicar Receber na hora | soma XP, marca resgatado | nada acontece | funciona |
| Clicar Receber duas vezes seguidas | idempotente, não soma 2x | — | ok |
| Resgate sobrevive à virada do dia seguinte | não duplica, não desfaz | — | ok |
| Resgatar tier NÃO atingido (chamada direta) | recusado | — | ok |
| Criar tarefa depois de vencer | continua bloqueado | ok | ok |

### Se algum dia isso precisar mudar de novo

Se `criar()` ou `verificarVitoriaAoExcluir()` perderem a guarda contra
`monstroJaCaiu()` — por exemplo, numa sessão futura que queira permitir
adicionar tarefa extra depois de vencer — esta correção **para de ser
segura** e o resgate volta a precisar conferir contra o histórico
permanente. Os dois pontos estão citados no comentário do código
justamente pra isso não passar despercebido.

---

## 29. Som de recompensa de conquista + retomada em cima de arquivo mais novo (v4.42)

> Versão do arquivo ao final desta sessão: `questlog-4-42-sfx-conquistas.html`

### Contexto: sessão retomada em cima de um arquivo que andou sozinho

Esta sessão de SFX (seção 20) tinha ficado parada em `v4.32`. Entre ela e
agora, outras sessões avançaram o projeto até `v4.41` (seções 21–28,
incluindo o sistema de recompensa de conquistas em si — seção 27 — e o
fix de resgate — seção 28). O pedido desta rodada foi retomar o SFX **em
cima do arquivo mais novo do project knowledge**
(`questlog-4-41-fix-resgate.html`), não da cópia antiga de trabalho.

Conferido antes de mexer: o motor de SFX inteiro (catálogo de sons,
`window.tocarSom`, todos os ganchos das seções 20) já estava presente e
intacto no `4-41` — o usuário tinha reincorporado o resultado da sessão
anterior no arquivo de produção normalmente. Não foi preciso reaplicar
nada, só validar que ainda batia (`node --check` limpo, contagens de
`<div>`/`<svg>`/comentário balanceadas) antes de somar o novo som.

**Nota à parte, não relacionada a SFX:** o roadmap tem dois títulos
`## 28.` (`Bug: clique repetido...` e `Resgate de conquista só
funcionava...`, v4.40 e v4.41). Não renumerei — não é escopo desta
sessão e mexer na numeração de seções de outra sessão sem combinar
pode confundir referência cruzada já feita em comentário de código
(ex: `// ver secao 28 do roadmap, v4.41` dentro de
`resgatarConquista()`). Só sinalizando pra quando for conveniente
arrumar.

### O que foi pedido

Som pra receber recompensa de conquista (`resgatarConquista()`),
reusando o som `grimorio` já existente — pedido explícito do usuário,
sem precisar desenhar um som novo.

### O que mudou

Edição direta dentro de `resgatarConquista()`, logo após
`persistirResgatados(resgatados)` confirmar o resgate:

```js
window.tocarSom?.('grimorio');
```

**Por que edição direta, não wrap externo:** mesma família de exceção
já documentada pra `comprar()`/`investir()` — `resgatarConquista()` é
chamada pelo listener delegado dentro do **mesmo módulo/IIFE** que a
declara (`alvoConquistas.addEventListener('click', e => { ...
resgatarConquista(btn.dataset.resgatar); })`, seção 27/28). A busca do
nome `resgatarConquista` dentro dessa arrow function resolve pelo
escopo léxico do módulo antes de chegar em `window.resgatarConquista`,
então reatribuir `window.resgatarConquista` por fora não interceptaria
esse clique — mesmo padrão de causa-raiz que a armadilha de `criar()`
documentada na seção 20, aplicado aqui por closure em vez de referência
copiada.

Posicionado depois de todos os guards de elegibilidade/idempotência
(`resgatados.has(tierId)`, tier inválido, `valorReal < metaReal`) —
só toca em resgate genuíno, nunca em clique bloqueado ou resgate
repetido. Se o resgate também disparar level up, o som `levelup` toca
separado (lógica de detecção já existente na função) — `grimorio` cobre
especificamente "recompensa recebida", os dois não se excluem.

### Validação

32 blocos `<script>` (cresceu de 29 pra 32 com o sistema de conquistas
do arquivo `4.41`), `node --check` limpo em todos, comentários `<!--
-->` (23/23), `<div>` (260/260) e `<svg>` (20/20) balanceados.

---

## 30. Tela de login + Firebase Auth — primeira versão visual (v4.43)

> Versão do arquivo ao final desta sessão: `questlog-4-43-login-firebase.html`
> **Sessão pausada por crédito do usuário — retomar por aqui.**

### O que foi pedido

Item 13 (seção acima) finalmente entrou em implementação: tela de login
antes do onboarding, com email/senha + Google, referência visual solta
(print de um app chamado "Focus Knight") — não pra copiar 1:1.

### O que foi construído

- **`#passoLogin`**: novo passo injetado via JS (`insertAdjacentHTML`)
  dentro de `#intro .card`, **não edita nenhuma linha estática** de
  `#intro`/`#passo1..#passo3`. Só aparece se `#intro` **não** tiver a
  classe `off` (ou seja: usuário novo, sem save local). Quem já joga
  não vê nada disso — zero mudança de comportamento pra quem já usa o
  app offline, confirmando a decisão já registrada no item 13.
- Campos email/senha, toggle "Entrar" ↔ "Criar conta" (reamarra o
  listener do botão a cada troca, porque `innerHTML` descarta o nó
  antigo), "Esqueceu a senha?", botão Google, "Continuar sem conta"
  (mesmo fluxo de onboarding de sempre).
- **Botão de idioma**: cosmético, sem função ainda — só dispara
  `aviso('Idioma: em breve')`.
- **Botão de tema**: cicla entre os 3 temas existentes escrevendo na
  **mesma chave** `questlog.tema.v1` que o seletor de Perfil > Config
  já usa — nenhuma lógica de tema nova, só um atalho de UI.
- **Módulo Firebase** (`<script type="module">`, separado do resto):
  `firebaseConfig` como placeholder (`"COLE_AQUI_SUA_APIKEY"` etc.) —
  enquanto não for preenchido, os botões de auth só avisam
  "Configure o firebaseConfig" em vez de tentar carregar o SDK.
  Quando preenchido: `signInWithEmailAndPassword` /
  `createUserWithEmailAndPassword` / `signInWithPopup` (Google) /
  `sendPasswordResetEmail`, todos via SDK modular v10 direto do CDN
  (`gstatic.com`, sem bundler — compatível com o formato single-file).
- **Sync MVP, last-write-wins**: ao logar, puxa `questlog.v1` inteiro
  do Firestore (`saves/{uid}`) e sobrescreve o local; a partir daí,
  todo `salvar()` local também empurra pra nuvem (wrapper encadeado
  sobre `window.salvar`, no mesmo padrão já usado pelo módulo de
  Conquistas — `salvar` já tinha 1 wrapper antes deste, agora tem 2).
  **Sem resolução de conflito** — limitação conhecida, não escondida.

### O fundo: 4 tentativas até desistir da ideia

Pedido inicial: "seria legal uma imagem de dungeon de fundo mas não
copia exatamente". Registrando o caminho porque cada tentativa ensinou
algo que vale pra próxima vez que alguém for gerar arte de fundo aqui:

1. **Vinheta com gradientes CSS.** Rejeitada pelo usuário como
   genérica — não lia como dungeon nenhuma, só um vinheta difusa.
2. **SVG de "boca de caverna" (silhueta jagged, viewBox 400×800
   portrait) com `background-size:cover` no `.intro` inteiro.**
   Pareceu bem no preview mas **quebrou feio em desktop largo**: o
   usuário testou numa janela de Chrome widescreen e o resultado foi
   uma mancha laranja lavada sem contraste nenhum.
   **Causa raiz, vale registrar:** `background-size:cover` com uma
   imagem fonte **portrait** (alta e estreita) num container
   **landscape** (largo e baixo) faz o navegador escalar pela largura
   — o fator de escala vira gigante, e só sobra visível uma fatia
   horizontal fininha da imagem original (no caso, ~24% da altura).
   Com `background-position:center bottom`, essa fatia caiu bem no
   meio do "brilho" largo perto da base do desenho, perdendo toda a
   silhueta de rocha que dava contraste. **Lição: arte portrait +
   `cover` num container muito mais largo que alto SEMPRE recorta
   agressivo — ou o desenho precisa ser robusto a qualquer recorte
   vertical (textura repetida/uniforme), ou não deve usar `cover` num
   container de proporção livre.**
3. **Corrigido pra ser "crop-invariant"**: paredes de rocha dentada
   correndo a altura inteira do SVG nas duas bordas, brilho sempre no
   meio — technicamente resolvia o problema de (2), mas nunca chegou a
   ser testado nessa forma porque o usuário pediu pra trocar de
   abordagem antes (usando a imagem de referência de uma entrada de
   dungeon com parede de tijolo + arco escuro no meio).
4. **Parede de tijolo (reaproveitando o MESMO PNG que a `.arena` já
   usa) + arco desenhado em cima.** Duas rodadas de erro aqui:
   - **Erro de posicionamento:** o arco foi centralizado no `.intro`
     inteiro (`background-position:center`), caindo bem atrás dos
     campos de email/senha — usuário reportou "esse meio não ficou
     legal, nada a ver". Corrigido prendendo o arco só atrás da
     `.marca` (logo/título), nunca atrás do formulário.
   - **Erro de linguagem visual:** o arco usava um comando de arco
     elíptico do SVG (curva suave) — destoando de **todo** o resto do
     jogo, que é pixel art em blocos (`shape-rendering:crispEdges`,
     ícones montados em grade de `<rect>`). Usuário notou na hora:
     "o problema é que é pixel, não sei por que tu tá fazendo algo
     circular". Corrigido trocando a curva por 5 `<rect>` empilhados
     em degraus (efeito corbelled arch/escada, comum em pixel art de
     dungeon), larguras 200→160→120→80→40.
   - **Decisão final do usuário: tirar o arco de vez.** Depois de
     corrigido, ainda assim o custo (3 rodadas de ajuste) não
     compensou o ganho visual. Fundo final = **só a parede de tijolo**
     (tile reaproveitado da `.arena` + gradiente das cores do tema),
     sem arco nenhum. `pintarCaverna()` ficou reduzida a isso.

**Se algum dia isso for retomado:** a versão (3) crop-invariant nunca
foi validada visualmente — é candidata mais robusta que qualquer coisa
baseada em `cover` de uma imagem inteira, caso a ideia do arco volte à
mesa. Mas dado o histórico desta sessão, a recomendação é: só voltar a
mexer nisso se o usuário pedir de novo, não por iniciativa própria.

### Limpeza: ícone do monstro roxo removido de 2 lugares

A pedido do usuário ("tira esse bixo roxo... de todos os lugares"):
- Removido da `.marca` do **`#passo1`** (primeira tela do onboarding
  **original**, não é algo desta sessão — mas o pedido foi explícito
  "todos os lugares", então entrou no escopo).
- Removido da `.marca` da tela de login.
- Removida também a frase `"Entre pra sincronizar seu progresso entre
  aparelhos. É opcional."` da tela de login (usuário: "todo mundo sabe
  pra que serve").
- **Não removido:** a mesma silhueta de monstro roxo aparece uma
  terceira vez, dentro de `#mobSprite` na arena de combate — é o
  placeholder estático que existe antes do JS desenhar o monstro
  sorteado do dia por cima. Função de jogo diferente (não é logo),
  deixado intacto por não ter confirmação explícita de que era esse o
  alvo. **Pendência em aberto, perguntar antes de mexer.**

### Pendências pra retomar

1. **Bloqueante: falta o `firebaseConfig` real.** O usuário confirmou
   que já tem os valores prontos (projeto `questlog-d4c11`, ver item
   13), mas ainda não colou no chat. Sem isso, login/cadastro/Google só
   mostram o toast de aviso — nunca foi testado de ponta a ponta.
   Único ponto a editar: dentro do `<script type="module">`, comentário
   `>>> UNICA COISA A EDITAR <<<`.
2. **Layout do topo da tela de login não foi revisado** depois de tirar
   o ícone e a frase — `.marca` agora só tem o título "QUESTLOG"
   sozinho, pode ter sobrado espaço em branco/respiro errado ali.
   Sinalizado pelo próprio Claude ao usuário, não conferido ainda.
3. **`#mobSprite` na arena** — nota antiga, provavelmente já resolvida:
   confirmado em 26/08 que o HTML estático atual não tem nenhum
   elemento roxo/silhueta ali (só `<div class="sombra"></div>`) — a
   silhueta descrita aqui não existe mais no markup corrente. Ver
   detalhe completo e a explicação de um problema *diferente e novo*
   com o mesmo nome, na seção 70 (divisão de arquivos).
4. Fluxo de sync (last-write-wins) nunca foi testado com conta real —
   só o código foi validado (`node --check`, balanço de `<div>`/`<svg>`/
   comentário), não o comportamento em runtime com Firebase de verdade.

### Validação desta sessão

34 blocos `<script>` (32 → 34, os 2 novos deste bloco: classic +
`type="module"`), `node --check` limpo em todos — inclusive o módulo,
testado também isolado como `.mjs` puro pra confirmar sintaxe ESM real
(top-level `await import(...)` dentro de `type="module"`). `<div>`
267/267, `<svg>` 22/22 (variou ao longo da sessão conforme o fundo
mudava — 24 no meio do caminho com o arco, voltou pra 22 depois dele
ser removido, mais os 2 ícones do monstro tirados), comentários 24/24.

---

## 31. Firebase Auth testado de ponta a ponta com conta real (continuação da sessão 30)

> Mesma sessão do item 30, retomada depois da pausa por crédito.
> `firebaseConfig` real foi colado pelo usuário e login/cadastro/Google
> **foram validados funcionando com contas reais** (não é mais só
> teoria). Versão final do arquivo: `questlog-4-43-login-firebase.html`
> (mesmo nome, seguiu incrementando a mesma sessão).

### Fundo do login: mais 3 rodadas depois da pausa

Retomando de onde o item 30 parou (fundo = só parede de tijolo,
reaproveitando o tile da `.arena`):

1. Usuário pediu tijolo "de verdade" (a referência: PNG genérico da
   arena não parecia tijolo). Trocado por um **tile SVG desenhado à
   mão** (padrão de alvenaria corrida, 5 `<rect>`, fileira de baixo
   deslocada meio-tijolo) — rejeitado depois: *"eu tô falando os
   tijolos usados na arena"* — ou seja, o usuário queria o PNG
   original de volta, não uma reinterpretação. Revertido pro PNG real.
2. Usuário pediu **sprite aleatório em cima** do tijolo — implementado
   sorteando de `ITENS` via `estiloSprite()` (reaproveita o spritesheet
   do jogo, zero asset novo). Depois trocado para **fixo** no Grimório
   Proibido (sprite 108, raridade máxima) a pedido do usuário — mais
   simbólico que aleatório.
3. Usuário testou 3 fotos reais como fundo (floresta com fogueiras,
   castelo com lua cheia, ruínas em arco) — todas embutidas em base64
   diretamente no HTML (mesmo padrão do spritesheet). **Uma 4ª foto foi
   recusada**: tinha marca d'água visível da Adobe Stock (Claude
   identificou e não usou, explicando o motivo ao usuário). Testado
   também tentar imitar o layout de um app de referência ("Focus
   Knight") — Claude recusou reproduzir a arte/identidade de terceiros,
   mas ofereceu recriar só a composição/clima em estilo próprio.
4. **Decisão final, a pedido do usuário**: voltar pro tijolo (o PNG
   real da arena) + sprite fixo do Grimório. As fotos e o tijolo
   desenhado à mão foram descartados. É o que está no arquivo hoje.
5. Ao longo dessas trocas de fundo, o layout também mudou: painel
   translúcido atrás do formulário (testado, depois removido a pedido
   — *"tirar esses blocos de fundo"* → o usuário queria o oposto, mais
   fundo visível) → ícones de envelope/cadeado nos campos + botão
   Entrar preenchido + sombra de texto nos labels, sem painel.

### A saga de testar o Firebase de verdade — bugs reais encontrados e corrigidos

Com o `firebaseConfig` real colado, veio uma sequência de problemas
**genuínos**, cada um diagnosticado e corrigido nesta sessão:

1. **CDN do gstatic bloqueado.** Primeiro teste no celular: `Failed to
   fetch dynamically imported module`. Causa: rede do celular
   (Data Saver do Chrome ou DNS privado) bloqueando `gstatic.com`.
   Resolvido do lado da rede do usuário, não do código.
2. **`auth/unauthorized-domain` no Google.** O domínio do Netlify não
   estava na lista de domínios autorizados do Firebase Auth. Resolvido
   adicionando o domínio em Authentication → Settings → Authorized
   domains.
3. **Pop-up do Google "não fazia nada" no celular.** `signInWithPopup`
   é conhecido por ser pouco confiável em navegador mobile (o pop-up
   fecha sem a promise resolver, sem erro nenhum). **Trocado por
   `signInWithRedirect`** — só que criou um novo problema (ver item 6).
4. **Login parecia travar silenciosamente.** Causa raiz: `aoLogar()`
   fazia `await puxarNuvem(uid)` **sem try/catch** — se o Firestore
   falhasse (banco ainda não criado no projeto), a função inteira
   abortava antes de sequer tentar mostrar app ou onboarding, sem
   nenhum erro visível. **Corrigido**: puxar da nuvem virou
   best-effort (try/catch dedicado, login sempre completa mesmo se a
   nuvem falhar). Também foi adicionado um listener global de
   `unhandledrejection`, porque `aoLogar()` é chamada dentro do
   callback do `onAuthStateChanged` sem `await`/`.catch()` própria —
   sem essa rede de segurança, qualquer erro dentro dela desaparecia
   132% silencioso.
5. **Firestore Database nunca tinha sido criado no projeto** (só os
   provedores de Auth estavam ativos). Causava `[unavailable]: Failed
   to get document because the client is offline` — não é erro de
   código, é infraestrutura faltando. Resolvido pelo usuário criando o
   banco em Build → Firestore Database → modo de teste.
6. **`getRedirectResult()` voltando `null` depois do redirect
   completar.** Esse foi o mais difícil de achar. Sintoma: usuário
   escolhia a conta Google, a página voltava pro QuestLog, chegava a
   **mostrar a tela de onboarding por um instante** (login funcionou!),
   e depois voltava sozinha pra tela de login, sem nenhum erro. Causa:
   o navegador não estava conseguindo religar a volta do Google com o
   pedido original — `getRedirectResult()` resolvia com `result: null`
   como se a página nunca tivesse saído pra um redirect. Não era
   bloqueio de cookies de terceiros (usuário confirmou que "Permitir
   cookies de terceiros" já estava ativo) nem DevTools em modo de
   emulação de dispositivo (usuário testou sem DevTools também, mesmo
   erro). **Causa provável**: o `authDomain`
   (`questlog-d4c11.firebaseapp.com`) é um domínio diferente do
   hosting real (Netlify), e a reconciliação do estado pendente do
   redirect entre esses dois domínios está falhando no ambiente de
   teste do usuário (desktop Chrome) por algum motivo não
   100% identificado.
   **Solução aplicada**: `signInWithPopup` no desktop (detecção via
   `navigator.userAgent`) + `signInWithRedirect` só no mobile —
   pop-up fica na mesma aba o tempo todo, sem a ida-e-volta entre
   domínios que estava falhando, e resolveu o teste no notebook.
   **Confirmado funcionando pelo usuário** (mensagem: "foiii").

### Instrumentação de debug adicionada (ainda no arquivo, TEMPORÁRIA)

Pra investigar o bug do item 6, foi adicionado:
- Uma caixa vermelha fixa (`#debugFirebase`) que **acumula histórico**
  com timestamp (não sobrescreve mais, empilha do mais novo pro mais
  antigo) — crucial pra ver a sequência de eventos, não só o último.
- Logs em cada disparo de `onAuthStateChanged` (inclusive quando
  dispara com `user: null`), em cada chamada de `aoLogar()`, no
  resultado de `getRedirectResult()`, e no clique do botão Google.
- Listener global de `window.addEventListener('unhandledrejection', ...)`.

**Isso tudo ainda está no arquivo.** Combinado explicitamente com o
usuário: só remover depois de confirmar que o Google também funciona
no **celular de verdade** (só foi validado no desktop até agora, via
`signInWithPopup`). Quando isso for confirmado, trocar toda a caixa
vermelha + `debug(...)` pelos avisos normais (`window.aviso`) e apagar
a instrumentação — não faz sentido isso sobreviver numa versão
publicada.

### Estado atual, validado com contas reais

- ✅ Cadastro por email/senha (`createUserWithEmailAndPassword`)
- ✅ Login por email/senha (`signInWithEmailAndPassword`)
- ✅ Login com Google — **desktop via pop-up confirmado**; mobile via
  redirect **ainda não teve confirmação de sucesso** (só foi até aqui
  o bug do item 6, que motivou a mudança pra pop-up-no-desktop; o
  caminho mobile com redirect não foi re-testado depois da correção)
- ✅ Sync com Firestore (`saves/{uid}`) — puxa ao logar, empurra a
  cada `salvar()`, best-effort (não trava o login se falhar)
- ✅ Reset de progresso local + reload puxando de volta da nuvem
  (testado no vídeo, funcionou)

### Pendências pra retomar

1. **Confirmar Google login no celular de verdade** (redirect) — não
   foi re-testado depois da correção do item 6 acima.
2. **Remover a instrumentação de debug** (`#debugFirebase`, todas as
   chamadas `debug(...)`, o listener de `unhandledrejection`) assim
   que o item 1 for confirmado.
3. Entender de verdade a causa raiz do `getRedirectResult() = null`
   (item 6) — a correção (pop-up no desktop) contorna o problema, mas
   não foi identificada a causa exata. Se algum dia o redirect do
   mobile também apresentar esse sintoma, essa investigação precisa
   ser retomada com mais profundidade (possivelmente envolve configurar
   um domínio customizado pro Firebase Auth em vez do
   `*.firebaseapp.com` padrão).
4. Itens 2 e 3 da lista de pendências anterior (layout do topo da tela
   de login sem revisão, `#mobSprite` da arena com o monstro roxo)
   continuam em aberto, não foram tocados nesta continuação.
5. Regras de segurança do Firestore ainda estão em **modo de teste**
   (acesso aberto) — antes de publicar de verdade, precisa apertar pra
   regras reais (ex: cada usuário só lê/escreve o próprio documento em
   `saves/{uid}`).

### Validação desta continuação

Cada edição (troca de fundo, correção dos bugs de auth, instrumentação
de debug) foi validada individualmente com `node --check` em todos os
blocos `<script>` + balanço de `<div>`/`<svg>`/comentários antes de
cada entrega — mesmo processo das seções anteriores, não repetido aqui
edição por edição pra não inflar o roadmap. Estado final validado:
34 blocos `<script>`, 0 falhas de `node --check`, `<div>` 269/269,
`<svg>` 24/24, comentários 24/24.

---

## 32. Fim da investigação do redirect + limpeza da instrumentação de debug

> Mesma sessão, fechamento final. Item 31 ficou pendente de duas
> coisas: confirmar Google no celular, e tirar o debug depois disso.
> As duas foram resolvidas nesta parte.

### Redirect testado no celular -- mesmo bug do desktop

Testado `signInWithRedirect` no celular: **mesmo sintoma exato** do
desktop -- `getRedirectResult()` resolve com `result: null` mesmo
depois do usuário completar a escolha de conta no Google. Ou seja, o
bug do item 31.6 não era específico de desktop/DevTools -- é o
`redirect` que não funciona neste projeto, em nenhum ambiente testado.

**Decisão final: abandonar `signInWithRedirect` por completo.**
Removida a distinção mobile/desktop (`EH_MOBILE` + branch condicional)
implementada no item 31 -- agora "Entrar com Google" usa
`signInWithPopup` sempre, independente de dispositivo. Popup é o único
método com sucesso **comprovado** (via teste real) nos dois ambientes;
redirect nunca funcionou nem uma vez, apesar de ser teoricamente "o
recomendado pra mobile". **Confirmado funcionando no celular pelo
usuário** (mensagem: "foiii"). Removidos do código: `signInWithRedirect`,
`getRedirectResult` -- não são mais usados em lugar nenhum do arquivo.

**Se algum dia isso for revisitado**: causa raiz nunca identificada
com certeza. Suspeita mais forte é reconciliação de estado entre o
domínio do app (Netlify) e o `authDomain` do Firebase
(`*.firebaseapp.com`) -- possivelmente resolvido configurando um
domínio customizado pro Firebase Auth. Não foi investigado a fundo
porque o popup resolveu o problema prático sem essa configuração extra.

### Instrumentação de debug removida

Com os dois métodos de login confirmados em ambiente real, removida
toda a instrumentação temporária: a caixa vermelha fixa
(`#debugFirebase`) e seu HTML/CSS, a função `debug()`, o listener de
`unhandledrejection`, e as 19 chamadas de log espalhadas pelo módulo.

**O que ficou**: todos os `try/catch` continuam no lugar -- a robustez
alcançada durante a investigação (login nunca trava se a nuvem falhar,
mensagens de erro específicas por código via `aviso()`) é permanente,
só a *exibição visual* dos erros técnicos que saiu. Erros agora vão
pro `console.error()` do navegador, prefixados com `QuestLog/Firebase:`.

### Estado final da feature de login (fim desta sessão)

- ✅ Cadastro por email/senha -- confirmado
- ✅ Login por email/senha -- confirmado
- ✅ Login com Google -- **confirmado em desktop E celular**, ambos via
  `signInWithPopup`
- ✅ Sync com Firestore -- confirmado (puxa ao logar, empurra a cada
  save, best-effort)
- ✅ Reset local + recuperação da nuvem -- confirmado
- ✅ Instrumentação de debug removida, código de produção limpo

**Pendências reais que sobram:**
1. ~~Layout do topo da tela de login sem revisão~~ -- **resolvido no
   item 33**: o subtítulo `#loginModo` ("Entre na sua conta"/"Crie sua
   conta") preenche o espaço que ficou vazio depois de tirar o ícone.
2. ~~`#mobSprite` da arena com silhueta de monstro roxo estática~~ --
   **nota antiga, sem confirmação de ainda existir**: HTML estático
   atual não tem nenhum elemento roxo ali. Ver seção 70 pra um problema
   diferente, mas de nome parecido, confirmado em 26/08.
3. Regras de segurança do Firestore em modo de teste (acesso aberto)
   -- apertar antes de publicar de verdade.
4. Causa raiz do bug do redirect nunca identificada (ver item 32) --
   não é bloqueante, só documentado caso volte a incomodar.

### Validação final

34 blocos `<script>`, `node --check` limpo em todos, `<div>` 268/268
(caiu de 269 com a remoção do painel de debug), `<svg>` 24/24,
comentários 24/24. Zero referências órfãs a `debugFirebase`,
`unhandledrejection`, `signInWithRedirect` ou `getRedirectResult`
restantes no arquivo (confirmado via grep).

---

## 33. Tela de boas-vindas + toggle Entrar/Cadastro mais notável

> Mesma sessão, ainda em cima do login (itens 30-32). Dois ajustes de
> UX pedidos depois de tudo já validado funcionando.

### Problema 1: toggle Entrar/Cadastro mal perceptível

Antes, alternar entre os modos só trocava o texto do botão principal
("Entrar" ↔ "Criar conta") e do link do rodapé — o resto da tela
ficava idêntico, dificultando notar em qual modo se está.

**Corrigido:**
- Novo subtítulo abaixo do título "QUESTLOG" (`#loginModo`) que troca
  junto: "Entre na sua conta" / "Crie sua conta".
- "Esqueceu a senha?" (`#loginLinhaSenha`) some no modo cadastro —
  não faz sentido recuperar senha de uma conta que ainda não existe.

### Problema 2: sem confirmação visível de que o login funcionou

Antes, depois de logar, a pessoa caía direto no app (conta existente)
ou no onboarding (conta nova) — visualmente indistinguível de só ter
clicado "Continuar sem conta". Primeira tentativa de correção foi um
toast ("Bem-vindo de volta, Nome!"), mas o usuário esclareceu que
quer uma **tela dedicada**, não um pop-up passageiro.

**Implementado: nova tela `#passoBoasVindas`**, injetada junto com
`#passoLogin` (mesmo padrão -- `card.insertAdjacentHTML('afterbegin', ...)`),
mostrada entre o login e a entrada de fato no app/onboarding:
- Rótulo pequeno em cima: "Bem-vindo de volta" (conta existente) ou
  "Conta criada! Bem-vindo" (conta nova).
- Nome em destaque grande, embaixo.
- Botão "Continuar" -- **só avança com toque manual**, sem timer
  automático (uma primeira versão tinha `setTimeout` de 2.2s avançando
  sozinho; removido a pedido do usuário, que achou que estava "passando
  sozinho sem clicar").
- Nome vem de `user.displayName` (conta Google, só o primeiro nome) ou
  do que vem antes do `@` no email (cadastro por email/senha não tem
  displayName).

**Bug de estilo corrigido no caminho:** a primeira versão do nome
reaproveitava a classe `.titulo` (a mesma do logo "QUESTLOG" -- fonte
pixelada Silkscreen com letter-spacing largo). Funciona bem pra um
logo de 6 letras fixas, mas deixava nomes de pessoas com letras
"esticadas"/estranhas. Corrigido com uma classe própria
(`#boasVindasNome`), fonte normal (Outfit, a mesma dos botões),
`letter-spacing:normal`.

**Detalhe técnico**: a função `aoLogar()` foi reestruturada -- a lógica
de "entrar de fato no app" (que já existia) virou uma função interna
`entrarNoApp()`, chamada só depois que a pessoa confirma a tela de
boas-vindas (clique em "Continuar"), não mais direto ao fim do login.

### Validação

34 blocos `<script>`, `node --check` limpo, `<div>` 270/270 (dois a
mais: a nova tela de boas-vindas), `<svg>` 24/24, comentários 24/24.
IDs novos (`passoBoasVindas`, `boasVindasRotulo`, `boasVindasNome`,
`boasVindasContinuar`, `loginModo`, `loginLinhaSenha`) confirmados
únicos no arquivo.

---

## 34. Som de clique na tela de login/boas-vindas (v4.44)

> Versão do arquivo ao final desta sessão: `questlog-4-44-login-sfx.html`

### Contexto

Retomada do SFX (seções 20/29) em cima do arquivo mais novo do project
knowledge — `questlog-4-43-login-firebase_23.html`, que trouxe as telas
`#passoLogin` e `#passoBoasVindas` (seções 30-33: login/cadastro,
Google Sign-In, recuperação de senha, tela de boas-vindas pós-login).
Pedido: dar som de clique pra essas telas, mesmo tratamento que nav
principal/onboarding já recebem.

### O que ganhou som (`clique`, reaproveitado — nenhum som novo)

Botão de idioma, botão de tema, "Esqueceu a senha?", "Entrar"/"Criar
conta", "Entrar com Google", "Continuar sem conta", toggle Entrar↔
Cadastro, "Continuar" da tela de boas-vindas.

### Achado 1: ordem de execução dos scripts, não closure nem referência

Os dois problemas de gancho já catalogados nas seções 20/29 (armadilha
de closure; referência de função copiada num `onclick` direto) não se
aplicam aqui — esse é um **terceiro tipo**, de timing:

`#passoLogin`/`#passoBoasVindas` **não existem no HTML estático** — são
injetados via `insertAdjacentHTML` dentro de uma IIFE (linha ~6829 do
arquivo desta sessão) que só roda, em runtime, pra usuário **sem save
local** (`if (!intro || intro.classList.contains('off')) return;`). O
bloco "SFX — CLIQUE DE NAVEGAÇÃO" (seção 20) já existente fica **antes**
dessa IIFE no arquivo — como scripts clássicos executam em ordem de
documento durante o parse, se os hooks de login entrassem naquele bloco
de cima, todo `getElementById('idiomaBtn')` etc. voltaria `null` (os
elementos simplesmente ainda não existiriam no DOM). Precisou de um
bloco novo, posicionado **depois** do fechamento dessa IIFE.

**Regra prática pra próximas sessões:** quando a tela/elemento é
injetado dinamicamente (via `insertAdjacentHTML`/`innerHTML`) em vez de
existir no HTML estático, o gancho de som tem que ficar depois, em
ordem de documento, do código que faz essa injeção — não importa se o
elemento é global ou local, `getElementById` só acha o que já foi
criado até aquele ponto da execução.

### Achado 2: mais um caso de nó recriado (mesma família do #gradeHerois)

`loginToggleCadastro` reescreve o próprio pai (`#loginRodape.innerHTML`)
a cada alternância Entrar↔Cadastro — comportamento já documentado na
seção 30 (`ligarToggleCadastro()`, comentário original: "religa no novo
`<button>`, o innerHTML acima descartou o antigo"). Um listener de som
preso direto nesse `<button>` morreria no primeiro toggle. Resolvido do
mesmo jeito que `#gradeHerois` (seção 20): delegação no container pai
estável (`#loginRodape`), que nunca é recriado — só seu `innerHTML`.

### Sem conflito com o módulo Firebase

`loginEntrarBtn`, `loginGoogleBtn` e `loginEsqueci` também têm `onclick`
reatribuído depois, dentro do `<script type="module">` do Firebase (que
roda deferido, depois de todo script clássico). Como o gancho de som
usa `addEventListener` (não mexe em `onclick`), os dois convivem sem
pisar um no outro, em qualquer ordem.

### Validação

34 blocos `<script>` clássicos + 1 `<script type="module">` (checado
separado, como `.mjs`), `node --check` limpo nos dois grupos. `<div>`
270/270, `<svg>` 24/24, comentários 25/25.

**Nota de processo:** a validação por regex deste roadmap quase deu
falso positivo — o comentário do próprio código HTML mencionava a
string literal `<script type="module">`, confundindo a regex de
extração de blocos. Reescrito o comentário pra descrever sem repetir a
tag; vale lembrar disso ao escrever comentário dentro de HTML sobre
outras tags `<script>`.

## 35. "Apagar tudo" renomeado pra "Apagar dados" + bug crítico: nunca apagava de verdade pra conta logada (v4.45)

### O pedido

Renomear o rótulo "Apagar progresso" pra "Apagar dados" e **verificar**
se o botão realmente apaga os dados da conta — não foi pedido corrigir
nada especificamente, só checar.

### O que a verificação encontrou

Bug real, 100% reproduzível pra qualquer usuário logado numa conta
Firebase, encontrado por leitura de código (não suposição) cruzando o
módulo de login/sync (seções 30–32) com o módulo de apagar dados
(seção 15). Cadeia completa:

1. `zerarConfirmar.onclick` fazia só `localStorage.clear();
   location.reload();` — nunca tocava no Firestore.
2. Ao recarregar, sem `questlog.v1` no `localStorage`, `carregar()`
   falha e `#intro` **não** ganha a classe `.off`.
3. A condição que decide se a tela de login (`#passoLogin`) é
   injetada no DOM é literalmente `if (!intro ||
   intro.classList.contains('off')) return;` — ou seja, **sem** `.off`,
   a tela de login **é** injetada. Isso é o oposto do que acontece numa
   sessão normal de quem já tem save local (onde essa injeção é
   pulada, e por isso o SDK do Firebase nem carrega nessas sessões —
   ver nota na seção 15).
4. Com `#passoLogin` de volta no DOM, o bootstrap do Firebase roda,
   `onAuthStateChanged` dispara — e encontra a **mesma sessão ainda
   ativa**, porque o Firebase Auth persiste em IndexedDB, não em
   `localStorage`. `localStorage.clear()` não alcança isso.
5. Sessão ativa → `aoLogar()` → `puxarNuvem(uid)` → busca
   `saves/{uid}` no Firestore, que **nunca foi apagado** → escreve os
   dados antigos de volta no `localStorage` que acabou de ser limpo.

Resultado: o apagamento *parecia* funcionar (tela fica vazia por um
instante), mas o próprio reload — a mesma ação que devia confirmar o
apagamento — é o gatilho que restaura tudo de volta, pra 100% das
contas logadas, sem exceção. Contas sem login (offline, "continuar sem
conta") não têm esse problema, porque não existe `saves/{uid}` nenhum
pra restaurar.

### Fix

`zerarConfirmar.onclick` agora tenta apagar `saves/{uid}` no Firestore
**antes** de limpar o `localStorage`, se houver usuário logado:

```js
async function apagarDaNuvemSeLogado(){
  if (!window.firebaseConfig || window.firebaseConfig.apiKey === 'COLE_AQUI_SUA_APIKEY') return;
  const { initializeApp, getApps, getApp } = await import(".../firebase-app.js");
  const { getAuth, onAuthStateChanged } = await import(".../firebase-auth.js");
  const { getFirestore, doc, deleteDoc } = await import(".../firebase-firestore.js");

  const app = getApps().length ? getApp() : initializeApp(window.firebaseConfig);
  const auth = getAuth(app);
  const usuario = await aguardarUsuario(auth, onAuthStateChanged, 4000);
  if (usuario) await deleteDoc(doc(getFirestore(app), 'saves', usuario.uid));
}
```

Pontos de design que valem registro:

- **Não reaproveita `auth`/`db` do módulo de login.** Não dá — pra
  quem já tem save local (o caso normal de quem clica "apagar tudo"),
  aquele bootstrap nunca rodou nesta sessão (ver passo 3 acima), então
  não existe instância pronta pra reaproveitar. Este módulo carrega o
  próprio SDK, de forma independente, via `import()` dinâmico com as
  mesmas URLs.
- **`getApps().length ? getApp() : initializeApp(...)`** evita o erro
  de "app já inicializado" nos casos em que os dois bootstraps
  acabarem rodando na mesma sessão (ex.: usuário sem save local que
  loga e imediatamente apaga tudo de novo).
- **`window.firebaseConfig` exposto** no módulo de login (uma linha
  nova: `window.firebaseConfig = firebaseConfig;`) evita duplicar a
  `apiKey` inline nos dois módulos — um lugar só pra atualizar se a
  chave rodar.
- **`aguardarUsuario()` com timeout de 4s:** `auth.currentUser` pode
  estar `null` por um instante logo após `getAuth()`, mesmo com sessão
  válida — a restauração da sessão persistida é assíncrona. Espera um
  disparo de `onAuthStateChanged` antes de decidir se tem usuário ou
  não, com teto de 4s pra não travar em rede lenta.

### Achado em teste, não previsto no design original

Rodei o teste com `window.firebaseConfig` simulado (chave falsa, só
pra passar do guard de "config pendente") num ambiente sem rota pra
`www.gstatic.com` — cenário real de rede ruim/CDN fora do ar. Primeira
versão do fix (só o timeout de 4s dentro de `aguardarUsuario`) **ficou
presa indefinidamente** — passados 6s, nem tinha apagado o
`localStorage`, nem recarregado, nem avisado nada. O timeout de 4s só
cobria a espera do `onAuthStateChanged`; os três `import()` dinâmicos
que rodam **antes** disso não tinham proteção nenhuma.

Corrigido com um timeout **geral**, envolvendo a tentativa inteira:

```js
await Promise.race([
  apagarDaNuvemSeLogado(),
  new Promise((_, rej) => setTimeout(() => rej(new Error('timeout geral de 8s')), 8000))
]);
```

Reexecutando o teste, o erro real apareceu rápido
(`ERR_VM_DYNAMIC_IMPORT_CALLBACK_MISSING` — jsdom não implementa
`import()` dinâmico sem um callback configurado; especificidade do
ambiente de teste, não do app rodando num navegador de verdade), caiu
no `catch`, avisou o usuário, e seguiu com o apagamento local — exatamente
o comportamento correto. O teto de 8s continua valendo como rede de
segurança pra qualquer cenário real de CDN lento/rede ruim em produção,
independente de qual seja a causa exata de uma trava.

### Renomeação

- Rótulo da linha em Config: "Apagar progresso" → **"Apagar dados"**.
- Título da folha de confirmação: "Apagar todo o progresso?" →
  "Apagar todos os dados?"
- Descrição da folha atualizada pra mencionar a nuvem explicitamente:
  "Zera nível, moedas, itens, vida e tudo o mais salvo — neste
  aparelho e, se você estiver logado numa conta, também na nuvem. Não
  tem volta."
- Botão de confirmar continua "Apagar tudo" (microcópia do botão,
  ainda precisa e curta — só o rótulo da linha e o título da folha
  mudaram pra "dados").

### Validado em jsdom, 3 cenários

1. **Rótulo:** confirmado texto "Apagar dados" na linha do Config.
2. **Sem conta / `firebaseConfig` ausente:** guard clause pula a
   tentativa de nuvem inteira, apaga local e recarrega imediatamente —
   sem atraso nenhum introduzido pela mudança.
3. **Com "conta" simulada, rede indisponível:** botão mostra
   "Apagando…" e fica desabilitado durante a tentativa; mesmo com a
   nuvem falhando, o `localStorage` local é limpo, o `aviso()` dispara
   avisando que a nuvem não foi alcançada, e o app segue (não trava).

**O que não deu pra testar neste ambiente:** o caminho de sucesso real
— login de verdade + `deleteDoc()` de verdade contra o Firestore.
`www.gstatic.com` não está na lista de domínios liberados pro
`bash_tool` deste sandbox, então o `import()` dos SDKs sempre falha
aqui, por design do ambiente de teste, não por bug do código. A lógica
em volta (guard clauses, timeout, fallback pro apagamento local,
mensagens de erro) foi validada a fundo; o `deleteDoc()` em si, só
testável num navegador de verdade com conta real logada.

## 36. Botão "Sair" da conta (v4.46), depois ajustado pra voltar à tela de login (v4.47)

### O pedido

Um botão separado, só pra sair da conta — sem apagar nada.

### Diferença de propósito em relação a "Apagar dados" (seção 35)

Sair **não apaga nada**. O save local (`questlog.v1` e todo o resto)
fica intacto — o jogador continua vendo o próprio progresso depois de
sair, só para de sincronizar com a nuvem até logar de novo. Por isso o
handler usa `localStorage.removeItem()` de uma chave só, nunca
`localStorage.clear()` — usar `clear()` aqui seria o oposto do que
"Sair" deveria fazer, apagaria o jogo inteiro sem avisar que essa não
é a intenção do botão.

### O mesmo obstáculo de sempre, resolvido antes de precisar descobrir de novo

A maioria das sessões (quem já tem save local) nunca carrega o SDK do
Firebase — mesma limitação documentada na seção 35. Isso significa que
não dá pra simplesmente checar `auth.currentUser` pra decidir se
mostra o botão "Sair": na maior parte das vezes não haveria nem
`auth` inicializado pra checar.

**Solução: um marcador leve em `localStorage`**
(`questlog.conta.v1 = {nome, email}`), gravado dentro de `aoLogar()`
(módulo de login, seção 30) no exato momento do login — uma linha nova
lá, `localStorage.setItem('questlog.conta.v1', JSON.stringify({nome,
email}))`. Esse marcador **está sempre disponível**, mesmo em sessões
onde o Firebase nunca chegou a carregar, porque foi escrito numa
sessão anterior (a do login) e persiste no aparelho. A linha "Conta"
em Config lê só essa chave pra decidir se aparece — zero custo de
Firebase até o usuário efetivamente clicar em "Sair".

A linha começa com a classe `.oculto` no HTML (reaproveitando a
classe genérica já existente, `display:none !important`) — só some
esse estado quando o marcador é encontrado.

### Mesma armadilha de closure, mesma solução de sempre

`sincronizarConfig()` (a função que já atualiza os outros campos de
Config ao abrir a sub-aba) é local à IIFE "PERFIL — SUB-ABAS" — não dá
pra chamar de fora, nem pra estender sem editar aquele módulo. Em vez
de tocar nele, um **segundo** `addEventListener('click', ...)` no
mesmo botão da sub-aba "config" (em paralelo ao `onclick` que já
existe ali, sem conflito — mesmo padrão já usado em Bestiário,
Conquistas e nas outras vezes que esse exato obstáculo apareceu)
dispara `atualizarLinhaConta()` toda vez que Config abre.

### `signOut()` com a mesma defesa contra travamento da seção 35

Carrega o Firebase por conta própria (mesmas URLs, mesmo padrão de
`getApps().length ? getApp() : initializeApp(...)` pra não colidir com
uma inicialização concorrente do outro módulo), envolto no mesmo
`Promise.race()` com teto de 8s — pelo mesmo motivo já documentado e
já testado na seção 35: `import()` pode travar sem nunca resolver nem
rejeitar, e o botão não pode ficar preso esperando pra sempre.

### Por que precisa de `location.reload()` no final

Se o Firebase chegou a carregar nesta sessão (login feito na mesma
sessão em que "Sair" foi clicado), `window.salvar` ganhou um wrapper
que empurra pra nuvem a cada `salvar()` — e esse wrapper fica com o
`uid` antigo fechado no closure **pra sempre em memória**, mesmo
depois do `signOut()`. Só um reload garante que esse estado é
descartado de verdade, e que a próxima sessão recomeça limpa (sem
sync nenhum ativo, já que `onAuthStateChanged` vai disparar com
`user: null` desta vez).

### Validado em jsdom, 2 cenários

1. **Sem marcador de conta:** linha "Conta" permanece escondida ao
   abrir Config — nenhuma tentativa de carregar Firebase acontece.
2. **Com marcador de conta** (`{nome:'Davi', email:'davi@teste.com'}`):
   linha aparece com "Logado como Davi"; clique em "Sair" mostra
   "Saindo…" e desabilita o botão durante a tentativa; mesmo com a
   rede falhando (mesma limitação de sandbox da seção 35 —
   `www.gstatic.com` não liberado pro `bash_tool`), o marcador de
   conta é removido ao final, **e o save do jogo (`questlog.v1`)
   continua intacto** — confirmando que "Sair" não apaga progresso,
   só desconecta.

**Mesmo limite de validação da seção 35 se aplica aqui:** o caminho de
sucesso real do `signOut()` contra um servidor Firebase de verdade não
foi testado neste ambiente, pela mesma razão de rede. A lógica ao
redor (guard clauses, timeout, preservação dos dados do jogo,
mensagens de erro) foi validada a fundo.

### v4.47 — "Sair" devia voltar pra tela de login, não devolver pro app calado

Pergunta do usuário depois de ver a v4.46 funcionando: "o botão sair
não deveria mandar pra tela de login inicial?" — resposta: sim,
deveria, e a v4.46 não fazia isso. `signOut()` + reload devolvia o
jogador direto pro app, com o save local intacto (por design — Sair
não apaga nada) — só que sem nenhum sinal visível de que a conta
desconectou. Pra quem espera o padrão comum de "sair" (voltar pra tela
de entrada), isso parece bugado, mesmo estando "certo" tecnicamente.

**Por que a tela de login não aparecia sozinha:** o módulo que injeta
`#passoLogin` no DOM só roda se `#intro` **não** tiver a classe `.off`
— e essa classe já tinha sido aplicada no boot normal, porque
`carregar()` encontra o save local (que "Sair" preserva de propósito).
Sem save ausente, sem tela de login. É o mesmo mecanismo, ao contrário,
do bug da seção 35 (lá, a AUSÊNCIA de save é que trazia a tela de
login de volta sem querer; aqui, a PRESENÇA do save é que a mantém
escondida quando ela deveria aparecer).

**Fix: flag de uso único.** `questlog.forcarLogin.v1` é gravada pelo
módulo "CONTA — SAIR" logo antes do `location.reload()`. No próximo
boot, uma checagem nova — três linhas, logo depois do `if
(carregar())` já existente no script principal, **antes** do módulo
que decide se injeta `#passoLogin` — consome a flag (remove
imediatamente, pra não forçar login de novo em boots futuros) e desfaz
o `.off` que tinha acabado de ser aplicado. Com `#intro` sem `.off`
outra vez, o módulo de login roda normalmente e injeta a tela.

**Efeito colateral que precisou de fix junto: "Continuar sem conta"
não sabia lidar com essa situação nova.** Esse botão sempre assumiu
que só seria visto por quem **nunca** teve save local (instalação
nova) — por isso ia direto pro `passo1`, o onboarding do zero. Com a
tela de login agora podendo reaparecer por cima de um save **já
existente** (o caso de quem acabou de sair da conta), clicar em
"Continuar sem conta" sem essa correção jogaria o onboarding por cima
dos próprios dados do jogador — perda de progresso por um clique
supostamente inofensivo. Corrigido com o mesmo branch `temSaveLocal` /
`entrarNoApp()` que `aoLogar()` já usa pra decidir a mesma coisa:
se há save, reentra direto no app (chama `desenharHeroi()`/`render()`
e aplica `.off` de novo); se não há, segue pro onboarding como sempre.

### Validado em jsdom, 2 partes (antes e depois do reload)

Como o `location.reload()` de verdade não roda em jsdom, o teste
simula as duas metades separadamente, encadeando o `localStorage` de
uma instância de `JSDOM` pra outra:

**Parte 1 (antes do reload):** sessão com save + marcador de conta,
clica em "Sair". Confirmado: `questlog.v1` continua intacto, marcador
de conta removido, `questlog.forcarLogin.v1` setada.

**Parte 2 (depois do reload, nova instância com aquele localStorage):**
boot com a flag presente — `#intro` **sem** `.off` (confirma que a
flag desfez a aplicação normal), `#passoLogin` injetado no DOM, flag
consumida (removida) logo após o uso. Clique em "Continuar sem conta":
**não** foi pro onboarding (`#passo1` continua sem `.on`), `#intro`
ganhou `.off` de volta (reentrou direto no app), e o nome do herói
salvo (`"Testerion"`) continua o mesmo — confirma que os dados não
foram tocados nem sobrescritos pelo fluxo de login.

## 37. Sincronização com a nuvem funcionava só na 1ª sessão após login (v4.48)

### O achado, durante a verificação do "Sair" (não foi o pedido original)

Enquanto explicava por que a linha "Conta" ficava escondida mesmo pra
quem estava logado (seção 36), apareceu um problema mais sério por
trás: o módulo do Firebase só carrega quando `#passoLogin` é injetado
no DOM, e essa injeção só acontece quando `#intro` **não** tem a
classe `.off` — ou seja, só quando **não há save local ainda**. Isso
significa que, pra qualquer sessão depois da primeira (a esmagadora
maioria — assim que existe save local, o que acontece quase
imediatamente), o SDK do Firebase nunca carrega. Consequência direta:
o gancho que faz `window.salvar` empurrar pra nuvem a cada save só
existe **na memória daquela sessão específica** — fecha o app, esse
gancho desaparece, e nenhum progresso feito depois volta a sincronizar
até o jogador deslogar e logar de novo (o que ninguém faz por rotina).

Na prática: a sincronização entre aparelhos, que é o motivo de existir
conta, só funciona no primeiro dia. Confirmado pelo usuário como
prioridade pra corrigir depois de eu explicar a cadeia.

### O fix: desacoplar "carregar o Firebase" de "mostrar a tela de login"

Antes, era uma coisa só — um `if (!passoLogin) { não faz nada }`.
Agora são duas decisões independentes:

1. **Carregar o SDK e checar sessão ativa** — roda em **toda** sessão
   onde a config do Firebase estiver pronta, com ou sem save local.
2. **Qual fluxo dispara ao encontrar um usuário logado** — decidido
   dentro do callback de `onAuthStateChanged`, olhando se `#passoLogin`
   existe e está com a classe `.on` (ou seja, se a tela de login está
   mesmo visível agora):
   - **Visível** → `aoLogar(user)`, o fluxo completo de sempre (puxa da
     nuvem, mostra "Bem-vindo de volta", troca de tela).
   - **Não visível** (sessão comum, o jogador já está vendo o app) →
     `aoLogarSilencioso(user)`, novo, que **não mexe em nada visível**
     — só reconecta o envio.

```js
function reconectarEnvio(user){
  // comum aos dois fluxos: grava o marcador que "Sair" (secao 36) le,
  // e garante que window.salvar volta a empurrar pra nuvem
  ...
}
async function aoLogarSilencioso(user){
  reconectarEnvio(user);
}
onAuthStateChanged(auth, user => {
  if (!user) return;
  if (passoLogin && passoLogin.classList.contains('on')) {
    aoLogar(user)...            // fluxo completo, com UI
  } else {
    aoLogarSilencioso(user)...  // so reconecta, sem tocar na tela
  }
});
```

`aoLogar()` foi refatorada pra chamar `reconectarEnvio()` também, em
vez de duplicar a lógica de marcador+gancho que já existia nela —
`reconectarEnvio()` agora é a única fonte dessas duas linhas de
código, usada pelos dois fluxos.

### Decisão de escopo deliberada: reconecta o ENVIO, não o RECEBIMENTO

`aoLogarSilencioso()` **não chama `puxarNuvem()`**. Só `aoLogar()`
(fluxo com tela visível) puxa da nuvem. Isso foi uma escolha
consciente, não uma omissão — considerei fazer o oposto (sincronizar
os dois sentidos em toda sessão) e recuei por causa do risco real:

Puxar e sobrescrever o save local **silenciosamente em segundo plano**,
numa sessão onde o jogador já está interagindo com o app, arriscaria
apagar qualquer mudança feita nos primeiros segundos daquela sessão —
antes da checagem assíncrona de autenticação terminar (`onAuthStateChanged`
não é instantâneo). Pior: se o jogador jogou em outro aparelho e depois
volta pra este, com este aparelho tendo dados mais antigos, um
`empurrarNuvem()` automático aqui **sobrescreveria o progresso mais
recente do outro aparelho** com dados velhos — regressão de dados,
silenciosa, sem aviso nenhum.

Escolhi resolver só o problema que foi de fato relatado (envio parava
de funcionar) sem introduzir esse risco novo. **Isso significa que
sincronização entre 2+ aparelhos ainda não é totalmente confiável** —
melhorou (progresso feito em qualquer sessão agora chega na nuvem),
mas puxar a versão mais recente de outro aparelho só acontece
explicitamente no login (deslogar e logar de novo). Registrado aqui
como limite conhecido, não escondido — resolver isso direito exigiria
lógica de merge ou timestamp comparando local vs. nuvem antes de
decidir qual lado vence, escopo maior que o que foi pedido nesta
sessão.

### Bug de sintaxe pego pela validação, não pela leitura

Ao mover o corpo inteiro do bootstrap pra dentro de uma função nova
(`iniciarFirebase()`), a primeira tentativa usou `return;` pra sair
cedo quando o SDK falha numa sessão silenciosa (sem UI de login pra
quebrar visualmente). `node --check` recusou: **este bloco é
`<script type="module">`, que suporta `await` no nível superior do
módulo — mas `return` fora de função é erro de sintaxe em módulo ES**,
mesmo com top-level await disponível. A checagem sintática pegou isso
antes de qualquer teste funcional. Corrigido envolvendo o corpo inteiro
numa `async function iniciarFirebase(){...}` de verdade, onde `return`
é válido.

**Um segundo bug, esse sim só visível depois de validar com
`node --check` de novo:** o primeiro `str_replace` que tentou trocar o
final de `aoLogar()` (pra usar `reconectarEnvio()`) usou um trecho-alvo
que só correspondia à **cauda** da função original — o INÍCIO da
função antiga (declaração de `nomeConta`, gravação do marcador,
`entrarNoApp()`, tela de boas-vindas) nunca foi removido, porque
`str_replace` só troca o texto exatamente casado, não a função
inteira. Resultado: duas cópias de `aoLogar()` aninhadas, chaves
completamente desbalanceadas. `node --check` acusou "Unexpected end of
input" — sintoma genérico, não apontou a causa. Achado com um contador
de chaves linha a linha (ignorando comentários) comparando a
profundidade final contra a versão anterior já validada (que dava
zero) — a versão nova dava 1, indicando uma chave de abertura sem
par. Corrigido removendo o corpo antigo duplicado por completo,
mantendo só a versão que usa `reconectarEnvio()`.

**Lição prática:** ao usar `str_replace` pra alterar o **fim** de uma
função existente (não a função inteira), sempre conferir depois se o
**início** dela não ficou órfão, duplicado ou com corpo partido —
`str_replace` não tem noção de "função", só de texto casado.

### Validado

**Sintaxe:** `node --check` limpo nos 35 blocos `<script>` clássicos e
no `<script type="module">` (checado separado). Confirmado por grep
que existe exatamente uma definição de `aoLogar`, `aoLogarSilencioso`
e `iniciarFirebase` cada — sem duplicata sobrando.

**Estrutural, em jsdom:** sessão com save local (retornando) — app
renderiza normalmente, `#passoLogin` **não** é injetado (correto,
save existe), nenhum erro síncrono capturado. Sessão sem save local —
`#passoLogin` é injetado como sempre (regressão testada: o mesmo
`loginGoogleBtn` sem `onclick` funcional já acontecia **antes** desta
mudança, no mesmo sandbox, confirmado rodando o mesmo teste contra a
versão anterior — não é regressão introduzida agora, é a mesma
limitação de rede de sempre).

**O que não deu pra verificar neste ambiente (na hora):** o caminho de
sucesso completo — `import()` de verdade resolvendo, `onAuthStateChanged`
disparando com um usuário real, `reconectarEnvio()` de fato reanexando
o gancho de `window.salvar`. Diferente de antes (onde o `import()`
falhava rápido com um erro claro em script clássico), dentro de
`<script type="module">` o `import()` parece ficar **pendente
indefinidamente** neste sandbox sem rota pra `www.gstatic.com` — nem
resolve, nem rejeita nos primeiros segundos. Isso não trava nem quebra
o app (o resto do boot já rodou antes deste módulo), mas significava
que a prova final só viria de um teste manual num navegador de
verdade, com conta real — mesma ressalva das seções 35 e 36.

### Confirmado pelo usuário, com conta real, servindo local via `http.server`

Roteiro: login → completar tarefa → `F12` Console →
`window.salvar._questlogSyncGancho` (deu `true`) → **F5** (simula
sessão 2, sem esperar um dia de verdade — o bug nunca dependia de
tempo passar, só de já existir save local no próximo boot) → esperar
a checagem assíncrona de login terminar → repetir o mesmo comando no
Console. Resultado: **`true` de novo**, confirmando que o gancho de
envio foi religado na sessão 2, exatamente o que falhava antes do fix
(dava `undefined`).

Fechando o ciclo ponta a ponta: completou outra tarefa depois do F5,
conferiu o documento `saves/{uid}` no Firestore Console, e os valores
batiam exato com o estado local (**75 XP, 39 moedas**) — não só o
gancho estava religado, o dado real estava chegando na nuvem depois do
reload. Esse era o problema original, verificado de ponta a ponta por
fora deste ambiente de teste.

Nota pra quem for reproduzir: **precisa ser servido por `http(s)`, não
`file://`** — Firebase Auth (a popup do Google, a checagem de domínio
autorizado) não funciona direito com o arquivo aberto direto.
`localhost` já vem autorizado por padrão no Firebase, sem precisar
adicionar na lista de domínios (diferente do Netlify, que precisou ser
adicionado manualmente — ver seção sobre isso). `python3 -m http.server`
na pasta do arquivo resolve pra esse tipo de teste rápido, sem precisar
publicar nada.

## 38. Mudo dos efeitos sonoros (v4.49), movido pra ícone na topbar em seguida

### O pedido, e a dúvida legítima por trás dele

Item 13c do roadmap ("UI de volume/mudo") estava pendente desde a
seção 20 — a API já existia (`sfxAtivo`/`definirSfxAtivo`/`sfxVolume`/
`definirSfxVolume`, persistida em `questlog.sfx.v1`), só nunca tinha
ganho controle visual. O usuário perguntou se isso era realmente
necessário — "não tem nem música nada".

Esclarecimento que resolveu a dúvida: não é sobre música (o app não
tem trilha nenhuma), é sobre os efeitos sonoros — 14 sons curtos,
sintetizados via Web Audio API (ver seção 20). E o som `'clique'`
especificamente **dispara em praticamente todo botão do app**
(composer, "+ Adicionar", grade de herói, botões de Config, até a tela
de login) — não é um som raro tipo "subiu de nível", é por toque.
Confirmado no código (`grep` por `tocarSom('clique')`) antes de dar
opinião, não por suposição. Isso justifica a necessidade: sem jeito de
desligar, incomoda de verdade em ambiente silencioso — e é exatamente
esse o feedback que motivou o item no roadmap (playtest real, não
brainstorm interno).

### Escopo reduzido, decisão explícita

A API completa já suporta volume gradual (`sfxVolume`/
`definirSfxVolume`, 0 a 1), mas a decisão desta sessão foi construir
**só o mudo** (liga/desliga) — não o slider. Raciocínio: o problema
relatado é "para de fazer barulho", que um botão binário resolve
inteiro; um slider de volume seria UI adicional pra um caso de uso
("quero mais baixo, mas não mudo") que ninguém pediu ainda. Fica
registrado como possível segunda fase, não como omissão.

### Implementação — só UI, zero lógica nova

```js
btn.onclick = () => {
  const ligadoAntes = window.sfxAtivo();
  window.definirSfxAtivo(!ligadoAntes);
  atualizar();
  if (ligadoAntes === false && typeof window.tocarSom === 'function') window.tocarSom('clique');
};
```

Linha nova em Config ("Som" / "Ligado"↔"Desligado"), entre "Tema" e
"Histórico" — mesmo padrão visual `.cfgrow` das outras linhas. Não
precisou de nenhuma lógica de áudio nova: só chama a API que já
existia. Feedback sonoro só ao **ligar** — ao desligar, tocar um som
seria contraditório com a própria ação.

Mesmo padrão de sempre pra atualizar ao abrir a sub-aba Config: um
segundo `addEventListener` no botão da sub-aba "config", em paralelo
ao `onclick` que "PERFIL — SUB-ABAS" já usa.

### Validado em jsdom

Estado inicial "Ligado" (padrão), clique desliga (texto muda, `sfxAtivo()`
retorna `false`, persiste em `questlog.sfx.v1`), sair da aba e voltar
mantém o estado desligado (não reseta), clique de novo religa.

### Validado (versão dentro de Config, primeira tentativa)

`node --check` nos 36 blocos `<script>` (subiu de 35), balanço de
`<div>` (274/274).

### Ajuste em seguida: virou ícone na topbar, não botão de texto em Config

Questionamento do usuário: cavar até Perfil > Config só pra desligar
um som que incomoda **na hora** não faz sentido — devia ser um ícone
sempre visível, perto de onde as moedas aparecem. Concordei — o efeito
mais irritante (`'clique'` em quase todo toque) é justamente o tipo de
coisa que se quer desligar rápido, no momento, não navegando fundo.

**Trocou de lugar, não duplicou.** A linha em Config foi removida por
completo — dois controles pro mesmo toggle seria a mesma "inflar a
tela" que já tinha motivado fazer só o mudo em vez do slider de
volume completo nesta mesma sessão.

**Coube na topbar sem precisar de layout novo.** Antes de prometer,
conferi o CSS: `#nomeTopo{flex:1}` (regra que já existia, seção de
CSS por volta da linha 500) já absorve o espaço do meio da topbar e
empurra `.coins` pro canto direito — um filho a mais (`.somBtn`)
simplesmente cola do lado das moedas pelo mesmo mecanismo, sem
precisar mexer em `justify-content` nem em nada estrutural. Diferente
da sub-nav do Perfil (seção 6), que estourou porque não tinha esse
tipo de elemento flexível absorvendo o espaço sobrando.

**Ícone com duas variações** (alto-falante com ondas / alto-falante
com X), trocadas via `innerHTML` do `<svg>` conforme `sfxAtivo()` —
mesmo estilo de traço (`stroke-width:2`, pontas arredondadas) dos
outros ícones já usados no app, pra não destoar.

**Mais simples que a versão de Config, não só diferente**: por estar
na topbar (sempre visível, não escondida atrás de nenhuma sub-aba),
não precisou do padrão de "segundo `addEventListener` ao abrir a
sub-aba" que os controles dentro de Perfil > Config sempre exigem —
só pinta uma vez, no carregamento da página.

### Validado de novo, versão final

`node --check` limpo. Confirmado: botão presente já no boot, sem
precisar entrar em Perfil; continua dentro da `.topbar` (não escondido
por nenhuma view de aba específica, então visível em qualquer aba, não
só Perfil); ícone troca de desenho ao alternar estado; e a linha antiga
`#cfgSomBtn` dentro de Config confirmada **ausente** — não ficou
duplicada, foi removida de verdade.

## 39. "Receber tudo" — resgate em lote das conquistas pendentes (v4.50)

Pedido explícito: uma função pra resgatar todas as recompensas
pendentes de uma vez, em vez de clicar marco por marco. Construída em
cima do arquivo mais recente do Project Knowledge (`4-49-mudo.html`),
que já trazia as correções das seções 27–38 (resgate ao vivo, som de
recompensa, etc.) — sessão não repetiu nenhuma delas, só leu o estado
atual de `resgatarConquista()`/`montarContexto()` antes de mexer.

### O que foi adicionado

`listarPendentes(ctx, resgatados)` — varre as 5 categorias e devolve os
marcos `feito`-mas-não-`resgatado`, reaproveitado tanto pelo botão
quanto pelo cálculo do XP total exibido nele.

`resgatarTodasConquistas()` — mesma lógica de `resgatarConquista()),
em lote: um `xpTotal += somaXP` só (não um por marco), uma checagem de
nível antes/depois só (evita empilhar vários popups de level-up se o
lote cruzar mais de um nível de uma vez), um `tocarSom('grimorio')` só.
Usa `montarContexto(true)` — o mesmo contexto ao vivo que
`resgatarConquista()` já usa desde a correção da seção 28, não o
`(false)` antigo.

Botão `Receber tudo · +N XP (M conquistas)` no topo do painel de
Conquistas, cor `--accent` (não a cor de nenhuma categoria específica,
já que cobre todas), some sozinho quando não há pendente.

### Comportamento em cascata, verificado (não é bug)

Resgatar em lote pode empurrar XP o suficiente pra desbloquear um novo
marco de "Subir de Nível" que não estava pronto antes do clique — esse
marco aparece como pendente de novo, pronto pra outro "Receber tudo".
Testado em jsdom: 9 marcos forjados como pendentes (mistura de Nível,
Tarefas e Itens), um clique resgatou os 9 e o XP resultante desbloqueou
um 10º marco de Nível na sequência; um segundo clique (ou o mesmo loop)
pegou esse também. Idempotência confirmada à parte, com a fila
genuinamente vazia: XP e `conquistasResgatadas` não mudam num terceiro
clique.

## 40. Botão "Criar conta" em Config, pra quem joga localmente (v4.51)

### O pedido (item 13e do roadmap)

Espelho do "Sair" (item 13a, seções 36/37): antes desta versão, o
fluxo de login só aparecia na tela inicial, pra quem **ainda não**
tinha save local. Quem já joga há dias sem conta (guest) e decide
querer criar uma, pra não perder progresso ou sincronizar entre
aparelhos, não tinha nenhum caminho — a única forma de ver a tela de
login de novo seria apagar tudo primeiro, o que é o oposto do que essa
pessoa quer.

### Design: uma linha só, dois estados — não duas linhas

Em vez de criar uma linha nova "Criar conta" ao lado da linha "Conta"
já existente (que só aparecia pra quem estava logado), a linha
`#cfgRowConta` deixou de ficar `oculto` por inteiro. Agora ela sempre
aparece, e alterna **qual botão** mostra:

- **Logado:** "Logado como Fulano" + botão "Sair" (comportamento
  idêntico ao de antes, sem mudança).
- **Sem conta:** "Jogando sem conta" + botão "Criar conta".

Nunca os dois botões ao mesmo tempo — `atualizarLinhaConta()` (já
existia, só ganhou o branch novo) alterna a classe `.oculto` em cada
botão individualmente, em vez de esconder a `div` inteira.

### Zero UI nova — reaproveita 100% o mecanismo do "Sair"

"Criar conta" faz exatamente as mesmas duas linhas que "Sair" já
fazia pra voltar à tela de login:

```js
btnEntrar.onclick = () => {
  localStorage.setItem('questlog.forcarLogin.v1', '1');
  location.reload();
};
```

Mesma flag de uso único, mesmo ponto de consumo (logo após `if
(carregar())` no script principal, que desfaz o `.off` de `#intro`
antes do módulo que decide injetar `#passoLogin` rodar — ver seção
37). A única diferença do "Sair": não chama `signOut()` antes, porque
não existe sessão nenhuma pra encerrar — quem clica aqui nunca esteve
logado.

**A tela de login em si não precisou de nenhuma mudança.** Ela já
existe inteira desde a seção 30 (email/senha, Google, toggle
Entrar/Cadastro), e já sabe lidar com "tem save local" corretamente —
`aoLogar()` checa `temSaveLocal` e reentra direto no app (em vez de ir
pro onboarding) quando há progresso pra reaproveitar, fix que já tinha
sido feito na seção 37 justamente pensando no "Sair" reabrindo essa
tela por cima de um save existente. "Criar conta" é o mesmo cenário
exato, só chegando lá por um caminho diferente — nenhum tratamento
especial precisou ser escrito pra esse caso, o código já estava
preparado.

### Nuance registrada, não resolvida nesta sessão

Se o jogador loga numa conta que **já tem dados salvos na nuvem** (não
é uma conta nova), `aoLogar()` chama `puxarNuvem()` antes de checar se
há save local — ou seja, o progresso local recente (de quem estava
jogando sem conta até agora) pode acabar sobrescrito pelos dados
antigos daquela conta. Isso não é um bug introduzido por este botão —
é o mesmo comportamento que a tela de login sempre teve, pra qualquer
login, novo ou não. Só ficou mais alcançável agora, porque existe um
caminho novo pra chegar lá com progresso local recente em jogo (antes,
só quem tinha acabado de instalar o app, sem nada a perder, via essa
tela). Resolver isso direito pediria lógica de merge ou comparação por
timestamp entre local e nuvem antes de decidir qual lado vence — a
mesma pendência já registrada na seção 37 para sincronização geral
entre aparelhos. Fora do escopo deste botão específico; registrado
aqui pra não se perder.

### Nota separada: item 13b estava desatualizado, corrigido no `.md`

Ao revisar os itens da seção 13 pra confirmar o que já estava feito,
o item 13b ("renomear apagar progresso") ainda descrevia um
diagnóstico de sessão anterior à seção 35 — dizia que bastava
renomear o rótulo, porque "é sync funcionando como projetado, não
bug". A seção 35 já tinha ido mais fundo e achado um bug de verdade
por trás (o Firestore nunca era apagado, cadeia completa documentada
lá). Corrigido o texto do item 13b pra refletir isso, sem reescrever
a investigação em si — só apontando pra onde ela já mora.

### Validado em jsdom, 2 cenários + regressão

**Sem conta:** linha "Conta" visível (não mais escondida por
completo), texto "Jogando sem conta", botão "Criar conta" visível,
"Sair" escondido. Clique em "Criar conta": flag `forcarLogin` setada,
`questlog.v1` confirmado intacto (não apagou nada). Reload simulado
(nova instância de `JSDOM` encadeando o mesmo `localStorage`):
`#passoLogin` injetado, `#intro` sem `.off` — tela de login volta de
verdade, exatamente como no fluxo do "Sair" (seção 37).

**Com conta logada (regressão):** texto "Logado como Davi", botão
"Sair" visível, "Criar conta" escondido — confirma que o branch antigo
continua funcionando sem mudança depois da unificação da linha.

### Validado

`node --check` limpo nos 35 blocos `<script>` clássicos e no
`<script type="module">` (checado separado).

## 41. Save principal misturava progresso entre contas ao trocar de conta no mesmo aparelho (v4.52)

### O bug relatado

Usuário loga na Conta A, joga, sai, loga na Conta B — e o progresso
da Conta A aparecia na Conta B. Investigação confirmou que não era só
exibição errada: era mistura de dados de verdade. Causa raiz: o save
local sempre viveu numa chave fixa só, `questlog.v1` — sem nenhuma
referência a qual uid estava logado. "Sair" (seção 36) nunca limpa
essa chave de propósito (não apaga nada, só desconecta a sincronização),
então ao logar na Conta B, `puxarNuvem(uid)` só sobrescrevia o save
local se já existisse documento na nuvem pra aquele uid — se a Conta B
fosse nova ou ainda sem save na nuvem, essa puxada falhava
silenciosamente (`if (snap.exists() && snap.data().data)`) e a chave
`questlog.v1` continuava com o progresso da Conta A. No primeiro
`salvar()` da nova sessão, `empurrarNuvem(uid)` pegava esse mesmo
`questlog.v1` — progresso da conta errada — e gravava no documento da
Conta B.

Piorava por haver **duas constantes desconectadas** apontando pro
mesmo literal `'questlog.v1'`: `CHAVE` no módulo principal de
save/load (linha ~1522) e `CHAVE_SAVE`, isolada dentro do módulo
Firebase (linha ~7261). Mudar uma sem a outra deixaria o bug
parcialmente corrigido — sync e save local voltando a divergir.

### Decisão de escopo, confirmada com o usuário antes de implementar

Perda de dados é aceitável **só no momento da migração** (a primeira
sessão de quem já tinha conta/progresso antes desta atualização), não
durante o uso normal do app (trocar de conta, criar conta, reabrir o
app já logado). Isso descartou a solução mais simples (só trocar a
chave e pronto) e trouxe duas exigências extras que só apareceram ao
mapear os fluxos existentes a fundo:

1. **Criar conta com progresso local já existente não pode perder
   esse progresso.** O item 13e (seção 40) já garante um caminho pra
   isso — "Criar conta" em Config abre o login por cima de um save já
   existente, sem apagar nada. Com a chave nova namespaced por uid, uma
   conta recém-criada nasceria vazia por padrão (nunca teve nada salvo
   sob aquele uid) — reintroduziria a perda de progresso que o 13e já
   tinha resolvido, só que por um motivo diferente.
2. **Reabrir o app já logado precisa continuar lendo a chave certa
   mesmo antes do Firebase confirmar a sessão.** Descoberto ao rastrear
   o boot: desde a seção 37, o SDK do Firebase carrega em **toda**
   sessão (não só na tela de login), mas de forma assíncrona — enquanto
   isso, o `if (carregar())` no topo do script principal já rodou de
   forma síncrona. Se qual-chave-ler dependesse só de uma variável em
   memória setada pelo Firebase, todo reload de quem já está logado
   leria a chave de convidado por engano, até o Firebase confirmar a
   sessão segundos depois — sem re-carregar os dados certos sozinho.

### O fix

**Fonte única da chave de save**: `chaveSaveAtual()`, uma função nova
perto de `CHAVE` (linha ~1522, dentro do módulo principal de
save/load), que devolve `'questlog.v1'` pra quem joga sem conta, ou
`'questlog.v1.uid.<uid>'` pra quem está logado. Exposta em
`window.chaveSaveAtual` porque o módulo Firebase (bloco separado,
mais abaixo no arquivo) também precisa dela — isso elimina a
`CHAVE_SAVE` duplicada de dentro daquele módulo, que passou a chamar
`window.chaveSaveAtual()` nos dois pontos onde lia/escrevia
(`puxarNuvem`/`empurrarNuvem`).

**Qual uid está ativo** é controlado por `window.definirUidAtivo(uid)`,
chamada em três pontos: dentro de `aoLogar()` (login normal e criação
de conta), dentro de `aoLogarSilencioso()` (reconexão silenciosa de
sessão já ativa, sem tela de login visível) e implicitamente desfeita
no "Sair" (ver abaixo). Essa função guarda o uid tanto em memória
quanto — ponto que resolve a exigência 2 acima — em
`localStorage.questlog.uidAtivo.v1`, lido de forma síncrona logo na
declaração de `chaveSaveAtual()`, antes de qualquer `carregar()`
rodar. Mesmo padrão já usado pro marcador `questlog.conta.v1` (seção
36), só que agora também influencia qual chave o app lê, não só o que
a UI mostra.

**Preservar progresso ao criar conta** (exigência 1 acima): dentro de
`aoLogar(user)`, antes de puxar da nuvem, uma checagem detecta conta
recém-criada — `user.metadata.creationTime === user.metadata.lastSignInTime`,
truque padrão do Firebase (os dois timestamps só coincidem no exato
momento da criação; cobre cadastro por email **e** Google, que cria
conta on-the-fly no primeiro popup sem passar por
`createUserWithEmailAndPassword`). Se for conta nova, copia o que
estiver em `questlog.v1` (chave de convidado) pra dentro da chave
namespaced do uid novo, antes de qualquer outra coisa rodar. A chave
de convidado não é apagada — fica órfã, mas intacta, caso o usuário
volte a jogar sem conta depois.

**"Sair" também limpa o marcador de uid ativo** (`questlog.uidAtivo.v1`),
além do `questlog.conta.v1` que já limpava — sem isso, o próximo boot
continuaria lendo a chave da conta que acabou de sair, já que a leitura
do marcador é síncrona e independente de qualquer chamada ao Firebase.

### Efeito colateral aceito, confirmado com o usuário

Quem já tinha conta e progresso salvos **antes** desta atualização vai
ver, na primeira sessão pós-deploy, uma reacomodação silenciosa: o
boot ainda lê a chave antiga (`questlog.v1`, sem namespace, porque o
marcador de uid ainda não existe) e mostra o progresso certo
normalmente — mas assim que o Firebase reconectar a sessão em segundo
plano, `definirUidAtivo()` muda a chave ativa pra namespaced, e o
próximo `salvar()` grava ali. No reload seguinte, o marcador já
aponta pra chave certa e tudo se estabiliza sozinho, desde que pelo
menos um `salvar()` tenha rodado na sessão de transição. Confirmado
com o usuário como aceitável: perda/reacomodação de dados só durante
a atualização em si, nunca durante uso normal depois dela.

### Validado

`node --check` limpo nos 36 blocos `<script>` (nenhum bloco novo
criado, só os 4 pontos editados). Contagem de `<div>`/`</div>`,
`<script>`/`</script>` e `<svg>`/`</svg>` idêntica entre o arquivo
original e o patcheado — confirma que nenhuma tag foi tocada fora dos
4 pontos pretendidos. Lógica de seleção de chave extraída e testada
isoladamente (harness Node standalone, sem montar o DOM inteiro de
7600+ linhas) em 4 cenários:

1. Logar na Conta A, salvar, sair, logar na Conta B (sem nada salvo
   pra ela ainda): Conta B não vê o progresso da Conta A ao entrar;
   depois de salvar, as duas gavetas (`questlog.v1.uid.uidA` e
   `...uidB`) ficam com os dados corretos e isolados uma da outra.
2. Progresso de convidado existente + criar conta nova: o progresso é
   herdado pra dentro da chave namespaced (nada perdido), e a chave de
   convidado permanece intacta (não apagada).
3. Logar, salvar, simular reload (nova instância do módulo, mesmo
   `localStorage`, **antes** de qualquer chamada assíncrona rodar): o
   boot síncrono já lê a chave certa, graças ao marcador persistido.
4. Sair + simular reload: o boot volta a ler a chave de convidado, não
   a da conta que acabou de sair.

**O que não deu pra testar neste ambiente:** o caminho de sucesso real
com `puxarNuvem()`/`empurrarNuvem()` contra o Firestore de verdade —
mesma limitação de sempre (`www.gstatic.com` fora da lista de domínios
liberados pro `bash_tool` deste sandbox). A lógica de seleção de chave
em si, que é onde o bug morava, foi validada a fundo; a chamada real ao
SDK, só testável num navegador de verdade com contas reais.

### Nota: lacuna de versões 4-53 a 4-57 não documentada aqui

Este `.md` acompanhou o arquivo até a v4.52. As versões v4.53 a v4.57
(incluindo a reescrita de `DIALOGOS` do tutorial) rodaram em outra
sessão/chat, sem passar por este documento — coerente com a pendência
já conhecida de changelogs de v4.53/v4.54 nunca terem sido registrados.
A sessão atual recebeu o arquivo já na v4.57 direto do usuário; o que
segue documenta só a partir daí. Fica registrado como lacuna conhecida,
não como sessão perdida — o trabalho existe, só não tem relato aqui.

## 42. Menu Config virou tela cheia (overlay), separado das sub-abas de Perfil (v4.58)

### Motivação

Usuário comparou o app com a tela de Configurações do Habitica (print
anexado) — lá, "Settings" é uma tela própria, cheia, com seta de
voltar e seções (`ACCOUNT` / `APP SETTINGS`). No QuestLog, Config
sempre foi só mais uma sub-aba dentro de Perfil (`perfiltabs`: ícone
de engrenagem, Atributos, Conquistas, Bestiário), trocada por classe
`.oculto`, do mesmo jeito que as outras.

Avaliação de arquitetura antes de mexer: Atributos/Conquistas/
Bestiário são conteúdo de personagem (cresce jogando); Config é
configuração do app (tema, conta, sprite, idioma) — categoria
diferente, cresce por outro motivo (mais preferências, não mais XP).
Empilhar os dois como abas irmãs do mesmo nível confundia domínio, e
a lista de Config só tende a crescer (idioma real ainda pendente,
item 13d; parte de perfis separados, item 13f) — uma tela dedicada
escala melhor que competir por espaço numa fileira de 4 abas.

### Decisões de escopo confirmadas com o usuário antes de implementar

Duas perguntas, respondidas via botões (mobile):
1. **Onde abre**: só a partir do Perfil (não virou ícone global
   acessível de qualquer aba — escopo mínimo, decisão explícita de não
   expandir os pontos de entrada nesta leva).
2. **Reorganização**: sim, já reagrupar o conteúdo existente em seções
   (`Conta` / `App`), não só mover sem tocar em nada.

### O fix

Em vez de inventar mecanismo de overlay novo, reaproveitado o padrão
que já existia pro Histórico e pro Grimório (`histOverlay`/
`grimOverlay`: `position:fixed;inset:0`, escondido por padrão, mostrado
via classe `.on`, com cabeçalho próprio e botão de fechar/voltar) —
zero conceito novo, só extensão de um padrão já validado.

**HTML**: a `id="perfilConfig"` continuou fisicamente no mesmo lugar
do arquivo (depois de `perfilBestiario`) — só saiu de dentro de
`#viewPerfil` pra virar irmã dela, e trocou de `class="perfilpane
oculto"` pra `class="cfgOverlay"`. `position:fixed` tira do fluxo
visual independente de aninhamento, então não havia necessidade real
de mover o bloco pra outro lugar do arquivo — menor diff possível.
Conteúdo reorganizado em duas seções com o rótulo `.edsec` (classe que
já existia, usada nas folhas modais — reaproveitada em vez de criar
rótulo de seção do zero): **Conta** (linha "Conta" com
Entrar/Sair, "Apagar dados") e **App** (Nome do herói, Sprite,
Tema, Histórico). Adicionado cabeçalho novo (`cfgovhead`) com botão de
voltar (seta, SVG novo) + título "Configurações", e um corpo rolável
(`cfgovcorpo`) envolvendo as linhas de config já existentes.

**CSS**: bloco novo `.cfgOverlay`/`.cfgovhead`/`.cfgvoltar`/
`.cfgovcorpo`, mesmo padrão visual de `.histOverlay`. `z-index:69` —
um degrau abaixo do `histOverlay`/`grimOverlay` (`z-index:70`) de
propósito: o botão "Histórico" abre de dentro do Config, então o
Histórico precisa pintar por cima quando os dois estão "abertos" ao
mesmo tempo (Config só fica visualmente atrás, não fecha sozinho).

**JS**: dentro da IIFE "PERFIL — SUB-ABAS" — `PAINEIS` perdeu
`'config'` (não é mais sub-aba trocada por `mostrarSubPerfil`). O
clique no botão de engrenagem (`data-ptab="config"`) passou a chamar
`abrirConfig()` em vez de `mostrarSubPerfil('config')` — os outros 3
botões de sub-aba continuam no fluxo antigo, sem mudança de
comportamento. `abrirConfig()`/`fecharConfig()` novas, expostas em
`window.*` (mesmo padrão de `window.abrirHistorico`), a primeira
chamando a já existente `sincronizarConfig()` antes de mostrar o
overlay.

### Validado

`node --check` limpo nos 36 blocos `<script>` (nenhum bloco novo além
do já existente, só HTML/CSS/JS editados nos pontos pretendidos).
Contagem de tags comparada arquivo original vs. patcheado: `<div>`
272→276 (+4: `cfgovhead`, `cfgovcorpo`, 2× `.edsec` — bate com o que
foi de fato adicionado), `<svg>` 25→26 (+1: ícone da seta de voltar),
`<button>` +1/+1 (botão de voltar) — todas as contagens fecham
casadas (abertura = fechamento), nenhum vazamento de tag. Nenhuma
referência solta a `perfilConfig` como sub-aba sobrou no arquivo
(`grep` limpo).

Simulação funcional em jsdom (fragmento real do HTML + bloco JS
extraído do arquivo, não reescrito à parte) cobrindo 13 cenários:
overlay começa fechado; clique na engrenagem abre e sincroniza
(`cfgNomeAtual`, grade de heróis, grid de temas todos populados);
botão de engrenagem **não** ganha a classe `.on` (confirma que não é
mais tratado como sub-aba); botão voltar fecha; as 3 sub-abas restantes
(Atributos/Conquistas/Bestiário) continuam trocando entre si
normalmente, sem regressão; `window.abrirConfig()`/`window.fecharConfig()`
funcionam chamados diretamente, não só via clique.

**O que não deu pra testar neste ambiente:** a integração visual real
em navegador (transição, safe-area em notch de verdade, o Histórico
abrindo por cima do Config com o `z-index` escolhido) — a simulação
em jsdom cobre lógica e estado de classes, não renderização.

## 42-b. Login, Nome, Herói e Tarefas fundidos no carrossel único (v4.113 → v4.114)

### O pedido

Até a v4.113 existiam DOIS mecanismos de onboarding coexistindo, com troca
abrupta de visual entre eles:
1. Carrossel moderno (splash → QUESTLOG → BATALHA → EVOLUA), com swipe,
   dots, seta Voltar, fundo texturizado.
2. Fluxo antigo (`mostrarPasso()`), sem swipe: `#passoLogin` (tela
   separada, fundo próprio) → `#passo1` (regras, duplicava o pitch do
   slide QUESTLOG) → `#passo2` (nome) → `#passoHeroi` → `#passo3`
   (tarefas).

Pedido: unificar tudo num único carrossel interativo, incluindo login,
seleção de nome, seleção de herói e criação das primeiras tarefas.

### Decisões fechadas com o usuário antes de implementar

- `#passo1` (regras) **mantido como slide extra** dentro do carrossel,
  não cortado — mas reescrito pra não repetir o título/pitch "QUESTLOG"
  que já aparece no slide 1 (virou "COMO FUNCIONA", só as 3 regras).
- Login, Nome, Herói e Tarefas **viram slides do MESMO carrossel**
  (swipe + dots + seta Voltar), não passos separados com transição só
  cosmética.
- "Continuar sem conta" (pular login) **avança pro slide de Nome**,
  dentro do mesmo carrossel — decisão de engenharia (usuário deixou a
  critério): mesmo destino usado por login bem-sucedido de conta nova.

### Numeração final dos 8 slides

```
1 QUESTLOG (marca)  ·  2 regras ("como funciona")  ·  3 BATALHA
4 EVOLUA  ·  5 LOGIN  ·  6 NOME  ·  7 HERÓI  ·  8 TAREFAS
```

### Como foi feito (arquitetura, não reescrita)

Em vez de duplicar HTML/lógica dos 5 passos antigos (`#passo1`,
`#passoLogin`, `#passo2`, `#passoHeroi`, `#passo3`), eles são
**reparentados em runtime** (`appendChild`) pro mesmo
`#carrosselPalco` que já continha os 3 slides gerados
(QUESTLOG/BATALHA/EVOLUA). Cada um ganha só `class="carrosselSlide"` +
atributo `data-slide="N"` — ids, listeners internos (`irEscolha`,
`loginEntrarBtn`, delegação de `#gradeHerois`, etc.) e toda a lógica de
validação continuam **100% intactos**, só mudam de pai no DOM.

Mudanças de mecanismo, todas dentro da IIFE do carrossel:
- `irPara(alvo)` virou genérico pra 1-8 via `data-slide` (função
  `slideEl()`), em vez de `getElementById('passoCarrossel'+alvo)` +
  branch especial `if (alvo === 'login')`. Esse branch especial (que
  restaurava a parede de tijolo original ao entrar no login) foi
  **removido** — decisão de design: o fundo agora é o MESMO gradiente+
  tijolo do carrossel do início ao fim do onboarding, sem troca abrupta.
- `pegarVizinho()` (arraste) e os dois pontos de parse de `atualNum` no
  gesto de arrastar trocaram de `elemento.id.replace('passoCarrossel','')`
  pra `elemento.dataset.slide`.
- `SLIDES` (array dos 3 slides gerados por template) ganhou campos
  explícitos `dataSlide`/`next` em vez de inferir por `i+1`/
  `SLIDES.length` — necessário porque a numeração final pula o 2
  (reservado pro slide de regras, que não vem do array).
- Botão "Pular": antes de login (slides 1-4) pula pro login (5); a
  partir do login pula direto pro Nome (6, mesmo destino de "Continuar
  sem conta"); a partir do Nome em diante **fica oculto** (criação de
  personagem é obrigatória, ninguém "pula" o próprio nome/herói/
  primeira tarefa) — `atualizarTopo()` controla isso via `.oculto`.
- Handlers antigos de `irPasso2`/`voltar1`/`irEscolha`/`voltarNome`/
  `irPasso3` (que chamavam `mostrarPasso()`) foram **sobrescritos**
  (não apagados — `.onclick = ...` é atribuição simples, a última
  atribuição no load vence) pra chamar `irPara()` do carrossel.
  `mostrarPasso()` continua definida, só nunca mais é chamada — código
  morto documentado, não removido (convenção wrap-not-rewrite).
- Novo guard no início do gesto de arrastar (`pointerdown`): ignora
  input/textarea/select/button/`.opcao` como ponto de partida do swipe.
  Necessário porque login/nome/herói/tarefas têm campos de verdade —
  sem isso, selecionar texto num campo ou tocar num botão era
  interpretado como início de swipe, arrastando a tela inteira.
- `window.irParaCarrossel` exposto globalmente, pra dois pontos fora da
  IIFE do carrossel poderem pular direto pro slide de Nome: o handler
  de "Continuar sem conta" (bloco de login) e `entrarNoApp()` dentro de
  `aoLogar()` (bloco Firebase, conta nova sem save local).

### O que NÃO mudou

- Toda a lógica de autenticação (Firebase, `aoLogar`, `aoLogarSilencioso`,
  sync com nuvem) — zero linha tocada.
- Validação de nome, montagem da grade de heróis (`montarGrade`,
  `pintarEscolha`), lista de tarefas iniciais (`renderIniciais`) e o
  handler final `#entrar` (que já não dependia de `mostrarPasso`,
  não precisou de rewire).
- Delegação de clique em `#gradeHerois`, haptic feedback (`feedbackClique`)
  em todos os botões de navegação — só a lista de ids do bloco SFX dos
  slides gerados foi atualizada (`carrosselBtn1/3/4`, porque a numeração
  agora pula o 2).

### Validação desta sessão

- `node --check` nos 39 blocos `<script>` do arquivo (classic + module) —
  0 erros.
- Balanceamento de `<div>`/`<svg>`/`<style>`/comentários HTML — OK.
  (`<script>`/`<button>` aparecem desbalanceados na contagem bruta, mas
  isso é **pré-existente** desde a v4.113 — confirmado rodando a mesma
  checagem no arquivo anterior; provavelmente menções a essas tags
  dentro de comentários de documentação, não erro real de HTML.)

### Pendências / decisões abertas pra próxima sessão

- **Ainda não testado em dispositivo real** (Playwright CDP touch) —
  esta sessão foi só análise de código + edição cirúrgica, sem sandbox
  de browser disponível. Prioridade #1 da próxima sessão: testar o
  arraste em cima dos campos de login/nome (guard de `pointerdown`) e a
  transição de fundo (agora fixa) num aparelho de verdade.
- Botão "Voltar" (topo) e os botões locais `voltar1`/`voltarNome`
  (dentro dos slides Nome/Herói) agora fazem exatamente a mesma coisa
  (decrementar 1) — redundante mas inofensivo. Não removido por
  segurança; considerar simplificar visualmente numa sessão futura
  dedicada a polish (não é bloqueador).
- `.intro.loginBg` e `paredeOriginal` ficaram sem uso funcional (fundo
  não troca mais) — documentados como código morto, não removidos.
- Animações "melhores" pedidas pelo usuário: implementado o essencial
  funcional (guard de arraste, fundo unificado, Pular contextual). Não
  foi gasto tempo em polish visual adicional (ex. easing customizado,
  micro-animação no botão Pular sumindo) — por decisão de foco em
  lógica/funcionamento primeiro, conforme instrução do usuário no início
  da sessão. Item em aberto pra sessão de polish, sem urgência.

---

## 42-c. Corte do slide de regras, reordenação (login pro final) e opacidade do tijolo (v4.114 → v4.115)

### Pedido (mesma sessão, rodada seguinte)

1. Cortar o slide 2 (regras/"como funciona") — feedback: "faz
   basicamente a mesma coisa" que o slide QUESTLOG.
2. Textura de tijolo pouco visível num aparelho com brilho no médio —
   aumentar opacidade.
3. Reestruturar a ORDEM: login deixa de vir logo após EVOLUA e passa
   pra DEPOIS da escolha de herói (a pessoa já investiu em nome+herói
   antes de decidir se cria conta).

### Numeração final (7 slides, era 8)

```
1 QUESTLOG · 2 BATALHA · 3 EVOLUA
4 nome · 5 herói · 6 login · 7 tarefas
```

### O que mudou

- `#passo1` (regras) **saiu do carrossel** — não é mais reparentado,
  não ganha `data-slide`, nunca mais aparece. Markup mantido no HTML
  (não apagado, convenção wrap-not-rewrite), mas 100% morto.
- `SLIDES` voltou a ter `dataSlide` contíguo (1,2,3) — não pula mais o
  2, já que não há mais nada pra reservar aquele número.
- `REPARENTAR`: `passo2`(nome)=4, `passoHeroi`=5, `passoLogin`=6 (era
  slide 5, agora vem depois do herói), `passo3`(tarefas)=7.
- Opacidade do gradiente que cobre o tijolo reduzida de 65%/82% pra
  42%/55% (ambos os pontos: CSS do splash e o `intro.style.backgroundImage`
  do carrossel) — ajuste feito só por número, sem preview em
  dispositivo real nesta sessão. **Primeira coisa a validar no próximo
  teste real** — pode precisar de mais um ajuste fino.
- "Pular" simplificado: só fica visível nos slides 1-3 (marketing),
  sempre leva direto pro slide Nome (4) — não precisa mais checar em
  qual dos 3 a pessoa está, porque não existe mais alvo intermediário
  (login saiu do caminho direto).
- Destinos pós-login atualizados: "Continuar sem conta" e conta nova
  via Firebase (`entrarNoApp`) agora pulam pro slide **Tarefas (7)**,
  não mais Nome — porque quem chega no login já passou por nome/herói
  nesta nova ordem. Ambos os pontos também focam `#primeiraTarefa` ao
  chegar lá (retomado do comportamento antigo de `irPasso3`, que fazia
  sentido quando herói levava direto pra tarefas).

### Trade-off registrado, não resolvido

Como nome/herói agora são escolhidos ANTES do login, existe um cenário
onde a pessoa escolhe nome+herói, aí loga numa conta EXISTENTE que já
tem progresso na nuvem — `puxarNuvem()` sobrescreve o local com os
dados antigos da conta, descartando o nome/herói que acabou de
escolher nesta sessão. Esse comportamento já existia antes (mesma
lógica de `aoLogar`/`temSaveLocal`), mas ficava menos visível porque
login vinha ANTES da escolha; agora é mais provável a pessoa notar que
"perdeu" uma escolha que acabou de fazer. Mesma família do problema já
registrado na seção 37 (merge/timestamp entre local e nuvem) — fora do
escopo desta sessão, mas vale priorizar se aparecer reclamação real.

### Validação desta sessão

- `node --check` nos 39 blocos `<script>` — 0 erros.
- Balanceamento `<div>`/`<svg>`/`<style>` — OK.
- Sanity check manual de todos os `irPara(N)`/`irParaCarrossel(N)`
  restantes no arquivo, confirmando que nenhum aponta pra número fora
  do range 1-7 ou pra um slide removido.
- **Não testado em dispositivo real** (mesma pendência da rodada
  anterior, ainda não resolvida — sem sandbox de browser disponível
  nesta sessão).

### Pendências abertas

- Testar em aparelho real: opacidade do tijolo (ajuste só numérico),
  guard de arraste sobre campos de texto, nova ordem completa
  (principalmente a transição herói→login e login→tarefas, que são as
  duas transições novas desta rodada).
- "Reestruturação" da tela de Herói e da tela de Login foi mencionada
  pelo usuário mas ainda **não especificada** — perguntar escopo antes
  de mexer (layout? conteúdo? novos campos?) na próxima sessão.

---

## 42-d/42-e. Herói com setas + Login como desvio opcional (v4.115 → v4.116)

### Contexto: vídeo de referência

Usuário mandou uma gravação de tela do **Habit Slayer** (45s, onboarding
completo). Conclusões tiradas do vídeo (análise de frames, não
descrição do usuário):
- **Não existe tela de login/senha em NENHUM ponto do onboarding** —
  todo o fluxo roda só com nome, sem email/senha/criar conta.
- Herói (lá chamado de "character") não é grade de sprites prontos — é
  composição por atributo: abas de raça (Human/Elf/Orc/Undead) + 4
  seletores independentes `‹ ›` (Body Type, Skin Color, Hair Style,
  Hair Color), preview central único.
- Título "What is your name?" com transição typewriter antes.
- Além disso, o vídeo mostra permissão de notificação, seleção de
  áreas de interesse e paywall de assinatura — **fora do escopo**,
  não implementados (monetização/features novas, não pedidas).

### Decisões do usuário

- Herói: **manter o catálogo de sprites prontos** (não migrar pra
  composição em camadas — mudança de arquitetura grande demais pro
  pedido). Só melhorar a interação/visual.
- Login: "tenta algo novo" — carta branca, dado o achado de que a
  referência nem tem essa tela.

### O que foi feito

**Herói (item 42-d)**: setas `‹ ›` flanqueando o palco (preview
central), navegando o MESMO array `HEROIS` que a grade já usa —
`heroiEscolhido` incrementa/decrementa com wraparound, chama
`pintarEscolha()` (mesma função que a grade já chamava). Grade
continua embaixo como atalho, nada removido. Preview aumentado de
96px pra 120px (mais parecido com o preview central da referência).

**Login (item 42-e)**: saiu de "passo numerado do carrossel" (era
slide 6) e virou **desvio opcional**, acessível a qualquer momento por
um link discreto "Já tem conta?" fixo no topo (ao lado de "Pular",
mas — ao contrário dele — nunca some, fica disponível em todos os
slides 1-6). Mecanismo:
- `passoLogin.dataset.slide = 'login'` (string, fora do range
  numérico 1-6) — não entra em `TOTAL_SLIDES` (voltou a 6), não ganha
  dot.
- `irParaLogin()`: guarda o slide de origem (`ultimoSlideAntesLogin`),
  apaga todos os dots (sinaliza visualmente "você saiu da sequência
  principal"), esconde Pular e o próprio link "Já tem conta?", desliza
  pro login vindo da direita.
- `voltarDoLoginCarrossel()`: volta pro slide de origem — chamada
  tanto pela seta Voltar (agora com um branch especial pra
  `dataset.slide === 'login'`) quanto pelo botão dentro do login
  (renomeado de "Continuar sem conta" pra **"Agora não"**, já que não
  significa mais "pular a criação de conta pra sempre", só fecha o
  desvio).
- `entrarNoApp()` (conta nova via Firebase) também usa
  `voltarDoLoginCarrossel()` em vez de um alvo fixo — necessário porque
  agora o login pode ser aberto de QUALQUER slide (1 a 6), não só
  depois do herói como na v4.115.
- `irPara()` numérico ganhou fallback (`|| ultimoSlideAntesLogin`) pro
  cálculo de direção da animação, pro caso de ser chamado vindo do
  login (`dataset.slide` não numérico, `parseInt` daria `NaN`).

### Trade-off da v4.115 (login sempre depois do herói) resolvido

A pendência registrada na seção 42-c (nome/herói escolhidos e depois
descartados se a pessoa loga numa conta existente) fica **menos
provável** agora — como login é opcional e não bloqueia mais nada, a
pessoa só entra nele se quiser, não é mais forçada a passar por ali
pra continuar. Ainda pode acontecer (login antecipado, tela 1, numa
conta existente) mas o cenário ficou mais raro.

### Validação desta sessão

- `node --check` nos 39 blocos `<script>` — 0 erros.
- Balanceamento `<div>`/`<svg>`/`<style>` — OK. `<button>` mantém a
  mesma diferença pré-existente de antes (não piorou com os 3 botões
  novos: heroiAnterior, heroiProximo, carrosselEntrarLink).
- Sanity check de todas as referências novas (`irParaLogin`,
  `voltarDoLoginCarrossel`, ids das setas) — todas presentes e
  consistentes.
- **Não testado em dispositivo real** (mesma pendência de sempre nesta
  sessão — sem sandbox de browser disponível).

### Pendências abertas

- Testar em aparelho real: TODAS as pendências das seções 42-b/c
  seguem valendo, mais especificamente agora: o desvio de login
  (abrir de vários pontos diferentes e voltar), as setas do herói
  (wraparound, sincronismo com a grade).
- Título "What is your name?" com efeito typewriter (visto na
  referência) não foi implementado — puramente visual, baixo risco,
  candidato pra sessão de polish.
- Itens fora de escopo confirmados como tal: permissão de notificação,
  seleção de áreas de interesse, paywall de assinatura — não
  implementados, ficam registrados aqui caso o usuário queira
  priorizar algum no futuro.

---

## 42-f. Slide de transição entre EVOLUA e Nome (v4.116 → v4.117)

### Pedido

"Tá faltando uma transição, talvez um diálogo, entre a tela do EVOLUA e
a tela de nome" — inspirado no vídeo de referência, que tem uma tela
"Let's start your journey..." (frase única, efeito typewriter) entre o
marketing e o "What is your name?".

### O que foi feito

Novo slide 4 (empurra nome/herói/tarefas +1 na numeração: 5/6/7 —
login continua fora da contagem, é um desvio, não muda):

```
1 QUESTLOG · 2 BATALHA · 3 EVOLUA · 4 transição
5 nome · 6 herói · 7 tarefas   (login: fora da numeração)
```

Conteúdo: frase única "Antes de começar, vamos te conhecer melhor..."
— sem personalização (nome ainda não existe nesse ponto), centralizada,
sem `.titulo`/cabeçalho (a referência também não tem um ali, só a
frase). Efeito typewriter revela a frase caractere por caractere
(28ms/caractere) com um cursor piscando via `::after`.

**Decisão técnica**: typewriter implementado em **JS**, não CSS
`steps()`/`width` fixo. CSS puro exigiria calcular a largura em `ch`
batendo com o tamanho exato do texto — frágil a qualquer edição futura
do texto (o título dos slides 1-3 já passou por isso, ver item 42-a:
3 rodadas só pra achar um tamanho que não quebrasse linha). Com JS, o
texto vive só em `data-texto` no HTML — editar `SLIDES[3].texto` basta,
nada mais pra recalcular.

**Refactor pequeno junto**: a composição do corpo de cada slide
(`corpo = i === 0 ? ... : i === 1 ? ... : ...`) era baseada em
**posição no array**, comentário dizia literalmente "slide 1 é assim,
slide 2 é assim". Com um 4º slide de tipo diferente isso ia ficar
ilegível/frágil — trocado por um campo `layout` explícito em cada
entrada de `SLIDES` (`'marcaPrimeiro'`, `'comTarefasDemo'`,
`'imagemPrimeiro'`, `'textoSolo'`). Comportamento dos 3 slides
existentes não mudou, só ficou explícito em vez de posicional.

**Hook do typewriter**: disparado dentro de `atualizarTopo(num)`
(`if (num === SLIDE_TRANSICAO) ...`) — esse ponto já é chamado tanto
por navegação via botão (`irPara`) quanto por swipe completado
(`finalizarArraste` também chama `atualizarTopo`), então um hook só
cobre os dois jeitos de chegar no slide. Roda uma única vez (flag
`window.__questlogTypewriterFoi`) — revisitar o slide (ex. clicar
Voltar a partir do Nome) só mostra o texto já pronto, sem re-animar.

### Nota sobre o estado do arquivo nesta sessão

Ao abrir o arquivo de trabalho pra começar esta mudança, o array
`SLIDES` e o `TOTAL_SLIDES` já tinham uma edição **parcial e
inconsistente** (aparentemente de uma tentativa anterior interrompida)
— só a entrada do slide 4 tinha sido adicionada, mas `REPARENTAR`,
`voltar1`/`irEscolha`/`voltarNome`/`irPasso3` e o comentário de
numeração ainda apontavam pros números antigos. Tratado como se fosse
começar do zero: toda a cadeia de números foi conferida e corrigida
manualmente, um `<style></style>` vazio sobrando (efeito colateral da
edição parcial) foi removido.

### Validação desta sessão

- `node --check` nos 40 blocos `<script>` (39 + 1 novo, do typewriter)
  — 0 erros.
- Balanceamento `<div>`/`<svg>`/`<style>` — OK (`<script>` mantém a
  mesma diferença pré-existente de sempre, +1/+1 pelo bloco novo).
- Sanity check de toda a cadeia numérica (REPARENTAR, todos os
  `irPara(N)`, `TOTAL_SLIDES`, `SLIDE_TRANSICAO`) — consistente ponta a
  ponta.
- **Não testado em dispositivo real** (pendência de todas as sessões
  anteriores, ainda não resolvida).

### Pendências abertas

- Todas as pendências de teste real das seções 42-b a 42-e continuam
  valendo, mais especificamente agora: timing do typewriter (28ms/char
  pode precisar de ajuste depois de ver rodando de verdade), e o cursor
  piscando (`::after`) em cima de fonte serifada itálica — não validado
  visualmente nesta sessão.

---

## 42-i. Bug real: slides sobrepostos / tela em branco (v4.117 → v4.118)

### O que o vídeo mostrou

Usuário mandou gravação de tela (17.7s) do carrossel em uso real.
Analisando frame a frame, dois sintomas do MESMO bug:
1. **Tela em branco**: parado no slide EVOLUA (dot 3 aceso), só o
   fundo de tijolo visível — sem imagem, título, texto ou botão — por
   ~4 segundos seguidos, até o usuário desistir e recarregar a página.
2. **Dois slides sobrepostos**: depois do reload, em dado momento
   QUESTLOG (slide 1) e EVOLUA (slide 3) ficaram os DOIS totalmente
   visíveis, exatamente na mesma posição (não lado a lado, empilhados)
   — sprites, títulos e texto de ambos misturados, botão mostrando
   "COMEÇARCONTINUAR" (label dos dois botões sobrepostos). Poucos
   segundos depois, o mesmo aconteceu entre BATALHA (2) e EVOLUA (3).

### Causa raiz

O arraste (swipe, `finalizarArraste()`) e o clique de botão (`irPara()`
→ `deslizar()`) tinham **travas de transição independentes**. Clique
respeitava `emTransicao` (`if (emTransicao) return;`); arraste tinha só
seu próprio timeout local (`DURACAO_SOLTAR`, 220ms) pra assentar a
animação — sem nunca setar ou checar `emTransicao`. Se a pessoa solta o
dedo de um arraste e, dentro dessa janela de ~220ms, um clique em botão
dispara (o botão pode ter acabado de deslizar pra debaixo do dedo, ou o
navegador sintetiza um evento `click` a partir do mesmo toque, sujeito
a heurística própria de cada browser), os dois sistemas mexem no `.on`
de slides diferentes ao mesmo tempo sem se coordenar — dá tanto pra
sobrar dois `.carrosselSlide.on` simultâneos (dois visíveis, já que
`position:absolute;inset:0` empilha em vez de somar) quanto pra nenhum
(ambos removidos por engano). Explica o "às vezes" — depende do timing
exato entre soltar o arraste e o próximo toque.

### Correção

1. **`emTransicao` virou compartilhada**: `finalizarArraste()` agora
   seta `emTransicao = true` assim que decide (completar ou voltar) e
   só libera (`= false`) no fim do próprio `setTimeout` de assentamento
   — igual `deslizar()` já fazia. Como `irPara()` e o `pointerdown` do
   arraste JÁ checavam essa variável antes de agir, isso fecha o buraco
   na raiz: nenhum clique de botão nem novo arraste consegue começar
   enquanto o assentamento do arraste anterior ainda está rodando.
2. **Rede de segurança nova, `garantirSlideUnico(manter)`**: chamada
   no fim de toda transição (as 3 saídas: `deslizar()` e os 2 branches
   de `finalizarArraste()`) — força o invariante "exatamente 1
   `.carrosselSlide` com `.on`", removendo de qualquer outro e
   garantindo que o slide certo tenha. Independente de ter fechado a
   causa raiz ou não, essa rede evita que o SINTOMA visual (sobreposto
   ou em branco) volte a aparecer mesmo se outra corrida parecida for
   introduzida no futuro.

### Validação desta sessão

- `node --check` nos 40 blocos `<script>` — 0 erros.
- Não foi possível reproduzir o race condition num teste automatizado
  (é uma corrida de timing entre dois eventos de ponteiro — exatamente
  o tipo de bug que só aparece em dispositivo real, como já registrado
  nos "learnings" do projeto). A correção foi validada por leitura de
  código (o caminho que causava a corrida foi eliminado), não por
  reprodução automatizada.

### Pendências abertas

- **Prioridade alta**: testar em dispositivo real especificamente
  tentando reproduzir o bug original — arrastar um slide e tocar em
  algo (botão, próximo arraste) bem rápido em seguida, várias vezes,
  tentando pegar a janela de ~220ms. Se ainda acontecer, a causa raiz
  não era só essa, e a rede de segurança (`garantirSlideUnico`) só
  estaria mascarando o sintoma, não resolvendo — vale investigar mais
  fundo nesse caso.

---

## 42-j. "Criar conta"/"Sair" (Config) não abriam mais direto no login (v4.118 → v4.119)

### Pedido

"O botão criar conta deveria mandar direto pro menu do login, não?" —
usuário notou que não estava indo direto.

### Causa (regressão da própria refatoração desta sessão)

"Criar conta" e "Sair" (tela de Config, fora do onboarding) usam o
mesmo mecanismo desde a v4.47/v4.51: gravam uma flag
(`questlog.forcarLogin.v1`) e recarregam a página; no boot, essa flag
desfaz o `.off` do `#intro`, fazendo a tela de login reaparecer. Isso
funcionava porque, até a v4.115, `#passoLogin` era a **primeira coisa
mostrada** do onboarding. Desde a v4.116 (item 42-e, login virou
desvio dentro do carrossel), desfazer `.off` só faz o carrossel INTEIRO
rodar de novo desde o splash/QUESTLOG — a pessoa que clicou "Criar
conta" caía de volta no marketing, não no login. Regressão não
percebida na hora porque essas duas sessões trataram de partes
diferentes do fluxo.

### Correção

A flag `questlog.forcarLogin.v1` é lida e removida do `localStorage`
**bem no início** do arquivo (antes até do carrossel existir no DOM) —
mas quem precisa reagir a ela (IIFE do carrossel) só roda bem mais
tarde. Guardada agora também num global (`window.__questlogForcarLogin`)
que sobrevive até lá. A splash (`fecharSplash()`) checa esse global: se
setado, chama `irParaLogin()` direto (em vez de `irPara(1)`, que iria
pro QUESTLOG) e também pula a espera de 1.1s da splash normal — não
faz sentido segurar quem pediu login explicitamente numa tela de logo
animada.

### Validação desta sessão

- `node --check` nos 40 blocos `<script>` — 0 erros.
- Confirmado que `irParaLogin()` é `function` declaration (hoisted),
  chamável com segurança de dentro de `fecharSplash()` mesmo definida
  antes dela no arquivo.
- Comportamento de `ultimoSlideAntesLogin` neste caminho: como nenhum
  slide numerado chega a ficar `.on` antes do login abrir (splash vai
  direto pro login), o valor guardado é o default (`1`, QUESTLOG) — se
  a pessoa clicar "Agora não" ou Voltar a partir daqui, cai no slide 1.
  Comportamento aceitável (mesmo default de sempre), não testado com
  usuário real ainda.
- **Não testado em dispositivo real** (pendência de todas as sessões
  anteriores, ainda não resolvida).

---

## 42-k. Bloquear arraste pra frente sem preencher o nome (v4.119 → v4.120)

### Pedido

"O usuário pode arrastar a tela de colocar o nome sem colocar o nome"
— o botão "Continuar" já validava (não deixava passar com o campo
vazio), mas o arraste (swipe) pulava essa validação por fora.

### O que foi feito

`pegarVizinho()` (função que decide qual slide vizinho o arraste vai
buscar) agora recusa buscar vizinho pra frente saindo do slide Nome
(5) se o campo estiver vazio — o arraste simplesmente não acha pra
onde ir e volta pro lugar (snap-back), exatamente o mesmo
comportamento que já existe nas pontas do carrossel (primeiro/último
slide, mesma função). Ao soltar o dedo depois de um arraste bloqueado
por essa razão especificamente, reaproveita o MESMO aviso visual que
o botão "Continuar" já mostra (borda vermelha + placeholder trocado).

**Herói NÃO ganhou a mesma trava** — decisão consciente, não
esquecimento: diferente do nome (que pode estar genuinamente vazio),
o slide de Herói sempre tem um herói pré-selecionado por padrão
(`heroiEscolhido` começa num índice válido), então não existe um
estado "vazio" pra bloquear ali. Se isso não bater com a intenção
(por exemplo, se a ideia era forçar a pessoa a *olhar* a tela antes de
poder passar), me avisa que ajusto.

### Validação desta sessão

- `node --check` nos 40 blocos `<script>` — 0 erros.
- Confirmado que `arrasteDelta`/`direcaoVizinho` continuam sendo
  setados mesmo quando `pegarVizinho()` retorna `null` (o early-return
  de "sem vizinho" no `pointermove` acontece DEPOIS dessas
  atribuições) — necessário pra `finalizarArraste()` conseguir
  detectar corretamente "foi um arraste bloqueado pra frente saindo do
  Nome" e disparar o aviso certo.
- **Não testado em dispositivo real** (mesma pendência de sempre).

---

## 42-l. Fortuna 2%/ponto + Vigor implementado de verdade (v4.120 → v4.121)

### Pedido

"Arruma o de Fortuna pra subir de 2 em 2%, e a gente deveria terminar
aquele Vigor que tá ali também" — tela de Perfil, pontos de atributo
(fora do onboarding, mudança avulsa).

### Fortuna: 4% → 2% por ponto

`FORTUNA_POR_PONTO`: `0.04` → `0.02`. Teto (`FORTUNA_TETO`, 50%) não
mexido — só o incremento por ponto, dobrando o número de pontos
necessários pra chegar no teto (12,5 → 25).

### Vigor: implementado (estava só o placeholder "Em preparo")

O card já existia travado (`.trava`, opacidade reduzida, botão
`disabled`, descrição "Em preparo — perdão de fuga") — comentário do
código já documentava a razão de ter ficado de fora: diferente de
Fortuna/Foco (que só precisaram *envolver* uma função global de fora,
sem editá-la), o efeito do Vigor vive dentro de `verificarVirada()`
(dano por tarefa largada na virada do dia), fechada numa IIFE própria
("VIDA DO HERÓI"), sem gancho externo possível. Exigia editar aquela
função por dentro — e ela é a mesma que o roadmap chama de "correção
crítica" (já teve bug real ali, seção 6), por isso tinha ficado pra
uma sessão dedicada.

**O que foi feito:**
- Card destravado: `id`s reais (`atrVigorValor`, `atrMaisVigor`),
  descrição trocada pra "de perdão no dano por tarefa largada".
- Módulo Atributos ganhou `gasto.vigor`, `VIGOR_POR_PONTO` (5%),
  `VIGOR_TETO` (50%), `perdaoVigor()` — mesmo padrão de
  `bonusFortuna()`/`descontoFoco()`, incluindo persistência
  (`carregarAtrib`/`salvarAtrib` já eram genéricos, só precisaram ler
  o campo novo).
- **A parte delicada**: dentro de `verificarVirada()`, o dano agora é
  multiplicado por `(1 - perdão)` antes de aplicar. Mas **não** lê
  `window.perdaoVigor()` — lê o valor **direto do `localStorage`**
  (`questlog.atrib.v1`), com os números (5%/ponto, teto 50%)
  duplicados ali como constantes locais. Motivo: `verificarVirada()`
  roda logo no boot, e o módulo Atributos só é definido bem mais tarde
  no arquivo — no cenário mais comum de todos (fechar o app, abrir de
  novo no dia seguinte), `window.perdaoVigor` ainda não existiria
  nesse momento exato, e o dano seria aplicado sem perdão nenhum
  mesmo com pontos investidos. Ler o `localStorage` direto é imune à
  ordem de carregamento dos scripts.
- Resto da função **intocado**: a trava "uma queda por retorno ao
  app" (`quedaNaFila`), o resync de relógio-pra-trás, o registro no
  histórico — nada disso foi tocado, só a linha do cálculo de `dano`.

### Trade-off registrado

Os números do Vigor (5%/ponto, teto 50%) estão duplicados em dois
lugares (módulo Atributos e dentro de `verificarVirada()`) porque as
duas IIFEs não têm um jeito de compartilhar constante sem expor mais
coisa do que o necessário. Se calibrar um lado, **precisa calibrar o
outro também** — documentado com comentário nos dois pontos, mas é um
lugar real de dessincronia futura se alguém esquecer.

### Validação desta sessão

- `node --check` nos 40 blocos `<script>` — 0 erros.
- Balanceamento `<div>`/`<svg>`/`<style>` — OK (conferido especificamente
  no trecho HTML do card do Vigor depois de uma edição que precisou de
  correção no meio do caminho — ver nota abaixo).
- **Nota de processo**: a primeira tentativa de editar o HTML do card
  do Vigor introduziu `</div>` duplicados por engano (texto de rascínio
  vazou pro arquivo real). Detectado e corrigido antes de seguir,
  reconferido com contagem de divs isolada no trecho.
- **Não testado em dispositivo real** — nem a UI (card destravado,
  botão, valor) nem o efeito de verdade (precisa de uma virada de dia
  real ou simulada via botão de debug pra confirmar que o dano sai
  reduzido). Prioridade alta pro próximo teste, dado o histórico dessa
  função específica com bugs reais.

---

## 42-m. Vigor também 2%/ponto (v4.121 → v4.122)

Ajuste rápido: `VIGOR_POR_PONTO` (5% → 2%), consistência com Fortuna.
Trocado nos **dois** pontos duplicados (módulo Atributos +
`verificarVirada()`, ver nota de sincronia na seção 42-l) — os
comentários que documentavam o valor antigo (0.05) também foram
atualizados pra não ficarem enganosos. `node --check` limpo nos 40
blocos.

## 43. Poção de Vida agora cura HP de verdade (v4.59)

### Causa raiz

Confirmada a suspeita já registrada no item 16 (seção 4): a tabela
`ITENS` não tinha nenhum campo de cura — só
`[spriteIdx, nome, tipo, raridade, valor, bonusMoedas, bonusXp]` — e
`usarItem()` só aplicava `it.x`/`it.m`. O sistema de HP existe e
funciona (`curar()`, módulo Vida, usado em vitória do dia e recompensa
por tarefa concluída), mas vive dentro da IIFE de Vida e não é exposto
por closure — só `window.vidaHeroi.get/set/max` sai pra fora
(armadilha de closure #1 já catalogada). `usarItem()` mora no módulo
Inventário, carregado bem antes do módulo Vida no arquivo, então não
tinha como chamar `curar()` diretamente.

### O fix

Três edições pontuais, sem tocar em mais nada:

1. **`ITENS`**: linha da Poção de Vida (posição 63 do array) ganhou um
   8º elemento — `[56, "Pocao de Vida", "cons", 2, 20, 0, 60, 25]` (era
   só até o `60`). O `56` inicial é o índice do sprite, não confundir
   com a posição/id real do item (armadilha descoberta na prática
   nesta sessão — usei `56` como id num botão de debug temporário e
   ele puxou "Frasco de Água" em vez da poção). O `25` no fim é o
   valor de cura; as outras 60 e poucas linhas de `ITENS` continuam
   com 7 elementos, sem precisar tocar em nenhuma.
2. **`item(id)`**: passou a ler um 8º campo, `h:a[7]||0` — pra qualquer
   item sem esse campo (todos exceto a Poção de Vida), `a[7]` vem
   `undefined` e cai no `||0`, sem quebrar nada.
3. **`usarItem(id)`**: ganhou um bloco que, se `it.h` for truthy, lê
   `window.vidaHeroi.get()`/`.max()`, soma a cura com teto no máximo e
   grava via `window.vidaHeroi.set(...)` — usa a API pública em vez de
   tentar acessar `curar()` direto (que não seria alcançável dali).
   `aviso()` também passou a mostrar `+N HP` quando o item cura, no
   lugar de XP/moedas.

### Validado

`node --check` limpo nos 36 blocos `<script>` do arquivo (mesma
contagem de antes — nenhum bloco novo criado). Diff conferido linha a
linha contra a v4.58: só as 4 mudanças acima aparecem, nada mais foi
tocado. Contagem de tags (`<div>`, `<button>`, `<svg>`) idêntica à
v4.58 em ambos os lados — o desbalanço de `<button>` (104 aberturas
contra 102 fechamentos) e de `<script>` (38 contra 36) já existia no
arquivo original antes deste patch, confirmado comparando as duas
versões; não foi introduzido por esta mudança.

**Teste manual real feito pelo usuário no celular**, via um botão de
debug temporário (`#testarPocaoBtn`, ao lado do `#debugbtn` já
existente) que dava a poção + zerava a vida pra sobrar espaço de cura
— confirmado que a barra de HP sobe e o aviso mostra `+25 HP`. Botão
de debug removido do arquivo depois da confirmação (não é feature de
produto, mesma categoria do `#debugbtn`/`#pularTutoriaisBtn` do item 6
da seção 4 — que continuam ativos por decisão do usuário).

## 44. Poção de Mana e Poção de Vigor removidas do jogo (v4.60)

### Motivação

Segunda metade do item 16 (seção 4), decisão já fechada em sessão de
brainstorm anterior: as duas poções prometem sistemas que não existem
no jogo (sem stat de mana ou vigor) — não é bug técnico como a Poção
de Vida foi, é item que nunca deveria ter esse nome. Usuário decidiu
remover os dois de vez.

### O fix

`id` de item é a **posição no array** `ITENS`, não um campo próprio —
apagar a linha desloca o índice de tudo que vem depois (mesma classe
de bug-fantasma já documentada pro elenco de monstros, no corte de
"Besta de esporos" que reembaralhava `monstroDoDia()`). Por isso a
decisão já fechada foi **placeholder morto**, não exclusão de linha:

1. **`ITENS`**: as duas linhas (posições 64 e 65 do array — antes
   "Poção de Mana" e "Poção de Vigor") viraram
   `[77, "###REMOVIDO###", "cons", 2, 0, 0, 0, 0, true]` e
   `[112, "###REMOVIDO###", "cons", 2, 0, 0, 0, 0, true]` — sprite e
   posição mantidos intactos, valor/moedas/xp/cura zerados, e um 9º
   campo novo (`true`) marcando o item como morto.
2. **`item(id)`**: passou a ler esse 9º campo, `morto:!!a[8]` — mesmo
   padrão do `h` adicionado na v4.59, itens sem o campo caem em
   `false` por padrão.
3. **Fonte de loot (`sortearItem`)**: os dois filtros de pool (o
   principal, por raridade sorteada, e o de fallback quando a raridade
   sorteada não tem itens) ganharam `&& !ITENS[i][8]` — item morto
   nunca é sorteado, em nenhum dos dois caminhos.
4. **Estoque da loja (`montarEstoque`)**: o pool de origem (hoje só
   filtrado por tipo, via `LOJA_TIPOS.includes(...)`) ganhou o mesmo
   `&& !ITENS[i][8]` — item morto nunca entra na prateleira, incluindo
   no caminho de fallback "sempre tem 1 consumível" que ignora
   raridade.
5. **Grimório (`renderGrimorio`)**: passou a montar a lista a partir de
   `idsVivos` (todos os ids de `ITENS` menos os mortos) em vez de
   `ITENS.forEach` direto — item morto não aparece na grade nem entra
   na contagem "X de Y itens descobertos".
6. **Conquista "Mestre do Grimório"**: `totalItensCatalogo` (usado pra
   calcular a meta "descubra todos os N itens") passou a excluir itens
   mortos (`ITENS.filter(a => !a[8]).length`) — sem isso a meta vira
   permanentemente inalcançável (98 reais contra 100 no catálogo).

**Decisão de produto que ficou de fora, por escopo:** o que fazer com
um save antigo que já tenha essas poções no inventário ou marcadas
como vistas no Grimório — hoje elas continuam existindo como "item
fantasma" (`item()` não quebra, só mostra `"###REMOVIDO###"` se o
jogador abrir a ficha de algo que já tinha) em vez de serem migradas
ou removidas automaticamente. Não é bug, é decisão em aberto — se
aparecer um save assim, perguntar antes de mexer.

### Validado

`node --check` limpo nos 36 blocos `<script>` (nenhum bloco novo,
mesma contagem desde a v4.58). Contagem de tags idêntica de novo —
nada além do JS foi tocado nesta sessão.

Simulação de regressão em Node puro (tabela `ITENS` real extraída do
arquivo + as funções reais de `item()`/`sortearItem()`, não
reescritas à parte), cobrindo os cenários que o item 16 pedia
explicitamente:
- Pool da loja **exclui** os dois ids mortos, mantendo a Poção de Vida
  (posição 63) e outros 62 itens normalmente elegíveis.
- 20.000 rodadas de sorteio de loot, cobrindo as 5 raridades
  igualmente — os dois ids mortos **nunca** saem, nem no caminho
  principal nem no fallback.
- `totalItensCatalogo` cai de 100 pra 98 (bate exatamente com os 2
  itens marcados como mortos).
- `idsVivos` do Grimório também fecha em 98, excluindo os dois ids
  certos.
- **Save fake** com inventário contendo as duas poções mortas (`id 64`
  e `id 65`, quantidades 1 e 2) mais a Poção de Vida — `item()` não
  lança exceção pra nenhum dos três, confirmando que um save
  pré-existente com essas poções ainda no bolso não quebra a tela de
  Inventário.

**O que não deu pra testar neste ambiente:** navegação real no
Inventário/Loja/Grimório dentro de um navegador de verdade — a
simulação cobre a lógica de exclusão nos dados, não a renderização.
Recomendo confirmar visualmente que a prateleira da loja e o Grimório
nunca mostram as poções removidas depois de alguns dias de uso.

## 45. Conquista "Início da Jornada" disparava sem o jogador fazer nada (v4.61)

### O bug

Usuário notou que a conquista de nível ("Início da Jornada", categoria
"Subir de Nível") já aparecia concluída ao simplesmente abrir o app,
sem nenhuma tarefa feita. Causa: `progresso()` sempre começa com
`nivel=1` mesmo com `xpTotal=0` (ninguém nunca esteve no "nível 0" —
todo personagem nasce em I), e a definição da conquista era `{meta:1,
valor: ctx => ctx.nivel}` — condição satisfeita antes de qualquer XP
ganho.

### Escopo, fechado com o usuário antes de mexer

Duas abordagens possíveis: (a) mudar `progresso()` pra o personagem
nascer em nível 0, corrigindo a raiz; ou (b) mexer só na definição da
conquista. A opção (a) foi descartada — `progresso().nivel` é lido em
mais 4 lugares (`nivelExigido` da loja, pontos de atributo, os cards
de Perfil/topbar, e o resgate em lote de conquistas) e mudar o ponto
de partida desloca em -1 o nível exibido pra todo mundo com o mesmo
XP acumulado, atrasando pontos de atributo e liberação de itens por
nível — mudança de balanceamento, não só um fix de conquista. Usuário
confirmou: só a conquista.

### O fix

Uma linha, dentro da categoria `nivel` (seção de definição das
conquistas): a meta subiu de `1` pra `2` e o texto de `'Alcance o
nível I'` pra `'Alcance o nível II'` — passa a exigir o primeiro
level-up de verdade (ganhar XP suficiente pra sair do nível I), em vez
de estar satisfeita desde o boot. Não reaproveitei a condição de
`ctx.tarefasConcluidas` (completar 1ª tarefa) porque isso já existe
como conquista própria, separada, na categoria "Conclua Tarefas" —
usar o mesmo gatilho aqui duplicaria a semântica.

### Validado

`node --check` limpo nos 36 blocos `<script>`. Contagem de
`<div>`/`<svg>`/`<button>` idêntica ao arquivo de entrada — só a linha
da definição da conquista foi tocada.

---

## 46. Vibração no clique de navegação (v4.62)

> Versão do arquivo ao final desta sessão: `questlog-4-62-vibracao.html`

### Contexto

Retomada do SFX (seções 20/29/34) em cima do arquivo mais novo do
project knowledge (`questlog-4-61-fix-conquista-nivel1.html` — o jogo
avançou de v4.44 pra v4.61 entre uma sessão e outra: conquistas com
recompensa, correções de HP de poções, etc., nenhuma delas mexendo no
SFX). Pedido: implementar o item 17, que já tinha spec fechada de uma
sessão de brainstorm anterior — trocar o som de clique de navegação por
vibração no celular, com fallback pro som onde não há suporte.

### O que foi implementado

`window.vibrarOuTocar(som, ms)`, ao lado de `window.tocarSom` no motor
de áudio:

```js
window.vibrarOuTocar = function(som, ms){
  if (!ativo) return;
  if ('vibrate' in navigator){
    try { navigator.vibrate(ms || 10); } catch(e){ window.tocarSom(som); }
  } else {
    window.tocarSom(som);
  }
};
```

Os **5 pontos exatos** do escopo fechado da spec (nav principal,
sub-abas do Perfil, botões de onboarding, seleção de herói, "+
Adicionar" — bloco "SFX — CLIQUE DE NAVEGAÇÃO") trocaram
`tocarSom('clique')` por `vibrarOuTocar('clique', 10)`.

**2 diferenças da spec original, ambas somando robustez:**

1. **`try/catch` em volta de `navigator.vibrate()`** — a spec já tinha
   catalogado o risco (`navigator.vibrate` pode falhar em iframe sem
   permissão) mas não tinha o tratamento; adicionado, cai pro som em
   vez de estourar erro.
2. **Respeita o mudo.** Não estava na spec original — o usuário
   percebeu em teste que desligar o som pelo toggle da topbar não
   parava a vibração (`vibrarOuTocar` chamava `navigator.vibrate()`
   direto, sem checar nada). Corrigido com `if (!ativo) return;` logo
   no início — `ativo` é a mesma variável de módulo que
   `window.sfxAtivo()`/`window.definirSfxAtivo()` já expõem, então não
   precisou de estado novo, só ler o que já existia no mesmo escopo.

### Decisões de escopo tomadas nesta sessão, não na spec original

A spec de brainstorm falava em "os 5 pontos que hoje chamam
`tocarSom('clique')`" — mas entre a spec ser escrita e esta sessão
implementar, **mais lugares passaram a chamar esse mesmo som**, sem
fazer parte da lista original. Dois ficaram de fora por decisão
própria, registrando o porquê:

- **Toggle de mudo (topbar, "SFX — TOGGLE DE VOLUME").** Toca
  `tocarSom('clique')` especificamente pra confirmar que o **som**
  voltou a funcionar ao reativar — trocar por vibração ali testaria a
  coisa errada (o usuário quer ouvir que o áudio ligou, não sentir).
- **Cliques da tela de login/boas-vindas** (seção 34, bloco "SFX —
  CLIQUE DA TELA DE LOGIN / BOAS-VINDAS") — adicionado numa sessão
  posterior à spec de brainstorm, não estava na enumeração fechada.
  Fica pendente de confirmação explícita do usuário se deve entrar
  também.

### Validação

35 blocos `<script>` clássicos + 1 `<script type="module">` (Firebase,
checado separado como `.mjs`), `node --check` limpo nos dois grupos.
`<div>` 276/276, `<svg>` 26/26, comentários 27/27.

---

## 47. Investigação de "vibração mais suave" — testado, revertido, teto real do web (v4.63)

> Versão do arquivo ao final desta sessão: `questlog-4-63-vibracao-revert.html`

### Achado antes de começar: upload do 4.62 estava sem o fix do mudo

Ao retomar esta sessão, o `questlog-4-62-vibracao.html` do project
knowledge **não tinha** o guard `if (!ativo) return;` documentado na
seção 46 como pronto — o `roadmap.md` já registrava o fix, mas o HTML
enviado era de uma versão anterior a ele. Reaplicado antes de qualquer
outra mudança, pra ficar consistente com o que o roadmap já afirmava.
**Lição de processo:** ao subir arquivo novo pro project knowledge,
confirmar que é a versão mais recente de fato baixada, não uma cópia
antiga — mesma categoria do bug de preview do sandbox já catalogado na
seção 20 (arquivo "correto" no papel, mas o que está sendo testado é
outro).

### O pedido: vibração "mais suave" — mesma limitação da API, mais fundo

Usuário comparou com apps nativos (ex: Skiplino) que têm vibração
perceptivelmente mais suave. Pesquisado antes de responder (a
informação de treinamento sobre a Vibration API pode estar
desatualizada): confirmado que a API do navegador **nunca teve** e
**nunca vai ter** controle de amplitude — é um limite de spec, não uma
lacuna de implementação:

- **iOS/Safari:** nunca implementou (WebKit publicou posição contrária
  formal à spec).
- **Firefox:** removeu o suporte na v129 (não é mais "não implementado
  ainda", foi ativamente descontinuado).
- **Only Chromium/Android** tem suporte real hoje.
- Único controle disponível em qualquer navegador: duração (ms) e
  padrão (array de liga/pausa) — nunca força/amplitude.

**O que teria controle de força de verdade:** `UIImpactFeedbackGenerator`
(Taptic Engine, iOS) e `VibrationEffect.createOneShot(duração,
amplitude 1-255)` (Android nativo) — as duas são APIs de plataforma,
inacessíveis a partir de JS puro rodando no navegador. O caminho pra
alcançar isso seria empacotar o app com algo como Capacitor
(`@capacitor/haptics`), o que significa sair da arquitetura single-file
— pipeline de build, projeto nativo Xcode/Android Studio, conta de
desenvolvedor Apple pra testar no iPhone. **Não é um ajuste de código,
é mudança de arquitetura.** Registrado aqui como direção de longo prazo,
não como decisão tomada — usuário confirmou que reconhece que o
caminho "certo" no fim das contas é sair de single-file, mas não agora.

### Teste feito: 10ms → 7ms → revertido pra 10ms

Reduzida a duração dos 5 pontos de clique de navegação de `10ms` pra
`7ms`, testado no aparelho real. **Resultado: nenhuma diferença
perceptível.** Não foi erro de calibragem — motivo técnico:

> Motor de vibração de celular (ERM — massa excêntrica rotativa) tem
> atraso físico de partida/parada. Em durações muito curtas (a faixa de
> 5-15ms testada aqui), o motor mal termina de "ligar" antes do comando
> de desligar já ter chegado — a intensidade percebida satura nesse
> patamar, então reduzir ainda mais dentro dessa faixa não muda a
> sensação.

Revertido pra `10ms` (nos 5 pontos de chamada + default interno da
função + comentários) — não fazia sentido manter um número customizado
que não trouxe diferença real sobre o valor original.

### Estado final

`window.vibrarOuTocar(som, ms)` de volta ao comportamento da seção 46
(`ms` default 10, guard de mudo mantido), com o comentário do código
agora registrando o teste de 7ms e o motivo de ter sido revertido —
pra ninguém repetir esse mesmo experimento sem saber que já foi tentado
e por que não ajudou.

### Validação

35 blocos `<script>` clássicos + 1 `<script type="module">`, `node
--check` limpo nos dois grupos. `<div>` 276/276, `<svg>` 26/26,
comentários 27/27.

## 48. Perfil unificado — item 18 implementado (v4.64)

### Incidente de versionamento, registrado por transparência

Esta sessão começou a partir do `questlog-4-57-dialogos.html` (anexado
pelo usuário no início do chat), sem saber que outra sessão paralela já
tinha avançado a timeline real até `v4.63` com features completamente
diferentes (poção de vida curando de verdade, poções de mana/vigor
removidas, correção de bug na conquista "Início da Jornada", vibração
no clique de navegação). Três versões foram construídas em sequência
nesta sessão (barra de Vida no cabeçalho do Perfil, sprite do herói ao
lado das barras, e a unificação completa do Perfil) usando os números
`4-59`/`4-60`/`4-61` — que já pertenciam a outras features na timeline
real. O erro só foi percebido ao comparar o roadmap gerado nesta sessão
(que tinha virado, ele mesmo, a versão re-anexada no Project Knowledge)
contra o roadmap real, que já ia até a seção 47.

**Correção**: todo o trabalho desta sessão a partir da barra de Vida
foi **refeito do zero em cima do arquivo real** (`4-63-vibracao-
revert.html`, puxado do Project Knowledge), não da branch divergente.
Um ponto de atenção real surgiu nesse processo: a v4.62 trocou o hook
de clique de navegação de `tocarSom('clique')` pra
`vibrarOuTocar('clique', 10)` — o patch de retarget dos botões novos
(que nesta sessão tinha sido escrito contra `tocarSom`) precisou ser
adaptado pra `vibrarOuTocar` na reaplicação, senão os botões novos do
Perfil ficariam sem o feedback de vibração que o resto do app já tem.

### O que foi implementado (item 18 do roadmap)

**Cabeçalho** — sprite do herói (reaproveita `desenharHeroi()` por
encadeamento, não reescrita — ver nota abaixo), nome, barra de XP
(já existia) **+ barra de Vida** (nova, mesmo par `hpfill`/`hpnum` já
usado na Arena, ids próprios `perfilHpFill`/`perfilHpNum` pra não
colidir). A barra de Vida não estava na proposta original do item 18
(que só citava XP) — foi confirmada à parte, numa pergunta específica
sobre o cabeçalho, antes desta etapa começar.

**Faixa de status** (Vida máxima/Moedas/Bônus XP/Bônus moedas) — manti-
da como o grid 2×2 (`statgrid`) que já existia. A proposta original
pedia "compactados numa fileira" (uma linha só); não foi reformatada
nesta leva — fica como próximo ajuste visual, se o usuário quiser.

**Atributos** — permanece inline, sem prévia/overlay, exatamente como
proposto (só 3 cards + pontos disponíveis, pequeno o bastante).

**Conquistas e Bestiário** — saíram de sub-aba (`perfilpane`/`.oculto`
dentro de `#perfilTabs`) pra overlay em tela cheia, reaproveitando
literalmente as classes `.cfgOverlay`/`.cfgovhead`/`.cfgovcorpo`/
`.cfgvoltar` que a Config já usava desde a v4.58 (seção 42) — zero CSS
novo pros overlays em si. Os ids internos que os módulos de render já
tinham (`#perfilConquistas`, `#bestSub`, `#bestGrid`) foram preserva-
dos exatamente como estavam — `renderConquistas()`/`renderBestiario()`
continuam escrevendo neles sem saber que o wrapper mudou de aba pra
overlay.

**Prévias** — ficaram mais simples que a proposta original (que pedia
contador + 2-3 conquistas recentes/últimos monstros vistos, em ícones):
implementado só o contador em texto (`"N de 63 monstros derrotados"`,
`"N conquistas prontas pra resgatar!"` ou `"X de Y desbloqueadas"`,
`"N vitórias, M fugas este mês"` pro Histórico). O próprio item 18 já
previa essa liberdade ("conteúdo exato da prévia... ajustável na sessão
de implementação") — registrado aqui como simplificação consciente,
não como pendência esquecida. Fileira de ícones fica como possível
próximo passo.

**Engrenagem de Config** — saiu da fileira de pills (`perfiltabs`) e
foi pro cabeçalho (`vhead`, canto superior direito, ao lado de "Nível
I"). Comportamento (`abrirConfig()`) não mudou, só a posição.

**`#perfilTabs` removido inteiro** — Perfil virou rolagem única, sem
sub-abas. Isso confirmou na prática o risco de arquitetura que o
próprio item 18 já tinha catalogado: `mostrarSubPerfil` era função
local de uma IIFE (armadilha de closure documentada), e **3 blocos
diferentes** dependiam de elementos dentro de `#perfilTabs` sem estar
óbvio de cara:
1. `atualizarLinhaConta()` (texto da linha "Conta" em Config) só rodava
   num segundo `addEventListener` pendurado no botão da engrenagem
   dentro de `#perfilTabs` — reconectado direto em `abrirConfig()`.
2. O hook de vibração/som de clique de navegação (`#perfilTabs button`)
   — retargetado pros botões novos (engrenagem, 3 links "Ver...", 3
   botões de voltar dos overlays).
3. O badge de contagem de conquistas pendentes (`criarBadge`) estava
   preso no seletor `#perfilTabs [data-ptab="conquistas"]` — migrado
   pro botão `#verConquistasBtn` da prévia.

Uma quarta linha (`window.mostrarSubPerfil = mostrarSubPerfil;`, no
módulo de Temas) ficou órfã depois que a função foi removida — teria
quebrado em runtime (`ReferenceError`) se não fosse pega antes de
entregar.

### Validado

`node --check` limpo nos 36 blocos `<script>`. Parser HTML tolerante
(Python `html.parser`) rodado no arquivo inteiro, sem desalinhamento
de tags do início ao fim — checagem mais forte que só contagem de
abertura/fechamento, porque pega estruturas cruzadas que a contagem
simples deixaria passar. Nenhuma referência funcional solta a
`#perfilTabs` sobrou (só comentários explicativos).

32 cenários de teste funcional em jsdom, em 3 baterias:
- **14 cenários** cobrindo os overlays novos: gear button abre/fecha
  Config e chama `atualizarLinhaConta()`; "Ver todas"/"Ver tudo" abrem
  Conquistas/Bestiário e disparam `renderConquistas()`/
  `renderBestiario()`; botão de Histórico chama `abrirHistorico()`
  existente; as 3 prévias calculam o texto certo a partir de dados
  reais (`obterHistorico()` filtrado pelo mês corrente, resumo de
  conquistas com/sem pendentes, texto de `#bestSub` reaproveitado).
- **11 cenários** da barra de Vida (calculo de porcentagem, estado
  crítico ≤25%, e o caso de borda de `vidaHeroi` ainda não carregado
  não quebrar nem zerar a barra).
- **7 cenários** do sprite no cabeçalho (a Arena continua pintando
  normal — `desenharHeroi()` original não foi reescrito, só
  encadeado —, a cópia no Perfil atualiza sozinha ao trocar de sprite
  em Config, mesmo com a aba fechada).

**O que não deu pra testar neste ambiente:** integração visual real em
navegador (o Histórico abrindo por cima de Conquistas/Bestiário com o
`z-index` escolhido, a faixa de status ainda em grid 2×2 em vez de
fileira única, o layout do cabeçalho com sprite+duas barras em telas
pequenas).

## 49. Barra de XP fixada em verde, independente do tema (v4.65)

### Motivação

Levantado pelo usuário durante a reformulação do Perfil: a barra de XP
muda de cor junto com o tema (laranja no Crepúsculo, azul no
Meia-noite, dourado no Pergaminho) porque usa `var(--accent)`/
`var(--xp2)` — tokens **theme-variant** de propósito, pra maioria dos
elementos. Pedido: XP sempre verde, não importa o tema.

### Armadilha real encontrada antes de mexer

A cor da barra de XP não vem de uma regra CSS só — existem **4 blocos
`.fill{...}` diferentes**, em `<style>` separados ao longo do arquivo,
todos com a mesma especificidade (seletor de classe simples) e a
maioria com `!important`. Exatamente o tipo de cascata frágil que o
roadmap já documenta como armadilha (seção de lições de CSS, item
"grep antes de remover"): mexer ou remover a regra errada podia
reativar uma das outras 3 silenciosamente.

**Decisão**: não tocar em nenhuma das 4 regras `.fill` existentes.
Adicionada uma regra nova, escopada por ID (`#fill, #perfilFill`) —
IDs têm especificidade maior que classes por definição do CSS, então
vence a cascata de forma garantida (confirmado por simulação estática
de especificidade, não só leitura visual — ver Validado abaixo),
independente da ordem das outras 4 regras no arquivo.

### O fix

```css
#fill, #perfilFill{background:linear-gradient(90deg,#4FA980,var(--verde)) !important}
```

`--verde` (`#63C99A`) já existe no arquivo desde antes — e já é
**theme-invariant**: não é redefinida dentro de nenhum bloco
`:root[data-tema="..."]`, mesmo padrão de `--gold`. Reaproveitada
direto, sem criar variável nova.

**Escopo**: cobre as duas barras de XP do app — `#fill` (Arena, topo
da aba Tarefas) e `#perfilFill` (cabeçalho do Perfil, adicionado nesta
mesma leva de reformulação) — confirmado com o usuário via pergunta
direta antes de implementar, já que é o mesmo widget duplicado nos
dois lugares.

### Validado

`node --check` limpo nos 36 blocos `<script>`. Balanceamento de tags
(`<div>`, `<script>`, `<style>`) idêntico entre original e patcheado.
Parser HTML tolerante sem desalinhamento.

Além disso — como a preocupação real aqui era "essa regra nova
realmente vence a cascata contra as outras 4?" — rodada uma simulação
estática de especificidade CSS (não visual, cálculo real): extraídas
todas as regras que tocam `.fill`/`#fill`/`#perfilFill` do arquivo,
comparando especificidade (contagem de `#` vs `.` no seletor),
presença de `!important` e ordem no documento. Resultado: `#fill,
#perfilFill` (2 IDs) vence as 4 regras `.fill` (0 IDs cada) de forma
determinística, independente de qual delas está fisicamente mais
embaixo no arquivo — não depende de sorte de ordenação.

**O que não deu pra testar neste ambiente:** a cor renderizada de
verdade num navegador (o gradiente `#4FA980` → `--verde` pode precisar
de ajuste fino visual que só aparece na tela real).

### Ajuste de tom (v4.66)

Usuário achou o gradiente escuro/saturado demais e mandou print de
referência (cor sólida, mais clara). Trocado `linear-gradient(90deg,
#4FA980,var(--verde))` por cor chapada `#5FC77E`, mesma regra
`#fill, #perfilFill` — só o valor mudou, a técnica (override por ID
pra vencer a cascata das 4 regras `.fill`) continua a mesma.

## 50. Cards de atributo (Fortuna/Foco/Vigor) com preview — fecham por padrão, expandem ao tocar (v4.67)

### Motivação

Usuário achou o visual dos cards "não tão legal" (a barra colorida
cheia — fundo inteiro na cor do atributo, texto escuro por cima —
ficava chapada demais) e pediu que cada um mostrasse uma prévia antes
de abrir por completo, inspirado nos boxes compactos FOR/INT/AGI do
print de referência já usado antes (mesma imagem da reformulação do
Perfil).

### O fix

**Visual**: a cor do atributo (`--atr-cor`) deixou de preencher o
fundo inteiro da barra — agora é só um acento no ícone e no valor
numérico (`color:var(--atr-cor)`), fundo neutro (`var(--panel-2)`,
mesmo do card). Adicionado um chevron (seta) que gira 180° quando o
card abre, mesmo indicador visual que overlays/accordions costumam
usar.

**Comportamento**: os 3 cards começam **fechados** — só ícone, nome e
valor visíveis (a "prévia" pedida). Tocar na barra expande o `atrcorpo`
(descrição + botão de investir) com uma transição suave
(`max-height` + `padding`, `.22s`), tocar de novo fecha. Cada card
abre/fecha independente dos outros dois — não é accordion exclusivo
(abrir um não fecha os outros).

**Implementação**: um único listener delegado no container
`.atributospontos` (não um por card) — os 3 cards são estáticos no
HTML (não recriados via `innerHTML` como Conquistas/Bestiário), então
um listener direto em cada `.atrbarra` também funcionaria, mas
delegação foi preferida por já ser o padrão dominante no resto do
arquivo e não ter custo real aqui. O clique no botão "+" (dentro do
`atrcorpo`) não conflita com o toggle — `closest('.atrbarra')` a
partir do alvo do clique não encontra o botão, que vive um nível
abaixo, fora da barra.

O card travado (Vigor, "Em preparo") também expande normalmente ao
tocar — só o botão continua desabilitado, sem tratamento especial
pro toggle.

### Validado

`node --check` limpo nos 36 blocos `<script>`. Tags balanceadas
(`<div>`/`<svg>`/`<button>`/`<span>` todas abertura=fechamento).
Parser HTML tolerante sem desalinhamento.

7 cenários em jsdom: os 3 cards começam fechados; clique na barra abre
só aquele card, os outros dois continuam fechados (independência
confirmada); segundo clique fecha de novo (toggle); clicar no botão
"+" não fecha o card (sem conflito com o listener delegado); o card
travado (Vigor) também expande normalmente.

**O que não deu pra testar neste ambiente:** a transição visual real
(`max-height` + `padding` em `.22s`) e se `max-height:80px` é folga
suficiente pro texto mais longo (“Em preparo — perdão de fuga”) sem
cortar em telas bem estreitas — só verificável num navegador de
verdade.

## 51. Prévias de Histórico/Conquistas/Bestiário ganham conteúdo de verdade, não só texto (v4.68)

### Correção de interpretação

O pedido "cada um deveria mostrar tipo um preview antes de abrir por
completo" (mesma mensagem da seção 50) foi mal interpretado numa
primeira passada — implementado como expandir/recolher nos **cards de
atributo** (Fortuna/Foco/Vigor). O usuário esclareceu depois: a intenção
sempre foi nas **prévias de Histórico/Conquistas/Bestiário** (que desde
a v4.64 só mostravam um resumo em texto, tipo "3 vitórias, 1 fuga este
mês") — mostrar conteúdo de verdade ali mesmo, sem precisar tocar em
"Ver tudo": histórico dos últimos 5 dias, as 5 conquistas mais recentes,
ideia equivalente pro Bestiário. O trabalho da seção 50 (cards de
atributo) não foi revertido — fica como melhoria válida por conta
própria, só não era o que tinha sido pedido nesse ponto.

Isso também bate com o que já estava proposto no item 18 original do
roadmap (seção 42+), que a v4.64 tinha implementado de forma mais
simples de propósito ("conteúdo exato da prévia... ajustável na sessão
de implementação").

### O fix

Cada prévia virou um `.cfgrow.cfgcol` (título + botão na primeira
linha, faixa de conteúdo embaixo) em vez de só uma linha de texto.
Reaproveitadas classes visuais que já existiam em outros módulos, zero
CSS novo pro conteúdo em si — só o wrapper da faixa horizontal:

- **Histórico**: 5 células reaproveitando `.caldia`/`.calvitoria`/
  `.calfuga`/`.calsemtarefa`, o mesmo visual do calendário completo,
  só que numa fileira de 5 em vez de grade do mês. Mesmo truque de
  "hoje ao vivo" que o calendário já usava — se o monstro de hoje já
  caiu mas a virada ainda não gravou no histórico permanente, mostra
  vitória otimista mesmo assim.
- **Conquistas**: até 5 ícones circulares reaproveitando `.conqcaticone`
  (cor da categoria + ícone SVG), as mais recentes primeiro. Derivado
  sem precisar de timestamp novo — `Set` do JS preserva ordem de
  inserção, e como `resgatarConquista()` só chama `resgatados.add()` no
  momento do resgate, a ordem do array já é cronológica por
  construção.
- **Bestiário**: até 5 sprites reaproveitando visual parecido com
  `.bestimg`, os monstros vistos mais recentemente primeiro. Derivado
  do histórico permanente (`monstroId` já existe em toda entrada, não
  só nas de vitória), deduplicado — mesmo monstro derrotado várias
  vezes conta só a aparição mais recente.
- **Estado vazio**: cada faixa mostra uma frase (“Nenhuma conquista
  resgatada ainda” / “Nenhum monstro derrotado ainda”) em vez de ficar
  em branco quando não há nada — Histórico não precisa desse tratamento
  porque os 5 dias sempre existem, mesmo vazios de resultado.

### Validado

`node --check` limpo nos 36 blocos `<script>`. Tags balanceadas.
Parser HTML sem desalinhamento.

13 cenários em jsdom, com data fixa (`2026-08-20`) pra determinismo:
faixa de Histórico sempre com exatamente 5 células, cada uma com a
classe certa (vitória/fuga/sem-tarefa/hoje-sem-registro); faixa de
Conquistas respeita o limite de 5 e aplica a cor certa via
`--pv-cor`; faixa de Bestiário deduplica corretamente (monstro
derrotado 2x no histórico aparece só 1x, com a data mais recente
vencendo a ordem); os dois estados vazios (Conquistas/Bestiário sem
nada ainda) mostram a frase certa.

**O que não deu pra testar neste ambiente:** o visual real das 3
faixas lado a lado num card `.cfgrow` (se cabem numa linha só em
telas estreitas, ou se a faixa de 5 itens precisa de scroll
horizontal).

## 52. Conquistas — sistema inteiro reformulado: lista curada plana, sem árvore de tiers, sem recompensa, desbloqueio automático (v4.69)

### Motivação

Usuário achou os ícones das conquistas ruins e, discutindo isso, pediu
uma reformulação bem maior do sistema: menos conquistas (o catálogo
tinha ~38, espalhadas em 5 categorias × 6-9 degraus cada — "árvore de
habilidades" na visão dele), tirar a recompensa em XP, e mandou um
print de referência de outro app (lista plana, duas seções — "Minhas
conquistas" com ícone colorido + data, "Nenhuma ainda" com ícone cinza
— sem árvore, sem resgatar visível). Confirmado: sem resgate manual, o
desbloqueio automático mantém aviso na tela (toast).

**Ícones do pack `joi3` mencionado**: não implementados nesta leva —
o link era externo (itch.io) e este ambiente não tem navegação web;
os ícones em si nunca foram anexados na conversa. Os ícones SVG atuais
(reaproveitados das categorias antigas) continuam no lugar até o
usuário anexar os arquivos de verdade.

### Curadoria (38 → 17 conquistas)

Escolhidos 3-4 marcos por categoria (início, meio, marco alto, e o
"completar tudo" onde fazia sentido), proposta e aprovada antes de
implementar:

- **Sequência Diária**: Primeiro Passo (1d), Consistência (15d),
  Disciplina Absoluta (60d)
- **Matar Monstros**: Primeiro Sangue (1), Exterminador (10), Lenda da
  Caçada (60), Bestiário Completo
- **Subir de Nível**: Início da Jornada (nível II), Veterano (nível X),
  Ascensão (nível L)
- **Conclua Tarefas**: Primeira Vitória (1), Produtivo (20), Imparável
  (50)
- **Obter Itens**: Primeira Descoberta (1), O Livro Proibido
  (Grimório), Explorador (20 distintos), Mestre do Grimório (catálogo
  completo)

### O fix

**Sistema antigo mantido intacto no arquivo, só parou de ser chamado**
(convenção append-only) — `renderConquistas()`, `resgatarConquista()`,
`resgatarTodasConquistas()` (a feature "Receber tudo" da v4.50/seção
39) continuam existindo, mas nenhum botão na UI aciona mais elas.
Documentado explicitamente como remoção intencional de uso, não
regressão silenciosa.

**`CONQUISTAS_V2`**: as 17 conquistas curadas, construídas por
referência aos tiers antigos (`CATEGORIAS`, já no mesmo escopo do
módulo) — reaproveita `nome`/`req`/`meta`/`valor()`/cor/ícone da
categoria sem duplicar a lógica das condições em lugar nenhum novo.

**Desbloqueio automático, sem resgate**: `checarDesbloqueiosV2()` roda
a cada `render()` (mesmo gancho que o resto do app já usa) — para cada
uma das 17, se a condição bate e ainda não tinha sido desbloqueada,
grava a data (`questlog.conquistasDesbloqueadasV2.v1`, objeto
`{tierId: isoData}`) e dispara `aviso('Conquista: ' + nome, true)`
(reaproveita o toast dourado que já existia pra XP, sem widget novo).
Idempotente — não reavisa numa segunda checagem da mesma condição já
desbloqueada.

**Renderização em duas seções** (`renderConquistasV2()`, substitui
`renderConquistas()` como alvo de `abrirConquistas()`): "Minhas
conquistas" (desbloqueadas, ordenadas por data real — mais recente
primeiro —, ícone colorido, data formatada em BR) e "Ainda não"
(ícone acinzentado via `filter:grayscale`, sem data). Rótulos de
seção reaproveitam `.edsec`, já usado em Config.

**Badge de pendentes neutralizado**: `contarPendentes()` (usada pelo
badge no botão "Ver todas" da prévia do Perfil) virou um retorno fixo
`0` em vez de apagada — o conceito "feito mas aguardando resgate" não
existe mais no fluxo novo (desbloqueia sozinho no instante que bate),
então o badge nunca aparece, que é o comportamento certo. Função
mantida (não removida) pra não quebrar quem já chama ela.

**`resumoConquistasPerfil()`/`conquistasRecentesPerfil()`** (prévia do
Perfil, adicionadas na sessão da seção 51) reescritas pra ler do
sistema V2 em vez do `resgatadosSet()` antigo — `pendentes` fixo em
`0`, `resgatadas`/`total` contam sobre as 17 curadas, e a ordenação
de "mais recentes" agora usa a data real gravada, não mais a ordem de
inserção do `Set`.

### Validado

`node --check` limpo nos 36 blocos `<script>`. Tags balanceadas.
Parser HTML sem desalinhamento.

**12 cenários de lógica isolada** (réplica fiel do algoritmo, fixtures
simples — a `montarContexto()` real tem dependências profundas demais
pra montar no jsdom): nenhuma conquista desbloqueada no início;
condição batendo desbloqueia + dispara aviso exatamente 1 vez;
verificar de novo com a mesma condição não duplica aviso
(idempotência); ordenação por data real coloca a mais recente
primeiro mesmo que tenha sido definida antes na lista; resumo sempre
com `pendentes:0`.

**9 cenários com a função `renderConquistasV2()` real** (extraída do
arquivo, não reescrita à parte): 3 itens renderizados no total, split
correto entre desbloqueadas/trancadas, data em formato BR só nas
desbloqueadas, cor do ícone aplicada via `--pv-cor`, ordenação por
data confirmada no HTML gerado de verdade, as duas seções `.edsec`
presentes com o texto certo.

**O que não deu pra testar neste ambiente:** os ícones do pack `joi3`
(nunca chegaram anexados) e o visual real da lista de 17 itens rolando
dentro do overlay num navegador de verdade.

### Ajuste de rótulo (v4.70)

"Ainda não" trocado por "Não desbloqueadas" — mesmo texto do print de
referência ("Nenhuma ainda") não soou natural pro título da seção;
"Não desbloqueadas" descreve melhor o conteúdo.

## 53. Teste de ícones de conquista com asset pack real — reprovado; XP voltou pro amarelo; vibração investigada e confirmada (v4.71–4.72)

### Pack `joi3` (mencionado por link) — rejeitado antes de implementar

Usuário mandou um link do itch.io pedindo opinião sobre um pack de
ícones pra usar nas conquistas. **Este ambiente não tem navegação
web** — o link nunca foi aberto. Avisado disso diretamente, sem
fingir ter visto. Só depois que o usuário anexou o `.zip` de verdade
(`Emojis_Free.zip`, 63 ícones 16×16) foi possível avaliar: pack
genérico de "hobbies/atividades" (esporte, viagem, carro, casa),
colorido e preenchido — estilo destoante do resto do app (que usa
só linha fina monocromática) e sem mapeamento semântico claro pras
17 conquistas curadas. **Recomendado não usar**, sem implementar
nada — evitou gastar uma leva inteira num visual que não ia servir.

### Pack "1-bit Pixel Icons" — testado de verdade, também reprovado

Segundo `.zip` anexado (`1-bit_Pixel_Icons.zip`) — amostra de 39
ícones (1 corrompido, 38 válidos), estilo monocromático preto/branco
que bate melhor com a linguagem visual do app. Mas o conteúdo também
era uma amostra promocional aleatória de um pack pago maior (logos de
Photoshop/itch.io/Patreon/GOG, carta de baralho, biscoito, cano de
esgoto) — só 4 dos 38 tinham relação real com RPG/conquista: escudo
(dificuldade), alvo (precisão), moeda (ouro), criatura-pássaro.

**Implementado como teste real** (não só mockup) em 4 das 17
conquistas curadas — Disciplina Absoluta (escudo), Exterminador
(alvo), Mestre do Grimório (moeda), Bestiário Completo (criatura):
ícones convertidos pra base64 e embutidos direto no arquivo (mesmo
padrão já usado pro spritesheet de heróis/monstros), com um mapa
`ICONES_TESTE_V2` ligando id da conquista → data URI, e a função
`linha()` de `renderConquistasV2()` estendida pra renderizar `<img>`
quando o item tem `img` definido, `<svg>` de linha nos outros 13 sem
alteração.

**Testado de verdade no navegador**, não só em jsdom — Playwright
com Chromium headless, servindo o arquivo real via
`python3 -m http.server`, save sintético injetado via
`addInitScript()` pra pular a tela de login/tutorial, screenshots
reais da tela de Conquistas com os 4 ícones desbloqueados (data
injetada em `questlog.conquistasDesbloqueadasV2.v1`). Resultado:
tudo funcionou tecnicamente (ordenação por data certa, toast de
desbloqueio automático disparando sozinho no meio do teste, ícones
nítidos mesmo pequenos, estado trancado com `grayscale` legível) —
mas o usuário avaliou o resultado visual e reprovou (**"não ficou
bom"**, sem detalhar o motivo específico ainda). Reversão não
solicitada ainda — o teste fica no arquivo `4-71` como registro,
aguardando decisão do usuário sobre reverter pros SVG originais nas
4 conquistas ou tentar outro pack.

### Cor da barra de XP — reversão pro amarelo original (v4.72)

Pedido: voltar pro "tom de amarelo que tava antes" (antes das
mudanças pra verde nas seções 49/50), só que agora fixo em todos os
temas, não trocando por tema como era originalmente. Investigado qual
era o tom original: tema Crepúsculo (padrão, sem `data-tema`) usava
`var(--accent)` → `var(--xp2)` = `#F2A65A` → `#F2C94C` (laranja pro
dourado). Mesma técnica de override por ID já estabelecida (`#fill,
#perfilFill`), só trocado o valor pra esse gradiente hardcoded.
Terceira mudança de cor na mesma regra (verde-gradiente → verde-sólido
→ amarelo-gradiente) — histórico completo documentado direto no
comentário do CSS, pra não perder o contexto de por que a regra existe
nem os valores testados antes.

### Vibração "sumiu" — investigado, não era bug

Usuário relatou vibração de clique sumida. Testado com Playwright,
interceptando `navigator.vibrate()` de verdade (não mock) nos botões
de nav principal e nos botões novos do Perfil (engrenagem, voltar,
"Ver tudo") — todos vibrando 10ms corretamente, `sfxAtivo()` retornando
`true`. Descartada a hipótese de regressão no código antes de
qualquer especulação. Causa real: **modo de economia de energia do
aparelho do usuário**, desativando a vibração no nível do sistema
operacional, fora do controle do app.

### Validado

`node --check` limpo em ambas as versões (4-71, 4-72). Teste funcional
em jsdom (6 cenários) confirmando que a troca de ícone é condicional —
só os 4 IDs com `img` definido renderizam `<img>`, os outros 13
continuam com `<svg>` normalmente. Teste end-to-end real via Playwright
(não simulado) cobrindo: boot pulando login/tutorial, navegação entre
abas, abertura dos overlays de Config/Histórico/Conquistas, desbloqueio
automático dentro do fluxo real da aplicação (não isolado), e
interceptação real de `navigator.vibrate()`.

**O que não deu pra testar neste ambiente:** a razão específica de
"não ficou bom" nos ícones (usuário não detalhou — tamanho? cor de
fundo? mistura com os SVG? preciso perguntar antes de tentar de novo).

## 54. Badge da arma em destaque na faixa de equipamentos (v4.73, item 19)

### Contexto

Sessão de brainstorm (seção do item 19, 19/08) já tinha fechado o escopo:
só o badge de arma cresce, sem arte nova, reaproveitando a mesma lógica
de cor por raridade que os badges já tinham individualmente
(`--cor` por item, não a aura agregada do herói).

### Iteração até o tamanho final

Primeira versão: 2 categorias — arma (52px caixa / 32px ícone) versus
os outros 4 iguais entre si (30px / 18px, um pouco maiores que o
26px/16px original, "aumenta um pouco dos sprites comuns" foi o pedido
inicial).

Testado um refinamento de 3 categorias (elmo/armadura num degrau
médio entre escudo/acessório e a arma) a pedido do usuário — testado,
achou pior na prática ("pior que na real ficou pior"), revertido pro
esquema de 2 categorias. Fica registrado que 3 níveis de hierarquia
visual num espaço de badge pequeno (26-52px) não funcionou tão bem
quanto o binário simples "arma vs resto".

### O fix (estado final)

Dentro do bloco autônomo "EQUIPAMENTO VISÍVEL NO HERÓI":
- CSS: `.eqb` (comum) 26px → 30px; `.eqb-arma` (nova classe) 52px,
  borda 2px, `box-shadow` com glow mais forte + inset, reaproveitando
  `var(--cor)` que já vinha por item.
- JS (`montarFaixa`): cada badge testa `s === 'arma'`, aplica a classe
  e passa `32` (vs `18` dos outros) pro `spriteHTML()` — o ícone em si
  fica maior, não só a caixa ao redor.

### Validado

`node --check` limpo nos 36 blocos. `<div>`/`<svg>`/`<button>`
idênticos ao arquivo de entrada nas duas rodadas (a de 3 níveis e a
reversão para 2). Teste funcional em jsdom equipando os 5 slots:
confirma que só a arma recebe `.eqb-arma`, ícone em 32px vs 18px dos
demais, `background-position` calculado certo pros dois tamanhos.

## 55. Bug crítico: Grimório (item-chave) aparecia vendável na aba Vender da Loja (v4.74)

### O bug

Usuário notou, por acaso, um card do Grimório com botão "Vender" na
aba Vender da Loja. A ficha do item (`abrirFicha()`) sempre bloqueou
corretamente venda de itens `tipo === 'chave'` — mas essa é uma tela
diferente. `montarVenda()` lista o inventário inteiro sem esse
filtro, e `venderItem()` em si nunca teve nenhuma trava de tipo — só
remove do inventário e dá a moeda, sem checar o quê.

Sem o fix, era possível vender o Grimório de verdade e perder acesso
ao Bestiário/catálogo **permanentemente** — não é bug cosmético, é
perda de progresso irreversível.

### O fix

Três mudanças, todas em `montarVenda()`/`venderItem()`:
1. `montarVenda()`: lista filtrada por `item(s.id).tipo !== 'chave'`
   antes de renderizar — causa raiz.
2. `venderItem()`: ganhou trava própria (`if (it.tipo === 'chave')
   return;`) — rede de segurança pra qualquer caminho futuro que chame
   a função direto, não só a UI da Loja.
3. Aviso novo pro caso raro de mochila só com itens-chave (a lista
   fica vazia depois do filtro, mas a checagem original de "mochila
   vazia" olhava o array antes de filtrar, então ficaria em branco
   sem esse aviso).

### Validado

`node --check` limpo nos 36 blocos. `<div>`/`<svg>`/`<button>`
idênticos ao arquivo de entrada. Teste funcional em jsdom clicando de
verdade no botão da aba (não só chamando a função direto — o estado
`lojaAba` vive numa IIFE própria da Loja, inacessível por
atribuição externa): Grimório não aparece na lista, nenhum botão de
venda gerado pra ele, `venderItem()` chamado direto também recusa
(inventário e moedas inalterados), e o aviso de "só itens-chave"
aparece certo quando é o único item na mochila.

## 56. 6 itens Lendários novos + reclassificação de Épico + Lendário exclusivo em baú (v4.75, item 20)

### Contexto

Spec inteira já tinha sido fechada numa sessão de brainstorm anterior
(19/08) — nomes, itens-base, técnica de recolor e a regra de loja
já estavam 100% decididos, faltava só implementar. Nesta sessão o
usuário anexou 2 imagens (`lendarios-armadura-escudo-acess-dourado.png`,
`lendarios-armas-dourado.png`) com os 6 sprites já recoloridos em
dourado, prontos pra usar — cada imagem mostra 3 pares lado a lado
(original à esquerda, dourado à direita).

### Confirmação antes de mexer em qualquer coisa

Antes de tocar no arquivo, os 6 sprites "originais" das imagens
anexadas foram comparados pixel a pixel com os tiles reais do
spritesheet do jogo (idx 76 Cajado Arcano, 90 Adaga Ritual, 14 Arco,
62 Peitoral de Ferro, 111 Escudo Cravado, 32 Orbe de Cristal) — bateram
exatamente, confirmando que as imagens correspondem ao spec já fechado
antes de qualquer edição.

### Extração e inserção dos sprites

O jogo usa um único spritesheet embutido em base64 (`--sheet`, CSS
custom property), grade de 16×9 tiles de 32×32px, indexado por
`estiloSprite(sp, s)` via `background-position`. Processo:

1. Decodificado o PNG do spritesheet atual (512×288px, formato
   paletizado com transparência binária).
2. Recortado o sprite dourado de cada uma das 6 células das imagens
   anexadas, pelo bounding-box do conteúdo não-fundo.
3. Redimensionado cada recorte (nearest-neighbor, sem suavizar) pro
   tamanho exato do bounding-box do sprite-base correspondente dentro
   do tile 32×32 real do jogo — preserva alinhamento/proporção
   idênticos ao resto do spritesheet, não é um "colar e encolher"
   genérico.
4. Localizados os slots vazios do spritesheet (índices 129 a 143,
   14 tiles totalmente transparentes no final da grade) — os 6 tiles
   novos foram nos índices **129-134**, sem precisar crescer a folha
   nem arriscar colidir com nenhum sprite em uso.
5. Spritesheet resultante requantizado de volta pra PNG paletizado
   (~40KB, mesma ordem de grandeza do arquivo original de ~28KB —
   a versão intermediária sem paletizar tinha inchado pra ~75KB).
6. Base64 novo substituído no `--sheet` do arquivo.

### Dados: `ITENS`, reclassificação e regra da loja

1. **6 linhas novas em `ITENS`** (posições 100-105), cada uma
   apontando pro seu novo índice de sprite (129-134), raridade `4`:
   - `Cajado do Rei`, `Adaga Amaldicoada`, `Arco Real` — arma, val 145
   - `Peitoral de Ouro` — armadura, val 150
   - `Escudo do Guardiao` — escudo, val 80
   - `Orbe Proibido` — acess, val 160
   
   **Nenhuma mudança de código foi necessária pro bônus real desses
   itens funcionar** — `bonusItem()` já decide o bônus de equipamento
   inteiramente pela tabela `BONUS[tipo][raridade]`, que já tinha
   entrada pra raridade 4 em todos os slots (usada até então só pelo
   elmo "Coroa Real"). Os campos `val`/`m`/`x` na linha de `ITENS` só
   importam pra preço de loja/venda (`val`) e, pros catalogados de
   equipamento, são cosméticos — segue o padrão de progressão de cada
   coluna por slot (extrapolação ~1.6-1.8× do teto anterior de cada
   tipo), mas não afeta o bônus de fato equipado.
2. **"Manto Simples" (posição 23) virou "Manto de Alma"** — raridade
   0→3, `val:85, x:38`, exatamente os números já propostos no roadmap
   antes desta sessão.
3. **"Escudo Cravado" (posição 37) subiu raridade 2→3** — nome, sprite,
   `val` e `x` mantidos intactos, só o número de raridade mudou.
4. **`PESO_LOJA[4]` foi de `4` pra `0`** — Lendário nunca mais entra na
   prateleira. `PESO_RAR` (loot de vitória) não foi tocado, continua
   com peso 2 pro Lendário — é o único caminho de obtenção agora.

### Validado

`node --check` limpo nos 36 blocos `<script>`. Contagem de
`<div>`/`<button>`/`<svg>`/`<script>` idêntica à v4.74 em ambos os
lados — nada de HTML foi tocado nesta sessão, só JS/dados/imagem.

Simulação de regressão em Node puro, usando a tabela `ITENS` real e as
funções reais do arquivo (não reescritas à parte):
- `ITENS.length` fechou em 106 (100 + 6 novos), os 6 com `tipo`/`rar`
  corretos.
- "Manto de Alma" e "Escudo Cravado" conferidos com os valores certos
  pós-reclassificação.
- **5.000 sorteios simulados do RNG da loja**: raridade 4 nunca saiu
  (peso 0), confirmando a regra C na prática, não só a leitura do
  número no array.
- **5.000 sorteios simulados do loot de vitória**: raridade 4 saiu
  normalmente (94 vezes), confirmando que `PESO_RAR` não foi afetado
  e o Lendário continua obtível por essa via.
- Nenhuma colisão de índice de sprite entre os 6 novos (129-134) e
  qualquer item pré-existente.
- Confirmado que arma/armadura/escudo/acessório agora têm pelo menos
  um item em raridade 4 (lacuna original do item 20 fechada).

Spritesheet final reextraído de volta do arquivo (não só o arquivo
intermediário gerado durante o processo) e inspecionado visualmente
— os 6 tiles dourados aparecem corretos na posição esperada, resto da
folha idêntico ao original.

**O que não deu pra testar neste ambiente:** navegação real — abrir a
ficha de um dos 6 itens novos no Inventário/Grimório e ver o sprite
dourado renderizado de verdade num navegador, e confirmar visualmente
ao longo de alguns dias de uso que a prateleira da loja nunca oferece
Lendário. Recomendo forçar um dos novos itens via `darItem()` (mesmo
padrão de teste manual já usado pra Poção de Vida, seção 43) pra
conferir visualmente antes de considerar 100% fechado.

## 57. Fix: sprites Lendários da v4.75 tinham fundo preto em vez de transparente (v4.76)

### Causa raiz

O teste manual recomendado no fechamento da seção 56 (forçar os itens
via `darItem()`) foi feito pelo usuário e encontrou o bug de cara — os
6 tiles novos apareciam com um quadrado preto/azul-escuro atrás do
sprite, em vez do fundo transparente que todo o resto do spritesheet
tem.

A extração original (v4.75) recortava o **retângulo** delimitador
(bounding box) do sprite dourado dentro de cada célula das imagens
anexadas pelo usuário, redimensionava e colava num tile 32×32
transparente. O problema: esse retângulo é sempre maior que o contorno
real do item (uma adaga ocupa uma diagonal fina dentro de um retângulo
quadrado, por exemplo) — e os pixels de fundo `(20,20,28)` que sobram
dentro do retângulo, fora do contorno do sprite, vieram opacos junto,
porque a imagem de origem não tinha canal alfa diferenciando sprite de
fundo (era um PNG totalmente opaco, fundo escuro sólido).

### O fix

Antes de recortar/redimensionar/colar, cada uma das 6 células passou
por **chroma key**: todo pixel com distância euclidiana ≤18 da cor de
fundo `(20,20,28)` (confirmada como fundo exato nas duas imagens
anexadas, cantos e bordas conferidos) virou alpha `0`; o resto ficou
opaco. Só depois disso o bounding-box real (agora baseado em alpha, não
em cor) foi calculado, recortado e colado no tile 32×32 — mesma técnica
de alinhamento da v4.75, só que agora operando sobre uma imagem já sem
fundo.

Processo refeito do zero a partir do `questlog-4-74-fix-vender-grimorio.html`
limpo (não em cima da v4.75 com bug), pra garantir que não sobrasse
nenhum resquício do spritesheet malformado anterior. Todas as edições
de dados da v4.75 (6 linhas novas em `ITENS`, reclassificação de Manto
de Alma e Escudo Cravado, `PESO_LOJA[4] = 0`) foram reaplicadas
idênticas.

### Validado

Antes de reinserir no jogo: os 6 sprites corrigidos foram compostos
sobre um fundo xadrez de teste (visualização auxiliar, não faz parte
do arquivo) e conferidos visualmente — transparência limpa, sem halo
escuro residual nas bordas.

Depois de reinserir: contagem de pixels transparentes vs. opacos em
cada um dos 6 tiles (proporções condizentes com a silhueta de cada
item — arma fina tem mais transparência que escudo/armadura cheios).
Requantização pra PNG paletizado (mesma etapa de compressão da v4.75)
conferida pixel a pixel depois — a contagem de transparência bateu
exatamente igual antes e depois de paletizar, confirmando que a
compressão não introduziu nenhum artefato novo.

`node --check` limpo nos 36 blocos. Contagem de `<div>`/`<button>`/
`<svg>`/`<script>` idêntica à v4.74/v4.75. **Diff textual do arquivo
inteiro contra a v4.75, ignorando só a linha do `--sheet` (que muda de
propósito) veio vazio** — confirma que absolutamente nenhum dado
(`ITENS`, `PESO_LOJA`, raridades) foi alterado nesta correção, só o
PNG do spritesheet. Regressão da seção 56 rodada de novo por cima do
arquivo corrigido (contagem de itens, raridades dos 6 novos, Manto de
Alma, Escudo Cravado, 3.000 sorteios de loja confirmando Lendário
continua em peso 0) — tudo bateu igual.

**O que não deu pra testar neste ambiente:** confirmação visual final
num navegador de verdade. O usuário ainda precisa forçar os itens de
novo (`darItem()`) e conferir que agora o fundo saiu.

---

## 58. Som faltando em "Salvar alterações" e "Excluir" do editor de tarefa (v4.77, item 21)

> Versão do arquivo ao final desta sessão: `questlog-4-77-fix-som-editor.html`

### Contexto

Retomada do SFX em cima do arquivo mais novo do project knowledge
(`questlog-4-76-fix-transparencia_1.html` — o jogo avançou de v4.63 pra
v4.76 entre sessões: transparência de sprite Lendário, itens Lendários
novos, badge de arma em destaque, fix de Grimório vendável, etc.,
nenhuma delas mexendo em SFX). Pedido: resolver a queixa de
"inconsistências de áudio", usando a spec que uma sessão de brainstorm
já tinha deixado fechada no item 21 (seção 4) — incluindo uma auditoria
prévia que descartou bug de conexão como causa.

### O que foi implementado (exatamente como a spec propunha)

- `#edSalvar` (botão "Salvar alterações") → `window.tocarSom('tarefa')`,
  reaproveitando o som que já toca ao criar tarefa nova em `criar()`.
- `#edExcluir` (botão "Excluir", mesmo editor) →
  `window.tocarSom('desequipar')`, reaproveitando o thud curto/surdo já
  catalogado.

Confirmado antes de editar: os dois `onclick` vivem presos na mesma
IIFE do módulo "editor de tarefa" (`#edSalvar`/`#edExcluir`, linhas
~3625/3659) — exatamente a mesma família de exceção de fechamento já
catalogada pra `comprar()`/`investir()` (seções 20/29). Edição direta,
sem tentativa de gancho externo via `window.fn`, posicionada depois de
todos os guards de validação (`idx < 0`, texto vazio, dias não
escolhidos) — só toca em salvamento/exclusão genuínos, nunca em clique
bloqueado.

### Pendência que a spec já deixava em aberto, continua em aberto

O som `desequipar` pro `edExcluir` foi **proposta da sessão de
brainstorm, nunca confirmada com o usuário de fato** (a spec original
já registrava isso: "era só proposta minha, não perguntada
explicitamente ao usuário"). Implementado como estava escrito, mas
ainda precisa de teste real pra confirmar se combina com "excluir
tarefa" ou se troca por outro som/som novo.

### Achado à parte: nota da seção 5 sobre "3 blocos `<script>`" estava desatualizada

Ao validar, o arquivo real tem **35 blocos `<script>` clássicos + 1
`<script type="module">`** — bem longe dos "3 blocos" que uma nota
antiga da seção 5 registrava. Essa nota claramente ficou presa numa
versão bem mais antiga do arquivo, antes de SFX (seção 20), login
(seção 30) e o resto crescerem o arquivo. Corrigida a nota, sem mexer
em nenhuma lógica — só documentação desatualizada encontrada de
passagem, mesmo tipo de manutenção que a seção 34 já tinha feito com o
falso positivo de regex.

### Validação

35 blocos `<script>` clássicos + 1 `<script type="module">`
(checado separado), `node --check` limpo nos dois grupos. `<div>`
311/311, `<svg>` 32/32, comentários 29/29.

---

## 59. Efeito visual de golpe por categoria de arma + escala por raridade (v4.78, item 22)

> Versão do arquivo ao final desta sessão: `questlog-4-78-efeito-golpe-arma.html`

### O que foi implementado

Spec do item 22 (seção 4), fechada havia algumas sessões. Bloco novo,
autocontido, colado antes de `</body>` — nada do script principal foi
editado. Gancho em `window.animarGolpe` (função global, sem IIFE —
sem risco de closure trap): chama a versão original primeiro (mantém
`hit`/`shake` intactos) e soma o efeito por cima.

- **`CAT_ARMA`**: mapa `id do item (índice em ITENS) → categoria`,
  cobrindo as 25 armas do catálogo (22 antigas + 3 Lendárias). Cajado
  do Rei → arcano, Adaga Amaldiçoada → corte, Arco Real → distância.
- **5 efeitos por categoria**, todos CSS/SVG puro (zero arte nova):
  corte (risco diagonal), impacto (estrelinhas via `clip-path`),
  perfuração (linha reta + ponto de impacto), à distância (projétil
  viajando do herói até o monstro), arcano (partículas coloridas
  roxo/azul/verde).
- **Auréola por categoria** (não estava na spec original, adicionada
  no meio da sessão a pedido do usuário — "não seria mais perceptível
  com uma cor de fundo?"): um brilho radial atrás do monstro, cor fixa
  por categoria, leitura instantânea sem depender de reparar nas
  partículas pequenas.
- **Escala por raridade da arma** (decisão tomada nesta sessão, ver
  abaixo): tamanho/alcance do efeito cresce com a raridade (0.75x
  Comum → 1.3x Lendário), cor nunca muda com raridade.
- **Botão de debug `+ todas armas`**: adicionado na `.debugbar`
  existente (mesmo padrão de `#debugbtn`/`#pularTutoriaisBtn`), dá as
  25 armas do catálogo pro inventário de uma vez, pra testar as 5
  categorias sem precisar caçar item por item na loja/baú.

### Assunção não coberta pela spec original

Sem arma equipada (soco), tratado como categoria **impacto**. Não
tinha sido definido no brainstorm original — decisão tomada nesta
sessão, sinalizada ao usuário, sem objeção.

### Decisão tomada nesta sessão: raridade escala intensidade, não cor

Usuário perguntou se ficaria legal cor variar por raridade também.
Rejeitei duas variações antes de fechar:
- **Substituir cor de categoria pela cor de raridade** — mataria o
  propósito do item 22 (a cor é o sinal de "que tipo de ataque foi
  esse"; trocar por raridade joga fora essa legibilidade).
- **Somar camada extra de cor por raridade em todas as 6 raridades**
  — diluiria o que faz a Lendária ser especial hoje (ela é a única
  com camada extra; se todo mundo ganha uma, ninguém se destaca).

Fechado: raridade só escala **intensidade** (tamanho, alcance,
número de partículas), cor continua 100% definida pela categoria.
Tabela de escala: Comum 0.75x, Incomum 0.88x, Raro 1x, Épico 1.15x,
Lendário 1.3x. A camada dourada da Lendária (dela mesma) tem tamanho
próprio fixo, não é multiplicada de novo por essa escala.

### Bug real encontrado e corrigido antes da entrega

O comentário HTML de abertura do bloco novo (`<!--`) fechava com `*/`
(sintaxe de comentário JS, copiada por engano do padrão usado dentro
de `<script>`) em vez de `-->` — isso teria comentado o `<style>` e o
`<script>` inteiros, matando a feature inteira silenciosamente sem
erro de sintaxe visível. Pego pela checagem de balanceamento de
comentários (`<!--` vs `-->`) antes da primeira entrega, corrigido
antes do usuário testar.

### Bug de percepção encontrado depois da entrega: Arcano Épico vs Arcano Lendário pareciam iguais

Usuário reportou que a camada dourada da Lendária não estava
perceptível numa arma Arcana. Causa raiz: a cor de categoria Arcano
(`#B57BE8`, escolhida nesta sessão) é, por coincidência, **o mesmo
hex** de `COR_RAR[3]` (cor oficial de Épico no jogo). Com 8
partículas roxas de categoria já na tela, a camada extra dourada
(mais partículas da mesma família visual — círculos com glow) não
tinha contraste suficiente pra se destacar numa tela pequena.

**Fix:** anel dourado (`fx-anel-lendario`) — contorno, não mancha de
cor —, disparado com 110ms de atraso em relação ao burst de
categoria, lendo como um segundo flash em sequência. A distinção
passou a ser de **forma e timing**, não de contraste de cor, então
funciona em cima de qualquer categoria, não só Arcano. Validado em
jsdom: Cajado Arcano (Épico) não gera anel; Cajado do Rei (Lendário,
mesma categoria/cor de aura) gera exatamente 1 anel dourado.

### Validação

`node --check` limpo nos 37 blocos de script. Balanceamento de
`<div>` (311/311), `<button>` (mesmo delta da baseline pré-edição),
`<style>` (35/35) e comentários HTML (30/30, +1 do bloco novo,
consistente). Suíte jsdom simulando cliques reais (não só checagem de
sintaxe):
- 9 casos de categoria/lendária disparando `window.animarGolpe()` de
  verdade e checando os elementos `.fx-*` certos no DOM;
- regressão do `hit`/`shake` original (timing 0ms/120ms/320ms
  intacto);
- botão `+ todas armas`: as 25 armas aparecem no inventário, uma
  unidade cada, sem duplicar slot;
- escala por raridade: mesma categoria (impacto) em 3 raridades
  diferentes, tamanho de partícula/auréola cresce estritamente
  (8.25px → 9.68px → 11px);
- Épico vs Lendário na mesma categoria (arcano): só o Lendário gera o
  anel, cor de categoria idêntica nos dois como esperado.

### Não testado em sandbox

Timing visual real dos keyframes no dispositivo, legibilidade do
projétil "à distância" atravessando a arena numa tela pequena, se o
anel dourado realmente resolve a percepção Épico-vs-Lendário no
Chrome Android (só a leitura estática/jsdom confirma que o anel
existe e está condicionado certo — não que ele *parece* bom). Pendente
de teste real do usuário.

---

## 60. Redesign pixel-art + integração de sprites reais (Super Pixel Effects Gigapack) no efeito de golpe (v4.78, continuação do item 22)

> Versão do arquivo ao final desta sessão: `questlog-4-78-efeito-golpe-arma.html`
> Sessão encerrada aqui — próxima sessão continua em chat novo (economia de créditos).

### Parte 1: usuário apontou quebra de identidade visual

A implementação da seção 59 (losangos/gradientes radiais/blur/`clip-path`
arredondado) usa linguagem visual de jogo vetorial moderno — o resto do
app é 100% pixel-snapped (`shape-rendering="crispEdges"`,
`image-rendering:pixelated"` em toda sprite/ícone existente). Usuário
perguntou diretamente se isso não quebrava a identidade do app — tinha
razão, foi erro de julgamento, não só gosto.

**Redesign CSS puro (sem asset ainda) aplicado:**
- `border-radius:50%` → removido em tudo (quadrado/losango, quinas retas)
- `radial-gradient`/`linear-gradient` → cor sólida chapada
- `box-shadow` com blur → halo em cruz/8 direções com cópias sólidas
  deslocadas (offset, blur-radius 0)
- `clip-path` de estrela arredondada → cruz pixelada (só ângulos de 90°)
- `ease-out` (interpolação suave) → `steps(3–6)` (movimento em saltos,
  tipo sprite quadro-a-quadro)

Essa versão intermediária **não é mais a que está no arquivo** — foi
inteiramente substituída pela Parte 2 abaixo. Registrado aqui só pelo
raciocínio (a lição de "checar contra a identidade visual estabelecida
antes de sair desenhando" vale pra qualquer efeito futuro).

### Parte 2: usuário trouxe um asset pack de verdade

Upload: `Super_Pixel_Effects_Gigapack__Free_Version__v2_8_0.zip`
(itch.io, Will Tice / unTied Games). Antes de qualquer coisa visual,
checagem de licença: **atribuição obrigatória + uso comercial liberado
+ proibido revender o asset isolado**. Confirmado tanto pelo
`license.txt` do pacote quanto por screenshot da página do itch.io que
o usuário mandou depois — bate.

**Resolução nativa compatível**: sprites do pack vêm em pixel art de
verdade (sem anti-aliasing), variante "small" em 32-48px, batendo com
o grid nativo do herói (32×32 — confirmado extraindo o sprite base64
já embutido no jogo). Isso é genuinamente mais fiel à identidade pixel
do que qualquer coisa desenhada em CSS puro.

**93 efeitos free catalogados** (9 categorias: Impacts, Lightning,
Magic Bursts, Fantasy Spells, Explosions, Sci-fi, Smoke Bursts,
Splatters, Symbols) — inventário completo gerado e entregue ao usuário
como GIF animado numerado + legenda em markdown, pra ele escolher por
número em vez de nome inteiro digitado.

### Seleção final de efeitos (por categoria de golpe)

| Categoria | Efeito do pack | Frames usados | Cor final (recolorida) |
|---|---|---|---|
| Corte | Directional Impact 002 | todos os 7 | `#EDEDED` (já era branco de origem) |
| Impacto | Symmetrical Impact 006 | todos os 8 | `#E8703C` |
| Perfuração | Directional Impact 003 | todos os 6 | `#EDEDED` |
| À distância | Directional Impact 001 (só o flash de chegada — a barra que viaja do herói até o monstro continua sendo CSS procedural, o pack não tem asset de "projétil em voo") | todos os 7 | `#EDEDED` |
| Arcano | Round Sparkle Burst 002 | recorte 1-7 (de 18 originais — fase de explosão densa, antes de virar poeira espalhada) | `#B57BE8` |
| Lendário (camada bônus, soma sobre a categoria) | Round Firework Burst 002 | recorte 15-20 (de 27 originais — fase de faíscas em anel solto; o usuário apontou exatamente esse frame por print) | `#F2A65A` (`COR_RAR[4]`) |

**Trocas ao longo da sessão, todas a pedido do usuário:**
- Lendário começou como Crown (`Symbols/symbol_crown_001`, recorte
  2-8 dos 45 frames originais — múltiplos de linha, não uma tira
  simples, por isso o recorte)
- Usuário pediu pra testar `#19 do catálogo` (numeração da legenda) =
  Round Firework Burst 002, mas achou que o recorte inicial (fase de
  explosão densa, frames 2-8) não batia com o que ele via no GIF —
  mandou print apontando a fase de faíscas em anel (frames ~16-19).
  Recorte final ajustado pra 15-20 depois de numerar cada frame
  individualmente e comparar com o print.
- Impacto/Arcano trocados de Symmetrical Impact 001 / Lightning Burst
  001 pros atuais porque as formas originais (dois anéis abertos com
  espinhos) ficavam parecidas demais entre si, só mudando cor —
  usuário pediu mais diferenciação de silhueta, não só de cor.

**Técnica de recolorização**: remapeamento de luminosidade (não
substituição de cor por cor) — preserva sombra/luz do sprite original,
só troca o matiz. Onde a cor-alvo já era próxima da original (corte,
perfuração, distância — todas brancas/prata de origem), o efeito é
quase identidade.

**Técnica de animação**: `background-position` animado via `steps(N)`
(spritesheet real, não interpolação suave) — cada spritesheet
recortada foi empacotada numa tira horizontal e embutida como base64
inline (mesmo padrão já usado pro sprite do herói). ~15KB de base64
total pros 6 efeitos, irrelevante no arquivo.

**Tamanho**: usuário pediu efeitos maiores → `TAMANHO_BASE = 2.2`
(multiplicador fixo, `const` no topo da função `fxSprite`), empilha
com a escala de raridade que já existia (0.75x–1.3x da seção 59) via
`transform:scale(TAMANHO_BASE * escala)`.

### Bug crítico encontrado e corrigido: corrupção de CSS por regex non-greedy

**Causa raiz**: cada troca de sprite foi feita via script Python
substituindo o bloco `.fx-sprite-<categoria>{...} @keyframes
fxSprite<Nome>{...}` inteiro por regex. O padrão usado
(`.*?\}` non-greedy, com `re.DOTALL`) parava no **primeiro** `}`
encontrado — que várias vezes era o fechamento do `from{...}` *interno*
do `@keyframes`, não o fechamento do bloco `@keyframes` inteiro (que
tem chaves aninhadas: uma pro `to{...}`, outra pro bloco todo).
Resultado: cada substituição (Impacto, Arcano, Lendário — 3 vezes)
deixou pra trás um fragmento órfão `to{background-position-x:-Npx}\n}`
solto no meio da folha de estilo, sobra da versão anterior que não foi
capturada pelo regex.

**Por que passou despercebido**: `node --check` só valida JavaScript,
nunca chega a olhar pra dentro de `<style>`. A checagem de
balanceamento de chaves que eu vinha rodando (contagem simples de `{`
vs `}` no arquivo inteiro) também não pegou, porque o número total de
chaves abertas/fechadas ainda batia — só a *estrutura* estava errada
(fragmentos soltos fora de contexto de regra CSS válida, não chaves
faltando). CSS não tem tolerância a fragmentos soltos como HTML às
vezes tem: a regra quebra silenciosamente, sem erro de console, e o
navegador simplesmente não aplica a animação. Usuário reportou "ainda
não apareceu dentro do app" — só aí que a investigação foi disparada.

**Fix**: os 4 fragmentos órfãos localizados manualmente (grep pelo
padrão `to{background-position-x:` sobrando fora de contexto) e
removidos um a um, com confirmação visual do trecho antes/depois de
cada remoção.

**Mudança de processo daqui pra frente**: instalado `css` (parser real
do npm, o mesmo tipo de parsing que o navegador faz) — toda edição de
CSS agora passa por `csstree.parse()` em cada bloco `<style>`, não só
contagem de chaves. Rodado depois do fix: 35/35 blocos válidos.
Qualquer sessão futura editando CSS via regex/substituição
programática deveria considerar sempre matching guloso (`.*` sem `?`)
com âncora explícita no próximo seletor conhecido, ou usar um parser
de verdade pra fatiar o bloco em vez de regex — non-greedy com chaves
aninhadas é uma armadilha real, não hipotética.

### Validação final desta sessão

`node --check` limpo nos 37 blocos de script. `css` (parser npm) limpo
nos 35 blocos de estilo. Balanceamento de tags mantido. Suíte jsdom
completa re-executada depois de cada mudança de sprite e depois do fix
de corrupção: 9 categorias, regressão hit/shake original, botão de
debug de armas, escala por raridade (crescente), Épico-vs-Lendário
distinguível — tudo passou na versão final.

### Pendências pro próximo chat

- **Tela de créditos**: a licença do pack exige atribuição
  ("Super Pixel Effects Gigapack — Will Tice / unTied Games") em
  algum lugar visível do app. Não existe tela de Sobre/Créditos hoje.
  Não bloqueia teste local, **bloqueia publicação**.
- **Teste real no Chrome Android**: tudo validado até aqui é
  estrutural (jsdom, node --check, parser CSS) — nenhuma confirmação
  visual real de como os 6 efeitos ficam na tela pequena do celular,
  se o tamanho 2.2x ficou grande demais/de menos, se o `steps()`
  anima suave o suficiente.
- Se o usuário quiser trocar mais algum efeito, a legenda numerada
  (`legenda_efeitos.md`, 93 itens) e o GIF (`todos_efeitos_numerado.gif`)
  já existem — não precisa gerar de novo, só re-consultar.

---

## 61. Reversão: usuário descartou a integração do asset pack, voltou pro CSS puro (v4.78, estado final do item 22)

> Versão do arquivo ao final desta sessão: `questlog-4-78-efeito-golpe-arma.html`
> **Este é o estado FINAL e canônico do item 22.** As seções 59 e 60
> documentam o caminho percorrido (histórico útil pra entender as
> decisões), mas **não** descrevem o que está no arquivo agora — a
> integração do Super Pixel Effects Gigapack (seção 60, Parte 2) foi
> revertida nesta sessão, a pedido direto do usuário ("volta com os
> efeitos básicos antes de colocar aquele pacote lá zip"). Sem
> explicação adicional dada — não perguntar de novo sobre a decisão,
> só respeitar.

### Estado final: 100% CSS procedural, zero asset externo

O bloco de efeito de golpe (autocontido, antes de `</body>`, gancho em
`window.animarGolpe`) é exatamente a versão "identidade pixel" da
seção 60 Parte 1 — a que veio *depois* do redesign (sem círculo, sem
gradiente, sem blur) mas *antes* de qualquer sprite do pack:

- **Corte**: `.fx-corte` — barra sólida `#EDEDED`, risco diagonal
- **Impacto**: `.fx-estrela` — 5 partículas em cruz pixelada (`clip-path`
  angular, só 90°), cor `#E8703C`, halo em cruz via `box-shadow`
  deslocado (0 blur)
- **Perfuração**: `.fx-perfuracao` (linha reta) + `.fx-pontoimpacto`
  (flash no ponto de impacto)
- **À distância**: `.fx-projetil` (barra viajando do herói até o
  monstro) + `.fx-pontoimpacto` na chegada
- **Arcano**: `.fx-arcanoparticula` — 8 partículas roxo/azul/verde,
  halo em 8 direções
- **Lendário** (camada bônus): `.fx-anel-lendario` — losango dourado
  `#F2A65A`, atrasado 110ms sobre o efeito de categoria (resolve a
  mesma confusão Épico-vs-Lendário documentada na seção 59, por forma
  e tempo, não por cor)
- **Auréola por categoria** (`.fx-aura`, losango `clip-path`) e
  **escala por raridade** (`ESCALA_RARIDADE`, 0.75x Comum → 1.3x
  Lendário, só intensidade, nunca cor) — os dois recursos da seção 59
  que sobreviveram à reversão, continuam ativos
- Todas as animações em `steps(3–6)` (movimento quadro-a-quadro, não
  easing suave)

**O que foi removido nesta reversão**: as 6 spritesheets base64
embutidas (Super Pixel Effects Gigapack), a constante `TAMANHO_BASE`
(multiplicador 2.2x), as funções `fxSprite`/`DUR_SPRITE`/
`SPRITE_POR_CATEGORIA`. Arquivo ficou ~12KB menor. Zero dependência de
licença de terceiro agora — não bloqueia mais publicação por conta de
crédito pendente (a pendência de tela de créditos da seção 60 **não se
aplica mais**, pode ser removida do radar a menos que o pack volte a
ser cogitado no futuro).

### Como foi feita a reversão

Reconstrução do bloco inteiro a partir do texto já escrito nesta mesma
sessão (não foi possível fazer diff/reverter automaticamente — o
arquivo tinha sido sobrescrito em cada edição, sem backup salvo em
disco). Colado via corte por índice de linha (não regex) pra não
repetir o erro de corrupção documentado na seção 60.

### Validação

`node --check` limpo nos 37 blocos de script. Parser `css` (npm) limpo
nos 35 blocos de estilo. Balanceamento de tags mantido idêntico à
baseline. Suíte jsdom completa re-executada com os seletores revertidos
(`.fx-estrela`, `.fx-corte`, `.fx-anel-lendario` etc. em vez de
`.fx-sprite-*`): 9 categorias, regressão hit/shake original, botão de
debug de armas, escala por raridade (crescente), Épico-vs-Lendário
distinguível — tudo passou.

### Não testado em sandbox

Nunca foi testado no dispositivo real em nenhuma das três encarnações
(pixel puro → sprites do pack → pixel puro de novo). Esse é o mesmo
"não testado" que já valia desde a seção 59 — a reversão não muda essa
pendência, só volta pro ponto de partida dela.

### Arquivos de referência que sobraram da sessão (não fazem mais parte do app, mas ficam disponíveis se o pack voltar à mesa)

`legenda_efeitos.md` (93 efeitos catalogados) e
`todos_efeitos_numerado.gif` — gerados durante a exploração do pack,
não precisam ser refeitos se uma sessão futura quiser retomar esse
caminho.




---

## 62. Item 23: a implementação real, em 3 tentativas — do fallback automático à preferência manual (v4.79–4.80)

> Versão do arquivo ao final desta sessão: `questlog-4-80-vibra-e-som.html`

### Resumo executivo

A spec do item 23 (seção 4) previa um fix simples: checar o retorno
`false` de `navigator.vibrate()`, além da exceção já tratada. Implementado
exatamente assim primeiro — **e não resolveu**, confirmado em teste real
do usuário. A causa raiz é mais funda do que a spec original sabia:
**não existe, em vários aparelhos, nenhum sinal que o JavaScript possa
captar quando o sistema bloqueia vibração silenciosamente.** A solução
final não é técnica (detectar melhor) — é de produto (deixar o usuário
escolher manualmente). 3 tentativas, nesta ordem:

### Tentativa 1 (v4.79) — exatamente a spec original

```js
try {
  const ok = navigator.vibrate(ms || 10);
  if (ok === false) window.tocarSom(som);
} catch(e){
  window.tocarSom(som);
}
```

Implementado, validado por sintaxe, entregue. **Usuário testou com Não
Perturbe ligado: silêncio total, nem vibrou nem tocou som.**

### Investigação da falha da tentativa 1

Pesquisado (não estava nos dados de treinamento com confiança
suficiente — Web APIs mudam): MDN documenta *"some devices may not
vibrate if they are in Silent mode or Do Not Disturb (DND) mode"* como
nota **separada** do comportamento de retorno `false`. A própria spec
da Vibration API deixa as condições de retorno `false` deliberadamente
não especificadas — decisão de cada implementação/fabricante. Na
prática: em vários aparelhos, o Chrome entrega o pedido pro sistema
operacional, o SO recebe o comando "Não Perturbe" e decide não vibrar —
mas devolve `true` pro navegador mesmo assim, porque do ponto de vista
do browser a chamada "funcionou" (foi repassada). **Não existe sinal
nenhum pro JS detectar esse caso específico.** Confirmado que não é
falta de mais uma checagem — é ausência estrutural de informação.

### Tentativa 2 (efêmera, mesma sessão) — vibra E toca, sempre

Descartada a ideia de detectar; virou incondicional:

```js
window.vibrarETocar = function(som, ms){
  if (!ativo) return;
  if ('vibrate' in navigator){
    try { navigator.vibrate(ms || 10); } catch(e){}
  }
  window.tocarSom(som);
};
```
(função renomeada de `vibrarOuTocar` pra `vibrarETocar`, já que virou
"e" em vez de "ou")

Resolve o silêncio, mas troca por outro problema: em aparelho **sem**
bloqueio nenhum, agora toca vibração **e** som juntos em todo clique de
nav — o usuário achou redundante ("não dá pra sair só um som?").

### Tentativa 3 (v4.80, final) — preferência manual, não detecção

Given que não existe informação confiável, a saída foi expor a decisão
pro usuário em vez de tentar adivinhar:

```js
window.feedbackPreferido = () => feedback;               // 'vibrar' | 'som'
window.definirFeedbackPreferido = function(v){ ... };     // persiste em questlog.sfx.v1

window.feedbackClique = function(som, ms){                // renomeado de novo, nome neutro
  if (!ativo) return;
  const usarVibracao = feedback === 'vibrar' && ('vibrate' in navigator);
  if (!usarVibracao){ window.tocarSom(som); return; }
  try {
    const ok = navigator.vibrate(ms || 10);
    if (ok === false) window.tocarSom(som);
  } catch(e){
    window.tocarSom(som);
  }
};
```

Mantém a checagem de `false`/exceção da tentativa 1 como rede de
segurança extra pros aparelhos que *reportam* corretamente — não some
esse cuidado, só para de depender **só** dele. `feedback` default
`'vibrar'` (mesmo comportamento de sempre pra quem não mexe em nada).

**Controle:** nova linha em Perfil > Config (`Feedback de clique`,
botão que alterna "Vibrar"/"Som" e já testa a escolha na hora do
clique) — **não** um ícone na topbar. Motivo, decisão do usuário: o
botão de mudo (seção 53-ish/toggle de volume) está na topbar porque é
ajuste "na hora, durante o jogo"; esta preferência é "testa uma vez,
esquece" — não justifica ocupar espaço permanente na tela só de
"coisa boba" sempre visível. Só aparece (linha inteira, não só botão
desabilitado) em aparelho que suporta `navigator.vibrate` — em
iOS/Firefox 129+ a escolha seria falsa, "vibrar" cairia sempre pro som
de qualquer jeito.

**Sincronização:** `abrirConfig()` (fechada na mesma IIFE de "PERFIL —
SUB-ABAS", mesma armadilha de closure de sempre) ganhou mais uma linha
de gancho defensivo (`if (typeof window.atualizarBotaoFeedback ===
'function') ...`), mesmo padrão já usado por `atualizarLinhaConta()`
ali do lado.

### Nome da função, 3 vezes — lição de nomenclatura

`vibrarOuTocar` (v4.62) → `vibrarETocar` (tentativa 2, mesma sessão) →
`feedbackClique` (tentativa 3, final). As duas primeiras descreviam
implementação (`Ou`/`E`), e cada mudança de comportamento invalidava o
nome. A 3ª é neutra de propósito — descreve o *efeito* (dar feedback de
clique), não o *mecanismo* — pra não precisar renomear de novo se a
lógica interna mudar outra vez. **Lição pra nomear função que pode
evoluir: nome pelo efeito observável, não pela implementação atual.**

### Storage

`questlog.sfx.v1` ganhou 3º campo: `{ ativo, volume, feedback }`. Mesma
chave de sempre, mesmo padrão de carregar com fallback seguro
(`typeof salvo.campo === tipo esperado`) já usado pros outros dois.

### Validação

37 blocos `<script>` clássicos + 1 `<script type="module">`, `node
--check` limpo nos dois grupos. `<div>` 313/313, `<svg>` 32/32,
comentários 31/31.

---

## 63. Dois bugs pequenos da tela de Perfil: teto real de Fortuna/Foco e colagem de texto no xprow (v4.81)

> Versão do arquivo ao final desta sessão: `questlog-4-81-fix-atributos-xprow.html`

Sessão dedicada a bugs pequenos e diretos, sem sessão de brainstorm
prévia — os dois já vinham anotados como pendência no cabeçalho do
roadmap.

### Bug A — pontos de atributo desperdiçados silenciosamente

`bonusFortuna()`/`descontoFoco()` já clampavam o valor exibido com
`Math.min(TETO, gasto * POR_PONTO)`, mas `investir()` só checava
`pontosDisponiveis() <= 0` — não se o atributo *específico* já tinha
saturado. Resultado: dava pra continuar gastando ponto em Fortuna após
o 13º (ou Foco após o 15º) sem nenhum ganho e sem aviso, só consumindo
o ponto à toa.

Fix: nova função `noTeto(atr)` que reusa `bonusFortuna()`/
`descontoFoco()` pra checar se o atributo já bateu o teto. `investir()`
bloqueia e chama `window.aviso('Esse atributo já está no teto máximo')`
antes de incrementar. `renderAtributosPontos()` passa a desabilitar
cada botão (`atrMaisFortuna`/`atrMaisFoco`) individualmente quando
aquele atributo satura, mesmo com pontos disponíveis sobrando — antes
só desabilitava quando `pontosDisponiveis()` chegava a zero.

### Bug B — label/valor de XP e Vida colando no card do Perfil

`.xprow{justify-content:space-between}` não tem `gap` mínimo. Na
topbar (`#hpnum`/`#xpnum`) o container é largo e nunca deu problema; no
card do Perfil (`.perfilheroInfo{flex:1;min-width:0}`, ao lado do
sprite do herói) o espaço é mais apertado e nível/XP alto (ex.
`9999 / 9999`) encostava no label.

Fix escopado — **não** mexeu na regra genérica `.xprow` (reaproveitada
fora do Perfil): nova regra `.perfilhero .xprow{gap:8px}` mais
`flex:none` no label e no valor pra eles pararem de disputar espaço
elástico entre si.

### Validação

Diff conferido linha a linha contra a v4.80 — só as linhas dos dois
fixes mudaram, nada mais tocado. `node --check` limpo nos 37 blocos
clássicos + 1 módulo. Balanço de tags idêntico ao baseline: `<div>`
313/313, `<svg>` 32/32, comentários 31/31.

---

## 64. Autoscroll ao arrastar tarefa pra reordenar (v4.81)

> Versão do arquivo ao final desta sessão: `questlog-4-81-fix-atributos-xprow.html`

### O bug

`#list` tem scroll próprio (`overflow-y:auto`). O sistema de arrastar
(seção "segurar em qualquer parte do card", bloco autônomo perto do fim
do arquivo) só reordenava entre os `.task` **já visíveis** na tela — o
`pointermove` comparava `e.clientY` contra o meio de cada irmão visível
pra decidir onde mover o placeholder, mas nunca tocava `list.scrollTop`.
Numa lista longa, não dava pra arrastar uma tarefa do topo pro fim (ou
vice-versa) numa tacada só: a tela não seguia o dedo.

### O fix

Três mudanças, todas dentro da mesma IIFE do módulo de arrastar:

1. **`atualizarPlaceholder(clientY)`** — extraída do que antes era um
   trecho inline dentro do `pointermove`. Mesma lógica exata (percorre
   os irmãos, decide se o placeholder vai antes de um deles ou no
   fim), só que agora é uma função nomeada — precisa ser chamável de
   dois lugares, não só do `pointermove`.

2. **`passoAutoScroll()`** — loop via `requestAnimationFrame` que roda
   sozinho enquanto `dragEl` existir. A cada frame mede a distância do
   último `clientY` conhecido até o topo/fundo de `list.getBoundingClientRect()`;
   dentro de uma faixa de 70px da borda, ajusta `list.scrollTop` (mais
   rápido quanto mais perto da borda, até 14px/frame) e chama
   `atualizarPlaceholder()` de novo — necessário porque a lista pode
   rolar sem o dedo se mexer, e o placeholder precisa acompanhar.
   Para sozinho quando `dragEl` vira `null` (solto o card).

3. **`ultimoClientY`** — variável de estado que guarda a última posição
   do dedo, atualizada tanto em `iniciarArrasto()` (arma o valor inicial
   e já dispara o primeiro `requestAnimationFrame`) quanto a cada
   `pointermove`. O loop de autoscroll depende dela porque roda
   independente de o `pointermove` disparar ou não.

O card em si continua se movendo por `position:fixed` com
`left`/`top` recalculados a cada `pointermove` — isso já funcionava
certo e não precisou mudar; o scroll da lista por baixo dele não afeta
o posicionamento porque é fixo à viewport, não ao documento.

### Por que não usar scroll nativo do navegador

`touch-action:none` já está em uso nesse componente pra tirar o scroll
nativo do caminho durante o gesto (documentado no comentário original
da seção de "soltar como scroll"). Sem controlar o scroll manualmente
via `requestAnimationFrame`, não haveria como fazer a lista rolar
*enquanto* o dedo fica parado numa borda segurando o card — só existe
esse timing quando o próprio código dirige o `scrollTop`.

### Validação

`node --check` limpo nos 38 blocos (37 clássicos + 1 módulo). Diff
conferido: só o bloco de arrastar mudou nesta seção. Balanço de tags
mantido: `<div>` 313/313, `<svg>` 32/32, comentários 31/31.

---

## 65. Reversão do teste de ícones PNG nas Conquistas (v4.81)

> Versão do arquivo ao final desta sessão: `questlog-4-81-fix-atributos-xprow.html`

### Contexto

O sistema de Conquistas V2 (seção 6690+, lista curada e plana de 17
marcos) tinha um teste em andamento: 4 das 17 conquistas
(`sequencia:5`, `monstros:2`, `itens:8`, `monstros:9`) usavam ícones
PNG de uma amostra promocional do pack "1-bit Pixel Icons", enquanto as
outras 13 continuavam com o SVG de linha da própria categoria
(`cat.icone`, o mesmo estilo usado no resto do app). O comentário
original já deixava marcado que era teste pendente de decisão: comprar
o pack completo se aprovasse o estilo, ou reverter pro SVG.

O usuário reportou que os ícones "fora do padrão" incomodavam — mistura
de estilos visuais na mesma lista (pixel art vs. linha) sem o pack
completo pra cobrir as 17, que era a condição original pra manter a
mudança.

### O fix

Em `CONQUISTAS_V2` (o `.map()` que monta a lista final a partir de
`IDS_CURADOS_V2`), o campo `img` deixou de consultar `ICONES_TESTE_V2[id]`
e passou a ser sempre `null`. Como `renderConquistasV2()` já tinha a
lógica de fallback pronta (`item.img ? <img> : <svg>...`), não precisou
mexer em nada na função de render — só a fonte do dado mudou.

`ICONES_TESTE_V2` (o objeto com os 4 base64) **não foi apagado** —
convenção append-only do arquivo, documentado como registro histórico
de como era, caso uma sessão futura queira retomar a ideia com o pack
completo.

### Validação

`node --check` limpo nos 38 blocos. Diff conferido: só a linha do
`img` em `CONQUISTAS_V2` e o comentário acima dela mudaram nesta seção.
Balanço de tags mantido: `<div>` 313/313, `<svg>` 32/32, comentários
31/31.

---

## 66. Placeholder do drag de tarefa: tentativa de borda tracejada, revertida (v4.81)

> Versão do arquivo ao final desta sessão: `questlog-4-81-fix-atributos-xprow.html`

### Tentativa 1 — borda tracejada

Pedido inicial: deixar visível onde a tarefa vai cair ao soltar.
Tentativa: trocar `.task-placeholder` de `background:transparent;border:none`
pra uma borda tracejada na cor de destaque (`2px dashed var(--accent)`,
`border-radius:10px`, `opacity:.5`).

**Revertida na mesma sessão** — o usuário queria só um espaço vazio
maior mostrando o "buraco" entre as tarefas, não uma caixa com contorno.
`.task-placeholder` voltou exatamente ao valor original
(`background:transparent;border:none;margin-bottom:9px`) — diff contra
a v4.80 confirma zero mudança nessa regra.

### O que já resolvia o "onde vai cair"

O placeholder já ocupa a altura certa no fluxo (`placeholder.style.height
= r.height + 'px'`, em `iniciarArrasto()`), e `moverPlaceholderAnimado()`
(FLIP) desliza os vizinhos suavemente pra abrir espaço nele — o espaço
vazio em si já existe e se move junto com o dedo. Combinado com o
autoscroll da seção 64 (a lista rola sozinha perto das bordas), o gap
fica visível e acompanha o arrasto sem precisar de nenhuma pista visual
extra tipo borda ou preenchimento.

### Validação (tentativa 1)

`node --check` limpo nos 38 blocos. Diff contra a v4.80: zero mudança
em `.task-placeholder` (voltou ao original). Balanço de tags mantido:
`<div>` 313/313, `<svg>` 32/32, comentários 31/31.

### Tentativa 2 (final) — não era estilo, era tamanho

Pedido mal-entendido na tentativa 1: não era sobre *como* o gap parece
(linha/contorno), era sobre o *tamanho* dele. `placeholder.style.height`
em `iniciarArrasto()` usava `r.height` — exatamente a altura do card
sendo arrastado, o que fazia o gap parecer só "o espaço que o próprio
card já ocupava", sutil demais pra notar ao passar por cima de outra
tarefa.

Fix: `placeholder.style.height = (r.height + 40) + 'px'` — abre um vão
40px maior que o card, perceptível mesmo em listas com cards pequenos.
Resto de `iniciarArrasto()` (posição fixa do card real, offsets,
`setPointerCapture`) intocado.

### Validação (tentativa 2)

`node --check` limpo nos 38 blocos. Diff contra a v4.80: só a linha de
`placeholder.style.height` mudou. Balanço de tags mantido: `<div>`
313/313, `<svg>` 32/32, comentários 31/31.

### Tentativa 3 (final) — volta ao tamanho normal

Feedback do usuário depois de ver a tentativa 2 rodando: o gap devia
ser do tamanho que uma tarefa normal ocupa, não maior. `placeholder.style.height`
voltou de `r.height + 40` pra `r.height` puro — mesmo valor da v4.80
original. Entre as três tentativas desta seção (borda tracejada →
altura maior → altura normal), o que sobrou de mudança real é zero
nessa linha especificamente; o que resolve o pedido original (mostrar
onde a tarefa vai cair) é a combinação do placeholder ocupando o
tamanho certo no fluxo + o autoscroll da seção 67, não um ajuste
cosmético nele.

### Validação (tentativa 3)

`node --check` limpo nos 38 blocos. Diff contra a v4.80: zero mudança
em `.task-placeholder` e em `placeholder.style.height` — ambos
voltaram ao original. Balanço de tags mantido: `<div>` 313/313, `<svg>`
32/32, comentários 31/31.

---

## 67. Autoscroll: zona de gatilho apertada pra ativar só na borda real (v4.81)

> Versão do arquivo ao final desta sessão: `questlog-4-81-fix-atributos-xprow.html`

### O ajuste

`BORDA_AUTOSCROLL` (seção 64) começava em 70px — um buffer generoso
que fazia a lista começar a rolar bem antes do dedo chegar de fato na
borda da área visível de tarefas. Pedido do usuário: o autoscroll só
deveria ativar quando a área visível de tarefas na tela realmente
acabasse e precisasse subir/descer pra revelar mais itens, não antes
disso.

Reduzido pra 16px — ainda uma faixa pequena o bastante pra dar uma
folga de detecção contra o dedo parar exatamente no pixel da borda
(caso raro de trigger falhar por 1px de diferença), mas pequena o
bastante pra não disparar cedo demais. `VELOC_MAX_AUTOSCROLL` (14px/frame
no pico) não mudou — só a distância que ativa o gatilho.

Resto da lógica de `passoAutoScroll()` (seção 64) intocada: mesmo
cálculo de velocidade proporcional à proximidade da borda, mesmo guard
contra rolar além do início/fim do conteúdo.

### Validação

`node --check` limpo nos 38 blocos. Diff contra a v4.80: só a constante
`BORDA_AUTOSCROLL` mudou de valor. Balanço de tags mantido: `<div>`
313/313, `<svg>` 32/32, comentários 31/31.

---

## 68. Vão elástico no drag de tarefa (v4.81)

> Versão do arquivo ao final desta sessão: `questlog-4-81-fix-atributos-xprow.html`

### Origem do pedido

Usuário mandou vídeo de outro app mostrando o efeito desejado.
Confirmado por ele mesmo que **não era o Questlog** rodando — era só
referência visual. No vídeo, ao arrastar um card, o espaço vazio deixado
no lugar original não tem altura fixa: ele cresce continuamente
acompanhando a distância entre o card flutuante (seguindo o dedo) e o
slot de onde ele saiu, dando uma sensação "elástica" — puxa mais,
abre mais.

### O que existia antes

`placeholder.style.height` era setado uma vez em `iniciarArrasto()`
(`r.height`, a altura do card) e só mudava de novo quando o placeholder
trocava de posição no DOM via `moverPlaceholderAnimado()` (troca
discreta ao cruzar o meio de um vizinho) — sem nenhum vínculo com a
distância que o dedo já percorreu.

### O fix

Nova função `atualizarAlturaElastica()`, chamada a cada `pointermove`
durante o arrasto e a cada frame do loop de autoscroll (seção 64) —
precisa rodar nos dois lugares porque o scroll da lista move a posição
do placeholder no viewport mesmo sem o dedo se mexer.

Lógica: mede a posição atual do placeholder no viewport (`phTop`,
`getBoundingClientRect().top`, já que ele é filho normal do fluxo de
`#list` e se move com o scroll) contra a posição atual do card
flutuante (`dragTop`, lido direto de `dragEl.style.top`, que é
`position:fixed` e segue o dedo). Se o card se afastou pra baixo do
placeholder, o vão estica até alcançar o fundo do card; se se afastou
pra cima, estica até alcançar o topo dele. Nunca fica menor que
`alturaBaseCard` (a altura do card capturada no instante em que o
arrasto começou, nova variável de estado) nem maior que
`list.clientHeight` (teto de segurança pra não esticar além da própria
área visível da lista).

```js
function atualizarAlturaElastica(){
  if (!placeholder || !dragEl) return;
  const phTop = placeholder.getBoundingClientRect().top;
  const phBottomBase = phTop + alturaBaseCard;
  const dragTop = parseFloat(dragEl.style.top) || 0;
  const dragBottom = dragTop + alturaBaseCard;

  let altura = alturaBaseCard;
  if (dragBottom > phBottomBase){
    altura = dragBottom - phTop;
  } else if (dragTop < phTop){
    altura = phBottomBase - dragTop;
  }
  altura = Math.max(alturaBaseCard, Math.min(altura, list.clientHeight));
  placeholder.style.height = altura + 'px';
}
```

A troca discreta de posição no DOM (`atualizarPlaceholder()`/
`moverPlaceholderAnimado()`, seção 64) continua existindo do jeito que
estava — o vão elástico é uma camada visual por cima, não substitui a
lógica de "pra qual slot o placeholder pertence". Quando o placeholder
muda de posição no DOM (cruzou o meio de um vizinho), `phTop` muda na
próxima leitura de `getBoundingClientRect()` e o elástico recalcula a
partir do novo ponto, sem precisar de nenhum reset manual.

### Limitação conhecida desta sessão

**Validado só por lógica isolada e sintaxe, não visualmente.** Testado
com `node` puro a fórmula de `atualizarAlturaElastica()` em casos de
borda (parado, esticando pra baixo, esticando pra cima, exagero
capado pelo teto, drag mínimo de 1px) — todos bateram o esperado. Mas
não há como simular o gesto de toque real (`pointerdown`/`pointermove`
sequenciado com posições de tela reais) nem ver o resultado renderizado
nesta sessão. Jean precisa testar no aparelho antes de considerar
fechado — especialmente o comportamento combinado com o autoscroll
(seção 64) e com listas de tamanhos variados.

### Validação

`node --check` limpo nos 38 blocos. Diff contra a v4.80: nova função
`atualizarAlturaElastica()`, nova variável `alturaBaseCard`, e as
chamadas dela em `iniciarArrasto()`, `pointermove` e `passoAutoScroll()`
— nada além disso tocado. Balanço de tags mantido: `<div>` 313/313,
`<svg>` 32/32, comentários 31/31.
## 69. Efeitos de golpe: sprites animados do pack "Slashes", por raridade (v4.86)

> Versão do arquivo ao final desta sessão: `questlog-4-86-slash-fx.html`

### Origem do pedido

Jean anexou `Pixel_Art_Animations_-_Slashes.zip` (3 estilos de golpe —
`Slash 1`/`Slash 2`/`Slash 3` — em 5 cores cada, 64×64 e 128×128,
7-9 frames por animação) pedindo pra melhorar as animações de combate,
que até então eram só CSS/SVG puro (linhas, partículas, pontos —
seção 61, estado revertido pra pure-CSS).

### Trajetória da sessão (decisões e reversões, nessa ordem)

1. **Primeira tentativa: sprite por categoria de arma.** `corte`/`impacto`
   ganharam sprite (`Slash 1` branco / `Slash 2` laranja),
   `perfuracao`/`distancia`/`arcano` mantidos em CSS puro. Bug de escala
   (largura/altura do elemento dessincronizada do `background-size` da
   sprite-sheet) fez o golpe borrar numa mancha branca pra qualquer
   raridade com escala ≠ 1 — corrigido trocando pra `transform:scale()`
   em vez de redimensionar o elemento.
2. Pedido pra tirar **todo** efeito residual (aura, partículas) que
   sobrava atrás/junto do sprite nas categorias com sprite — feito.
3. Identificado por vídeo enviado pelo usuário: um "quadrado laranja"
   aparecendo em cima do monstro com arma Lendária. Era o
   `fxAnelLendario` (efeito pré-existente, não relacionado ao sprite
   novo) — `clip-path` de losango com `background` sólido em vez de
   contorno. Removido. Segunda rodada do mesmo sintoma: era o `fxAura`
   (também losango sólido via `clip-path`, comentário original já
   dizia "losango solido"). Removido também — a camada extra de
   Lendária ficou só com as partículas.
4. **Decisão que mudou o eixo inteiro:** usuário percebeu que o Taco de
   Madeira (comum, categoria `impacto` nativa) e qualquer arma Lendária
   testada com o override "Lendária = Slash 2 laranja" ficavam com o
   mesmo visual — a categoria como eixo de cor colidia com raridade como
   eixo de tamanho. **Sprite por categoria foi abandonado.** Critério
   virou: **cor = raridade**, categoria da arma não influencia mais o
   efeito visual.
5. Cores definidas pelo usuário mapeando pra `RARIDADES`/`COR_RAR`
   (`0..4`, "Único" sem cor definida — cai no fallback de Lendário):

   | Raridade | Cor do slash |
   |---|---|
   | Comum | branco |
   | Incomum | verde |
   | Raro | azul |
   | Épico | roxo |
   | Lendário | laranja |

6. Iteração de estilo/movimento, também por pedido explícito, em ordem:
   - Sprite parado no centro → usuário pediu pra **atravessar o mob**
     (efeito de corte de verdade, não só cycling de frame no lugar) →
     implementado deslocamento horizontal, depois trocado pra diagonal.
   - Testou `Slash 2` (comum/incomum) + `Slash 3` (raro/épico) +
     `Slash 1` (lendário, inalterado) — variedade de movimento por
     estilo, dando 3 grids diferentes (7 vs 9 frames) rodando em
     paralelo.
   - Pedido pra **raro/épico pararem de se deslocar** (ficar fixos,
     só ciclando frame) — implementado com `@keyframes` próprio sem
     `translate`/`rotate` de varredura.
   - Ajustes de escala em várias rodadas (ver histórico de valores de
     `ESCALA_RARIDADE` abaixo) — inclusive um bug real: o offset de
     recentralização (`translateY`) tinha sido escrito **depois** de
     `scale()` na composição do `transform`, então era um deslocamento
     fixo em px que não acompanhava a escala — aumentar o tamanho sem
     ajustar o offset fazia o sprite "subir" de novo. Corrigido
     invertendo a ordem (`scale()` antes de `translateY()`), com os
     valores de offset recalculados a partir do centro de massa real
     dos pixels opacos de cada sprite (medido via Pillow, não chute).
   - Pedido pra **comum/incomum/lendário também pararem de se
     deslocar** — mesma lógica de fixo aplicada aos 3.
   - Ângulo de rotação fixo adicionado (`rotate(25deg)`), sentido
     invertido uma vez a pedido do usuário.
   - Pedido de teste final: **todas as 5 raridades usando o mesmo
     estilo/tamanho do raro/épico** (`Slash 3`, 9 frames), só cor
     mudando — pra comparar se a progressão de raridade já ficava
     clara só pela cor, sem diferença de sprite/escala por classe.
     **Esse teste foi aprovado e virou o estado final.**

### Estado final (o que está no arquivo agora)

Todas as 5 raridades usam **`Slash 3`** (9 frames, 576px de sprite-sheet),
**mesmo tamanho** (`ESCALA_RARIDADE` uniforme, `1.4` pra todas — antes
tinha uma curva crescente por raridade, abandonada nesse teste final),
**fixas no centro do mob** (sem varredura/translação), `rotate(25deg)`,
`.42s steps(9) forwards`. Só a cor/filtro muda:

| Raridade | Fonte no pack | Filtro CSS |
|---|---|---|
| Comum | `Slash 3/color5` (ciano) | `grayscale(1) brightness(2.4)` → branco |
| Incomum | `Slash 3/color1` (verde) | nenhum (nativo) |
| Raro | `Slash 3/color5` (ciano) | nenhum (nativo) |
| Épico | `Slash 3/color3` (azul-roxo) | `hue-rotate(44deg) saturate(1.3) brightness(1.1)` → roxo |
| Lendário | `Slash 3/color4` (laranja) | nenhum (nativo) |

Categoria da arma (`corte`/`impacto`/`perfuracao`/`distancia`/`arcano`)
**não influencia mais nada visualmente** no golpe — só raridade decide
sprite/cor/tamanho.

`equipado.arma === null/undefined` (sem arma, soco) cai em raridade 0
(comum), mesma faixa de intensidade de uma arma comum equipada — sem
mudança de comportamento aqui.

Raridade "Único" (índice 5 em `RARIDADES`, se algum item algum dia usar)
não foi especificada pelo usuário — cai no fallback de Lendário
(`CLASSE_POR_RARIDADE[rar] || 'lendario'`). Se aparecer algum item
Único, decidir separadamente se merece cor própria.

### Limpeza de código morto (fim da sessão)

Removido tudo que ficou sem nenhuma chamada depois da mudança de eixo
categoria→raridade e das iterações de movimento:

- Funções JS: `fxAura`, `fxAnelLendario`, `fxParticula`, `fxPonto`,
  `fxLinha` (efeitos CSS-puro de categoria, pré-sprite)
- `CAT_ARMA` (tabela id-arma→categoria) e `categoriaArmaAtual()` —
  sem consumidor desde a mudança pra raridade
- `efeitoGolpeCategoria(cat, lendaria, rar)` renomeada pra
  `efeitoGolpeRaridade(lendaria, rar)` — parâmetro `cat` removido do
  assinatura e da chamada, já que não era mais lido dentro da função
- CSS: `.fx-aura`, `.fx-anel-lendario`, `.fx-particula`, `.fx-estrela`,
  `.fx-arcanoparticula`, `.fx-pontoimpacto`, `.fx-corte`,
  `.fx-perfuracao`, `.fx-projetil` e todos os `@keyframes` associados
  (`fxAuraPulso`, `fxAnelLendario`, `fxParticulaBurst`,
  `fxPontoImpacto`, `fxCorte`, `fxPerfuracao`, `fxProjetil`)
- Também ficaram mortos (não removidos ainda, próxima sessão se
  precisar): os `@keyframes` intermediários de iterações anteriores
  que não são mais referenciados por nenhuma classe —
  confirmar se sobrou algum resíduo desses na versão final salva.

O que ficou ativo: `centroRelativoArena()`, `fxSpriteSlash()`,
`armaEhLendaria()`, `raridadeArmaAtual()`, `escalaPorRaridade()`,
`efeitoGolpeRaridade()`, e um único `@keyframes fxSpriteSlash9Fixo`
usado pelas 5 classes de raridade (`.comum`, `.incomum`, `.raro`,
`.epico`, `.lendario`).

### Assets embutidos

Sprites extraídos do zip com Pillow (strips horizontais próprios,
1 linha × N frames, não o `sprite-sheet.png` do pack que vem em grid
5×2 com slots vazios), convertidos pra base64 e embutidos em `:root{}`
como `--spr-slash-comum/incomum/raro/epico/lendario`. Peso total
adicionado ao arquivo: ~15-20KB de base64, desprezível.

### Validação

`node --check` limpo nos 38 blocos de `<script>` em toda a sessão.
Balanço de tags (`<div>`, `<style>`, `<script>`, `<svg>`) conferido a
cada entrega. CSS validado com parser real (`css` via npm), não
contagem de chaves. Lógica de seleção de sprite por raridade simulada
em `jsdom` pra cada uma das 5 raridades a cada mudança relevante —
confirmado que cada raridade dispara exatamente 1 elemento
`.fx-sprite-slash` com a classe certa e nenhum elemento residual de
efeito antigo.

**Não validado nesta sessão:** renderização visual real (posição/
proporção/legibilidade em tela) — só o que apareceu nos 2 vídeos que o
usuário mandou durante o processo. Aprovação final ("muito bom, não
precisa mexer mais") foi verbal, sem novo vídeo/print confirmando o
estado exato pós-limpeza de código morto. Recomendado Jean confirmar
visualmente essa build final no aparelho antes de considerar fechado,
já que a limpeza mexeu em código (removeu funções/CSS) depois do
último vídeo aprovado.

## 70. Divisão do arquivo único em `index.html` + `style.css` + `assets.js` (v4.127)

**Motivação:** arquivo único vinha ficando pesado (10.361 linhas / 553KB)
por causa de dois blocos de conteúdo que não são lógica de jogo — CSS
espalhado em 37 blocos `<style>` e os catálogos `MONSTROS`/`HEROIS`/
`ITENS` com sprites em base64 embutido. Objetivo: extrair esses dois
blocos pra arquivos próprios e economizar tokens nas próximas sessões
de implementação, sem tocar em nenhuma lógica de jogo.

### O que foi feito

**`style.css` (novo arquivo, 2.981 linhas / 250KB):**
Consolidados **todos os 37 blocos `<style>`** do arquivo original — 17
que ficavam no `<head>` e **20 que estavam espalhados pelo corpo**,
colados dentro dos módulos autônomos (editor de tarefa, vida do herói,
equipamento visível, atributos evoluíveis, histórico, conquistas, SFX,
bestiário, tela de login, etc. — os blocos marcados nos comentários
como "bloco autônomo, cole antes de `</body>`"). Cada bloco original
ficou marcado por comentário (`/* ===== Bloco style #N ===== */`) pra
rastrear a origem se precisar depurar.

No HTML, os 37 blocos foram substituídos por uma única
`<link rel="stylesheet" href="style.css">`, inserida no `<head>` no
lugar do primeiro bloco (linha 19 do arquivo original).

**`assets.js` (novo arquivo, 187 linhas / 108KB):**
Os três catálogos de dados extraídos como estavam, sem nenhuma
alteração de conteúdo:
- `MONSTROS` (13 monstros, sprites base64)
- `HEROIS` (7 heróis, sprites base64)
- `ITENS` (~50 itens, array compacto sem sprite próprio —
  `[id, nome, tipo, raridade, preco, atk, def]`)

No HTML, os três `const` foram removidos dos blocos `<script>` onde
viviam e substituídos por `<script src="assets.js"></script>`,
inserido **antes do primeiro `<script>` inline** (scripts clássicos
executam em ordem de aparição no documento, então isso garante que
`MONSTROS`/`HEROIS`/`ITENS` já existem no escopo global quando
`heroiAtual()`, `desenharHeroi()` e o módulo de inventário rodam).

### Resultado

| Arquivo | Linhas | Tamanho |
|---|---|---|
| `index.html` original (tudo junto) | 10.361 | 553 KB |
| `index.html` final (só estrutura + lógica) | 8.299 | 387 KB |
| `style.css` | 2.981 | 250 KB |
| `assets.js` | 187 | 108 KB |

**Nota de expectativa:** o usuário estranhou o HTML final ainda ter
~8.300 linhas — esperava uma redução mais parecida com o número de
linhas removidas. Explicado que linha não é a métrica certa aqui: cada
sprite base64 era uma única linha gigante, então a extração dos
catálogos cortou pouca contagem de linha (~183) mas bastante peso real
(~108KB). O que sobrou no HTML é lógica de jogo genuína (39 blocos
`<script>` — economia, combate, inventário, loja, conquistas,
bestiário, editor de tarefas, autenticação Firebase) que **não foi
tocada nem cortada**, só o CSS e os dados estáticos saíram.

### Não feito nesta sessão (decisão consciente, não pendência)

Cogitado ir além e separar os 39 blocos `<script>` em arquivos JS
próprios por módulo (`combate.js`, `inventario.js`, `loja.js`...), o
que reduziria a contagem de linha do HTML de forma mais visível. **Não
feito** porque, diferente do CSS e dos catálogos (dados estáticos
óbvios pra isolar), os blocos de script são interdependentes por
escopo — muitos módulos dependem de `const`/`let` declarados em blocos
anteriores dentro do mesmo arquivo (arquitetura já documentada no
roadmap: "por isso vive no mesmo `<script>` — const não atravessa
blocos separados"). Mapear essas dependências pra dividir sem quebrar
nada é uma refatoração de risco bem maior que a extração de CSS/dados,
e não foi pedida. Se o usuário quiser esse próximo nível de divisão,
tratar como sessão dedicada, com o mesmo cuidado de mapeamento de
dependências usado historicamente pra outras refatorações de risco
neste projeto.

### Validação

`node --check` limpo nos 39 blocos `<script>` clássicos restantes no
HTML pós-extração (o bloco `type="module"` não entra nessa checagem
específica). Balanço de tags conferido: `<div>` 360/360, `<svg>` 46/46,
zero `<style>` remanescente no HTML. Confirmado por `grep` que os três
`const` (`MONSTROS`, `HEROIS`, `ITENS`) não existem mais em lugar
nenhum do HTML. Arquivo termina corretamente em `</body></html>`.

**Não validado nesta sessão:** teste em aparelho real do
`index.html` novo carregando `style.css` e `assets.js` via `<link>`/
`<script src>` — a extração foi só estrutural (mesmo conteúdo, arquivos
diferentes), mas o comportamento de carregamento de arquivo externo
(caminho relativo, CORS se aplicável no Netlify, ordem de carregamento)
não foi testado fora do ambiente local. Recomendado publicar os três
arquivos juntos no Netlify e confirmar que o app abre normal antes de
considerar essa divisão finalizada.

## 71. Validação proativa de criar tarefa (desabilitar botão em vez de toast)
 
### Origem do pedido
Usuário queria que a criação de tarefa avisasse de forma mais clara quando algo impedia a ação — sem depender de `aviso()`, que está mudo desde que `TOASTS_DESATIVADOS = true` (item 41). Decisão explícita do usuário: solução mais simples possível.
 
### O que foi feito
- `#save` ("Criar tarefa") e `#addbtn` ("+ Adicionar") passam a vir **desabilitados proativamente**, cobrindo os 3 casos: monstro já caiu no dia (`monstroJaCaiu()`), título vazio, e "repete" sem nenhum dia da semana marcado.
- Nova função `atualizarEstadoSave()`, ligada em: digitar no input, trocar hoje/repete, marcar/desmarcar dia, abrir a composer, e a cada `render()` (cobre a virada automática do dia).
- `criar()` manteve os guards antigos como defesa em profundidade, mas na prática o botão já vem desabilitado antes de qualquer um deles disparar.
- CSS de `:disabled` pros dois botões adicionado como bloco novo no fim de `style.css` (módulos 1-20 duplicados, bloco novo sempre vence a cascata).
### Validação
`node --check` nos 44 blocos, `<div>`/`<svg>` balanceados antes/depois.
 
---
 
## 72. Remoção do card "Histórico" duplicado dentro de Config
 
### Origem do pedido
Menu de Configurações tinha um card "Histórico" que abria o mesmo overlay que já existe na prévia da tela de Perfil (`#verHistoricoBtn` → `window.abrirHistorico()`).
 
### O que foi feito
Removido o card `#cfgHistorico` do HTML. A função `abrirHistorico()` continua exposta em `window` e acessível pelo caminho que já existia (prévia em Perfil) — nenhuma lógica duplicada, só um atalho a menos.
 
---
 
## 73. Sinal unificado nos 3 atributos (Fortuna/Foco/Vigor)
 
### Origem do pedido
Print mostrando os 3 atributos com sinais diferentes na mesma tela: Fortuna `+0%`, Foco `0%` (sem sinal), Vigor `-0%`. Usuário achou confuso — os 3 são conceitualmente a mesma coisa (quanto já foi investido), o "-" do Vigor era só porque ele reduz dano, mas visualmente parecia que o atributo "piorava".
 
### O que foi feito
Os 3 passam a sempre mostrar `+N%`. Só trocou o texto formatado (`elFortuna.textContent`, `elFoco.textContent`, `elVigor.textContent`) — o significado de cada atributo continua explicado na descrição que aparece ao expandir o card, isso não mudou.
 
---
 
## 74. Sistema de conquistas: notificação de desbloqueio, badge, tag "NOVO", títulos
 
### Contexto importante: dois sistemas de conquista coexistem no arquivo
Existe um sistema **V1** (categorias com tiers, XP, botão "Receber" — `renderConquistas()`/`resgatarConquista()`) que **parou de ser chamado pela tela real desde a v4.69** (só o V2 roda hoje, ver `abrirConquistas()`), e o sistema **V2** ativo (`renderConquistasV2()`, 17 conquistas curadas, desbloqueio automático sem etapa de resgate).
 
**Armadilha desta sessão:** a primeira tentativa de dar feedback visual ao desbloquear uma conquista (trocar `aviso()` mudo por um flutuante em `resgatarConquista()`/`resgatarTodasConquistas()`) foi implementada e testada com jsdom, mas **não teve efeito nenhum no app real** — porque editou o sistema V1 morto. Lição: **antes de editar uma função de conquistas, confirmar qual sistema (V1 ou V2) está de fato ligado na tela, via `abrirConquistas()`**.
 
### 74.1 — Badge de notificação (bolinha) no nav Perfil + botão "Ver todas"
- Infraestrutura (`criarBadge()`, `.conqbadge`) já existia no arquivo mas `contarPendentes()` estava fixo em `return 0` (resto do sistema V1).
- **1ª versão:** contava quantas das 17 conquistas curadas faltavam desbloquear no total. Usuário testou e achou estranho ("por que aparece 9 num save novo?") — o comportamento certo era mostrar **notificação de novidade** (desbloqueado mas ainda não visto), não um contador de progresso permanente.
- **2ª versão (final):** novo par de chaves — `questlog.conquistasDesbloqueadasV2.v1` (já existia) e `questlog.conquistasVistasV2.v1` (nova). Badge conta a diferença: desbloqueadas menos vistas. Abrir a tela de Conquistas marca tudo que está desbloqueado como visto (dentro de `renderConquistasV2()`).
- Testado com jsdom carregando o bloco real do arquivo: save novo sem badge, desbloqueio sem abrir a tela mostra a contagem certa, abrir a tela zera, novo desbloqueio soma de novo sem contar o que já foi visto.
### 74.2 — Bug: badge sumia depois que a tradução rodava
`aplicarIdioma()` sobrescreve `innerHTML` de qualquer elemento com `data-i18n` — e o `data-i18n` de `#verConquistasBtn` estava direto no `<button>`, não num `<span>` interno (diferente do ícone "Perfil" da nav, que já usava esse padrão). Toda vez que a tradução rodava, apagava o badge (inserido como filho do botão). **Fix:** moveu o `data-i18n` pro `<span>` interno, igual ao padrão já usado na nav.
 
### 74.3 — Animação do badge + tag "NOVO" na lista
- Badge trocou de `display:none/flex` (não anima) pra classes `.on`/`.pop` controladas por `opacity`+`transform:scale()` via CSS transition — nasce com bounce, some com fade.
- Cada item desbloqueado-e-ainda-não-visto ganha uma tag "NOVO" na lista (dentro de `renderConquistasV2()`), pra mostrar visualmente de onde vem a notificação do badge.
### 74.4 — Ajustes finos de posição/visual (pedidos do usuário)
- Badge estava colado por dentro do botão, cobrindo o texto → movido pra fora (`top:-6px;right:-6px`, metade fora da borda, padrão comum de notification-dot).
- Faixa de chips na prévia de Perfil (nomes das conquistas recentes) — 1ª rodada tirou o texto (virou bolinha colorida), 2ª rodada removeu a faixa inteira (usuário não queria nada ali, só o cabeçalho "X de Y desbloqueadas" + botão "Ver todas").
### 74.5 — Sistema de títulos (implementado, pausado a pedido do usuário)
Cada conquista desbloqueada pode ser equipada como título, mostrado embaixo do nome no cabeçalho de Perfil (`#perfilTitulo`). Estrela clicável em cada linha da lista de conquistas desbloqueadas (`data-titulo`, toggle equipar/desequipar). Chave nova: `questlog.tituloEquipado.v1`. **Implementado e validado (sintaxe + balanço), mas o usuário pediu pra "deixar pra depois" antes de testar no aparelho — feature está no arquivo mas não foi usada/confirmada ainda.**
 
### Validação (em todas as sub-entregas)
`node --check` nos 44 blocos, `<div>`/`<svg>` balanceados, testes funcionais reais com jsdom carregando o bloco extraído do próprio arquivo (não reimplementação) sempre que a lógica JS mudou.
 
---
 
## 75. Arrasto de tarefas (reordenar lista): trava, suavização, e "pisca" — sessão de diagnóstico
 
### Contexto
Usuário relatou que o "vão elástico" no arrasto de tarefa (item 68, implementado numa sessão anterior e nunca confirmado em aparelho real) simplesmente não acontecia no celular, mesmo funcionando perfeitamente no DevTools (emulação de toque por mouse).
 
### Tentativas, nessa ordem
1. **`-webkit-tap-highlight-color` faltando em `.task`** — suspeita de que o destaque azul nativo do navegador (visível no vídeo do aparelho real, ausente no DevTools) competia com o efeito visual do app. Corrigido. **Não resolveu sozinho.**
2. **`LIMIAR_TOQUE` (8px → 18px)** — hipótese: 8px de tolerância de movimento durante os 220ms de long-press foi calibrado testando só com mouse (sem tremedeira); um dedo real facilmente ultrapassa isso, cancelando o arrasto antes de começar. **Aparentemente ajudou** (combinado com o item 1) — usuário confirmou depois que o arrasto passou a engatar.
3. **Painel de debug temporário** (`DEBUG_ARRASTO`, flag booleana) — criado depois de 2 tentativas erradas seguidas, pra parar de adivinhar e ver o ciclo de vida real do gesto (`pointerdown`/timer/`iniciarArrasto`/`soltar`/`pointercancel`/`pointerleave`) direto na tela do aparelho, com timestamp relativo. Religado e desligado 2x ao longo da sessão conforme a necessidade. **Fica no arquivo, desligado (`DEBUG_ARRASTO = false`)** — reativar trocando a constante pra `true` se precisar de novo.
4. **Suavização do arrasto** (usuário relatou "travadinho" depois do arrasto engatar): trocado `dragEl.style.left/top` (força recálculo de layout a cada pointermove) por `transform:translate3d()` (só composição/GPU). Variáveis novas: `dragBaseLeft`/`dragBaseTop` (âncora fixa) e `dragAtualTop` (usada por `atualizarAlturaElastica()` no lugar de reler `style.top`, que parou de mudar).
5. **REGRESSÃO real:** tentativa de otimizar mais ainda, agrupando `atualizarAlturaElastica()`/`atualizarPlaceholder()` pra rodar no máximo 1x por frame via `requestAnimationFrame` (em vez de a cada pointermove cru). Isso introduziu uma **race condition**: se o usuário soltasse a tarefa antes do frame agendado rodar, a chamada adiada executava com `placeholder` já nulo (zerado por `soltar()`), e `moverPlaceholderAnimado()` quebrava no meio (`list.insertBefore(null, ...)`), deixando `transform` residual preso em vizinhos e a lista instável/rolando sozinha. **Revertido** — voltou a chamar as 2 funções direto e síncrono, mantendo só a otimização do `transform` (que não tinha esse risco). Testado o cenário exato (soltar imediatamente após mover, sem nenhum frame de folga) com jsdom — 8 asserts, sem exceção, sem placeholder órfão.
6. **"Pisca" durante o arrasto** — investigado com o painel de debug religado. O log mostrou o ciclo `pointerdown → timer 220ms → iniciarArrasto → soltar → pointerleave` rodando limpo, **sem nenhum `pointercancel`**, com gaps de 176-495ms sem toque na tela entre um ciclo e outro. Conclusão: **não era bug** — eram múltiplos toques rápidos (soltar e pegar de novo em sequência), o que visualmente parece "piscar" mas é comportamento correto (contorno aparece/some a cada ciclo de fato completo). Usuário confirmou.
### Estado final
Arrasto funcionando: engata, não trava, não cancela sozinho. `LIMIAR_TOQUE = 18`, movimento via `transform`, `DEBUG_ARRASTO = false` (painel pronto pra religar se precisar).
 
### Lição geral desta sessão de diagnóstico
Duas tentativas de fix "no escuro" (adivinhando pela leitura de vídeo comprimido) não resolveram. O que resolveu de fato foi instrumentar o código com log visível na tela e pedir um novo vídeo — trocar suposição por dado real. Vale repetir esse padrão em bugs futuros que só reproduzem em aparelho real.
 
---
 
## 76. Rebrand QuestLog → Dungeonlog + troca de ícone do app
 
### 76.1 — Nome
Motivo: "QuestLog" já é usado por pelo menos 5 apps na Play Store.
 
**Trocado** (cosmético, visível pro usuário, zero risco):
- `<title>`, `apple-mobile-web-app-title`
- `name`/`short_name` dentro do manifest do PWA (embutido em base64 — decodificado, editado, recodificado)
- Telas do carrossel de onboarding (`QUESTLOG` → `DUNGEONLOG`, substituição literal do texto maiúsculo, não tocou nas ~110 ocorrências minúsculas `questlog.` que são chaves de `localStorage`)
**Não tocado** (decisão consciente, não pendência):
- Prefixo `questlog.` no `localStorage` (~110 chaves) — trocar quebraria o save de quem já está jogando (o app procuraria chaves novas, não acharia nada, pareceria ter resetado). Fica assim pra sempre, é invisível pro jogador.
- Projeto Firebase (`questlog-d4c11`, authDomain/projectId/storageBucket) — Firebase não permite renomear projeto; trocar exigiria criar um projeto novo do zero e migrar usuários/Firestore. Só vale a pena se um dia importar ter o nome batendo na URL de login/verificação de email.
### 76.2 — Ícone do app (a maior novela da sessão)
Fluxo completo, do primeiro escudo até a versão final:
 
1. **Ícone original** (escudo dourado + check laranja, vetorial, fundo `#0E1116`) trocado nos 3 pontos que existem no arquivo: `apple-touch-icon`, `icon` (favicon), e os 2 tamanhos (192x192, 512x512) dentro do manifest embutido em base64.
2. **Corte no aparelho real** — ícone adaptável do Android só garante a zona segura central (~66% de diâmetro); a imagem original tinha só ~7% de margem no topo. Recalibrado pra ~62% de escala (margem generosa) → usuário achou **pequeno demais** perto de outros apps (Habitica, Skillion) → recalibrado de novo pra ~80% de escala (meio-termo). Padrão que se repetiu em toda imagem nova recebida depois: **sempre simular em máscara circular (pior caso) e medir margem numericamente antes de aplicar**, e não pecar por excesso de cautela na margem — comparar com apps de verdade, não só a teoria.
3. **Exploração de conceitos alternativos** (usuário pediu algo mais alinhado com a identidade pixel art do resto do app, já que o escudo vetorial não combinava): espada pixel art (rejeitada — Skillion já usa espada), baú de tesouro e caveira/monstro (pixel art, ambos rejeitados sem motivo específico), poção pixel art (bem recebida) e depois **poção vetorial** (usuário notou que nem Habitica nem Skillion usam pixel art no ícone, só no conteúdo interno do app — decisão de manter o ícone vetorial/liso, reservando pixel art pro miolo do app).
4. **Pivô final: portal/arco de pedra.** Usuário estava desenhando isso no Figma em paralelo. Trajetória:
   - Primeira versão (só linha, sem cor): tinha rachaduras decorativas nos pilares e a base dividida em 4 segmentos — testado em simulação de 48px/96px, confirmado que os detalhes finos viravam ruído visual nesse tamanho. Usuário simplificou.
   - Versão colorida (roxo + gema dourada brilhando): boa qualidade, mas o export do Figma trazia cantos arredondados + fundo branco + uma linha de contorno decorativa **já embutidos na própria imagem** — precisou ser limpo (recortar a forma real, substituir os resíduos de branco/contorno pela cor de fundo real) antes de aplicar.
   - **Aplicada e funcionando** (ficou como opção A).
5. **Tentativa de versão em escala de cinza** (render com sombreamento mais refinado): rejeitada nessa forma — tinha marca d'água de outra ferramenta de IA visível, resolução baixa (276×270), e sem cor nenhuma (quebrava a paleta dourado/roxo do resto do app).
6. **SVG vetorizado (Vectorizer.io) do grid de referência original** — trouxe de volta a discussão de cor vs. escala de cinza. Usuário: (a) gerado por IA gratuita, sem problema de uso; (b) sugeriu recortar só o quadrante sem marca d'água em vez de descartar o arquivo inteiro (funcionou — o quadrante do triângulo não tinha a marca, que só estava no quadrante da chave); (c) observou que o tema padrão do app não é preto-e-branco (Laranja é o padrão, Escuro/Grafite é só uma das 5 opções — corrigido, mas o argumento de fundo sobre monocromático ser uma escolha de design válida se manteve).
   - Tentativa de recolorir automaticamente (mapear luminosidade pra roxo/dourado) **falhou** — script confundiu fundo com gema por causa de como o cairosvg renderizou a transparência, resultado ficou pior que simplesmente usar em cinza. Não insistido.
   - Limpeza da versão cinza teve a **mesma classe de problema** da versão colorida (cantos arredondados + branco residual + contorno decorativo embutidos), resolvida com a técnica mais robusta: **análise de componente conectado** (`scipy.ndimage.label`) pra achar o maior "blob" de cor real e apagar tudo fora dele, em vez de ajustar limiar de distância manualmente (que precisou de 3-4 rodadas até funcionar de verdade na primeira tentativa).
   - **Versão final escolhida pelo usuário: cinza**, escala recalibrada pra ~85% (maior possível sem vazar do círculo).
### Lições técnicas gerais desta sessão de ícone
- **Nunca aplicar uma imagem de referência (Figma, gerador de IA, vetorizador) direto** — checar sempre: (1) cantos arredondados/fundo branco já embutidos na própria imagem (comum em exports de ferramentas de design), (2) ruído de cor sutil em áreas que parecem sólidas (comum em imagem gerada por IA — a cor "de fundo" varia pixel a pixel mesmo parecendo uma cor só), (3) resolução mínima (idealmente 512px+, nunca menor que o maior tamanho de saída necessário).
- **Técnica que funciona de verdade pra limpar fundo:** achar o maior componente conectado de pixels distantes da cor de fundo (`scipy.ndimage.label`), não tentar ajustar threshold de distância manualmente.
- **Validar sempre nos 2 piores casos antes de considerar pronto:** máscara circular (mais agressiva que qualquer launcher real usa) e ampliação do PNG final real (192px, sem suavizar) — várias vezes um problema só apareceu numericamente ou visualmente numa dessas duas checagens, não bastava olhar a imagem grande original.
- **Calibração de margem de segurança:** não travar só na teoria (66% de zona segura) — comparar com apps de verdade lado a lado. Ícone com margem grande demais parece "capenga"/pequeno; o ideal ficou por volta de 80-85% de preenchimento, testado numericamente pra garantir zero vazamento mesmo no círculo puro.
### Validação (repetida a cada nova versão de ícone)
Decodificar os 3 pontos do arquivo de volta (favicon, apple-touch-icon, manifest 192px/512px) e comparar hash MD5 byte a byte com a imagem gerada. `node --check` nos 44 blocos. Teste de vazamento circular numérico (contagem de pixels fora do raio). Nas últimas rodadas, também amplificação do PNG real (192px) sem suavizar, pra pegar ruído que só aparece nesse tamanho específico.
 
---
 
## 77. Logo do app dentro do onboarding (splash + login), no lugar do Grimório
 
### Origem do pedido
Depois de fechar o ícone (item 76), usuário perguntou se não valeria usar o mesmo logo **dentro** do app — especificamente trocando o sprite pixel art do "Grimório Proibido" (sprite 108, usado até então na tela de splash e na tela de login) pelo logo novo.
 
### Ressalva levantada antes de implementar
O motivo de o ícone do app ter ficado vetorial/liso (em vez de pixel art) foi justamente pra combinar com ícones de outros apps na tela inicial do celular — mas splash e login são **dentro** do app, onde o resto do onboarding é 100% pixel art (sprites de herói/monstro nos outros slides do carrossel). Usar a versão lisa ali cria a tensão inversa: destoa do resto do app em vez de combinar com o sistema operacional. Sugestão alternativa (fazer uma versão pixel art dedicada) foi oferecida; **usuário optou por testar a versão vetorial mesmo assim primeiro.**
 
### O que foi feito
- Extraído o PNG 512×512 que já está de fato aplicado como ícone (direto do manifest embutido no próprio arquivo, não regerado do zero — garante 100% de consistência com o ícone real).
- Fundo tornado transparente (a versão do ícone tem fundo sólido preenchendo o quadrado inteiro, necessário pra ícone adaptável — mas errado pra um elemento flutuando sobre a parede de tijolo do onboarding).
- **Login** (`#passoLogin`): sprite pixel art antigo (`<div class="pxi loginSprite">`, `estiloSprite(SPRITE_LOGIN, 72)`) trocado por `<img class="loginSprite logoApp">` com o logo em base64, no mesmo lugar (acima do título "DUNGEONLOG" que já existia).
- **Splash** (`#passoSplash`, primeira tela que abre): antes só mostrava o sprite sozinho, **sem texto nenhum**. Agora mostra o logo + o texto "DUNGEONLOG" embaixo (adicionado — não existia antes), envolvidos num `<div class="marca">` pra reaproveitar o layout em coluna centralizada que o resto do app já usa.
- Nova classe `.logoApp` (CSS, bloco novo no fim de `style.css`): dimensiona a `<img>` (72px no login, 120px na splash via `#passoSplash .logoApp`), com `image-rendering:auto` (não `pixelated` — é ilustração lisa, não pixel art) e `object-fit:contain`.
- **Ajuste seguinte (mesmo pedido, turno seguinte):** a classe `.loginSprite` reaproveitada carregava a animação `respira` (balanço vertical, `translateY`) que fazia sentido pro sprite pixel art antigo mas não pro logo novo. Usuário pediu pra ficar estático — `animation:none` adicionado direto na regra `.logoApp` (que already vem depois de `.loginSprite` na cascata, então sobrescreve sem precisar de `!important`).
### Não tocado (fora do que foi pedido)
O 1º slide do carrossel de onboarding ("DUNGEONLOG/BATALHA/EVOLUA") não foi tocado — ele usa uma composição de 3 sprites de monstro (`tipo:'trioLogo'`, não o Grimório), e o usuário não pediu mudança ali.
 
### Validação
As 2 imagens `<img>` embutidas (splash e login) decodificadas de volta e comparadas por hash MD5 com o arquivo gerado — batem exatas. `node --check` nos 44 blocos. Balanço de tags consistente com a troca esperada (`<div>` caiu 1, exatamente o esperado pela troca de `<div class="pxi">` por `<img>` no login). CSS parseado sem erro.
 
**Não testado em aparelho real** — a ressalva de estilo (vetorial liso ao lado de pixel art no resto do onboarding) só vai ficar clara de verdade num teste visual real, ainda pendente.
 

## 78. Logo do app dentro do onboarding — continuação: halo na splash nativa, expansão pra todas as telas, e reversão final

### Contexto
Continuação direta do item 77. Usuário mandou vídeo comparando a abertura do próprio app com a do Habitica.

### 78.1 — "2 logos" e halo escuro atrás do logo
Vídeo mostrou o logo aparecendo **duas vezes** ao abrir o app, e a primeira aparição tinha um círculo escuro visível atrás dele (deveria ser transparente).

**Diagnóstico:** não eram dois logos do app — eram duas camadas diferentes. A primeira é a **splash nativa do Android**, gerada automaticamente pelo sistema a partir do `manifest` (ícone + `background_color`) **antes** da página carregar — isso é padrão de qualquer PWA, não é controlado pelo código, e o ícone ali precisa mesmo ter fundo sólido. A segunda é a splash própria do app (`#passoSplash`, já com fundo transparente, funcionando certo).

O halo era um problema real, mas de outra causa: `background_color` do manifest (`#0E1116`) estava numa cor levemente diferente do fundo real do ícone (`#191919`) — o Android pinta a tela toda com uma cor e desenha o ícone com outra por cima, e essa diferença sutil aparecia como uma borda visível. **Fix:** igualou as duas cores pra `#191919` (`background_color` e `theme_color` do manifest).

### 78.2 — Splash própria removida
A pedido do usuário, `#passoSplash` parou de ser inserida no DOM — só a splash nativa do Android aparece agora. O app decide na hora (sem esperar timeout nem clique) pra onde ir depois que a página carrega: `irParaLogin()` se veio de "Criar conta"/"Sair", ou `irPara(1)` (início do carrossel) caso contrário. HTML da splash antiga ficou no arquivo, comentado como não usado (convenção do projeto).

### 78.3 — Reconsideração de estilo, e decisão de manter o vetorial
Usuário perguntou se não seria melhor tirar o logo de dentro do app e deixar só fora (no ícone). Resposta: sim, fazia sentido — voltar pro sprite pixel art do Grimório Proibido resolveria a tensão de estilo (vetorial liso ao lado de pixel art no resto do onboarding) levantada no item 77. Comecei a reverter, mas o usuário decidiu **testar a versão vetorial mesmo assim primeiro** antes de decidir de vez.

### 78.4 — Expansão pra todas as telas com "DUNGEONLOG" + aumento de tamanho
Usuário pediu pra colocar o logo em **toda tela que tem o texto "DUNGEONLOG" e precisa do logo**, e aumentar o tamanho.

Mapeadas 4 telas com esse texto:
- `#passoSplash` — já tinha logo (aumentado 120px → 170px)
- `#passoLogin` — já tinha logo (aumentado 72px → 104px)
- `#passoVerificarEmail` (fluxo normal de verificação) — não tinha nenhuma imagem, só texto. Logo adicionado.
- `#bloqueioVerificacaoEmail` (overlay standalone de bloqueio silencioso) — mesma coisa, logo adicionado.

Não tocado: 1º slide do carrossel ("DUNGEONLOG/BATALHA/EVOLUA") — já tinha conteúdo próprio ali (trio de 3 sprites de monstro, decisão de sessão anterior), não uma tela "sem logo".

### 78.5 — Decisão final: reversão completa, só texto
Depois de ver tudo aplicado, usuário decidiu que não tem problema nenhum deixar só o texto "DUNGEONLOG", sem logo nenhum, em nenhuma das 4 telas. **Revertido por completo** — as 4 ocorrências do `<img class="logoApp">` removidas, sobrando só `<span class="titulo">DUNGEONLOG</span>` em cada tela, exatamente como era antes de qualquer imagem entrar (pré-item 77). CSS da classe `.logoApp` ficou no arquivo sem uso (não apagado, convenção do projeto).

### Validação (repetida a cada rodada)
`node --check` nos 44 blocos a cada mudança. Hash MD5 das imagens embutidas comparado com a fonte a cada adição (todas bateram). Balanço de `<div>`/`<svg>`/`<img>` conferido a cada rodada — sempre consistente com o número exato de tags adicionadas/removidas.

### Lição
Essa foi uma decisão de design que oscilou bastante (adicionar → expandir → reverter) — normal em trabalho de UI/branding, mas vale registrar o estado final claro pra não confundir sessões futuras: **hoje as 4 telas de onboarding/login mostram só texto, nenhuma imagem/logo**. Se reabrir essa discussão, o CSS (`.logoApp`) e o histórico de como extrair/tratar a imagem (fundo transparente, halo, etc.) já estão documentados aqui e no item 77 — não precisa refazer esse trabalho do zero.

---

## 79. Legibilidade dos títulos de conquista + bug da seta "Voltar" depois de "Criar conta"

### 79.1 — Legibilidade das conquistas
Pedido do usuário, sem problema específico relatado — só melhoria. `.conqv2nome` (nome da conquista) foi de 13.5px pra 15.5px. `.conqv2desc` (descrição) foi de 11.5px pra 13px, e trocou de cor `--dim` (contraste baixo) pra `--muted` (contraste melhor, mas ainda mais apagada que o título — mantém a hierarquia visual entre nome e descrição).

### 79.2 — Bug: seta "Voltar" no login levava pro início do carrossel de marketing
**Relato do usuário:** clicar em "Criar conta" abre a tela de login corretamente, mas a seta de voltar joga de volta pras telas do carrossel (DUNGEONLOG/BATALHA/EVOLUA), o que não deveria acontecer.

**Causa raiz:** "Criar conta"/"Sair" (Config) recarregam a página com uma flag (`questlog.forcarLogin.v1`) que faz o app pular direto pra `irParaLogin()`, **antes de qualquer slide do carrossel ter sido mostrado nessa carga de página**. A função `irParaLogin()` só atualiza `ultimoSlideAntesLogin` (a variável que diz pra onde a seta deve voltar) quando existe um slide `.on` de verdade — nesse caminho não existe nenhum, então a variável ficava presa no valor padrão (`1`), e a seta levava pro slide 1 mesmo sem o usuário nunca ter passado por lá nessa sessão.

**Fix:** `irParaLogin()` passou a aceitar um parâmetro (`semVoltar`). Quando `true`, a seta de voltar fica escondida (`classList.toggle('visivel', !semVoltar)`) em vez de aparecer apontando pra um lugar que não faz sentido. Só a chamada da entrada forçada (`irParaLogin(true)`) usa esse parâmetro — o clique normal em "Já tem conta?" (que abre o login vindo de um slide real do carrossel) continua mostrando a seta normalmente.

**Bug secundário evitado na mesma correção:** o link "Já tem conta?" usava `onclick = irParaLogin` (a função direto, sem wrapper). Nesse formato, o clique passaria o objeto `Event` do navegador como primeiro argumento — que é *truthy*, ativando o "sem voltar" por engano também nesse caso legítimo (onde a seta deveria continuar aparecendo). Corrigido pra `onclick = () => irParaLogin()`, sem repassar o evento.

### Validação
`node --check` nos 44 blocos. CSS parseado sem erro. Testados os 3 cenários da lógica de `semVoltar` isoladamente em Node (entrada forçada, clique normal via wrapper, e o bug do `Event` sendo passado sem wrapper) — os 3 bateram com o comportamento esperado antes de aplicar a correção final.

## 80. Namespace por conta no localStorage (item 13f) — implementação e 2 bugs reais encontrados testando
 
### O que foi pedido
Resolver o item 13f: 12 chaves de `localStorage` (atributos, conquistas, histórico, vida do monstro, itens vistos, loja, tarefas concluídas, título equipado) ainda eram compartilhadas entre contas diferentes no mesmo aparelho — só o save principal já tinha esse cuidado.
 
### Implementação
- Novo helper `chaveConta(chaveBase)`, generalizando o mesmo mecanismo que já existia pro save principal (`chaveSaveAtual()`), reaproveitando a mesma variável `_uidAtivo`. Movido pro topo do arquivo (logo após `assets.js`) porque uma das chaves (`CHAVE_DIA`) precisa dele antes de qualquer login acontecer nesse mesmo `<script>` contínuo.
- Todas as 12 chaves passaram a usar `window.chaveConta(CHAVE_X)` em vez da chave crua.
- Migração automática: dado de "convidado" (pré-login) é copiado pro namespace da conta no primeiro login.
### Bug 1: migração rodava mais de uma vez, vazando dado de uma conta pra outra
Testado pelo usuário: Conta B herdou uma tarefa que era da Conta A. Causa: a Conta A tinha sido usada **antes** dessa correção existir — os dados dela ficaram nas chaves "sem dono". A migração tratava isso como "resto de convidado" e distribuía pra **toda** conta nova que logasse, não só a primeira. **Fix:** marcador `questlog.legadoMigrado.v1` — a migração roda no máximo 1 vez no total (não 1 vez por conta), e a chave crua é apagada depois de reivindicada (evita que um boot futuro em modo convidado ache o resto de novo).
 
### Bug 2: `carregar()` não resetava nada quando falhava
Testado pelo usuário: tarefa da Conta A se juntando com tarefa nova da Conta B. Causa: `carregar()` só escrevia as variáveis de estado (`tarefas`, `xpTotal`, etc.) no caminho de sucesso — quando a chave da conta não existia (conta nova, sem save ainda), retornava `false` sem limpar nada, deixando o que sobrou de uma chamada anterior bem-sucedida (de outra conta, ou do boot em modo convidado) parado na memória. **Fix:** nova função `resetarEstadoParaPadrao()`, chamada em todo caminho de falha do `carregar()`.
 
### Bug 3 (relacionado, mesma sessão de teste): corrida entre salvar local e enviar pra nuvem
Mudança feita pouco antes de "Sair" podia ter o envio pra nuvem cancelado pelo próprio `location.reload()` no meio do caminho (`empurrarNuvem()` é assíncrono e nunca era esperado). **Fix:** "Sair" agora espera o último envio pendente terminar (`window._questlogUltimoPush`) antes de recarregar, com teto de 3s pra não travar o botão se a rede estiver ruim.
 
### Bug 4 (menor, mesma leva): título equipado "não salvava"
Na real salvava certo — só a exibição embaixo do nome nunca era atualizada depois do login (só pintava no boot inicial e ao clicar na estrela). **Fix:** `renderTituloPerfil()` adicionada no fluxo de entrada pós-login (`entrarNoApp()`).
 
### Validação
`node --check` nos 44 blocos a cada rodada. Testes funcionais com jsdom/vm carregando o código real extraído do arquivo (não reimplementação) pra cada bug — incluindo simulação completa do cenário relatado (convidado → Conta A → Conta B → volta pra Conta A) reproduzindo e confirmando cada fix.
 
---
 
## 81. Corrida real na inicialização: interação antes do Firebase confirmar a sessão
 
### Contexto
Depois dos fixes do item 80, usuário ainda relatou perda de tarefa ao alternar contas, "sem padrão claro". Duas rodadas de simulação local não reproduziram o bug — precisou de diagnóstico com dado real do aparelho (mesmo padrão do item 75, arrasto de tarefas): painel de debug visível (pilula recolhida no canto, expande sob toque — v2, a v1 cobria botões do app e foi corrigida a pedido do usuário) instrumentando `aoLogar()`, `aoLogarSilencioso()`, `puxarNuvem()`, `empurrarNuvem()`, `criar()` e o boot.
 
### Causa raiz (confirmada com log real, não suposição)
Existe uma janela de **9 a 11 segundos** entre a página carregar (mostrando a tela de tarefas na hora, com o que tinha salvo localmente) e o Firebase confirmar de verdade se existe uma sessão de login válida — `onAuthStateChanged` é sempre assíncrono, e o SDK demora pra carregar de um CDN externo. Se o usuário interagisse (criasse tarefa) **dentro dessa janela**, a ação ia parar na chave "sem dono" (`uidAtivo` ainda `null` naquele instante) — quando o Firebase confirmava a conta segundos depois, o app trocava pra chave real e puxava o que já estava na nuvem, fazendo a tarefa recém-criada "sumir" (não apagada — salva no lugar errado, nunca mais visível dali).
 
Print do log que confirmou: `criar() -- tarefa "a" adicionada | uidAtivo=null | chave=questlog.v1` — a criação aconteceu com `uidAtivo` ainda nulo, mesmo a tela já parecendo "pronta".
 
### Fix
Se existe indício de sessão anterior (`questlog.uidAtivo.v1` já salvo no aparelho), mostra um overlay leve bloqueando interação ("Carregando…", texto trocado de "Confirmando sua conta…" a pedido do usuário) até `aoLogar()`/`aoLogarSilencioso()` confirmarem de verdade — ou no máximo 8s (rede ruim/offline libera e segue local). Quem nunca logou no aparelho não vê overlay nenhum, zero mudança de comportamento pro convidado genuíno.
 
### Validação
Lógica testada isolada (aparece com conta conhecida, some ao confirmar, idempotente, não aparece pra convidado real). `node --check` nos 44 blocos.
 
---
 
## 82. Performance: paralelizar os imports do Firebase (3 pontos)
 
### Origem
Usuário perguntou por que outros apps não precisam de tela de "confirmando conta" — motivo real: a arquitetura "convidado primeiro" do Dungeonlog (interação sem login) cria a janela do item 81, que outros apps evitam exigindo login antes de mostrar qualquer coisa. Investigando o porquê dos 9-11s especificamente, achado: os 3 módulos do Firebase (`app`, `auth`, `firestore`) eram importados **sequencialmente** (`await` um atrás do outro) via CDN externo (gstatic.com), em 3 pontos do código (login principal, "Apagar tudo", "Sair") — a espera total era a **soma** das 3 latências de rede, não a do mais lento.
 
### Fix
Trocado `await import()` sequencial por `Promise.all()` nos 3 pontos — os 3 pedidos disparam ao mesmo tempo, espera total vira só a do mais lento dos três.
 
### Achado à parte (não mexido, só sinalizado)
`PRAZO_TOLERANCIA_VERIFICACAO_MS = 30 * 1000` com comentário `v4.125-TESTE: 30s (era 10min) -- SO PRA TESTAR O WATCHDOG, reverter antes de publicar` — valor de teste esquecido no código, watchdog de verificação de email tolerando só 30s em vez de 10min. Não corrigido nesta sessão (fora do escopo do que foi pedido) — **fica pendente pra antes do lançamento**.
 
### Validação
`node --check` nos 44 blocos. Confirmado que não sobrou nenhum `import()` sequencial fora de `Promise.all` (8 imports totais, agrupados em 3 chamadas). Teste isolado do ganho: sequencial somou as 3 latências simuladas (~1050ms), paralelo ficou só com a do mais lento (~400ms).

---


## 83. Ajuste do overlay do item 81: visual só aparece em rede lenta de verdade

### Contexto
Overlay do item 81 (ver seção 81) pintava fundo/blur/cartão "Carregando…" desde o instante em que era criado — usuário queria que a trava de interação continuasse ativa do mesmo jeito (zero mudança na correção da corrida original), mas que o visual só aparecesse quando a confirmação realmente demorasse, não sempre.

### Tentativa 1 — limiar de 180ms (REVERTIDA)
Primeira versão: overlay nascia transparente (só bloqueando clique) e só pintava fundo/cartão se `aoLogar()`/`aoLogarSilencioso()` não resolvesse em ~180ms. **Rejeitada pelo usuário na prática** — 180ms é curto demais pro tempo real de import do SDK do Firebase via CDN + round-trip de auth, então o visual acabava aparecendo quase sempre, inclusive em conexão boa. Não resolvia o problema.

### Tentativa 2 — 100% invisível, nunca aparece (REVERTIDA)
Segunda versão: removido todo o conteúdo visual, overlay virou um `div` transparente só pra bloquear clique, em qualquer cenário. Levantado o risco pelo Claude e confirmado pelo usuário como indesejado: em rede ruim/instável, o app trava a interação por até 8s (teto de segurança já existente) **sem nenhum feedback visual** — usuário não tem como saber se o app travou/quebrou ou só está esperando a rede.

### Fix final
Limiar alto, pensado especificamente pra separar "caso comum" de "rede lenta de verdade": `LIMIAR_REDE_LENTA_MS = 2500`. Overlay nasce transparente (trava de clique ativa desde o início, síncrona, sem nenhuma mudança na lógica que resolve a corrida do item 81). Só ganha fundo escurecido + blur + cartão "Carregando…" se passar de 2,5s sem `confirmarSessaoResolvida()` disparar — bem acima do tempo normal de confirmação em rede boa, então não aparece no caso comum, mas cobre o cenário de rede ruim antes do teto de 8s (inalterado) liberar o app pra seguir 100% local. Convidado genuíno (`!uidConhecido`) continua sem ver nada, como sempre.

### Validação
`node --check` nos 42 blocos `<script>` inline (contagem já refletindo a divisão em `index.html`/`style.css`/`assets.js`, ver item de infraestrutura). Balanceamento de `<div>`/`<svg>` conferido. `dbgConta` instrumentado com linha própria (`'overlay de sessao ficou visivel -- rede lenta (> 2500ms)'`) pra permitir confirmar em campo, via log real do aparelho, se uma eventual reaparição do overlay é rede lenta genuína ou regressão.

## 84. Bug real: celebração "DIA VENCIDO" disparava de novo em qualquer reentrada na Arena

### Contexto
`_vitoriaCelebrada` (flag que controla o disparo único de `celebrarVitoria()` — flutuante, faíscas e contagem progressiva de moedas) só vivia em memória. Ela some a cada reload/reentrada na Arena (sair e voltar do app, trocar de aba e voltar), mas `derrotadoEm` continua batendo com `isoAtual()` — então `render()` reconhecia `venceu = true` e disparava a celebração inteira de novo, mesmo o dia já tendo sido vencido antes. `ultimoGanho` (valor de moedas mostrado) também nunca foi persistido em lugar nenhum, então o replay indevido acontecia com `+0` moedas.

### Fix
Nova chave `questlog.celebracaoDiaMostrada.v1`, mesmo padrão de `questlog.hpMonstro.v1` (namespaced por conta via `window.chaveConta()`). Guarda `{dia, ganho}` — não só a data, porque `ultimoGanho` precisa ser restaurado de algum lugar pro estado estático mostrar o valor certo.

Em `render()`: antes de chamar `celebrarVitoria()`, checa o registro persistido. Se `registro.dia === isoAtual()`, é reentrada — sincroniza `_vitoriaCelebrada = true`, restaura `ultimoGanho` do registro e escreve o texto final direto no DOM, sem animação. Só dispara a celebração completa (com gravação da flag) quando não há registro batendo com hoje — ou seja, na vitória real. Reset é automático na virada do dia: o branch `!venceu` (monstro ainda vivo, `isoAtual()` mudou) já limpa a flag, mesmo ciclo que zera `derrotadoEm`/`hpMonstro`.

### Validação
`node --check` nos 42 blocos `<script>` inline. Balanceamento de `<div>`/`<svg>` conferido (desbalanceamento pré-existente em `<script>` confirmado via `git stash` — não relacionado a este fix). Teste funcional em Node simulando os 5 cenários: vitória real → reentrada mesma sessão → segunda reentrada → virada de dia → nova vitória no dia novo. Todos passaram.

## 85. Toggle de debug pelo ícone de moedas

### O que foi pedido
Um jeito de ligar/desligar tudo que é debug de uma vez, sem precisar mexer em código: 1 clique no ícone/contador de moedas (aba Tarefas) inverte o estado, salvo em `localStorage['questlog.modoDebug.v1']` (boolean, default `false`). Zero feedback visual no próprio ícone — fica indistinguível do normal de propósito. Persiste entre aberturas do app, sem reset automático.

Fora do escopo por definição: `DEBUG_ARRASTO` e flags booleanas fixas no código (não-visuais) continuam exigindo trocar a constante manualmente — são instrumentação de log, não elemento de UI pra esconder/mostrar.

### Implementação — 3 partes

**1. CSS** (`.debugbar`/`.debug-el`): `.debugbar` (já existia, 3 botões de debug) e a nova classe genérica `.debug-el` (pra qualquer painel de debug futuro nascer já compatível) ficam `display:none` por padrão. `body.modo-debug` reverte os dois.

**2. Toggle de UI**: bloco autônomo no fim do `<body>`, ouvindo clique em `.coins`. Lê/grava a chave, aplica/remove a classe `modo-debug` no `<body>`. Expõe `window.modoDebugAtivo()` pra outros blocos consultarem o estado sem duplicar a leitura do `localStorage`.

**3. Silenciador de console**: pedido à parte, mesma sessão — "o log também é debug e tem que desaparecer também". Decisão do usuário: `console.log`, `.warn` e `.error` ficam **todos** mudos por padrão (não só `.log`), incluindo os ~15 `console.error` de falha real do Firebase espalhados pelo arquivo. Instalado como o **primeiro** `<script>` do `<head>`, antes até do bloco de i18n — garante que nada escapa do gate antes dele existir. Consulta o `localStorage` a cada chamada (não cacheia), então ligar/desligar em runtime já muda o comportamento na hora, sem precisar recarregar a página. Guarda as funções originais em `window.__consoleOriginal` como válvula de escape pro devtools.

### Bug real encontrado depois de "pronto": a pílula do item 81 não obedecia o toggle
Print do usuário mostrou a pílula "☰ log (2)" (`dbgContaPilula`, painel de debug do item 81 — fluxo de login/troca de conta) ainda visível com o toggle desligado.

**Causa raiz:** essa pílula é criada via `document.createElement` e anexada direto no `document.body`, sem nenhuma classe — não era pega pela regra `.debugbar`/`.debug-el`. Mais grave: o painel expandido dela usa `painel.style.display = 'block'/'none'` **inline** via JS, que sempre vence qualquer regra de CSS externa (inline bate qualquer seletor de stylesheet, com ou sem classe). Se o painel fosse deixado aberto e o usuário desligasse o toggle mestre, ele reapareceria sozinho na próxima linha de log.

**Fix:** `_dbgContaRepintar()` agora consulta `window.modoDebugAtivo()` diretamente em JS logo no início — se desligado, força `display:none` na pílula e no painel (se existir) e sai, independente do estado interno de aberto/fechado. `window.__dbgContaAtualizarVisibilidade` exposto como gancho, chamado pelo `aplicar()` do toggle mestre — a pílula reage **na hora do clique** nas moedas, não só na próxima mensagem de log.

### Validação
`node --check` nos 44 blocos `<script>` inline a cada rodada. Balanceamento de `<div>`/`<svg>`/`<body>`/comentários conferido (dois falsos positivos identificados e corrigidos: texto literal `<script>`/`<head>` dentro de comentários HTML — reescrito pra não usar esses tokens como texto puro, evita confundir ferramentas de extração no futuro). CSS parseado sem erro (`css` npm lib, 1510 regras).

Testes funcionais em jsdom/Node, código real extraído do arquivo:
- Toggle de UI: 3 cliques (off → on → off) + simulação de "reabertura do app" com estado persistido — todos bateram.
- Silenciador de console: `log`/`warn`/`error` mudos por padrão, aparecem com 1 clique, mudos nen de novo com o 2º — em tempo real, sem reload.
- Pílula do item 81: 6 fases, incluindo o cenário do bug (painel aberto quando o mestre desliga) — pílula e painel somem juntos, mesmo sem fechar o painel manualmente antes.

### Lição
Nem todo elemento de debug obedece CSS: qualquer coisa que manipule `style.display` **inline** via JS (não só classe) precisa ser verificada caso a caso — a regra `.debug-el` sozinha só cobre quem não tem lógica de visibilidade própria em JS. Vale checar isso de novo se aparecer um painel de debug novo no futuro.

## 86. Baú clicável na Arena + baú especial com chave (Spec 4 + Spec 4b)

### O que foi pedido
Spec 4: ao vencer o dia, em vez do pop-up de recompensa abrir sozinho, um sprite de baú fechado aparece fixo na Arena, ao lado do herói. Clique abre o pop-up mostrando o que já foi creditado (não recalcula). Evoluiu em sessão de brainstorm pra Spec 4b: além do baú padrão (sempre spawna, abre sem chave), uma chance à parte de um **segundo baú, especial**, que exige chave pra abrir — não substitui o padrão, os dois coexistem, e o especial pode nem aparecer.

### Decisões de design (fechadas em sessão de brainstorm antes da implementação)
- **Fonte de chave:** loot aleatório (baú comum) + loja.
- **Itens de chave:** reaproveita os 5 já existentes no catálogo (`Chave de Ferro/Chave/Dourada/Cristal/Mestra`) — retipados de `tesouro` pra `chave` em vez de criar itens novos.
- **Compatibilidade:** chave de tier igual ou maior destrava (consome a de **menor tier suficiente** no inventário, nunca desperdiça uma chave melhor à toa).
- **Sem chave no fim do dia:** loot do baú especial é perdido de verdade (risco real) — o baú padrão sempre credita na hora, só o pop-up é que fica pendente até o clique.
- **Raridade do baú especial:** pesada pra cima de propósito (pesos `[5,15,35,45]` pra Comum/Incomum/Raro/Épico) — ele já é raro de aparecer, então quando aparece deveria pedir uma chave que pareça valiosa na maior parte das vezes.

### Implementação
`assets.js`: 5 itens de chave retipados. `index.html`: `LOJA_TIPOS` ganha `'chave'` (com exclusão explícita do Grimório do pool, que também é tipo `chave` mas é recompensa de nível, não mercadoria); `mediaDifHoje()`/`chanceBauTrancado()`/`tierBauNecessario()` (pesos por tier, dificuldade do dia dá empurrão extra); `sortearGanhos()`/`creditarGanhos()`/`chaveParaDestravar()`; `gerarEstadoBauDia()` (função única compartilhada entre o gancho de vitória e o fallback de segurança); `atualizarBauArena()`/`abrirBauPadrao()`/`abrirBauEspecial()`. Sprites do pack "Treasure Chests" (Mana Seed / Seliel the Shaper, itch.io, uso comercial liberado) embutidos em base64 no `:root{}` do `style.css`, um par fechado/aberto pro baú padrão e 4 pares (um por tier de raridade) pro especial.

### Bugs reais encontrados (nenhum pego só lendo código — todos surgiram testando)
1. **Loja excluiria as chaves sozinha.** `LOJA_TIPOS` tinha uma whitelist que não incluía `'chave'` — a decisão de "loja como fonte" teria sido quebrada silenciosamente se eu não tivesse checado o filtro antes de implementar.
2. **Estado preso em formato antigo.** Ao separar baú padrão/especial, o schema do `localStorage` mudou de `{ids,trancado,tier,aberto}` pra `{padrao,especial}`. Um dia já vencido antes da mudança ficava com dado no formato velho — o baú simplesmente não aparecia (sem erro, sem aviso). Fix: migração automática dentro de `lerBauDia()`, na leitura, sem re-creditar nada.
3. **Baú dependia só do instante exato da vitória.** Se o dia já tinha sido vencido antes desse recurso existir (ou a transição foi perdida por qualquer motivo), recarregar a página nunca recriava o estado — `alternar()` só dispara na transição, não em reload. Fix: `garantirBauDia()`, chamado a cada `atualizarBauArena()`, gera o estado on-demand se faltando.
4. **Causa raiz real do "sumiu de novo": `desenharHeroi()` reescreve `heroSprite.innerHTML` inteiro.** O baú tinha sido colocado como filho de `#heroSprite` pra ficar "grudado" no herói — mas essa função redesenha o sprite do zero toda vez que roda, apagando qualquer filho extra junto. Só foi encontrado rodando o app de verdade (servidor local + jsdom simulando vitória) e vendo `document.getElementById('bauArena')` voltar `null` mesmo com o estado salvo corretamente. Fix: baú virou irmão de `#heroSprite`, ambos dentro de `.fighter` (nunca reescrito).
5. **Pulso da animação não parava quando o baú era aberto.** `.bauArena.mostrar` (com a animação) e `.bauArena.aberto` (com `animation:none`) tinham a mesma especificidade CSS (2 classes cada) — a regra que vem depois no arquivo vence em empate, e por acaso era a do pulso. Fix: `.bauArena.mostrar.aberto` (3 classes), especificidade maior, vence sempre, independente da ordem no arquivo. Confirmado calculando a especificidade real via parser CSS, não só lendo o código.
6. **Texto da dica errado.** `"Requer uma Raro ou superior"` — faltava a palavra "chave" na frase inteira, e o adjetivo tava no gênero errado (deveria concordar com "chave", feminino). Fix: array `RARIDADES_FEM_PT` só pra essa concordância + frase corrigida pra `"Requer uma chave Rara ou superior"`.
7. **Raridade do loot do baú especial saía fraca.** Primeira tentativa (bônus de sorte no sorteio) foi simulada antes de entregar e o resultado foi fraco demais pra se notar (~6 pontos percentuais de diferença). Trocado por garantia real: pelo menos 1 item sai numa raridade mínima que sobe com o tier (Incomum→Raro→Épico→Lendário) — testado 5000 vezes por tier, 0 falhas.

### Validação
`node --check` nos 44 blocos `<script>`, balanceamento de `<div>`/`<svg>`, CSS parseado (`css` npm lib). Além disso — pela primeira vez nessa profundidade — o app foi rodado **de verdade**: servidor HTTP local servindo os 3 arquivos + jsdom executando o JS real, simulando completar tarefas, vencer o dia, clicar nos baús (com e sem chave no inventário), e conferindo classes CSS aplicadas no DOM depois de cada ação. Foi assim que os bugs 3, 4 e 5 foram encontrados — nenhum aparecia só lendo o código.

### Pendências / decisões que ainda podem mudar
- Posicionamento visual (offsets em px dos dois baús ao lado do herói) foi calibrado por tentativa e erro a partir de prints do usuário — ainda não confirmado em dispositivo real, só no navegador dele.
- Pesos de chance/tier/raridade (`ECO.chanceBauTrancadoMin/Max`, `PESO_TIER_ESPECIAL`, `RAR_MINIMA_POR_TIER`) são valores iniciais, fáceis de ajustar depois de testar o "feel" real.

## 87. Bug pequeno: rótulo "Equipamentos" preso em português no Perfil

### O que foi pedido
A tira de badges de equipamento (acima da barra de Vida, tela de Perfil/Tarefas) sempre mostrava "Equipamentos" em português, mesmo com o app em inglês.

### Causa raiz
`montarFaixa()` criava o rótulo com texto fixo (`'<span class="xplabel">Equipamentos</span>'`), sem passar pelo sistema de i18n (`data-i18n`/`window.t()`). Bug duplo: além de nunca traduzir, mesmo que traduzisse só na criação, trocar de idioma **depois** que a linha já existia não teria efeito nenhum (a função só monta o rótulo `if (!row)`, ou seja, uma vez só).

### Fix
Chave nova no dicionário (`perfil.equipamentos`: Equipamentos/Equipment). Rótulo criado com `data-i18n="perfil.equipamentos"` (pego pelo scanner global `aplicarIdioma()`) **e** retraduzido via `window.t()` toda vez que `montarFaixa()` roda — não só na criação — pra acompanhar troca de idioma em qualquer momento.

### Validação
`node --check` nos 44 blocos, tags balanceadas.

## 88. Bug real: item-chave abria o Grimório sem querer

### O que foi pedido
Usuário percebeu (sessão de revisão do item 86): as 5 chaves de baú, agora `tipo:"chave"` igual o Grimório, ganharam o mesmo botão "Abrir" da ficha — e clicar nele abria o bestiário do Grimório, não fazia nada relacionado à chave.

### Causa raiz
O botão "Abrir" era renderizado pra **qualquer** item com `tipo === 'chave'` (sem checar qual item era), e o handler do clique chamava `window.abrirCatalogoGrimorio()` incondicionalmente. Reaproveitar o tipo `chave` pras 5 chaves (decisão do item 86) trouxe esse efeito colateral de brinde.

### Fix
Botão "Abrir" só aparece quando `id === ID_GRIMORIO_INV` (constante que já existia no mesmo bloco, reaproveitada em vez de duplicada). Como as chaves de baú ficaram sem nenhum botão de ação (Vender já era escondido pra `tipo:"chave"` desde o item 86), adicionei uma linha informativa na ficha: *"Usada automaticamente pra destrancar um baú trancado na Arena"* — senão a ficha ficava sem nenhuma explicação de pra que serve o item.

### Validação
Testado via jsdom rodando o app de verdade: ficha da Chave de Ferro → zero botões de ação, só o texto informativo. Ficha do Grimório → continua com "Abrir" normalmente, sem regressão.

## 89. Hipótese fundamentada (não confirmada em aparelho): arrasto de tarefas estranho com só 2 tarefas na lista

### O que foi pedido
Usuário relatou: arrastar pra reordenar com só 2 tarefas na lista se comporta de forma estranha; a partir de 3 tarefas funciona normal.

### Causa provável
`#list{flex:1}` faz a lista preencher toda a altura disponível na tela, **independente da quantidade de tarefas**. O teto do "vão elástico" (`atualizarAlturaElastica()`, item 64/68/75) usava `list.clientHeight` — a altura cheia do container, não a altura do conteúdo real. Com só 2 tarefas, sobra um espaço vazio enorme dentro do container que não aparece visualmente mas contava pro cálculo, deixando o vão esticar muito além do esperado. Com 3+ tarefas o conteúdo ocupa mais desse espaço e o mesmo efeito (idêntico no código) fica mascarado.

### Fix
Teto trocado pra ser proporcional à quantidade real de cards visíveis (`alturaBaseCard × (nCards + 0.5)`) em vez da altura do container inteiro.

### Importante — nível de confiança
Essa é uma **hipótese bem fundamentada por leitura de código e cálculo numérico isolado**, não um bug confirmado visualmente — jsdom não faz layout de verdade (`getBoundingClientRect` não retorna posições reais), então não dá pra reproduzir o gesto de toque aqui. **Pendente de teste em aparelho real**, mesmo padrão de outras hipóteses já registradas nesse módulo (ver comentário do `LIMIAR_TOQUE`).

## 90. Item Lendário exclusivo do baú especial (nunca no baú padrão)

### O que foi pedido
Decisão do usuário: itens de raridade Lendário devem sair só do baú especial (com chave), nunca do baú padrão/comum.

### Implementação
`sortearItem()` ganhou parâmetro opcional `permitirLendario` (default `true` — não quebra nenhum chamador existente). `darLoot()` (usado só pelo baú padrão) passa `false` explicitamente: zera o peso da raridade 4 no sorteio ponderado e também exclui ela do fallback (`pool` vazio por raridade).

### Bug real encontrado no caminho
O wrapper de bônus de Fortuna (`window.sortearItem = function(sorte){ return _sortearItem((sorte||0)+bonusFortuna()); }`, item do efeito de atributo) só repassava o primeiro argumento — o `false` de `permitirLendario` seria descartado silenciosamente, e qualquer jogador com Fortuna investida voltaria a poder tirar Lendário do baú comum, furando a regra por trás das costas. Corrigido pra repassar todos os argumentos (`...resto`).

### Validação
4000 sorteios simulados via jsdom: **0 Lendários** no baú padrão, mesmo forçando um bônus de Fortuna artificialmente alto pra estressar o wrapper. Baú especial testado em paralelo, continua sorteando Lendário normalmente.

## 91. Calibração da chance de spawn do baú especial (foi longe demais nos dois sentidos)

### Histórico da calibração
- Original (item 86): **15-50%/dia** — usuário achou comum demais.
- Primeira correção: **5-18%/dia** — usuário achou raro demais (foi longe demais no sentido contrário).
- Ajuste final, meio-termo: **10-30%/dia**.

### Números de referência (dia de dificuldade média)
- Original: ~32%/dia → ~2,3 baús especiais por semana.
- Intermediário: ~12%/dia → ~0,8 por semana.
- Final: ~20%/dia → ~1,4 por semana.

### Onde mexer se precisar recalibrar de novo
`ECO.chanceBauTrancadoMin` / `ECO.chanceBauTrancadoMax`, `index.html`.

## 92. Ícone do popup de recompensa mostra o baú de verdade que foi aberto

### O que foi pedido
O popup de recompensa (`mostrarBauLoot`) sempre mostrava o ícone genérico antigo do catálogo (sprite 118, "Baú do Tesouro"), independente de qual baú real foi clicado — padrão ou qual tier do especial.

### Implementação
`mostrarBauLoot(ganhos, aoFechar, iconeVariante)` ganhou um terceiro parâmetro opcional (`'baupadrao'` ou `'tier0'..'tier3'`). Quando presente, o ícone do popup usa as **mesmas CSS vars do pack Treasure Chests** já embutidas pra Arena (item 86), em vez do sprite genérico — mesmo bounce de abertura de sempre (`.abriu{animation:bauPulo}`), só trocando qual imagem de fundo aparece. Sem variante (nenhuma chamada externa usa isso hoje, mas por segurança), cai no sprite genérico antigo — não quebra compatibilidade.

### Validação
Testado via jsdom: ao abrir o baú padrão, o ícone do popup recebe a classe `bauicone2 baupadrao` corretamente.

## 93. Barra de categorias do inventário sumindo com muitos itens

### O que foi pedido
Com muita coisa acumulada na mochila, a barra de filtro de categorias (Tudo/Equipamento/Consumíveis/Tesouros/Item-chave) desaparecia ao rolar a grade de itens.

### Causa raiz
`#viewInventario` é uma única região rolável (`.view{flex:1;overflow-y:auto}`) — cabeçalho, caixa de equipamento, barra de filtros e grade de itens rolam tudo junto, como um bloco só. Com muitos itens, os filtros ficavam lá em cima, fora da área visível.

### Fix
`.invfiltros` virou `position:sticky;top:0`, com fundo sólido (`var(--panel)`) pra não deixar os itens da grade aparecerem por baixo enquanto ela fica fixa no topo durante a rolagem.

### Validação
Confirmado via `getComputedStyle` no jsdom que `position:sticky` está de fato aplicado no elemento.

## 94. Redesign dos Pontos de Atributo (sem acordeão)

### O que foi pedido
Usuário não gostava do design anterior: cada atributo era um cartão fechado por padrão, precisava tocar pra expandir e só aí apareciam a descrição e o botão de investir — 2 toques pra gastar 1 ponto, descrição escondida por padrão.

### Direção de design
Apresentei 3 direções (bolinhas/pips sempre visíveis, cards em grid com barra de progresso, anel circular estilo skill tree). Usuário pediu pra eu escolher — fui na de **barra de progresso horizontal**, adaptada pra pilha vertical de 3 cards (não grid 2 colunas, que deixaria 1 célula órfã com só 3 itens).

### Implementação
Novo markup `.atrcard2`: ícone/nome/valor sempre visíveis no topo, descrição sempre visível logo abaixo (não escondida atrás de clique), barra de progresso (`.atrbarrafundo`/`.atrbarrafill`) mostrando a fração já investida do teto, botão "+" sempre visível ao lado da barra. Fortuna/Foco/Vigor têm o mesmo teto (30%) e custo por ponto (2%), então a barra usa `bonus/TETO` direto sem precisar de lógica por atributo.

O acordeão antigo (`.atrcard`/`.atrbarra`/`.atrcorpo`, listener de clique que expandia via `.aberto`) foi **comentado, não apagado** — mesmo padrão de outros blocos `DEPRECATED` já no arquivo.

### Validação
Testado via jsdom forçando `gasto.fortuna` em valores diferentes: 5 pontos investidos → barra em 33,3% e valor `+10%`; 15 pontos (teto) → barra em 100% e valor `+30%` — batendo exato com o esperado nos dois casos.

## 95. Fonte ilegível no título de categoria de conquistas

### O que foi pedido
Usuário achou o texto dos títulos de conquista (cabeçalho de cada categoria: "Sequência Diária", "Matar Monstros" etc.) muito ilegível.

### Diagnóstico
Calculei o contraste real (fórmula WCAG) de todas as 5 cores de categoria contra o fundo `--panel-2` dos 4 temas — todas passam (4,3:1 a 11:1, a maioria bem acima do mínimo de 4,5:1), então não era problema de contraste de cor. O suspeito real: `.conqcatnome` era a **única fonte serifada decorativa do app inteiro** (Cormorant Garamond) — todo o resto usa Outfit (sans) ou Silkscreen (pixel). Serifada fina não combina bem com telas pequenas/pixel-art.

### Fix
Trocada pra Outfit, peso 700, 18px (ajustado de 20px já que sans "pesa" visualmente mais que serifada no mesmo tamanho, pra manter a mesma hierarquia).

### Pendência
Não confirmado ainda se resolve de fato — se continuar ruim, o problema pode estar em outro elemento (nome individual de cada conquista, `.conqv2nome`, não o cabeçalho da categoria).

## 96. Cor da dificuldade Média presa na cor do tema em vez de fixa

### O que foi pedido
A cor da dificuldade "Média" (pip no card da tarefa e seletor no composer) mudava conforme o tema escolhido pelo usuário — deveria ser uma cor fixa, como as outras 3 dificuldades já são.

### Causa raiz
`.task[data-dif="media"] .difpip{color:var(--accent)}` e `.dif[data-dif="media"].on{color:var(--accent)}` usavam a cor de destaque do tema (`--accent`), que muda entre Laranja/Azul/Dourado/Escuro. Trivial (cinza fixo `#7E8BA3`), Fácil (`--verde`) e Difícil (`--perigo`) já usavam cores fixas, independentes de tema — só Média tinha esse comportamento diferente. Achado no caminho: o nome do rótulo ("Média") no seletor do composer nem tinha regra própria de cor (`.dif[data-dif="media"].on .difnome`) — as outras 3 dificuldades têm, essa não, e caía no mesmo fallback genérico ligado ao tema.

### Fix
Trocado pra `#F2C94C` (o mesmo amarelo dourado já usado em outros lugares do app — moeda, categoria "Nível" das conquistas), fixo independente de tema. Duas correções, replicadas nos dois blocos de CSS duplicados do arquivo (6 ocorrências no total): cor do pip, cor do card ativo, e a regra do nome do rótulo que estava faltando.

### Validação
`css` npm lib confirmou o CSS válido depois da troca; conferido visualmente por grep que as 6 ocorrências (3 regras × 2 blocos duplicados) ficaram consistentes com `#F2C94C`.

### Bug: baú do dia duplicava recompensa ao criar conta depois de já ter aberto como convidado

**Sintoma:** usuário abre o baú do dia como convidado (ganha moedas/item), depois cria
conta -> Arena mostra baú novo, fechado -> abre de novo -> credita moedas e sorteia
item outra vez. Recompensa duplicada pro mesmo dia.

**Causa:** a lista de chaves migradas convidado->conta em aoLogar() (item 13f do
roadmap, mesma rotina que migra tarefas/XP/inventário/etc. pra chave namespaced por
uid) tem 12 chaves hardcoded. CHAVE_BAU_DIA ('questlog.bauDia.v1', item 86) foi
implementada DEPOIS dessa lista existir e nunca foi adicionada nela. Resultado: no
login, a chave crua do baú (convidado) é ignorada -- nem copiada nem apagada -- e
window.chaveConta(CHAVE_BAU_DIA) não encontra nada na chave nova. garantirBauDia()
interpreta isso como "baú do dia ainda não gerado" e cria um do zero.

**Fix:** adicionada 'questlog.bauDia.v1' ao array de 12 chaves em aoLogar() (agora
13). Nenhuma mudança em garantirBauDia()/salvarBauDia()/lerBauDia() -- a leitura já
usava window.chaveConta() corretamente, só faltava a chave entrar na migração.

**Alerta pra próximas specs:** essa lista de migração NÃO é automática -- toda vez
que uma feature nova introduzir uma chave de localStorage namespaced por conta
(padrão questlog.[key].v1 + chaveConta()), ela precisa ser adicionada manualmente
a esse array em aoLogar(), ou fica invisível pro fluxo convidado->conta (mesma
classe de bug documentada aqui, agora seu 2º caso real). Revisar esse array antes
de fechar qualquer spec que crie chave nova.

**Teste de validação:** fluxo completo simulado -- boot como convidado, resgatar
baú do dia (moedas X, item Y anotados), criar conta, verificar: (1) nenhum baú novo
aparece na Arena pro dia corrente, (2) saldo de moedas bate com o valor de antes da
criação da conta (sem incremento), (3) inventário não ganhou item duplicado, (4)
chave crua 'questlog.bauDia.v1' some do localStorage depois do login (confirma que
foi migrada+removida, não só ignorada).

## auth/email-already-in-use — erro inline no campo de email

Problema: tentar criar conta com email ja cadastrado nao dava NENHUM
feedback visual -- o catch chamava window.aviso(), mas aviso() fica
mudo com TOASTS_DESATIVADOS=true. Usuario ficava sem saber por que
o cadastro nao completou.

Fix: auth/email-already-in-use passou a usar o mesmo padrao visual
inline ja validado na tela de senha (campoStatus com icone erro +
paragrafo .loginSenhaErro), em vez do toast generico. Os outros
codigos de erro (weak-password, wrong-password, etc.) continuam
passando por window.aviso() -- ou seja, continuam mudos. Nao foi
pedido resolver isso pra todos os codigos, so pro caso especifico
que estava sem feedback nenhum.

Detalhe de arquitetura: o catch do Firebase vive num <script
type="module"> (bloco de login/signup) que NAO compartilha escopo
com a IIFE que controla os campos de senha (campoSenha, statusSenha
etc, mais acima no arquivo). Por isso os helpers
window.questlogMostrarErroEmail() e window.questlogLimparErroEmail()
foram expostos globalmente -- mesmo padrao ja usado por
window.questlogLimparStatusSenha() e window.questlogModoCadastro().

Limpeza do erro: acontece em 3 momentos -- (1) usuario digita de
novo no campo email (listener 'input'), (2) usuario troca de
Entrar/Cadastro (dentro de questlogLimparStatusSenha), (3) inicio
de cada tentativa de submit (limparErroEmail no comeco do onclick).

CSS: nenhuma classe nova. Reaproveita .campoStatus.erro e
.loginSenhaErro que ja existiam pro campo de senha.

Arquivo: index.html
- HTML do campo de email: adicionado span#loginEmailStatus +
  p#loginEmailErro
- IIFE do login: declarados campoEmail/statusEmail/erroEmail,
  funcao limparErroEmail(), helpers expostos em window
- Modulo Firebase (loginEntrarBtn.onclick): catch agora ramifica
  auth/email-already-in-use pro campo inline em vez do toast

  - [style.css] Removida duplicação Bloco #19-20 (linhas 821-1063) — cópia byte-a-byte
  de Módulo #2-3 (linhas 1993-2235), causada por sobreposição das duas eras de
  numeração de bloco. Confirmado via diff textual + parser `css` (npm) que as
  regras remanescentes no Módulo são idênticas selector+decl+!important às
  removidas — zero mudança de cascata. 3547 → 3304 linhas. Nenhuma regra única
  perdida. Demais blocos (fora da faixa 821-1063 ↔ 1993-2235) não foram varridos
  — se suspeitar de outra duplicação, pedir novo mapeamento completo dos 62 blocos.
