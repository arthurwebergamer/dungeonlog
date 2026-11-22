// Raiz do app: carrega dados e save, e mostra a barra de navegação do app original (5 ícones, as 5 abas prontas).
import 'vibra.dart';
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dados/armazenamento.dart';
import '../dados/carregador_assets.dart';
import '../dados/conta.dart';
import '../dados/conta_falsa.dart' show ServicoContaIndisponivel;
import '../dados/nuvem.dart';
import '../dados/sincronizador_nuvem.dart';
import 'crt.dart';
import 'equip_arena.dart';
import 'estado_jogo.dart';
import 'icones.dart';
import 'login_conta.dart';
import 'respiracao.dart';
import 'som.dart';
import 'tela_inventario.dart';
import 'tela_loja.dart';
import 'tela_estatisticas.dart';
import 'tela_perfil.dart';
import 'cfg_base.dart' show BolinhaAviso;
import 'tela_tarefas.dart';
import 'tema.dart';
import '../dominio/entrada.dart';
import '../dominio/tutorial.dart' show telasTutorial;
import 'onboarding.dart';
import 'splash.dart';
import 'tour.dart';

class DungeonlogApp extends StatefulWidget {
  /// [conta]: o serviço de conta (o `main` passa o do Firebase). Sem ele ninguém pode entrar (só "convidado").
  /// [nuvem]: onde o save da conta é sincronizado (o `main` passa o Firestore). Sem ela o jogo fica só no aparelho.
  const DungeonlogApp({super.key, this.conta, this.nuvem});
  final ServicoConta? conta;
  final RepositorioNuvem? nuvem;
  @override
  State<DungeonlogApp> createState() => _DungeonlogAppState();
}

class _DungeonlogAppState extends State<DungeonlogApp> {
  @override
  void initState() {
    super.initState();
    temaMudou.addListener(_aoMudarTema);
    crtAtivo.addListener(_aoMudarCrt);
  }

  @override
  void dispose() {
    temaMudou.removeListener(_aoMudarTema);
    crtAtivo.removeListener(_aoMudarCrt);
    super.dispose();
  }

  /// A paleta é global: troca o tema do MaterialApp e refaz todos os widgets (sem perder o estado das telas).
  void _aoMudarTema() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) reconstruirTudo(context);
    });
  }

  void _aoMudarCrt() => setState(() {});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dungeonlog',
        theme: temaApp(),
        builder: (context, child) => Stack(children: [
          Positioned.fill(child: child ?? const SizedBox.shrink()),
          const Positioned.fill(child: CamadaTour()),
          if (crtAtivo.value) const Positioned.fill(child: CamadaCrt()),
        ]),
        home: _Carregador(conta: widget.conta ?? const ServicoContaIndisponivel(), nuvem: widget.nuvem),
      );
}

class _Carregador extends StatefulWidget {
  const _Carregador({required this.conta, this.nuvem});
  final ServicoConta conta;
  final RepositorioNuvem? nuvem;
  @override
  State<_Carregador> createState() => _CarregadorState();
}

