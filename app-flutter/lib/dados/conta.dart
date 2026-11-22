// Conta do jogador (Fase 6, parte A: só autenticação). Nada aqui importa o Firebase: o app usa [ServicoConta] e quem
// fala com o Firebase de verdade é `conta_firebase.dart`. Os testes usam `conta_falsa.dart` e nunca inicializam o Firebase.
//
// As mensagens de erro são as do app HTML (play/index.html, `MENSAGENS` do login por e-mail, "Não deu pra entrar com
// Google" e "Não deu pra enviar o email"), em português e inglês.
import 'dart:async';

/// Contas criadas depois desta data precisam confirmar o e-mail (`DATA_CORTE_VERIFICACAO_EMAIL` do original).
final DateTime corteVerificacaoEmail = DateTime.utc(2026, 8, 24);

/// Quem está logado (o que o app precisa saber; o resto fica no Firebase).
class UsuarioConta {
  const UsuarioConta({
    required this.uid,
    this.email,
    this.nomeExibicao,
    this.usaGoogle = false,
    this.contaNova = false,
    this.emailVerificado = false,
    this.criadoEm,
  });
  final String uid;
  final String? email;

  /// `displayName` do Firebase (o do Google; null no e-mail/senha).
  final String? nomeExibicao;
  final bool usaGoogle;

  /// Conta recém-criada: no Firebase é `creationTime == lastSignInTime` (o `contaNova` do `aoLogar` do original).
  final bool contaNova;
  final bool emailVerificado;
  final DateTime? criadoEm;

  /// O nome mostrado na linha "Logado como ...": primeiro nome do Google, senão o começo do e-mail, senão "aventureiro"
  /// (o `nomeConta` de `reconectarEnvio`).
  String get nome {
    final n = nomeExibicao;
    if (n != null && n.trim().isNotEmpty) return n.trim().split(RegExp(r'\s+')).first;
    final e = email;
    if (e != null && e.isNotEmpty) return e.split('@').first;
    return 'aventureiro';
  }

  /// A trava de e-mail não confirmado do original (`precisaVerificar`): só contas novas o bastante. O Google já chega
  /// com o e-mail verificado.
  bool get precisaVerificarEmail =>
      !emailVerificado && criadoEm != null && criadoEm!.toUtc().isAfter(corteVerificacaoEmail);

  UsuarioConta copiar({bool? emailVerificado, bool? contaNova}) => UsuarioConta(
        uid: uid,
        email: email,
        nomeExibicao: nomeExibicao,
        usaGoogle: usaGoogle,
        contaNova: contaNova ?? this.contaNova,
        emailVerificado: emailVerificado ?? this.emailVerificado,
        criadoEm: criadoEm,
      );

  @override
  bool operator ==(Object o) =>
      o is UsuarioConta && o.uid == uid && o.email == email && o.nomeExibicao == nomeExibicao && o.usaGoogle == usaGoogle && o.emailVerificado == emailVerificado;
  @override
  int get hashCode => Object.hash(uid, email, nomeExibicao, usaGoogle, emailVerificado);
}

/// Erro de conta com o código do Firebase Auth SEM o prefixo `auth/` (ex.: `wrong-password`).
class ErroConta implements Exception {
  const ErroConta(this.codigo);
  final String codigo;

  /// Quem fechou o seletor do Google ou o popup de propósito: não é erro, não mostra nada.
  bool get cancelou => codigo == 'popup-closed-by-user' || codigo == 'cancelled-popup-request';

  bool get semConexao => codigo == 'network-request-failed';

  @override
  String toString() => 'ErroConta($codigo)';
}

/// Tira o prefixo `auth/` (o JS do original usa `auth/wrong-password`, o plugin do Flutter usa `wrong-password`).
String codigoSemPrefixo(String? codigo) {
  final c = codigo ?? '';
  return c.startsWith('auth/') ? c.substring(5) : c;
}

const _semConexaoPt = 'Sem conexão. Verifique a internet e tente de novo.';
const _semConexaoEn = 'No connection. Check your internet and try again.';

