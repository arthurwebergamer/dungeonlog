// Folhas (painéis que sobem de baixo) e diálogos no estilo do app original: .edov / .edsheet / .md-sheet.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tema.dart';

/// Área tocável que escurece de leve enquanto pressionada (sem a onda do Material).
class Toque extends StatefulWidget {
  const Toque({super.key, required this.aoTocar, required this.child, this.rotulo});
  final VoidCallback? aoTocar;
  final Widget child;
  final String? rotulo;
  @override
  State<Toque> createState() => _ToqueState();
}

class _ToqueState extends State<Toque> {
  bool _apertado = false;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: widget.rotulo,
        excludeSemantics: widget.rotulo != null, // com rótulo próprio, o leitor de tela não lê o "×" ou "☾" de dentro
        enabled: widget.aoTocar != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.aoTocar == null ? null : (_) => setState(() => _apertado = true),
          onTapCancel: () => setState(() => _apertado = false),
          onTapUp: (_) => setState(() => _apertado = false),
          onTap: widget.aoTocar,
          child: AnimatedOpacity(duration: const Duration(milliseconds: 90), opacity: _apertado ? 0.7 : 1, child: widget.child),
        ),
      );
}

/// Botão largo das folhas: branco com texto escuro (padrão) ou com as cores dadas.
class BotaoFolha extends StatelessWidget {
  const BotaoFolha(
    this.texto, {
    super.key,
    required this.aoTocar,
    this.fundo = Colors.white,
    this.cor = corFundo,
    this.borda,
    this.raio = 12,
    this.tamanho = 15,
    this.padding = 14,
  });
  final String texto;
  final VoidCallback? aoTocar;
  final Color fundo;
  final Color cor;
  final Color? borda;
  final double raio;
  final double tamanho;
  final double padding;
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: aoTocar == null ? 0.4 : 1,
        child: Toque(
          aoTocar: aoTocar,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fundo,
              borderRadius: BorderRadius.circular(raio),
              border: borda == null ? null : Border.all(color: borda!, width: 0.8),
            ),
            child: Text(texto, style: TextStyle(fontSize: tamanho, fontWeight: FontWeight.w600, color: cor, height: 1.28)),
          ),
        ),
      );
}

/// Rótulo de seção em maiúsculas (.edtitulo 12px / .diflabel 11.5px).
class RotuloSecao extends StatelessWidget {
  const RotuloSecao(this.texto, {super.key, this.titulo = false});
  final String texto;
  final bool titulo;
  @override
  Widget build(BuildContext context) => Text(
        texto.toUpperCase(),
        style: TextStyle(
          fontSize: titulo ? 12 : 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: titulo ? 0.84 : 0.69,
          color: corApagado,
          height: 1.26,
        ),
      );
}

Future<T?> abrirFolha<T>(BuildContext context, WidgetBuilder builder) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: corVeu,
      elevation: 0,
      builder: builder,
    );

/// Corpo de uma folha: puxador, "x" de fechar, título em maiúsculas e o conteúdo.
class Folha extends StatelessWidget {
  const Folha({super.key, required this.titulo, required this.filhos});
  final String titulo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: corPainel2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: corLinha, width: 0.8),
        ),
        child: Stack(children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 18 + mq.viewPadding.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 6),
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: corLinha, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 14),
              RotuloSecao(titulo, titulo: true),
              const SizedBox(height: 10),
              ...filhos,
            ]),
          ),
          Positioned(
            top: 10,
            right: 11,
            child: Toque(
              rotulo: 'Fechar',
              aoTocar: () => Navigator.pop(context),
              child: const SizedBox(width: 32, height: 32, child: Center(child: Text('×', style: TextStyle(fontSize: 24, color: corApagado, height: 1)))),
            ),
          ),
        ]),
      ),
    );
  }
}

/// "Apagar tarefa" de tarefa que se repete: devolve true (só hoje), false (todos os dias) ou null (fechou).
Future<bool?> perguntarApagarRecorrente(BuildContext context, String quando) => abrirFolha<bool>(
      context,
      (ctx) => Folha(titulo: 'Apagar tarefa', filhos: [
        Text('Essa tarefa se repete ($quando). Apagar só hoje ou em todos os dias?', style: const TextStyle(fontSize: 14, height: 1.45, color: corApagado)),
        const SizedBox(height: 14),
        BotaoFolha('Só hoje', aoTocar: () => Navigator.pop(ctx, true)),
        const SizedBox(height: 9),
        BotaoFolha('Hoje e nos outros dias', fundo: corPainel, cor: corVida, borda: const Color(0x59F45781), aoTocar: () => Navigator.pop(ctx, false)),
      ]),
    );

