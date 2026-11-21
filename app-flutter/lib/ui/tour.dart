// Tutorial guiado (o TOUR de play/index.html ~13586): a tela escurece, só o elemento da vez fica aceso e o herói explica em
// uma frase digitada letra a letra. Os destaques apontam para widgets reais, registrados por GlobalKey em [TourAlvos].
import 'dart:async';

import 'package:flutter/material.dart';

import '../dominio/save.dart' show nomeHeroiNorm;
import '../dominio/tarefa.dart';
import '../dominio/tutorial.dart';
import 'estado_jogo.dart';
import 'icones.dart' show pixel;
import 'vibra.dart';

/// Chaves dos elementos que o tour destaca (um widget real por id).
class TourAlvos {
  TourAlvos._();
  static final addbtn = GlobalKey(debugLabel: 'tour-addbtn');
  static final input = GlobalKey(debugLabel: 'tour-input');
  static final save = GlobalKey(debugLabel: 'tour-save');
  static final tarefaBox = GlobalKey(debugLabel: 'tour-tarefaBox');
  static final restbtn = GlobalKey(debugLabel: 'tour-restbtn');
  static final equipbox = GlobalKey(debugLabel: 'tour-equipbox');
  static final lojaLinha = GlobalKey(debugLabel: 'tour-lojaLinha');
  static final prevConquistas = GlobalKey(debugLabel: 'tour-prevConquistas');
  static final prevBestiario = GlobalKey(debugLabel: 'tour-prevBestiario');
  static final perfilCfgBtn = GlobalKey(debugLabel: 'tour-perfilCfgBtn');
  static final estCardPrincipal = GlobalKey(debugLabel: 'tour-estCardPrincipal');

  /// A tarefa que o jogador criou no passo 2 (a caixinha dela ganha [tarefaBox]).
  static Tarefa? tarefaAlvo;

  /// true enquanto a folha de nova tarefa está aberta (o passo 1 espera isso).
  static final ValueNotifier<bool> folhaNovaAberta = ValueNotifier(false);

  static GlobalKey? porId(String id) => switch (id) {
        'addbtn' => addbtn,
        'input' => input,
        'save' => save,
        'tarefaBox' => tarefaBox,
        'restbtn' => restbtn,
        'equipbox' => equipbox,
        'lojaLinha' => lojaLinha,
        'prevConquistas' => prevConquistas,
        'prevBestiario' => prevBestiario,
        'perfilCfgBtn' => perfilCfgBtn,
        'estCardPrincipal' => estCardPrincipal,
        _ => null,
      };
}

class TourControle extends ChangeNotifier {
  TourControle({required this.estado, required this.irParaAba, required this.abaAtual});
  final EstadoJogo estado;
  final void Function(int) irParaAba;
  final int Function() abaAtual;

  /// O controle da casca em uso (o botão "Rever tutorial" das Configurações chama [revisar] nele).
  static TourControle? instancia;

  /// O que a camada do tour mostra (null = nada).
  static final ValueNotifier<TourControle?> visivel = ValueNotifier(null);

  bool ativo = false;
  int i = 0;
  int _tok = 0;
  List<Rect> rects = [];
  Rect? alvo;
  bool saindo = true; // anel e cartão escondidos (o escurecimento fica)
  String _textoCompleto = '';
  int _letras = 0;
  Timer? _digita, _poll, _agenda;
  int _n0 = 0;

  PassoTour get passo => passosTour[i.clamp(0, passosTour.length - 1)];
  String get fala => _textoCompleto;
  int get letras => _letras;

  /// `agendarDialogoTela('tarefas')`: depois de 120 ms, abre o tour se esta tela ainda não foi vista.
  void agendar() {
    if (ativo || estado.tutorialVisto('tarefas')) return;
    _agenda?.cancel();
    _agenda = Timer(const Duration(milliseconds: 120), iniciar);
  }

  /// `revisarTutorial()`.
  void revisar() {
    estado.reiniciarTutorial();
    irParaAba(0);
    iniciar();
  }

  void iniciar() {
    if (ativo) return;
    ativo = true;
    i = 0;
    saindo = true;
    TourAlvos.tarefaAlvo = null;
    visivel.value = this;
    notifyListeners();
    _passo(1);
  }

  void proximo() {
    if (!ativo) return;
    i++;
    _passo(1);
  }

