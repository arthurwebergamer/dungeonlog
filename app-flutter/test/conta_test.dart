// Fase 6 (parte A): a camada de conta (mensagens, serviço falso) e a troca de dono dos dados no EstadoJogo.
// Nenhum teste aqui inicializa o Firebase: só o serviço falso.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dados/conta.dart';
import 'package:dungeonlog_flutter/dados/conta_falsa.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:flutter_test/flutter_test.dart';

DadosJogo _dados() {
  String l(String n) => File('assets/dados/$n.json').readAsStringSync();
  return DadosJogo.deTextos(monstros: l('monstros'), herois: l('herois'), temas: l('temas_arena'), itens: l('itens'), traducoes: l('traducoes'));
}

Future<EstadoJogo> _estado(ArmazenamentoMemoria arm, ServicoContaFalso conta, {String? uid}) async {
  final e = EstadoJogo(dados: _dados(), armazenamento: arm, agora: () => DateTime(2026, 11, 11, 10), aleatorio: Random(1), conta: conta, uid: uid);
  await e.abrirDonoAtual();
  return e;
}

/// Convidado com save começado (nome e herói escolhidos) e a marca de convidado.
Future<EstadoJogo> _convidadoComSave(ArmazenamentoMemoria arm, ServicoContaFalso conta, {String nome = 'Gui', int heroi = 2}) async {
  final e = await _estado(arm, conta);
  expect(e.onboardingPendente, isTrue);
  e.marcarConvidado();
  await e.concluirOnboarding(nome: nome, heroi: heroi);
  return e;
}

UsuarioConta _nova(String uid) => UsuarioConta(uid: uid, email: '$uid@x.com', contaNova: true, emailVerificado: true, criadoEm: DateTime.utc(2026, 11, 11));
UsuarioConta _existente(String uid) => UsuarioConta(uid: uid, email: '$uid@x.com', emailVerificado: true, criadoEm: DateTime.utc(2026, 1, 1));

