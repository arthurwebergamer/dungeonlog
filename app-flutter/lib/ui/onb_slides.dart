// Os 5 slides do carrossel de apresentação (SLIDES de play/index.html ~17400) e a animação do golpe do último.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../dominio/catalogo.dart' show ItemCatalogo;
import '../dominio/entrada.dart';
import 'equip_arena.dart';
import 'estado_jogo.dart';
import 'icones.dart' show pixel;
import 'itens_ui.dart';
import 'onb_comum.dart';
import 'tema.dart' show fontePixel;

/// Conteúdo central de um slide (`.carrosselMeio`).
class ConteudoSlide extends StatelessWidget {
  const ConteudoSlide({super.key, required this.slide, required this.estado, required this.categoria, required this.aoEscolher, required this.ativo});
  final SlideOnb slide;
  final EstadoJogo estado;
  final String categoria;
  final ValueChanged<String> aoEscolher;
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    final l = estado.idioma;
    final cab = CabecalhoOnb(fraca: slide.tFraca(l), forte: slide.tipo == TipoSlide.quizCategoria ? null : slide.tTitulo(l));
    final corpo = CorpoOnb(slide.tTexto(l));
    const g = SizedBox(height: 18);
    switch (slide.tipo) {
      case TipoSlide.monstro:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 168, child: pixel(estado.dados.monstros[slide.idx].img, largura: 168, altura: 168)),
          g, cab, g, corpo,
        ]);
      case TipoSlide.quizCategoria:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          cab,
          const SizedBox(height: 24),
          Text(slide.tTitulo(l), textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, height: 1.25, color: onbTexto)),
          const SizedBox(height: 34),
          for (var i = 0; i < categoriasOnboarding.length; i++) ...[
            if (i > 0) const SizedBox(height: 9),
            _OpcaoQuiz(cat: categoriasOnboarding[i], idioma: l, selecionada: categoria == categoriasOnboarding[i].id, aoTocar: () => aoEscolher(categoriasOnboarding[i].id)),
          ],
        ]);
      case TipoSlide.heroi:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 168, child: pixel(estado.dados.herois[slide.idx].img, largura: 168, altura: 168)),
          g, cab,
          const SizedBox(height: 32),
          _CartaoProgresso(idioma: l),
          g, corpo,
        ]);
      case TipoSlide.conquistasPreview:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: 96,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              for (final id in itensConquistasOnboarding) ...[_Emblema(estado: estado, id: id), const SizedBox(width: 12)],
              const _EmblemaTrancado(),
            ]),
          ),
          g, cab, g, corpo,
        ]);
      case TipoSlide.golpeAnim:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 150, width: double.infinity, child: PalcoGolpe(estado: estado, monstro: slide.idx, ativo: ativo)),
          g, cab, g, corpo,
        ]);
    }
  }
}

class _OpcaoQuiz extends StatelessWidget {
  const _OpcaoQuiz({required this.cat, required this.idioma, required this.selecionada, required this.aoTocar});
  final CategoriaOnb cat;
  final String idioma;
  final bool selecionada;
  final VoidCallback aoTocar;
  @override
  Widget build(BuildContext context) {
    final cor = Color(0xFF000000 | cat.cor);
    return GestureDetector(
      key: ValueKey('quiz-${cat.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 65.6,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selecionada ? onbSel : onbPainel,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selecionada ? cor : onbLinha, width: 0.8),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: onbPoco, borderRadius: BorderRadius.circular(10)),
            child: pixel('assets/img/ui/onb_${cat.id}.png', largura: 28, altura: 28),
          ),
          const SizedBox(width: 12),
          Text(cat.t(idioma), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onbTexto)),
          const Spacer(),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(shape: BoxShape.circle, color: selecionada ? cor : null, border: Border.all(color: selecionada ? cor : const Color(0xFF5C5C5C), width: 0.8)),
            child: selecionada ? CustomPaint(painter: _PintorCheck()) : null,
          ),
        ]),
      ),
    );
  }
}

class _PintorCheck extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = const Color(0xFF1A1526)..style = PaintingStyle.stroke..strokeWidth = 2;
    c.drawPath(Path()..moveTo(5, 9)..lineTo(8, 12)..lineTo(13, 6), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _CartaoProgresso extends StatelessWidget {
  const _CartaoProgresso({required this.idioma});
  final String idioma;
  @override
  Widget build(BuildContext context) => Container(
        width: 280,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(color: onbPainel, borderRadius: BorderRadius.circular(16), border: Border.all(color: onbLinha, width: 0.8)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(idioma == 'en' ? 'LEVEL 4' : 'NÍVEL 4', style: const TextStyle(fontFamily: fontePixel, fontSize: 12, color: onbTexto)),
            const Text('640 / 1000 XP', style: TextStyle(fontSize: 11.5, color: onbDim)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(height: 8, color: onbLinha, alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: 0.64, child: Container(color: onbTexto))),
          ),
        ]),
      );
}