  void voltar() {
    if (ativo && i > 0) {
      i--;
      _passo(-1);
    }
  }

  void fim() {
    _tok++;
    ativo = false;
    _poll?.cancel();
    _digita?.cancel();
    estado.marcarTelasVistas(telasTutorial);
    irParaAba(0);
    saindo = true;
    notifyListeners();
    if (visivel.value == this) visivel.value = null;
  }

  @override
  void dispose() {
    _tok++;
    _poll?.cancel();
    _digita?.cancel();
    _agenda?.cancel();
    if (instancia == this) instancia = null;
    if (visivel.value == this) visivel.value = null;
    super.dispose();
  }

  List<Rect>? _medir(PassoTour p) {
    final out = <Rect>[];
    for (final id in p.alvos) {
      final ctx = TourAlvos.porId(id)?.currentContext;
      if (ctx == null || !ctx.mounted) return null;
      final r = ctx.findRenderObject();
      if (r is! RenderBox || !r.attached || !r.hasSize) return null;
      out.add(r.localToGlobal(Offset.zero) & r.size);
    }
    return out;
  }

  Future<void> _passo(int dir) async {
    final tok = ++_tok;
    _poll?.cancel();
    if (i < 0) i = 0;
    if (i >= passosTour.length) return fim();
    final p = passosTour[i];
    saindo = true;
    notifyListeners();
    if (abaAtual() != p.aba) {
      irParaAba(p.aba);
      await Future<void>.delayed(const Duration(milliseconds: 320));
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    for (var n = 6; n >= 0; n--) {
      if (tok != _tok || !ativo) return;
      if (p.rolar) {
        final ctx = TourAlvos.porId(p.alvos.first)?.currentContext;
        if (ctx != null && ctx.mounted) {
          try {
            await Scrollable.ensureVisible(ctx, alignment: .5, duration: Duration.zero);
          } catch (_) {}
        }
      }
      final r = _medir(p);
      if (r != null && r.every((q) => q.width >= 4 && q.height >= 4)) {
        _aplicar(r);
        _esperar(p, tok);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    if (tok != _tok || !ativo) return;
    // alvo que não existe agora: pula (volta nunca cai num passo interativo)
    var prox = i + dir, d = dir;
    if (d < 0 && (prox < 0 || passosTour[prox].interativo)) {
      d = 1;
      prox = i + 1;
    }
    i = prox;
    _passo(d);
  }

  void _aplicar(List<Rect> r) {
    rects = r;
    alvo = r.skip(1).fold<Rect>(r.first, (a, b) => a.expandToInclude(b));
    final nova = passo.tSub(estado.idioma);
    if (nova != _textoCompleto || saindo) {
      _textoCompleto = nova;
      _letras = 0;
      _digita?.cancel();
      _digita = Timer.periodic(const Duration(milliseconds: 38), (t) {
        _letras += 2;
        if (_letras % 4 == 0 && _letras - 1 < _textoCompleto.length && _textoCompleto[_letras - 1] != ' ') Vibra.toque();
        if (_letras >= _textoCompleto.length) {
          _letras = _textoCompleto.length;
          t.cancel();
        }
        notifyListeners();
      });
    }
    saindo = false;
    notifyListeners();
  }

  void _esperar(PassoTour p, int tok) {
    _poll?.cancel();
    if (p.espera == EsperaTour.criar) _n0 = estado.save.tarefas.length;
    _poll = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (tok != _tok || !ativo) {
        _poll?.cancel();
        return;
      }
      // acompanha animações (folha subindo, rolagem, teclado): mede de novo e só avisa se mudou
      final r = _medir(p);
      if (r != null && !saindo && (r.length != rects.length || [for (var k = 0; k < r.length; k++) r[k] != rects[k]].contains(true))) {
        rects = r;
        alvo = r.skip(1).fold<Rect>(r.first, (a, b) => a.expandToInclude(b));
        notifyListeners();
      }
      switch (p.espera) {
        case EsperaTour.nenhuma:
          break;
        case EsperaTour.abrir:
          if (TourAlvos.folhaNovaAberta.value) {
            _poll?.cancel();
            Timer(const Duration(milliseconds: 420), () {
              if (tok == _tok && ativo) proximo();
            });
          }
        case EsperaTour.criar:
          if (estado.save.tarefas.length > _n0) {
            _poll?.cancel();
            TourAlvos.tarefaAlvo = estado.save.tarefas.last;
            saindo = true;
            notifyListeners();
            Timer(const Duration(milliseconds: 60), () {
              if (tok == _tok && ativo) proximo();
            });
          } else if (!TourAlvos.folhaNovaAberta.value) {
            _poll?.cancel(); // fechou sem criar: volta ao passo anterior
            i = i > 0 ? i - 1 : 0;
            _passo(-1);
          }
        case EsperaTour.concluir:
          final t = TourAlvos.tarefaAlvo;
          if (t == null || t.feitaEm != null || !estado.save.tarefas.contains(t)) {
            _poll?.cancel();
            saindo = true; // o golpe e o XP aparecem sem nada em cima
            notifyListeners();
            Timer(const Duration(milliseconds: 1300), () {
              if (tok == _tok && ativo) proximo();
            });
          }
      }
    });
  }
}

/// A camada do tour, por cima de tudo (inclusive das folhas): só o buraco do destaque deixa o toque passar.
class CamadaTour extends StatelessWidget {
  const CamadaTour({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<TourControle?>(
        valueListenable: TourControle.visivel,
        builder: (_, c, __) => c == null ? const SizedBox.shrink() : _TourView(key: ValueKey(c), c: c),
      );
}

const _corVeu = Color(0xFF05040A);

class _TourView extends StatefulWidget {
  const _TourView({super.key, required this.c});
  final TourControle c;
  @override
  State<_TourView> createState() => _TourViewState();
}

class _TourViewState extends State<_TourView> with SingleTickerProviderStateMixin {
  final _cartao = GlobalKey();
  double _altCartao = 170;
  late final AnimationController _pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, cons) => ListenableBuilder(listenable: widget.c, builder: (_, __) => _montar(ctx, Size(cons.maxWidth, cons.maxHeight))));

