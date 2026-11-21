// Peças comuns da entrada (onboarding): cores do grafite fixas, botão principal, topo (voltar / pontos / pular) e fundos.
// Medidas lidas do CSS computado de play/index.html em 390x844 (#intro, .carrosselTopo, .primario, .carrosselDot...).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tema.dart';

// O carrossel é grafite SEMPRE (o CSS do original fixa os tons de propósito: o onboarding roda antes de escolher tema).
const onbTexto = Color(0xFFFAFAFA);
const onbMudo = Color(0xFFC2C2C2); // .obCorpo
const onbFraca = Color(0xFF9A9A9A); // .obFraca do carrossel
const onbDim = Color(0xFF909090);
const onbPainel = Color(0xFF323232); // .quizOpcao, .progressoCard
const onbLinha = Color(0xFF494949); // borda dos cartões e pontos apagados
const onbSel = Color(0xFF4A4A4A);
const onbPoco = Color(0xFF1C1C1C);
const onbFundoLogin = Color(0xFF0B0710); // #intro.loginBg

/// Curva `--spring-curve` do original.
const curvaMola = Cubic(.34, 1.56, .64, 1);

/// Curva `--expo` do original.
const curvaExpo = Cubic(.16, 1, .3, 1);

/// `linear-gradient(160deg, de, ate)` de um retângulo de [tam] (a linha do gradiente do CSS vai de canto a canto).
class FundoGradienteCss extends StatelessWidget {
  const FundoGradienteCss({super.key, required this.de, required this.ate, this.graus = 160});
  final Color de, ate;
  final double graus;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _PintorGrad(de, ate, graus), child: const SizedBox.expand());
}

class _PintorGrad extends CustomPainter {
  _PintorGrad(this.de, this.ate, this.graus);
  final Color de, ate;
  final double graus;
  @override
  void paint(Canvas canvas, Size s) {
    final a = graus * math.pi / 180;
    final dx = math.sin(a), dy = -math.cos(a);
    final len = (s.width * dx).abs() + (s.height * dy).abs();
    final c = Offset(s.width / 2, s.height / 2);
    final p0 = c - Offset(dx, dy) * (len / 2), p1 = c + Offset(dx, dy) * (len / 2);
    canvas.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(colors: [de, ate]).createShader(Rect.fromPoints(p0, p1)));
  }

  @override
  bool shouldRepaint(_PintorGrad o) => o.de != de || o.ate != ate || o.graus != graus;
}

/// Botão principal da entrada (`#intro .primario`): 44 de altura, branco, sombra de "tecla" e a seta "›".
class BotaoOnb extends StatefulWidget {
  const BotaoOnb(this.texto, {super.key, required this.aoTocar, this.seta = true, this.chave});
  final String texto;
  final VoidCallback? aoTocar;
  final bool seta;
  final Key? chave;
  @override
  State<BotaoOnb> createState() => _BotaoOnbState();
}

class _BotaoOnbState extends State<BotaoOnb> {
  bool _baixo = false;
  @override
  Widget build(BuildContext context) {
    final ativo = widget.aoTocar != null;
    return GestureDetector(
      key: widget.chave,
      behavior: HitTestBehavior.opaque,
      onTapDown: ativo ? (_) => setState(() => _baixo = true) : null,
      onTapCancel: () => setState(() => _baixo = false),
      onTapUp: (_) => setState(() => _baixo = false),
      onTap: widget.aoTocar,
      child: Opacity(
        opacity: ativo ? 1 : 0.5,
        child: Transform.translate(
          offset: Offset(0, _baixo ? 3 : 0),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onbTexto,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: const Color(0xFFA9A9A9), offset: Offset(0, _baixo ? 1 : 4)),
                const BoxShadow(color: Color(0x24FFFFFF), offset: Offset(0, 10), blurRadius: 24),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(widget.texto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.13, color: Color(0xFF1E1E1E), height: 1.2)),
              if (widget.seta) ...const [SizedBox(width: 9), Text('›', style: TextStyle(fontSize: 17.55, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E), height: 1))],
            ]),
          ),
        ),
      ),
    );
  }
}

