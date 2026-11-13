// Folha "md" do app original (.cq-tela / .md-sheet, play/style.css ~6275): fundo escurecido e desfocado que aparece
// em 0,35 s e a folha que sobe em 0,22 s; o conteúdo entra aos poucos, cada peça com o seu atraso (`mdIn`, `mdRow`).
// Usada pela cerimônia de estágio, subir de nível, "Você caiu", tarefas perdidas e resumo do dia.
import 'dart:async';

import 'package:flutter/material.dart';

import 'tema.dart';

/// Relógio compartilhado das entradas: 0 a [total] ms desde que a folha abriu.
class _MdTempo extends InheritedWidget {
  const _MdTempo({required this.c, required this.totalMs, required super.child});
  final AnimationController c;
  final int totalMs;
  static _MdTempo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_MdTempo>()!;
  @override
  bool updateShouldNotify(_MdTempo old) => old.c != c;
}

/// Uma peça que entra no instante [atraso] (ms): aparece (e sobe 8 px se [sobe]) em [dur] ms.
class MdEntra extends StatelessWidget {
  const MdEntra({super.key, required this.atraso, this.dur = 400, this.sobe = true, this.mola = false, required this.filho});
  final int atraso;
  final int dur;
  final bool sobe;
  final bool mola; // mdRow: sobe 16 px e cresce de .97 a 1 com mola
  final Widget filho;

  @override
  Widget build(BuildContext context) {
    final t = _MdTempo.of(context);
    return AnimatedBuilder(
      animation: t.c,
      child: filho,
      builder: (_, f) {
        final x = ((t.c.value * t.totalMs - atraso) / dur).clamp(0.0, 1.0);
        final v = mola ? Curves.elasticOut.transform(x).clamp(0.0, 1.1) : Curves.ease.transform(x);
        final op = (mola ? x * 1.6 : v).clamp(0.0, 1.0);
        final dy = mola ? 16 * (1 - v) : (sobe ? 8 * (1 - v) : 0.0);
        return Opacity(opacity: op, child: Transform.translate(offset: Offset(0, dy), child: mola ? Transform.scale(scale: 0.97 + 0.03 * v, child: f) : f));
      },
    );
  }
}

/// Valor de 0 a 1 de um trecho da linha do tempo (para animações próprias, como a íris e o preenchimento).
double mdTrecho(BuildContext context, int atrasoMs, int durMs, {Curve curva = Curves.ease}) {
  final t = _MdTempo.of(context);
  final x = ((t.c.value * t.totalMs - atrasoMs) / durMs).clamp(0.0, 1.0);
  return curva.transform(x);
}

/// Reconstrói a cada quadro da linha do tempo (para peças que usam [mdTrecho]).
class MdQuadro extends StatelessWidget {
  const MdQuadro({super.key, required this.builder});
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) {
    final t = _MdTempo.of(context);
    return AnimatedBuilder(animation: t.c, builder: (ctx, _) => builder(ctx));
  }
}

/// Fila dos popups do jogo (nível, estágio, queda, resumo, tarefas perdidas, baú): só um fica na tela por vez e o
/// próximo entra quando o anterior fecha, na ordem em que foram pedidos. Sem isso, subir de nível e mudar de estágio
/// ao mesmo tempo abria uma tela em cima da outra.
class FilaPopups {
  FilaPopups._();
  static final List<Future<void> Function()> _fila = [];
  static bool _ocupada = false;

  /// Quantos popups estão esperando (ou abertos) agora; serve para testes.
  static int get pendentes => _fila.length + (_ocupada ? 1 : 0);

  /// Esvazia a fila (testes: cada um começa sem herdar popups pendentes do anterior).
  static void reiniciar() {
    _fila.clear();
    _ocupada = false;
  }

  /// Pede para abrir um popup: abre na hora se não há outro na tela; senão espera a vez (ordem de chegada).
  static Future<T> enfileirar<T>(Future<T> Function() abrir) {
    final c = Completer<T>();
    _fila.add(() async {
      try {
        c.complete(await abrir());
      } catch (e, st) {
        c.completeError(e, st);
      }
    });
    _proximo();
    return c.future;
  }

  static void _proximo() {
    if (_ocupada || _fila.isEmpty) return;
    _ocupada = true;
    _fila.removeAt(0)().whenComplete(() {
      _ocupada = false;
      _proximo();
    });
  }
}