  Widget _montar(BuildContext context, Size tam) {
    final c = widget.c;
    final mq = MediaQuery.of(context);
    final p = c.passo;
    final en = c.estado.idioma == 'en';
    final alvo = c.alvo;
    final temAlvo = alvo != null && !c.saindo;
    const pad = 6.0;
    final furo = temAlvo ? Rect.fromLTRB(alvo.left - pad, alvo.top - pad, alvo.right + pad, alvo.bottom + pad) : Rect.zero;
    final filhos = <Widget>[
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _pulso,
            builder: (_, __) => CustomPaint(painter: _PintorVeu(furo: temAlvo ? furo : null, leve: p.leve, pulso: _pulso.value, vez: p.interativo)),
          ),
        ),
      ),
    ];
    // blocos que seguram o toque; o buraco só deixa passar nos passos interativos
    Widget bloco(Rect r) => Positioned(left: r.left, top: r.top, width: r.width.clamp(0, double.infinity), height: r.height.clamp(0, double.infinity), child: const AbsorbPointer(child: SizedBox.expand()));
    if (temAlvo) {
      filhos.addAll([
        bloco(Rect.fromLTRB(0, 0, tam.width, furo.top)),
        bloco(Rect.fromLTRB(0, furo.bottom, tam.width, tam.height)),
        bloco(Rect.fromLTRB(0, furo.top, furo.left, furo.bottom)),
        bloco(Rect.fromLTRB(furo.right, furo.top, tam.width, furo.bottom)),
        if (!p.interativo) bloco(furo),
      ]);
    } else {
      filhos.add(Positioned.fill(child: const AbsorbPointer(child: SizedBox.expand())));
    }
    if (alvo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final h = _cartao.currentContext?.size?.height;
        if (h != null && (h - _altCartao).abs() > 0.5 && mounted) setState(() => _altCartao = h);
      });
      final pos = posicionarCartaoTour(larguraTela: tam.width, alturaTela: tam.height, alturaCartao: _altCartao, alvo: alvo, alvos: c.rects, pad: pad);
      final topo = pos.topo == null ? null : pos.topo! + (pos.safeTopo ? mq.padding.top : 0);
      final base = pos.base == null ? null : pos.base! + (pos.safeBase ? mq.padding.bottom : 0);
      filhos.add(Positioned(
        left: pos.esquerda,
        width: pos.largura,
        top: topo,
        bottom: base,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: c.saindo ? 0 : 1,
          child: IgnorePointer(ignoring: c.saindo, child: KeyedSubtree(key: _cartao, child: _Cartao(c: c, en: en, noTopo: pos.noTopo))),
        ),
      ));
    }
    return Material(type: MaterialType.transparency, child: Stack(children: filhos));
  }
}

