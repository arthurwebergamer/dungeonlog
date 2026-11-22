// Entrada do app (o `#intro` do original): carrossel de 5 slides -> login -> configuração do herói (escolha + nome).
// Só aparece quando não há save começado. Nada é gravado até o fim (EstadoJogo.onboardingPendente).
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dados/conta.dart';
import '../dominio/entrada.dart';
import 'estado_jogo.dart';
import 'login_conta.dart';
import 'icones.dart' show pixel;
import 'onb_comum.dart';
import 'onb_slides.dart';
import 'som.dart';
import 'tema.dart';
import 'vibra.dart';

const _svgGoogle = '<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg"><path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3c-1.6 4.7-6 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.1 8 3l6-6C34 5.1 29.3 3 24 3 12.4 3 3 12.4 3 24s9.4 21 21 21 21-9.4 21-21c0-1.4-.1-2.4-.4-3.5z"/><path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.6 15.9 18.9 13 24 13c3.1 0 5.8 1.1 8 3l6-6C34 5.1 29.3 3 24 3 16.3 3 9.7 7.3 6.3 14.7z"/><path fill="#4CAF50" d="M24 45c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 36.4 26.7 37.3 24 37.3c-5.3 0-9.7-3.3-11.3-8l-6.5 5C9.6 40.6 16.2 45 24 45z"/><path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.3-2.2 4.2-4.1 5.6l6.2 5.2C40.9 36 44 30.5 44 24c0-1.4-.1-2.4-.4-3.5z"/></svg>';

enum _Tela { slide, login, loginForm, boasVindas, heroi, nome }

