// Telas cheias do jogo no formato "md" do original: subir de nível (mostrarNivelUp), "Você caiu" (mostrarQueda),
// resumo do dia vencido (mostrarResumoDia) e "Tarefas perdidas" (mostrarTarefasPerdidas), em play/index.html ~12535 a 12930.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dominio/economia.dart';
import '../dominio/regras.dart' show estagioAtual;
import '../dominio/tarefa.dart';
import 'arena.dart' show FundoTema, TochaArena;
import 'estado_jogo.dart';
import 'icones.dart';
import 'sheet_md.dart';
import 'som.dart';
import 'tema.dart';

/// Um sprite na arte da folha (`.md-hero`): entra subindo 28 px e crescendo de .85 a 1 depois de [atraso] ms.
class MdSprite {
  const MdSprite(this.img, {this.esquerda = 0.5, this.baixo = 14, this.atraso = 550, this.cinza = 0, this.giro = 0});
  final String img;
  final double esquerda; // fração da largura (centro do sprite)
  final double baixo;
  final int atraso;
  final double cinza; // 0 a 1 (filter: grayscale + brightness)
  final double giro; // radianos
}

/// `.md-art`: 158 px com a parede da masmorra, as duas tochas, sombra embaixo e os sprites por cima.
class ArteMd extends StatelessWidget {
  const ArteMd({super.key, required this.estado, required this.sprites, this.nome});
  final EstadoJogo estado;
  final List<MdSprite> sprites;
  final String? nome; // texto grande no canto (ex.: o nível em romano)

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: MdQuadro(builder: (ctx) {
        final zoom = 1.14 - 0.14 * mdTrecho(ctx, 400, 1800, curva: const Cubic(0.2, 0.7, 0.2, 1));
        return LayoutBuilder(builder: (_, caixa) {
          return Stack(children: [
            Positioned.fill(child: Transform.scale(scale: zoom, child: FundoTema(tema: estado.dados.temas.first))),
            const Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x99000000)]))),
            ),
            const Positioned(left: 4, top: 4, child: TochaArena('assets/img/ui/tocha_esq.png', 0)),
            const Positioned(right: 4, top: 4, child: TochaArena('assets/img/ui/tocha_dir.png', 0)),
            for (final s in sprites)
              Positioned(
                left: caixa.maxWidth * s.esquerda - 41.5,
                bottom: s.baixo,
                width: 83,
                height: 83,
                child: Builder(builder: (c) {
                  final t = mdTrecho(c, s.atraso, 800, curva: const Cubic(0.2, 0.9, 0.3, 1.1));
                  final op = mdTrecho(c, s.atraso, 250);
                  Widget img = Image.asset(s.img, fit: BoxFit.contain, filterQuality: FilterQuality.none);
                  if (s.cinza > 0) {
                    final k = 1 - s.cinza * 0.3;
                    img = ColorFiltered(
                      colorFilter: ColorFilter.matrix(<double>[
                        (0.2126 * s.cinza + (1 - s.cinza)) * k, 0.7152 * s.cinza * k, 0.0722 * s.cinza * k, 0, 0,
                        0.2126 * s.cinza * k, (0.7152 * s.cinza + (1 - s.cinza)) * k, 0.0722 * s.cinza * k, 0, 0,
                        0.2126 * s.cinza * k, 0.7152 * s.cinza * k, (0.0722 * s.cinza + (1 - s.cinza)) * k, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                      child: img,
                    );
                  }
                  return Opacity(
                    opacity: op,
                    child: Transform.translate(offset: Offset(0, 28 * (1 - t)), child: Transform.scale(scale: 0.85 + 0.15 * t, child: Transform.rotate(angle: s.giro, child: img))),
                  );
                }),
              ),
            if (nome != null)
              Positioned(
                left: 14,
                bottom: 10,
                height: 34,
                child: ClipRect(
                  child: Builder(builder: (c) {
                    final y = 1 - mdTrecho(c, 1200, 600, curva: const Cubic(0.2, 0.9, 0.2, 1));
                    return Transform.translate(
                      offset: Offset(0, 34 * 1.1 * y),
                      child: Text(nome!, style: const TextStyle(fontFamily: 'Cormorant Garamond', fontStyle: FontStyle.italic, fontVariations: [FontVariation('wght', 600)], fontSize: 28, height: 34 / 28, color: Colors.white)),
                    );
                  }),
                ),
              ),
          ]);
        });
      }),
    );
  }
}

