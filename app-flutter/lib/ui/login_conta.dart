// Peças de conta das telas (Fase 6, parte A): o "bonequinho correndo" de carregamento do login (`#loadingMasmorra`),
// "Bem-vindo de volta" (`#passoBoasVindas`), a trava "Confirme seu e-mail" (`#passoVerificarEmail`) e a folha "Excluir
// conta?" (`#excluirContaOverlay`). Textos e regras de play/index.html (~16903, ~18980, ~19103, ~14051 e ~14960).
import 'dart:async';

import 'package:flutter/material.dart';

import '../dados/conta.dart';
import 'cfg_base.dart' show tr;
import 'estado_jogo.dart';
import 'folhas.dart';
import 'icones.dart' show pixel;
import 'onb_comum.dart';
import 'som.dart';
import 'tema.dart';
import 'vibra.dart';

const sombraTextoConta = [Shadow(color: Color(0xD9000000), blurRadius: 4, offset: Offset(0, 1))];

// ---------------------------------------------------------------- carregando ("masmorra")
enum FaseCarregando { oculto, carregando, erro }

/// Liga e desliga o carregamento (`mostrarLoadingMasmorra` / `esconderLoadingMasmorra` / `erroLoadingMasmorra`).
class ControleCarregando extends ChangeNotifier {
  FaseCarregando fase = FaseCarregando.oculto;
  String mensagem = '';

  void mostrar() {
    fase = FaseCarregando.carregando;
    notifyListeners();
  }

  void esconder() {
    if (fase == FaseCarregando.oculto) return;
    fase = FaseCarregando.oculto;
    notifyListeners();
  }

  /// O herói tomba e aparece "Algo deu errado" + a mensagem + "Tentar de novo" (que só fecha e devolve ao formulário).
  void erro(String msg) {
    fase = FaseCarregando.erro;
    mensagem = msg;
    notifyListeners();
  }
}

const _frasesPt = ['Carregando a masmorra...', 'Acordando o herói...', 'Afiando a espada...', 'Acendendo as tochas...', 'Abrindo o portal...', 'Consultando o oráculo...'];
const _frasesEn = ['Loading the dungeon...', 'Waking the hero...', 'Sharpening the sword...', 'Lighting the torches...', 'Opening the portal...', 'Consulting the oracle...'];

/// Tela cheia de carregamento por cima do login: cor de fundo do tema, o herói "Loiro" (índice 1, sempre) pulando e uma
/// frase que troca a cada 1,8 s. No erro o herói tomba (1,1 s) e entram o texto, a mensagem e o botão, em escada.
class CarregandoMasmorra extends StatefulWidget {
  const CarregandoMasmorra({super.key, required this.controle, required this.estado});
  final ControleCarregando controle;
  final EstadoJogo estado;
  @override
  State<CarregandoMasmorra> createState() => _CarregandoMasmorraState();
}

class _CarregandoMasmorraState extends State<CarregandoMasmorra> with TickerProviderStateMixin {
  late final AnimationController _pulo = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final AnimationController _queda = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  Timer? _frases;
  Timer? _desmontar;
  int _i = 0;
  bool _visivel = false; // o alvo da transição de 250 ms
  bool _montado = false; // o conteúdo existe (some só depois do fade)

  @override
  void initState() {
    super.initState();
    widget.controle.addListener(_mudou);
    _mudou();
  }

  @override
  void didUpdateWidget(CarregandoMasmorra old) {
    super.didUpdateWidget(old);
    if (old.controle != widget.controle) {
      old.controle.removeListener(_mudou);
      widget.controle.addListener(_mudou);
    }
  }

  @override
  void dispose() {
    widget.controle.removeListener(_mudou);
    _frases?.cancel();
    _desmontar?.cancel();
    _pulo.dispose();
    _queda.dispose();
    super.dispose();
  }

