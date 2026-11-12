// Paridade do loot: o JS sorteou com uma sequência gravada de Math.random; o Dart recebe a MESMA sequência
// e precisa escolher os mesmos ids, consumindo exatamente a mesma quantidade de números.
import 'dart:convert';
import 'dart:io';

import 'package:dungeonlog_flutter/dominio/catalogo.dart';
import 'package:dungeonlog_flutter/dominio/loot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final casos = jsonDecode(File('test/fixtures/casos_js.json').readAsStringSync()) as Map<String, dynamic>;
  final linhas = ((jsonDecode(File('assets/dados/itens.json').readAsStringSync()) as Map)['linhas'] as List)
      .map((l) => List<dynamic>.from(l as List))
      .toList();
  final loot = (casos['loot'] as List).cast<Map<String, dynamic>>();

  test('há casos de loot nos fixtures', () => expect(loot.length, 400));

  for (var n = 0; n < loot.length; n++) {
    final c = loot[n];
    test('loot #$n (modo ${c['modo']})', () {
      final cat = Catalogo.deLinhas(linhas);
      final seq = (c['usados'] as List).map((e) => (e as num).toDouble()).toList();
      var i = 0;
      double r() {
        if (i >= seq.length) fail('o Dart pediu mais números aleatórios que o JS (${seq.length})');
        return seq[i++];
      }

      final sorte = (c['sorte'] as num).toDouble();
      final tes = (c['tes'] as num).toInt(), tex = (c['tex'] as num).toInt();
      late List<int> ids;
      switch (c['modo'] as int) {
        case 0:
          ids = [sortearItem(cat, r, sorte, afixoTes: tes)];
        case 1:
          ids = [sortearItem(cat, r, sorte, permitirLendario: false, afixoTes: tes)];
        case 2:
          final t = tesouroExtra(cat, r, sorte, afixoTex: tex);
          ids = t == null ? [] : [t];
        default:
          ids = sortearLootDoDia(cat, r,
              nTarefas: (c['nTarefas'] as num).toInt(), estagio: (c['estagio'] as num).toInt(), afixoTes: tes, afixoTex: tex);
      }
      expect(ids, (c['ids'] as List).cast<int>());
      expect(i, seq.length, reason: 'mesma quantidade de números consumidos');
      expect(jsonDecode(jsonEncode(cat.exportarVariantes())), c['vars']);
    });
  }
}
