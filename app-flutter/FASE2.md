# Fase 2: loot, baús, Inventário, Loja, Forja, sons

## Feito (lógica conferida contra o JS)
- **Loot** (`lib/dominio/loot.dart`): 400 casos com a mesma sequência de números aleatórios nos dois lados.
- **Baús** (`lib/dominio/bau.dart`): padrão, trancado (com chave e garantia aos 6 dias), extra (afixo Abundante),
  escolha da chave de menor raridade suficiente. 300 casos do `gerarEstadoBauDia` real do JS + 120 de chaves.
- **Loja** (`lib/dominio/loja.dart`): estoque do dia determinístico, nível mínimo, preços, oferta, desconto do afixo
  Barganhista; 120 estoques conferidos. Venda de itens e de todos os tesouros.
- **Forja** (`lib/dominio/forja.dart`): custo em tesouros, chance de maldição, sorteio do novo afixo; 300 casos.
- **Telas** copiadas do original: Inventário, ficha, forja com roleta, Loja, baús na arena (com sombra), popup do baú
  (com confete), arma e escudo no herói.
- **Sons** (`lib/ui/som.dart`, `tools/gerar_sons.mjs`): os mesmos efeitos do original, renderizados em WAV a partir das
  receitas de osciladores/ruído. Volume 0,55 e liga/desliga em `questlog.sfx.v1` (a tela de ajustes vem no Perfil, Fase 3).
- **Fonte** Cormorant Garamond itálico (OFL) nos nomes dos itens.

## Fica para as próximas fases (dependem de telas que ainda não existem)
- **Grimório** (item único): é dado no marco de nível 5 e abre o catálogo/bestiário (Fase 4).
- **Fortuna e Foco**: os atributos do Perfil (Fase 3). No app atual ambos retornam 0, então chance de baú e desconto
  da loja só usam afixos de equipamento, como o original faz hoje.
- Ajustes de som (liga/desliga, volume) e de vibração: Perfil (Fase 3).
- Não conferido na tela: arcos e bestas na mão do herói.
