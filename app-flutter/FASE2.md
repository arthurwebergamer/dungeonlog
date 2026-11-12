# Fase 2: loot, baús, Inventário, Loja e Forja

## O que funciona (lógica conferida contra o JS)
- **Loot** (`lib/dominio/loot.dart`): 400 casos com a mesma sequência de números aleatórios nos dois lados.
- **Baú do dia** (`lib/dominio/bau.dart`): padrão, trancado (especial, com chave e garantia aos 6 dias), extra (afixo Abundante),
  escolha da chave de menor raridade suficiente. 300 casos do `gerarEstadoBauDia` real do JS + 120 de chaves.
- **Loja** (`lib/dominio/loja.dart`): estoque do dia determinístico (mulberry32), nível mínimo, preços, oferta, desconto do afixo
  Barganhista; 120 estoques conferidos. Venda de itens e de todos os tesouros.
- **Forja** (`lib/dominio/forja.dart`): custo em tesouros, chance de maldição, sorteio do novo afixo; 300 casos.
- **Telas** (funcionais): Inventário (slots, busca, filtros, grade, ficha com equipar/usar/vender/forjar), Loja (comprar/vender),
  botões dos baús na aba Tarefas, popup de loot.
- Estado salvo em `questlog.bauDia.v1`, `questlog.bauSemEspecial.v1` (garantia) e `questlog.loja.v1`.

## Diferenças conhecidas / ainda fora
- Fortuna e Foco (Perfil, Fase 3) valem 0 no app atual, então chance de baú e desconto da loja só usam afixos de equipamento.
- Grimório (item único) não é dado nem aberto ainda (depende do Perfil/bestiário).
- Subfiltros de arma e filtro por afixo no Inventário.
- Visual: telas ainda não comparadas com o original; sem arte do baú, sem animação da roleta da forja,
  sem equipamento desenhado no herói da arena, sem sons.