class _Emblema extends StatelessWidget {
  const _Emblema({required this.estado, required this.id});
  final EstadoJogo estado;
  final int id;
  @override
  Widget build(BuildContext context) {
    final it = estado.catalogo.item(id)!;
    final cor = corRaridade[it.raridade.clamp(0, 7)];
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onbPoco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor, width: 0.8),
        boxShadow: [BoxShadow(color: cor.withValues(alpha: 0.38), blurRadius: 12)],
      ),
      child: SpriteItem(estado: estado, item: it, tamanho: 34),
    );
  }
}

class _EmblemaTrancado extends StatelessWidget {
  const _EmblemaTrancado();
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.4,
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: onbPainel, borderRadius: BorderRadius.circular(16), border: Border.all(color: onbLinha, width: 0.8)),
          child: CustomPaint(size: const Size(28, 28), painter: _PintorCadeado()),
        ),
      );
}

class _PintorCadeado extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final k = s.width / 24;
    final p = Paint()..color = onbDim..style = PaintingStyle.stroke..strokeWidth = 1.5 * k..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4 * k, 10 * k, 16 * k, 10 * k), Radius.circular(2 * k)), p);
    c.drawPath(Path()..moveTo(8 * k, 10 * k)..lineTo(8 * k, 7 * k)..arcToPoint(Offset(16 * k, 7 * k), radius: Radius.circular(4 * k))..lineTo(16 * k, 10 * k), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ---------------------------------------------------------------------------------------------------------------
/// Palco do slide "É rápido assim": o herói corre até o monstro, o corte aparece, a recompensa voa até ele, "+4 · +12 XP"
/// sobe e a espada troca (`golpeOb` do original). Um golpe a cada 2,4 s, o primeiro 250 ms depois de o slide abrir.
class PalcoGolpe extends StatefulWidget {
  const PalcoGolpe({super.key, required this.estado, required this.monstro, required this.ativo});
  final EstadoJogo estado;
  final int monstro;
  final bool ativo;
  @override
  State<PalcoGolpe> createState() => _PalcoGolpeState();
}

class _PalcoGolpeState extends State<PalcoGolpe> with SingleTickerProviderStateMixin {
  late final Ticker _tk = createTicker(_tick);
  double _ms = -1; // tempo desde o início do primeiro golpe

  @override
  void initState() {
    super.initState();
    if (widget.ativo) _tk.start();
  }

  @override
  void didUpdateWidget(PalcoGolpe o) {
    super.didUpdateWidget(o);
    if (widget.ativo && !_tk.isActive) _tk.start();
    if (!widget.ativo && _tk.isActive) {
      _tk.stop();
      setState(() => _ms = -1);
    }
  }

  void _tick(Duration d) => setState(() => _ms = d.inMilliseconds - 250.0);

  @override
  void dispose() {
    _tk.dispose();
    super.dispose();
  }

  static const _T = 900.0, _ciclo = 2400.0;
  static double _lerpKf(double t, List<(double, double)> kf) {
    for (var i = 1; i < kf.length; i++) {
      if (t <= kf[i].$1) {
        final a = kf[i - 1], b = kf[i];
        final u = b.$1 == a.$1 ? 1.0 : (t - a.$1) / (b.$1 - a.$1);
        return a.$2 + (b.$2 - a.$2) * u;
      }
    }
    return kf.last.$2;
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      final ciclo = _ms < 0 ? 0 : (_ms ~/ _ciclo);
      final loc = _ms < 0 ? -1.0 : _ms % _ciclo;
      final espadaIdx = (ciclo + (loc >= _T + 350 ? 1 : 0)) % espadasOnboarding.length;
      final espada = e.catalogo.item(espadasOnboarding[espadaIdx])!;
      // herói: caixa 125x126, bottom 0, a 40,9 px da esquerda; monstro 108 em right 6%, bottom 4
      final heroiEsq = w * 0.06 + 20.4; // medido no original em repouso: 40,9 px do palco
      final mobEsq = w - w * 0.06 - 108;
      final dx = math.max(0.0, (mobEsq - (heroiEsq + 125) + 14).roundToDouble());
      double tx = 0, ty = 0, esc = 1;
      double grauArma = 8;
      if (loc >= 0 && loc <= _T) {
        final p = const Cubic(.3, .7, .3, 1).transform(loc / _T);
        tx = dx * _lerpKf(p, [(0, 0), (.22, .55), (.40, 1), (.55, 1), (1, 0)]);
        ty = _lerpKf(p, [(0, 0), (.22, -6), (.40, 0), (1, 0)]);
        esc = _lerpKf(p, [(0, 1), (.22, 1.04), (.40, 1.08), (.55, 1.08), (1, 1)]);
        final q = Curves.easeOut.transform(loc / _T);
        grauArma = _lerpKf(q, [(0, -20), (.40, -20), (.55, 75), (.75, 75), (1, 8)]);
      }
      // impacto aos 42% do golpe
      final imp = loc - _T * 0.42;
      double mx = 0, my = 0, mrot = 0;
      var branco = false;
      if (imp >= 0 && imp <= 320) {
        final u = imp / 320;
        mx = _lerpKf(u, [(0, 0), (.3, -5), (.6, 4), (1, 0)]);
        my = _lerpKf(u, [(0, 0), (.3, -2), (.6, 1), (1, 0)]);
        mrot = _lerpKf(u, [(0, 0), (.3, -6), (.6, 5), (1, 0)]) * math.pi / 180;
        branco = u > 0 && u < 1;
      }
      final mobCentro = Offset(mobEsq + 54, 150 - 4 - 54);
      final heroiCentro = Offset(heroiEsq + 62.5, 150 - 63);
      final filhos = <Widget>[
        Positioned(
          left: mobEsq,
          bottom: 4,
          width: 108,
          height: 108,
          child: Transform.translate(
            offset: Offset(mx, my),
            child: Transform.rotate(
              angle: mrot,
              child: ColorFiltered(
                colorFilter: branco ? const ColorFilter.mode(Colors.white, BlendMode.srcATop) : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: pixel(e.dados.monstros[widget.monstro].img, largura: 108, altura: 108),
              ),
            ),
          ),
        ),
        Positioned(
          left: heroiEsq,
          bottom: 0,
          width: 125,
          height: 126,
          child: Transform.translate(
            offset: Offset(tx, ty),
            child: Transform.scale(scale: esc, alignment: Alignment.bottomLeft, child: _HeroiGolpe(estado: e, espada: espada, grau: grauArma, pop: loc >= _T + 350 && loc < _T + 610 ? (loc - _T - 350) / 260 : 1)),
          ),
        ),
      ];
      // corte (9 quadros, .42 s) sobre o monstro
      if (imp >= 0 && imp < 420) {
        final rar = espada.raridade;
        final quadro = (imp / 420 * 9).floor().clamp(0, 8);
        final escala = escalaCorteOnboarding(rar) * 1.5;
        filhos.add(Positioned(
          left: mobCentro.dx - 32,
          top: mobCentro.dy - 32,
          width: 64,
          height: 64,
          child: IgnorePointer(
            child: Transform.translate(
              offset: Offset(0, 12.5 * escala),
              child: Transform.scale(
                scale: escala,
                child: Transform.rotate(angle: 25 * math.pi / 180, child: _QuadroCorte(classe: classeCorteOnboarding(rar), quadro: quadro)),
              ),
            ),
          ),
        ));
      }
      // moeda e gema voando até o herói (.75 s)
      for (final (atraso, gema) in [(0.0, false), (90.0, true)]) {
        final u = (imp - atraso) / 750;
        if (imp >= 0 && u >= 0 && u <= 1) {
          final p = const Cubic(.25, .65, .3, 1).transform(u);
          final pos = Offset.lerp(mobCentro, heroiCentro, p)!;
          final op = u < .16 / .75 ? 1.0 : (1 - ((u - .16 / .75) / (1 - .16 / .75))).clamp(0.0, 1.0);
          filhos.add(Positioned(
            left: pos.dx - 11,
            top: pos.dy - 11,
            width: 22,
            height: 22,
            child: Opacity(opacity: op, child: Transform.scale(scale: 1 - .65 * Curves.easeIn.transform(u), child: gema ? CustomPaint(painter: _PintorGema()) : pixel('assets/img/ui/moeda.png', largura: 22, altura: 22))),
          ));
        }
      }
      // "+4 moeda · +12 XP" aos 840 ms depois do impacto
      final fl = (imp - 840) / 1100;
      if (imp >= 840 && fl <= 1) {
        final t = Curves.easeOut.transform(fl);
        final entra = (t / .15).clamp(0.0, 1.0), sai = ((t - .55) / .45).clamp(0.0, 1.0);
        filhos.add(Positioned(
          left: 0,
          right: 0,
          bottom: 130 + 34 * sai,
          child: IgnorePointer(
            child: Opacity(
              opacity: t < .55 ? entra : 1 - sai,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: const [
                _TextoFlut('+4', Color(0xFFE8E8E8)),
                SizedBox(width: 4),
                _MoedaMini(),
                SizedBox(width: 6),
                _TextoFlut('·', Color(0xFFC2C2C2)),
                SizedBox(width: 6),
                _TextoFlut('+12 XP', onbTexto),
              ]),
            ),
          ),
        ));
      }
      return ClipRect(clipBehavior: Clip.none, child: Stack(clipBehavior: Clip.none, children: filhos));
    });
  }
}

