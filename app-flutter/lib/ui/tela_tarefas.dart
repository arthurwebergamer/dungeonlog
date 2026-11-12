// Aba Tarefas, no visual do app original (tema grafite): topo (avatar, nível em romano, moedas), arena,
// cartão de Vida e Experiência, cabeçalho "Tarefas de <dia>" com a lua e "+ Adicionar", e a lista de pendentes.
// Medidas e cores copiadas do CSS computado de play/ em 390x844.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/economia.dart';
import '../dominio/tarefa.dart';
import 'arena.dart';
import 'tela_inventario.dart';
import 'estado_jogo.dart';
import 'folha_nova_tarefa.dart';
import 'folhas.dart';
import 'icones.dart';
import 'tema.dart';

const _nomesDia = ['domingo', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'];

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _golpe = AnimationController(vsync: this, duration: const Duration(milliseconds: 480), value: 1);
  EstadoJogo get e => widget.estado;
  String _aviso = ''; // texto do aviso que desce do topo (.toast)
  bool _avisoVisivel = false;
  Timer? _avisoTimer;

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
    _avisoTimer?.cancel();
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

  void _abrirBau() {
    final itens = e.abrirBauPadrao();
    if (itens == null) return;
    HapticFeedback.heavyImpact();
    abrirFolha<void>(
      context,
      (ctx) => Folha(titulo: 'Baú do dia', filhos: [
        for (final it in itens)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(14), border: Border.all(color: corRaridade[it.raridade.clamp(0, 7)])),
              child: Row(children: [
                SpriteItem(estado: e, item: it, tamanho: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(it.nomeNoIdioma(e.idioma), style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(nomeRaridade(it.raridade, e.idioma), style: TextStyle(fontSize: 12, color: corRaridade[it.raridade.clamp(0, 7)])),
                  ]),
                ),
              ]),
            ),
          ),
        const SizedBox(height: 6),
        BotaoFolha('Guardar no inventário', aoTocar: () => Navigator.pop(ctx)),
      ]),
    );
  }

  void _avisar(String texto) {
    _avisoTimer?.cancel();
    setState(() {
      _aviso = texto;
      _avisoVisivel = true;
    });
    _avisoTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _avisoVisivel = false); // o texto fica até a pílula sumir
    });
  }

  Future<void> _mostrarEvento() async {
    final ev = e.consumirEvento();
    if (ev == null || !mounted) return;
    final linhas = <String>[
      if (ev.vitoriaAutomatica) 'Você concluiu todas as tarefas de ontem: a recompensa do dia foi creditada.',
      if (ev.dano > 0) '${ev.largadas} ${ev.largadas == 1 ? 'tarefa largada' : 'tarefas largadas'}: -${ev.dano} de vida.',
      if (ev.caiu) 'Você caiu! Perdeu ${ev.moedasPerdidas} moedas e voltou com a vida cheia.',
    ];
    await mostrarAviso(context, titulo: ev.caiu ? 'Você caiu' : (ev.dano > 0 ? 'O dia virou' : 'Dia concluído'), texto: linhas.join('\n\n'));
  }

  /// Toque na caixa: o golpe sai na hora (como no original) e a conta vem em seguida.
  void _golpear() {
    HapticFeedback.mediumImpact();
    _golpe.forward(from: 0);
  }

  Future<void> _concluir(Tarefa t) async {
    final g = e.concluir(t);
    if (g == null) return;
    _avisar('+${g.xp} XP   ·   +${g.moedas} ${g.moedas == 1 ? 'moeda' : 'moedas'}');
    if (g.subiuNivel && mounted) {
      await mostrarAviso(context, selo: 'Subiu de nível', titulo: 'Nível ${romano(g.nivel)}', texto: 'Sua vida máxima agora é ${e.vidaMaxima}.');
    }
  }

  Future<void> _terminarDia() async {
    final nTarefas = e.tarefasDeHoje.length;
    final ganho = e.terminarDia();
    if (ganho == null) return;
    HapticFeedback.heavyImpact();
    _golpe.forward(from: 0);
    if (!mounted) return;
    final p = e.progressoAtual;
    await mostrarDiaVencido(
      context,
      monstro: e.monstro.nomeNoIdioma(e.idioma),
      nivel: p.nivel,
      xp: p.resto.toInt(),
      xpMeta: p.meta.toInt(),
      tarefas: nTarefas,
      moedas: ganho,
    );
  }

  Future<void> _adicionar() async {
    if (!e.podeCriarTarefa) return;
    HapticFeedback.selectionClick();
    await abrirNovaTarefa(context, e);
  }

  Future<void> _descanso() async {
    HapticFeedback.selectionClick();
    if (e.descansando) {
      e.definirDescanso(false);
      return;
    }
    if (await perguntarDescanso(context) == true) e.definirDescanso(true);
  }

  String get _vazio {
    final total = e.tarefasDeHoje.length;
    if (e.descansando) return 'Descansando hoje.\nVolte quando estiver bem.';
    if (total == 0) return '${e.monstro.nomeNoIdioma(e.idioma)} está à espreita.\nAdicione tarefas para encarar.';
    return e.derrotado ? 'Tudo concluído.\nO monstro de hoje foi derrotado.' : 'Tudo concluído por enquanto.\nAdicione mais tarefas ou toque em Terminar dia.';
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = e.pendentesDeHoje;
    final prog = e.progressoAtual;
    final total = e.tarefasDeHoje.length;
    final diaSemana = DateTime.parse(e.hoje).weekday % 7;
    return Stack(children: [
      SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _Topo(estado: e),
          Arena(estado: e, golpe: _golpe),
          if (e.bauPadraoFechado) _BotaoBau(aoTocar: _abrirBau),
          const SizedBox(height: 14),
          _CartaoBarras(
            vida: e.vida,
            vidaMaxima: e.vidaMaxima,
            xp: prog.resto.toInt(),
            xpMeta: prog.meta.toInt(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 13),
            child: _Cabecalho(
              titulo: 'Tarefas de ${_nomesDia[diaSemana]}',
              subtitulo: e.descansando ? 'Descansando hoje — progresso protegido' : '${e.nFeitasHoje} de $total concluídas',
              descansando: e.descansando,
              mostrarLua: e.descansando || !e.derrotado,
              podeAdicionar: e.podeCriarTarefa,
              aoDescansar: _descanso,
              aoAdicionar: _adicionar,
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: e.descansando ? 0.45 : 1,
              child: CustomScrollView(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverReorderableList(
                    itemCount: pendentes.length,
                    onReorderItem: (de, para) {
                      HapticFeedback.selectionClick();
                      e.reordenar(de, para);
                    },
                    proxyDecorator: (filho, _, __) => Material(type: MaterialType.transparency, child: Transform.scale(scale: 1.02, child: filho)),
                    itemBuilder: (_, i) {
                      final t = pendentes[i];
                      return ReorderableDelayedDragStartListener(
                        key: ObjectKey(t),
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 13),
                          child: _CartaoTarefa(
                            tarefa: t,
                            indice: i,
                            estado: e,
                            aoGolpear: _golpear,
                            aoConcluir: () => _concluir(t),
                            aoEditar: () => abrirNovaTarefa(context, e, editar: t),
                            aoApagar: () => apagarTarefaPerguntando(context, e, t),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 68),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (pendentes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
                          child: Text(_vazio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5, color: corApagado)),
                        ),
                      if (e.podeTerminarDia) ...[
                        const SizedBox(height: 14),
                        BotaoFolha('Terminar dia', aoTocar: _terminarDia),
                      ],
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
      // aviso que desce do topo: pílula branca com letra pixel (.toast)
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        child: SafeArea(
          child: IgnorePointer(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              offset: Offset(0, _avisoVisivel ? 0 : -1.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _avisoVisivel ? 1 : 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 20, offset: Offset(0, 6))],
                    ),
                    child: Text(_aviso, style: const TextStyle(fontFamily: fontePixel, fontSize: 13, color: corFundo)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// Topo: avatar redondo do herói + "Nível II" à esquerda, pilha de moedas + número à direita (.topbar).
class _Topo extends StatelessWidget {
  const _Topo({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: SizedBox(
        height: 30,
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: corPainel2, shape: BoxShape.circle, border: Border.all(color: corLinha, width: 0.8)),
            // background-size:154% / position:50% 8% -> o rosto do herói
            child: OverflowBox(
              maxWidth: 43.12,
              maxHeight: 43.12,
              minWidth: 43.12,
              minHeight: 43.12,
              alignment: const Alignment(0, -0.84),
              child: pixel(estado.heroi.img, largura: 43.12, altura: 43.12),
            ),
          ),
          const SizedBox(width: 6),
          Text('Nível ${romano(estado.nivel)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          pixel('assets/img/ui/moedas.png', largura: 30, altura: 30),
          const SizedBox(width: 6),
          Text('${estado.save.moedas.toInt()}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: corOuro)),
        ]),
      ),
    );
  }
}

/// Cartão com as barras de Vida (rosa) e Experiência (laranja -> amarelo) (.xpwrap).
class _CartaoBarras extends StatelessWidget {
  const _CartaoBarras({required this.vida, required this.vidaMaxima, required this.xp, required this.xpMeta});
  final int vida;
  final int vidaMaxima;
  final int xp;
  final int xpMeta;

  Widget _linha(String rotulo, String numero, Color corNumero) => SizedBox(
        height: 19.2,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(rotulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: corSuave, height: 1.23)),
          const Spacer(),
          Text(numero, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: corNumero, height: 1.28, fontFeatures: algarismosFixos)),
        ]),
      );

  Widget _barra(double fracao, {Color? cor, Gradient? degrade}) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 7,
          color: const Color(0x52000000),
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: fracao.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: cor, gradient: degrade, borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          _linha('Vida', '$vida / $vidaMaxima', corVida),
          const SizedBox(height: 4),
          _barra(vidaMaxima == 0 ? 0 : vida / vidaMaxima, cor: corVida),
          const SizedBox(height: 10),
          _linha('Experiência', '$xp / $xpMeta', corTexto),
          const SizedBox(height: 4),
          _barra(xpMeta == 0 ? 0 : xp / xpMeta, degrade: const LinearGradient(colors: [corXpA, corXpB])),
        ]),
      );
}