/// Abre a folha. [filhos] recebe a função de fechar (com a animação de saída de 0,22 s). [totalMs] = duração da coreografia.
Future<void> abrirSheetMd(
  BuildContext context, {
  required List<Widget> Function(VoidCallback fechar) filhos,
  int totalMs = 3200,
  bool dispensavel = false,
}) =>
    FilaPopups.enfileirar(() => _abrirSheetMd(context, filhos: filhos, totalMs: totalMs, dispensavel: dispensavel));

Future<void> _abrirSheetMd(
  BuildContext context, {
  required List<Widget> Function(VoidCallback fechar) filhos,
  required int totalMs,
  required bool dispensavel,
}) async {
  if (!context.mounted) return; // a tela que pediu já não existe
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: dispensavel,
    barrierLabel: 'Fechar',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => _SheetMd(anim: anim, totalMs: totalMs, filhos: filhos),
  );
}

class _SheetMd extends StatefulWidget {
  const _SheetMd({required this.anim, required this.totalMs, required this.filhos});
  final Animation<double> anim;
  final int totalMs;
  final List<Widget> Function(VoidCallback fechar) filhos;
  @override
  State<_SheetMd> createState() => _SheetMdState();
}

class _SheetMdState extends State<_SheetMd> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.totalMs))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _fechar() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return _MdTempo(
      c: _c,
      totalMs: widget.totalMs,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(children: [
        // absorve os toques fora da folha (sem isso o toque passava para a barra de baixo)
        Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {})),
        Positioned.fill(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: widget.anim, curve: Curves.ease),
            child: const ColoredBox(color: Color(0xB3000000)), // sem desfoque: mais leve
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1.05), end: Offset.zero).animate(CurvedAnimation(parent: widget.anim, curve: Curves.ease)),
            child: Container(
              constraints: BoxConstraints(maxWidth: 520, maxHeight: mq.size.height * 0.94),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: corPainel2,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                border: Border(top: BorderSide(color: corLinha, width: 0.8)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + mq.viewPadding.bottom),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Container(width: 38, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: corLinha, borderRadius: BorderRadius.circular(2))),
                  ...widget.filhos(_fechar),
                ]),
              ),
            ),
          ),
        ),
      ]),
      ),
    );
  }
}

/// `.md-k`: rótulo em Silkscreen com espaçamento largo.
class MdRotulo extends StatelessWidget {
  const MdRotulo(this.texto, {super.key, this.atraso = 300});
  final String texto;
  final int atraso;
  @override
  Widget build(BuildContext context) => MdEntra(
        atraso: atraso,
        filho: Text(texto, style: const TextStyle(fontFamily: fontePixel, fontSize: 10, letterSpacing: 1.8, color: corSuave)),
      );
}

/// `.md-t`: título.
class MdTitulo extends StatelessWidget {
  const MdTitulo(this.texto, {super.key, this.atraso = 450});
  final String texto;
  final int atraso;
  @override
  Widget build(BuildContext context) => MdEntra(
        atraso: atraso,
        filho: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: corTexto, height: 1.2)),
        ),
      );
}

/// `.md-btn`: botão largo que entra por último.
class MdBotao extends StatelessWidget {
  const MdBotao(this.texto, {super.key, required this.atraso, required this.aoTocar});
  final String texto;
  final int atraso;
  final VoidCallback aoTocar;
  @override
  Widget build(BuildContext context) => MdEntra(
        atraso: atraso,
        dur: 500,
        mola: true,
        filho: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: aoTocar,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(texto, style: const TextStyle(color: corFundo, fontWeight: FontWeight.w600, fontSize: 15))),
              ),
            ),
          ),
        ),
      );
}

/// `.md-row`: linha com ícone, texto e valor (resumos de nível, dia etc.).
class MdLinha extends StatelessWidget {
  const MdLinha({super.key, required this.indice, required this.base, required this.icone, required this.texto, required this.valor});
  final int indice;
  final int base; // atraso da primeira linha (ms)
  final String icone;
  final String texto;
  final Widget valor;
  @override
  Widget build(BuildContext context) => MdEntra(
        atraso: base + indice * 60,
        dur: 300,
        sobe: false,
        filho: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(color: const Color(0x0FFFFFFF), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: corLinha, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(icone, style: const TextStyle(fontFamily: fontePixel, fontSize: 10, color: corOuro))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(texto, style: const TextStyle(fontSize: 13.5, color: corSuave))),
            DefaultTextStyle.merge(style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: corTexto, fontFeatures: algarismosFixos), child: valor),
          ]),
        ),
      );
}