class _CarregadorState extends State<_Carregador> with WidgetsBindingObserver {
  late final Future<EstadoJogo> _futuro = _iniciar();
  EstadoJogo? _estado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _estado?.nuvem?.parar();
    super.dispose();
  }

  /// Nuvem: indo para o fundo sobe o que falta já (sem esperar o atraso); voltando, tenta o que ficou pendente.
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    final n = _estado?.nuvem;
    if (n == null) return;
    if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden || s == AppLifecycleState.detached) {
      n.descarregar();
    } else if (s == AppLifecycleState.resumed) {
      n.aoVoltar();
    }
  }
  Color _corAbertura = Paleta.grafite.bg;
  bool _splashSaiu = false;

  Future<EstadoJogo> _iniciar() async {
    final arm = await ArmazenamentoLocal.abrir();
    // preferências do aparelho: idioma, tema de cor, vibração e efeito CRT (as mesmas chaves do app original)
    var langSalva = arm.ler(chaveIdiomaApp);
    if (langSalva == null || langSalva.isEmpty) {
      // primeira abertura: idioma pelo aparelho (pt-BR = PT, o resto EN), gravado como o script do <head> do original
      langSalva = idiomaPadraoDoAparelho([for (final l in PlatformDispatcher.instance.locales) l.toLanguageTag()]);
      await arm.gravar(chaveIdiomaApp, langSalva);
    }
    final idioma = langSalva == 'en' ? 'en' : 'pt';
    Paleta.atual = Paleta.porId(arm.ler(chaveTema)) ?? Paleta.grafite;
    if (mounted) setState(() => _corAbertura = Paleta.atual.bg);
    final dados = await carregarDadosJogo();
    await EquipArena.carregar();
    await Respiracao.carregar();
    Som.atual = SomAudio(arm);
    crtAtivo.value = arm.ler(chaveCrt) == '1';
    // a sessão do Firebase é restaurada sozinha: quem já entrou antes abre direto na conta. Conta nova que ainda não
    // confirmou o e-mail NÃO abre os dados da conta (a raiz mostra a trava "Confirme seu e-mail").
    final conta = widget.conta;
    conta.definirIdioma(idioma);
    final usuario = conta.atual;
    final trava = usuario != null && usuario.precisaVerificarEmail;
    final nuvem = widget.nuvem == null ? null : SincronizadorNuvem(repo: widget.nuvem!, armazenamento: arm);
    final estado = EstadoJogo(dados: dados, armazenamento: arm, idioma: idioma, uid: usuario != null && !trava ? usuario.uid : null, conta: conta, nuvem: nuvem);
    _estado = estado;
    await estado.sincronizarAoAbrir(); // conta já logada: local x nuvem ANTES de abrir os dados (no máximo 3 s)
    await estado.abrirDonoAtual(); // o herói ativo do dono (conta ou convidado) e o save dele
    Vibra.ligada = estado.vibracaoLigada;
    estado.entrada.value = estado.onboardingPendente ? EntradaModo.completa : EntradaModo.nenhuma;
    if (trava) estado.verificando.value = usuario;
    return estado;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<EstadoJogo>(
        future: _futuro,
        builder: (_, snap) {
          if (snap.hasError) {
            return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Erro ao carregar:\n${snap.error}'))));
          }
          final splash = AberturaSplash(cor: _corAbertura, texto: textoAbertura(PlatformDispatcher.instance.locale.languageCode));
          if (!snap.hasData) return splash;
          final estado = snap.data!;
          return Stack(children: [
            Positioned.fill(
              child: ValueListenableBuilder<UsuarioConta?>(
                valueListenable: estado.verificando,
                builder: (_, pendente, __) => pendente != null
                    ? TelaVerificarEmail(key: ValueKey('verificar-${pendente.uid}'), estado: estado, usuario: pendente)
                    : ValueListenableBuilder<EntradaModo>(
                        valueListenable: estado.entrada,
                        builder: (_, modo, __) => modo == EntradaModo.nenhuma
                            ? Casca(estado: estado, comTutorial: true)
                            : Onboarding(key: ValueKey('entrada-${modo.name}'), estado: estado, somenteLogin: modo == EntradaModo.soLogin, aoConcluir: () => estado.entrada.value = EntradaModo.nenhuma),
                      ),
              ),
            ),
            if (!_splashSaiu)
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: 0),
                  duration: const Duration(milliseconds: 280),
                  onEnd: () => setState(() => _splashSaiu = true),
                  builder: (_, v, __) => IgnorePointer(child: Opacity(opacity: v, child: splash)),
                ),
              ),
          ]);
        },
      );
}

class Casca extends StatefulWidget {
  const Casca({super.key, required this.estado, this.comTutorial = false});
  final EstadoJogo estado;

  /// true no app de verdade: o tutorial guiado abre sozinho na primeira vez (os testes de tela ficam sem ele).
  final bool comTutorial;
  @override
  State<Casca> createState() => _CascaState();
}

class _CascaState extends State<Casca> {
  int _aba = 0;
  TourControle? _tour;

