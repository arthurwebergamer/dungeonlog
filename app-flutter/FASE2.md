# Fase 2 (parte 1): loot, baú do dia e Inventário

## O que funciona
- **Loot** (`lib/dominio/loot.dart`): sorteio de itens por raridade, afixos de fábrica, tesouro extra e quantidade por estágio.
  Conferido contra o JS com 400 casos (mesma sequência de números aleatórios nos dois lados: mesmos ids, mesma
  quantidade de números consumidos, mesmas variantes criadas). Teste: `test/loot_paridade_test.dart`.
- **Baú do dia** (padrão): ao vencer o dia ("Terminar dia") o loot é sorteado e creditado; botão "Abrir baú do dia" mostra os itens.
  Estado salvo em `questlog.bauDia.v1`.
- **Inventário**: 5 slots de equipamento, busca, filtros, grade, ficha do item (equipar/desequipar, usar consumível, vender).

## Ainda fora
- Baú trancado (especial), chaves, baú extra (afixo Abundante), pity.
- Forja/afixos (rerrolar), subfiltros de armas, filtro por afixo, grimório.
- Loja (estoque diário, comprar, vender tesouros).
- Equipamento desenhado no herói da arena, animação/efeito do baú, som.
- Visual do Inventário ainda não foi comparado com o original (só funcional).
