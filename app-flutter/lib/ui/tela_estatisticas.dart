// Aba Estatísticas (#viewEstatisticas do original, tela "sem caixas" do CSS v2e/v2f): cabeçalho com o mês, cartão da
// sequência atual + "desde o início", abas Semanal/Mensal/Anual e, conforme a aba, taxa (anel) + composição do mês,
// últimos 7 dias (linha) e histórico (mês, semana ou ano). O bloco "estn" v2 do HTML é código morto (escondido por CSS)
// e não foi portado.
//
// PRO: os cartões de taxa, composição, 7 dias e histórico são Pro no original (`assinaturaAtiva()`). Aqui o ponto de
// ligação é `EstadoJogo.ehPro` (false até a Fase 7): bloqueado, o cartão ganha um véu escuro (o original usa blur, que
// aqui travava o celular) com o cadeado e o selo PRO; tocar avisa que o plano chega numa próxima versão.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../dominio/estatisticas.dart';
import '../dominio/historico.dart';
import '../dominio/save.dart' show nomeHeroiNorm;
import 'cartao_sequencia.dart';
import 'cfg_base.dart' show tr;
import 'estado_jogo.dart';
import 'folhas.dart';
import 'tela_config.dart' show avisoEmBreve;
import 'tema.dart';
import 'tour.dart';
import 'topo.dart';
import 'tocha_est.dart';
import 'vibra.dart';

// A escolha de aba e de ano vale enquanto o app está aberto (no original são variáveis do módulo).
String _periodoAtual = 'mes';
int? _anoEscolhido;
double _ultimoPctAnel = 0;

/// Volta ao estado de quando o app abre (testes).
void reiniciarEstadoEstatisticas() {
  _periodoAtual = 'mes';
  _anoEscolhido = null;
  _ultimoPctAnel = 0;
}

TextStyle _outfit(double tam, Color cor, {FontWeight peso = FontWeight.w400, double ls = 0, double altura = 1.26}) =>
    TextStyle(fontFamily: 'Outfit', fontSize: tam, fontWeight: peso, color: cor, letterSpacing: ls, height: altura, leadingDistribution: TextLeadingDistribution.even);

TextStyle _pixel(double tam, Color cor, {double altura = 1.28}) =>
    TextStyle(fontFamily: fontePixel, fontSize: tam, color: cor, height: altura, leadingDistribution: TextLeadingDistribution.even);

Color _corVar(String n) => switch (n) {
      'accent' => corAccent,
      'gold' => corOuro,
      _ => corTexto,
    };

/// `corDoStreak(streak)` como cor do tema atual.
Color corDoNumero(int streak) {
  final m = corDoStreak(streak);
  if (m == null) return corApagado;
  if (m.de == 'gold') return corOuro;
  return Color.lerp(_corVar(m.de), _corVar(m.para), m.pct / 100)!;
}

const _svgCadeado =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="11" width="14" height="9" rx="2.5"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/></svg>';
const _svgSeta = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M9 6l6 6-6 6"/></svg>';
const _svgAnterior = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 6l-6 6 6 6"/></svg>';
const _svgProximo = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 6l6 6-6 6"/></svg>';
const _svgCompartilhar =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12"/><path d="M7 8l5-5 5 5"/><path d="M5 15v3a2 2 0 002 2h10a2 2 0 002-2v-3"/></svg>';

Widget _svg(String s, double tam, Color cor) => SvgPicture.string(s, width: tam, height: tam, theme: SvgTheme(currentColor: cor));

