// Aba Tarefas: topo (herói, nível, moedas), arena, barras de vida e XP, botão "Terminar dia" e a lista do dia.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/economia.dart';
import '../dominio/tarefa.dart';
import 'arena.dart';
import 'estado_jogo.dart';
import 'folha_nova_tarefa.dart';
import 'tema.dart';

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _golpe = AnimationController(vsync: this, duration: const Duration(milliseconds: 480), value: 1);
  EstadoJogo get e => widget.estado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    e.addListener(_mudou);
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarEvento());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    e.removeListener(_mudou);
    _golpe.dispose();
    super.dispose();
  }

  void _mudou() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) {
      e.verificarDia(); // virada do dia enquanto o app estava em segundo plano
      WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarEvento());
    }
  }

  Future<void> _mostrarEvento() async {
    final ev = e.consumirEvento();
    if (ev == null || !mounted) return;
    final linhas = <String>[
      if (ev.vitoriaAutomatica) 'Você concluiu todas as tarefas de ontem: a recompensa do dia foi creditada.',
      if (ev.dano > 0) '${ev.largadas} ${ev.largadas == 1 ? 'tarefa largada' : 'tarefas largadas'}: -${ev.dano} de vida.',
      if (ev.caiu) 'Você caiu! Perdeu ${ev.moedasPerdidas} moedas e voltou com a vida cheia.',
    ];
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: corCard,
        title: Text(ev.caiu ? 'Você caiu' : (ev.dano > 0 ? 'O dia virou' : 'Dia concluído')),
        content: Text(linhas.join('\n\n')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continuar'))],
      ),
    );
  }

  Future<void> _concluir(Tarefa t) async {
    final g = e.concluir(t);
    if (g == null) return;
    HapticFeedback.mediumImpact();
    _golpe.forward(from: 0);
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 1400),
      behavior: SnackBarBehavior.floating,
      backgroundColor: corCard,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 92),
      content: Text('+${g.xp} XP   ·   +${g.moedas} ${g.moedas == 1 ? 'moeda' : 'moedas'}', style: const TextStyle(fontWeight: FontWeight.w600)),
    ));
    if (g.subiuNivel) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: corCard,
          title: Text('Nível ${g.nivel}!'),
          content: Text('Sua vida máxima agora é ${e.vidaMaxima}.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continuar'))],
        ),
      );
    }
  }

  Future<void> _terminarDia() async {
    final ganho = e.terminarDia();
    if (ganho == null) return;
    HapticFeedback.heavyImpact();
    _golpe.forward(from: 0);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: corCard,
        title: const Text('Monstro derrotado!'),
        content: Text('+$ganho moedas pela vitória do dia. Sua vida foi restaurada em parte.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continuar'))],
      ),
    );
  }

  Future<void> _menuTarefa(Tarefa t) async {
    HapticFeedback.selectionClick();
    final opcao = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: corCard,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: Text(t.texto ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
          ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Editar'), onTap: () => Navigator.pop(context, 'editar')),
          if (e.ehRecorrente(t)) ...[
            ListTile(leading: const Icon(Icons.today), title: const Text('Apagar só hoje'), onTap: () => Navigator.pop(context, 'hoje')),
            ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Apagar todas'), onTap: () => Navigator.pop(context, 'todas')),
          ] else
            ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Apagar tarefa'), onTap: () => Navigator.pop(context, 'todas')),
        ]),
      ),
    );
    if (opcao == 'editar') {
      if (mounted) await abrirNovaTarefa(context, e, editar: t);
    } else if (opcao != null) {
      e.apagarTarefa(t, soHoje: opcao == 'hoje');
    }
  }

  Future<void> _adicionar() async {
    if (!e.podeCriarTarefa) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('O monstro de hoje já caiu. Novas tarefas só amanhã.')));
      return;
    }
    HapticFeedback.selectionClick();
    await abrirNovaTarefa(context, e);
  }

  @override
  Widget build(BuildContext context) {
    final tarefas = e.tarefasDeHoje;
    final prog = e.progressoAtual;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionar,
        backgroundColor: e.podeCriarTarefa ? Colors.white : Colors.white24,
        foregroundColor: e.podeCriarTarefa ? Colors.black : Colors.white54,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                _Topo(estado: e),
                const SizedBox(height: 12),
                Arena(estado: e, golpe: _golpe),
                _Barra(rotulo: 'VIDA', texto: '${e.vida} / ${e.vidaMaxima}', fracao: e.vidaMaxima == 0 ? 0 : e.vida / e.vidaMaxima, cor: corVida),
                const SizedBox(height: 8),
                _Barra(rotulo: 'XP', texto: '${prog.resto.toInt()} / ${prog.meta}', fracao: prog.meta == 0 ? 0 : (prog.resto / prog.meta).toDouble(), cor: corXp),
                if (e.podeTerminarDia) ...[
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: corDestaque, foregroundColor: Colors.black, padding: const EdgeInsets.all(14)),
                    onPressed: _terminarDia,
                    icon: const Icon(Icons.flag),
                    label: const Text('Terminar dia', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
                const SizedBox(height: 18),
                Row(children: [
                  const Text('Hoje', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${e.nFeitasHoje}/${tarefas.length}', style: const TextStyle(color: corTexto2, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 10),
                if (tarefas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: Text('Nenhuma tarefa para hoje.\nToque em Adicionar para criar a primeira.', textAlign: TextAlign.center, style: TextStyle(color: corTexto2))),
                  ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
            sliver: SliverList.separated(
              itemCount: tarefas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CartaoTarefa(
                key: ObjectKey(tarefas[i]),
                tarefa: tarefas[i],
                estado: e,
                aoConcluir: () => _concluir(tarefas[i]),
                aoSegurar: () => _menuTarefa(tarefas[i]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Topo extends StatelessWidget {
  const _Topo({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final h = estado.heroi;
    return Row(children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: corCard,
        child: ClipOval(child: Image.asset(h.img, width: 40, height: 40, fit: BoxFit.cover, filterQuality: FilterQuality.none)),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(estado.save.nomeHeroi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        Text('Nível ${estado.nivel}', style: const TextStyle(fontSize: 12, color: corTexto2)),
      ]),
      const Spacer(),
      const Icon(Icons.paid, color: corOuro),
      const SizedBox(width: 6),
      Text('${estado.save.moedas.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.rotulo, required this.texto, required this.fracao, required this.cor});
  final String rotulo;
  final String texto;
  final double fracao;
  final Color cor;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 34, child: Text(rotulo, style: const TextStyle(fontSize: 10, color: corTexto2, letterSpacing: 1, fontWeight: FontWeight.w700))),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: fracao.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 10, backgroundColor: corCard, color: cor),
          ),
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(width: 74, child: Text(texto, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
    ]);
  }
}

class _CartaoTarefa extends StatelessWidget {
  const _CartaoTarefa({super.key, required this.tarefa, required this.estado, required this.aoConcluir, required this.aoSegurar});
  final Tarefa tarefa;
  final EstadoJogo estado;
  final VoidCallback aoConcluir;
  final VoidCallback aoSegurar;

  @override
  Widget build(BuildContext context) {
    final feita = estado.feitaHoje(tarefa);
    final meta = tarefa.meta;
    final vezes = tarefa.dados['vezesData'] == estado.hoje ? ((tarefa.dados['vezesN'] as num?)?.toInt() ?? 0) : 0;
    final pips = dificuldades.firstWhere((d) => d.id == tarefa.dif).pips;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: feita ? 0.5 : 1,
      child: Material(
        color: corCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: feita ? null : aoConcluir,
          onLongPress: aoSegurar,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(feita ? Icons.check_circle : Icons.radio_button_unchecked, key: ValueKey(feita), color: feita ? corDestaque : Colors.white54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(tarefa.texto ?? '', style: TextStyle(fontSize: 16, decoration: feita ? TextDecoration.lineThrough : null)),
              ),
              if (meta > 1)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: corFundo, borderRadius: BorderRadius.circular(10)),
                  child: Text('${feita ? meta : vezes}/$meta', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              Text('◆' * pips, style: TextStyle(color: corDificuldade(pips), fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }
}