/// "Voltar" textual (`.secundario`).
class BotaoSecundarioOnb extends StatelessWidget {
  const BotaoSecundarioOnb(this.texto, {super.key, required this.aoTocar, this.visivel = true});
  final String texto;
  final VoidCallback aoTocar;
  final bool visivel;
  @override
  Widget build(BuildContext context) => Visibility(
        visible: visivel,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: aoTocar,
          child: SizedBox(height: 28, child: Center(child: Text(texto, style: TextStyle(fontSize: 13, color: corApagado)))),
        ),
      );
}

/// Seta redonda de voltar do topo (`.carrosselVoltar`): 34 de diâmetro, branco a 6%.
class SetaVoltarOnb extends StatelessWidget {
  const SetaVoltarOnb({super.key, required this.visivel, required this.aoTocar, required this.rotulo});
  final bool visivel;
  final VoidCallback aoTocar;
  final String rotulo;
  @override
  Widget build(BuildContext context) => Visibility(
        visible: visivel,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: Semantics(
          button: true,
          label: rotulo,
          child: GestureDetector(
            key: const ValueKey('onb-voltar'),
            behavior: HitTestBehavior.opaque,
            onTap: aoTocar,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0x0FFFFFFF), shape: BoxShape.circle),
              child: CustomPaint(size: const Size(18, 18), painter: _PintorChevron()),
            ),
          ),
        ),
      );
}

class _PintorChevron extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // path "M15 18l-6-6 6-6" num viewBox 24
    final k = s.width / 24;
    final p = Path()
      ..moveTo(15 * k, 18 * k)
      ..lineTo(9 * k, 12 * k)
      ..lineTo(15 * k, 6 * k);
    canvas.drawPath(p, Paint()..color = onbTexto..style = PaintingStyle.stroke..strokeWidth = 2 * k..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

/// Pontinhos do carrossel (`.carrosselDot`): 6x6; o ativo é uma pílula de 16x6.
class PontosOnb extends StatelessWidget {
  const PontosOnb({super.key, required this.total, required this.ativo});
  final int total;
  final int ativo; // 0 = nenhum ativo (login)
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var j = 0; j < total; j++) ...[
          if (j > 0) const SizedBox(width: 7),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: j == ativo - 1 ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(color: j == ativo - 1 ? onbTexto : onbLinha, borderRadius: BorderRadius.circular(3)),
          ),
        ],
      ]);
}

/// Cabeçalho "eyebrow" + título forte (`.obHeadline`): a frase fraca em caixa alta e a forte em 25 px.
class CabecalhoOnb extends StatelessWidget {
  const CabecalhoOnb({super.key, required this.fraca, this.forte, this.corFraca = onbFraca});
  final String fraca;
  final String? forte;
  final Color corFraca;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(fraca.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.54, color: corFraca, height: 1.309)),
          if (forte != null) ...[
            const SizedBox(height: 5),
            Text(forte!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -0.25, color: onbTexto, height: 1.2)),
          ] else
            const SizedBox(height: 5),
        ]),
      );
}

/// Corpo do slide (`.obCorpo`): 14 px, no máximo 270 de largura.
class CorpoOnb extends StatelessWidget {
  const CorpoOnb(this.texto, {super.key});
  final String texto;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 270),
          child: Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.55, color: onbMudo)),
        ),
      );
}

/// A marca "dungeon" fina + "log" grossa (`.logoDL`): `clamp(36px, 14vw, 58px)`.
class LogoDungeonlog extends StatelessWidget {
  const LogoDungeonlog({super.key});
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final fs = (w * 0.14).clamp(36.0, 58.0);
    return Text.rich(
      TextSpan(children: [
        const TextSpan(text: 'dungeon', style: TextStyle(fontWeight: FontWeight.w300)),
        const TextSpan(text: 'log', style: TextStyle(fontWeight: FontWeight.w700)),
      ]),
      style: TextStyle(fontSize: fs, color: const Color(0xFFF5F0E9), letterSpacing: -0.012 * fs, height: 1),
      textAlign: TextAlign.center,
    );
  }
}
