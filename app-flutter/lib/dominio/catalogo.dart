// Catálogo de itens e "variantes" (equipamento com afixo/forja). Espelha ITENS, variante(), restaurarVariantes()
// e afins de play/index.html (~3188 a 3253).
//
// O id de um item no inventário é o índice dele neste catálogo. Os ids >= baseN são variantes criadas em
// tempo de execução; o save guarda a lista delas (`variantes`) e o app reconstrói NA MESMA ORDEM ao carregar,
// então a ordem de criação precisa ser idêntica à do JS.
import 'economia.dart';
import 'js_compat.dart';

class Afixo {
  final String tipo;
  final int valor;
  const Afixo(this.tipo, this.valor);
  @override
  bool operator ==(Object o) => o is Afixo && o.tipo == tipo && o.valor == valor;
  @override
  int get hashCode => Object.hash(tipo, valor);
}

class ItemCatalogo {
  final int id;
  final int sprite;
  final String nome;
  final String tipo;
  final int raridade;
  final int valor;
  final num bonusMoedas;
  final num bonusXp;
  final int cura;
  final bool morto;
  final String? nomeEn;
  final Afixo? afixo;
  final int rer; // quantas vezes passou pela forja
  final int base; // id do item de origem (o próprio id nos itens base)
  final bool ehVariante;

  const ItemCatalogo({
    required this.id,
    required this.sprite,
    required this.nome,
    required this.tipo,
    required this.raridade,
    required this.valor,
    required this.bonusMoedas,
    required this.bonusXp,
    required this.cura,
    required this.morto,
    required this.nomeEn,
    required this.afixo,
    required this.rer,
    required this.base,
    required this.ehVariante,
  });

  /// Linha do `itens.json` (formato de ITENS: sprite, nome, tipo, raridade, valor, bonusMoedas, bonusXp, cura, morto, nome_en).
  factory ItemCatalogo.deLinha(int id, List<dynamic> r) => ItemCatalogo(
        id: id,
        sprite: (r[0] as num).toInt(),
        nome: r[1] as String,
        tipo: r[2] as String,
        raridade: (r[3] as num).toInt(),
        valor: (r[4] as num).toInt(),
        bonusMoedas: r[5] as num,
        bonusXp: r[6] as num,
        cura: numeroOu0(r.length > 7 ? r[7] : 0).toInt(),
        morto: _verdadeiro(r.length > 8 ? r[8] : null),
        nomeEn: r.length > 9 && r[9] is String ? r[9] as String : null,
        afixo: null,
        rer: 0,
        base: id,
        ehVariante: false,
      );

  static bool _verdadeiro(Object? v) => v == true || (v is num && v != 0) || (v is String && v.isNotEmpty);

  String nomeNoIdioma(String idioma) => (idioma == 'en' && nomeEn != null) ? nomeEn! : nome;
}

class Catalogo {
  final List<ItemCatalogo> _itens;
  final int baseN;
  final Map<String, int> _varMapa = {};

  Catalogo._(this._itens) : baseN = _itens.length;

  factory Catalogo.deLinhas(List<List<dynamic>> linhas) =>
      Catalogo._([for (var i = 0; i < linhas.length; i++) ItemCatalogo.deLinha(i, linhas[i])]);

  int get tamanho => _itens.length;

  bool existe(Object? id) => id is num && id == id.toInt() && id >= 0 && id < _itens.length;

  /// `item(id)`; null se o id não existe.
  ItemCatalogo? item(Object? id) => existe(id) ? _itens[(id as num).toInt()] : null;

  /// Tipos de afixo válidos (`AFIXOS[...]`).
  bool afixoValido(Object? k) => k is String && afixoChaves.contains(k);

  bool ehEquipBase(int id) {
    final it = item(id);
    return it != null && id < baseN && !it.morto && slotsEquip.contains(it.tipo);
  }

  /// `baseDe(id)`
  int baseDe(int id) => item(id)?.base ?? id;

  /// `variante(baseId, afx, rer)`: cria (ou reaproveita) a variante e devolve o id.
  int variante(int baseId, Afixo? afx, [num? rer]) {
    final r = numeroOu0(rer).toInt();
    final chave = '$baseId|${afx != null ? '${afx.tipo}|${afx.valor}' : 'sem'}|$r';
    final existente = _varMapa[chave];
    if (existente != null) return existente;
    final o = _itens[baseId];
    final id = _itens.length;
    _itens.add(ItemCatalogo(
      id: id, sprite: o.sprite, nome: o.nome, tipo: o.tipo, raridade: o.raridade, valor: o.valor,
      bonusMoedas: o.bonusMoedas, bonusXp: o.bonusXp, cura: o.cura, morto: o.morto, nomeEn: o.nomeEn,
      afixo: afx, rer: r, base: baseId, ehVariante: true,
    ));
    return _varMapa[chave] = id;
  }

  void limparVariantes() {
    _itens.removeRange(baseN, _itens.length);
    _varMapa.clear();
  }

  /// `exportarVariantes()`: `[base, tipoAfixo|null, valor, rer]` na ordem de criação.
  List<List<dynamic>> exportarVariantes() => [
        for (final it in _itens.skip(baseN))
          [it.base, it.afixo?.tipo, it.afixo?.valor ?? 0, it.rer],
      ];

  /// `restaurarVariantes(lista)`: ignora entradas inválidas, como o JS.
  void restaurarVariantes(Object? lista) {
    limparVariantes();
    if (lista is! List) return;
    for (final v in lista) {
      if (v is! List || v.length < 2) continue;
      if (!existe(v[0])) continue;
      final k = v[1];
      if (!(k == null || afixoValido(k))) continue;
      final valor = v.length > 2 ? numeroOu0(v[2]).toInt() : 0;
      final rer = v.length > 3 ? v[3] : null;
      variante((v[0] as num).toInt(), k == null ? null : Afixo(k as String, valor), rer is num ? rer : numeroOu0(rer));
    }
  }
}