/// "Tarefas de quinta" + "0 de 2 concluídas", botão da lua (descanso) e "+ Adicionar" (.thead).
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.titulo,
    required this.subtitulo,
    required this.descansando,
    required this.mostrarLua,
    required this.podeAdicionar,
    required this.aoDescansar,
    required this.aoAdicionar,
  });
  final String titulo;
  final String subtitulo;
  final bool descansando;
  final bool mostrarLua;
  final bool podeAdicionar;
  final VoidCallback aoDescansar;
  final VoidCallback aoAdicionar;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(titulo, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: 0.19, height: 1.263)),
              Text(subtitulo, style: const TextStyle(fontSize: 13, color: corApagado, height: 1.23)),
            ]),
          ),
          if (mostrarLua) ...[
            const SizedBox(width: 6),
            Toque(
              rotulo: descansando ? 'Cancelar descanso' : 'Descansar',
              aoTocar: aoDescansar,
              child: Container(
                height: 28,
                padding: EdgeInsets.symmetric(horizontal: descansando ? 10 : 7.5),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: descansando ? corDescansoAtivo : corDescanso, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icone(IconeApp.lua, tamanho: 10, cor: descansando ? Colors.white : corDescansoTexto),
                  if (descansando) ...[
                    const SizedBox(width: 4),
                    const Text('Cancelar descanso', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white, height: 1.3)),
                  ],
                ]),
              ),
            ),
          ],
          const SizedBox(width: 6),
          Opacity(
            opacity: podeAdicionar ? 1 : 0.4,
            child: Toque(
              aoTocar: podeAdicionar ? aoAdicionar : null,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                child: const Text('+ Adicionar', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: corFundo)),
              ),
            ),
          ),
        ]),
      );
}

