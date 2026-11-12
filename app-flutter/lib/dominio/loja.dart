// Loja: estoque diário determinístico, preço, nível mínimo e venda de tesouros. Espelha o bloco LOJA de
// play/index.html (~9398 a 9592).
import 'catalogo.dart';
import 'economia.dart';
import 'js_compat.dart';
import 'loot.dart' show rarEscala;

const List<String> lojaTipos = ['arma', 'armadura', 'elmo', 'escudo', 'acess', 'cons', 'chave'];
const List<double> pesoLoja = [38, 30, 12, 7, 9, 0, 0, 0];

class VagaLoja {
  final int id;
  final bool oferta;
  const VagaLoja(this.id, this.oferta);
}

/// `nivelMinimo(rar)`
int nivelMinimo(int rar) => 1 + jsRound(rarEscala[rar] * (Eco.lojaNivelPorRaridade < 0 ? 0 : Eco.lojaNivelPorRaridade));

/// `pesosLojaPorNivel(nivel)`: zera as raridades que o nível ainda não compra.
List<double> pesosLojaPorNivel(int nivel) {
  final pesos = [for (var rar = 0; rar < pesoLoja.length; rar++) (rar < 5 && nivelMinimo(rar) <= nivel) ? pesoLoja[rar] : 0.0];
  final soma = pesos.fold<double>(0, (a, b) => a + b);
  return soma > 0 ? pesos : [1, 0, 0, 0, 0, 0, 0, 0];
}

/// `descontoLoja()` (Foco ainda é 0 no app atual): afixo Barganhista entre -10% e +30%.
double descontoLoja(int afixoBar, {double descontoFoco = 0}) {
  final v = descontoFoco + afixoBar / 100;
  return v < -0.10 ? -0.10 : (v > 0.30 ? 0.30 : v);
}

/// `precoLoja(id, oferta)`
int precoLoja(ItemCatalogo it, bool oferta, {double desconto = 0}) {
  final margem = it.tipo == 'cons' ? Eco.lojaMargemConsumivel : Eco.lojaMargem;
  final base = it.valor * margem * (oferta ? Eco.lojaDesconto : 1);
  final v = jsRound(base * (1 - desconto));
  return v < 1 ? 1 : v;
}

int _imul(int a, int b) {
  a &= 0xFFFFFFFF;
  b &= 0xFFFFFFFF;
  final ah = a >> 16, al = a & 0xFFFF, bh = b >> 16, bl = b & 0xFFFF;
  return ((al * bl) + (((ah * bl + al * bh) & 0xFFFF) << 16)) & 0xFFFFFFFF;
}

/// `rngLoja(seed)`: mulberry32, igual ao JS.
double Function() rngLoja(int seed) {
  var a = seed & 0xFFFFFFFF;
  return () {
    a = (a + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _imul(a ^ (a >> 15), 1 | a);
    t = ((t + _imul(t ^ (t >> 7), 61 | t)) ^ t) & 0xFFFFFFFF;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296;
  };
}

/// `montarEstoque()`: 8 vagas (6 equipamento/chave + 2 consumíveis), uma em oferta. [diasCorridos] e [semente] do jogo.
List<VagaLoja> montarEstoque(Catalogo cat, {required int diasCorridos, required num semente, required int nivel}) {
  final r = rngLoja(diasCorridos * 7919 + semente.toInt() * 104729 + 999);
  final idGrimorio = [for (var i = 0; i < cat.baseN; i++) if (cat.item(i)!.nome == 'Grimório') i].firstOrNull ?? -1;
  final pool = [
    for (var i = 0; i < cat.baseN; i++)
      if (lojaTipos.contains(cat.item(i)!.tipo) && !cat.item(i)!.morto && i != idGrimorio) i
  ];
  final vagas = Eco.lojaVagas < 1 ? 1 : Eco.lojaVagas;
  final pesos = pesosLojaPorNivel(nivel);
  final total = pesos.fold<double>(0, (a, b) => a + b);
  final nCons = Eco.lojaConsumiveis < vagas ? Eco.lojaConsumiveis : vagas;

  List<int> sortear(List<int> poolBase, int qtd) {
    final out = <int>[];
    var voltas = 0;
    while (out.length < qtd && voltas < 500) {
      voltas++;
      var x = r() * total;
      var rar = 0;
      for (var i = 0; i < pesos.length; i++) {
        x -= pesos[i];
        if (x <= 0) {
          rar = i;
          break;
        }
      }
      var sub = [for (final i in poolBase) if (cat.item(i)!.raridade == rar && !out.contains(i)) i];
      if (sub.isEmpty) sub = [for (final i in poolBase) if (!out.contains(i)) i];
      if (sub.isEmpty) break;
      out.add(sub[(r() * sub.length).floor()]);
    }
    return out;
  }

  final outros = sortear([for (final i in pool) if (cat.item(i)!.tipo != 'cons') i], vagas - nCons);
  final poolEquip = [for (final i in pool) if (cat.item(i)!.tipo != 'cons') i];
  var raros = outros.where((i) => cat.item(i)!.raridade >= 2).length;
  for (var k = outros.length - 1; k >= 0 && raros < Eco.lojaRarosMin; k--) {
    if (cat.item(outros[k])!.raridade >= 2) continue;
    final cand = [for (final i in poolEquip) if (cat.item(i)!.raridade == 2 && !outros.contains(i)) i];
    if (cand.isEmpty) break;
    outros[k] = cand[(r() * cand.length).floor()];
    raros++;
  }
  final cons = sortear([for (final i in pool) if (cat.item(i)!.tipo == 'cons') i], nCons);
  final ids = [...outros, ...cons];
  final iOferta = ids.isNotEmpty ? (r() * ids.length).floor() : -1;
  return [for (var i = 0; i < ids.length; i++) VagaLoja(ids[i], i == iOferta)];
}