class TelaEstatisticas extends StatefulWidget {
  const TelaEstatisticas({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaEstatisticas> createState() => _TelaEstatisticasState();
}

class _TelaEstatisticasState extends State<TelaEstatisticas> {
  EstadoJogo get e => widget.estado;

  void _trocarAba(String id) {
    if (_periodoAtual == id) return;
    Vibra.toque();
    setState(() {
      _periodoAtual = id;
      if (id == 'ano') _anoEscolhido = null;
    });
  }

  void _avisoPro() {
    final en = e.idioma == 'en';
    avisoEmBreve(context, e, pro: en ? 'The full statistics panel' : 'O painel de estatísticas completo');
  }

  void _abrirSequencia(int streak, String rotulo) {
    Vibra.toque();
    abrirFolha<void>(context, (_) => FolhaSequencia(estado: e, streak: streak, rotulo: rotulo));
  }

  String _rotuloSequencia(ResumoEst r) {
    String t(String k) => tr(e, k);
    return switch (r.rotulo) {
      RotuloSequencia.vencaHoje => t('est.vencaHoje'),
      RotuloSequencia.recordeAtual => t('est.recordeAtual'),
      RotuloSequencia.faltaUm => t('est.recordeFaltaUm').replaceFirst('{recorde}', '${r.recorde}'),
      RotuloSequencia.faltam => t('est.recordeFaltam').replaceFirst('{recorde}', '${r.recorde}').replaceFirst('{faltam}', '${r.faltam}'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final hoje = e.hoje;
        final hist = e.histAoVivo;
        final r = resumoEstatisticas(hist, hoje);
        final am = anoMesDe(hoje);
        final bloq = !e.ehPro;
        final en = e.idioma == 'en';
        return SafeArea(
          bottom: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TopoApp(estado: e),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // .vhead: título e mês, alinhados pela linha de base
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(tr(e, 'nav.estatisticas'), style: _outfit(16, corTexto, peso: FontWeight.w600)),
                    const Spacer(),
                    Text(rotuloMesAno(am.ano, am.mes, e.idioma), style: _outfit(12, corApagado)),
                  ]),
                  const SizedBox(height: 14),
                  _cartaoPrincipal(r),
                  _abas(en),
                  if (_periodoAtual == 'mes') _linhaTaxa(r, bloq),
                  if (_periodoAtual == 'semana') _cartao7Dias(hist, hoje, bloq),
                  _cartaoHistorico(hist, hoje, am, bloq),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ---------- cartão da sequência + desde o início ----------
  Widget _cartaoPrincipal(ResumoEst r) {
    final streak = r.streak;
    final rotulo = _rotuloSequencia(r);
    final titulo = tr(e, 'est.sequenciaAtual').toUpperCase();
    final tituloStyle = _outfit(11.5, corSuave, peso: FontWeight.w600, ls: 0.805);
    return Toque(
      key: TourAlvos.estCardPrincipal,
      escala: 0.97,
      aoTocar: () => _abrirSequencia(streak, rotulo),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // .est-streakcard: gradiente 135deg, a tocha cresce com a sequência e é cortada pelo cartão
            CustomPaint(
              painter: _Fundo135(corPainel3, corPainel2, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text(titulo, style: tituloStyle),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 46,
                        child: Text('$streak', style: _pixel(46, corDoNumero(streak), altura: 1)),
                      ),
                    ]),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 12,
                    child: Transform.scale(
                      scale: escalaTocha(streak),
                      alignment: Alignment.bottomRight,
                      child: streak == 0 ? const TochaSprite(variante: VarianteTocha.apagada) : const TochaChama(),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            Text(tr(e, 'est.desdeInicio').toUpperCase(), style: tituloStyle),
            const SizedBox(height: 12),
            Row(children: [
              _resumo('${e.totalConcluidas}', tr(e, 'est.tarefasConcluidas')),
              const SizedBox(width: 10),
              _resumo('${r.vitoriasTotal}', tr(e, 'est.diasVencidos')),
              const SizedBox(width: 10),
              _resumo('${r.taxaGeral}%', tr(e, 'est.taxaGeral')),
            ]),
          ]),
        ),
        Positioned(top: 22, right: 18, child: _svg(_svgSeta, 15, corApagado)),
      ]),
    );
  }

  Widget _resumo(String num, String rotulo) => Expanded(
        child: Column(children: [
          Text(num, style: _pixel(22, corTexto, altura: 1.2727)),
          const SizedBox(height: 4),
          Text(rotulo, textAlign: TextAlign.center, style: _outfit(11, corApagado, altura: 1.3)),
        ]),
      );

  // ---------- abas Semanal / Mensal / Anual ----------
  Widget _abas(bool en) {
    final nomes = {'semana': en ? 'Weekly' : 'Semanal', 'mes': en ? 'Monthly' : 'Mensal', 'ano': en ? 'Yearly' : 'Anual'};
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: corLinha, width: 0.8))),
        child: Row(children: [
          for (final id in const ['semana', 'mes', 'ano']) ...[
            if (id != 'semana') const SizedBox(width: 24),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _trocarAba(id),
              child: Semantics(
                button: true,
                selected: _periodoAtual == id,
                child: SizedBox(
                  height: 28.4,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Text(nomes[id]!, style: _outfit(14, _periodoAtual == id ? corTexto : corApagado, peso: FontWeight.w600)),
                    if (_periodoAtual == id) Positioned(left: 0, right: 0, bottom: -1, child: Container(height: 2, color: corAccent)),
                  ]),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  // ---------- taxa de conclusão + como foi o mês (aba Mensal) ----------
  Widget _linhaTaxa(ResumoEst r, bool bloq) {
    final tituloStyle = _outfit(11.5, corSuave, peso: FontWeight.w600, ls: 0.805, altura: 1.3);
    Widget legenda(Color cor, String rotulo, int n) => SizedBox(
          height: 16,
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 7),
            Text(rotulo, style: _outfit(13, corSuave, altura: 1.2)),
            const Spacer(),
            Text('$n', style: _outfit(13, corTexto, peso: FontWeight.w600, altura: 1.2)),
          ]),
        );
    final colTaxa = _Trava(
      bloqueado: bloq,
      aoTocar: _avisoPro,
      child: SizedBox(
        width: 112,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 29.9),
            child: Text(tr(e, 'est.taxaConclusaoTitulo').toUpperCase(), style: tituloStyle),
          ),
          const SizedBox(height: 12 + 4),
          _AnelTaxa(taxa: r.taxaMes, unidade: tr(e, 'est.mes')),
        ]),
      ),
    );
    final colMes = Expanded(
      child: _Trava(
        bloqueado: bloq,
        aoTocar: _avisoPro,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 29.9),
            child: Text(tr(e, 'est.comoFoiMes').toUpperCase(), style: tituloStyle),
          ),
          const SizedBox(height: 12 + 6),
          legenda(corAccent, tr(e, 'est.vitoria'), r.vitoriasMes),
          const SizedBox(height: 12),
          legenda(corAccent.withValues(alpha: 0.4), tr(e, 'est.fuga'), r.fugasMes),
          const SizedBox(height: 12),
          legenda(const Color(0xFF6F86E0), tr(e, 'est.descanso'), r.descansoMes),
          const SizedBox(height: 12),
          legenda(corPainel3, tr(e, 'est.semTarefa'), r.semTarefaMes),
        ]),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [colTaxa, const SizedBox(width: 22), colMes]),
    );
  }

  // ---------- últimos 7 dias (aba Semanal) ----------
  Widget _cartao7Dias(List<EntradaHist> hist, String hoje, bool bloq) {
    final g = ultimos7Dias(hist, hoje);
    final nomes = e.idioma == 'en' ? diasSemanaEn : diasSemanaPt;
    return _Trava(
      bloqueado: bloq,
      aoTocar: _avisoPro,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(tr(e, 'est.ultimos7').toUpperCase(), style: _outfit(11.5, corSuave, peso: FontWeight.w600, ls: 0.805)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              // o svg é "inline": 80 de gráfico + 4 de folga da linha de base
              SizedBox(height: 84, child: Align(alignment: Alignment.topLeft, child: _Grafico7(pontos: g.pontos))),
              const SizedBox(height: 8),
              SizedBox(
                height: 14,
                child: LayoutBuilder(
                  builder: (_, c) => Stack(clipBehavior: Clip.none, children: [
                    for (var i = 0; i < 7; i++)
                      Positioned(
                        left: c.maxWidth * i / 6,
                        top: 0,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: Text(nomes[g.diasSemana[i]], style: _outfit(10.5, i == 6 ? corTexto : corApagado, peso: i == 6 ? FontWeight.w700 : FontWeight.w400, ls: 0.21)),
                        ),
                      ),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ---------- histórico (mês, semana ou ano) ----------
  Widget _cartaoHistorico(List<EntradaHist> hist, String hoje, ({int ano, int mes}) am, bool bloq) {
    final sufixoChave = _periodoAtual == 'semana' ? 'est.periodoSemana' : (_periodoAtual == 'ano' ? 'est.periodoAno' : 'est.periodoMes');
    final tituloStyle = _outfit(11.5, corSuave, peso: FontWeight.w600, ls: 0.805);
    final comBorda = _periodoAtual != 'ano';
    final anoAlvo = anoEfetivo(_anoEscolhido, am.ano);
    Widget corpo;
    if (_periodoAtual == 'semana') {
      corpo = _GradeDias(dias: mapaDaSemana(hist, hoje));
    } else if (_periodoAtual == 'ano') {
      corpo = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _seletorAno(anoAlvo, am.ano),
        const SizedBox(height: 14),
        _GradeAno(meses: mapaDoAno(hist, anoAlvo, hoje), nomes: e.idioma == 'en' ? mesesCurtosEn : mesesCurtosPt),
      ]);
    } else {
      corpo = _GradeDias(dias: mapaDoMes(hist, am.ano, am.mes, hoje));
    }
    final miolo = Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text(tr(e, 'est.mapaDoMes').toUpperCase(), style: tituloStyle),
          const SizedBox(width: 7),
          Text(tr(e, sufixoChave).toUpperCase(), style: tituloStyle.copyWith(fontWeight: FontWeight.w400, color: corApagado)),
        ]),
        const SizedBox(height: 12),
        corpo,
        const SizedBox(height: 10),
        _legendaMapa(),
      ]),
    );
    return Container(
      decoration: BoxDecoration(border: comBorda ? Border(top: BorderSide(color: corLinha, width: 0.8)) : null),
      child: bloq
          ? Toque(escala: 0.97, aoTocar: _avisoPro, child: _Trava(bloqueado: true, aoTocar: _avisoPro, child: miolo))
          : miolo,
    );
  }

  Widget _seletorAno(int ano, int anoHoje) {
    Widget botao(String svg, bool ativo, VoidCallback aoTocar) => Opacity(
          opacity: ativo ? 1 : 0.3,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: ativo ? aoTocar : null,
            child: SizedBox(width: 28, height: 28, child: Center(child: _svg(svg, 16, corApagado))),
          ),
        );
    return SizedBox(
      height: 28,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Semantics(label: e.idioma == 'en' ? 'Previous year' : 'Ano anterior', child: botao(_svgAnterior, true, () => setState(() => _anoEscolhido = ano - 1))),
        const SizedBox(width: 16),
        ConstrainedBox(constraints: const BoxConstraints(minWidth: 44), child: Text('$ano', textAlign: TextAlign.center, style: _pixel(15, corTexto))),
        const SizedBox(width: 16),
        Semantics(label: e.idioma == 'en' ? 'Next year' : 'Próximo ano', child: botao(_svgProximo, ano < anoHoje, () => setState(() => _anoEscolhido = ano + 1))),
      ]),
    );
  }

  Widget _legendaMapa() {
    Widget tile(Color fundo, Color borda) => Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(4), border: Border.all(color: borda, width: 0.8)),
        );
    Widget rot(String k) => Text(tr(e, k), style: _outfit(9.5, corApagado));
    return Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
      tile(corPainel3, corLinha),
      rot('est.semTarefa'),
      tile(_fundoFuga, _fundoFuga),
      rot('est.fuga'),
      tile(_fundoVitoria, _fundoVitoria),
      rot('est.vitoria'),
      tile(_fundoDescanso, _fundoDescanso),
      rot('est.descanso'),
    ]);
  }
}

