// Aba Tarefas, no visual do app original (tema grafite): topo (avatar, nível em romano, moedas), arena,
// cartão de Vida e Experiência, cabeçalho "Tarefas de <dia>" com a lua e "+ Adicionar", e a lista de pendentes.
// Medidas e cores copiadas do CSS computado de play/ em 390x844.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/economia.dart';
import '../dominio/tarefa.dart';
import 'arena.dart';
import 'cerimonia_estagio.dart';
import 'golpes_fx.dart';
import 'som.dart';
import 'popups_md.dart';
import 'popup_bau.dart';
import 'estado_jogo.dart';
import 'folha_nova_tarefa.dart';
import 'folhas.dart';
import 'icones.dart';
import 'som.dart';
import 'tema.dart';
import 'topo.dart';

const _nomesDia = ['domingo', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'];

class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GolpeControlador _golpe = GolpeControlador();
  EstadoJogo get e => widget.estado;
  String _aviso = ''; // texto do aviso que desce do topo (.toast)
  bool _avisoVisivel = false;
  Timer? _avisoTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    e.addListener(_mudou);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mostrarEvento();
      await _verCerimonia();
    });
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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _mostrarEvento();
        await _verCerimonia();
      });
    }
  }

  bool _cerimoniaAberta = false;

  /// Cerimônia de estágio (tela cheia): abre quando o estágio atual passou o último já celebrado.
  Future<void> _verCerimonia() async {
    if (_cerimoniaAberta || !mounted || !e.cerimoniaPendente) return;
    _cerimoniaAberta = true;
    final c = e.iniciarCerimonia();
    if (c != null && mounted) await mostrarCerimoniaEstagio(context, e, c);
    _cerimoniaAberta = false;
  }

  /// Toque num baú da arena (`abrirBauPadrao/Extra/Especial`): marca como aberto e mostra o que saiu.
  void _abrirBau(String qual) {
    final tier = e.tierBauEspecial;
    final itens = e.abrirBau(qual);
    if (itens == null) {
      if (qual == 'especial') Som.atual.tocar('bauTrancado');
      return;
    }
    HapticFeedback.heavyImpact();
    Som.atual.tocar('loot');
    mostrarBauLoot(context, e, itens, variante: qual == 'especial' ? 't${(tier ?? 0).clamp(0, 3)}' : 'padrao');
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
    if (ev.vitoriaAutomatica) {
      await mostrarAviso(context, titulo: 'Dia concluído', texto: 'Você concluiu todas as tarefas de ontem: a recompensa do dia foi creditada.');
      if (!mounted) return;
    }
    if (ev.tarefas.isNotEmpty && ev.dano > 0) {
      _golpe.escapar(ev.tarefas.length);
      await Future<void>.delayed(Duration(milliseconds: GolpeControlador.duracaoEscapada(ev.tarefas.length)));
      if (!mounted) return;
    }
    // "Tarefas perdidas" primeiro (o que escapou) e, se o golpe foi fatal, depois "Você caiu"
    if (ev.tarefas.isNotEmpty && ev.dano > 0) {
      await mostrarTarefasPerdidas(context, e, ev);
      if (!mounted) return;
    }
    if (ev.caiu) await mostrarQueda(context, e, ev.moedasPerdidas);
  }

  /// Toque na caixa: o golpe sai na hora (como no original) e a conta vem em seguida.
  void _golpear([String dif = 'media']) {
    HapticFeedback.mediumImpact();
    _golpe.golpear(dif: dif);
  }

  Future<void> _concluir(Tarefa t) async {
    final g = e.concluir(t);
    if (g == null) return;
    // o golpe aparece primeiro (~1 s); só depois vêm "subiu de nível" e a cerimônia de estágio, como na fila do original
    if (g.subiuNivel || e.cerimoniaPendente) {
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
    }
    if (g.subiuNivel && mounted) {
      await mostrarNivelUp(context, e, g.nivel);
    }
    await _verCerimonia();
  }

  bool _vitoriaEmAndamento = false;

  /// `terminarDia()` do original: golpe crítico → o monstro some numa nuvem → o dia vira "derrotado" (baú aparece)
  /// → só depois o resumo do dia (`dispararVitoriaDoDia`, ~925 ms + 560 ms + 650 ms).
  Future<void> _terminarDia() async {
    if (_vitoriaEmAndamento || !e.podeTerminarDia) return;
    setState(() => _vitoriaEmAndamento = true);
    final nTarefas = e.tarefasDeHoje.length;
    HapticFeedback.heavyImpact();
    Som.atual.tocar('golpe');
    _golpe.golpear(fim: true);
    await Future<void>.delayed(const Duration(milliseconds: 925));
    if (!mounted) return;
    _golpe.poof();
    await Future<void>.delayed(const Duration(milliseconds: 560));
    final ganho = e.terminarDia();
    _golpe.mostrarMonstro();
    if (ganho == null || !mounted) {
      if (mounted) setState(() => _vitoriaEmAndamento = false);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _vitoriaEmAndamento = false);
    await mostrarResumoDia(context, e, nTarefas: nTarefas, ganho: ganho);
    await _verCerimonia();
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
          TopoApp(estado: e),
          Arena(estado: e, golpe: _golpe, aoAbrirBau: _abrirBau),
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
                      if (e.podeTerminarDia && !_vitoriaEmAndamento) ...[
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
  const CaixaTarefa({super.key, required this.feita, required this.aoTocar, this.cor});
  final bool feita;

  /// Cor da tarefa (`.task.comcor`): a borda da caixa vira 60% dessa cor.
  final Color? cor;
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
            border: Border.all(color: feita ? corVerde : (cor?.withValues(alpha: 0.6) ?? corApagado), width: 1.6),
          ),
          child: feita ? const Icone(IconeApp.check, tamanho: 18, cor: corFundo) : null,
        ),
      );
}

/// "#RGB" ou "#RRGGBB" para [Color].
Color corDeHex(String hex) {
  var h = hex.replaceFirst('#', '');
  if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
  return Color(0xFF000000 | int.parse(h, radix: 16));
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
  final void Function(String dif) aoGolpear;
  final VoidCallback aoConcluir;
  final VoidCallback aoEditar;
  final VoidCallback aoApagar;

  @override
  State<_CartaoTarefa> createState() => _CartaoTarefaState();
}

class _CartaoTarefaState extends State<_CartaoTarefa> {
  Color? _cor;
  bool _feita = false; // caixa verde, logo antes de sair
  bool _saindo = false; // desliza para a direita e some (.vanish)
  bool _travado = false; // trava contra toque duplo, como o dataset.travado do original

  int get _vezes {
    final t = widget.tarefa;
    return t.dados['vezesData'] == widget.estado.hoje ? ((t.dados['vezesN'] as num?)?.toInt() ?? 0) : 0;
  }

  Future<void> _tocarCaixa() async {
    if (_travado) return;
    widget.aoGolpear(widget.tarefa.dif);
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
    final hex = t.corBox;
    _cor = hex == null ? null : corDeHex(hex);
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
            decoration: BoxDecoration(color: _cor == null ? corPainel3 : Color.alphaBlend(_cor!.withValues(alpha: 0.10), corPainel3), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              CaixaTarefa(feita: _feita, aoTocar: _tocarCaixa, cor: _cor),
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