class _TextoFlut extends StatelessWidget {
  const _TextoFlut(this.t, this.c);
  final String t;
  final Color c;
  @override
  Widget build(BuildContext context) => Text(t, style: TextStyle(fontFamily: fontePixel, fontSize: 13, fontWeight: FontWeight.w700, color: c, decoration: TextDecoration.none, shadows: const [Shadow(color: Color(0x99000000), blurRadius: 2, offset: Offset(0, 1))]));
}

class _MoedaMini extends StatelessWidget {
  const _MoedaMini();
  @override
  Widget build(BuildContext context) => pixel('assets/img/ui/moeda.png', largura: 16, altura: 16);
}

class _PintorGema extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final k = s.width / 16;
    void r(double x, double y, double w, double h, int cor) => c.drawRect(Rect.fromLTWH(x * k, y * k, w * k, h * k), Paint()..color = Color(0xFF000000 | cor));
    r(7, 1, 2, 1, 0x63C99A); r(5, 2, 6, 1, 0x63C99A); r(3, 3, 10, 2, 0x7EDBB0); r(1, 5, 14, 3, 0x63C99A);
    r(3, 8, 10, 2, 0x4EA97E); r(5, 10, 6, 1, 0x4EA97E); r(7, 11, 2, 1, 0x4EA97E);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _QuadroCorte extends StatelessWidget {
  const _QuadroCorte({required this.classe, required this.quadro});
  final String classe;
  final int quadro;
  @override
  Widget build(BuildContext context) {
    Widget img = ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 576,
        maxWidth: 576,
        minHeight: 64,
        maxHeight: 64,
        child: Transform.translate(offset: Offset(-64.0 * quadro, 0), child: Image.asset('assets/img/ui/slash_$classe.png', width: 576, height: 64, fit: BoxFit.fill, filterQuality: FilterQuality.none)),
      ),
    );
    if (classe == 'comum') {
      // filter: grayscale(1) brightness(2.4)
      img = ColorFiltered(colorFilter: const ColorFilter.matrix(<double>[0.316, 1.064, 0.107, 0, 0, 0.316, 1.064, 0.107, 0, 0, 0.316, 1.064, 0.107, 0, 0, 0, 0, 0, 1, 0]), child: img);
    }
    return SizedBox(width: 64, height: 64, child: img);
  }
}

