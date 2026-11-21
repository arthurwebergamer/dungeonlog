// Fase 5: entrada (abertura, onboarding, quiz, login, configuração do herói) e tutorial guiado.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/entrada.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/dominio/tutorial.dart';
import 'package:dungeonlog_flutter/ui/app.dart';
import 'package:dungeonlog_flutter/ui/equip_arena.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:dungeonlog_flutter/ui/onboarding.dart';
import 'package:dungeonlog_flutter/ui/sheet_md.dart' show FilaPopups;
import 'package:dungeonlog_flutter/ui/tema.dart';
import 'package:dungeonlog_flutter/ui/tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DadosJogo _dados() {
  String l(String n) => File('assets/dados/$n.json').readAsStringSync();
  return DadosJogo.deTextos(monstros: l('monstros'), herois: l('herois'), temas: l('temas_arena'), itens: l('itens'), traducoes: l('traducoes'));
}

Future<EstadoJogo> _estado(ArmazenamentoMemoria arm, {bool onboarding = false, String idioma = 'pt'}) async {
  final e = EstadoJogo(dados: _dados(), armazenamento: arm, agora: () => DateTime(2026, 11, 11, 10), aleatorio: Random(1), idioma: idioma);
  await e.iniciar(permitirOnboarding: onboarding);
  return e;
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

Widget _app(Widget home) => MaterialApp(
      theme: temaApp(),
      builder: (c, ch) => Stack(children: [Positioned.fill(child: ch!), const Positioned.fill(child: CamadaTour())]),
      home: home,
    );

void main() {
  setUp(() {
    FilaPopups.reiniciar();
    Paleta.atual = Paleta.grafite;
  });
  setUpAll(() async {
    await _fontes();
    EquipArena.atual = EquipArena.deTexto(File('assets/dados/equip_arena.json').readAsStringSync());
  });

  group('regras da entrada', () {
    test('idioma padrão do aparelho: pt-BR e "pt" são PT; o resto EN; pt-BR em qualquer posição vale', () {
      expect(idiomaPadraoDoAparelho(['pt-BR']), 'pt');
      expect(idiomaPadraoDoAparelho(['pt']), 'pt');
      expect(idiomaPadraoDoAparelho(['en-US', 'pt-BR']), 'pt');
      expect(idiomaPadraoDoAparelho(['pt-PT']), 'en');
      expect(idiomaPadraoDoAparelho(['en-US']), 'en');
      expect(idiomaPadraoDoAparelho([]), 'en');
    });
    test('texto da abertura segue a língua do aparelho', () {
      expect(textoAbertura('pt'), 'Carregando a masmorra...');
      expect(textoAbertura('pt-PT'), 'Carregando a masmorra...');
      expect(textoAbertura('en'), 'Loading the dungeon...');
      expect(textoAbertura(null), 'Carregando a masmorra...');
    });
    test('registro de telas vistas lê e grava como o JSON do original', () {
      expect(lerTelasVistas(null), isEmpty);
      expect(lerTelasVistas('lixo'), isEmpty);
      expect(lerTelasVistas('[1]'), isEmpty);
      expect(lerTelasVistas('{"tarefas":true,"loja":false}'), {'tarefas': true});
      expect(jsonDecode(gravarTelasVistas({'tarefas': true})), {'tarefas': true});
    });
    test('cartão do tour: embaixo se o alvo está em cima, no topo se o alvo está embaixo', () {
      var p = posicionarCartaoTour(larguraTela: 390, alturaTela: 844, alturaCartao: 170, alvo: const Rect.fromLTWH(20, 100, 100, 44), alvos: const [Rect.fromLTWH(20, 100, 100, 44)]);
      expect(p.base, 14);
      expect(p.safeBase, isTrue);
      expect(p.esquerda, 12);
      expect(p.largura, 366);
      expect(p.noTopo, isFalse);
      p = posicionarCartaoTour(larguraTela: 390, alturaTela: 844, alturaCartao: 170, alvo: const Rect.fromLTWH(20, 700, 100, 44), alvos: const [Rect.fromLTWH(20, 700, 100, 44)]);
      expect(p.topo, 12);
      expect(p.safeTopo, isTrue);
      expect(p.noTopo, isTrue);
    });
    test('quiz: 4 categorias, 5 slides e o quinto leva ao login', () {
      expect(categoriasOnboarding.map((c) => c.id), ['estudos', 'trabalho', 'rotina', 'tudo']);
      expect(slidesOnboarding.length, 5);
      expect(slidesOnboarding.last.botao, 'Criar minha conta');
      expect(nomeAoFimDoSetup('   '), isNull);
      expect(nomeAoFimDoSetup('  Ana '), 'Ana');
    });
  });

  group('estado: entrada pendente não grava nada', () {
    test('sem save: pendente e nada gravado; ao concluir grava save v3 com comecou, nome e herói', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm, onboarding: true);
      expect(e.onboardingPendente, isTrue);
      expect(arm.ler(chaveSave()), isNull, reason: 'fechar o app no meio recomeça da entrada');
      expect(arm.ler('questlog.vida.v1.pj.pj1'), isNull);
      await e.concluirOnboarding(nome: ' Ana ', heroi: 3);
      expect(e.onboardingPendente, isFalse);
      final j = jsonDecode(arm.ler(chaveSave())!) as Map<String, dynamic>;
      expect(j['comecou'], true);
      expect(j['nomeHeroi'], 'Ana');
      expect(j['heroi'], 3);
      expect(j['versao'], 3);
      expect(jsonDecode(arm.ler('questlog.vida.v1.pj.pj1')!)['vida'], 40);
      final e2 = await _estado(arm, onboarding: true);
      expect(e2.onboardingPendente, isFalse);
      expect(e2.save.nomeHeroi, 'Ana');
    });
    test('save existente não vê a entrada', () async {
      final arm = ArmazenamentoMemoria();
      await _estado(arm); // jogo já começado (grava)
      final e = await _estado(arm, onboarding: true);
      expect(e.onboardingPendente, isFalse);
    });
    test('tutorial: marcar telas, rever e chave do aparelho', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm);
      expect(e.tutorialVisto('tarefas'), isFalse);
      e.marcarTelasVistas(['loja']);
      expect(e.tutorialVisto('loja'), isTrue);
      expect(arm.ler('questlog.tutorialTelas.v2'), '{"loja":true}');
      e.marcarTelasVistas(telasTutorial);
      expect(e.telasVistas.length, 5);
      e.reiniciarTutorial();
      expect(e.telasVistas, isEmpty);
    });
  });

  testWidgets('onboarding completo: slides, quiz, login, convidado, herói, nome e conclusão', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => t.binding.setSurfaceSize(null));
    late EstadoJogo e;
    final arm = ArmazenamentoMemoria();
    await t.runAsync(() async => e = await _estado(arm, onboarding: true));
    var concluiu = false;
    await t.pumpWidget(_app(Onboarding(estado: e, aoConcluir: () => concluiu = true)));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Suas tarefas viram uma masmorra pra vencer'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
    expect(find.byKey(const ValueKey('onb-voltar')).hitTestable(), findsNothing);

    Future<void> toca(Finder f) async {
      await t.tap(f);
      await t.pump();
      await t.pump(const Duration(milliseconds: 450));
    }

    await toca(find.byKey(const ValueKey('onb-btn1')));
    expect(find.text('O que você mais quer organizar?'), findsOneWidget);
    expect(find.text('Rotina pessoal'), findsOneWidget);
    await toca(find.byKey(const ValueKey('quiz-rotina')));
    expect(arm.ler('questlog.onboarding.categoria.v1'), 'rotina');
    expect(arm.ler(chaveSave()), isNull);
    await toca(find.byKey(const ValueKey('onb-btn2')));
    expect(find.text('Veja seu herói evoluir a cada tarefa'), findsOneWidget);
    expect(find.text('NÍVEL 4'), findsOneWidget);
    await toca(find.byKey(const ValueKey('onb-btn3')));
    expect(find.text('Desbloqueie conquistas conforme joga'), findsOneWidget);
    await toca(find.byKey(const ValueKey('onb-btn4')));
    expect(find.text('Marcou como feito. Golpe certeiro.'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1500)); // roda o golpe
    expect(t.takeException(), isNull);
    await toca(find.byKey(const ValueKey('onb-voltar')));
    expect(find.text('Desbloqueie conquistas conforme joga'), findsOneWidget);
    await toca(find.byKey(const ValueKey('onb-btn4')));
    await toca(find.byKey(const ValueKey('onb-btn5')));
    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('Entrar como convidado'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('login-google')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Disponível em breve'), findsOneWidget);
    await t.tap(find.text('Entendi'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await toca(find.byKey(const ValueKey('login-convidado')));
    expect(arm.ler('questlog.convidado.v1'), '1');
    expect(find.text('Quem vai enfrentar os monstros?'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await toca(find.byKey(const ValueKey('onb-heroi-prox')));
    }
    await toca(find.byKey(const ValueKey('onb-continuar')));
    expect(find.text('Como quer ser chamado?'), findsOneWidget);
    await toca(find.byKey(const ValueKey('onb-comecar')));
    expect(concluiu, isFalse);
    expect(find.text('Escolha um nome pra continuar'), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('onb-nome')), 'Um nome muito comprido demais');
    await t.pump();
    expect(t.widget<TextField>(find.byKey(const ValueKey('onb-nome'))).controller!.text.length, maximoNomeHeroi);
    await t.enterText(find.byKey(const ValueKey('onb-nome')), 'Ana');
    await t.pump();
    await t.tap(find.byKey(const ValueKey('onb-comecar')));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await t.pump();
    expect(concluiu, isTrue);
    final j = jsonDecode(arm.ler(chaveSave())!) as Map<String, dynamic>;
    expect((j['nomeHeroi'], j['heroi'], j['comecou']), ('Ana', 3, true));
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('onboarding: Pular vai ao login, a seta volta ao slide de origem; 360 px; inglês', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => t.binding.setSurfaceSize(null));
    late EstadoJogo e;
    await t.runAsync(() async => e = await _estado(ArmazenamentoMemoria(), onboarding: true, idioma: 'en'));
    await t.pumpWidget(_app(Onboarding(estado: e, aoConcluir: () {})));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Your tasks become a dungeon to beat'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('onb-btn1')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.byKey(const ValueKey('onb-pular')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 450));
    expect(find.text('Continue as guest'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('login-email')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 450));
    expect(find.text('Log into your account'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('login-alternar')));
    await t.pump();
    expect(find.text('Create your account'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('onb-voltar')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.byKey(const ValueKey('onb-voltar')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 450));
    expect(find.text('What do you want to organize most?'), findsOneWidget, reason: 'voltou ao slide de onde saiu');
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('tour: abre sozinho na primeira vez e não volta depois de visto', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => t.binding.setSurfaceSize(null));
    late EstadoJogo e;
    await t.runAsync(() async => e = await _estado(ArmazenamentoMemoria()));
    await t.pumpWidget(_app(Casca(estado: e, comTutorial: true)));
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
    expect(TourControle.visivel.value, isNotNull);
    expect(find.text('1 / 9'), findsOneWidget);
    expect(find.text('SUA VEZ'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    expect(find.text('Toque em + Adicionar pra criar sua primeira tarefa.'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('tour-pular')));
    await t.pump(const Duration(milliseconds: 300));
    expect(TourControle.visivel.value, isNull);
    expect(e.telasVistas.length, 5);
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(_app(Casca(estado: e, comTutorial: true)));
    await t.pump(const Duration(milliseconds: 600));
    expect(TourControle.visivel.value, isNull);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('tour: percorre os passos informativos até "Concluir"', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => t.binding.setSurfaceSize(null));
    late EstadoJogo e;
    await t.runAsync(() async => e = await _estado(ArmazenamentoMemoria()));
    await t.pumpWidget(_app(Casca(estado: e, comTutorial: true)));
    await t.pump(const Duration(milliseconds: 600));
    final c = TourControle.instancia!;
    e.criarTarefa(texto: 'Ler', modo: ModoTarefa.hoje, dif: 'media');
    TourAlvos.tarefaAlvo = e.save.tarefas.last;
    c.i = 2;
    c.proximo();
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('4 / 9'), findsOneWidget);
    for (var n = 5; n <= 9; n++) {
      await t.tap(find.byKey(const ValueKey('tour-proximo')));
      await t.pump(const Duration(milliseconds: 100));
      await t.pump(const Duration(milliseconds: 900));
      expect(find.text('$n / 9'), findsOneWidget, reason: 'passo $n');
    }
    expect(find.text('Concluir'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('tour-proximo')));
    await t.pump(const Duration(milliseconds: 300));
    expect(TourControle.visivel.value, isNull);
    expect(e.telasVistas.length, 5);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
}
