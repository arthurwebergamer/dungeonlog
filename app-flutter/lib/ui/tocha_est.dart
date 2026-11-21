// A tocha das Estatísticas (`.est-tocha` do original): o mesmo sprite da tocha da arena (assets/img/ui/tocha_esq.png,
// folha 48x32 com 3 quadros de 16x32), ampliada por `escala` sem suavização. Variantes do CSS:
//  - acesa: a chama em laço (`animation: tochaChama .6s steps(3) infinite`) ou parada no 2º quadro (`.est-tocha-estatica`);
//  - apagada (`.est-tocha-apagada`): cinza e escurecida (`grayscale(1) brightness(.55)`), só a parte de baixo aparece
//    (`clip-path: inset(56% 0 0 0)`);
//  - descanso (`.est-tocha-descanso`): `hue-rotate(190deg) saturate(1.15) brightness(1.05)`, a tocha azul.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'icones.dart' show pixel;

const String folhaTochaEst = 'assets/img/ui/tocha_esq.png';

enum VarianteTocha { acesa, apagada, descanso }

/// Matriz 3x3 (linhas de RGB) -> `ColorFilter.matrix` de 4x5.
ColorFilter _filtro(List<List<double>> m) => ColorFilter.matrix([
      m[0][0], m[0][1], m[0][2], 0, 0, //
      m[1][0], m[1][1], m[1][2], 0, 0,
      m[2][0], m[2][1], m[2][2], 0, 0,
      0, 0, 0, 1, 0,
    ]);

List<List<double>> _mul(List<List<double>> a, List<List<double>> b) => [
      for (var i = 0; i < 3; i++) [for (var j = 0; j < 3; j++) a[i][0] * b[0][j] + a[i][1] * b[1][j] + a[i][2] * b[2][j]],
    ];

/// `hue-rotate(graus)` do CSS (matriz da especificação de filtros).
List<List<double>> _matizCss(double graus) {
  final a = graus * math.pi / 180, c = math.cos(a), s = math.sin(a);
  return [
    [0.213 + c * 0.787 - s * 0.213, 0.715 - c * 0.715 - s * 0.715, 0.072 - c * 0.072 + s * 0.928],
    [0.213 - c * 0.213 + s * 0.143, 0.715 + c * 0.285 + s * 0.140, 0.072 - c * 0.072 - s * 0.283],
    [0.213 - c * 0.213 - s * 0.787, 0.715 - c * 0.715 + s * 0.715, 0.072 + c * 0.928 + s * 0.072],
  ];
}

List<List<double>> _saturaCss(double s) => [
      [0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s],
      [0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s],
      [0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s],
    ];

List<List<double>> _brilhoCss(double b) => [
      [b, 0, 0],
      [0, b, 0],
      [0, 0, b],
    ];

/// `grayscale(1) brightness(.55)`.
final ColorFilter filtroTochaApagada = _filtro(_mul(_brilhoCss(0.55), [
  [0.2126, 0.7152, 0.0722],
  [0.2126, 0.7152, 0.0722],
  [0.2126, 0.7152, 0.0722],
]));

/// `hue-rotate(190deg) saturate(1.15) brightness(1.05)` (nessa ordem: o matiz é aplicado primeiro).
final ColorFilter filtroTochaDescanso = _filtro(_mul(_brilhoCss(1.05), _mul(_saturaCss(1.15), _matizCss(190))));

/// O recorte `inset(56% 0 0 0)` da tocha apagada: some a parte de cima (a chama) e fica o cabo.
class _RecorteApagada extends CustomClipper<Rect> {
  const _RecorteApagada();
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.44);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> old) => false;
}

/// Um quadro da tocha (0, 1 ou 2), de 16x32 px multiplicados por [escala].
class TochaSprite extends StatelessWidget {
  const TochaSprite({super.key, this.quadro = 1, this.escala = 1, this.variante = VarianteTocha.acesa});
  final int quadro;
  final double escala;
  final VarianteTocha variante;

  @override
  Widget build(BuildContext context) {
    final w = 16.0 * escala, h = 32.0 * escala;
    Widget t = SizedBox(
      width: w,
      height: h,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 3 * w,
          maxWidth: 3 * w,
          minHeight: h,
          maxHeight: h,
          child: Transform.translate(offset: Offset(-w * quadro, 0), child: pixel(folhaTochaEst, largura: 3 * w, altura: h, fit: BoxFit.fill)),
        ),
      ),
    );
    switch (variante) {
      case VarianteTocha.acesa:
        break;
      case VarianteTocha.apagada:
        t = ClipRect(clipper: const _RecorteApagada(), child: ColorFiltered(colorFilter: filtroTochaApagada, child: t));
      case VarianteTocha.descanso:
        t = ColorFiltered(colorFilter: filtroTochaDescanso, child: t);
    }
    return t;
  }
}

/// A tocha da chama em laço (3 quadros em 0,6 s). Pausa quando há uma folha ou diálogo por cima, para poupar quadros.
class TochaChama extends StatefulWidget {
  const TochaChama({super.key, this.escala = 1});
  final double escala;
  @override
  State<TochaChama> createState() => _TochaChamaState();
}

class _TochaChamaState extends State<TochaChama> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  int _quadro = 0;
  bool _ativa = true;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      final q = math.min(2, (_c.value * 3).floor());
      if (q != _quadro) setState(() => _quadro = q);
    });
    _c.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final atual = ModalRoute.of(context)?.isCurrent ?? true;
    if (atual != _ativa) {
      _ativa = atual;
      if (atual) {
        _c.repeat();
      } else {
        _c.stop(canceled: false);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TochaSprite(quadro: _quadro, escala: widget.escala);
}
