// Save do herói: JSON versão 3 (chave `questlog.v1`, por conta e por personagem). O Dart lê e grava o MESMO formato
// do app atual (play/index.html: salvar() ~5444 e _carregarBase() ~5502), e guarda campos desconhecidos para não perdê-los.
//
//   { versao:3, tarefas, inventario, variantes, afixos:2, equipado, xpTotal, moedas, derrotadoEm,
//     nomeHeroi, heroi, semente, salvoEm, comecou:true }
import 'dart:convert';

import 'catalogo.dart';
import 'economia.dart';
import 'js_compat.dart';
import 'regras.dart' show Equipado;
import 'tarefa.dart';

const String chaveSaveBase = 'questlog.v1';

/// `chaveSaveAtual()`: `questlog.v1[.uid.<uid>].pj.<personagem>`
String chaveSave({String? uid, String personagem = 'pj1'}) =>
    '${uid != null && uid.isNotEmpty ? '$chaveSaveBase.uid.$uid' : chaveSaveBase}.pj.$personagem';

/// `chaveConta(base)`: mesma ideia para as chaves secundárias da conta (vida, descanso, histórico...).
String chaveConta(String chaveBase, {String? uid, String personagem = 'pj1'}) =>
    '${uid != null && uid.isNotEmpty ? '$chaveBase.uid.$uid' : chaveBase}.pj.$personagem';

String nomePadraoHeroi(String idioma) => idioma == 'en' ? 'Adventurer' : 'Aventureiro';

/// `nomeHeroiNorm(n)`: o nome padrão gravado em qualquer idioma vira o do idioma atual.
String nomeHeroiNorm(Object? n, String idioma) {
  if (n == null || n == false || n == '' || n == 'Aventureiro' || n == 'Adventurer') return nomePadraoHeroi(idioma);
  return n.toString();
}

class SaveV3 {
  List<Tarefa> tarefas;
  /// Slots `{id, q, ...}`: mapas, para preservar qualquer campo extra.
  List<Map<String, dynamic>> inventario;
  Equipado equipado;
  num xpTotal;
  num moedas;
  String? derrotadoEm;
  String nomeHeroi;
  num heroi;
  int semente;

  SaveV3({
    List<Tarefa>? tarefas,
    List<Map<String, dynamic>>? inventario,
    Equipado? equipado,
    this.xpTotal = 0,
    this.moedas = 0,
    this.derrotadoEm,
    required this.nomeHeroi,
    this.heroi = 0,
    required this.semente,
  })  : tarefas = tarefas ?? [],
        inventario = inventario ?? [],
        equipado = equipado ?? {for (final s in slotsEquip) s: null};

  /// `resetarEstadoParaPadrao()`: estado de quem ainda não começou. Limpa as variantes do catálogo.
  factory SaveV3.padrao(Catalogo cat, {String idioma = 'pt', required int semente}) {
    cat.limparVariantes();
    return SaveV3(nomeHeroi: nomePadraoHeroi(idioma), semente: semente);
  }

  /// `_carregarBase()`: lê o JSON bruto. Devolve null (e o estado padrão deve ser usado) se não houver save,
  /// se `comecou` for falso ou se o JSON for inválido. [sementeAtual] vale quando o save não traz `semente` numérica.
  /// Reconstrói as variantes no [cat] (na ordem do save) e remove itens que saíram do catálogo.
  static SaveV3? carregar(String? bruto, Catalogo cat, {String idioma = 'pt', required int sementeAtual}) {
    if (bruto == null) {
      cat.limparVariantes();
      return null;
    }
    try {
      final d = jsonDecodeSeguro(bruto);
      if (d is! Map || !_verdadeiro(d['comecou'])) {
        cat.limparVariantes();
        return null;
      }
      final s = SaveV3(nomeHeroi: nomeHeroiNorm(d['nomeHeroi'], idioma), semente: sementeAtual);
      s.tarefas = d['tarefas'] is List
          ? [for (final t in d['tarefas'] as List) if (t is Map) Tarefa.deJson(Map<String, dynamic>.from(t))]
          : [];
      s.xpTotal = numeroOu0(d['xpTotal']);
      s.moedas = numeroOu0(d['moedas']);
      s.derrotadoEm = _verdadeiro(d['derrotadoEm']) ? d['derrotadoEm'].toString() : null;
      s.heroi = numeroOu0(d['heroi']);
      if (d['semente'] is num) s.semente = (d['semente'] as num).toInt();
      cat.restaurarVariantes(d['variantes']);
      s.inventario = d['inventario'] is List
          ? [for (final sl in d['inventario'] as List) if (sl is Map) Map<String, dynamic>.from(sl)]
          : [];
      if (d['equipado'] is Map) s.equipado.addAll(Map<String, dynamic>.from(d['equipado'] as Map));
      if (!_verdadeiro(d['afixos'])) s._migrarAfixos(cat); // contas antigas: cada equipamento ganha um afixo, uma única vez
      if (d['afixos'] != 2) s._limparAfixosFabrica(cat); // uma vez: tira encantamento de fábrica (afixo com 0 forjas)
      // itens removidos do catálogo (marcados "morto") saem do inventário e do equipamento
      bool morto(Object? id) {
        final it = cat.item(id);
        return it == null || it.morto;
      }

      s.inventario = [for (final sl in s.inventario) if (!morto(sl['id'])) sl];
      for (final k in slotsEquip) {
        if (s.equipado[k] != null && morto(s.equipado[k])) s.equipado[k] = null;
      }
      return s;
    } catch (_) {
      cat.limparVariantes();
      return null;
    }
  }

