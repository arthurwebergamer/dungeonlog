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

## Visual (comparado com o original em 390x844, tema grafite)
Medidas e cores copiadas do CSS computado de `play/`; telas conferidas lado a lado no navegador (build web).
- **Topo** (avatar, nível, moedas) agora aparece em todas as abas (`lib/ui/topo.dart`).
- **Inventário** (`tela_inventario.dart`): cabeçalho com a contagem, caixa dos 5 slots (tracejado + ícone fantasma + rótulo
  quando vazio; borda da raridade quando cheio), linha "Moedas +N%  XP +N%", busca em pílula (ignora acento; acha também
  pelo nome do encantamento), filtros presos no topo da rolagem, subfiltros de equipamento (`subcatEquip`), grade de 5
  colunas com borda/brilho por raridade, quantidade, bolinha verde de equipado e armas escuras clareadas.
- **Ficha do item e Forja** (`ficha_item.dart`): ficha roxa (#251E38), linhas "◆ +10% XP", "Vende por", botões
  Equipar/Usar/Forjar/Vender; seleção de tesouros; roleta (tira de 28 linhas que desacelera em 2,2 s, moldura que pulsa);
  resultado "Atual / Novo"; troca de tela deslizando.
- **Loja** (`tela_loja.dart`): "renova em Nh", pílula do saldo, abas, linhas com oferta do dia (preço cheio riscado),
  travado por nível, esgotado, sem moedas; aba Vender com "×N", "em uso — será desequipado" e o botão tracejado de vender
  todos os tesouros; folha de confirmação com fundo desfocado.
- **Baús na arena** (`arena.dart`): padrão, trancado (4 tiers + cadeado) e extra nas posições do original, surgem com um
  salto e pulsam até abrir; dica "Requer uma chave X ou superior"; pop-up "Baú do Tesouro" (`popup_bau.dart`).
- **Equipamento no herói**: escudo e arma (com a mão por cima) como em `desenharHeroi()`; tabelas em
  `assets/dados/equip_arena.json` (EQ_BB, ARMA_GRIP, ARMA_AJUSTE, ARMA_ESCURA e o cadeado), artes em `assets/img/baus/`.
- **Avisos flutuantes** (`flutuante.dart`): "+N XP / +N HP" ao usar e "+N" com a moeda ao vender, em cima do item.

## Diferenças conhecidas / ainda fora
- **Fonte do nome do item**: o original usa Cormorant Garamond itálico (Google Fonts). O arquivo não está no repositório e
  não foi baixado; o código já pede a família `Cormorant Garamond` e cai na serifada do sistema (no build web cai na
  sem serifa). Para fechar: pôr `CormorantGaramond-Italic.ttf` em `assets/fonts/` e declarar a família no `pubspec.yaml`.
- **Filtro por encantamento (chips)**: no original o código existe mas o elemento `#invAfxFiltros` não está no HTML, então
  os chips nunca aparecem; aqui também não. A busca por nome de encantamento funciona.
- **Arma/escudo no herói**: o original consulta ARMA_GRIP/EQ_BB/ARMA_ESCURA pelo id do item; como todo equipamento do
  inventário dele é variante (id acima do catálogo), a consulta falha e vale a posição padrão. Aqui é igual (mesma imagem
  do original); itens com id do catálogo base (comprados na loja do Flutter) usam a medida fina.
- **Avisos de equipar e comprar**: no original `aviso()` está mudo (TOASTS_DESATIVADOS), então nada aparece; aqui sobe um
  flutuante "EQUIPADO / DESEQUIPADO / COMPROU X" em cima do item. Vender tesouros em lote não mostra aviso (como lá).
- Sons não existem; a roleta e os baús usam só vibração. Sem as partículas do pop-up do baú nem a sombra projetada dos baús.
- Grimório (item único) aparece na ficha sem o botão "Abrir" (depende do Perfil/bestiário).
- Fortuna e Foco (Perfil, Fase 3) valem 0 no app atual, então chance de baú e desconto da loja só usam afixos de equipamento.
