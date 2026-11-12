// Explosão de confete do popup do baú (`spawnParticulas` do original): 22 retângulos 6x10 que saem do centro em
// direções aleatórias (50 a 120 px), giram até ±360° e encolhem para 40% enquanto somem, em 0,9 s (curva "expo").
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ExplosaoParticulas extends StatefulWidget {
  const ExplosaoParticulas({super.key, this.cores = const [Color(0xFFF2C94C), Color(0xFFF2A65A), Color(0xFFE8D48A)], this.qtd = 22});
  final List<Color> cores;
  final int qtd;
  @override
  State<ExplosaoParticulas> createState() => _ExplosaoParticulasState();
}

class _ExplosaoParticulasState extends State<ExplosaoParticulas> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final List<(double, double, double)> _p = () {
    final r = math.Random();
    return [
      for (var i = 0; i < widget.qtd; i++) (r.nextDouble() * math.pi * 2, 50 + r.nextDouble() * 70, (r.nextDouble() * 720 - 360) * math.pi / 180),
    ];
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(painter: _Pintor(_p, widget.cores, Curves.easeOutExpo.transform(_c.value))),
        ),
      );
}

class _Pintor extends CustomPainter {
  _Pintor(this.p, this.cores, this.t);
  final List<(double, double, double)> p;
  final List<Color> cores;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    for (var i = 0; i < p.length; i++) {
      final (ang, dist, rot) = p[i];
      final pos = centro + Offset(math.cos(ang), math.sin(ang)) * dist * t;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rot * t);
      final escala = 1 - 0.6 * t;
      final paint = Paint()..color = cores[i % cores.length].withValues(alpha: 1 - t);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 6 * escala, height: 10 * escala), const Radius.circular(1)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Pintor o) => o.t != t;
}
