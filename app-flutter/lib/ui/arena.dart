// Arena: parede de tijolos, duas tochas, herói x monstro do dia com "vs" no meio e a barra de vida fina
// em cima do monstro. Medidas e cores copiadas de .arena / .fight / .mobBarra / .vitoria do app original.
// Também desenha os baús do dia no canto esquerdo (.bauArena) e a arma e o escudo equipados no herói (desenharHeroi).
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../dominio/bau.dart' show tierRar;
import '../dominio/save.dart' show chaveConta;
import '../dominio/catalogo.dart';
import '../dominio/dados_jogo.dart' show TemaArena;
import '../dominio/regras.dart';
import 'equip_arena.dart';
import 'estado_jogo.dart';
import 'golpes_fx.dart';
import 'icones.dart';
import 'itens_ui.dart';
import 'popup_bau.dart' show imagemBau;
import 'som.dart';
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
  const Arena({super.key, required this.estado, required this.golpe, this.aoAbrirBau});
  final EstadoJogo estado;

  /// Toque num baú fechado que pode ser aberto: 'padrao', 'extra' ou 'especial' (este só quando há chave).
  final ValueChanged<String>? aoAbrirBau;

  /// Pedidos de golpe (conclusão de tarefa): o herói ataca e o monstro treme (golpes variados do original).
  final GolpeControlador golpe;

  @override
  State<Arena> createState() => _ArenaState();
}

class _ArenaState extends State<Arena> with TickerProviderStateMixin {
  // relógio único das animações em laço: chama das tochas (0,6 s em 3 quadros) e balanço do herói (1,1 s em passos)
  static const _cicloMs = 6600;
  late final MotorGolpe _motor = MotorGolpe(this);
  late final AnimationController _relogio = AnimationController(vsync: this, duration: const Duration(milliseconds: _cicloMs))..repeat();

  // ----- cenário: arrastar para o lado troca de bioma (touchstart/move/end de play/index.html ~5310) -----
  late final AnimationController _pouso = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..addListener(_pousando);
  double _larg = 360;
  double _dx = 0;
  double _dxInicio = 0;
  double _dxFim = 0;
  int? _alvo; // índice do cenário que entra
  int _frente = 0; // índice do cenário que sai (guardado durante o gesto)
  int _direcao = 0; // -1: puxa da esquerda, 1: puxa da direita
  bool _pontos = false;
  Timer? _pontosTimer;

  void _pousando() {
    setState(() => _dx = _dxInicio + (_dxFim - _dxInicio) * Curves.ease.transform(_pouso.value));
  }

  void _arrastoInicio(DragStartDetails d) {
    if (_pouso.isAnimating) return;
    _dx = 0;
    _alvo = null;
  }

  void _arrastoMove(DragUpdateDetails d) {
    if (_pouso.isAnimating) return;
    final e = widget.estado;
    setState(() {
      _dx = (_dx + d.delta.dx).clamp(-_larg, _larg);
      if (_alvo == null && _dx.abs() > 5) {
        _direcao = _dx > 0 ? -1 : 1;
        _frente = e.indiceTemaExibido;
        _alvo = (_frente + _direcao + e.dados.temas.length) % e.dados.temas.length;
        _pontosTimer?.cancel();
        _pontos = true;
      }
    });
  }