/// Erro de e-mail/senha (cadastro ou entrada): o `MENSAGENS` do `loginEntrarBtn.onclick`.
String mensagemErroLogin(ErroConta e, {required bool en}) {
  final m = en
      ? const {
          'email-already-in-use': 'This email already has an account -- switch to "Log in"',
          'invalid-email': 'Invalid email',
          'weak-password': 'Password too weak (minimum 6 characters)',
          'user-not-found': 'No account with this email -- switch to "Sign up"',
          'wrong-password': 'Wrong password',
          'invalid-credential': 'Wrong email or password',
          'too-many-requests': 'Too many attempts -- wait a bit and try again',
          'network-request-failed': _semConexaoEn,
        }
      : const {
          'email-already-in-use': 'Esse email já tem conta -- troca pra "Entrar"',
          'invalid-email': 'Email inválido',
          'weak-password': 'Senha fraca demais (mínimo 6 caracteres)',
          'user-not-found': 'Não existe conta com esse email -- troca pra "Cadastre-se"',
          'wrong-password': 'Senha incorreta',
          'invalid-credential': 'Email ou senha incorretos',
          'too-many-requests': 'Muitas tentativas -- espera um pouco e tenta de novo',
          'network-request-failed': _semConexaoPt,
        };
  return m[e.codigo] ?? (en ? "Couldn't sign in" : 'Não deu pra entrar');
}

/// Esses dois erros aparecem embaixo do campo de e-mail (com o X vermelho); os outros vão para a tela "Algo deu errado".
bool erroDoCampoEmail(ErroConta e) => e.codigo == 'email-already-in-use' || e.codigo == 'invalid-email';

/// Erro do Google: só "sem conexão" tem texto próprio.
String mensagemErroGoogle(ErroConta e, {required bool en}) =>
    e.semConexao ? (en ? _semConexaoEn : _semConexaoPt) : (en ? "Couldn't sign in with Google" : 'Não deu pra entrar com Google');

/// Erro ao pedir a redefinição de senha (`loginEsqueci.onclick`).
String mensagemErroRedefinir(ErroConta e, {required bool en}) {
  switch (e.codigo) {
    case 'invalid-email':
      return en ? 'Invalid email' : 'Email inválido';
    case 'network-request-failed':
      return en ? _semConexaoEn : _semConexaoPt;
    case 'too-many-requests':
      return en ? 'Too many attempts -- wait a bit and try again' : 'Muitas tentativas -- espera um pouco e tenta de novo';
    default:
      return en ? "Couldn't send the email -- try again" : 'Não deu pra enviar o email -- tenta de novo';
  }
}

/// Erro ao excluir a conta: a CHAVE da tradução (`cfg.excluirConta...`), ou null quando o jogador só fechou o Google.
String? chaveErroExcluir(ErroConta e, {required bool google}) {
  switch (e.codigo) {
    case 'wrong-password':
    case 'invalid-credential':
      return 'cfg.excluirContaSenhaErrada';
    case 'popup-closed-by-user':
    case 'cancelled-popup-request':
      return null;
    case 'requires-recent-login':
      return 'cfg.excluirContaPrecisaRelogar';
    default:
      return google ? 'cfg.excluirContaGoogleFalhou' : 'cfg.excluirContaFalhouGenerico';
  }
}

/// Regra de senha do cadastro (`senhaForteOk`): 6+ caracteres e pelo menos 1 número. Só vale ao criar a senha.
bool senhaForteOk(String s) => RegExp(r'^(?=.*[0-9]).{6,}$').hasMatch(s);

/// O que o app faz com a conta. A implementação real é `ServicoContaFirebase`; os testes usam `ServicoContaFalso`.
abstract class ServicoConta {
  /// Quem está logado agora (a sessão do Firebase é restaurada sozinha ao abrir o app), ou null.
  UsuarioConta? get atual;

  /// O usuário atual a cada mudança (entrou, saiu, confirmou o e-mail). Emite o valor atual primeiro.
  Stream<UsuarioConta?> get mudancas;

  /// Idioma dos e-mails que o Firebase manda (`__ajustarIdiomaEmail`): 'pt' ou 'en'.
  void definirIdioma(String idioma);

  /// Cria a conta e manda o e-mail de confirmação (se o envio falhar, o cadastro vale mesmo assim).
  Future<UsuarioConta> cadastrar(String email, String senha);

  Future<UsuarioConta> entrar(String email, String senha);

  /// Google. Se o jogador fechar o seletor, lança [ErroConta] com `cancelou == true`.
  Future<UsuarioConta> entrarComGoogle();

  Future<void> enviarRedefinicaoDeSenha(String email);

  Future<void> sair();

  /// Excluir de verdade: pede a identidade de novo (a [senha] na conta e-mail/senha, o Google de novo na conta Google),
  /// apaga os dados na nuvem (se houver gancho, ver `ServicoContaFirebase.apagarNuvem`) e remove o login.
  Future<void> excluir({String? senha});

  Future<void> reenviarVerificacao();

  /// Relê o usuário no servidor (único jeito de saber que o e-mail foi confirmado) e devolve o estado novo.
  Future<UsuarioConta?> recarregar();

  /// "Email errado? Corrigir": apaga a conta que acabou de nascer (sem dado nenhum); se não der, só sai.
  Future<void> corrigirEmailErrado();
}
