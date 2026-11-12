// Baú trancado (especial), baú extra (afixo Abundante), garantia (pity) e chaves. Espelha play/index.html:
// PITY_BAU_ESPECIAL/chanceBauTrancado/tierBauNecessario (~2692 a 2721), chaveParaDestravar (~8366),
// sortearGanhos (~8536), gerarEstadoBauDia (~9170). A ordem dos sorteios é a do JS (testada com sequência gravada).
import 'catalogo.dart';
import 'economia.dart';
import 'loot.dart';

const int pityBauEspecial = 6;
const List<double> pesoTierEspecial = [5, 15, 35, 45];
const List<int> tierRar = [0, 1, 2, 4]; // tier da chave -> raridade mínima da chave
const List<int> rarMinimaPorTier = [1, 2, 4, 5]; // raridade garantida no baú especial: Incomum, Raro, Épico, Lendário

/// `mediaDifHoje()`: média dos losangos (1 a 4) das tarefas de hoje; null se não há tarefa.
double? mediaDif(List<int> pips) => pips.isEmpty ? null : pips.fold<int>(0, (a, b) => a + b) / pips.length;

double fatorDif(double media) => ((media - 1) / 3).clamp(0.0, 1.0).toDouble();

/// `chanceBauTrancado(media)`. [afixoBau]: soma do afixo Caçador de Baús; [bonusFortuna]: 0 no app atual.
double chanceBauTrancado(double? media, {int afixoBau = 0, double bonusFortuna = 0}) {
  if (media == null) return 0;
  final f = fatorDif(media);
  final v = Eco.chanceBauTrancadoMin +
      (Eco.chanceBauTrancadoMax - Eco.chanceBauTrancadoMin) * f +
      bonusFortuna * 0.5 +
      afixoBau / 100;
  return v < 0.95 ? v : 0.95;
}

/// `tierBauNecessario(media)`: 0 a 3, pesado para cima.
int tierBauNecessario(double? media, Aleatorio r) {
  final empurrao = media == null ? 0.0 : fatorDif(media);
  final pesos = [for (var i = 0; i < pesoTierEspecial.length; i++) pesoTierEspecial[i] + empurrao * i * 8];
  final total = pesos.fold<double>(0, (a, b) => a + b);
  var x = r() * total;
  for (var i = 0; i < pesos.length; i++) {
    x -= pesos[i];
    if (x <= 0) return i;
  }
  return pesos.length - 1;
}

/// `sortearGanhos(nTarefas, bonusSorte, rarMinima)`: escolhe os itens sem creditar.
List<int> sortearGanhos(Catalogo cat, Aleatorio r,
    {required int nTarefas,
    required int estagio,
    double bonusSorte = 0,
    int? rarMinima,
    int afixoTes = 0,
    int afixoTex = 0}) {
  final le = lootDoEstagio(estagio, r);
  final sorte = (nTarefas / 10 + bonusSorte + le.bonus).clamp(double.negativeInfinity, 1.0).toDouble();
  final ids = <int>[];
  for (var i = 0; i < le.qtd; i++) {
    ids.add(sortearItem(cat, r, sorte, afixoTes: afixoTes));
  }
  final tx = tesouroExtra(cat, r, sorte, afixoTex: afixoTex);
  if (tx != null) ids.add(tx);
  if (rarMinima != null) {
    var pior = 0;
    for (var i = 1; i < ids.length; i++) {
      if (cat.item(ids[i])!.raridade < cat.item(ids[pior])!.raridade) pior = i;
    }
    if (cat.item(ids[pior])!.raridade < rarMinima) {
      final pool = [for (var i = 0; i < cat.baseN; i++) if (cat.item(i)!.raridade >= rarMinima && !cat.item(i)!.morto) i];
      if (pool.isNotEmpty) ids[pior] = comAfixo(cat, pool[(r() * pool.length).floor()], r);
    }
  }
  return ids;
}

class BauDiaGerado {
  /// `{dia, padrao:{ids,aberto}, especial:{ids,tier,aberto}|null, extra:{ids,aberto}|null}`
  final Map<String, dynamic> estado;

  /// Novo valor do contador de garantia (`questlog.bauSemEspecial.v1`).
  final int pity;

  /// Ids a creditar já: padrão e extra (o especial só entra ao destrancar).
  final List<int> creditar;
  const BauDiaGerado(this.estado, this.pity, this.creditar);
}

/// `gerarEstadoBauDia(dia, nTarefas)`. [media] = `mediaDifHoje()`; [pityAtual] = dias sem baú especial.
BauDiaGerado gerarBauDia(Catalogo cat, Aleatorio r,
    {required String dia,
    required int nTarefas,
    required int estagio,
    required double? media,
    required int pityAtual,
    int afixoTes = 0,
    int afixoTex = 0,
    int afixoBau = 0,
    int afixoAbu = 0}) {
  final padrao = sortearLootDoDia(cat, r, nTarefas: nTarefas, estagio: estagio, afixoTes: afixoTes, afixoTex: afixoTex);
  final sorteado = pityAtual >= pityBauEspecial || r() < chanceBauTrancado(media, afixoBau: afixoBau);
  Map<String, dynamic>? especial;
  if (sorteado) {
    final tier = tierBauNecessario(media, r);
    especial = {
      'ids': sortearGanhos(cat, r,
          nTarefas: nTarefas,
          estagio: estagio,
          bonusSorte: 0.35 + tier * 0.15,
          rarMinima: rarMinimaPorTier[tier],
          afixoTes: afixoTes,
          afixoTex: afixoTex),
      'tier': tier,
      'aberto': false,
    };
  }
  Map<String, dynamic>? extra;
  List<int> idsExtra = const [];
  if (r() * 100 < afixoAbu) {
    idsExtra = sortearLootDoDia(cat, r, nTarefas: nTarefas, estagio: estagio, afixoTes: afixoTes, afixoTex: afixoTex);
    extra = {'ids': idsExtra, 'aberto': false};
  }
  return BauDiaGerado(
    {
      'dia': dia,
      'padrao': {'ids': padrao, 'aberto': false},
      'especial': especial,
      'extra': extra,
    },
    sorteado ? 0 : pityAtual + 1,
    [...padrao, ...idsExtra],
  );
}

/// `chaveParaDestravar(tierMin)`: chave de MENOR raridade suficiente no inventário (nunca o Grimório); null se não há.
int? chaveParaDestravar(Catalogo cat, List<Map<String, dynamic>> inventario, int tier) {
  final candidatas = <ItemCatalogo>[];
  for (final sl in inventario) {
    final it = cat.item(sl['id']);
    if (it == null) continue;
    if (((sl['q'] as num?) ?? 0) > 0 && it.tipo == 'chave' && it.nome != 'Grimório' && it.raridade >= tierRar[tier]) {
      candidatas.add(it);
    }
  }
  if (candidatas.isEmpty) return null;
  var melhor = candidatas.first; // menor raridade; no empate vale a primeira do inventário (sort estável do JS)
  for (final c in candidatas.skip(1)) {
    if (c.raridade < melhor.raridade) melhor = c;
  }
  return melhor.id;
}
