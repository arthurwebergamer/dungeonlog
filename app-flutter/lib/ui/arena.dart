// Arena: parede de tijolos, duas tochas, herói x monstro do dia com "vs" no meio e a barra de vida fina
// em cima do monstro. Medidas e cores copiadas de .arena / .fight / .mobBarra / .vitoria do app original.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dominio/regras.dart';
import 'estado_jogo.dart';
import 'icones.dart';
import 'tema.dart';

/// Matriz de saturação (0 = cinza, 1 = cor cheia), o `grayscale()` do CSS.
ColorFilter _saturacao(double s) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  final i = 1 - s;
  return ColorFilter.matrix(<double>[
    r * i + s, g * i, b * i, 0, 0, //
    r * i, g * i + s, b * i, 0, 0, //
    r * i, g * i, b * i + s, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}

class Arena extends StatefulWidget {
  const Arena({super.key, required this.estado, required this.golpe});
  final EstadoJogo estado;

  /// 0 a 1 a cada golpe (conclusão de tarefa): o herói avança e o monstro treme.
  final Animation<double> golpe;

  @override
  State<Arena> createState() => _ArenaState();
}

class _ArenaState extends State<Arena> with SingleTickerProviderStateMixin {
  // relógio único das animações em laço: chama das tochas (0,6 s em 3 quadros) e balanço do herói (1,1 s em passos)
  static const _cicloMs = 6600;
  late final AnimationController _relogio = AnimationController(vsync: this, duration: const Duration(milliseconds: _cicloMs))..repeat();

  @override
  void dispose() {
    _relogio.dispose();
    super.dispose();
  }

  int get _quadroTocha => (_relogio.value * _cicloMs / 200).floor() % 3;
  double get _balanco => const [0.0, -1.0, -2.0, -1.0][(_relogio.value * _cicloMs / 275).floor() % 4];

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    final tema = e.dados.temas.firstWhere((t) => t.id == e.temaArenaId);
    final m = e.monstro;
    final h = e.heroi;
    final venceu = e.derrotado;
    final semTarefas = e.tarefasDeHoje.isEmpty;
    final descansando = e.descansando;

    final heroi = SizedBox(
      width: 83,
      height: 87,
      child: Stack(clipBehavior: Clip.none, children: [
        const Positioned(left: 13.5, top: 75, child: _Sombra()),
        AnimatedBuilder(
          animation: Listenable.merge([_relogio, widget.golpe]),
          builder: (_, filho) => Transform.translate(
            offset: Offset(math.sin(widget.golpe.value * math.pi) * 60, descansando ? 0 : _balanco),
            child: filho,
          ),
          child: pixel(h.imgArena ?? h.img, largura: 83, altura: 83),
        ),
        if (descansando)
          const Positioned(
            left: 50,
            top: -26,
            child: Text('z Z', style: TextStyle(fontFamily: fontePixel, fontSize: 16, color: Color(0xFF9DB4FF), letterSpacing: 4)),
          ),
      ]),
    );

    final monstro = SizedBox(
      width: 78,
      height: 82,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(left: 11, top: 70, child: Opacity(opacity: semTarefas ? 0.4 : 1, child: const _Sombra())),
        AnimatedBuilder(
          animation: widget.golpe,
          builder: (_, filho) {
            final t = widget.golpe.value;
            return Transform.translate(offset: Offset(math.sin(t * math.pi * 7) * 6 * (1 - t), 0), child: filho);
          },
          child: semTarefas
              ? Opacity(opacity: 0.45, child: ColorFiltered(colorFilter: _saturacao(0.45), child: pixel(m.img, largura: 78, altura: 78)))
              : pixel(m.img, largura: 78, altura: 78),
        ),
        if (!semTarefas) Positioned(left: 8, top: -6, child: _BarraMonstro(fracao: e.vidaMonstro)),
      ]),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: venceu ? 215 : 188,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x47000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          // parede: degradê cinza + tijolo 32x10 repetido em 130x41
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF454545), Color(0xFF383838), Color(0xFF2C2C2C)],
                  stops: [0, 0.55, 1],
                ),
                image: DecorationImage(
                  image: AssetImage('assets/img/arena/tile.png'),
                  repeat: ImageRepeat.repeat,
                  alignment: Alignment.topLeft,
                  scale: 32 / 130,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),
          if (tema.arte != null)
            Positioned.fill(child: Image.asset(tema.arte!, fit: BoxFit.cover, alignment: Alignment.bottomCenter, filterQuality: FilterQuality.none)),
          // escurecido nas bordas (radial-gradient at 50% 45%, transparente até 55%)
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(center: Alignment(0, -0.1), radius: 0.78, colors: [Color(0x00000000), Color(0x59000000)], stops: [0.55, 1], transform: _Oval(1.75)),
              ),
            ),
          ),
          Positioned(left: 4, top: 4, child: AnimatedBuilder(animation: _relogio, builder: (_, __) => _Tocha('assets/img/ui/tocha_esq.png', _quadroTocha))),
          Positioned(right: 4, top: 4, child: AnimatedBuilder(animation: _relogio, builder: (_, __) => _Tocha('assets/img/ui/tocha_dir.png', _quadroTocha))),
          Positioned(
            left: 16,
            right: 16,
            top: 56,
            height: 87,
            child: venceu
                ? Center(child: heroi)
                : Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    heroi,
                    const SizedBox(width: 28),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text('VS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.2, color: corApagado, height: 1.27)),
                    ),
                    const SizedBox(width: 28),
                    Opacity(opacity: descansando ? 0.35 : 1, child: monstro),
                  ]),
          ),
          if (venceu)
            Positioned(
              left: 16,
              right: 16,
              top: 159,
              child: Column(children: [
                const Text(
                  'DIA VENCIDO',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: corFaixaVitoria,
                    height: 1.27,
                    shadows: [Shadow(color: Color(0x99E8E8E8), blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 5),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  pixel('assets/img/ui/moeda.png', largura: 16, altura: 16),
                  const SizedBox(width: 5),
                  Text('+${recompensaVitoria(e.tarefasDeHoje.length, multMoedas: e.bonus.multMoedas)}', style: const TextStyle(fontSize: 12, color: corOuro)),
                ]),
              ]),
            ),
          // dia de descanso: arena apagada (filter: brightness(.7) saturate(.75))
          if (descansando) const Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Color(0x4D000000)))),
        ]),
      ),
    );
  }
}