/// Caixa de seleção quadrada arredondada da tarefa (.box).
class CaixaTarefa extends StatelessWidget {
  const CaixaTarefa({super.key, required this.feita, required this.aoTocar});
  final bool feita;
  final VoidCallback aoTocar;
  @override
  Widget build(BuildContext context) => Toque(
        rotulo: 'Concluir tarefa',
        aoTocar: aoTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: feita ? corVerde : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: feita ? corVerde : corApagado, width: 1.6),
          ),
          child: feita ? const Icone(IconeApp.check, tamanho: 18, cor: corFundo) : null,
        ),
      );
}

/// Cartão de tarefa (.task): caixa, título, losangos + repetição + contador, "x" de apagar e alça de arrastar.
class _CartaoTarefa extends StatefulWidget {
  const _CartaoTarefa({
    required this.tarefa,
    required this.indice,
    required this.estado,
    required this.aoGolpear,
    required this.aoConcluir,
    required this.aoEditar,
    required this.aoApagar,
  });
  final Tarefa tarefa;
  final int indice;
  final EstadoJogo estado;
  final VoidCallback aoGolpear;
  final VoidCallback aoConcluir;
  final VoidCallback aoEditar;
  final VoidCallback aoApagar;

  @override
  State<_CartaoTarefa> createState() => _CartaoTarefaState();
}

