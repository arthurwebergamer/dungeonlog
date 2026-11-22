// Serviço de conta de verdade: Firebase Auth + Google. Só o `main.dart` importa este arquivo (os testes não).
// O projeto é o mesmo do app HTML (`questlog-d4c11`); o Android lê a configuração do `google-services.json`
// (copiado para `android/app/` pelo CI, ver `android_config/preparar_android.sh`).
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'conta.dart';

/// Web client ID do projeto (público, o mesmo `GOOGLE_WEB_CLIENT_ID` do app HTML): é ele que faz o Google devolver o
/// `idToken` que o Firebase aceita.
const googleWebClientId = '991047001122-mq3ofpduhb4ssbvk6ctiuiptfb45aggb.apps.googleusercontent.com';

class ServicoContaFirebase implements ServicoConta {
  ServicoContaFirebase._(this._auth, this.apagarNuvem);

  /// Inicia o Firebase (lê o `google-services.json`) e devolve o serviço. Lança se o Firebase não puder iniciar.
  ///
  /// [apagarNuvem]: gancho da parte B (sincronização): é chamado com o uid ANTES de excluir o login, para apagar o
  /// save na nuvem (no HTML, `deleteDoc(saves/{uid})`). Falha nele não impede a exclusão (como no original).
  static Future<ServicoContaFirebase> iniciar({Future<void> Function(String uid)? apagarNuvem}) async {
    await Firebase.initializeApp();
    return ServicoContaFirebase._(fb.FirebaseAuth.instance, apagarNuvem);
  }

  final fb.FirebaseAuth _auth;
  final Future<void> Function(String uid)? apagarNuvem;
  bool _googleIniciado = false;

  static UsuarioConta? _de(fb.User? u) {
    if (u == null) return null;
    final criado = u.metadata.creationTime;
    final ultimo = u.metadata.lastSignInTime;
    return UsuarioConta(
      uid: u.uid,
      email: u.email,
      nomeExibicao: u.displayName,
      usaGoogle: u.providerData.any((p) => p.providerId == 'google.com'),
      contaNova: criado != null && ultimo != null && criado.millisecondsSinceEpoch ~/ 1000 == ultimo.millisecondsSinceEpoch ~/ 1000,
      emailVerificado: u.emailVerified,
      criadoEm: criado,
    );
  }

  Future<T> _traduz<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on fb.FirebaseAuthException catch (e) {
      throw ErroConta(codigoSemPrefixo(e.code));
    } on GoogleSignInException catch (e) {
      throw ErroConta(e.code == GoogleSignInExceptionCode.canceled ? 'cancelled-popup-request' : 'google-${e.code.name}');
    } on ErroConta {
      rethrow;
    } catch (_) {
      throw const ErroConta('desconhecido');
    }
  }

  @override
  UsuarioConta? get atual => _de(_auth.currentUser);

  @override
  Stream<UsuarioConta?> get mudancas => _auth.userChanges().map(_de);

  @override
  void definirIdioma(String idioma) {
    _auth.setLanguageCode(idioma == 'en' ? 'en' : 'pt').catchError((_) {});
  }

  @override
  Future<UsuarioConta> cadastrar(String email, String senha) => _traduz(() async {
        final c = await _auth.createUserWithEmailAndPassword(email: email, password: senha);
        // não bloqueia o cadastro se o envio falhar (igual ao original)
        try {
          await c.user?.sendEmailVerification();
        } catch (_) {}
        return _de(c.user ?? _auth.currentUser)!;
      });

  @override
  Future<UsuarioConta> entrar(String email, String senha) => _traduz(() async {
        final c = await _auth.signInWithEmailAndPassword(email: email, password: senha);
        return _de(c.user ?? _auth.currentUser)!;
      });

  Future<fb.AuthCredential> _credencialGoogle() async {
    if (!_googleIniciado) {
      await GoogleSignIn.instance.initialize(serverClientId: googleWebClientId);
      _googleIniciado = true;
    }
    final conta = await GoogleSignIn.instance.authenticate();
    final idToken = conta.authentication.idToken;
    if (idToken == null) throw const ErroConta('google-sem-token');
    return fb.GoogleAuthProvider.credential(idToken: idToken);
  }

  @override
  Future<UsuarioConta> entrarComGoogle() => _traduz(() async {
        final cred = await _credencialGoogle();
        final c = await _auth.signInWithCredential(cred);
        return _de(c.user ?? _auth.currentUser)!;
      });

  @override
  Future<void> enviarRedefinicaoDeSenha(String email) => _traduz(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> sair() async {
    await _traduz(() => _auth.signOut());
    try {
      if (_googleIniciado) await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  @override
  Future<void> excluir({String? senha}) => _traduz(() async {
        final u = _auth.currentUser;
        if (u == null) throw const ErroConta('no-current-user');
        final google = u.providerData.any((p) => p.providerId == 'google.com');
        if (google) {
          await u.reauthenticateWithCredential(await _credencialGoogle());
        } else {
          await u.reauthenticateWithCredential(fb.EmailAuthProvider.credential(email: u.email ?? '', password: senha ?? ''));
        }
        // apaga o save na nuvem antes; se falhar, segue para excluir o login (é o que importa para a Play Store)
        try {
          await apagarNuvem?.call(u.uid);
        } catch (_) {}
        await u.delete();
        try {
          if (_googleIniciado) await GoogleSignIn.instance.signOut();
        } catch (_) {}
      });

  @override
  Future<void> reenviarVerificacao() => _traduz(() async {
        final u = _auth.currentUser;
        if (u == null) throw const ErroConta('no-current-user');
        await u.sendEmailVerification();
      });

  @override
  Future<UsuarioConta?> recarregar() => _traduz(() async {
        final u = _auth.currentUser;
        if (u == null) return null;
        await u.reload();
        return _de(_auth.currentUser);
      });

  @override
  Future<void> corrigirEmailErrado() async {
    final u = _auth.currentUser;
    try {
      await u?.delete();
    } catch (_) {
      // sessão velha demais para apagar: só sai (a conta sem e-mail confirmado fica órfã e inofensiva)
      try {
        await _auth.signOut();
      } catch (_) {}
    }
  }
}