  static bool _verdadeiro(Object? v) => v != null && v != false && v != 0 && v != '' && !(v is double && v.isNaN);

  /// `migrarAfixos()` (contas sem o campo `afixos`). No JS cada cópia sorteia um afixo e logo em seguida
  /// `limparAfixosFabrica()` o remove; o efeito líquido é cada equipamento base virar a variante "sem afixo, 0 forjas".
  void _migrarAfixos(Catalogo cat) {
    final novo = <Map<String, dynamic>>[];
    final mapaEq = <int, int>{};
    for (final sl in inventario) {
      final id = sl['id'];
      if (id is! num || !cat.ehEquipBase(id.toInt())) {
        novo.add(sl);
        continue;
      }
      final q = numeroOu0(sl['q']).toInt();
      for (var k = 0; k < q; k++) {
        final v = cat.variante(id.toInt(), null, 0);
        mapaEq.putIfAbsent(id.toInt(), () => v);
        final e = novo.where((z) => z['id'] == v).firstOrNull;
        if (e != null) {
          e['q'] = numeroOu0(e['q']) + 1;
        } else {
          novo.add({'id': v, 'q': 1});
        }
      }
    }
    inventario = novo;
    for (final k in slotsEquip) {
      final e = equipado[k];
      if (e is num && mapaEq.containsKey(e.toInt())) equipado[k] = mapaEq[e.toInt()];
    }
  }

  /// `limparAfixosFabrica()`: variante com afixo e 0 forjas volta a ser "sem afixo".
  void _limparAfixosFabrica(Catalogo cat) {
    Object? conv(Object? id) {
      final a = cat.item(id);
      if (a != null && a.ehVariante && a.afixo != null && a.rer == 0) return cat.variante(a.base, null, 0);
      return id;
    }

    final novo = <Map<String, dynamic>>[];
    for (final sl in inventario) {
      final id = conv(sl['id']);
      final e = novo.where((z) => z['id'] == id).firstOrNull;
      if (e != null) {
        e['q'] = numeroOu0(e['q']) + numeroOu0(sl['q']);
      } else {
        novo.add({...sl, 'id': id});
      }
    }
    inventario = novo;
    for (final k in slotsEquip) {
      if (equipado[k] != null) equipado[k] = conv(equipado[k]);
    }
  }

  /// `salvar()`: o JSON exatamente como o app atual grava. [salvoEm] = carimbo em ms (quem for mais novo, local ou nuvem, vence).
  Map<String, dynamic> paraJson(Catalogo cat, {required int salvoEm}) => {
        'versao': 3,
        'tarefas': [for (final t in tarefas) t.paraJson()],
        'inventario': inventario,
        'variantes': cat.exportarVariantes(),
        'afixos': 2,
        'equipado': equipado,
        'xpTotal': normalizaNumero(xpTotal),
        'moedas': normalizaNumero(moedas),
        'derrotadoEm': derrotadoEm,
        'nomeHeroi': nomeHeroi,
        'heroi': normalizaNumero(heroi),
        'semente': semente,
        'salvoEm': salvoEm,
        'comecou': true,
      };
}

/// jsonDecode; texto inválido lança FormatException, que `SaveV3.carregar` trata como "sem save".
Object? jsonDecodeSeguro(String s) => jsonDecode(s);