class _PintorVeu extends CustomPainter {
  _PintorVeu({required this.furo, required this.leve, required this.pulso, required this.vez});
  final Rect? furo;
  final bool leve, vez;
  final double pulso;
  @override
  void paint(Canvas canvas, Size s) {
    final veu = Paint()..color = _corVeu.withValues(alpha: leve ? .5 : .86);
    if (furo == null) {
      canvas.drawRect(Offset.zero & s, veu);
      return;
    }
    final rr = RRect.fromRectAndRadius(furo!, const Radius.circular(16));
    canvas.drawPath(Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & s), Path()..addRRect(rr)), veu);
    canvas.drawRRect(rr, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    if (vez) {
      final k = Curves.easeOut.transform(pulso);
      final g = rr.outerRect.inflate(2 + k * (furo!.width * .06));
      canvas.drawRRect(RRect.fromRectAndRadius(g, Radius.circular(16 + k * 6)), Paint()..color = Colors.white.withValues(alpha: .7 * (1 - k))..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_PintorVeu o) => o.furo != furo || o.leve != leve || o.pulso != pulso || o.vez != vez;
}

class _Cartao extends StatelessWidget {
  const _Cartao({required this.c, required this.en, required this.noTopo});
  final TourControle c;
  final bool en, noTopo;
  @override
  Widget build(BuildContext context) {
    final e = c.estado;
    final p = c.passo;
    final total = passosTour.length;
    final digitado = c.fala.substring(0, c.letras.clamp(0, c.fala.length));
    final falta = c.fala.substring(c.letras.clamp(0, c.fala.length));
    final mostraVolta = !(p.interativo || c.i == 0 || passosTour[c.i - 1].interativo);
    final ultimo = c.i == total - 1;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF251E38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B3257), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0x80000000), blurRadius: 40, offset: Offset(0, noTopo ? 10 : -10))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFF1B1629), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF3B3257), width: 1)),
            child: pixel(e.heroi.img, largura: 60, altura: 60),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(nomeHeroiNorm(e.save.nomeHeroi, e.idioma), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cormorant Garamond', fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 19, color: Color(0xFFEDE9F7)))),
                if (p.interativo) ...[
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)), child: Text(en ? 'YOUR TURN' : 'SUA VEZ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFF14101F)))),
                ],
                const Spacer(),
                Text('${c.i + 1} / $total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.32, color: Color(0xFF8C84A6))),
              ]),
              const SizedBox(height: 3),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Text.rich(TextSpan(children: [TextSpan(text: digitado), TextSpan(text: falta, style: const TextStyle(color: Color(0x00000000)))]), style: const TextStyle(fontSize: 15, height: 1.35, color: Color(0xFFEDE9F7))),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Row(children: [
              for (var k = 0; k < total; k++) Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: k == total - 1 ? 0 : 4), decoration: BoxDecoration(color: k <= c.i ? Colors.white : const Color(0xFF3B3257), borderRadius: BorderRadius.circular(2)))),
            ]),
          ),
          const SizedBox(width: 10),
          GestureDetector(key: const ValueKey('tour-pular'), behavior: HitTestBehavior.opaque, onTap: c.fim, child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(en ? 'Skip' : 'Pular', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8C84A6))))),
          if (mostraVolta) ...[
            const SizedBox(width: 10),
            GestureDetector(key: const ValueKey('tour-voltar'), onTap: c.voltar, child: Container(padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 14.5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF4A4170), width: 1.5)), child: Text(en ? 'Back' : 'Voltar', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFEDE9F7))))),
          ],
          if (!p.interativo) ...[
            const SizedBox(width: 10),
            GestureDetector(key: const ValueKey('tour-proximo'), onTap: ultimo ? c.fim : c.proximo, child: Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Text(ultimo ? (en ? 'Done' : 'Concluir') : (en ? 'Next' : 'Próximo'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF14101F))))),
          ],
        ]),
      ]),
    );
  }
}