/// `.md-seg` com um único segmento que enche até [fracao] (com [atraso] e [dur] em ms).
class MdSegmentoUnico extends StatelessWidget {
  const MdSegmentoUnico({super.key, required this.fracao, this.atraso = 500, this.dur = 800});
  final double fracao;
  final int atraso;
  final int dur;
  @override
  Widget build(BuildContext context) => MdQuadro(builder: (ctx) {
        final f = fracao * mdTrecho(ctx, atraso, dur, curva: const Cubic(0.3, 0.7, 0.2, 1));
        return Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(color: corLinha, borderRadius: BorderRadius.circular(3)),
          clipBehavior: Clip.antiAlias,
          child: Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: f.clamp(0.0, 1.0), child: const ColoredBox(color: corOuro, child: SizedBox.expand()))),
        );
      });
}

/// `.md-segl`: duas pontas de texto pequeno embaixo da barra.
class MdLegenda extends StatelessWidget {
  const MdLegenda(this.esq, this.dir, {super.key, this.atraso = 500});
  final String esq;
  final String dir;
  final int atraso;
  @override
  Widget build(BuildContext context) => MdEntra(
        atraso: atraso,
        sobe: false,
        dur: 250,
        filho: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(esq, style: const TextStyle(fontSize: 12, color: corApagado)),
            Text(dir, style: const TextStyle(fontSize: 12, color: corApagado, fontFeatures: algarismosFixos)),
          ]),
        ),
      );
}

class _Pontilhado extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = corLinha;
    for (double x = 0; x < size.width; x += 4) {
      canvas.drawCircle(Offset(x + 1, size.height / 2), 1, p);
    }
  }

  @override
  bool shouldRepaint(_Pontilhado o) => false;
}

/// `.rl-l`: "Rótulo ........ valor", entra com fade em 1,1 s + 0,08 s por linha.
class MdRl extends StatelessWidget {
  const MdRl({super.key, required this.indice, required this.rotulo, required this.valor, this.total = false});
  final int indice;
  final String rotulo;
  final Widget valor;
  final bool total;
  @override
  Widget build(BuildContext context) {
    final cor = total ? const Color(0xFFF2C14E) : corSuave;
    return MdEntra(
      atraso: 1100 + indice * 80,
      dur: 300,
      sobe: false,
      filho: Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(rotulo, style: TextStyle(fontSize: total ? 15 : 14, fontWeight: total ? FontWeight.w600 : FontWeight.w500, color: cor)),
          const SizedBox(width: 7),
          Expanded(child: SizedBox(height: 4, child: CustomPaint(painter: _Pontilhado()))),
          const SizedBox(width: 7),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: total ? const Color(0xFFF2C14E) : corTexto, fontFeatures: algarismosFixos),
            child: valor,
          ),
        ]),
      ),
    );
  }
}

/// Linha que separa as parcelas do total (`.rl hr`).
class MdRlLinha extends StatelessWidget {
  const MdRlLinha({super.key, required this.indice});
  final int indice;
  @override
  Widget build(BuildContext context) => MdEntra(
        atraso: 1350 + 3 * 80,
        dur: 300,
        sobe: false,
        filho: Container(height: 2, margin: const EdgeInsets.only(bottom: 9), color: corLinha),
      );
}

// ---------------------------------------------------------------------------------------------