  void _arrastoFim(DragEndDetails d) {
    if (_alvo == null) return;
    final e = widget.estado;
    final passou = _dx.abs() > _larg * 0.16;
    _dxInicio = _dx;
    _dxFim = passou ? (_dx > 0 ? _larg : -_larg) : 0;
    if (passou) {
      HapticFeedback.selectionClick();
      e.pousarTema(_alvo!);
    }
    _pouso.forward(from: 0);
    _pontosTimer?.cancel();
    _pontosTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _pontos = false);
    });
  }

  /// As duas camadas de fundo acompanhando o dedo: a que sai e a que entra.
  Widget _fundos(EstadoJogo e) {
    final temas = e.dados.temas;
    final bloqueadaAtual = !e.temaDesbloqueado(e.indiceTemaExibido);
    if (_alvo == null) return FundoTema(tema: temas[e.indiceTemaExibido], bloqueado: bloqueadaAtual);
    final frente = temas[_frente];
    final entra = temas[_alvo!];
    final lado = _direcao > 0 ? _larg : -_larg;
    return Stack(clipBehavior: Clip.hardEdge, children: [
      Positioned.fill(child: Transform.translate(offset: Offset(_dx, 0), child: FundoTema(tema: frente, bloqueado: !e.temaDesbloqueado(_frente)))),
      Positioned.fill(child: Transform.translate(offset: Offset(_dx + lado, 0), child: FundoTema(tema: entra, bloqueado: !e.temaDesbloqueado(_alvo!)))),
    ]);
  }

  // ----- selo "Estágio N em X tarefas" (some sozinho depois de 3,5 s) -----
  bool _selo = false;
  Timer? _seloTimer;
  int? _totalVisto;
  int _tickVisto = 0;

  void _piscarSelo() {
    _seloTimer?.cancel();
    setState(() => _selo = true);
    _seloTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _selo = false);
    });
  }

  void _verSelo({required bool primeira}) {
    final e = widget.estado;
    final total = e.totalConcluidas;
    final tick = e.seloTick;
    final max = e.estagio >= 4;
    final mudou = !primeira && total != _totalVisto;
    final aba = tick != _tickVisto;
    _totalVisto = total;
    _tickVisto = tick;
    if (max) {
      if (primeira && e.consumirDicaArrastar()) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _piscarSelo() : null);
      return;
    }
    if (primeira || mudou || aba) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _piscarSelo() : null);
  }

  @override
  void initState() {
    super.initState();
    _pouso.addStatusListener((st) {
      if (st == AnimationStatus.completed && mounted) {
        setState(() {
          _alvo = null;
          _dx = 0;
        });
      }
    });
    _verSelo(primeira: true);
    widget.golpe.addListener(_aoGolpe);
    _espia.addListener(() {
      if (_alvo != null && _espia.isAnimating) setState(() => _dx = -44 * math.sin(math.pi * _espia.value));
    });
    _espia.addStatusListener((st) {
      if (st == AnimationStatus.completed && mounted) {
        setState(() {
          _alvo = null;
          _dx = 0;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _talvezEspiar());
  }

  late final AnimationController _espia = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  /// Primeira abertura com mais de um cenário liberado: a arena "espia" para o lado e volta (uma vez só).
  Future<void> _talvezEspiar() async {
    final e = widget.estado;
    const k = 'questlog.dicaSwipeArena.v3';
    final chave = chaveConta(k, uid: e.uid, personagem: e.personagem);
    if (e.estagio < 2 || e.armazenamento.ler(chave) != null) return;
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _alvo != null) return;
    e.armazenamento.gravar(chave, '1');
    setState(() {
      _frente = e.indiceTemaExibido;
      _direcao = 1;
      _alvo = (_frente + 1) % e.dados.temas.length;
    });
    _espia.forward(from: 0);
  }

  int _golpeVisto = 0;
  int _escapadaVista = 0;

  /// Geometria do herói e do monstro dentro da arena (a linha `.fight` fica centralizada: 83 + 28 + "VS" + 28 + 78).
  GeometriaGolpe _geometria() {
    const vs = 17.0;
    final largura = _larg;
    final esq = 16 + (largura - 32 - (83 + 28 + vs + 28 + 78)) / 2;
    return GeometriaGolpe(
      heroi: Rect.fromLTWH(esq, 56, 83, 87),
      monstro: Rect.fromLTWH(esq + 83 + 28 + vs + 28, 61, 78, 82),
      arena: Size(largura, 188),
    );
  }

  void _aoGolpe() {
    final g = widget.golpe;
    if (!mounted) return;
    if (g.contadorEscapada != _escapadaVista) {
      _escapadaVista = g.contadorEscapada;
      _motor.escapada(_geometria(), g.escapadas);
      return;
    }
    if (g.contador == _golpeVisto) return;
    _golpeVisto = g.contador;
    final e = widget.estado;
    final id = e.save.equipado['arma'];
    final arma = id is num ? e.catalogo.item(id) : null;
    _motor.raridade = (arma?.raridade ?? 0).clamp(0, 7);
    _motor.preferenciaVariada = e.armazenamento.ler('questlog.golpesVariados.v1') != '0';
    final distancia = arma != null && RegExp(r'^(Arco|Besta|Arbalesta|Zarabatana|Estilingue|Funda)', caseSensitive: false).hasMatch(arma.nome);
    _motor.golpear(g: _geometria(), dif: g.dif, fim: g.fim, distancia: distancia);
  }

  @override
  void didUpdateWidget(Arena old) {
    super.didUpdateWidget(old);
    _verSelo(primeira: false);
  }

  @override
  void dispose() {
    _dicaTimer?.cancel();
    _seloTimer?.cancel();
    _pontosTimer?.cancel();
    widget.golpe.removeListener(_aoGolpe);
    _espia.dispose();
    _motor.dispose();
    _pouso.dispose();
    _relogio.dispose();
    super.dispose();
  }

  // baú trancado tocado sem chave: mostra a dica por 1,8 s e para de pulsar (até aparecer uma chave ou virar o dia)
  bool _dicaVisivel = false;
  String? _bauPausado;
  Timer? _dicaTimer;

  void _tocarBau(String qual) {
    final e = widget.estado;
    if (!e.bauFechado(qual)) return;
    if (qual == 'especial' && e.chaveDoEspecial == null) {
      HapticFeedback.mediumImpact();
      Som.atual.tocar('bauTrancado');
      _dicaTimer?.cancel();
      setState(() {
        _dicaVisivel = true;
        _bauPausado = '${e.hoje}:${e.tierBauEspecial}';
      });
      _dicaTimer = Timer(const Duration(milliseconds: 1800), () {
        if (mounted) setState(() => _dicaVisivel = false);
      });
      return;
    }
    widget.aoAbrirBau?.call(qual);
  }

  /// Os baús do dia, na ordem do HTML: padrão, trancado (com a dica) e extra.
  List<Widget> _baus(EstadoJogo e) {
    final b = e.bauDia;
    if (b == null || b['dia'] != e.hoje) return const [];
    bool existe(String q) => b[q] is Map;
    bool aberto(String q) => (b[q] as Map)['aberto'] == true;
    final filhos = <Widget>[];
    if (existe('padrao')) {
      filhos.add(Positioned(
        left: 24,
        bottom: 47,
        child: _BauArena(key: ValueKey('padrao-${b['dia']}'), variante: 'padrao', aberto: aberto('padrao'), aoTocar: () => _tocarBau('padrao')),
      ));
    }
    if (existe('especial')) {
      final tier = (((b['especial'] as Map)['tier'] as num?) ?? 0).toInt().clamp(0, 3);
      final ab = aberto('especial');
      final pausado = !ab && _bauPausado == '${e.hoje}:$tier' && e.chaveDoEspecial == null;
      filhos.add(Positioned(
        left: 4,
        bottom: 91,
        child: _BauArena(
          key: ValueKey('especial-${b['dia']}'),
          variante: 't$tier',
          aberto: ab,
          trancado: !ab,
          pausado: pausado,
          aoTocar: () => _tocarBau('especial'),
        ),
      ));
      filhos.add(Positioned(
        left: 4,
        bottom: 91 + 64,
        child: IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _dicaVisivel ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
              child: Text('Requer uma chave ${nomeRaridadeFem(tierRar[tier])} ou superior', style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.5)),
            ),
          ),
        ),
      ));
    }
    if (existe('extra')) {
      filhos.add(Positioned(
        left: 44,
        bottom: 128,
        child: _BauArena(key: ValueKey('extra-${b['dia']}'), variante: 'padrao', aberto: aberto('extra'), aoTocar: () => _tocarBau('extra')),
      ));
    }
    return filhos;
  }

  int get _quadroTocha => (_relogio.value * _cicloMs / 200).floor() % 3;
  double get _balanco => const [0.0, -1.0, -2.0, -1.0][(_relogio.value * _cicloMs / 275).floor() % 4];

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    final bloqueada = !e.temaDesbloqueado(e.indiceTemaExibido) && _alvo == null;
    final m = e.monstro;
    final venceu = e.derrotado;
    final semTarefas = e.tarefasDeHoje.isEmpty;
    final descansando = e.descansando;

    final heroi = SizedBox(
      width: 83,
      height: 87,
      child: Stack(clipBehavior: Clip.none, children: [
        const Positioned(left: 13.5, top: 75, child: _Sombra()),
        AnimatedBuilder(
          animation: Listenable.merge([_relogio, _motor]),
          builder: (_, filho) => Transform.translate(
            offset: _motor.heroi + Offset(0, descansando ? 0 : _balanco),
            child: Opacity(opacity: _motor.heroiOpacidade, child: Transform.scale(scaleX: _motor.heroiEscalaX, child: filho)),
          ),
          child: _HeroiEquipado(estado: e, motor: _motor),
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
          animation: _motor,
          builder: (_, filho) => Transform.translate(offset: _motor.monstro, child: Transform.rotate(angle: _motor.monstroGiro, child: filho)),
          child: semTarefas
              ? Opacity(opacity: 0.45, child: ColorFiltered(colorFilter: _saturacao(0.45), child: pixel(m.img, largura: 78, altura: 78)))
              : pixel(m.img, largura: 78, altura: 78),
        ),
        if (!semTarefas) Positioned(left: 8, top: -6, child: _BarraMonstro(fracao: e.vidaMonstro)),
      ]),
    );

    return LayoutBuilder(builder: (context, caixa) {
      _larg = caixa.maxWidth - 28;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _arrastoInicio,
        onHorizontalDragUpdate: _arrastoMove,
        onHorizontalDragEnd: _arrastoFim,
        child: AnimatedBuilder(animation: _motor, builder: (_, filho) => Transform.translate(offset: _motor.arena, child: filho), child: _corpo(e, venceu, heroi, monstro, bloqueada, semTarefas, descansando)),
      );
    });
  }

  Widget _corpo(EstadoJogo e, bool venceu, Widget heroi, Widget monstro, bool bloqueada, bool semTarefas, bool descansando) {
    final m = e.monstro;
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
          Positioned.fill(child: _fundos(e)),
          Positioned(left: 4, top: 4, child: AnimatedBuilder(animation: _relogio, builder: (_, __) => TochaArena('assets/img/ui/tocha_esq.png', _quadroTocha))),
          Positioned(right: 4, top: 4, child: AnimatedBuilder(animation: _relogio, builder: (_, __) => TochaArena('assets/img/ui/tocha_dir.png', _quadroTocha))),
          Positioned(
            left: 16,
            right: 16,
            top: 56,
            height: 87,
            child: bloqueada
                ? const SizedBox.shrink()
                : venceu
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
          if (!bloqueada) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: PintorGolpe(_motor)))),
          if (venceu && !bloqueada)
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
          if (!bloqueada) ..._baus(e),
          if (bloqueada) Positioned.fill(child: _BloqueioTema(estado: e)),
          Positioned(top: 10, left: 0, right: 0, child: Center(child: _SeloEstagio(estado: e, visivel: _selo))),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _pontos ? 1 : 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < e.dados.temas.length; i++)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: i == (_alvo != null ? _alvo : e.indiceTemaExibido) ? const Color(0xE6FFFFFF) : const Color(0x59FFFFFF)),
                    ),
                ]),
              ),
            ),
          ),
          // dia de descanso: arena apagada (filter: brightness(.7) saturate(.75))
          if (descansando) const Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Color(0x4D000000)))),
        ]),
      ),
    );
  }
}