const _fundoVitoria = Color(0xFF3A2E1A);
const _fundoFuga = Color(0xFF3C3C44);
const _fundoDescanso = Color(0xFF4A60B8);

/// Gradiente de 135 graus do CSS (`linear-gradient(135deg, a, b)`) num retângulo que não é quadrado.
class _Fundo135 extends CustomPainter {
  _Fundo135(this.a, this.b, this.raio);
  final Color a, b;
  final double raio;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final meio = (size.width + size.height) * math.sqrt1_2 / 2; // metade do comprimento da linha do gradiente
    final d = Offset(math.sqrt1_2, math.sqrt1_2) * meio;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(raio)),
      Paint()..shader = ui.Gradient.linear(c - d, c + d, [a, b]),
    );
  }

  @override
  bool shouldRepaint(_Fundo135 old) => old.a != a || old.b != b || old.raio != raio;
}

/// Véu do Pro: com [bloqueado], o conteúdo fica por baixo de um véu escuro com o cadeado e o selo PRO; tocar chama [aoTocar].
class _Trava extends StatelessWidget {
  const _Trava({required this.bloqueado, required this.aoTocar, required this.child});
  final bool bloqueado;
  final VoidCallback aoTocar;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!bloqueado) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: Stack(children: [
        IgnorePointer(child: child),
        Positioned.fill(child: ColoredBox(color: corFundo.withValues(alpha: 0.82))),
        Positioned.fill(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _svg(_svgCadeado, 20, corTexto),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: corAccent, borderRadius: BorderRadius.circular(999)),
                child: Text('PRO', style: _outfit(8, corSobreAccent, peso: FontWeight.w700, ls: 0.3)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Anel da taxa do mês (`.est-ringbox`, 100x100): trilha cinza, arco em degradê e o número no meio.
class _AnelTaxa extends StatelessWidget {
  const _AnelTaxa({required this.taxa, required this.unidade});
  final int taxa;
  final String unidade;
  @override
  Widget build(BuildContext context) {
    final de = _ultimoPctAnel;
    _ultimoPctAnel = taxa.toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: de, end: taxa.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => SizedBox(
        width: 100,
        height: 100,
        child: CustomPaint(
          painter: _PintorAnel(v, taxa),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$taxa%', style: _pixel(15, corAccent, altura: 1.28)),
              Text(unidade, style: _outfit(7, corApagado, ls: 0.42, altura: 1.26)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PintorAnel extends CustomPainter {
  _PintorAnel(this.pct, this.taxa);
  final double pct;
  final int taxa;
  @override
  void paint(Canvas canvas, Size size) {
    const largura = 6.0;
    final r = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - largura / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = largura
      ..color = corPainel3;
    canvas.drawArc(r, 0, math.pi * 2, false, base);
    if (taxa == 0) return;
    final traco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = largura;
    if (pct >= 99.5) {
      canvas.drawArc(r, 0, math.pi * 2, false, traco..color = corAccent);
      return;
    }
    // conic-gradient(from 0deg, accent 35% -> accent em pct%): o arco começa no topo e vai no sentido horário
    final varre = math.pi * 2 * pct / 100;
    if (varre < 0.01) return; // começo da animação: o gradiente cônico exige um arco maior que zero
    traco.shader = SweepGradient(
      startAngle: 0,
      endAngle: varre,
      colors: [corAccent.withValues(alpha: 0.35), corAccent],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(r);
    canvas.drawArc(r, -math.pi / 2, varre, false, traco);
  }

  @override
  bool shouldRepaint(_PintorAnel old) => old.pct != pct || old.taxa != taxa;
}

/// Gráfico dos últimos 7 dias (viewBox 300x80 esticado na largura): linha, área em degradê e pontos, com a entrada animada.
class _Grafico7 extends StatefulWidget {
  const _Grafico7({required this.pontos});
  final List<PontoGrafico> pontos;
  @override
  State<_Grafico7> createState() => _Grafico7State();
}

class _Grafico7State extends State<_Grafico7> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) => AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(size: Size(c.maxWidth, grafAltura), painter: _PintorGrafico7(widget.pontos, _c.value, corAccent)),
        ),
      );
}

class _PintorGrafico7 extends CustomPainter {
  _PintorGrafico7(this.pontos, this.t, this.cor);
  final List<PontoGrafico> pontos;
  final double t; // 0..1 sobre 1,1 s
  final Color cor;

  double _faixa(double ini, double fim, [Curve c = Curves.linear]) => c.transform(((t * 1.1 - ini) / (fim - ini)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.isEmpty) return;
    canvas.clipRect(Offset.zero & size); // o svg corta o que passa da caixa (o 1º ponto fica pela metade)
    canvas.scale(size.width / grafLargura, 1); // preserveAspectRatio="none"
    final linha = Path()..moveTo(pontos.first.x, pontos.first.y);
    for (final p in pontos.skip(1)) {
      linha.lineTo(p.x, p.y);
    }
    final xFim = pontos.last.x;
    final area = Path.from(linha)
      ..lineTo(xFim, grafAltura)
      ..lineTo(0, grafAltura)
      ..close();
    final topo = pontos.map((p) => p.y).reduce(math.min);
    final opArea = _faixa(0.3, 0.8, Curves.easeOutCubic);
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, topo), const Offset(0, grafAltura), [cor.withValues(alpha: 0.35 * opArea), cor.withValues(alpha: 0)]),
    );
    final prog = _faixa(0, 0.65, const Cubic(0.16, 1, 0.3, 1));
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = cor;
    for (final m in linha.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * prog), stroke);
    }
    for (var i = 0; i < pontos.length; i++) {
      final k = _faixa(0.5 + i * 0.05, 0.8 + i * 0.05, Curves.easeOutBack);
      if (k <= 0) continue;
      canvas.drawCircle(Offset(pontos[i].x, pontos[i].y), 4 * k, Paint()..color = cor.withValues(alpha: pontos[i].alfa * math.min(1, k)));
    }
  }

  @override
  bool shouldRepaint(_PintorGrafico7 old) => old.t != t || old.cor != cor || old.pontos != pontos;
}

