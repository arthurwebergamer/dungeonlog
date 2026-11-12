// Topo do app, igual em todas as abas (.topbar do original).
import 'package:flutter/material.dart';

import 'estado_jogo.dart';
import 'icones.dart';
import 'tema.dart';

/// Topo: avatar redondo do herói + "Nível II" à esquerda, pilha de moedas + número à direita (.topbar).
class TopoApp extends StatelessWidget {
  const TopoApp({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: SizedBox(
        height: 30,
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: corPainel2, shape: BoxShape.circle, border: Border.all(color: corLinha, width: 0.8)),
            // background-size:154% / position:50% 8% -> o rosto do herói
            child: OverflowBox(
              maxWidth: 43.12,
              maxHeight: 43.12,
              minWidth: 43.12,
              minHeight: 43.12,
              alignment: const Alignment(0, -0.84),
              child: pixel(estado.heroi.img, largura: 43.12, altura: 43.12),
            ),
          ),
          const SizedBox(width: 6),
          Text('Nível ${romano(estado.nivel)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          pixel('assets/img/ui/moedas.png', largura: 30, altura: 30),
          const SizedBox(width: 6),
          Text('${estado.save.moedas.toInt()}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: corOuro)),
        ]),
      ),
    );
  }
}