class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.estado, required this.aoConcluir, this.somenteLogin = false});
  final EstadoJogo estado;
  final VoidCallback aoConcluir;

  /// Abre direto no login (depois de "Sair", de excluir a conta ou pelo "Entrar" das Configurações): sem apresentação.
  final bool somenteLogin;
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  _Tela _tela = _Tela.slide;
  int _slide = 1;
  int _origemLogin = 1;
  int _dir = 1;
  int _heroi = 0;
  String _categoria = ''; // só a escolha desta sessão (nada vem pré-marcado)
  final _nome = TextEditingController();
  bool _nomeErro = false;
  bool _gravando = false;
  final _carregando = ControleCarregando();
  final _msgEmail = ValueNotifier<({String texto, bool ok})?>(null);
  bool _googleEmCurso = false;
  UsuarioConta? _entrou; // quem acabou de entrar (para o "Bem-vindo de volta")

  EstadoJogo get e => widget.estado;
  String get l => e.idioma;

  @override
  void initState() {
    super.initState();
    if (widget.somenteLogin) {
      _tela = _Tela.login;
    } else if (e.logado && e.uid != null) {
      // já tem conta (entrou e o app fechou antes de escolher o herói): só falta o herói
      _tela = _Tela.heroi;
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _carregando.dispose();
    _msgEmail.dispose();
    super.dispose();
  }

  void _ir(_Tela t, {int slide = 0, int dir = 1}) {
    Vibra.toque();
    setState(() {
      if (t == _Tela.login && _tela == _Tela.slide) _origemLogin = _slide;
      _dir = dir;
      _tela = t;
      if (slide > 0) _slide = slide;
    });
  }

  bool get _setaVisivel {
    if (_tela == _Tela.boasVindas) return false;
    if (_tela == _Tela.heroi && e.logado) return false; // depois de entrar na conta não há volta ao login
    if (_tela == _Tela.login && widget.somenteLogin) return !e.onboardingPendente; // só se há um jogo para voltar
    return !(_tela == _Tela.slide && _slide == 1);
  }

  void _voltar() {
    switch (_tela) {
      case _Tela.slide:
        if (_slide > 1) _ir(_Tela.slide, slide: _slide - 1, dir: -1);
      case _Tela.login:
        if (widget.somenteLogin) {
          widget.aoConcluir(); // volta ao jogo (só aparece a seta se há um jogo)
        } else {
          _ir(_Tela.slide, slide: _origemLogin, dir: -1);
        }
      case _Tela.loginForm:
        _ir(_Tela.login, dir: -1);
      case _Tela.boasVindas:
        break;
      case _Tela.heroi:
        _ir(_Tela.login, dir: -1);
      case _Tela.nome:
        _ir(_Tela.heroi, dir: -1);
    }
  }

  Future<void> _convidado() async {
    e.marcarConvidado();
    // já havia jogo local (voltou do "Sair" ou do "Entrar" sem conta): reentra direto, como o original
    if (!e.onboardingPendente) {
      widget.aoConcluir();
      return;
    }
    _ir(_Tela.heroi, dir: 1);
  }

  // ---------- conta ----------
  /// Terminou um login/cadastro/Google: se precisa confirmar o e-mail a raiz mostra a trava; senão troca o dono dos
  /// dados e segue ("Bem-vindo de volta" se já há save desta conta aqui, senão a escolha do herói).
  Future<void> _aoLogar(UsuarioConta u) async {
    if (u.precisaVerificarEmail) {
      _carregando.esconder();
      e.verificando.value = u;
      return;
    }
    final temSave = await e.entrarNaConta(u);
    _carregando.esconder();
    if (!mounted) return;
    _entrou = u;
    if (temSave) {
      _ir(_Tela.boasVindas, dir: 1);
    } else {
      _ir(_Tela.heroi, dir: 1);
    }
  }

  bool get _en => l == 'en';

  void _erroEmail(String texto) => _msgEmail.value = (texto: texto, ok: false);

  Future<void> _google() async {
    if (_googleEmCurso) return;
    _googleEmCurso = true;
    _carregando.mostrar();
    try {
      final u = await e.conta.entrarComGoogle();
      await _aoLogar(u);
    } on ErroConta catch (err) {
      if (err.cancelou) {
        _carregando.esconder(); // fechou o seletor de propósito: não é erro
      } else {
        _carregando.erro(mensagemErroGoogle(err, en: _en));
      }
    } finally {
      _googleEmCurso = false;
    }
  }

  /// "Entrar" / "Criar conta" do formulário de e-mail (as validações e mensagens são as do loginEntrarBtn.onclick).
  Future<void> _enviar(String email, String senha, String confirmar, bool cadastro) async {
    final en = _en;
    email = email.trim();
    _msgEmail.value = null;
    if (email.isEmpty || senha.isEmpty) {
      _erroEmail(en ? 'Fill in email and password' : 'Preencha email e senha');
      return;
    }
    if (cadastro) {
      if (senha != confirmar) {
        _erroEmail(en ? "Passwords don't match" : 'As senhas não são iguais');
        return;
      }
      if (!senhaForteOk(senha)) {
        _erroEmail(en ? 'Password needs at least 6 characters and 1 number' : 'Senha precisa de pelo menos 6 caracteres e 1 número');
        return;
      }
    }
    _carregando.mostrar();
    try {
      e.conta.definirIdioma(e.idioma);
      final u = cadastro ? await e.conta.cadastrar(email, senha) : await e.conta.entrar(email, senha);
      await _aoLogar(u);
    } on ErroConta catch (err) {
      Som.atual.tocar('erro');
      final msg = mensagemErroLogin(err, en: en);
      if (erroDoCampoEmail(err)) {
        _erroEmail(msg);
        _carregando.esconder();
      } else {
        _carregando.erro(msg);
      }
    }
  }

  /// "Esqueceu a senha?": usa o e-mail já digitado; o resultado aparece embaixo do campo.
  Future<void> _esqueci(String email) async {
    final en = _en;
    email = email.trim();
    _msgEmail.value = null;
    if (email.isEmpty) {
      _erroEmail(en ? 'Type your email first' : 'Digita seu email primeiro');
      return;
    }
    try {
      e.conta.definirIdioma(e.idioma);
      await e.conta.enviarRedefinicaoDeSenha(email);
      _msgEmail.value = (texto: en ? 'Recovery email sent -- check your inbox' : 'Email de recuperação enviado -- confira sua caixa de entrada', ok: true);
    } on ErroConta catch (err) {
      _erroEmail(mensagemErroRedefinir(err, en: en));
    }
  }

  Future<void> _concluir() async {
    final n = nomeAoFimDoSetup(_nome.text);
    if (n == null) {
      setState(() => _nomeErro = true);
      return;
    }
    if (_gravando) return;
    _gravando = true;
    Vibra.toque();
    await e.concluirOnboarding(nome: n, heroi: _heroi);
    widget.aoConcluir();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final emSlide = _tela == _Tela.slide;
    final fundoCenario = !emSlide;
    final grad = _slide == 1 || _slide == 5 ? const Color(0xFF333333) : const Color(0xFF323232);
    return PopScope(
      canPop: !_setaVisivel,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltar();
      },
      child: Material(
        color: onbFundoLogin,
        child: Stack(children: [
          // fundos: gradiente do carrossel e cenário (montanhas) do login/configuração, em fusão
          Positioned.fill(child: AnimatedOpacity(duration: const Duration(milliseconds: 450), opacity: emSlide ? 1 : 0, child: FundoGradienteCss(de: grad, ate: const Color(0xFF1E1E1E)))),
          Positioned.fill(child: AnimatedOpacity(duration: const Duration(milliseconds: 350), opacity: fundoCenario ? 1 : 0, child: const CenarioLogin())),
          Padding(
            // o teclado encolhe a área útil (o campo de nome nunca fica coberto; o conteúdo rola)
            padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
            child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 24),
                  child: Column(children: [
                    SizedBox(
                      height: 34,
                      child: Row(children: [
                        Expanded(child: Align(alignment: Alignment.centerLeft, child: SetaVoltarOnb(visivel: _setaVisivel, aoTocar: _voltar, rotulo: l == 'en' ? 'Back' : 'Voltar'))),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: emSlide
                                ? GestureDetector(
                                    key: const ValueKey('onb-pular'),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _ir(_Tela.login, dir: 1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(l == 'en' ? 'Skip' : 'Pular', style: const TextStyle(fontSize: 12, letterSpacing: 0.24, color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Stack(children: [
                        // os pontinhos ficam POR BAIXO do slide (no original o slide é irmão posterior): opções do quiz os cobrem
                        if (emSlide) Positioned(left: 0, right: 0, bottom: 78, child: IgnorePointer(child: Center(child: PontosOnb(total: slidesOnboarding.length, ativo: _slide)))),
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300), // DURACAO_SLIDE do original
                            reverseDuration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) {
                              final k = (child.key as ValueKey<String>).value;
                              final entrando = k == _chaveAtual;
                              return AnimatedBuilder(
                                animation: anim,
                                builder: (_, f) {
                                  // transform .3s var(--spring-curve): passa um pouco do ponto e assenta. A que entra vem de fora (1 -> 0);
                                  // a que sai (o valor do AnimatedSwitcher desce de 1 a 0) vai de 0 para fora, para o lado oposto
                                  final p = curvaMola.transform(entrando ? anim.value : 1 - anim.value);
                                  final fator = entrando ? _dir * (1 - p) : -_dir * p;
                                  return LayoutBuilder(builder: (_, c) => Transform.translate(offset: Offset(fator * c.maxWidth, 0), child: f));
                                },
                                child: child,
                              );
                            },
                            layoutBuilder: (atual, anteriores) => Stack(children: [...anteriores, if (atual != null) atual]),
                            child: KeyedSubtree(key: ValueKey(_chaveAtual), child: _corpo(mq)),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          ),
          CarregandoMasmorra(controle: _carregando, estado: e),
        ]),
      ),
    );
  }

  String get _chaveAtual => _tela == _Tela.slide ? 'slide$_slide' : _tela.name;

  Widget _corpo(MediaQueryData mq) {
    switch (_tela) {
      case _Tela.slide:
        final s = slidesOnboarding[_slide - 1];
        return Column(children: [
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Center(
                    child: ConteudoSlide(
                      slide: s,
                      estado: e,
                      categoria: _categoria,
                      ativo: true,
                      aoEscolher: (id) {
                        Vibra.toque();
                        e.gravarCategoriaOnboarding(id);
                        setState(() => _categoria = id);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          BotaoOnb(s.tBotao(l), chave: ValueKey('onb-btn$_slide'), aoTocar: () => s.numero == 5 ? _ir(_Tela.login, dir: 1) : _ir(_Tela.slide, slide: _slide + 1, dir: 1)),
        ]);
      case _Tela.login:
        return _LoginEscolha(
          idioma: l,
          aoGoogle: _google,
          aoEmail: () => _ir(_Tela.loginForm, dir: 1),
          aoConvidado: _convidado,
        );
      case _Tela.loginForm:
        return _LoginForm(idioma: l, mensagem: _msgEmail, aoEnviar: _enviar, aoEsqueci: _esqueci);
      case _Tela.boasVindas:
        return BoasVindasDeVolta(estado: e, usuario: _entrou ?? e.usuario!, aoContinuar: widget.aoConcluir);
      case _Tela.heroi:
        return _SetupHeroi(estado: e, selecionado: _heroi, aoMudar: (i) => setState(() => _heroi = i), aoContinuar: () => _ir(_Tela.nome, dir: 1));
      case _Tela.nome:
        return _SetupNome(
          estado: e,
          heroi: _heroi,
          controle: _nome,
          erro: _nomeErro,
          aoDigitar: () {
            if (_nomeErro) setState(() => _nomeErro = false);
          },
          aoComecar: _concluir,
          aoVoltar: _voltar,
        );
    }
  }
}

const _sombraTexto = [Shadow(color: Color(0xD9000000), blurRadius: 4, offset: Offset(0, 1))];

/// Posiciona o logo com o centro a 36% da altura da tela (mínimo 96 + metade da altura), como `posicionarMarcas`.
class _MarcaA36 extends StatelessWidget {
  const _MarcaA36({required this.filho, required this.altura});
  final Widget filho;
  final double altura;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, c) {
        final h = MediaQuery.of(ctx).size.height;
        // o bloco ocupa o topo do palco; o palco começa ~82 px abaixo do topo da tela
        final alvo = (h * 0.36).clamp(96 + altura / 2, double.infinity);
        final topo = (alvo - altura / 2 - 82).clamp(0.0, c.maxHeight);
        return Padding(padding: EdgeInsets.only(top: topo), child: Align(alignment: Alignment.topCenter, child: filho));
      });
}

class _LoginEscolha extends StatelessWidget {
  const _LoginEscolha({required this.idioma, required this.aoGoogle, required this.aoEmail, required this.aoConvidado});
  final String idioma;
  final VoidCallback aoGoogle, aoEmail, aoConvidado;
  @override
  Widget build(BuildContext context) {
    final en = idioma == 'en';
    Widget pilula(Key k, Widget icone, String t, VoidCallback f) => GestureDetector(
          key: k,
          behavior: HitTestBehavior.opaque,
          onTap: f,
          child: Container(
            height: 54.8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 3))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [icone, const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, color: Color(0xFF1A1526)))]),
          ),
        );
    Widget link(Key k, String t, VoidCallback f) => GestureDetector(key: k, behavior: HitTestBehavior.opaque, onTap: f, child: Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(t, style: const TextStyle(fontSize: 12.5, color: Colors.white, shadows: _sombraTexto))));
    return Stack(children: [
      _MarcaA36(altura: 54.7, filho: const LogoDungeonlog()),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(en ? 'Your tasks become an adventure' : 'Suas tarefas viram uma aventura', style: TextStyle(fontSize: 15, color: corApagado, shadows: _sombraTexto)),
            const SizedBox(height: 16),
            pilula(const ValueKey('login-google'), SvgPicture.string(_svgGoogle, width: 18, height: 18), en ? 'Continue with Google' : 'Continuar com Google', aoGoogle),
            const SizedBox(height: 16),
            pilula(const ValueKey('login-email'), const Text('📧', style: TextStyle(fontSize: 19, height: 1)), en ? 'Continue with email' : 'Continuar com email', aoEmail),
            const SizedBox(height: 18),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(en ? 'Already have an account?' : 'Já tem conta?', style: TextStyle(fontSize: 14, color: corApagado, shadows: _sombraTexto)),
              const SizedBox(width: 3),
              link(const ValueKey('login-entrar'), en ? 'Log in' : 'Entrar', aoEmail),
            ]),
            const SizedBox(height: 16),
            link(const ValueKey('login-convidado'), en ? 'Continue as guest' : 'Entrar como convidado', aoConvidado),
          ]),
        ),
      ),
    ]);
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.idioma, required this.mensagem, required this.aoEnviar, required this.aoEsqueci});
  final String idioma;

  /// Mensagem embaixo do campo de e-mail (`questlogMostrarErroEmail` / `questlogMostrarOkEmail`): erro em vermelho com o
  /// X no campo, ou sucesso em verde.
  final ValueNotifier<({String texto, bool ok})?> mensagem;
  final Future<void> Function(String email, String senha, String confirmar, bool cadastro) aoEnviar;
  final Future<void> Function(String email) aoEsqueci;
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

