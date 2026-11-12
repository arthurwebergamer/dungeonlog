// Arena: herói x monstro do dia, com a barra de vida do monstro (fração das tarefas ainda pendentes).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'estado_jogo.dart';
import 'tema.dart';

Widget _sprite(String caminho, double tamanho) => Image.asset(
      caminho,
      width: tamanho,
      height: tamanho,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none, // pixel art nítida
      gaplessPlayback: true,
    );

class Arena extends StatelessWidget {
  const Arena({super.key, required this.estado, required this.golpe});
  final EstadoJogo estado;

  /// 0 a 1 a cada golpe (conclusão de tarefa): faz o monstro tremer.
  final Animation<double> golpe;

  @override
  Widget build(BuildContext context) {
    final tema = estado.dados.temas.firstWhere((t) => t.id == estado.temaArenaId);
    final m = estado.monstro;
    final h = estado.heroi;
    final derrotado = estado.derrotado;
    return Container(
      height: 214,
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A2D57), Color(0xFF261D3B), Color(0xFF181226)],
        ),
        image: const DecorationImage(
          image: AssetImage('assets/img/arena/tile.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.28,
          filterQuality: FilterQuality.none,
        ),
      ),
      child: Stack(children: [
        if (tema.arte != null)
          Positioned.fill(child: Image.asset(tema.arte!, fit: BoxFit.cover, alignment: Alignment.bottomCenter, filterQuality: FilterQuality.none)),
        // chão
        Positioned(left: 0, right: 0, bottom: 0, height: 34, child: Container(color: const Color(0x66000000))),
        Positioned(
          left: 26,
          bottom: 24,
          child: AnimatedBuilder(
            animation: golpe,
            builder: (_, filho) => Transform.translate(offset: Offset(math.sin(golpe.value * math.pi) * 70, 0), child: filho), // avança e volta
            child: _sprite(h.imgArena ?? h.img, 96),
          ),
        ),
        Positioned(
          right: 26,
          bottom: 24,
          child: AnimatedBuilder(
            animation: golpe,
            builder: (_, filho) {
              final t = golpe.value;
              return Transform.translate(offset: Offset(math.sin(t * math.pi * 7) * 7 * (1 - t), 0), child: filho);
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: derrotado ? 0.25 : 1,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 400),
                scale: derrotado ? 0.8 : 1,
                child: _sprite(m.img, 96),
              ),
            ),
          ),
        ),
        // nome e barra de vida do monstro
        Positioned(
          right: 14,
          top: 12,
          width: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(m.nomeNoIdioma(estado.idioma), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: estado.vidaMonstro),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 9, backgroundColor: const Color(0x55000000), color: corVida),
              ),
            ),
          ]),
        ),
        Positioned(
          left: 14,
          top: 12,
          child: Text(h.nomeNoIdioma(estado.idioma), style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ),
        if (derrotado)
          const Positioned(
            left: 0,
            right: 0,
            top: 60,
            child: Center(
              child: Text('MONSTRO DERROTADO', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: corOuro)),
            ),
          ),
      ]),
    );
  }
}