/// "Descansar hoje?": devolve true se o jogador confirmou.
Future<bool?> perguntarDescanso(BuildContext context) => abrirFolha<bool>(
      context,
      (ctx) => Folha(titulo: 'Descansar hoje?', filhos: [
        for (final l in const ['Sem perda de vida nem "Você caiu"', 'A sequência fica congelada, não zera', 'Hoje não rende XP nem moedas', 'Dá pra cancelar a qualquer momento'])
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(width: 20, height: 23.8, child: Center(child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: corSuave, shape: BoxShape.circle))))),
            Expanded(child: Text(l, style: const TextStyle(fontSize: 14, height: 1.7, color: corSuave))),
          ]),
        const SizedBox(height: 16),
        BotaoFolha('Descansar hoje', fundo: corDescansoAtivo, cor: Colors.white, tamanho: 14, padding: 12, aoTocar: () => Navigator.pop(ctx, true)),
        const SizedBox(height: 8),
        Toque(
          aoTocar: () => Navigator.pop(ctx, false),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: Text('Cancelar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: corApagado))),
          ),
        ),
      ]),
    );

/// Linha "rótulo ........ valor" do resumo do dia (.rl-l).
class _LinhaResumo extends StatelessWidget {
  const _LinhaResumo(this.rotulo, this.valor, {this.total = false});
  final String rotulo;
  final String valor;
  final bool total;
  @override
  Widget build(BuildContext context) {
    final cor = total ? const Color(0xFFF2C14E) : corSuave;
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(rotulo, style: TextStyle(fontSize: total ? 15 : 14, fontWeight: total ? FontWeight.w600 : FontWeight.w500, color: cor)),
      const SizedBox(width: 7),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: LayoutBuilder(
            builder: (_, c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (var i = 0; i < (c.maxWidth / 4).floor(); i++) Container(width: 1.5, height: 1.5, color: cor.withValues(alpha: 0.45)),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 7),
      Text(valor, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: total ? cor : corTexto)),
    ]);
  }
}

/// Resumo "Dia vencido" (.md-sheet): monstro derrotado, nível e moedas da vitória.
Future<void> mostrarDiaVencido(
  BuildContext context, {
  required String monstro,
  required int nivel,
  required int xp,
  required int xpMeta,
  required int tarefas,
  required int moedas,
}) =>
    abrirFolha<void>(
      context,
      (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + MediaQuery.of(ctx).viewPadding.bottom),
        decoration: BoxDecoration(
          color: corPainel2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: corLinha, width: 0.8),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 38, height: 4, decoration: BoxDecoration(color: corLinha, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('DIA VENCIDO', style: TextStyle(fontFamily: fontePixel, fontSize: 10, letterSpacing: 1.8, color: corSuave)),
          const SizedBox(height: 8),
          Text('$monstro derrotado', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.27)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              width: double.infinity,
              child: Stack(children: [
                const Positioned.fill(child: ColoredBox(color: corLinha)),
                FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: xpMeta <= 0 ? 0 : (xp / xpMeta).clamp(0.0, 1.0), child: const ColoredBox(color: corOuro, child: SizedBox.expand())),
              ]),
            ),
          ),
          const SizedBox(height: 7),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Nível ${romano(nivel)}', style: const TextStyle(fontSize: 12, color: corApagado)),
            Text('$xp / $xpMeta', style: const TextStyle(fontSize: 12, color: corApagado)),
          ]),
          const SizedBox(height: 16),
          _LinhaResumo('Tarefas concluídas', '$tarefas'),
          const SizedBox(height: 11),
          Container(height: 1.6, color: corLinha),
          const SizedBox(height: 11),
          _LinhaResumo('Moedas', '+$moedas', total: true),
          const SizedBox(height: 18),
          BotaoFolha('Continuar', raio: 14, aoTocar: () => Navigator.pop(ctx)),
        ]),
      ),
    );

/// Diálogo central simples (título, texto e "Continuar"), no estilo dos avisos do app original.
Future<void> mostrarAviso(BuildContext context, {String? selo, required String titulo, required String texto, String botao = 'Continuar'}) {
  HapticFeedback.mediumImpact();
  return showDialog<void>(
    context: context,
    barrierColor: corVeu,
    builder: (ctx) => Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 34),
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
          decoration: BoxDecoration(color: corPainel, borderRadius: BorderRadius.circular(22), border: Border.all(color: corLinha, width: 0.8)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (selo != null) ...[
              Text(selo.toUpperCase(), style: const TextStyle(fontFamily: fontePixel, fontSize: 10, letterSpacing: 1.8, color: corSuave)),
              const SizedBox(height: 8),
            ],
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14.5, height: 1.45, color: corSuave)),
            const SizedBox(height: 20),
            BotaoFolha(botao, aoTocar: () => Navigator.pop(ctx)),
          ]),
        ),
      ),
    ),
  );
}