/// Subiu de nível: "NÍVEL ALCANÇADO", "Nível N!", a vida máxima contando até o valor novo.
Future<void> mostrarNivelUp(BuildContext context, EstadoJogo e, int nivel) {
  Som.atual.tocar('levelup');
  final en = e.idioma == 'en';
  final vMax = e.vidaMaxima;
  final dV = Eco.vidaPorNivel.round();
  return abrirSheetMd(
    context,
    totalMs: 2600,
    filhos: (fechar) => [
      MdRotulo(en ? 'LEVEL REACHED' : 'NÍVEL ALCANÇADO', atraso: 350),
      MdTitulo('${en ? 'Level ' : 'Nível '}$nivel!', atraso: 350),
      ArteMd(estado: e, sprites: [MdSprite(e.heroi.img)], nome: romano(nivel)),
      const MdSegmentoUnico(fracao: 1),
      MdLegenda('${en ? 'Level ' : 'Nível '}${nivel - 1}', '${en ? 'Level ' : 'Nível '}$nivel'),
      const SizedBox(height: 16),
      MdRl(
        indice: 0,
        rotulo: en ? 'Max health' : 'Vida máxima',
        valor: MdQuadro(builder: (ctx) {
          final p = mdTrecho(ctx, 1100, 650, curva: Curves.easeOutCubic);
          final v = (vMax - dV + dV * p).round();
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Text('$v'),
            if (dV > 0) ...[const SizedBox(width: 6), Text('+$dV', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7FE0B5)))],
          ]);
        }),
      ),
      MdBotao(en ? 'Continue' : 'Continuar', atraso: 1400, aoTocar: fechar),
    ],
  );
}

/// Vida zerada: "DERROTA", "Você caiu", o herói caído e o que mudou.
Future<void> mostrarQueda(BuildContext context, EstadoJogo e, int moedasPerdidas) {
  Som.atual.tocar('morte');
  final en = e.idioma == 'en';
  final vMax = e.vidaMaxima;
  return abrirSheetMd(
    context,
    totalMs: 2400,
    filhos: (fechar) => [
      MdRotulo(en ? 'DEFEAT' : 'DERROTA'),
      MdTitulo(en ? 'You fell' : 'Você caiu'),
      ArteMd(estado: e, sprites: [MdSprite(e.heroi.img, baixo: 4, cinza: 1, giro: -math.pi / 2)]),
      MdRl(indice: 0, rotulo: en ? 'Coins lost' : 'Moedas perdidas', valor: Text('−$moedasPerdidas')),
      MdRl(indice: 1, rotulo: en ? 'Health restored' : 'Vida restaurada', valor: Text('$vMax / $vMax')),
      MdBotao(en ? 'Get up' : 'Levantar', atraso: 1200, aoTocar: fechar),
    ],
  );
}