/// Uma camada de cenário: parede de tijolos, arte do bioma e vinheta. [bloqueado] põe a silhueta escura por cima.
class FundoTema extends StatelessWidget {
  const FundoTema({required this.tema, this.bloqueado = false});
  final TemaArena tema;
  final bool bloqueado;
  @override
  Widget build(BuildContext context) => Stack(children: [
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
        if (bloqueado) const Positioned.fill(child: ColoredBox(color: Color(0xD1000000))),
      ]);
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
class TochaArena extends StatelessWidget {
  const TochaArena(this.folha, this.quadro, {super.key});
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

/// Herói da arena com o equipamento por cima (`desenharHeroi()`): corpo < escudo < arma < mão.
/// Só o escudo e a arma aparecem; armadura, elmo e acessório ficam de fora, como no original.
class _HeroiEquipado extends StatelessWidget {
  const _HeroiEquipado({required this.estado, required this.motor});
  final EstadoJogo estado;
  final MotorGolpe motor;

  ItemCatalogo? _item(String slot) {
    final id = estado.save.equipado[slot];
    return id is num ? estado.catalogo.item(id) : null;
  }

  @override
  Widget build(BuildContext context) {
    final h = estado.heroi;
    final feminina = estado.save.heroi.toInt() >= 4; // heróis 0-3 e 4+ têm a mão em lugares diferentes
    final tabelas = EquipArena.atual;
    final filhos = <Widget>[pixel(h.imgArena ?? h.img, largura: 83, altura: 83)];

    // As tabelas são consultadas pelo id do item equipado, igual ao original. Lá, todo equipamento do inventário é
    // uma "variante" (id acima do catálogo base), então a consulta falha e valem os valores padrão; aqui acontece
    // o mesmo, e a medida fina só entra para itens com id do catálogo base (ex.: comprados na loja).

    // escudo: o retângulo real do desenho (EQ_BB) é esticado para caber numa área de 34x34 centrada em x=19, topo em y=47
    final escudo = _item('escudo');
    if (escudo != null) {
      final bb = tabelas.eqBB[escudo.id] ?? const [2.0, 2.0, 30.0, 30.0];
      final bw = bb[2] - bb[0], bh = bb[3] - bb[1];
      final ky = 34 / bh, kx = math.min(34 / bw, ky * 1.2);
      filhos.add(Positioned(
        left: 19 - (bb[0] + bw / 2) * kx,
        top: 47 - bb[1] * ky,
        child: _ComSombra(opacidade: 0.45, child: Sprite(estado: estado, sprite: escudo.sprite, largura: 32 * kx, altura: 32 * ky, clarear: false)),
      ));
    }

    final arma = _item('arma');
    var corpoACorpo = false;
    if (arma != null) {
      final nome = arma.nome;
      bool tem(String padrao) => RegExp(padrao, caseSensitive: false).hasMatch(nome);
      final distancia = tem(r'^(Arco|Besta|Arbalesta|Zarabatana|Estilingue|Funda)');
      corpoACorpo = !distancia;
      // armas de sprite grande encolhem para não dominar o herói; o cabo continua na mão
      final lado = tem(r'Martelo de Guerra') ? 34.0 : (tem(r'Machado de Guerra|Chicote') ? 44.0 : 56.0);
      final k = lado / 32;
      final cabo = tabelas.armaGrip[arma.id];
      final ajuste = tabelas.armaAjuste[arma.id] ?? const [0.0, 0.0];
      final mao = feminina ? const Offset(65, 63.3) : const Offset(60, 63.3);
      Widget desenho = _ComSombra(opacidade: 0.5, child: Sprite(estado: estado, sprite: arma.sprite, tamanho: lado, clarear: tabelas.armaEscura.contains(arma.id)));
      double esq, topo;
      if (distancia) {
        // arcos e bestas ficam de pé, sem girar; os arcos diagonais (Real/Longo) são endireitados
        esq = 46;
        topo = 36;
        if (tem(r'^Arco (Real|Longo)')) desenho = Transform.rotate(angle: -math.pi / 4, child: Transform.scale(scale: 0.78, child: desenho));
      } else {
        Offset pivo; // ponto em volta do qual a arma gira 8 graus
        if (cabo != null) {
          esq = mao.dx - cabo[0] * k + ajuste[0];
          topo = mao.dy - cabo[1] * k + ajuste[1];
          pivo = Offset(cabo[0] * k, cabo[1] * k);
        } else {
          esq = lado == 56 ? 52 : 59 - 0.12 * lado;
          topo = lado == 56 ? 15 : 64 - 0.88 * lado;
          pivo = Offset(lado * 0.2, lado * 0.85);
        }
        final centro = pivo - Offset(lado / 2, lado / 2);
        desenho = AnimatedBuilder(
          animation: motor,
          builder: (_, f) => Transform.rotate(angle: motor.armaGraus * math.pi / 180, origin: centro, child: f),
          child: desenho,
        );
      }
      filhos.add(Positioned(left: esq, top: topo, width: lado, height: lado, child: desenho));
    }

    // a mão por cima do cabo: recorte (manga + punho) do próprio sprite do herói; só nas armas corpo a corpo
    if (corpoACorpo) {
      filhos.add(Positioned(
        left: 0,
        top: 0,
        child: ClipRect(
          clipper: _Recorte(feminina ? const Rect.fromLTRB(61, 58.6, 83 - 14.6, 83 - 17.1) : const Rect.fromLTRB(56.1, 56.1, 83 - 19.5, 83 - 17.1)),
          child: pixel(h.img, largura: 83, altura: 83),
        ),
      ));
    }
    return SizedBox(width: 83, height: 87, child: Stack(clipBehavior: Clip.none, children: filhos));
  }
}

class _Recorte extends CustomClipper<Rect> {
  const _Recorte(this.area);
  final Rect area;
  @override
  Rect getClip(Size size) => area;
  @override
  bool shouldReclip(_Recorte oldClipper) => oldClipper.area != area;
}

/// `filter: drop-shadow(0 1px 0 rgba(0,0,0,a))`: a silhueta do desenho em preto, 1px abaixo.
class _ComSombra extends StatelessWidget {
  const _ComSombra({required this.child, required this.opacidade});
  final Widget child;
  final double opacidade;
  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        Positioned(
          left: 0,
          top: 1,
          child: ColorFiltered(colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: opacidade), BlendMode.srcIn), child: child),
        ),
        child,
      ]);
}

