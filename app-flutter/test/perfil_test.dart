// Fase 3: estado do Perfil (histórico, Grimório, conquistas, heróis, preferências) e uma passada pelas telas.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dominio/conquistas.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/dominio/tarefa.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:dungeonlog_flutter/ui/sheet_md.dart' show FilaPopups;
import 'package:dungeonlog_flutter/ui/svg_icone.dart' show IconeSvg;
import 'package:dungeonlog_flutter/ui/tela_catalogo.dart' show abrirCatalogoGrimorio, abrirFichaGrimorioOculto;
import 'package:dungeonlog_flutter/ui/tela_perfil.dart';
import 'package:dungeonlog_flutter/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DadosJogo _dados() {
  String l(String n) => File('assets/dados/$n.json').readAsStringSync();
  return DadosJogo.deTextos(monstros: l('monstros'), herois: l('herois'), temas: l('temas_arena'), itens: l('itens'), traducoes: l('traducoes'));
}

Future<EstadoJogo> _estado(ArmazenamentoMemoria arm, {DateTime? agora, String idioma = 'pt', String personagem = 'pj1'}) async {
  final relogio = agora ?? DateTime(2026, 11, 11, 10);
  final e = EstadoJogo(dados: _dados(), armazenamento: arm, agora: () => relogio, aleatorio: Random(1), idioma: idioma, personagem: personagem);
  await e.iniciar();
  return e;
}

Future<void> _fontes() async {
  for (final (nome, arqs) in [
    ('Outfit', ['Outfit-Regular.ttf', 'Outfit-Medium.ttf', 'Outfit-SemiBold.ttf', 'Outfit-Bold.ttf']),
    ('Silkscreen', ['Silkscreen-Regular.ttf']),
  ]) {
    final l = FontLoader(nome);
    for (final a in arqs) {
      l.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$a').readAsBytesSync())));
    }
    await l.load();
  }
}

