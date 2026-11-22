// Serviço de conta falso, só em memória: usado pelos testes (que NÃO podem inicializar o Firebase) e como padrão do
// `EstadoJogo` quando ninguém passa um serviço.
import 'dart:async';

import 'conta.dart';

class ServicoContaFalso implements ServicoConta {
  ServicoContaFalso({UsuarioConta? usuario}) : _atual = usuario;

  UsuarioConta? _atual;
  final _ctl = StreamController<UsuarioConta?>.broadcast();
  final Map<String, ({String senha, UsuarioConta usuario})> _contas = {};
  int _seq = 0;

  /// Registro do que foi chamado (nome do método, em ordem), para os testes conferirem.
  final List<String> chamadas = [];

  /// Se não for null, TODA chamada espera por ele (testa o estado "carregando").
  Completer<void>? segurar;

  /// O próximo método que mexe na conta falha com esse código (e volta ao normal).
  String? proximoErro;

  /// Usuário devolvido pelo Google (null = o jogador fechou o seletor).
  UsuarioConta? usuarioGoogle = const UsuarioConta(uid: 'google-1', email: 'ana@gmail.com', nomeExibicao: 'Ana Souza', usaGoogle: true, emailVerificado: true);

  /// Se true, as contas criadas por [cadastrar] já saem com e-mail confirmado (senão precisam confirmar).
  bool cadastroJaVerificado = false;

  /// Simula o jogador clicando no link do e-mail: o próximo [recarregar] devolve o e-mail como confirmado.
  bool confirmarNoProximoRecarregar = false;

  /// O gancho `apagarNuvem` do serviço de verdade (chamado em [excluir], depois de conferir a senha).
  Future<void> Function(String uid)? apagarNuvem;

  String? idiomaEmails;
  String? ultimoEmailRedefinicao;
  String? ultimaSenhaExcluir;

  /// Cria uma conta já existente (para testar o login e o "já tem conta").
  UsuarioConta criarContaExistente(String email, String senha, {String? uid, bool verificado = true, String? nome}) {
    final u = UsuarioConta(uid: uid ?? 'uid-${++_seq}', email: email, nomeExibicao: nome, emailVerificado: verificado, criadoEm: DateTime.utc(2026, 1, 1));
    _contas[email.toLowerCase()] = (senha: senha, usuario: u);
    return u;
  }

  void _definir(UsuarioConta? u) {
    _atual = u;
    _ctl.add(u);
  }

  Future<void> _passo(String nome) async {
    chamadas.add(nome);
    if (segurar != null) await segurar!.future;
    final e = proximoErro;
    if (e != null) {
      proximoErro = null;
      throw ErroConta(e);
    }
  }

  @override
  UsuarioConta? get atual => _atual;

  @override
  Stream<UsuarioConta?> get mudancas async* {
    yield _atual;
    yield* _ctl.stream;
  }

  @override
  void definirIdioma(String idioma) => idiomaEmails = idioma;

  @override
  Future<UsuarioConta> cadastrar(String email, String senha) async {
    await _passo('cadastrar');
    final chave = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(chave)) throw const ErroConta('invalid-email');
    if (_contas.containsKey(chave)) throw const ErroConta('email-already-in-use');
    if (senha.length < 6) throw const ErroConta('weak-password');
    final u = UsuarioConta(
      uid: 'uid-${++_seq}',
      email: chave,
      contaNova: true,
      emailVerificado: cadastroJaVerificado,
      criadoEm: DateTime.utc(2026, 11, 11),
    );
    _contas[chave] = (senha: senha, usuario: u);
    _definir(u);
    chamadas.add('emailVerificacaoEnviado');
    return u;
  }

  @override
  Future<UsuarioConta> entrar(String email, String senha) async {
    await _passo('entrar');
    final chave = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(chave)) throw const ErroConta('invalid-email');
    final c = _contas[chave];
    if (c == null || c.senha != senha) throw const ErroConta('invalid-credential');
    final u = c.usuario.copiar(contaNova: false);
    _definir(u);
    return u;
  }

  @override
  Future<UsuarioConta> entrarComGoogle() async {
    await _passo('google');
    final u = usuarioGoogle;
    if (u == null) throw const ErroConta('popup-closed-by-user');
    _definir(u);
    return u;
  }

  @override
  Future<void> enviarRedefinicaoDeSenha(String email) async {
    await _passo('redefinir');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) throw const ErroConta('invalid-email');
    ultimoEmailRedefinicao = email.trim();
  }

  @override
  Future<void> sair() async {
    await _passo('sair');
    _definir(null);
  }

  @override
  Future<void> excluir({String? senha}) async {
    await _passo('excluir');
    final u = _atual;
    if (u == null) throw const ErroConta('no-current-user');
    if (!u.usaGoogle) {
      final c = _contas[(u.email ?? '').toLowerCase()];
      if (c == null || c.senha != senha) throw const ErroConta('wrong-password');
    }
    // como o ServicoContaFirebase: depois de reautenticar, apaga a nuvem (falha nela não impede a exclusão)
    try {
      await apagarNuvem?.call(u.uid);
    } catch (_) {}
    if (!u.usaGoogle) _contas.remove((u.email ?? '').toLowerCase());
    ultimaSenhaExcluir = senha;
    _definir(null);
  }

  @override
  Future<void> reenviarVerificacao() async {
    await _passo('reenviarVerificacao');
  }

  @override
  Future<UsuarioConta?> recarregar() async {
    await _passo('recarregar');
    final u = _atual;
    if (u == null) return null;
    if (confirmarNoProximoRecarregar && !u.emailVerificado) {
      confirmarNoProximoRecarregar = false;
      _definir(u.copiar(emailVerificado: true));
    }
    return _atual;
  }

  @override
  Future<void> corrigirEmailErrado() async {
    await _passo('corrigirEmailErrado');
    final u = _atual;
    if (u != null) _contas.remove((u.email ?? '').toLowerCase());
    _definir(null);
  }

  void fechar() => _ctl.close();
}

/// Usado quando o Firebase não pôde ser iniciado (ou em testes de tela que não querem conta): ninguém logado e toda
/// operação falha com um erro genérico (a tela mostra "Não deu pra entrar").
class ServicoContaIndisponivel implements ServicoConta {
  const ServicoContaIndisponivel();
  Never _falha() => throw const ErroConta('app-not-initialized');
  @override
  UsuarioConta? get atual => null;
  @override
  Stream<UsuarioConta?> get mudancas => Stream.value(null);
  @override
  void definirIdioma(String idioma) {}
  @override
  Future<UsuarioConta> cadastrar(String email, String senha) async => _falha();
  @override
  Future<UsuarioConta> entrar(String email, String senha) async => _falha();
  @override
  Future<UsuarioConta> entrarComGoogle() async => _falha();
  @override
  Future<void> enviarRedefinicaoDeSenha(String email) async => _falha();
  @override
  Future<void> sair() async {}
  @override
  Future<void> excluir({String? senha}) async => _falha();
  @override
  Future<void> reenviarVerificacao() async => _falha();
  @override
  Future<UsuarioConta?> recarregar() async => null;
  @override
  Future<void> corrigirEmailErrado() async {}
}
