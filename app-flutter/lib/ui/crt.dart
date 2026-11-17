// Efeito CRT (Configurações > Preferências), a camada `:root[data-crt="1"]::after` do original: linhas de varredura, franjas
// vermelha/verde/azul, vinheta nas bordas e uma leve cintilação a cada 4 s. Fica por cima de tudo e não recebe toques.
// O que NÃO foi portado: a sombra cromática do texto e o `backdrop-filter` de saturação (desfoque/filtro de fundo travava
// o celular nas outras telas, então não foi usado).
import 'package:flutter/material.dart';

class CamadaCrt extends StatefulWidget {
  const CamadaCrt({super.key});
  @override
  State<CamadaCrt> createState() => _CamadaCrtState();
}

class _CamadaCrtState extends State<CamadaCrt> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// `crtFlicker`: opacidade em degraus (1, .9, 1, .93, 1, .91, 1) ao longo dos 4 s.
  static double _opacidade(double t) {
    if (t >= 0.07 && t < 0.08) return 0.9;
    if (t >= 0.44 && t < 0.46) return 0.93;
    if (t >= 0.81 && t < 0.82) return 0.91;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final camada = const RepaintBoundary(child: CustomPaint(painter: _PintorCrt(), size: Size.infinite));
    return IgnorePointer(
      child: reduzir
          ? camada
          : AnimatedBuilder(animation: _c, child: camada, builder: (_, f) => Opacity(opacity: _opacidade(_c.value), child: f)),
    );
  }
}

class _PintorCrt extends CustomPainter {
  const _PintorCrt();
  @override
  void paint(Canvas canvas, Size size) {
    // repeating-linear-gradient(0deg, rgba(0,0,0,.26) 0 1px, transparent 1px 3px)
    final linha = Paint()..color = const Color(0x42000000);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), linha);
    }
    // repeating-linear-gradient(90deg, vermelho .06 0 1px, verde .04 1px 2px, azul .06 2px 3px)
    final r = Paint()..color = const Color(0x0FFF0000);
    final g = Paint()..color = const Color(0x0A00FF00);
    final b = Paint()..color = const Color(0x0F0050FF);
    for (var x = 0.0; x < size.width; x += 3) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), r);
      canvas.drawRect(Rect.fromLTWH(x + 1, 0, 1, size.height), g);
      canvas.drawRect(Rect.fromLTWH(x + 2, 0, 1, size.height), b);
    }
    // box-shadow: inset 0 0 90px 4px rgba(0,0,0,.35): vinheta nas bordas
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: const [Color(0x00000000), Color(0x00000000), Color(0x59000000)],
          stops: const [0, 0.62, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_PintorCrt old) => false;
}
