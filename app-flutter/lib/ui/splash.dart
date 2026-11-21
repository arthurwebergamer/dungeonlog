// Tela de abertura (#bootSplash do original): fundo da cor do tema, o herói correndo e "Carregando a masmorra...".
import 'package:flutter/material.dart';

import '../dominio/entrada.dart';
import 'icones.dart' show pixel;
import 'tema.dart' show fontePixel;

class AberturaSplash extends StatefulWidget {
  const AberturaSplash({super.key, required this.cor, required this.texto});
  final Color cor;
  final String texto;
  @override
  State<AberturaSplash> createState() => _AberturaSplashState();
}

class _AberturaSplashState extends State<AberturaSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: widget.cor,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 96,
              height: 84,
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final t = Curves.easeInOut.transform(_c.value);
                  return Stack(children: [
                    Positioned(left: 26, bottom: 4, width: 44, height: 8, child: Opacity(opacity: 1 - .4 * t, child: Transform.scale(scaleX: 1 - .3 * t, child: const DecoratedBox(decoration: BoxDecoration(color: Color(0x59000000), borderRadius: BorderRadius.all(Radius.elliptical(22, 4)))))))
                    ,
                    Positioned(
                      left: 20,
                      bottom: 10,
                      width: 56,
                      height: 56,
                      child: Transform.translate(offset: Offset(0, -12 * t), child: Transform.rotate(angle: (-4 + 8 * t) * 3.14159265 / 180, child: pixel('assets/img/ui/splash_heroi.png', largura: 56, altura: 56))),
                    ),
                  ]);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.texto, textAlign: TextAlign.center, style: const TextStyle(fontFamily: fontePixel, fontSize: 12, color: Color(0xFF909090), letterSpacing: 0.24, decoration: TextDecoration.none)),
          ]),
        ),
      );
}

String textoDaAbertura(Locale l) => textoAbertura(l.languageCode);