enum _Status { nenhum, ok, erro }

class _LoginFormState extends State<_LoginForm> {
  bool _cadastro = false;
  bool _ver = false;
  final _email = TextEditingController(), _senha = TextEditingController(), _conf = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.mensagem.addListener(_mudouMensagem);
  }

  @override
  void dispose() {
    widget.mensagem.removeListener(_mudouMensagem);
    _email.dispose();
    _senha.dispose();
    _conf.dispose();
    super.dispose();
  }

  void _mudouMensagem() {
    if (mounted) setState(() {});
  }

  // check/X em tempo real dos campos de senha (só ao criar a conta; `atualizarStatusSenha` / `atualizarStatusConfirmar`)
  _Status get _statusSenha => !_cadastro || _senha.text.isEmpty ? _Status.nenhum : (senhaForteOk(_senha.text) ? _Status.ok : _Status.erro);
  _Status get _statusConf => !_cadastro || _conf.text.isEmpty ? _Status.nenhum : (_conf.text == _senha.text ? _Status.ok : _Status.erro);

  Widget? _iconeStatus(_Status s) => switch (s) {
        _Status.ok => const Icon(Icons.check_rounded, size: 20, color: Color(0xFF4ADE80)),
        _Status.erro => const Icon(Icons.close_rounded, size: 20, color: corVida),
        _Status.nenhum => null,
      };

  Widget _campo(String rotulo, TextEditingController c, IconData ic, {bool senha = false, String? dica, _Status status = _Status.nenhum, ValueChanged<String>? aoDigitar, Key? chave}) {
    final iconeStatus = _iconeStatus(status);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(rotulo, style: const TextStyle(fontSize: 13, color: onbMudo, shadows: _sombraTexto)),
      const SizedBox(height: 8),
      SizedBox(
        height: 46.8,
        child: TextField(
          key: chave,
          controller: c,
          obscureText: senha && !_ver,
          keyboardType: senha ? TextInputType.visiblePassword : TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: aoDigitar,
          style: const TextStyle(fontSize: 15, color: onbTexto),
          decoration: InputDecoration(
            filled: true,
            fillColor: corPainel2,
            hintText: dica,
            hintStyle: TextStyle(color: corApagado.withValues(alpha: .6)),
            prefixIcon: Icon(ic, size: 20, color: corApagado),
            suffixIcon: (senha || iconeStatus != null)
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    if (iconeStatus != null) iconeStatus,
                    if (senha) IconButton(icon: Icon(_ver ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: corApagado), onPressed: () => setState(() => _ver = !_ver)),
                    if (!senha) const SizedBox(width: 14),
                  ])
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: corLinha, width: 0.8)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: corLinha, width: 0.8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: corAccent, width: 0.8)),
          ),
        ),
      ),
    ]);
  }

  Widget _erroAbaixo(Key k, String texto, {Color cor = corVida}) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Align(alignment: Alignment.centerLeft, child: Text(texto, key: k, style: TextStyle(fontSize: 12, color: cor, shadows: _sombraTexto))),
      );

  @override
  Widget build(BuildContext context) {
    final en = widget.idioma == 'en';
    final msg = widget.mensagem.value;
    final senhaStatus = _statusSenha, confStatus = _statusConf;
    return Stack(children: [
      _MarcaA36(altura: 85.1, filho: Column(mainAxisSize: MainAxisSize.min, children: [
        const LogoDungeonlog(),
        const SizedBox(height: 12),
        Text(_cadastro ? (en ? 'Create your account' : 'Crie sua conta') : (en ? 'Log into your account' : 'Entre na sua conta'), style: TextStyle(fontSize: 14, color: corApagado, shadows: _sombraTexto)),
      ])),
      Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          reverse: true,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _campo(en ? 'Email' : 'Email', _email, Icons.mail_outline, dica: 'voce@email.com', chave: const ValueKey('login-email-campo'), status: msg != null && !msg.ok ? _Status.erro : _Status.nenhum, aoDigitar: (_) {
              if (widget.mensagem.value != null) widget.mensagem.value = null;
            }),
            if (msg != null) _erroAbaixo(const ValueKey('login-msg-email'), msg.texto, cor: msg.ok ? const Color(0xFF4CAF7A) : corVida),
            const SizedBox(height: 18),
            _campo(en ? 'Password' : 'Senha', _senha, Icons.lock_outline, senha: true, dica: '••••••••', chave: const ValueKey('login-senha-campo'), status: senhaStatus, aoDigitar: (_) => setState(() {})),
            if (senhaStatus == _Status.erro) _erroAbaixo(const ValueKey('login-msg-senha'), en ? 'Your password must have at least 6 characters and 1 number' : 'Sua senha deve ter pelo menos 6 caracteres e 1 número'),
            if (_cadastro) ...[
              const SizedBox(height: 18),
              _campo(en ? 'Confirm password' : 'Confirmar senha', _conf, Icons.lock_outline, senha: true, dica: '••••••••', chave: const ValueKey('login-confirmar-campo'), status: confStatus, aoDigitar: (_) => setState(() {})),
              if (confStatus == _Status.erro) _erroAbaixo(const ValueKey('login-msg-confirmar'), en ? "Passwords don't match" : 'As senhas não coincidem'),
            ],
            const SizedBox(height: 10),
            _Termos(idioma: widget.idioma, prefixo: en ? 'By continuing, you agree to the ' : 'Ao continuar, você concorda com os ', cor: const Color(0xFFD5D8DE)),
            if (!_cadastro) ...[
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: GestureDetector(key: const ValueKey('login-esqueci'), onTap: () => widget.aoEsqueci(_email.text), child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(en ? 'Forgot your password?' : 'Esqueceu a senha?', style: const TextStyle(fontSize: 12.5, color: Colors.white, shadows: _sombraTexto))))),
            ],
            const SizedBox(height: 18),
            BotaoPilulaLogin(
              key: const ValueKey('login-enviar'),
              _cadastro ? (en ? 'Create account' : 'Criar conta') : (en ? 'Log in' : 'Entrar'),
              aoTocar: () => widget.aoEnviar(_email.text, _senha.text, _conf.text, _cadastro),
            ),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_cadastro ? (en ? 'Already have an account? ' : 'Já tem conta? ') : (en ? "Don't have an account? " : 'Não tem conta? '), style: TextStyle(fontSize: 13, color: corApagado, shadows: _sombraTexto)),
              GestureDetector(
                key: const ValueKey('login-alternar'),
                onTap: () {
                  widget.mensagem.value = null;
                  setState(() => _cadastro = !_cadastro);
                },
                child: Text(_cadastro ? (en ? 'Log in' : 'Entrar') : (en ? 'Sign up now' : 'Cadastre-se agora'), style: const TextStyle(fontSize: 12.5, color: Colors.white, shadows: _sombraTexto)),
              ),
            ]),
          ]),
        ),
      ),
    ]);
  }
}

