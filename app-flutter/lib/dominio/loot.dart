// Espólio: sorteio de itens, afixos de fábrica e itens do baú. Espelha play/index.html:
// afxRolar/comAfixo (~3214 a 3246), PESO_RAR/sortearItem/tesouroExtra/lootDoEstagio/darLoot (~8471 a 8527).
//
// O sorteio usa uma fonte de números em [0,1) (`Aleatorio`) para os testes poderem alimentar a MESMA
// sequência no JS (Math.random) e no Dart, e conferir id por id. A ORDEM das chamadas é a do JS.
import 'catalogo.dart';
import 'economia.dart';

typedef Aleatorio = double Function();

const List<double> pesoRar = [50, 28, 8, 6, 6, 1.4, 0.6, 0]; // Comum..Única
const List<double> rarEscala = [0, 1, 2, 2.5, 3, 4, 4.5, 5];
const double pNegLoot = 0.20;
const double pSemAfx = 0.90;

const Map<String, List<List<int>>> faixaAfixo = {
  'gan': [[1, 2], [1, 3], [2, 4], [3, 5], [3, 6], [5, 8], [7, 11], [7, 11]],
  'est': [[1, 2], [1, 3], [2, 4], [3, 5], [3, 6], [5, 8], [7, 11], [7, 11]],
  'sor': [[1, 1], [1, 1], [1, 2], [2, 2], [2, 3], [2, 4], [3, 6], [3, 6]],
  'bar': [[1, 1], [1, 2], [2, 3], [2, 3], [2, 4], [3, 5], [4, 7], [4, 7]],
  'bau': [[1, 1], [1, 2], [2, 3], [3, 3], [3, 4], [4, 5], [6, 7], [6, 7]],
  'abu': [[1, 2], [2, 3], [3, 4], [4, 5], [4, 6], [6, 8], [8, 11], [8, 11]],
  'tes': [[2, 3], [3, 5], [4, 6], [5, 7], [6, 8], [8, 12], [11, 17], [11, 17]],
  'tex': [[1, 2], [2, 3], [3, 4], [4, 5], [4, 6], [6, 9], [8, 13], [8, 13]],
};
const List<String> afixoNegChaves = ['gan', 'est', 'sor', 'bar'];
const Map<String, List<List<int>>> faixaAfixoNeg = {
  'gan': [[1, 1], [1, 2], [1, 3], [2, 3], [2, 4], [3, 5], [4, 6], [4, 6]],
  'est': [[1, 1], [1, 2], [1, 3], [2, 3], [2, 4], [3, 5], [4, 6], [4, 6]],
  'sor': [[1, 1], [1, 1], [1, 2], [1, 2], [1, 3], [2, 3], [3, 4], [3, 4]],
  'bar': [[1, 1], [1, 1], [1, 2], [2, 2], [2, 3], [2, 4], [3, 5], [3, 5]],
};

int _indice(Aleatorio r, int n) => (r() * n).floor();

/// `afxRolar(rar, excluir, pNeg)`
Afixo afixoRolar(int rar, String? excluir, double? pNeg, Aleatorio r) {
  final ri = rar.clamp(0, 6);
  final neg = pNeg != null && pNeg != 0 && r() < pNeg;
  final ch = (neg ? afixoNegChaves : afixoChaves).where((k) => k != excluir).toList();
  final k = ch[_indice(r, ch.length)];
  final f = (neg ? faixaAfixoNeg[k]! : faixaAfixo[k]!)[ri];
  final v = f[0] + (r() * (f[1] - f[0] + 1)).floor();
  return Afixo(k, neg ? -v : v);
}

/// `comAfixo(id)`: equipamento base vira uma variante (90% sem afixo); o resto passa direto.
int comAfixo(Catalogo cat, int id, Aleatorio r) {
  if (!cat.ehEquipBase(id)) return id;
  final semAfixo = r() < pSemAfx;
  return cat.variante(id, semAfixo ? null : afixoRolar(cat.item(id)!.raridade, null, pNegLoot, r), 0);
}