/// Dia vencido: monstro derrotado, barra de nível, tarefas, XP do dia, estágio e as moedas da vitória.
Future<void> mostrarResumoDia(BuildContext context, EstadoJogo e, {required int nTarefas, required int ganho}) {
  Som.atual.tocar('levelup');
  final en = e.idioma == 'en';
  final p = e.progressoAtual;
  final pct = p.meta == 0 ? 0.0 : (p.resto / p.meta).clamp(0.0, 1.0).toDouble();
  final est = estagioAtual(e.totalConcluidas);
  final String rotuloEst;
  final String valorEst;
  if (est >= 4) {
    rotuloEst = '${en ? 'Stage ' : 'Estágio '}$est';
    valorEst = 'MAX';
  } else {
    final ini = est == 1 ? 0 : limiaresEstagio[est - 2];
    final alvo = limiaresEstagio[est - 1];
    rotuloEst = '${en ? 'To stage ' : 'Rumo ao estágio '}${est + 1}';
    valorEst = '${(e.totalConcluidas - ini).clamp(0, alvo - ini)} / ${alvo - ini}';
  }
  final m = e.monstro;
  final nomeM = m.nomeNoIdioma(e.idioma);
  return abrirSheetMd(
    context,
    totalMs: 2400,
    filhos: (fechar) => [
      MdRotulo(en ? 'DAY WON' : 'DIA VENCIDO'),
      MdTitulo(en ? '$nomeM defeated' : '$nomeM derrotado'),
      ArteMd(estado: e, sprites: [MdSprite(e.heroi.img, esquerda: 0.34, baixo: 16), MdSprite(m.img, esquerda: 0.66, baixo: 16, atraso: 800, cinza: 0.6)]),
      MdSegmentoUnico(fracao: pct, atraso: 600),
      MdLegenda('${en ? 'Level ' : 'Nível '}${romano(p.nivel)}', '${p.resto.toInt()} / ${p.meta.toInt()}', atraso: 600),
      const SizedBox(height: 16),
      MdRl(indice: 0, rotulo: en ? 'Tasks done' : 'Tarefas concluídas', valor: Text('$nTarefas')),
      MdRl(indice: 1, rotulo: en ? 'Experience' : 'Experiência', valor: Text('+${e.xpDoDia}')),
      MdRl(indice: 2, rotulo: rotuloEst, valor: Text(valorEst)),
      const MdRlLinha(indice: 3),
      MdRl(indice: 3, rotulo: en ? 'Coins' : 'Moedas', valor: Text('+$ganho'), total: true),
      MdBotao(en ? 'Continue' : 'Continuar', atraso: 1700, aoTocar: fechar),
    ],
  );
}

/// Virada do dia com tarefas largadas e o herói de pé: "Tarefas perdidas — Ele escapou."
Future<void> mostrarTarefasPerdidas(BuildContext context, EstadoJogo e, EventoVirada ev) {
  final en = e.idioma == 'en';
  final m = ev.diaVirada != null ? e.monstroDoDiaEm(ev.diaVirada!) : e.monstro;
  const base = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: corTexto);
  return abrirSheetMd(
    context,
    totalMs: 1800,
    filhos: (fechar) => [
      MdEntra(
        atraso: 100,
        filho: SizedBox(
          width: 56,
          height: 56,
          child: Transform.scale(
            scaleX: -1,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[0.17, 0.57, 0.06, 0, 0, 0.17, 0.57, 0.06, 0, 0, 0.17, 0.57, 0.06, 0, 0, 0, 0, 0, 1, 0]),
              child: Image.asset(m.img, filterQuality: FilterQuality.none, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      MdEntra(
        atraso: 150,
        filho: Text((en ? 'Skipped Tasks' : 'Tarefas Perdidas').toUpperCase(), style: const TextStyle(fontFamily: fontePixel, fontSize: 11, letterSpacing: 1.5, color: corVida)),
      ),
      const SizedBox(height: 8),
      MdEntra(
        atraso: 200,
        filho: Text(en ? 'It got away.' : 'Ele escapou.', style: const TextStyle(fontFamily: 'Cormorant Garamond', fontStyle: FontStyle.italic, fontVariations: [FontVariation('wght', 600)], fontSize: 20, height: 1.2, color: corTexto)),
      ),
      const SizedBox(height: 14),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: SingleChildScrollView(
          child: Column(children: [
            for (var i = 0; i < ev.tarefas.length; i++)
              MdEntra(
                atraso: 250 + math.min(i, 8) * 60,
                dur: 320,
                filho: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 0.8)),
                  child: Row(children: [
                    Expanded(child: Text(ev.tarefas[i].texto ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: base)),
                    const SizedBox(width: 10),
                    Builder(builder: (_) {
                      final pips = dificuldades.firstWhere((d) => d.id == ev.tarefas[i].dif).pips;
                      return Losangos(pips, cor: corDificuldade(pips));
                    }),
                  ]),
                ),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      MdEntra(atraso: 500, filho: Text(en ? '−${ev.dano} health' : '−${ev.dano} de vida', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: corVida))),
      MdBotao(en ? 'Continue' : 'Continuar', atraso: 600, aoTocar: fechar),
    ],
  );
}