/// Baú na arena (.bauArena, 64x64): surge com um salto, pulsa enquanto fechado e fica parado depois de aberto.
/// O trancado leva o cadeado por cima e para de pulsar quando [pausado].
class _BauArena extends StatefulWidget {
  const _BauArena({super.key, required this.variante, required this.aberto, required this.aoTocar, this.trancado = false, this.pausado = false});
  final String variante;
  final bool aberto;
  final bool trancado;
  final bool pausado;
  final VoidCallback aoTocar;
  @override
  State<_BauArena> createState() => _BauArenaState();
}

class _BauArenaState extends State<_BauArena> with TickerProviderStateMixin {
  // bauSurge .5s cubic-bezier(.34,1.56,.64,1) e depois bauPulso 1.4s em laço
  late final AnimationController _surge = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final AnimationController _pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  bool get _pulsa => !widget.aberto && !widget.pausado;

  @override
  void initState() {
    super.initState();
    if (widget.aberto) {
      _surge.value = 1; // baú já aberto (voltou ao app): aparece parado
    } else {
      _surge.forward().whenComplete(() {
        if (mounted && _pulsa) _pulso.repeat();
      });
    }
  }

  @override
  void didUpdateWidget(_BauArena antigo) {
    super.didUpdateWidget(antigo);
    if (!_pulsa) {
      _pulso
        ..stop()
        ..value = 0;
    } else if (!_pulso.isAnimating && _surge.isCompleted) {
      _pulso.repeat();
    }
  }

