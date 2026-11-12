// Aviso flutuante sobre um ponto da tela (.dmg-float.fixo do original): aparece, fica e sobe 34px sumindo, em 1,1 s.
// É o retorno de "usar" (+N XP / +N HP) e "vender" (+N e a moeda), que nascem em cima do ícone do item.
import 'package:flutter/material.dart';

import 'icones.dart';
import 'tema.dart';

const _estiloFlutuante = TextStyle(
  fontFamily: fontePixel,
  fontSize: 13,
  fontWeight: FontWeight.w700,
  height: 1.25,
  decoration: TextDecoration.none,
  shadows: [Shadow(color: Color(0x99000000), blurRadius: 2, offset: Offset(0, 1))],
);

/// Centro de um widget na tela (`pontoDeElemento`), para guardar ANTES de a lista redesenhar.
Offset? centroDe(BuildContext contexto) {
  final caixa = contexto.findRenderObject();
  if (caixa is! RenderBox || !caixa.attached) return null;
  return caixa.localToGlobal(caixa.size.center(Offset.zero));
}

/// Mostra [filho] centrado em [ponto] (coordenadas da tela), sem sair das bordas.
void mostrarFlutuante(BuildContext context, Offset? ponto, Widget filho) {
  final camada = Overlay.maybeOf(context, rootOverlay: true);
  if (camada == null || ponto == null) return;
  late final OverlayEntry entrada;
  entrada = OverlayEntry(builder: (_) => _Flutuante(ponto: ponto, aoTerminar: () => entrada.remove(), child: filho));
  camada.insert(entrada);
}

/// "+15 XP", "+40 HP", "EQUIPADO"... em letra pixel clara (.dmg-xp).
void flutuanteTexto(BuildContext context, Offset? ponto, String texto) =>
    mostrarFlutuante(context, ponto, Text(texto, style: _estiloFlutuante.copyWith(color: corTexto)));

/// "+23" e a moeda, na cor do ouro (.dmg-moeda).
void flutuanteMoedas(BuildContext context, Offset? ponto, int moedas) => mostrarFlutuante(
      context,
      ponto,
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text('+$moedas', style: _estiloFlutuante.copyWith(color: corOuro)),
        const SizedBox(width: 5),
        pixel('assets/img/ui/moeda.png', largura: 16, altura: 16),
      ]),
    );

class _Flutuante extends StatefulWidget {
  const _Flutuante({required this.ponto, required this.aoTerminar, required this.child});
  final Offset ponto;
  final VoidCallback aoTerminar;
  final Widget child;
  @override
  State<_Flutuante> createState() => _FlutuanteState();
}

class _FlutuanteState extends State<_Flutuante> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.aoTerminar();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomSingleChildLayout(
          delegate: _NoPonto(widget.ponto),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, filho) {
              // @keyframes dmgFloat: 0-15% cresce e aparece, até 55% parado, depois sobe 34px e some (ease-out)
              final t = Curves.easeOut.transform(_c.value);
              final entra = (t / 0.15).clamp(0.0, 1.0);
              final sai = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
              return Opacity(
                opacity: t < 0.55 ? entra : 1 - sai,
                child: Transform.translate(offset: Offset(0, -34 * sai), child: Transform.scale(scale: 0.8 + 0.2 * entra, child: filho)),
              );
            },
            child: widget.child,
          ),
        ),
      );
}

/// Centra o filho no ponto, com 10px de margem das laterais.
class _NoPonto extends SingleChildLayoutDelegate {
  _NoPonto(this.ponto);
  final Offset ponto;
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    const margem = 10.0;
    var x = ponto.dx - childSize.width / 2;
    final max = size.width - margem - childSize.width;
    if (x > max) x = max;
    if (x < margem) x = margem;
    return Offset(x, ponto.dy - childSize.height / 2);
  }

  @override
  bool shouldRelayout(_NoPonto o) => o.ponto != ponto;
}