/// Herói do carrossel (`obPintarHeroi`): corpo, espada na mão, manga por cima; ampliado 1,5x (feito por quem usa).
class _HeroiGolpe extends StatelessWidget {
  const _HeroiGolpe({required this.estado, required this.espada, required this.grau, required this.pop});
  final EstadoJogo estado;
  final ItemCatalogo espada;
  final double grau, pop;
  @override
  Widget build(BuildContext context) {
    final h = estado.dados.herois[1];
    final t = EquipArena.atual;
    const lado = 56.0, k = lado / 32;
    final cabo = t.armaGrip[espada.id];
    final aj = t.armaAjuste[espada.id] ?? const [0.0, 0.0];
    final esq = cabo == null ? 52.0 : 60 - cabo[0] * k + aj[0];
    final topo = cabo == null ? 15.0 : 63.3 - cabo[1] * k + aj[1];
    final pivo = cabo == null ? const Offset(lado * .2, lado * .85) : Offset(cabo[0] * k, cabo[1] * k);
    final centro = pivo - const Offset(lado / 2, lado / 2);
    Widget arma = Sprite(estado: estado, sprite: espada.sprite, tamanho: lado, clarear: t.armaEscura.contains(espada.id));
    arma = Transform.rotate(angle: grau * math.pi / 180, origin: centro, child: arma);
    if (pop < 1) arma = Opacity(opacity: pop.clamp(0.0, 1.0), child: arma);
    return SizedBox(
      width: 83,
      height: 87,
      child: Transform.scale(
        scale: 1.5,
        alignment: Alignment.bottomLeft,
        child: SizedBox(
          width: 83,
          height: 87,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(left: 13.5, top: 75, width: 56, height: 12, child: Center(child: Transform.scale(scaleX: 56 / 12, child: const SizedBox(width: 12, height: 12, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0x99000000), Color(0x47000000), Color(0x00000000)], stops: [0, 0.48, 0.75]))))))),
            pixel(h.img, largura: 83, altura: 83),
            Positioned(left: esq, top: topo, width: lado, height: lado, child: arma),
            Positioned(
              left: 0,
              top: 0,
              child: ClipRect(clipper: _RecorteMao(), child: pixel(h.img, largura: 83, altura: 83)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RecorteMao extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => const Rect.fromLTRB(56.1, 56.1, 83 - 19.5, 83 - 17.1);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> o) => false;
}
