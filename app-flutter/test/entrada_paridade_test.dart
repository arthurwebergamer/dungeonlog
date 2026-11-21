// Paridade com o JS (fixture gerado por tools/gerar_casos_js.mjs): idioma padrão do aparelho e posição do cartão do tour.
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dungeonlog_flutter/dominio/entrada.dart';
import 'package:dungeonlog_flutter/dominio/tutorial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final j = jsonDecode(File('test/fixtures/casos_js.json').readAsStringSync()) as Map<String, dynamic>;
  final ent = j['entrada'] as Map<String, dynamic>;

  test('idioma padrão do aparelho: igual ao script do <head> do original', () {
    final casos = ent['idioma'] as List;
    expect(casos.length, greaterThan(10));
    for (final c in casos) {
      final langs = [for (final l in c['langs'] as List) l as String];
      expect(idiomaPadraoDoAparelho(langs), c['idioma'], reason: 'idiomas $langs');
    }
  });

  test('cartão do tour: mesma posição que tourPosicionar (${(ent['cartao'] as List).length} casos)', () {
    var base = 0, topo = 0, numerico = 0, largo = 0;
    for (final c in ent['cartao'] as List) {
      final rects = [for (final r in c['rects'] as List) Rect.fromLTRB((r['left'] as num).toDouble(), (r['top'] as num).toDouble(), (r['right'] as num).toDouble(), (r['bottom'] as num).toDouble())];
      final r = c['r'] as Map<String, dynamic>;
      final alvo = Rect.fromLTRB((r['left'] as num).toDouble(), (r['top'] as num).toDouble(), (r['right'] as num).toDouble(), (r['bottom'] as num).toDouble());
      final p = posicionarCartaoTour(larguraTela: (c['W'] as num).toDouble(), alturaTela: (c['H'] as num).toDouble(), alturaCartao: (c['ch'] as num).toDouble(), alvo: alvo, alvos: rects);
      final s = c['saida'] as Map<String, dynamic>;
      final msg = 'caso $c';
      expect(p.largura, (s['cw'] as num).toDouble(), reason: msg);
      expect(p.largo, s['largo'], reason: msg);
      expect(p.esquerda, (s['nl'] as num).toDouble(), reason: msg);
      final nt = s['nt'];
      if (nt == 'auto') {
        base++;
        expect(p.base != null && p.safeBase, isTrue, reason: msg);
      } else if (nt is String) {
        topo++;
        expect(p.safeTopo, isTrue, reason: msg); // 'calc(12px + env(safe-area-inset-top))'
      } else {
        numerico++;
        expect(p.topo, (nt as num).toDouble(), reason: msg);
        expect(p.safeTopo || p.safeBase, isFalse, reason: msg);
      }
      if (s['largo'] == true) largo++;
    }
    // o gerador cobre todos os ramos
    expect(base, greaterThan(0));
    expect(topo, greaterThan(0));
    expect(numerico, greaterThan(0));
    expect(largo, greaterThan(0));
  });
}
