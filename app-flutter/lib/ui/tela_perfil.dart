// Aba Perfil (#viewPerfil do original): cabeçalho com "Nível" e a engrenagem, anel de XP e de vida com o herói dentro,
// nome e legenda, e os cartões de Conquistas e Bestiário (cada um abre uma tela cheia).
// O sistema de atributos (Fortuna/Foco/Vigor) está DESLIGADO no original e não foi portado; a linha de estatísticas
// (vida máxima, moedas, bônus) existe no HTML mas fica escondida por CSS, então também não aparece aqui.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dominio/conquistas.dart';
import '../dominio/historico.dart';
import '../dominio/save.dart' show nomeHeroiNorm;
import 'cfg_base.dart';
import 'estado_jogo.dart';
import 'folhas.dart';
import 'icones.dart';
import 'svg_icone.dart';
import 'tela_catalogo.dart';
import 'tela_config.dart';
import 'tema.dart';
import 'tour.dart';
import 'topo.dart';
import 'vibra.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key, required this.estado});
  final EstadoJogo estado;

  EstadoJogo get e => estado;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final en = e.idioma == 'en';
        final p = e.progressoAtual;
        final vMax = e.vidaMaxima;
        final vida = e.vida;
        final conq = e.conqDesbloq.length;
        final naoVistas = e.conquistasNaoVistas;
        final derrotados = e.monstrosDerrotadosIds;
        final vistos = ultimosMonstrosVistos(e.hist, hoje: e.hoje, monstroDeHojeSeVencido: e.derrotado ? e.monstroDoDiaIdx : null);
        return SafeArea(
          bottom: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TopoApp(estado: e),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // .vhead
                  SizedBox(
                    height: 34,
                    child: Row(children: [
                      Text(tr(e, 'nav.perfil'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: corTexto, height: 1.25)),
                      const Spacer(),
                      Text('${en ? 'Level ' : 'Nível '}${romano(p.nivel)}', style: TextStyle(fontSize: 12, color: corApagado, height: 1.26)),
                      const SizedBox(width: 10),
                      Semantics(
                        button: true,
                        label: tr(e, 'cfg.configuracoes'),
                        child: Toque(
                          aoTocar: () {
                            Vibra.toque();
                            abrirConfiguracoes(context, e);
                          },
                          child: Container(
                            key: TourAlvos.perfilCfgBtn,
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 0.8)),
                            child: Center(child: IconeSvg('engrenagem', tamanho: 17, cor: corSuave)),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14 + 12),
                  Center(child: AnelHeroi(estado: e, xp: p.meta == 0 ? 0 : p.resto / p.meta, vida: vMax == 0 ? 0 : vida / vMax)),
                  const SizedBox(height: 28 + 4),
                  Center(child: Text(nomeHeroiNorm(e.save.nomeHeroi, e.idioma), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: corTexto, height: 1.27))),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _Legenda(cor: const Color(0xFFE5698A), rotulo: tr(e, 'jogo.vida'), valor: '$vida / $vMax'),
                    const SizedBox(width: 18),
                    _Legenda(cor: const Color(0xFFF2C94C), rotulo: 'XP', valor: '${p.resto} / ${p.meta}'),
                  ]),
                  const SizedBox(height: 28),
                  // cartão Conquistas
                  _PreviaLinha(
                    chave: TourAlvos.prevConquistas,
                    titulo: tr(e, 'perfil.conquistas'),
                    texto: en ? '$conq of ${conquistasV2.length} unlocked' : '$conq de ${conquistasV2.length} desbloqueadas',
                    botao: tr(e, 'acao.verTodas'),
                    bolinha: naoVistas,
                    aoTocar: () {
                      Vibra.toque();
                      abrirConquistas(context, e);
                    },
                  ),
                  const SizedBox(height: 28),
                  // cartão Bestiário
                  _PreviaLinha(
                    chave: TourAlvos.prevBestiario,
                    titulo: tr(e, 'perfil.bestiario'),
                    texto: en
                        ? '${derrotados.length} of ${e.dados.monstros.length} monsters defeated'
                        : '${derrotados.length} de ${e.dados.monstros.length} monstros derrotados',
                    botao: tr(e, 'acao.verTudo'),
                    aoTocar: () {
                      Vibra.toque();
                      abrirBestiario(context, e);
                    },
                    rodape: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(children: [
                        for (var i = 0; i < 6; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Expanded(child: AspectRatio(aspectRatio: 1, child: _CelulaPrevia(estado: e, idx: i < vistos.length ? vistos[i] : null))),
                        ],
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.rotulo, required this.valor});
  final Color cor;
  final String rotulo;
  final String valor;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text.rich(
          TextSpan(style: TextStyle(fontSize: 12.5, color: corSuave, height: 1.28), children: [
            TextSpan(text: '$rotulo '),
            TextSpan(text: valor, style: TextStyle(fontWeight: FontWeight.w700, color: corTexto)),
          ]),
        ),
      ]);
}