/// Estica o degradê radial na horizontal (o `radial-gradient` do CSS é uma elipse até o canto mais distante).
class _Oval extends GradientTransform {
  const _Oval(this.sx);
  final double sx;
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final cx = bounds.center.dx;
    return Matrix4.identity()
      ..translateByDouble(cx, 0, 0, 1)
      ..scaleByDouble(sx, 1, 1, 1)
      ..translateByDouble(-cx, 0, 0, 1);
  }
}

/// Tocha animada: folha 48x32 com 3 quadros de 16x32, ampliada 1,7x.
class _Tocha extends StatelessWidget {
  const _Tocha(this.folha, this.quadro);
  final String folha;
  final int quadro;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 27.2,
        height: 54.4,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 81.6,
            maxWidth: 81.6,
            child: Transform.translate(
              offset: Offset(-27.2 * quadro, 0),
              child: pixel(folha, largura: 81.6, altura: 54.4, fit: BoxFit.fill),
            ),
          ),
        ),
      );
}

/// Sombra oval embaixo do herói e do monstro (56x12).
class _Sombra extends StatelessWidget {
  const _Sombra();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 56,
        height: 12,
        child: Center(
          child: Transform.scale(
            scaleX: 56 / 12,
            child: const SizedBox(
              width: 12,
              height: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Color(0x99000000), Color(0x47000000), Color(0x00000000)], stops: [0, 0.48, 0.75]),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Barra de vida do monstro: 62x8, fundo quase preto, enchimento vermelho.
class _BarraMonstro extends StatelessWidget {
  const _BarraMonstro({required this.fracao});
  final double fracao;
  @override
  Widget build(BuildContext context) => Container(
        width: 62,
        height: 8,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: const Color(0xC708060C),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xD9000000), width: 0.8),
          boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 3, offset: Offset(0, 1))],
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: fracao.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: v,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(1)),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE8556E), Color(0xFFB8283F)]),
              ),
            ),
          ),
        ),
      );
}
