// Forja de afixos: gasta tesouros para sortear um novo encantamento. Espelha play/index.html (~8810 a 8998).
import 'catalogo.dart';
import 'loot.dart';

const double pNegForjaBase = 0.30;

/// `pNegForja(sel)`: tesouro mais raro = menos chance de maldição.
double pNegForja(Catalogo cat, List<int> sel) {
  if (sel.isEmpty) return pNegForjaBase;
  final m = sel.fold<double>(0, (a, id) => a + rarEscala[cat.item(id)!.raridade.clamp(0, 7)]) / sel.length;
  return pNegForjaBase * (1 - 0.2 * m);
}

/// Quantos tesouros a forja pede: `1 + min(rer, 2)`.
int custoForja(int rer) => 1 + (rer < 2 ? rer : 2);

/// O sorteio da forja: `afxRolar(it.rar, afixoAtual, pNegForja(sel))`.
Afixo sortearAfixoForja(Catalogo cat, int idItem, List<int> sel, Aleatorio r) {
  final it = cat.item(idItem)!;
  return afixoRolar(it.raridade, it.afixo?.tipo, pNegForja(cat, sel), r);
}
