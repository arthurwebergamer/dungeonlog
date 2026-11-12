# Fase 0 (Base): o que existe, como rodar, o que ficou de fora

## O que foi entregue
- **Assets e textos** (`assets/`): extraídos de `play/` por `tools/extrair_assets.mjs`. 63 monstros, 8 heróis, 319 itens (linhas cruas de `ITENS` + folha `sheet.png`, 16x27 tiles de 32 px), 4 cenários, 300 chaves PT/EN. Não recortei a folha em PNGs soltos: o Flutter desenha o tile direto da folha (filtro "nearest").
- **Domínio em Dart puro** (`lib/dominio/`): `economia`, `datas`, `tarefa`, `catalogo` (variantes de afixo), `regras` (XP, moedas, nível, bônus de equipamento, estágio, monstro do dia), `vida` (vida, `ferir`, `curar`, `verificarVirada`), `save` (JSON versão 3), `dados_jogo`. `lib/dados/carregador_assets.dart` carrega os JSON no app.
- **Testes de paridade** (`test/paridade_js_test.dart`): comparam o Dart com o JS atual. Os casos vêm de `tools/gerar_casos_js.mjs`, que extrai as funções REAIS de `play/index.html` (e o bloco "Vida do herói" inteiro) e as roda no Node.

## Como rodar
```
flutter test                                        # em app-flutter/
node app-flutter/tools/gerar_casos_js.mjs           # regera os casos do JS (na raiz do repositório)
node app-flutter/tools/extrair_assets.mjs           # regera assets/ a partir de play/
```
Se `play/index.html` mudar a economia ou as regras, regere os casos: os testes passam a apontar a diferença.

## Pontos de atenção
- **Monstro do dia e fuso:** o JS calcula `floor(meia-noite local em ms / 86400000)`, o que em fusos a leste de UTC (Tóquio, Auckland) dá um dia a menos. O Dart reproduz isso de propósito (`diasCorridosComFuso`), testado em 8 fusos.
- **Personagem padrão da chave do save é `pj1`:** `questlog.v1.pj.pj1`.
- **`ordem` do XP:** na conclusão conta a própria tarefa; no toque parcial de meta>1 o JS usa a ordem SEM contar a atual (`alternar` ~6418).
- **Migração de conta legada** (save sem `afixos`): o JS sorteia afixos e logo os remove. O Dart faz direto o efeito líquido. O conteúdo é equivalente, mas os ids das variantes e a lista `variantes` podem diferir quando o sorteio do JS cai em "com afixo".

## Desvios conhecidos (só com save corrompido ou editado à mão)
Valores que o app atual nunca grava: `id`/`variantes` como string, `valor` de afixo fracionário ou ausente, `semente` fracionária, `derrotadoEm`/`nomeHeroi` numéricos, `inventario` com `null` em save legado, e reformatação de números aninhados (`3.0` vs `3`). O JS aceita ou quebra de jeitos diferentes; o Dart ignora ou normaliza sem lançar exceção.

## Fica para a Fase 1 (aba Tarefas)
- Estado de `alternar()`: trava contra recompensa em dobro, `vezesData`/`vezesN`, cancelar o descanso ao concluir, contador de estágio. Aqui existem só as contas (`ganhoPorConclusao`, `curar`).
- `totalTarefasConcluidas` (vem do histórico), tema da arena salvo (define o pool de monstros), descanso e histórico (chaves secundárias da conta), sorteio de loot/baú.
