// Ícones do app original, redesenhados a partir dos SVG inline de play/index.html (viewBox 24x24).
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum IconeApp { tarefas, inventario, loja, perfil, estatisticas, check, alca, lua }

class Icone extends StatelessWidget {
  const Icone(this.icone, {super.key, this.tamanho = 26, this.cor = Colors.white});
  final IconeApp icone;
  final double tamanho;
  final Color cor;
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(tamanho), painter: _PintorIcone(icone, cor));
}

class _PintorIcone extends CustomPainter {
  _PintorIcone(this.icone, this.cor);
  final IconeApp icone;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final cheio = Paint()..color = cor;
    Paint traco(double l) => Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = l
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (icone) {
      case IconeApp.tarefas: // quadrado cheio com o "check" vazado
        final p = Path()
          ..fillType = PathFillType.evenOdd
          ..addRRect(RRect.fromLTRBR(3, 4, 21, 20, const Radius.circular(1)))
          ..moveTo(10.7, 16.2)
          ..relativeLineTo(-3.4, -3.4)
          ..relativeLineTo(1.4, -1.4)
          ..relativeLineTo(2, 2)
          ..relativeLineTo(4.6, -4.6)
          ..relativeLineTo(1.4, 1.4)
          ..close();
        canvas.drawPath(p, cheio);
      case IconeApp.inventario: // sacola
        final t = traco(2.2);
        canvas.drawPath(Path()..moveTo(5, 8)..lineTo(19, 8)..lineTo(20, 20)..lineTo(4, 20)..close(), t);
        canvas.drawPath(Path()..moveTo(9, 8)..lineTo(9, 6)..arcToPoint(const Offset(15, 6), radius: const Radius.circular(3))..lineTo(15, 8), t);
      case IconeApp.loja: // carrinho
        final t = traco(2.2);
        canvas.drawCircle(const Offset(9, 20), 1.6, t);
        canvas.drawCircle(const Offset(18, 20), 1.6, t);
        canvas.drawPath(
            Path()
              ..moveTo(2, 3)
              ..lineTo(5, 3)
              ..lineTo(7.6, 15.4)
              ..arcToPoint(const Offset(9.6, 17), radius: const Radius.circular(2), clockwise: false)
              ..lineTo(17.8, 17)
              ..arcToPoint(const Offset(19.8, 15.4), radius: const Radius.circular(2), clockwise: false)
              ..lineTo(21.5, 7)
              ..lineTo(6, 7),
            t);
      case IconeApp.perfil:
        final t = traco(2.2);
        canvas.drawCircle(const Offset(12, 8), 4, t);
        canvas.drawPath(Path()..moveTo(4, 21)..cubicTo(4, 17, 8, 15, 12, 15)..cubicTo(16, 15, 20, 17, 20, 21), t);
      case IconeApp.estatisticas: // três barras
        final t = traco(2.2);
        canvas.drawLine(const Offset(4, 20), const Offset(4, 10), t);
        canvas.drawLine(const Offset(12, 20), const Offset(12, 4), t);
        canvas.drawLine(const Offset(20, 20), const Offset(20, 13), t);
      case IconeApp.check:
        canvas.drawPath(Path()..moveTo(20, 6)..lineTo(9, 17)..lineTo(4, 12), traco(4));
      case IconeApp.lua: // minguante fino, como o caractere da lua do botão de descanso
        canvas.drawPath(
            Path.combine(PathOperation.difference, Path()..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9)),
                Path()..addOval(Rect.fromCircle(center: const Offset(16.4, 12), radius: 8.8))),
            cheio);
      case IconeApp.alca: // seis pontos (alça de arrastar)
        for (final x in const [9.0, 15.0]) {
          for (final y in const [6.0, 12.0, 18.0]) {
            canvas.drawCircle(Offset(x, y), 1.6, cheio);
          }
        }
    }
  }

  @override
  bool shouldRepaint(_PintorIcone o) => o.icone != icone || o.cor != cor;
}

/// Losangos de dificuldade: quadrados de 6px girados 45°, com 3px de vão (`.difpip i`).
class Losangos extends StatelessWidget {
  const Losangos(this.pips, {super.key, required this.cor});
  final int pips;
  final Color cor;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: pips * 6.0 + (pips - 1) * 3.0,
        height: 6,
        child: Row(children: [
          for (var i = 0; i < pips; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(width: 6, height: 6, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(1))),
            ),
          ],
        ]),
      );
}

/// Imagem em pixel art (sem suavização).
Widget pixel(String caminho, {double? largura, double? altura, BoxFit fit = BoxFit.contain}) => Image.asset(
      caminho,
      width: largura,
      height: altura,
      fit: fit,
      filterQuality: FilterQuality.none,
      gaplessPlayback: true,
    );