void main() {
  group('usuário', () {
    test('nome mostrado: primeiro nome do Google, começo do e-mail ou "aventureiro"', () {
      expect(const UsuarioConta(uid: 'a', nomeExibicao: 'Ana Souza', email: 'ana@x.com').nome, 'Ana');
      expect(const UsuarioConta(uid: 'a', nomeExibicao: '  Maria   da Silva ').nome, 'Maria');
      expect(const UsuarioConta(uid: 'a', email: 'joao.p@x.com').nome, 'joao.p');
      expect(const UsuarioConta(uid: 'a', nomeExibicao: '', email: 'bia@x.com').nome, 'bia');
      expect(const UsuarioConta(uid: 'a').nome, 'aventureiro');
    });
    test('trava de e-mail: só conta nova (depois de 24/08/2026) e não verificada', () {
      expect(UsuarioConta(uid: 'a', criadoEm: DateTime.utc(2026, 11, 1)).precisaVerificarEmail, isTrue);
      expect(UsuarioConta(uid: 'a', criadoEm: DateTime.utc(2026, 11, 1), emailVerificado: true).precisaVerificarEmail, isFalse);
      expect(UsuarioConta(uid: 'a', criadoEm: DateTime.utc(2026, 8, 23)).precisaVerificarEmail, isFalse);
      expect(UsuarioConta(uid: 'a', criadoEm: DateTime.utc(2026, 8, 25)).precisaVerificarEmail, isTrue);
      expect(const UsuarioConta(uid: 'a').precisaVerificarEmail, isFalse, reason: 'sem data de criação não trava');
    });
  });

  group('mensagens de erro (as do app HTML)', () {
    test('prefixo auth/ é tirado', () {
      expect(codigoSemPrefixo('auth/wrong-password'), 'wrong-password');
      expect(codigoSemPrefixo('wrong-password'), 'wrong-password');
      expect(codigoSemPrefixo(null), '');
    });
    test('e-mail e senha em português', () {
      String m(String c) => mensagemErroLogin(ErroConta(c), en: false);
      expect(m('email-already-in-use'), 'Esse email já tem conta -- troca pra "Entrar"');
      expect(m('invalid-email'), 'Email inválido');
      expect(m('weak-password'), 'Senha fraca demais (mínimo 6 caracteres)');
      expect(m('user-not-found'), 'Não existe conta com esse email -- troca pra "Cadastre-se"');
      expect(m('wrong-password'), 'Senha incorreta');
      expect(m('invalid-credential'), 'Email ou senha incorretos');
      expect(m('too-many-requests'), 'Muitas tentativas -- espera um pouco e tenta de novo');
      expect(m('network-request-failed'), 'Sem conexão. Verifique a internet e tente de novo.');
      expect(m('qualquer-outro'), 'Não deu pra entrar');
    });
    test('e-mail e senha em inglês', () {
      String m(String c) => mensagemErroLogin(ErroConta(c), en: true);
      expect(m('email-already-in-use'), 'This email already has an account -- switch to "Log in"');
      expect(m('invalid-email'), 'Invalid email');
      expect(m('weak-password'), 'Password too weak (minimum 6 characters)');
      expect(m('user-not-found'), 'No account with this email -- switch to "Sign up"');
      expect(m('wrong-password'), 'Wrong password');
      expect(m('invalid-credential'), 'Wrong email or password');
      expect(m('too-many-requests'), 'Too many attempts -- wait a bit and try again');
      expect(m('network-request-failed'), 'No connection. Check your internet and try again.');
      expect(m('x'), "Couldn't sign in");
    });
    test('só e-mail repetido e e-mail inválido vão para baixo do campo', () {
      expect(erroDoCampoEmail(const ErroConta('email-already-in-use')), isTrue);
      expect(erroDoCampoEmail(const ErroConta('invalid-email')), isTrue);
      expect(erroDoCampoEmail(const ErroConta('wrong-password')), isFalse);
    });
    test('Google, redefinição de senha e exclusão', () {
      expect(mensagemErroGoogle(const ErroConta('network-request-failed'), en: false), 'Sem conexão. Verifique a internet e tente de novo.');
      expect(mensagemErroGoogle(const ErroConta('x'), en: false), 'Não deu pra entrar com Google');
      expect(mensagemErroGoogle(const ErroConta('x'), en: true), "Couldn't sign in with Google");
      expect(mensagemErroRedefinir(const ErroConta('invalid-email'), en: false), 'Email inválido');
      expect(mensagemErroRedefinir(const ErroConta('too-many-requests'), en: true), 'Too many attempts -- wait a bit and try again');
      expect(mensagemErroRedefinir(const ErroConta('network-request-failed'), en: false), 'Sem conexão. Verifique a internet e tente de novo.');
      expect(mensagemErroRedefinir(const ErroConta('x'), en: false), 'Não deu pra enviar o email -- tenta de novo');
      expect(mensagemErroRedefinir(const ErroConta('x'), en: true), "Couldn't send the email -- try again");
      expect(chaveErroExcluir(const ErroConta('wrong-password'), google: false), 'cfg.excluirContaSenhaErrada');
      expect(chaveErroExcluir(const ErroConta('invalid-credential'), google: false), 'cfg.excluirContaSenhaErrada');
      expect(chaveErroExcluir(const ErroConta('popup-closed-by-user'), google: true), isNull);
      expect(chaveErroExcluir(const ErroConta('cancelled-popup-request'), google: true), isNull);
      expect(chaveErroExcluir(const ErroConta('requires-recent-login'), google: false), 'cfg.excluirContaPrecisaRelogar');
      expect(chaveErroExcluir(const ErroConta('x'), google: true), 'cfg.excluirContaGoogleFalhou');
      expect(chaveErroExcluir(const ErroConta('x'), google: false), 'cfg.excluirContaFalhouGenerico');
    });
    test('cancelar o Google não é erro', () {
      expect(const ErroConta('popup-closed-by-user').cancelou, isTrue);
      expect(const ErroConta('cancelled-popup-request').cancelou, isTrue);
      expect(const ErroConta('network-request-failed').cancelou, isFalse);
      expect(const ErroConta('network-request-failed').semConexao, isTrue);
    });
    test('regra da senha ao criar: 6+ caracteres e 1 número', () {
      expect(senhaForteOk('abc123'), isTrue);
      expect(senhaForteOk('abcde1'), isTrue);
      expect(senhaForteOk('abcdef'), isFalse, reason: 'sem número');
      expect(senhaForteOk('a1b2c'), isFalse, reason: 'só 5');
      expect(senhaForteOk('123456'), isTrue);
      expect(senhaForteOk(''), isFalse);
    });
  });

  group('serviço falso', () {
    test('cadastrar, entrar e as recusas do Firebase', () async {
      final c = ServicoContaFalso();
      expect(c.atual, isNull);
      await expectLater(c.cadastrar('ruim', 'abc123'), throwsA(isA<ErroConta>().having((e) => e.codigo, 'codigo', 'invalid-email')));
      await expectLater(c.cadastrar('a@b.com', '123'), throwsA(isA<ErroConta>().having((e) => e.codigo, 'codigo', 'weak-password')));
      final u = await c.cadastrar('A@B.com', 'abc123');
      expect(u.contaNova, isTrue);
      expect(u.precisaVerificarEmail, isTrue);
      expect(c.atual, u);
      await expectLater(c.cadastrar('a@b.com', 'abc123'), throwsA(isA<ErroConta>().having((e) => e.codigo, 'codigo', 'email-already-in-use')));
      await c.sair();
      expect(c.atual, isNull);
      await expectLater(c.entrar('a@b.com', 'errada1'), throwsA(isA<ErroConta>().having((e) => e.codigo, 'codigo', 'invalid-credential')));
      final de = await c.entrar('a@b.com', 'abc123');
      expect(de.uid, u.uid);
      expect(de.contaNova, isFalse, reason: 'entrar de novo não é conta nova');
    });
    test('proximoErro falha só uma vez; Google cancelado; excluir pede a senha', () async {
      final c = ServicoContaFalso();
      c.criarContaExistente('x@y.com', 'senha1');
      c.proximoErro = 'network-request-failed';
      await expectLater(c.entrar('x@y.com', 'senha1'), throwsA(isA<ErroConta>().having((e) => e.semConexao, 'semConexao', isTrue)));
      await c.entrar('x@y.com', 'senha1');
      c.usuarioGoogle = null;
      await expectLater(c.entrarComGoogle(), throwsA(isA<ErroConta>().having((e) => e.cancelou, 'cancelou', isTrue)));
      await expectLater(c.excluir(senha: 'errada'), throwsA(isA<ErroConta>().having((e) => e.codigo, 'codigo', 'wrong-password')));
      expect(c.atual, isNotNull);
      await c.excluir(senha: 'senha1');
      expect(c.atual, isNull);
      await expectLater(c.entrar('x@y.com', 'senha1'), throwsA(isA<ErroConta>()), reason: 'a conta foi excluída');
    });
    test('mudancas emite o usuário atual e cada troca', () async {
      final c = ServicoContaFalso();
      final vistos = <String?>[];
      final sub = c.mudancas.listen((u) => vistos.add(u?.uid));
      await Future<void>.delayed(Duration.zero);
      c.criarContaExistente('a@b.com', 'abc123', uid: 'U1');
      await c.entrar('a@b.com', 'abc123');
      await c.sair();
      await Future<void>.delayed(Duration.zero);
      expect(vistos, [null, 'U1', null]);
      await sub.cancel();
      c.fechar();
    });
    test('o serviço indisponível não deixa ninguém entrar, mas deixa sair', () async {
      const c = ServicoContaIndisponivel();
      expect(c.atual, isNull);
      await expectLater(c.entrar('a@b.com', 'x'), throwsA(isA<ErroConta>()));
      await expectLater(c.entrarComGoogle(), throwsA(isA<ErroConta>()));
      await c.sair();
    });
  });

  group('troca de dono dos dados (o aoLogar do original, só local)', () {
    test('convidado com progresso + conta NOVA: as chaves do convidado passam para a conta e as cruas somem', () async {
      final arm = ArmazenamentoMemoria();
      final conta = ServicoContaFalso();
      final e = await _convidadoComSave(arm, conta);
      expect(arm.ler(chaveSave()), isNotNull);
      final cruas = arm.chaves().where((k) => k.contains('.pj.') || k == 'questlog.personagens.v1').toList();
      expect(cruas, isNotEmpty);
      final valoresAntes = {for (final k in cruas) k: arm.ler(k)};

      final temSave = await e.entrarNaConta(_nova('U1'));

      expect(temSave, isTrue, reason: 'o save do convidado foi para a conta: "Bem-vindo de volta"');
      expect(e.uid, 'U1');
      expect(e.onboardingPendente, isFalse);
      expect(e.save.nomeHeroi, 'Gui');
      expect(arm.ler('questlog.convidado.v1'), isNull);
      for (final k in cruas) {
        expect(arm.ler(k), isNull, reason: 'cru $k apagado');
      }
      expect(arm.ler('questlog.v1.uid.U1.pj.pj1'), isNotNull);
      expect(jsonDecode(arm.ler('questlog.v1.uid.U1.pj.pj1')!)['nomeHeroi'], 'Gui');
      expect(arm.ler('questlog.vida.v1.uid.U1.pj.pj1'), valoresAntes['questlog.vida.v1.pj.pj1']);
      expect(arm.ler('questlog.personagens.v1.uid.U1'), valoresAntes['questlog.personagens.v1']);
      // chaves do APARELHO não são mexidas
      expect(arm.chaves().where((k) => !k.contains('.uid.') && k.contains('.pj.')), isEmpty);
    });

    test('convidado com progresso + conta que JÁ EXISTE: nada do convidado é copiado (a nuvem venceria; ver FASE6.md)', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _convidadoComSave(arm, ServicoContaFalso());
      final crua = arm.ler('questlog.v1.pj.pj1');
      final temSave = await e.entrarNaConta(_existente('U2'));
      expect(temSave, isFalse, reason: 'a conta ainda não tem save neste aparelho: escolher o herói');
      expect(e.onboardingPendente, isTrue);
      expect(e.uid, 'U2');
      expect(arm.ler('questlog.convidado.v1'), isNull, reason: 'a marca de convidado sai nos dois casos');
      expect(arm.ler('questlog.v1.pj.pj1'), crua, reason: 'o jogo do convidado continua guardado, intacto');
      expect(arm.ler('questlog.v1.uid.U2.pj.pj1'), isNull);
    });

    test('sem a marca de convidado, conta nova NÃO leva as chaves cruas (só migra quem veio do convidado)', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm, ServicoContaFalso());
      await e.concluirOnboarding(nome: 'Gui', heroi: 1); // save cru, mas SEM marcarConvidado()
      final temSave = await e.entrarNaConta(_nova('U3'));
      expect(temSave, isFalse);
      expect(arm.ler('questlog.v1.pj.pj1'), isNotNull);
      expect(arm.ler('questlog.v1.uid.U3.pj.pj1'), isNull);
    });

    test('entrar de novo na mesma conta não troca nada; chaves do aparelho não migram', () async {
      final arm = ArmazenamentoMemoria();
      await arm.gravar('questlog.idioma.v1', 'pt');
      await arm.gravar('questlog.tutorialTelas.v2', '{"tarefas":true}');
      final e = await _convidadoComSave(arm, ServicoContaFalso());
      await e.entrarNaConta(_nova('U4'));
      final antes = Map.fromEntries(arm.dados.entries);
      final ok = await e.entrarNaConta(_nova('U4'));
      expect(ok, isTrue);
      expect(Map.fromEntries(arm.dados.entries).keys.toSet(), antes.keys.toSet());
      expect(arm.ler('questlog.idioma.v1'), 'pt');
      expect(arm.ler('questlog.tutorialTelas.v2'), '{"tarefas":true}');
    });

    test('duas contas e o convidado não se misturam: cada uma abre o próprio save', () async {
      final arm = ArmazenamentoMemoria();
      final conta = ServicoContaFalso();
      final e = await _convidadoComSave(arm, conta, nome: 'Gui');
      await e.entrarNaConta(_nova('A')); // leva o do convidado
      await e.sairDaConta();
      expect(e.uid, isNull);
      expect(e.onboardingPendente, isTrue, reason: 'o convidado levou tudo para A: sem jogo cru');
      // B entra (nova, sem convidado): configura o herói dela
      expect(await e.entrarNaConta(_nova('B')), isFalse);
      await e.concluirOnboarding(nome: 'Bia', heroi: 4);
      expect(e.save.nomeHeroi, 'Bia');
      await e.sairDaConta();
      // A volta: o save dela
      expect(await e.entrarNaConta(_existente('A')), isTrue);
      expect(e.save.nomeHeroi, 'Gui');
      expect(e.uid, 'A');
      // e B de novo
      await e.sairDaConta();
      expect(await e.entrarNaConta(_existente('B')), isTrue);
      expect(e.save.nomeHeroi, 'Bia');
    });

    test('o herói ativo é o da conta (questlog.personagemAtivo.v1.uid.<uid>)', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm, ServicoContaFalso());
      await e.entrarNaConta(_nova('C'));
      await e.concluirOnboarding(nome: 'Um', heroi: 0);
      e.ehPro = true;
      await e.criarPersonagem('Dois', 3);
      final segundo = e.personagem;
      expect(segundo, isNot('pj1'));
      expect(arm.ler('questlog.personagemAtivo.v1.uid.C'), segundo);
      await e.sairDaConta();
      expect(e.personagem, 'pj1');
      await e.entrarNaConta(_existente('C'));
      expect(e.personagem, segundo, reason: 'volta ao herói que estava ativo na conta');
      expect(e.save.nomeHeroi, 'Dois');
    });

    test('herói ativo que não existe mais na lista volta ao primeiro', () async {
      final arm = ArmazenamentoMemoria();
      await arm.gravar('questlog.personagemAtivo.v1.uid.D', 'pjfantasma');
      final e = await _estado(arm, ServicoContaFalso());
      await e.entrarNaConta(_existente('D'));
      expect(e.personagem, 'pj1');
    });

    test('sair: volta a jogar sem conta com o jogo local e abre o login; as chaves da conta ficam no aparelho', () async {
      final arm = ArmazenamentoMemoria();
      final conta = ServicoContaFalso();
      final e = await _estado(arm, conta);
      // convidado SEM marca: nada migra, o jogo cru fica
      await e.concluirOnboarding(nome: 'Cru', heroi: 1);
      await e.entrarNaConta(_existente('E'));
      expect(e.onboardingPendente, isTrue);
      await e.concluirOnboarding(nome: 'Da conta', heroi: 2);
      conta.criarContaExistente('e@x.com', 'abc123', uid: 'E');
      await conta.entrar('e@x.com', 'abc123');
      var avisos = 0;
      e.addListener(() => avisos++);
      await e.sairDaConta();
      expect(conta.atual, isNull);
      expect(e.uid, isNull);
      expect(e.entrada.value, EntradaModo.soLogin);
      expect(e.save.nomeHeroi, 'Cru');
      expect(e.onboardingPendente, isFalse);
      expect(arm.ler('questlog.v1.uid.E.pj.pj1'), isNotNull, reason: 'o save da conta continua no aparelho');
      expect(avisos, greaterThan(0));
    });

    test('sair sem rede ainda desconecta aqui', () async {
      final conta = ServicoContaFalso();
      final e = await _estado(ArmazenamentoMemoria(), conta);
      await e.entrarNaConta(_existente('F'));
      conta.proximoErro = 'network-request-failed';
      await e.sairDaConta();
      expect(e.uid, isNull);
      expect(e.entrada.value, EntradaModo.soLogin);
    });

    test('depois de excluir a conta: some tudo dela do aparelho, mas não o resto', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _convidadoComSave(arm, ServicoContaFalso(), nome: 'Gui');
      await e.entrarNaConta(_nova('X1'));
      await e.sairDaConta();
      await e.entrarNaConta(_nova('X2'));
      await e.concluirOnboarding(nome: 'Outra', heroi: 1);
      await arm.gravar('questlog.idioma.v1', 'en');
      await arm.gravar('questlog.v1.uid.X10.pj.pj1', '{}'); // outra conta cujo uid COMEÇA igual: não pode ser apagada
      await e.aposExcluirConta('X1');
      expect(arm.chaves().where((k) => k.contains('.uid.X1.') || k.endsWith('.uid.X1')), isEmpty);
      expect(arm.ler('questlog.v1.uid.X2.pj.pj1'), isNotNull);
      expect(arm.ler('questlog.v1.uid.X10.pj.pj1'), '{}');
      expect(arm.ler('questlog.idioma.v1'), 'en');
      expect(e.uid, isNull);
      expect(e.entrada.value, EntradaModo.soLogin);
    });

    test('logado: usuario e logado vêm do serviço', () async {
      final conta = ServicoContaFalso();
      final e = await _estado(ArmazenamentoMemoria(), conta);
      expect(e.logado, isFalse);
      conta.criarContaExistente('g@x.com', 'abc123', uid: 'G');
      await conta.entrar('g@x.com', 'abc123');
      expect(e.logado, isTrue);
      expect(e.usuario!.uid, 'G');
    });

    test('abrir já com um uid (sessão restaurada) usa o save daquela conta', () async {
      final arm = ArmazenamentoMemoria();
      final conta = ServicoContaFalso();
      final e = await _estado(arm, conta);
      await e.entrarNaConta(_nova('H'));
      await e.concluirOnboarding(nome: 'Hana', heroi: 5);
      final e2 = await _estado(arm, conta, uid: 'H');
      expect(e2.onboardingPendente, isFalse);
      expect(e2.save.nomeHeroi, 'Hana');
      expect(chaveSave(uid: 'H'), 'questlog.v1.uid.H.pj.pj1');
    });
  });
}