  void _mudou() {
    final f = widget.controle.fase;
    _frases?.cancel();
    _frases = null;
    if (f == FaseCarregando.carregando) {
      _i = 0;
      _queda.value = 0;
      if (!_pulo.isAnimating) _pulo.repeat(reverse: true);
      _frases = Timer.periodic(const Duration(milliseconds: 1800), (_) {
        if (mounted) setState(() => _i = _i + 1);
      });
    } else if (f == FaseCarregando.erro) {
      _pulo.stop();
      _queda.forward(from: 0);
    } else {
      _pulo.stop();
    }
    final ligar = f != FaseCarregando.oculto;
    if (!mounted) {
      _visivel = ligar;
      _montado = ligar;
      return;
    }
    _desmontar?.cancel();
    setState(() {
      _visivel = ligar;
      if (ligar) _montado = true;
    });
    // some de vez depois do fade de 250 ms (um Timer, e não o onEnd do fade, que não dispara se o carregando abre e fecha
    // antes de um quadro)
    if (!ligar) {
      _desmontar = Timer(const Duration(milliseconds: 280), () {
        if (mounted && !_visivel) setState(() => _montado = false);
      });
    }
  }

  // keyframes do `loadingMasmorraTombar`: (tempo 0..1, y, graus, escalaX, escalaY)
  static const _quadros = <(double, double, double, double, double)>[
    (0, -10, 4, 1, 1),
    (.28, 0, 0, 1.12, .86),
    (.40, 0, 0, .96, 1.04),
    (.55, -4, -14, 1, 1),
    (.75, 0, -72, 1, 1),
    (1, -2, -90, 1, 1),
  ];

  Widget _sprite(bool erro) {
    final img = widget.estado.dados.herois[widget.estado.dados.herois.length > 1 ? 1 : 0].img;
    return AnimatedBuilder(
      animation: Listenable.merge([_pulo, _queda]),
      builder: (_, __) {
        double y, g, sx = 1, sy = 1;
        if (erro) {
          final t = (_queda.value * 1.6 / 1.1).clamp(0.0, 1.0);
          var k = 0;
          while (k < _quadros.length - 2 && t > _quadros[k + 1].$1) {
            k++;
          }
          final a = _quadros[k], b = _quadros[k + 1];
          final u = ((t - a.$1) / (b.$1 - a.$1)).clamp(0.0, 1.0);
          double l(double x, double z) => x + (z - x) * u;
          y = l(a.$2, b.$2);
          g = l(a.$3, b.$3);
          sx = l(a.$4, b.$4);
          sy = l(a.$5, b.$5);
        } else {
          final t = Curves.easeInOut.transform(_pulo.value);
          y = -10 * t;
          g = -4 + 8 * t;
        }
        return Transform.translate(
          offset: Offset(0, y),
          child: Transform(
            alignment: erro ? const Alignment(0, .76) : Alignment.center,
            transform: Matrix4.rotationZ(g * 3.14159265 / 180)..scaleByDouble(sx, sy, 1, 1),
            child: pixel(img, largura: 56, altura: 56),
          ),
        );
      },
    );
  }