/// Mapa de dias em 7 colunas (mês e semana): cada tile é um quadrado com a tocha do resultado e o número do dia.
class _GradeDias extends StatelessWidget {
  const _GradeDias({required this.dias});
  final List<DiaMapa> dias;
  @override
  Widget build(BuildContext context) {
    final linhas = <List<DiaMapa>>[];
    for (var i = 0; i < dias.length; i += 7) {
      linhas.add(dias.sublist(i, math.min(i + 7, dias.length)));
    }
    return Column(children: [
      for (var i = 0; i < linhas.length; i++) ...[
        if (i > 0) const SizedBox(height: 5),
        Row(children: [
          for (var j = 0; j < 7; j++) ...[
            if (j > 0) const SizedBox(width: 5),
            Expanded(child: j < linhas[i].length ? AspectRatio(aspectRatio: 1, child: _TileDia(linhas[i][j])) : const SizedBox.shrink()),
          ],
        ]),
      ],
    ]);
  }
}

class _TileDia extends StatelessWidget {
  const _TileDia(this.d);
  final DiaMapa d;
  @override
  Widget build(BuildContext context) {
    final r = d.resultado;
    Color fundo = corPainel3, borda = corLinha, texto = corApagado;
    VarianteTocha? tocha;
    if (r == resVitoria) {
      fundo = borda = _fundoVitoria;
      texto = const Color(0xFFF2E7D5);
      tocha = VarianteTocha.acesa;
    } else if (r == resDescanso) {
      fundo = borda = _fundoDescanso;
      texto = const Color(0xFFDFE5FF);
      tocha = VarianteTocha.descanso;
    } else if (r == resFuga) {
      fundo = borda = _fundoFuga;
      texto = const Color(0xFFB4B4BC);
      tocha = VarianteTocha.apagada;
    }
    return Container(
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(4), border: Border.all(color: borda, width: 0.8)),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        if (tocha != null)
          Positioned(
            top: 2,
            left: 0,
            right: 0,
            child: Center(child: Transform.scale(scale: 0.85, alignment: Alignment.topCenter, child: TochaSprite(variante: tocha))),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 1,
          child: Text(
            '${d.dia}',
            textAlign: TextAlign.center,
            style: _outfit(8.5, texto, peso: FontWeight.w600, altura: 1.3).copyWith(shadows: const [Shadow(color: Color(0xD9000000), offset: Offset(0, 1), blurRadius: 2)]),
          ),
        ),
      ]),
    );
  }
}

