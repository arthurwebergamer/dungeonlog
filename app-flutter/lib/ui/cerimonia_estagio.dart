// Tela cheia "Estágio N Concluído!" (mostrarEstagioDesbloqueado, play/index.html ~12604): a arte do bioma anterior
// vira a do novo numa íris, o nome do bioma sobe, a barra de 4 estágios enche e os monstros novos aparecem em silhueta.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dominio/dados_jogo.dart';
import 'arena.dart' show FundoTema;
import 'estado_jogo.dart';
import 'sheet_md.dart';
import 'som.dart';
import 'tema.dart';

Future<void> mostrarCerimoniaEstagio(BuildContext context, EstadoJogo e, CerimoniaEstagio c) {
  Som.atual.tocar('estagioNovo');
  final en = e.idioma == 'en';
  return abrirSheetMd(
    context,
    totalMs: 3000,
    filhos: (fechar) => [
      MdRotulo(en ? 'STAGE REACHED' : 'ESTÁGIO ALCANÇADO'),
      MdTitulo(en ? 'Stage ${c.concluido} Complete!' : 'Estágio ${c.concluido} Concluído!'),
      _Arte(c: c, nome: en ? c.tema.nomeEn : c.tema.nome),
      _Segmentos(concluido: c.concluido),
      MdEntra(
        atraso: 600,
        filho: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${en ? 'Stage' : 'Estágio'} ${c.concluido} / 4', style: const TextStyle(fontSize: 12, color: corApagado)),
            if (c.alvo != null) Text('${c.alvo} / ${c.alvo} ${en ? 'tasks' : 'tarefas'}', style: const TextStyle(fontSize: 12, color: corApagado)),
          ]),
        ),
      ),
      if (c.monstros.isNotEmpty) ...[
        MdEntra(
          atraso: 1300,
          filho: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(en ? 'NEW MONSTERS IN THIS BIOME' : 'NOVOS MONSTROS NESTE BIOMA',
                  style: const TextStyle(fontFamily: fontePixel, fontSize: 10, letterSpacing: 1.6, color: corApagado)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          for (var i = 0; i < c.monstros.length; i++)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: i < c.monstros.length - 1 ? 8 : 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: MdEntra(atraso: 1400 + i * 70, dur: 550, mola: true, filho: _Silhueta(img: c.monstros[i].img, revelar: i == 0)),
                  ),
                ),
              ),
            ),
        ]),
      ],
      if (c.todosBiomas)
        MdEntra(
          atraso: 2000,
          filho: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              en ? "You've unlocked every biome! Swipe the Arena sideways to use whichever one you like." : 'Você desbloqueou todos os biomas! Arraste a Arena pro lado pra usar o que você quiser.',
              style: const TextStyle(fontSize: 13, color: corApagado, height: 1.4),
            ),
          ),
        ),
      MdBotao(en ? 'Continue' : 'Continuar', atraso: 2100, aoTocar: fechar),
    ],
  );
}

/// `.md-art`: 158 px de arte; o bioma anterior dá lugar ao novo numa íris, com um leve zoom, e o nome sobe de baixo.
class _Arte extends StatelessWidget {
  const _Arte({required this.c, required this.nome});
  final CerimoniaEstagio c;
  final String nome;

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
        final iris = mdTrecho(ctx, 550, 1000, curva: const Cubic(0.6, 0.05, 0.2, 1));
        final nomeY = 1 - mdTrecho(ctx, 1200, 600, curva: const Cubic(0.2, 0.9, 0.2, 1));
        return LayoutBuilder(builder: (_, caixa) {
          final raio = 0.8 * math.sqrt(caixa.maxWidth * caixa.maxWidth + caixa.maxHeight * caixa.maxHeight) / math.sqrt2 * iris;
          return Stack(children: [
            Positioned.fill(
              child: Transform.scale(
                scale: zoom,
                child: Stack(children: [
                  Positioned.fill(child: FundoTema(tema: c.anterior)),
                  Positioned.fill(
                    child: ClipPath(clipper: _Iris(raio, Offset(caixa.maxWidth * 0.5, caixa.maxHeight * 0.62)), child: FundoTema(tema: c.tema)),
                  ),
                ]),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x99000000)])),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 10,
              height: 34,
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(0, 34 * 1.1 * nomeY),
                  child: Text(nome, style: const TextStyle(fontFamily: 'Cormorant Garamond', fontStyle: FontStyle.italic, fontVariations: [FontVariation('wght', 600)], fontSize: 28, height: 34 / 28, color: Colors.white)),
                ),
              ),
            ),
          ]);
        });
      }),
    );
  }
}

class _Iris extends CustomClipper<Path> {
  _Iris(this.raio, this.centro);
  final double raio;
  final Offset centro;
  @override
  Path getClip(Size size) => Path()..addOval(Rect.fromCircle(center: centro, radius: raio));
  @override
  bool shouldReclip(_Iris o) => o.raio != raio;
}

/// `.md-seg`: 4 segmentos; os anteriores cheios, o concluído enche agora, os outros vazios.
class _Segmentos extends StatelessWidget {
  const _Segmentos({required this.concluido});
  final int concluido;
  @override
  Widget build(BuildContext context) => MdQuadro(builder: (ctx) {
        final enche = mdTrecho(ctx, 500, 800, curva: const Cubic(0.3, 0.7, 0.2, 1));
        return Row(children: [
          for (var k = 1; k <= 4; k++) ...[
            if (k > 1) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(color: k < concluido ? corOuro : corLinha, borderRadius: BorderRadius.circular(3)),
                clipBehavior: Clip.antiAlias,
                child: k == concluido ? Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: enche, child: const ColoredBox(color: corOuro, child: SizedBox.expand()))) : null,
              ),
            ),
          ],
        ]);
      });
}

/// `.md-mobs span`: quadrado com o monstro em silhueta; o primeiro é revelado depois de 2 s.
class _Silhueta extends StatelessWidget {
  const _Silhueta({required this.img, required this.revelar});
  final String img;
  final bool revelar;
  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(color: const Color(0x0FFFFFFF), borderRadius: BorderRadius.circular(14)),
          child: MdQuadro(builder: (ctx) {
            final r = revelar ? mdTrecho(ctx, 2000, 700) : 0.0;
            final imagem = Image.asset(img, width: 50, filterQuality: FilterQuality.none, fit: BoxFit.contain);
            return FractionallySizedBox(
              widthFactor: 0.62,
              heightFactor: 0.62,
              child: Stack(fit: StackFit.expand, children: [
                Opacity(opacity: 0.6 * (1 - r), child: ColorFiltered(colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn), child: Image.asset(img, filterQuality: FilterQuality.none, fit: BoxFit.contain))),
                Opacity(opacity: r, child: Image.asset(img, filterQuality: FilterQuality.none, fit: BoxFit.contain)),
              ]),
            );
          }),
        ),
      );
}