  @override
  void initState() {
    super.initState();
    if (widget.comTutorial) {
      _tour = TourControle(estado: widget.estado, irParaAba: (i) => setState(() => _aba = i), abaAtual: () => _aba);
      TourControle.instancia = _tour;
      // jogador que volta ou que acabou de entrar: a aba Tarefas fala na primeira vez (`agendarDialogoTela('tarefas')`)
      WidgetsBinding.instance.addPostFrameCallback((_) => _tour?.agendar());
    }
  }

  @override
  void dispose() {
    _tour?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // só a aba aberta fica montada: com as cinco vivas, cada compra ou tarefa reconstruía arena, lista, loja e mochila juntas
      body: ValueListenableBuilder<String>(
        valueListenable: widget.estado.personagemAtivo,
        builder: (_, pj, __) => KeyedSubtree(
          key: ValueKey('$pj-$_aba'),
          child: switch (_aba) {
            0 => TelaTarefas(estado: widget.estado),
            1 => TelaInventario(estado: widget.estado),
            2 => TelaLoja(estado: widget.estado),
            3 => TelaPerfil(estado: widget.estado),
            _ => TelaEstatisticas(estado: widget.estado),
          },
        ),
      ),
      bottomNavigationBar: BarraNavegacao(
        estado: widget.estado,
        aba: _aba,
        aoTrocar: (i) {
          Vibra.toque();
          if (i == 0 && _aba != 0) {
            widget.estado.limparPreviewTema();
            widget.estado.piscarSelo();
          }
          setState(() => _aba = i);
          final t = _tour;
          if (t != null && !t.ativo) {
            // as outras telas só marcam "vista" (o tour já cobre todas); Tarefas reabre o tour se ainda não foi visto
            if (i == 0) {
              t.agendar();
            } else {
              widget.estado.marcarTelasVistas([telasTutorial[i]]);
            }
          }
        },
      ),
    );
  }
}

/// Barra inferior do app original (#nav): 5 ícones sem rótulo e uma pílula cinza que desliza até a aba ativa.
class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({super.key, required this.estado, required this.aba, required this.aoTrocar});
  final EstadoJogo estado;
  final int aba;
  final ValueChanged<int> aoTrocar;

  static const _icones = [IconeApp.tarefas, IconeApp.inventario, IconeApp.loja, IconeApp.perfil, IconeApp.estatisticas];
  static const _chaves = ['nav.tarefas', 'nav.inventario', 'nav.loja', 'nav.perfil', 'nav.estatisticas'];

  @override
  Widget build(BuildContext context) {
    final t = estado.dados.traducoes;
    return ListenableBuilder(listenable: estado, builder: (context, _) => Container(
      decoration: BoxDecoration(color: corPainel, border: Border(top: BorderSide(color: corLinha, width: 0.8))),
      padding: EdgeInsets.fromLTRB(8, 6, 8, 6 + MediaQuery.of(context).viewPadding.bottom),
      child: SizedBox(
        height: 54,
        child: LayoutBuilder(builder: (_, c) {
          final largura = c.maxWidth / 5;
          return Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: largura * aba + (largura - 62) / 2,
              top: 2,
              width: 62,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: corAtivo,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x24FFFFFF), width: 0.8),
                  boxShadow: const [BoxShadow(color: Color(0x14FFFFFF), blurRadius: 10)],
                ),
              ),
            ),
            Row(children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == aba,
                    label: t.t(_chaves[i], estado.idioma),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => aoTrocar(i),
                      // o item ocupa os 54 px da barra e o ícone fica no centro (a bolinha não muda o tamanho do item)
                      child: SizedBox.expand(
                        child: Stack(clipBehavior: Clip.none, children: [
                          Center(child: Icone(_icones[i], tamanho: 26, cor: i == aba ? corAccent : corApagado)),
                          // bolinha de conquistas novas no ícone do Perfil (.conqbadge no .nav)
                          if (i == 3 && estado.conquistasNaoVistas > 0) Positioned(left: largura / 2 + 2, top: 2, child: BolinhaAviso(estado.conquistasNaoVistas)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
          ]);
        }),
      ),
    ));
  }
}