void main() {
  setUp(() {
    FilaPopups.reiniciar();
    Paleta.atual = Paleta.grafite;
  });
  setUpAll(_fontes);

  group('histórico e bestiário', () {
    test('a virada do dia grava o dia que fechou (vitória, com o monstro) e não duplica', () async {
      final arm = ArmazenamentoMemoria();
      // ontem (10/11) tinha uma tarefa feita; o app abre em 11/11
      final save = SaveV3(
        nomeHeroi: 'T',
        semente: 5,
        tarefas: [
          Tarefa({'texto': 'a', 'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6], 'feitaEm': '2026-11-10', 'dif': 'media', 'meta': 1}),
        ],
      );
      final cat = _dados().catalogo;
      await arm.gravar(chaveSave(), jsonEncode(save.paraJson(cat, salvoEm: 1)));
      await arm.gravar(chaveConta('questlog.vida.v1'), jsonEncode({'vida': 40, 'ultimoDia': '2026-11-10'}));
      final e = await _estado(arm);
      expect(e.hist.length, 1);
      expect(e.hist.first.data, '2026-11-10');
      expect(e.hist.first.resultado, 'vitoria');
      expect(e.hist.first.monstroId, isNotNull);
      expect(e.monstrosDerrotadosIds, contains(e.hist.first.monstroId));
      // gravou no mesmo formato do original
      final bruto = jsonDecode(arm.ler(chaveConta('questlog.hist.v1'))!) as List;
      expect(bruto.first, containsPair('resultado', 'vitoria'));
      // abrir de novo no mesmo dia não duplica
      final e2 = await _estado(arm);
      expect(e2.hist.length, 1);
    });

    test('dia largado vira fuga e não entra no bestiário', () async {
      final arm = ArmazenamentoMemoria();
      final save = SaveV3(nomeHeroi: 'T', semente: 5, tarefas: [
        Tarefa({'texto': 'a', 'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6], 'feitaEm': null, 'dif': 'media', 'meta': 1}),
      ]);
      await arm.gravar(chaveSave(), jsonEncode(save.paraJson(_dados().catalogo, salvoEm: 1)));
      await arm.gravar(chaveConta('questlog.vida.v1'), jsonEncode({'vida': 40, 'ultimoDia': '2026-11-10'}));
      final e = await _estado(arm);
      expect(e.hist.single.resultado, 'fuga');
      expect(e.monstrosDerrotadosIds, isEmpty);
    });

    test('monstro de hoje aparece no bestiário assim que o dia é vencido, sem gravar no histórico', () async {
      final e = await _estado(ArmazenamentoMemoria());
      e.criarTarefa(texto: 'x', modo: ModoTarefa.hoje, dif: 'media');
      e.concluir(e.tarefasDeHoje.first);
      e.terminarDia();
      expect(e.derrotado, isTrue);
      expect(e.monstrosDerrotadosIds, {e.monstroDoDiaIdx});
      expect(e.hist, isEmpty);
    });
  });

  group('Grimório e itens vistos', () {
    test('todo item que entra no inventário é marcado como visto (pelo id base) e o save guarda a lista', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm);
      expect(e.itensVistos, isEmpty);
      e.criarTarefa(texto: 'x', modo: ModoTarefa.hoje, dif: 'media');
      e.concluir(e.tarefasDeHoje.first);
      e.terminarDia(); // gera o baú, que credita itens imediatos
      final tesouro = e.catalogo.baseN > 0 ? e.save.inventario : [];
      for (final sl in tesouro) {
        expect(e.itensVistos, contains(e.catalogo.baseDe((sl['id'] as num).toInt())));
      }
      final gravado = jsonDecode(arm.ler(chaveConta('questlog.itensVistos.v1'))!) as List;
      expect(gravado.toSet(), e.itensVistos);
    });

    test('o Grimório é entregue só no nível do marco (IV a VII, pela semente) e some nas outras subidas', () async {
      final e = await _estado(ArmazenamentoMemoria());
      final alvo = nivelDoGrimorio(e.save.semente);
      expect(alvo, inInclusiveRange(4, 7));
      expect(e.entregarGrimorioSe(alvo - 1), isFalse);
      expect(e.quantidadeDe(e.idGrimorio), 0);
      expect(e.entregarGrimorioSe(alvo), isTrue);
      expect(e.quantidadeDe(e.idGrimorio), 1);
      expect(e.itensVistos, contains(e.idGrimorio));
    });
  });

  group('conquistas', () {
    test('desbloqueiam sozinhas com a data de hoje, aparecem como NOVAS até abrir a tela e depois somem', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm);
      e.criarTarefa(texto: 'x', modo: ModoTarefa.hoje, dif: 'media');
      e.concluir(e.tarefasDeHoje.first);
      expect(e.conqDesbloq['tarefas:0'], '2026-11-11'); // "Primeira Vitória"
      expect(e.conquistasNaoVistas, greaterThan(0));
      final antes = e.conquistasNaoVistas;
      e.marcarConquistasVistas();
      expect(e.conquistasNaoVistas, 0);
      expect(antes, e.conqDesbloq.length);
      // persistiu no formato do original
      final d = jsonDecode(arm.ler(chaveConta('questlog.conquistasDesbloqueadasV2.v1'))!) as Map;
      expect(d['tarefas:0'], '2026-11-11');
      final v = jsonDecode(arm.ler(chaveConta('questlog.conquistasVistasV2.v1'))!) as List;
      expect(v.toSet(), e.conqDesbloq.keys.toSet());
    });

    test('desbloqueio já feito não é refeito (a data fica a do primeiro dia)', () async {
      final arm = ArmazenamentoMemoria();
      await arm.gravar(chaveConta('questlog.conquistasDesbloqueadasV2.v1'), jsonEncode({'tarefas:0': '2026-01-01'}));
      final e = await _estado(arm);
      e.criarTarefa(texto: 'x', modo: ModoTarefa.hoje, dif: 'media');
      e.concluir(e.tarefasDeHoje.first);
      expect(e.conqDesbloq['tarefas:0'], '2026-01-01');
    });
  });

  group('preferências do aparelho', () {
    test('som, vibração, CRT, golpes, notificações e idioma gravam nas chaves do original', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm);
      expect(e.somLigado, isTrue);
      expect(e.vibracaoLigada, isTrue);
      expect(e.crtLigado, isFalse);
      expect(e.golpesVariados, isTrue);
      e.definirSom(false);
      e.definirVibracao(false);
      e.definirCrt(true);
      e.definirGolpesVariados(false);
      e.definirNotificacoes(true);
      e.definirIdioma('en');
      final sfx = jsonDecode(arm.ler('questlog.sfx.v1')!) as Map;
      expect(sfx['ativo'], false);
      expect(sfx['feedback'], 'desativado');
      expect(sfx['volume'], 0.55);
      expect(arm.ler('questlog.crt.v1'), '1');
      expect(arm.ler('questlog.golpesVariados.v1'), '0');
      expect(arm.ler('questlog.idioma.v1'), 'en');
      expect(e.idioma, 'en');
      // relê tudo igual
      expect(e.somLigado, isFalse);
      expect(e.vibracaoLigada, isFalse);
      expect(e.crtLigado, isTrue);
      expect(e.golpesVariados, isFalse);
      expect(e.notificacoesLigadas, isTrue);
    });

    test('o valor antigo "som" do feedback conta como vibração desligada', () async {
      final arm = ArmazenamentoMemoria();
      await arm.gravar('questlog.sfx.v1', jsonEncode({'ativo': true, 'volume': 0.3, 'feedback': 'som'}));
      final e = await _estado(arm);
      expect(e.vibracaoLigada, isFalse);
      e.definirSom(true);
      expect((jsonDecode(arm.ler('questlog.sfx.v1')!) as Map)['volume'], 0.3); // não perde o volume
    });
  });

  group('heróis', () {
    test('o grátis só tem um herói: criar é recusado (Pro é da Fase 7)', () async {
      final e = await _estado(ArmazenamentoMemoria());
      expect(e.limitePersonagens, 1);
      expect(await e.criarPersonagem('Novo', 2), isFalse);
      expect(e.personagens.length, 1);
    });

    test('Pro: cria com nome e sprite, troca preservando o save de cada um e exclui', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm);
      e.ehPro = true;
      e.criarTarefa(texto: 'do primeiro', modo: ModoTarefa.hoje, dif: 'media');
      e.concluir(e.tarefasDeHoje.first);
      final moedasPrimeiro = e.save.moedas;
      expect(moedasPrimeiro, greaterThan(0));
      expect(await e.criarPersonagem('Aria', 3), isTrue);
      expect(e.personagens.length, 2);
      final id2 = e.personagem;
      expect(id2, isNot('pj1'));
      expect(e.save.nomeHeroi, 'Aria');
      expect(e.save.heroi, 3);
      expect(e.save.moedas, 0); // herói novo começa do zero
      expect(e.tarefasDeHoje, isEmpty);
      expect(e.totalConcluidas, 0);
      expect(e.hist, isEmpty);
      expect(arm.ler('questlog.personagemAtivo.v1'), id2);
      // o segundo ganha moedas; voltar ao primeiro devolve exatamente o estado dele
      e.save.moedas = 99;
      await e.persistir();
      expect(await e.trocarPersonagem('pj1'), isTrue);
      expect(e.save.moedas, moedasPrimeiro);
      expect(e.tarefasDeHoje.length, 1);
      expect(e.totalConcluidas, 1);
      expect(e.personagemAtivo.value, 'pj1');
      await e.trocarPersonagem(id2);
      expect(e.save.moedas, 99);
      // excluir o ativo é recusado; trocar e excluir apaga as chaves do herói
      expect(await e.excluirPersonagem(id2), isFalse);
      await e.trocarPersonagem('pj1');
      expect(await e.excluirPersonagem(id2), isTrue);
      expect(e.personagens.map((p) => p.id), ['pj1']);
      expect(arm.chaves().where((k) => k.endsWith('.pj.$id2')), isEmpty);
      expect(arm.ler(chaveSave()), isNotNull);
    });

    test('renomear e trocar o sprite gravam no save do herói ativo', () async {
      final arm = ArmazenamentoMemoria();
      final e = await _estado(arm);
      e.renomearHeroi('  Mira  ');
      e.escolherSprite(4);
      final s = jsonDecode(arm.ler(chaveSave())!) as Map;
      expect(s['nomeHeroi'], 'Mira');
      expect(s['heroi'], 4);
      e.renomearHeroi('');
      expect(e.save.nomeHeroi, 'Aventureiro');
      e.definirIdioma('en');
      expect(nomeHeroiNorm(e.save.nomeHeroi, e.idioma), 'Adventurer');
    });
  });

  group('tela do Perfil', () {
    Future<void> montar(WidgetTester t, EstadoJogo e) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      await t.pumpWidget(MaterialApp(theme: temaApp(), home: Scaffold(body: TelaPerfil(estado: e))));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
    }

    testWidgets('mostra nome, nível, vida/XP, conquistas e bestiário do herói', (t) async {
      final e = await _estado(ArmazenamentoMemoria());
      await montar(t, e);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Nível I'), findsWidgets);
      expect(find.text('Aventureiro'), findsOneWidget);
      expect(find.textContaining('40 / 40'), findsOneWidget);
      expect(find.textContaining('0 / 100'), findsOneWidget);
      expect(find.text('0 de 18 desbloqueadas'), findsOneWidget);
      expect(find.text('0 de 63 monstros derrotados'), findsOneWidget);
      expect(find.text('Ver todas'), findsOneWidget);
      expect(find.text('Ver tudo'), findsOneWidget);
      expect(find.text('?'), findsNWidgets(6)); // prévia vazia: seis casas com "?"
    });

    testWidgets('o idioma muda os textos do Perfil na hora', (t) async {
      final e = await _estado(ArmazenamentoMemoria());
      await montar(t, e);
      e.definirIdioma('en');
      await t.pump();
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Level I'), findsOneWidget);
      expect(find.text('0 of 18 unlocked'), findsOneWidget);
      expect(find.text('0 of 63 monsters defeated'), findsOneWidget);
      expect(find.text('Adventurer'), findsOneWidget);
    });


    Future<void> esp(WidgetTester t) async {
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
    }

    testWidgets('Bestiário e ficha do monstro escondido abrem sem erro', (t) async {
      final e = await _estado(ArmazenamentoMemoria());
      await montar(t, e);
      await t.tap(find.text('Ver tudo'));
      await esp(t);
      expect(find.text('0 de 63 monstros derrotados'), findsWidgets);
      await t.tapAt(const Offset(58, 150));
      await esp(t);
      expect(find.text('?'), findsWidgets);
    });

    testWidgets('Grimório: catálogo e ficha de item escondido abrem sem erro', (t) async {
      final e = await _estado(ArmazenamentoMemoria());
      await montar(t, e);
      abrirCatalogoGrimorio(t.element(find.byType(TelaPerfil)), e);
      await esp(t);
      expect(find.textContaining('itens descobertos'), findsOneWidget);
      abrirFichaGrimorioOculto(t.element(find.byType(TelaPerfil, skipOffstage: false)), e, 1);
      await esp(t);
      expect(find.text('?'), findsWidgets);
    });

    testWidgets('Configurações: tela principal e sub-telas abrem sem erro', (t) async {
      final e = await _estado(ArmazenamentoMemoria());
      await montar(t, e);
      await t.tap(find.byType(IconeSvg).first);
      await esp(t);
      expect(find.text('Configurações'), findsOneWidget);
      for (final (linha, titulo) in [('Heróis', 'PERSONAGENS'), ('Aparência', 'Branco'), ('Preferências', 'EXPERIÊNCIA'), ('Conta', 'ID da conta')]) {
        await t.tap(find.text(linha));
        await esp(t);
        expect(find.text(titulo), findsWidgets, reason: linha);
        await t.tapAt(const Offset(34, 32));
        await esp(t);
      }
    });

    testWidgets('Conquistas: abre a tela, lista as 18 e marca como vistas', (t) async {
      final e = await _estado(ArmazenamentoMemoria());
      e.criarTarefa(texto: 'x', modo: ModoTarefa.hoje, dif: 'media');
      e.concluir(e.tarefasDeHoje.first);
      await montar(t, e);
      expect(e.conquistasNaoVistas, greaterThan(0));
      await t.tap(find.text('Ver todas'));
      await t.pumpAndSettle();
      expect(find.text('MINHAS CONQUISTAS'), findsOneWidget);
      expect(find.text('Primeira Vitória'), findsOneWidget);
      expect(find.text('NOVO'), findsWidgets);
      expect(e.conquistasNaoVistas, 0);
    });
  });
}
