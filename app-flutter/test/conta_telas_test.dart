// Fase 6 (parte A): as telas de conta com o serviço falso (login, cadastro, Google, esqueci a senha, carregando,
// bem-vindo de volta, confirmar e-mail, Configurações > Conta, Sair e Excluir conta). Nenhum teste inicializa o Firebase.
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dados/conta.dart';
import 'package:dungeonlog_flutter/dados/conta_falsa.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/ui/equip_arena.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:dungeonlog_flutter/ui/login_conta.dart';
import 'package:dungeonlog_flutter/ui/onboarding.dart';
import 'package:dungeonlog_flutter/ui/sheet_md.dart' show FilaPopups;
import 'package:dungeonlog_flutter/ui/tela_config.dart';
import 'package:dungeonlog_flutter/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DadosJogo _dados() {
  String l(String n) => File('assets/dados/$n.json').readAsStringSync();
  return DadosJogo.deTextos(monstros: l('monstros'), herois: l('herois'), temas: l('temas_arena'), itens: l('itens'), traducoes: l('traducoes'));
}

Future<void> _fontes() async {
  for (final (nome, arqs) in [
    ('Outfit', ['Outfit-Light.ttf', 'Outfit-Regular.ttf', 'Outfit-Medium.ttf', 'Outfit-SemiBold.ttf', 'Outfit-Bold.ttf']),
    ('Silkscreen', ['Silkscreen-Regular.ttf']),
    ('Cormorant Garamond', ['CormorantGaramond-Italic.ttf']),
  ]) {
    final l = FontLoader(nome);
    for (final a in arqs) {
      l.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$a').readAsBytesSync())));
    }
    await l.load();
  }
}

Widget _app(Widget home) => MaterialApp(theme: temaApp(), home: home);

class _Cena {
  _Cena(this.e, this.conta, this.arm);
  final EstadoJogo e;
  final ServicoContaFalso conta;
  final ArmazenamentoMemoria arm;
}

Future<_Cena> _cena(WidgetTester t, {String idioma = 'pt', ArmazenamentoMemoria? arm, ServicoContaFalso? conta}) async {
  final a = arm ?? ArmazenamentoMemoria();
  final c = conta ?? ServicoContaFalso();
  late EstadoJogo e;
  await t.runAsync(() async {
    e = EstadoJogo(dados: _dados(), armazenamento: a, agora: () => DateTime(2026, 11, 11, 10), aleatorio: Random(1), idioma: idioma, conta: c);
    await e.abrirDonoAtual();
  });
  return _Cena(e, c, a);
}

Future<void> _assenta(WidgetTester t, [int ms = 450]) async {
  await t.pump();
  await t.pump(Duration(milliseconds: ms));
  await t.pump(); // o fim do fade do carregando só desmonta no quadro seguinte
}

Future<void> _toca(WidgetTester t, Finder f) async {
  await t.tap(f);
  await _assenta(t);
}

Future<void> _digita(WidgetTester t, String chave, String texto) async {
  await t.enterText(find.byKey(ValueKey(chave)), texto);
  await t.pump();
}

/// Abre o login (modo "só login") e vai ao formulário de e-mail.
Future<void> _abrirForm(WidgetTester t, _Cena c, {VoidCallback? aoConcluir}) async {
  await t.pumpWidget(_app(Onboarding(estado: c.e, somenteLogin: true, aoConcluir: aoConcluir ?? () {})));
  await t.pump(const Duration(milliseconds: 500));
  await _toca(t, find.byKey(const ValueKey('login-email')));
}

Future<void> _preencheEEnvia(WidgetTester t, String email, String senha, {String? confirmar}) async {
  await _digita(t, 'login-email-campo', email);
  await _digita(t, 'login-senha-campo', senha);
  if (confirmar != null) await _digita(t, 'login-confirmar-campo', confirmar);
  await _toca(t, find.byKey(const ValueKey('login-enviar')));
}

