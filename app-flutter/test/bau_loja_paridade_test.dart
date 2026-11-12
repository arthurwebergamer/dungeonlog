// Paridade do baú do dia (padrão/especial/extra/pity), chaves, loja e forja contra o JS (ver tools/gerar_casos_js.mjs).
import 'dart:convert';
import 'dart:io';

import 'package:dungeonlog_flutter/dominio/bau.dart';
import 'package:dungeonlog_flutter/dominio/catalogo.dart';
import 'package:dungeonlog_flutter/dominio/economia.dart';
import 'package:dungeonlog_flutter/dominio/forja.dart';
import 'package:dungeonlog_flutter/dominio/loja.dart';
import 'package:dungeonlog_flutter/dominio/loot.dart';
import 'package:dungeonlog_flutter/dominio/regras.dart';
import 'package:flutter_test/flutter_test.dart';

Aleatorio _sequencia(List<dynamic> usados) {
  final seq = usados.map((e) => (e as num).toDouble()).toList();
  var i = 0;
  return () {
    if (i >= seq.length) fail('o Dart pediu mais números aleatórios que o JS (${seq.length})');
    return seq[i++];
  };
}

void main() {
  final casos = jsonDecode(File('test/fixtures/casos_js.json').readAsStringSync()) as Map<String, dynamic>;
  final linhas = ((jsonDecode(File('assets/dados/itens.json').readAsStringSync()) as Map)['linhas'] as List)
      .map((l) => List<dynamic>.from(l as List))
      .toList();
  Catalogo novoCat() => Catalogo.deLinhas(linhas);
  final pipsDe = {for (final d in dificuldades) d.id: d.pips};

  group('baú do dia (gerarEstadoBauDia)', () {
    final lista = (casos['bauDia'] as List).cast<Map<String, dynamic>>();
    test('300 casos nos fixtures', () => expect(lista.length, 300));
    for (var n = 0; n < lista.length; n++) {
      final c = lista[n];
      test('baú #$n', () {
        final cat = novoCat();
        final r = _sequencia(c['usados'] as List);
        final afx = c['afx'] as Map<String, dynamic>;
        final pips = [for (final d in (c['difs'] as List)) pipsDe[d]!];
        final media = mediaDif(pips);
        expect(media, c['media'] == null ? isNull : closeTo((c['media'] as num).toDouble(), 1e-12));
        final g = gerarBauDia(cat, r,
            dia: '2026-11-11',
            nTarefas: pips.length,
            estagio: c['estagio'] as int,
            media: media,
            pityAtual: c['pity'] as int,
            afixoTes: afx['tes'] as int,
            afixoTex: afx['tex'] as int,
            afixoBau: afx['bau'] as int,
            afixoAbu: afx['abu'] as int);
        expect(jsonDecode(jsonEncode(g.estado)), c['estado']);
        expect(g.pity, c['pityDepois']);
        // inventário que o JS montou = itens do padrão e do extra empilhados na ordem do sorteio
        final inv = <Map<String, dynamic>>[];
        for (final id in g.creditar) {
          final sl = inv.where((s) => s['id'] == id).firstOrNull;
          if (sl != null) {
            sl['q'] = (sl['q'] as int) + 1;
          } else {
            inv.add({'id': id, 'q': 1});
          }
        }
        expect(inv, (c['inventario'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList());
        expect(jsonDecode(jsonEncode(cat.exportarVariantes())), c['vars']);
      });
    }
  });

  test('chaveParaDestravar escolhe a de menor raridade suficiente', () {
    final lista = (casos['chavesBau'] as List).cast<Map<String, dynamic>>();
    expect(lista.length, 120);
    final cat = novoCat();
    for (final c in lista) {
      final inv = [for (final s in (c['inv'] as List)) Map<String, dynamic>.from(s as Map)];
      expect(chaveParaDestravar(cat, inv, c['tier'] as int), c['esperado'], reason: jsonEncode(c));
    }
  });

  group('loja', () {
    final l = casos['loja'] as Map<String, dynamic>;
    test('nível mínimo por raridade', () => expect([for (var r = 0; r < 8; r++) nivelMinimo(r)], l['nivelMinimo']));
    test('pesos por nível', () {
      final esperado = (l['pesos'] as List).map((p) => (p as List).map((x) => (x as num).toDouble()).toList()).toList();
      expect([for (var n = 1; n <= 16; n++) pesosLojaPorNivel(n)], esperado);
    });
    final lista = (l['casos'] as List).cast<Map<String, dynamic>>();
    for (var n = 0; n < lista.length; n++) {
      final c = lista[n];
      test('estoque #$n (${c['ano']}-${c['mes']}-${c['dia']}, semente ${c['sem']}, nível ${c['nivel']})', () {
        final cat = novoCat();
        expect(progresso(c['xp'] as num).nivel, c['nivel']);
        final est = montarEstoque(cat, diasCorridos: c['dc'] as int, semente: c['sem'] as int, nivel: c['nivel'] as int);
        expect([for (final v in est) {'id': v.id, 'o': v.oferta}], c['estoque']);
        final desc = (c['desc'] as num).toDouble();
        expect([for (final v in est) precoLoja(cat.item(v.id)!, v.oferta, desconto: desc)], c['precos']);
      });
    }
  });

  group('forja', () {
    final lista = (casos['forja'] as List).cast<Map<String, dynamic>>();
    for (var n = 0; n < lista.length; n++) {
      final c = lista[n];
      test('forja #$n', () {
        final cat = novoCat();
        final sel = (c['sel'] as List).cast<int>();
        expect(pNegForja(cat, sel), closeTo((c['pn'] as num).toDouble(), 1e-12));
        final r = _sequencia(c['usados'] as List);
        final a = afixoRolar(c['rar'] as int, c['excl'] as String?, (c['pn'] as num).toDouble(), r);
        expect([a.tipo, a.valor], c['afx']);
      });
    }
    test('custo da forja', () => expect([for (var i = 0; i < 5; i++) custoForja(i)], [1, 2, 3, 3, 3]));
  });
}