/// Visão do ano: uma linha por mês (jan a dez) com um quadradinho de 9 px por dia, quebrando a linha quando falta largura.
class _GradeAno extends StatelessWidget {
  const _GradeAno({required this.meses, required this.nomes});
  final List<List<String?>> meses;
  final List<String> nomes;
  @override
  Widget build(BuildContext context) {
    Color cor(String? r) => switch (r) {
          resVitoria => _fundoVitoria,
          resFuga => const Color(0xFF242428),
          resDescanso => const Color(0xFF4D5A8F),
          _ => corPainel3,
        };
    return Column(children: [
      for (var m = 0; m < 12; m++) ...[
        if (m > 0) const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: 24, child: Text(nomes[m], style: _outfit(9.5, corApagado, altura: 1.26))),
          const SizedBox(width: 7),
          Expanded(
            child: Wrap(spacing: 3, runSpacing: 3, children: [
              for (final r in meses[m]) Container(width: 9, height: 9, decoration: BoxDecoration(color: cor(r), borderRadius: BorderRadius.circular(3))),
            ]),
          ),
        ]),
      ],
    ]);
  }
}

/// Folha "Sequência atual" (`#estMontanhaOverlay`): o número, a frase, a tocha crescendo sobre o brilho e o botão Compartilhar.
class FolhaSequencia extends StatefulWidget {
  const FolhaSequencia({super.key, required this.estado, required this.streak, required this.rotulo});
  final EstadoJogo estado;
  final int streak;
  final String rotulo;
  @override
  State<FolhaSequencia> createState() => _FolhaSequenciaState();
}