/// "Ao continuar, você concorda com os Termos de Uso e a Política de Privacidade" (links para o site, como o original).
class _Termos extends StatefulWidget {
  const _Termos({required this.idioma, required this.prefixo, required this.cor, this.tamanho = 12.5});
  final String idioma, prefixo;
  final Color cor;
  final double tamanho;
  @override
  State<_Termos> createState() => _TermosState();
}

class _TermosState extends State<_Termos> {
  late final _r1 = TapGestureRecognizer()..onTap = () => _abrir('terms');
  late final _r2 = TapGestureRecognizer()..onTap = () => _abrir('privacy');

  Future<void> _abrir(String qual) async {
    try {
      await launchUrl(Uri.parse('https://dungeonlog.weberlabs.com.br/${widget.idioma == 'en' ? 'en/' : ''}$qual'), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  void dispose() {
    _r1.dispose();
    _r2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.idioma == 'en';
    final base = TextStyle(fontSize: widget.tamanho, height: 1.4, color: widget.cor, shadows: _sombraTexto);
    final link = base.copyWith(fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.underline);
    return Text.rich(
      TextSpan(style: base, children: [
        TextSpan(text: widget.prefixo),
        TextSpan(text: en ? 'Terms of Use' : 'Termos de Uso', style: link, recognizer: _r1),
        TextSpan(text: en ? ' and the ' : ' e a '),
        TextSpan(text: en ? 'Privacy Policy' : 'Política de Privacidade', style: link, recognizer: _r2),
      ]),
      textAlign: TextAlign.center,
    );
  }
}

/// Rola o conteúdo dos passos de configuração quando o teclado aperta a tela.
class _Centro extends StatelessWidget {
  const _Centro({required this.filho});
  final Widget filho;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) => SingleChildScrollView(child: ConstrainedBox(constraints: BoxConstraints(minHeight: c.maxHeight), child: Center(child: filho))),
      );
}

class _Pontos2 extends StatelessWidget {
  const _Pontos2(this.ativo);
  final int ativo;
  @override
  Widget build(BuildContext context) => PontosOnb(total: 2, ativo: ativo);
}

class _SetupHeroi extends StatefulWidget {
  const _SetupHeroi({required this.estado, required this.selecionado, required this.aoMudar, required this.aoContinuar});
  final EstadoJogo estado;
  final int selecionado;
  final ValueChanged<int> aoMudar;
  final VoidCallback aoContinuar;
  @override
  State<_SetupHeroi> createState() => _SetupHeroiState();
}

class _SetupHeroiState extends State<_SetupHeroi> {
  static const _passo = 118.0; // 104 de cartão + 14 de vão
  late final PageController _pc = PageController(initialPage: widget.selecionado, viewportFraction: _passo / 350.4);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _ir(int i) {
    final n = widget.estado.dados.herois.length;
    final j = i.clamp(0, n - 1);
    Vibra.toque();
    widget.aoMudar(j);
    _pc.animateToPage(j, duration: const Duration(milliseconds: 260), curve: curvaExpo);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    final en = e.idioma == 'en';
    final herois = e.dados.herois;
    Widget seta(Key k, bool esq) => Positioned(
          left: esq ? -2 : null,
          right: esq ? null : -2,
          top: 43,
          child: GestureDetector(
            key: k,
            onTap: () => _ir(widget.selecionado + (esq ? -1 : 1)),
            child: Container(width: 34, height: 34, decoration: BoxDecoration(color: corPainel3, shape: BoxShape.circle), child: Icon(esq ? Icons.chevron_left : Icons.chevron_right, size: 22, color: corTexto)),
          ),
        );
    return _Centro(
      filho: Column(mainAxisSize: MainAxisSize.min, children: [
        const _Pontos2(1),
        const SizedBox(height: 40),
        CabecalhoOnb(fraca: en ? 'Personalization' : 'Personalização', corFraca: corApagado),
        const SizedBox(height: 40),
        Text(en ? 'Who will face the monsters?' : 'Quem vai enfrentar os monstros?', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: corTexto)),
        const SizedBox(height: 22),
        SizedBox(
          height: 120,
          child: Stack(clipBehavior: Clip.none, children: [
            ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(colors: [Color(0x00000000), Color(0xFF000000), Color(0xFF000000), Color(0x00000000)], stops: [0, .22, .78, 1]).createShader(r),
              child: PageView.builder(
                key: const ValueKey('onb-herois'),
                controller: _pc,
                itemCount: herois.length,
                onPageChanged: (i) {
                  if (i != widget.selecionado) widget.aoMudar(i);
                },
                itemBuilder: (_, i) => AnimatedBuilder(
                  animation: _pc,
                  builder: (_, __) {
                    final pg = _pc.hasClients && _pc.position.haveDimensions ? (_pc.page ?? widget.selecionado.toDouble()) : widget.selecionado.toDouble();
                    final proximo = (1 - (pg - i).abs()).clamp(0.0, 1.0);
                    final sel = proximo > .5;
                    return Center(
                      child: GestureDetector(
                        key: ValueKey('onb-heroi-$i'),
                        onTap: () => _ir(i),
                        child: Opacity(
                          opacity: .4 + .6 * proximo,
                          child: Transform.scale(
                            scale: .82 + .18 * proximo,
                            child: Container(
                              width: 104,
                              height: 104,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel ? corAtivo : corPainel3,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: sel ? corAccent : corLinha, width: 0.8),
                                boxShadow: sel ? [BoxShadow(color: corAccent, spreadRadius: 1), const BoxShadow(color: Color(0x8C000000), blurRadius: 26, offset: Offset(0, 14), spreadRadius: -14)] : null,
                              ),
                              child: pixel(herois[i].img, largura: 76, altura: 76),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            seta(const ValueKey('onb-heroi-ant'), true),
            seta(const ValueKey('onb-heroi-prox'), false),
          ]),
        ),
        const SizedBox(height: 24),
        BotaoOnb(en ? 'Continue' : 'Continuar', chave: const ValueKey('onb-continuar'), aoTocar: widget.aoContinuar),
        const SizedBox(height: 28),
        _Termos(idioma: e.idioma, prefixo: en ? 'By continuing, you agree to the ' : 'Ao continuar, você concorda com os ', cor: const Color(0xB3D5D8DE), tamanho: 12),
        const SizedBox(height: 46),
      ]),
    );
  }
}

class _SetupNome extends StatelessWidget {
  const _SetupNome({required this.estado, required this.heroi, required this.controle, required this.erro, required this.aoDigitar, required this.aoComecar, required this.aoVoltar});
  final EstadoJogo estado;
  final int heroi;
  final TextEditingController controle;
  final bool erro;
  final VoidCallback aoDigitar, aoComecar, aoVoltar;
  @override
  Widget build(BuildContext context) {
    final en = estado.idioma == 'en';
    return _Centro(
      filho: Column(mainAxisSize: MainAxisSize.min, children: [
        const _Pontos2(2),
        const SizedBox(height: 40),
        CabecalhoOnb(fraca: en ? 'Personalization' : 'Personalização', corFraca: corApagado),
        const SizedBox(height: 40),
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [corPainel2, corPainel]), border: Border.all(color: corLinha, width: 0.8)),
          child: pixel(estado.dados.herois[heroi].img, largura: 52, altura: 52),
        ),
        const SizedBox(height: 36),
        Text(en ? 'What should we call you?' : 'Como quer ser chamado?', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: corTexto)),
        const SizedBox(height: 8),
        SizedBox(
          height: 46.8,
          child: TextField(
            key: const ValueKey('onb-nome'),
            controller: controle,
            maxLength: maximoNomeHeroi,
            textAlign: TextAlign.center,
            onChanged: (_) => aoDigitar(),
            onSubmitted: (_) => aoComecar(),
            style: TextStyle(fontSize: 15, color: corTexto),
            cursorColor: corTexto,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: corPainel2,
              hintText: erro ? (en ? 'Choose a name to continue' : 'Escolha um nome pra continuar') : (en ? 'Adventurer' : 'Aventureiro'),
              hintStyle: TextStyle(color: corApagado.withValues(alpha: .6)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: erro ? corVida : corLinha, width: 0.8)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: erro ? corVida : corLinha, width: 0.8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: erro ? corVida : corAccent, width: 0.8)),
            ),
          ),
        ),
        const SizedBox(height: 18),
        BotaoOnb(en ? 'Start the adventure' : 'Começar aventura', chave: const ValueKey('onb-comecar'), aoTocar: aoComecar),
        const SizedBox(height: 18),
        BotaoSecundarioOnb(en ? 'Back' : 'Voltar', aoTocar: aoVoltar),
      ]),
    );
  }
}