class _CartaoTarefaState extends State<_CartaoTarefa> {
  bool _feita = false; // caixa verde, logo antes de sair
  bool _saindo = false; // desliza para a direita e some (.vanish)
  bool _travado = false; // trava contra toque duplo, como o dataset.travado do original

  int get _vezes {
    final t = widget.tarefa;
    return t.dados['vezesData'] == widget.estado.hoje ? ((t.dados['vezesN'] as num?)?.toInt() ?? 0) : 0;
  }

  Future<void> _tocarCaixa() async {
    if (_travado) return;
    widget.aoGolpear();
    if (_vezes + 1 < widget.tarefa.meta) {
      widget.aoConcluir(); // toque parcial (meta > 1): só soma no contador
      return;
    }
    _travado = true;
    setState(() => _feita = true);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() => _saindo = true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    widget.aoConcluir();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tarefa;
    final meta = t.meta;
    final pips = dificuldades.firstWhere((d) => d.id == t.dif).pips;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: Offset(_saindo ? 0.11 : 0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _saindo ? 0 : (_feita ? 0.5 : 1),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _travado ? null : widget.aoEditar,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.fromLTRB(11, 7, 8, 7),
            decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              CaixaTarefa(feita: _feita, aoTocar: _tocarCaixa),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    t.texto ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: _feita ? corApagado : corTexto,
                      decoration: _feita ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 14.4,
                    child: Row(children: [
                      Losangos(pips, cor: corDificuldade(pips)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(rotuloTarefa(t), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: corApagado, height: 1.3)),
                      ),
                      if (meta > 1) ...[
                        const SizedBox(width: 8),
                        Text('$_vezes/$meta', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3)),
                      ],
                    ]),
                  ),
                ]),
              ),
              const SizedBox(width: 10),
              Toque(
                rotulo: 'Apagar tarefa',
                aoTocar: widget.aoApagar,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0x0BFFFFFF), borderRadius: BorderRadius.circular(12)),
                  child: const Text('×', style: TextStyle(fontSize: 21, color: corApagado, height: 1)),
                ),
              ),
              const SizedBox(width: 10),
              ReorderableDragStartListener(
                index: widget.indice,
                child: const Opacity(
                  opacity: 0.8,
                  child: SizedBox(width: 30, height: 38, child: Center(child: Icone(IconeApp.alca, tamanho: 18, cor: corApagado))),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Botão do baú do dia (aparece depois de vencer o dia, até abrir).
class _BotaoBau extends StatelessWidget {
  const _BotaoBau({required this.aoTocar});
  final VoidCallback aoTocar;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: GestureDetector(
          onTap: aoTocar,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: corXpB, borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('Abrir baú do dia', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15))),
          ),
        ),
      );
}