class _FolhaSequenciaState extends State<FolhaSequencia> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _compartilhar() async {
    if (_enviando) return;
    setState(() => _enviando = true);
    final e = widget.estado;
    final ok = await compartilharSequencia(streak: widget.streak, nome: nomeHeroiNorm(e.save.nomeHeroi, e.idioma), idioma: e.idioma);
    if (!mounted) return;
    setState(() => _enviando = false);
    if (!ok) {
      final en = e.idioma == 'en';
      await mostrarAviso(
        context,
        titulo: en ? 'Could not share' : 'Não foi possível compartilhar',
        texto: en ? 'The share sheet did not open on this device.' : 'A folha de compartilhamento não abriu neste aparelho.',
        botao: 'OK',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    final streak = widget.streak;
    final mq = MediaQuery.of(context);
    final escala = escalaTocha(streak);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          // #estMontanhaOverlay .edsheet: fundo roxo fixo (não segue o tema), só a borda de cima
          decoration: const BoxDecoration(
            color: Color(0xFF251E38),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: Color(0xFF3B3257), width: 0.8)),
          ),
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 18 + mq.viewPadding.bottom),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SizedBox(height: 6),
                Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: corLinha, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 14),
                Text(tr(e, 'est.sequenciaAtual').toUpperCase(), style: _outfit(12, corApagado, peso: FontWeight.w600, ls: 0.84)),
                const SizedBox(height: 10),
                Text('$streak', textAlign: TextAlign.center, style: _outfit(34, corDoNumero(streak), peso: FontWeight.w600)),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 15),
                  child: Text(widget.rotulo, textAlign: TextAlign.center, style: _outfit(11.5, corApagado)),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 130,
                    child: ColoredBox(
                      color: corPainel,
                      child: AnimatedBuilder(
                        animation: _c,
                        builder: (_, __) {
                          final brilho = streak > 0 ? Curves.ease.transform(_c.value) : 0.0;
                          final k = (_c.value * 1.1).clamp(0.0, 1.0);
                          final cresce = const Cubic(0.2, 0.9, 0.25, 1.3).transform(k);
                          final opac = Curves.ease.transform(((_c.value * 1.1) / 0.5).clamp(0.0, 1.0));
                          return Stack(children: [
                            Positioned.fill(
                              child: Opacity(
                                opacity: brilho,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: const Alignment(0, 0.7),
                                      radius: 1.62,
                                      colors: [corAccent.withValues(alpha: 0.35), const Color(0x00000000)],
                                      stops: const [0, 0.6],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Opacity(
                                  opacity: opac,
                                  child: Transform.scale(
                                    scale: (0.3 + 0.7 * cresce) * escala,
                                    alignment: Alignment.bottomCenter,
                                    child: streak == 0 ? const TochaSprite(variante: VarianteTocha.apagada) : const TochaChama(),
                                  ),
                                ),
                              ),
                            ),
                          ]);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Opacity(
                  opacity: _enviando ? 0.6 : 1,
                  child: Toque(
                    escala: 0.97,
                    aoTocar: _enviando ? null : _compartilhar,
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF2A65A), Color(0xFFE949CE)]),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _svg(_svgCompartilhar, 17, const Color(0xFF1A1526)),
                        const SizedBox(width: 8),
                        Text(tr(e, 'est.compartilhar'), style: _outfit(14, const Color(0xFF1A1526), peso: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
            Positioned(
              top: 10,
              right: 12,
              child: Toque(
                rotulo: e.idioma == 'en' ? 'Close' : 'Fechar',
                aoTocar: () => Navigator.pop(context),
                child: SizedBox(width: 32, height: 32, child: Center(child: Text('×', style: TextStyle(fontSize: 22, color: corApagado, height: 1)))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