void main() {
  setUp(() {
    FilaPopups.reiniciar();
    Paleta.atual = Paleta.grafite;
  });
  setUpAll(() async {
    await _fontes();
    EquipArena.atual = EquipArena.deTexto(File('assets/dados/equip_arena.json').readAsStringSync());
  });

  group('login por e-mail', () {
    testWidgets('validações antes de chamar a rede (mensagens do original) e check/X em tempo real', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      await _abrirForm(t, c);

      await _toca(t, find.byKey(const ValueKey('login-enviar')));
      expect(find.text('Preencha email e senha'), findsOneWidget);
      expect(c.conta.chamadas, isEmpty, reason: 'nada vai à rede com campo vazio');

      await _toca(t, find.byKey(const ValueKey('login-alternar')));
      expect(find.text('Crie sua conta'), findsOneWidget);
      expect(find.text('Preencha email e senha'), findsNothing, reason: 'trocar de modo limpa o aviso');

      await _digita(t, 'login-senha-campo', 'abcdef');
      expect(find.byKey(const ValueKey('login-msg-senha')), findsOneWidget);
      expect(find.text('Sua senha deve ter pelo menos 6 caracteres e 1 número'), findsOneWidget);
      await _digita(t, 'login-senha-campo', 'abcde1');
      expect(find.byKey(const ValueKey('login-msg-senha')), findsNothing);
      await _digita(t, 'login-confirmar-campo', 'outra1');
      expect(find.text('As senhas não coincidem'), findsOneWidget);

      await _preencheEEnvia(t, 'ana@x.com', 'abcde1', confirmar: 'outra1');
      expect(find.text('As senhas não são iguais'), findsOneWidget);

      await _preencheEEnvia(t, 'ana@x.com', 'abcdef', confirmar: 'abcdef');
      expect(find.text('Senha precisa de pelo menos 6 caracteres e 1 número'), findsOneWidget);
      expect(c.conta.chamadas, isEmpty);

      // digitar no e-mail limpa a mensagem
      await _digita(t, 'login-email-campo', 'ana@x.co');
      expect(find.text('Senha precisa de pelo menos 6 caracteres e 1 número'), findsNothing);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('em inglês', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t, idioma: 'en');
      c.conta.criarContaExistente('ana@x.com', 'abc123');
      await _abrirForm(t, c);
      await _toca(t, find.byKey(const ValueKey('login-enviar')));
      expect(find.text('Fill in email and password'), findsOneWidget);
      await _preencheEEnvia(t, 'ana@x.com', 'errada1');
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Wrong email or password'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('senha errada: carregando, depois "Algo deu errado" + mensagem; "Tentar de novo" volta ao formulário', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      c.conta.criarContaExistente('ana@x.com', 'abc123');
      await _abrirForm(t, c);
      expect(find.byKey(const ValueKey('carregando-masmorra')), findsNothing);

      final gate = Completer<void>();
      c.conta.segurar = gate;
      await _digita(t, 'login-email-campo', 'ana@x.com');
      await _digita(t, 'login-senha-campo', 'errada1');
      await t.tap(find.byKey(const ValueKey('login-enviar')));
      await _assenta(t, 300);
      expect(find.byKey(const ValueKey('carregando-masmorra')), findsOneWidget, reason: 'enquanto espera a rede o herói corre');
      expect(find.text('Carregando a masmorra...'), findsOneWidget);
      await t.pump(const Duration(milliseconds: 1800));
      expect(find.text('Carregando a masmorra...'), findsNothing, reason: 'a frase troca a cada 1,8 s');
      expect(find.text('Acordando o herói...'), findsOneWidget);

      gate.complete();
      c.conta.segurar = null;
      await _assenta(t, 300);
      expect(find.text('Algo deu errado'), findsOneWidget);
      expect(find.text('Email ou senha incorretos'), findsOneWidget);
      expect(find.byKey(const ValueKey('carregando-tentar-de-novo')), findsOneWidget);

      await t.pump(const Duration(milliseconds: 1700));
      await _toca(t, find.byKey(const ValueKey('carregando-tentar-de-novo')));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('carregando-masmorra')), findsNothing);
      expect(find.text('Entre na sua conta'), findsOneWidget, reason: 'voltou ao formulário');
      expect(c.e.uid, isNull);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('e-mail que já tem conta e e-mail inválido aparecem embaixo do campo, sem a tela de erro', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      c.conta.criarContaExistente('ana@x.com', 'abc123');
      await _abrirForm(t, c);
      await _toca(t, find.byKey(const ValueKey('login-alternar')));
      await _preencheEEnvia(t, 'ana@x.com', 'abc123', confirmar: 'abc123');
      expect(find.text('Esse email já tem conta -- troca pra "Entrar"'), findsOneWidget);
      expect(find.byKey(const ValueKey('carregando-masmorra')), findsNothing);
      await _preencheEEnvia(t, 'ana.x.com', 'abc123', confirmar: 'abc123');
      expect(find.text('Email inválido'), findsOneWidget);
      expect(find.text('Algo deu errado'), findsNothing);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('entrar numa conta sem save aqui leva à escolha do herói e o dono dos dados vira a conta', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      final u = c.conta.criarContaExistente('ana@x.com', 'abc123', uid: 'UANA');
      await _abrirForm(t, c);
      await _preencheEEnvia(t, 'ana@x.com', 'abc123');
      await t.pump(const Duration(milliseconds: 500));
      expect(c.e.uid, u.uid);
      expect(find.text('Quem vai enfrentar os monstros?'), findsOneWidget);
      expect(find.byKey(const ValueKey('onb-voltar')).hitTestable(), findsNothing, reason: 'logado: não há volta ao login');
      expect(find.byKey(const ValueKey('carregando-masmorra')), findsNothing);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('entrar numa conta com save: "Bem-vindo de volta" com o nome e o nível; Continuar entra; Trocar de conta sai', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final arm = ArmazenamentoMemoria();
      final c = await _cena(t, arm: arm);
      final u = c.conta.criarContaExistente('ana.silva@x.com', 'abc123', uid: 'UANA');
      await t.runAsync(() async {
        await c.e.entrarNaConta(u);
        await c.e.concluirOnboarding(nome: 'Anazinha', heroi: 3);
        await c.e.sairDaConta();
      });
      expect(c.e.uid, isNull);
      var concluiu = 0;
      await _abrirForm(t, c, aoConcluir: () => concluiu++);
      await _preencheEEnvia(t, 'ana.silva@x.com', 'abc123');
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Bem-vindo de volta'), findsOneWidget);
      expect(find.byKey(const ValueKey('boas-vindas-nome')), findsOneWidget);
      expect(find.text('ana.silva'), findsOneWidget, reason: 'sem nome do Google, o começo do e-mail');
      expect(find.text('NÍVEL I'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(c.e.uid, 'UANA');
      expect(c.e.save.nomeHeroi, 'Anazinha');

      await _toca(t, find.text('Continuar'));
      expect(concluiu, 1);

      await _toca(t, find.byKey(const ValueKey('boas-vindas-trocar')));
      expect(c.conta.atual, isNull);
      expect(c.e.uid, isNull);
      expect(c.e.entrada.value, EntradaModo.soLogin);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('cadastro de e-mail sem confirmar: a trava "Confirme seu e-mail" sobe e os dados NÃO trocam de dono', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      await _abrirForm(t, c);
      await _toca(t, find.byKey(const ValueKey('login-alternar')));
      await _preencheEEnvia(t, 'nova@x.com', 'abc123', confirmar: 'abc123');
      expect(c.conta.chamadas, containsAllInOrder(['cadastrar', 'emailVerificacaoEnviado']));
      expect(c.conta.idiomaEmails, 'pt');
      expect(c.e.verificando.value?.email, 'nova@x.com');
      expect(c.e.uid, isNull, reason: 'só troca depois de confirmar (como o aoLogar do original)');
      expect(find.byKey(const ValueKey('carregando-masmorra')), findsNothing);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('cadastro com e-mail já confirmado entra direto na escolha do herói (conta nova leva o convidado)', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      c.conta.cadastroJaVerificado = true;
      await _abrirForm(t, c);
      await _toca(t, find.byKey(const ValueKey('login-alternar')));
      await _preencheEEnvia(t, 'nova@x.com', 'abc123', confirmar: 'abc123');
      await t.pump(const Duration(milliseconds: 500));
      expect(c.e.uid, isNotNull);
      expect(find.text('Quem vai enfrentar os monstros?'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });
  });

  group('esqueci a senha', () {
    testWidgets('sem e-mail pede o e-mail; com e-mail avisa em verde; e-mail inválido avisa em vermelho', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      await _abrirForm(t, c);
      await _toca(t, find.byKey(const ValueKey('login-esqueci')));
      expect(find.text('Digita seu email primeiro'), findsOneWidget);
      expect(c.conta.chamadas, isEmpty);

      await _digita(t, 'login-email-campo', 'ana.x.com');
      await _toca(t, find.byKey(const ValueKey('login-esqueci')));
      expect(find.text('Email inválido'), findsOneWidget);

      await _digita(t, 'login-email-campo', ' ana@x.com ');
      await _toca(t, find.byKey(const ValueKey('login-esqueci')));
      expect(find.text('Email de recuperação enviado -- confira sua caixa de entrada'), findsOneWidget);
      expect(c.conta.ultimoEmailRedefinicao, 'ana@x.com');
      final msg = t.widget<Text>(find.byKey(const ValueKey('login-msg-email')));
      expect(msg.style!.color, const Color(0xFF4CAF7A), reason: 'sucesso em verde');

      c.conta.proximoErro = 'too-many-requests';
      await _toca(t, find.byKey(const ValueKey('login-esqueci')));
      expect(find.text('Muitas tentativas -- espera um pouco e tenta de novo'), findsOneWidget);
      c.conta.proximoErro = 'qualquer';
      await _toca(t, find.byKey(const ValueKey('login-esqueci')));
      expect(find.text('Não deu pra enviar o email -- tenta de novo'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });
  });

  group('Google', () {
    Future<_Cena> abrirEscolha(WidgetTester t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      await t.pumpWidget(_app(Onboarding(estado: c.e, somenteLogin: true, aoConcluir: () {})));
      await t.pump(const Duration(milliseconds: 500));
      return c;
    }

    testWidgets('entra e segue para a escolha do herói', (t) async {
      final c = await abrirEscolha(t);
      await _toca(t, find.byKey(const ValueKey('login-google')));
      await t.pump(const Duration(milliseconds: 500));
      expect(c.conta.chamadas, ['google']);
      expect(c.e.uid, 'google-1');
      expect(find.text('Quem vai enfrentar os monstros?'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('fechar o seletor do Google não é erro: só volta', (t) async {
      final c = await abrirEscolha(t);
      c.conta.usuarioGoogle = null;
      await _toca(t, find.byKey(const ValueKey('login-google')));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Algo deu errado'), findsNothing);
      expect(find.byKey(const ValueKey('carregando-masmorra')), findsNothing);
      expect(find.text('Continuar com Google'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('falha do Google: "Não deu pra entrar com Google"; sem rede: mensagem de conexão', (t) async {
      final c = await abrirEscolha(t);
      c.conta.proximoErro = 'google-unknownError';
      await _toca(t, find.byKey(const ValueKey('login-google')));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Algo deu errado'), findsOneWidget);
      expect(find.text('Não deu pra entrar com Google'), findsOneWidget);
      await _toca(t, find.byKey(const ValueKey('carregando-tentar-de-novo')));
      await t.pump(const Duration(milliseconds: 400));
      c.conta.proximoErro = 'network-request-failed';
      await _toca(t, find.byKey(const ValueKey('login-google')));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Sem conexão. Verifique a internet e tente de novo.'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });
  });

  group('entrar como convidado dentro do login', () {
    testWidgets('com jogo local reentra direto; sem jogo vai escolher o herói; a seta só existe se há jogo', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final arm = ArmazenamentoMemoria();
      final c = await _cena(t, arm: arm);
      // sem jogo local: sem seta, convidado vai ao herói
      var concluiu = 0;
      await t.pumpWidget(_app(Onboarding(estado: c.e, somenteLogin: true, aoConcluir: () => concluiu++)));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const ValueKey('onb-voltar')).hitTestable(), findsNothing);
      await _toca(t, find.byKey(const ValueKey('login-convidado')));
      expect(concluiu, 0);
      expect(find.text('Quem vai enfrentar os monstros?'), findsOneWidget);
      await t.pumpWidget(const SizedBox());

      // com jogo local: tem seta, e o convidado reentra
      await t.runAsync(() => c.e.concluirOnboarding(nome: 'Gui', heroi: 1));
      await t.pumpWidget(_app(Onboarding(estado: c.e, somenteLogin: true, aoConcluir: () => concluiu++)));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const ValueKey('onb-voltar')).hitTestable(), findsOneWidget);
      await _toca(t, find.byKey(const ValueKey('login-convidado')));
      expect(concluiu, 1);
      await _toca(t, find.byKey(const ValueKey('onb-voltar')));
      expect(concluiu, 2, reason: 'a seta volta ao jogo');
      await t.pumpWidget(const SizedBox());
    });
  });

  group('confirmar e-mail', () {
    testWidgets('texto, reenviar (ok e erro) e a conferência automática a cada 4 s', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      late UsuarioConta u;
      await t.runAsync(() async => u = await c.conta.cadastrar('nova@x.com', 'abc123'));
      c.e.verificando.value = u;
      await t.pumpWidget(_app(TelaVerificarEmail(estado: c.e, usuario: u)));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      expect(find.byKey(const ValueKey('verificar-texto')), findsOneWidget);
      expect(find.textContaining('nova@x.com', findRichText: true), findsOneWidget);
      expect(find.text('Reenviar email'), findsOneWidget);
      expect(find.text('Email errado? Corrigir'), findsOneWidget);

      await _toca(t, find.byKey(const ValueKey('verificar-reenviar')));
      expect(find.text('Email reenviado'), findsOneWidget);
      c.conta.proximoErro = 'too-many-requests';
      await _toca(t, find.byKey(const ValueKey('verificar-reenviar')));
      expect(find.text('Não deu pra reenviar -- espera um pouco e tenta de novo'), findsOneWidget);
      await t.pump(const Duration(seconds: 7));
      expect(find.byKey(const ValueKey('verificar-msg')), findsNothing, reason: 'a mensagem some em 6 s');

      // ainda não confirmou: confere e continua na trava
      await t.pump(const Duration(seconds: 4));
      expect(c.conta.chamadas.where((x) => x == 'recarregar'), isNotEmpty);
      expect(c.e.verificando.value, isNotNull);
      // clicou no link: a próxima conferência libera
      c.conta.confirmarNoProximoRecarregar = true;
      await t.pump(const Duration(seconds: 4));
      await t.pump(const Duration(milliseconds: 100));
      expect(c.e.verificando.value, isNull);
      expect(c.e.uid, u.uid);
      expect(c.e.entrada.value, EntradaModo.completa, reason: 'sem save: vai escolher o herói');
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('"Email errado? Corrigir" apaga a conta recém-criada e volta ao login', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      late UsuarioConta u;
      await t.runAsync(() async => u = await c.conta.cadastrar('errado@x.com', 'abc123'));
      c.e.verificando.value = u;
      await t.pumpWidget(_app(TelaVerificarEmail(estado: c.e, usuario: u)));
      await t.pump(const Duration(milliseconds: 300));
      await _toca(t, find.byKey(const ValueKey('verificar-corrigir')));
      expect(c.conta.chamadas, contains('corrigirEmailErrado'));
      expect(c.conta.atual, isNull);
      expect(c.e.verificando.value, isNull);
      expect(c.e.entrada.value, EntradaModo.soLogin);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('em inglês', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t, idioma: 'en');
      late UsuarioConta u;
      await t.runAsync(() async => u = await c.conta.cadastrar('nova@x.com', 'abc123'));
      await t.pumpWidget(_app(TelaVerificarEmail(estado: c.e, usuario: u)));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Confirm your email'), findsOneWidget);
      expect(find.text('Resend email'), findsOneWidget);
      expect(find.text('Wrong email? Fix it'), findsOneWidget);
      await _toca(t, find.byKey(const ValueKey('verificar-reenviar')));
      expect(find.text('Email resent'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });
  });

  group('Configurações > Conta', () {
    Future<void> abrirConfig(WidgetTester t, EstadoJogo e) async {
      await t.pumpWidget(_app(Builder(builder: (ctx) => Scaffold(body: Center(child: TextButton(onPressed: () => abrirConfiguracoes(ctx, e), child: const Text('abrir-config')))))));
      await t.tap(find.text('abrir-config'));
      await _assenta(t);
    }

    testWidgets('sem conta: "Jogando sem conta" + Criar conta (abre o login e marca o convidado); sem Sair nem Excluir', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      await abrirConfig(t, c.e);
      expect(find.text('Jogando sem conta'), findsOneWidget);
      expect(find.byKey(const ValueKey('cfg-sair')), findsNothing);
      expect(find.byKey(const ValueKey('cfg-excluir-conta')), findsNothing);
      await _toca(t, find.text('Criar conta'));
      expect(c.arm.ler('questlog.convidado.v1'), '1', reason: 'o progresso do convidado migra para a conta nova');
      expect(c.e.entrada.value, EntradaModo.soLogin);
      expect(find.text('Jogando sem conta'), findsNothing, reason: 'as Configurações fecharam');
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('logado: "Logado como", sem botão Criar conta, e a tela Gerenciar conta mostra o mesmo', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      final u = c.conta.criarContaExistente('bruno@x.com', 'abc123', uid: 'UB');
      await t.runAsync(() async {
        await c.conta.entrar('bruno@x.com', 'abc123');
        await c.e.entrarNaConta(u);
        await c.e.concluirOnboarding(nome: 'B', heroi: 0);
      });
      await abrirConfig(t, c.e);
      expect(find.text('Logado como bruno'), findsOneWidget);
      expect(find.text('Criar conta'), findsNothing);
      expect(find.byKey(const ValueKey('cfg-sair')), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(find.text('Excluir conta'), findsOneWidget);
      await _toca(t, find.text('Logado como bruno'));
      expect(find.byKey(const ValueKey('conta-id-info')), findsOneWidget);
      expect(t.widget<Text>(find.byKey(const ValueKey('conta-id-info'))).data, 'Logado como bruno');
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('em inglês: "Logged in as" e "Log out"', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t, idioma: 'en');
      c.conta.criarContaExistente('carl@x.com', 'abc123', uid: 'UC');
      await t.runAsync(() => c.conta.entrar('carl@x.com', 'abc123'));
      await abrirConfig(t, c.e);
      expect(find.text('Logged in as carl'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('Sair: desconecta, fecha as Configurações, volta ao jogo local e abre o login', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      final u = c.conta.criarContaExistente('dora@x.com', 'abc123', uid: 'UD');
      await t.runAsync(() async {
        await c.conta.entrar('dora@x.com', 'abc123');
        await c.e.entrarNaConta(u);
        await c.e.concluirOnboarding(nome: 'Dora', heroi: 0);
      });
      await abrirConfig(t, c.e);
      await t.tap(find.byKey(const ValueKey('cfg-sair')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(c.conta.chamadas, contains('sair'));
      expect(c.conta.atual, isNull);
      expect(c.e.uid, isNull);
      expect(c.e.entrada.value, EntradaModo.soLogin);
      expect(find.text('abrir-config'), findsOneWidget, reason: 'voltou à tela de baixo');
      expect(c.arm.ler('questlog.v1.uid.UD.pj.pj1'), isNotNull, reason: 'o save da conta fica no aparelho');
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('Excluir conta (e-mail/senha): pede a senha, recusa senha errada e vazia, exclui e limpa a conta do aparelho', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      final u = c.conta.criarContaExistente('eva@x.com', 'abc123', uid: 'UE');
      await t.runAsync(() async {
        await c.conta.entrar('eva@x.com', 'abc123');
        await c.e.entrarNaConta(u);
        await c.e.concluirOnboarding(nome: 'Eva', heroi: 0);
      });
      await abrirConfig(t, c.e);
      await _toca(t, find.byKey(const ValueKey('cfg-excluir-conta')));
      expect(find.text('EXCLUIR CONTA?'), findsOneWidget);
      expect(find.text('Isso apaga sua conta de login e todo o progresso salvo na nuvem, em definitivo. Não tem volta.'), findsOneWidget);
      expect(find.text('Confirme sua senha pra continuar'), findsOneWidget);
      expect(find.byKey(const ValueKey('excluir-senha')), findsOneWidget);
      expect(find.byKey(const ValueKey('excluir-google-aviso')), findsNothing);

      // vazia: não chama o serviço
      await _toca(t, find.byKey(const ValueKey('excluir-confirmar')));
      expect(find.text('Senha incorreta.'), findsOneWidget);
      expect(c.conta.chamadas.where((x) => x == 'excluir'), isEmpty);

      // errada: o serviço recusa
      await t.enterText(find.byKey(const ValueKey('excluir-senha')), 'errada1');
      await _toca(t, find.byKey(const ValueKey('excluir-confirmar')));
      expect(c.conta.chamadas.where((x) => x == 'excluir'), hasLength(1));
      expect(find.text('Senha incorreta.'), findsOneWidget);
      expect(c.conta.atual, isNotNull);
      expect(find.text('EXCLUIR CONTA?'), findsOneWidget, reason: 'a folha continua aberta');

      // certa
      await t.enterText(find.byKey(const ValueKey('excluir-senha')), 'abc123');
      await t.tap(find.byKey(const ValueKey('excluir-confirmar')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(c.conta.atual, isNull);
      expect(c.conta.ultimaSenhaExcluir, 'abc123');
      expect(c.arm.chaves().where((k) => k.contains('.uid.UE')), isEmpty);
      expect(c.e.uid, isNull);
      expect(c.e.entrada.value, EntradaModo.soLogin);
      expect(find.text('EXCLUIR CONTA?'), findsNothing);
      expect(find.text('abrir-config'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('Excluir conta (Google): sem campo de senha, com o aviso do Google; fechar o Google não mostra erro', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      late UsuarioConta u;
      await t.runAsync(() async {
        u = await c.conta.entrarComGoogle();
        await c.e.entrarNaConta(u);
        await c.e.concluirOnboarding(nome: 'Gabi', heroi: 0);
      });
      await abrirConfig(t, c.e);
      expect(find.text('Logado como Ana'), findsOneWidget, reason: 'primeiro nome do Google');
      await _toca(t, find.byKey(const ValueKey('cfg-excluir-conta')));
      expect(find.byKey(const ValueKey('excluir-google-aviso')), findsOneWidget);
      expect(find.byKey(const ValueKey('excluir-senha')), findsNothing);

      // o jogador fecha o Google: não é erro e a folha continua
      c.conta.proximoErro = 'popup-closed-by-user';
      await _toca(t, find.byKey(const ValueKey('excluir-confirmar')));
      expect(find.byKey(const ValueKey('excluir-erro')), findsNothing);
      expect(c.conta.atual, isNotNull);

      // falha qualquer: mensagem do Google
      c.conta.proximoErro = 'internal-error';
      await _toca(t, find.byKey(const ValueKey('excluir-confirmar')));
      expect(find.text('Não deu pra confirmar com o Google. Tenta de novo.'), findsOneWidget);

      // precisa entrar de novo
      c.conta.proximoErro = 'requires-recent-login';
      await _toca(t, find.byKey(const ValueKey('excluir-confirmar')));
      expect(find.text('Por segurança, entre na sua conta de novo e tente excluir em seguida.'), findsOneWidget);

      // agora vai
      await t.tap(find.byKey(const ValueKey('excluir-confirmar')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(c.conta.atual, isNull);
      expect(c.e.entrada.value, EntradaModo.soLogin);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('Excluir conta: durante a exclusão o botão mostra "Excluindo…" e a folha não fecha', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = await _cena(t);
      final u = c.conta.criarContaExistente('fabi@x.com', 'abc123', uid: 'UF');
      await t.runAsync(() async {
        await c.conta.entrar('fabi@x.com', 'abc123');
        await c.e.entrarNaConta(u);
        await c.e.concluirOnboarding(nome: 'Fabi', heroi: 0);
      });
      await abrirConfig(t, c.e);
      await _toca(t, find.byKey(const ValueKey('cfg-excluir-conta')));
      final gate = Completer<void>();
      c.conta.segurar = gate;
      await t.enterText(find.byKey(const ValueKey('excluir-senha')), 'abc123');
      await t.tap(find.byKey(const ValueKey('excluir-confirmar')));
      await t.pump();
      expect(find.text('Excluindo…'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('EXCLUIR CONTA?'), findsOneWidget, reason: 'não fecha no meio da exclusão');
      gate.complete();
      c.conta.segurar = null;
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(c.conta.atual, isNull);
      await t.pumpWidget(const SizedBox());
    });
  });
}