List<int> _idsBase(Catalogo cat, bool Function(ItemCatalogo) filtro) =>
    [for (var i = 0; i < cat.baseN; i++) if (filtro(cat.item(i)!)) i];

int _sortearRar(List<double> pesos, Aleatorio r) {
  final total = pesos.fold<double>(0, (a, b) => a + b);
  var x = r() * total;
  var rar = 0;
  for (var i = 0; i < pesos.length; i++) {
    x -= pesos[i];
    if (x <= 0) {
      rar = i;
      break;
    }
  }
  return rar;
}

/// `sortearItem(sorte, permitirLendario)`. [afixoTes] é `afixoSoma('tes')` do herói (Garimpeiro).
int sortearItem(Catalogo cat, Aleatorio r, double sorte, {bool permitirLendario = true, int afixoTes = 0}) {
  final pesos = [for (var i = 0; i < pesoRar.length; i++) pesoRar[i] * (1 + sorte * rarEscala[i] * 0.9)];
  if (!permitirLendario) {
    pesos[5] = 0;
    pesos[6] = 0;
  }
  final rar = _sortearRar(pesos, r);
  var pool = _idsBase(cat, (it) => it.raridade == rar && !it.morto);
  if (pool.isEmpty) pool = _idsBase(cat, (it) => !it.morto && (permitirLendario || it.raridade < 5));
  var pick = pool[_indice(r, pool.length)];
  if (cat.item(pick)!.tipo != 'tesouro' && r() * 100 < afixoTes) {
    var tp = pool.isNotEmpty ? _idsBase(cat, (it) => it.tipo == 'tesouro' && !it.morto && it.raridade == rar) : <int>[];
    if (tp.isEmpty) tp = _idsBase(cat, (it) => it.tipo == 'tesouro' && !it.morto && (permitirLendario || it.raridade < 5));
    if (tp.isNotEmpty) pick = tp[_indice(r, tp.length)];
  }
  return comAfixo(cat, pick, r);
}

/// `tesouroExtra(sorte)`: [afixoTex] é `afixoSoma('tex')` (Tesoureiro).
int? tesouroExtra(Catalogo cat, Aleatorio r, double sorte, {int afixoTex = 0}) {
  if (!(r() * 100 < afixoTex)) return null;
  final pesos = [for (var i = 0; i < pesoRar.length; i++) i < 5 ? pesoRar[i] * (1 + sorte * rarEscala[i] * 0.9) : 0.0];
  final rar = _sortearRar(pesos, r);
  var tp = _idsBase(cat, (it) => it.tipo == 'tesouro' && !it.morto && it.raridade == rar);
  if (tp.isEmpty) tp = _idsBase(cat, (it) => it.tipo == 'tesouro' && !it.morto && it.raridade < 5);
  return tp.isEmpty ? null : tp[_indice(r, tp.length)];
}

class LootEstagio {
  final int qtd;
  final double bonus;
  const LootEstagio(this.qtd, this.bonus);
}

/// `lootDoEstagio()`
LootEstagio lootDoEstagio(int estagio, Aleatorio r) {
  final e = estagio.clamp(1, 4);
  final mm = Eco.lootPorEstagio[e - 1];
  return LootEstagio(mm[0] + (r() * (mm[1] - mm[0] + 1)).floor(), Eco.sorteEstagio[e - 1]);
}

/// Itens do baú padrão do dia (`darLoot` sem creditar): devolve os ids; quem chama credita no inventário.
List<int> sortearLootDoDia(Catalogo cat, Aleatorio r,
    {required int nTarefas, required int estagio, int afixoTes = 0, int afixoTex = 0}) {
  final le = lootDoEstagio(estagio, r);
  final sorte = (nTarefas / 10 + le.bonus).clamp(double.negativeInfinity, 1.0).toDouble();
  final ids = <int>[];
  for (var i = 0; i < le.qtd; i++) {
    ids.add(sortearItem(cat, r, sorte, permitirLendario: false, afixoTes: afixoTes));
  }
  final tx = tesouroExtra(cat, r, sorte, afixoTex: afixoTex);
  if (tx != null) ids.add(tx);
  return ids;
}