/// Linha de prévia (`#prevConquistas` / `#prevBestiario`): linha fina em cima, título e texto à esquerda, botão à direita.
class _PreviaLinha extends StatelessWidget {
  const _PreviaLinha({this.chave, required this.titulo, required this.texto, required this.botao, required this.aoTocar, this.bolinha = 0, this.rodape});
  final GlobalKey? chave;
  final String titulo;
  final String texto;
  final String botao;
  final VoidCallback aoTocar;
  final int bolinha;
  final Widget? rodape;
  @override
  Widget build(BuildContext context) => Container(
        key: chave,
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: corLinha, width: 1))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(titulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: corTexto, height: 1.2)),
                const SizedBox(height: 2),
                Text(texto, style: TextStyle(fontSize: 11.5, color: corApagado, height: 1.26)),
              ]),
            ),
            const SizedBox(width: 12),
            Stack(clipBehavior: Clip.none, children: [
              CfgBotao(botao, aoTocar: aoTocar),
              if (bolinha > 0) Positioned(right: -5.2, top: -5.2, child: BolinhaAviso(bolinha)),
            ]),
          ]),
          if (rodape != null) rodape!,
        ]),
      );
}

/// Célula da prévia do bestiário (`.bestcel` do Perfil): monstro ou "?" tracejado.
class _CelulaPrevia extends StatelessWidget {
  const _CelulaPrevia({required this.estado, required this.idx});
  final EstadoJogo estado;
  final int? idx;
  @override
  Widget build(BuildContext context) {
    if (idx == null || idx! >= estado.dados.monstros.length) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: corFundo, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 1)),
        child: Text('?', style: TextStyle(fontFamily: fontePixel, fontSize: 13, color: corApagado)),
      );
    }
    final m = estado.dados.monstros[idx!];
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 0.8)),
      child: FractionallySizedBox(widthFactor: 0.7, heightFactor: 0.7, child: pixel(m.img)),
    );
  }
}

/// Anel grande (SVG 210x210): arco de XP por fora (r 92) e de vida por dentro (r 76), com o herói no centro (110 px).
class AnelHeroi extends StatelessWidget {
  const AnelHeroi({super.key, required this.estado, required this.xp, required this.vida});
  final EstadoJogo estado;
  final double xp;
  final double vida;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 210,
        height: 210,
        child: Stack(alignment: Alignment.center, children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: xp.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 500),
            builder: (_, vx, __) => TweenAnimationBuilder<double>(
              tween: Tween<double>(end: vida.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 500),
              builder: (_, vv, __) => CustomPaint(size: const Size(210, 210), painter: _PintorAnel(vx, vv, corLinha)),
            ),
          ),
          pixel(estado.heroi.img, largura: 110, altura: 110),
        ]),
      );
}

class _PintorAnel extends CustomPainter {
  _PintorAnel(this.xp, this.vida, this.trilho);
  final double xp;
  final double vida;
  final Color trilho;

  @override
  void paint(Canvas canvas, Size size) {
    const c = Offset(105, 105);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = trilho;
    canvas.drawCircle(c, 92, base);
    canvas.drawCircle(c, 76, base);
    Paint arco(Color cor) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = cor;
    // começa no topo (o SVG gira -90°) e vai no sentido horário
    if (xp > 0) canvas.drawArc(Rect.fromCircle(center: c, radius: 92), -math.pi / 2, 2 * math.pi * xp, false, arco(const Color(0xFFF2C94C)));
    if (vida > 0) canvas.drawArc(Rect.fromCircle(center: c, radius: 76), -math.pi / 2, 2 * math.pi * vida, false, arco(const Color(0xFFE5698A)));
  }

  @override
  bool shouldRepaint(_PintorAnel o) => o.xp != xp || o.vida != vida || o.trilho != trilho;
}
