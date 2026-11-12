// Respiração dos monstros: cada espécie tem um movimento próprio em laço (`.gvm-*` em play/style.css, extraído para
// assets/dados/respiracao.json por tools/extrair_assets.mjs). A família vem do nome em inglês (`familia()` do original),
// o movimento gira em volta da base do sprite (transform-origin: 50% 100%) e o easing é `steps(n)` por intervalo.
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

class _Quadro {
  const _Quadro(this.p, this.tx, this.ty, this.rot, this.sx, this.sy, this.op);
  final double p, tx, ty, rot, sx, sy, op;
}

class _Familia {
  const _Familia(this.dur, this.passos, this.quadros);
  final double dur; // segundos
  final int passos;
  final List<_Quadro> quadros;
}

class Respiracao {
  Respiracao._();
  static Map<String, _Familia> _dados = {};

  static Future<void> carregar([AssetBundle? bundle]) async {
    final j = jsonDecode(await (bundle ?? rootBundle).loadString('assets/dados/respiracao.json')) as Map<String, dynamic>;
    _dados = {
      for (final e in j.entries)
        e.key: _Familia(
          (e.value['dur'] as num).toDouble(),
          (e.value['passos'] as num).toInt(),
          [
            for (final q in e.value['quadros'] as List)
              _Quadro((q['p'] as num).toDouble(), (q['tx'] as num).toDouble(), (q['ty'] as num).toDouble(), (q['rot'] as num).toDouble(),
                  (q['sx'] as num).toDouble(), (q['sy'] as num).toDouble(), (q['op'] as num).toDouble()),
          ],
        ),
    };
  }

  /// `familia(nomeEn)` do original: a primeira espécie que combina; "olho" quando nenhuma combina.
  static String familiaDe(String nomeEn) {
    const tabela = [
      ('mimic', r'Mimic'),
      ('verme', r'Worm'),
      ('gosma', r'Slime'),
      ('morcego', r'\bBat\b'),
      ('rato', r'\bRat\b'),
      ('aranha', r'Spider'),
      ('olho', r'\bEye\b'),
      ('golem', r'Golem'),
      ('goblin', r'Goblin'),
      ('espectro', r'Specter|Spirit|Soul'),
      ('demonio', r'Demon'),
      ('cogumelo', r'Mushroom|Fungus'),
      ('esqueleto', r'Skeleton|Skull|Bones'),
    ];
    for (final (k, re) in tabela) {
      if (RegExp(re, caseSensitive: false).hasMatch(nomeEn)) return k;
    }
    return 'olho';
  }

  /// Envolve o sprite no movimento da [familia] no instante [ms] (relógio contínuo).
  static Widget aplicar(String familia, double ms, Widget filho) {
    final f = _dados[familia];
    if (f == null || f.quadros.length < 2) return filho;
    final p = ((ms / 1000) % f.dur) / f.dur;
    final q = f.quadros;
    var a = q.first, b = q.last;
    var u = 0.0;
    if (p <= q.first.p) {
      b = a;
    } else {
      for (var i = 0; i < q.length - 1; i++) {
        if (p <= q[i + 1].p) {
          a = q[i];
          b = q[i + 1];
          u = b.p == a.p ? 1 : (p - a.p) / (b.p - a.p);
          break;
        }
      }
      if (p > q.last.p) a = b = q.last;
    }
    final e = (u * f.passos).floor() / f.passos; // steps(n, end) em cada intervalo
    double l(double x, double y) => x + (y - x) * e;
    final m = Matrix4.identity()
      ..translateByDouble(l(a.tx, b.tx), l(a.ty, b.ty), 0, 1)
      ..rotateZ(l(a.rot, b.rot) * math.pi / 180)
      ..scaleByDouble(l(a.sx, b.sx), l(a.sy, b.sy), 1, 1);
    final op = l(a.op, b.op);
    final corpo = Transform(transform: m, alignment: Alignment.bottomCenter, child: filho);
    return op >= 0.999 ? corpo : Opacity(opacity: op.clamp(0.0, 1.0), child: corpo);
  }
}