  @override
  void dispose() {
    _surge.dispose();
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foto = Image.asset(imagemBau(widget.variante, aberto: widget.aberto), width: 64, height: 64, filterQuality: FilterQuality.none, gaplessPlayback: true);
    // sombra projetada (drop-shadow 0 8px 14px rgba(0,0,0,.55)): cópia escura e borrada atrás do baú
    final imagem = Stack(clipBehavior: Clip.none, children: [
      Transform.translate(
        offset: const Offset(0, 8),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: ColorFiltered(colorFilter: const ColorFilter.mode(Color(0x8C000000), BlendMode.srcIn), child: foto),
        ),
      ),
      foto,
    ]);
    return Semantics(
      button: !widget.aberto,
      label: widget.trancado ? 'Baú trancado' : 'Baú',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.aberto ? null : widget.aoTocar,
        child: AnimatedBuilder(
          animation: Listenable.merge([_surge, _pulso]),
          builder: (_, filho) {
            // surge: 0% scale(.35) translateY(8px) transparente -> 70% scale(1.14) translateY(-2px) -> 100% normal
            final t = const Cubic(0.34, 1.56, 0.64, 1).transform(_surge.value);
            final double escalaSurge, dy;
            if (t < 0.7) {
              escalaSurge = 0.35 + (1.14 - 0.35) * (t / 0.7);
              dy = 8 - 10 * (t / 0.7);
            } else {
              final u = (t - 0.7) / 0.3;
              escalaSurge = 1.14 - 0.14 * u;
              dy = -2 + 2 * u;
            }
            final p = Curves.easeInOut.transform(_pulso.value < 0.5 ? _pulso.value * 2 : 2 - _pulso.value * 2); // 0 -> 1 -> 0
            final brilho = 1 + 0.15 * p;
            return Opacity(
              opacity: (t / 0.7).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, _surge.isCompleted ? 0 : dy),
                child: Transform.scale(
                  scale: (_surge.isCompleted ? 1 : escalaSurge) * (1 + 0.08 * p),
                  child: p == 0
                      ? filho
                      : ColorFiltered(
                          colorFilter: ColorFilter.matrix(<double>[brilho, 0, 0, 0, 0, 0, brilho, 0, 0, 0, 0, 0, brilho, 0, 0, 0, 0, 0, 1, 0]),
                          child: filho,
                        ),
                ),
              ),
            );
          },
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(children: [
              imagem,
              // cadeado 22x26 centrado, a 14px da base (.bauArena.trancado::after)
              if (widget.trancado) const Positioned(left: 21, top: 24, child: CustomPaint(size: Size(22, 26), painter: _PintorCadeado())),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Cadeado em pixel art (retângulos numa grade 12x14 vindos do SVG do original).
class _PintorCadeado extends CustomPainter {
  const _PintorCadeado();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 12, size.height / 14);
    for (final (r, cor) in EquipArena.atual.cadeado) {
      canvas.drawRect(
          r,
          Paint()
            ..color = cor
            ..isAntiAlias = false);
    }
  }

  @override
  bool shouldRepaint(_PintorCadeado oldDelegate) => false;
}

/// Selo no topo da arena: "Estágio 2 em 7 tarefas" (ou a dica de arrastar no estágio máximo).
class _SeloEstagio extends StatelessWidget {
  const _SeloEstagio({required this.estado, required this.visivel});
  final EstadoJogo estado;
  final bool visivel;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    const base = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEEEEEE), height: 1);
    final List<Widget> filhos;
    if (e.estagio >= 4) {
      filhos = const [Text('◀', style: base), Text('Arraste pra trocar de bioma', style: base), Text('▶', style: base)];
    } else {
      final falta = e.faltamParaProximoEstagio;
      filhos = [
        Text('Estágio ${e.estagio + 1} em', style: base),
        Text('$falta', style: const TextStyle(fontFamily: fontePixel, fontSize: 11, color: Colors.white, height: 1)),
        Text(falta == 1 ? 'tarefa' : 'tarefas', style: base),
      ];
    }
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 450),
        opacity: visivel ? 1 : 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xB8141414), borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < filhos.length; i++) ...[if (i > 0) const SizedBox(width: 6), filhos[i]],
          ]),
        ),
      ),
    );
  }
}

/// Cadeado e aviso quando o cenário ainda não foi liberado (só prévia, não é salvo).
class _BloqueioTema extends StatelessWidget {
  const _BloqueioTema({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    final i = e.indiceTemaExibido;
    final t = e.dados.temas[i];
    return IgnorePointer(
      child: ColoredBox(
        color: const Color(0x59000000),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 6, offset: Offset(0, 2))]),
            child: Image.asset('assets/img/ui/cadeado_arena.png', width: 32, filterQuality: FilterQuality.none),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Chegue no Estágio ${i + 1} pra desbloquear ${t.nome}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, shadows: [Shadow(color: Color(0xB3000000), blurRadius: 6, offset: Offset(0, 2))]),
            ),
          ),
        ]),
      ),
    );
  }
}