  Widget _sobe(double inicio, Widget filho) => AnimatedBuilder(
        animation: _queda,
        builder: (_, f) {
          final t = Interval(inicio, inicio + 0.4 / 1.6, curve: Curves.easeOut).transform(_queda.value);
          return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 6 * (1 - t)), child: f));
        },
        child: filho,
      );

  @override
  Widget build(BuildContext context) {
    final c = widget.controle;
    final en = widget.estado.idioma == 'en';
    final erro = c.fase == FaseCarregando.erro;
    final frases = en ? _frasesEn : _frasesPt;
    return Positioned.fill(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: curvaExpo,
        opacity: _visivel ? 1 : 0,
        child: !_montado
            ? const SizedBox.shrink()
            : GestureDetector(
                key: const ValueKey('carregando-masmorra'),
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: ColoredBox(
                  color: corFundo,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(width: 56, height: 56 + 10, child: Align(alignment: Alignment.bottomCenter, child: _sprite(erro))),
                        SizedBox(height: erro ? 14 : 16),
                        if (erro)
                          _sobe(.9 / 1.6, Text(en ? 'Something went wrong' : 'Algo deu errado', textAlign: TextAlign.center, style: TextStyle(fontFamily: fontePixel, fontSize: 12, color: const Color(0xFFE5698A), letterSpacing: .24, decoration: TextDecoration.none)))
                        else
                          Text(frases[_i % frases.length], textAlign: TextAlign.center, style: TextStyle(fontFamily: fontePixel, fontSize: 12, color: corApagado, letterSpacing: .24, decoration: TextDecoration.none)),
                        if (erro) ...[
                          const SizedBox(height: 16),
                          _sobe(1.05 / 1.6, ConstrainedBox(constraints: const BoxConstraints(maxWidth: 260), child: Text(c.mensagem, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.4, color: corTexto, decoration: TextDecoration.none, fontWeight: FontWeight.w400)))),
                          const SizedBox(height: 16),
                          _sobe(
                            1.2 / 1.6,
                            GestureDetector(
                              key: const ValueKey('carregando-tentar-de-novo'),
                              behavior: HitTestBehavior.opaque,
                              onTap: c.esconder,
                              child: Container(
                                height: 46,
                                padding: const EdgeInsets.symmetric(horizontal: 26),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: corAccent, borderRadius: BorderRadius.circular(999)),
                                child: Text(en ? 'Try again' : 'Tentar de novo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: corFundo, decoration: TextDecoration.none)),
                              ),
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------- botão pílula do login
/// O botão principal do login (`#passoLogin .primario`): pílula branca com degradê e sombra dura.
class BotaoPilulaLogin extends StatelessWidget {
  const BotaoPilulaLogin(this.texto, {super.key, required this.aoTocar, this.altura = 47.2});
  final String texto;
  final VoidCallback? aoTocar;
  final double altura;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: aoTocar,
        child: Container(
          height: altura,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Color(0xFFECECEC)]),
            boxShadow: const [BoxShadow(color: Color(0xFFA9A9A9), offset: Offset(0, 4))],
          ),
          child: Text(texto, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
        ),
      );
}

Widget _linkLogin(Key k, String texto, VoidCallback aoTocar) => GestureDetector(
      key: k,
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(texto, style: const TextStyle(fontSize: 12.5, color: Colors.white, shadows: sombraTextoConta))),
    );

// ---------------------------------------------------------------- bem-vindo de volta
/// Quem entra numa conta que já tem save neste aparelho: herói, "Bem-vindo de volta", nome, nível, Continuar e
/// "Não é você? Trocar de conta" (que sai da conta e volta ao login).
class BoasVindasDeVolta extends StatelessWidget {
  const BoasVindasDeVolta({super.key, required this.estado, required this.usuario, required this.aoContinuar});
  final EstadoJogo estado;
  final UsuarioConta usuario;
  final VoidCallback aoContinuar;

  @override
  Widget build(BuildContext context) {
    final e = estado;
    final en = e.idioma == 'en';
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          pixel(e.heroi.img, largura: 96, altura: 96),
          const SizedBox(height: 10),
          Text(tr(e, 'login.bemVindoDeVolta'), style: const TextStyle(fontSize: 14, color: Color(0xFF909090), shadows: sombraTextoConta)),
          const SizedBox(height: 6),
          Text(usuario.nome, key: const ValueKey('boas-vindas-nome'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: onbTexto, height: 1.2, shadows: [Shadow(color: Color(0xD9000000), blurRadius: 10, offset: Offset(0, 2))])),
          const SizedBox(height: 6),
          Text('${en ? 'Level' : 'Nível'} ${romano(e.nivel)}'.toUpperCase(), style: const TextStyle(fontFamily: fontePixel, fontSize: 11, letterSpacing: .88, color: Color(0xFF909090), shadows: sombraTextoConta)),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: BotaoPilulaLogin(tr(e, 'acao.continuar'), aoTocar: aoContinuar)),
          const SizedBox(height: 10),
          _linkLogin(const ValueKey('boas-vindas-trocar'), tr(e, 'login.trocarConta'), () {
            Vibra.toque();
            e.sairDaConta();
          }),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------- confirmar e-mail
/// A trava "Confirme seu e-mail": conta nova de e-mail/senha só entra depois de abrir o link. Confere sozinha a cada 4 s
/// (`recarregar`), sem botão manual. "Reenviar email" e "Email errado? Corrigir" (apaga a conta recém-criada e volta ao login).
class TelaVerificarEmail extends StatefulWidget {
  const TelaVerificarEmail({super.key, required this.estado, required this.usuario});
  final EstadoJogo estado;
  final UsuarioConta usuario;
  @override
  State<TelaVerificarEmail> createState() => _TelaVerificarEmailState();
}

class _TelaVerificarEmailState extends State<TelaVerificarEmail> {
  Timer? _poll;
  Timer? _msgTimer;
  bool _ocupado = false;
  bool _terminou = false;
  String? _msg;
  bool _msgOk = false;

  EstadoJogo get e => widget.estado;
  bool get en => e.idioma == 'en';

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _checar());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _msgTimer?.cancel();
    super.dispose();
  }

  Future<void> _checar() async {
    if (_ocupado || _terminou) return;
    _ocupado = true;
    try {
      final u = await e.conta.recarregar();
      if (_terminou) return;
      if (u == null) {
        // a conta sumiu (apagada em outro lugar): volta ao login
        _terminou = true;
        e.verificando.value = null;
        e.entrada.value = EntradaModo.soLogin;
        return;
      }
      if (!u.precisaVerificarEmail) {
        _terminou = true;
        _poll?.cancel();
        final temSave = await e.entrarNaConta(u);
        e.verificando.value = null;
        e.entrada.value = temSave ? EntradaModo.nenhuma : EntradaModo.completa;
      }
    } on ErroConta {
      // rede falhou nesta rodada: tenta de novo no próximo tick
    } finally {
      _ocupado = false;
    }
  }

  void _aviso(String texto, bool ok) {
    _msgTimer?.cancel();
    setState(() {
      _msg = texto;
      _msgOk = ok;
    });
    _msgTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _msg = null);
    });
  }

  Future<void> _reenviar() async {
    try {
      e.conta.definirIdioma(e.idioma);
      await e.conta.reenviarVerificacao();
      if (mounted) _aviso(en ? 'Email resent' : 'Email reenviado', true);
    } on ErroConta {
      if (mounted) _aviso(en ? "Couldn't resend -- wait a bit and try again" : 'Não deu pra reenviar -- espera um pouco e tenta de novo', false);
    }
  }

  Future<void> _corrigir() async {
    _terminou = true;
    _poll?.cancel();
    await e.conta.corrigirEmailErrado();
    e.verificando.value = null;
    e.entrada.value = EntradaModo.soLogin;
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.usuario.email ?? '';
    final base = const TextStyle(fontSize: 14, height: 1.55, color: Color(0xFF909090), shadows: sombraTextoConta);
    return Material(
      color: onbFundoLogin,
      child: Stack(children: [
        const Positioned.fill(child: CenarioLogin()),
        SafeArea(
          minimum: const EdgeInsets.all(32),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const LogoDungeonlog(),
                  const SizedBox(height: 22),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: corAccent.withValues(alpha: .14), border: Border.all(color: corAccent.withValues(alpha: .35), width: 1)),
                    child: Icon(Icons.mail_outline_rounded, size: 30, color: corAccent),
                  ),
                  const SizedBox(height: 14),
                  Text(tr(e, 'login.confirmeTitulo'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, shadows: [Shadow(color: Color(0xD9000000), blurRadius: 10, offset: Offset(0, 2))])),
                  const SizedBox(height: 10),
                  Text.rich(
                    key: const ValueKey('verificar-texto'),
                    TextSpan(style: base, children: [
                      TextSpan(text: en ? 'We sent a link to ' : 'Enviamos um link para '),
                      TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      TextSpan(text: en ? '.\nOpen it and come back — confirmation is automatic.' : '.\nAbra o link e volte aqui — a confirmação é automática.'),
                    ]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(width: double.infinity, child: KeyedSubtree(key: const ValueKey('verificar-reenviar'), child: BotaoPilulaLogin(tr(e, 'login.reenviarEmail'), aoTocar: _reenviar))),
                  if (_msg != null) ...[
                    const SizedBox(height: 8),
                    Text(_msg!, key: const ValueKey('verificar-msg'), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: _msgOk ? const Color(0xFF4CAF7A) : corVida)),
                  ],
                  const SizedBox(height: 22),
                  _linkLogin(const ValueKey('verificar-corrigir'), tr(e, 'login.emailErrado'), _corrigir),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- excluir conta
/// "Excluir conta?" (`#excluirContaOverlay`): pede a identidade de novo (senha na conta e-mail/senha; na conta Google o
/// Google abre de novo ao confirmar) e exclui o login. Depois limpa os dados da conta no aparelho e abre o login.
Future<void> abrirExcluirConta(BuildContext context, EstadoJogo e) {
  final u = e.usuario;
  if (u == null) return Future.value();
  final nav = Navigator.of(context);
  return abrirFolha<void>(context, (ctx) => _FolhaExcluirConta(estado: e, usuario: u, navegador: nav));
}

class _FolhaExcluirConta extends StatefulWidget {
  const _FolhaExcluirConta({required this.estado, required this.usuario, required this.navegador});
  final EstadoJogo estado;
  final UsuarioConta usuario;
  final NavigatorState navegador;
  @override
  State<_FolhaExcluirConta> createState() => _FolhaExcluirContaState();
}

class _FolhaExcluirContaState extends State<_FolhaExcluirConta> {
  final _senha = TextEditingController();
  bool _emProgresso = false;
  String? _erro;

  EstadoJogo get e => widget.estado;
  bool get _google => widget.usuario.usaGoogle;

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  Future<void> _excluir() async {
    if (_emProgresso) return;
    if (!_google && _senha.text.isEmpty) {
      setState(() => _erro = tr(e, 'cfg.excluirContaSenhaErrada'));
      return;
    }
    setState(() {
      _emProgresso = true;
      _erro = null;
    });
    try {
      await e.excluirConta(senha: _google ? null : _senha.text);
    } on ErroConta catch (err) {
      if (!mounted) return;
      final chave = chaveErroExcluir(err, google: _google);
      setState(() {
        _emProgresso = false;
        _erro = chave == null ? null : tr(e, chave);
      });
      return;
    }
    // login excluído: fecha a folha e as Configurações, limpa o que era da conta e abre o login
    widget.navegador.popUntil((r) => r.isFirst);
    await e.aposExcluirConta(widget.usuario.uid);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_emProgresso, // não fecha no meio de uma exclusão em andamento
      child: Folha(titulo: tr(e, 'cfg.excluirContaTitulo'), filhos: [
        Text(tr(e, 'cfg.excluirContaDesc'), style: TextStyle(fontSize: 13, color: corApagado, height: 1.5)),
        const SizedBox(height: 16),
        if (_google) ...[
          Text(tr(e, 'cfg.excluirContaGoogleAviso'), key: const ValueKey('excluir-google-aviso'), style: TextStyle(fontSize: 12.5, color: corApagado, height: 1.5)),
          const SizedBox(height: 14),
        ] else ...[
          Text(tr(e, 'cfg.excluirContaSenhaLabel'), style: TextStyle(fontSize: 12, color: corApagado)),
          const SizedBox(height: 6),
          TextField(
            key: const ValueKey('excluir-senha'),
            controller: _senha,
            obscureText: true,
            autofocus: true,
            enabled: !_emProgresso,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _excluir(),
            style: TextStyle(fontSize: 15, color: corTexto),
            decoration: InputDecoration(
              hintText: tr(e, 'cfg.excluirContaSenhaPlaceholder'),
              hintStyle: TextStyle(color: corApagado),
              filled: true,
              fillColor: corPainel,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: corLinha, width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: corAccent, width: 1)),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (_erro != null) ...[
          Text(_erro!, key: const ValueKey('excluir-erro'), style: const TextStyle(fontSize: 12.5, color: Color(0xFFFF6B6B), height: 1.4)),
          const SizedBox(height: 10),
        ],
        Row(children: [
          Expanded(child: BotaoFolha((e.idioma == 'en' ? 'Cancel' : 'Cancelar'), fundo: corPainel2, cor: corTexto, aoTocar: _emProgresso ? null : () => Navigator.pop(context))),
          const SizedBox(width: 9),
          Expanded(
            child: KeyedSubtree(
              key: const ValueKey('excluir-confirmar'),
              child: BotaoFolha(_emProgresso ? tr(e, 'cfg.excluirContaExcluindo') : tr(e, 'cfg.excluirContaBotao'), fundo: corVida, cor: const Color(0xFF2A0E16), aoTocar: _emProgresso ? null : _excluir),
            ),
          ),
        ]),
      ]),
    );
  }
}

/// Toca o som de erro do login (o `tocarSom('erro')` do original).
void somErroLogin() => Som.atual.tocar('erro');

