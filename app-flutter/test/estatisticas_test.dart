// Fase 4: a aba Estatísticas (tela, bloqueio Pro, abas, ano, popup da sequência), o cartão de compartilhar e a linha
// "Sequência" do resumo do dia. As regras (sequência, taxa, mapas...) têm paridade contra o JS em
// estatisticas_paridade_test.dart.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/historico.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/dominio/tarefa.dart';
import 'package:dungeonlog_flutter/ui/cartao_sequencia.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:dungeonlog_flutter/ui/popups_md.dart';
import 'package:dungeonlog_flutter/ui/sheet_md.dart' show FilaPopups;
import 'package:dungeonlog_flutter/ui/tela_estatisticas.dart';
import 'package:dungeonlog_flutter/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DadosJogo _dados() {
  String l(String n) => File('assets/dados/$n.json').readAsStringSync();
  return DadosJogo.deTextos(monstros: l('monstros'), herois: l('herois'), temas: l('temas_arena'), itens: l('itens'), traducoes: l('traducoes'));
}

/// 11/11/2026: vitórias em 08, 09 e 10 (fuga em 07) e as tarefas de hoje todas feitas (hoje conta ao vivo): sequência 4.
Future<EstadoJogo> _estado({bool hojeFeito = true, bool comHist = true, String idioma = 'pt'}) async {
  final arm = ArmazenamentoMemoria();
  final save = SaveV3(
    nomeHeroi: 'Teste',
    semente: 5,
    tarefas: [
      Tarefa({'texto': 'a', 'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6], 'feitaEm': hojeFeito ? '2026-11-11' : null, 'dif': 'media', 'meta': 1}),
    ],
  );
  await arm.gravar(chaveSave(), jsonEncode(save.paraJson(_dados().catalogo, salvoEm: 1)));
  await arm.gravar(chaveConta('questlog.vida.v1'), jsonEncode({'vida': 40, 'ultimoDia': '2026-11-11'}));
  await arm.gravar(chaveConta('questlog.estagioCerimoniaMostrada.v1'), '9');
  if (comHist) {
    await arm.gravar(chaveConta('questlog.tarefasConcluidas.v1'), '25');
    await arm.gravar(
      chaveConta('questlog.hist.v1'),
      gravarHistorico([
        for (final (d, r) in [('2026-11-07', 'fuga'), ('2026-11-08', 'vitoria'), ('2026-11-09', 'vitoria'), ('2026-11-10', 'vitoria')])
          EntradaHist(data: d, resultado: r, monstroId: 1, tarefas: 2),
      ]),
    );
  }
  final e = EstadoJogo(dados: _dados(), armazenamento: arm, agora: () => DateTime(2026, 11, 11, 10), idioma: idioma);
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
    reiniciarEstadoEstatisticas();
    Paleta.atual = Paleta.grafite;
  });
  setUpAll(_fontes);

  Future<void> montar(WidgetTester t, EstadoJogo e) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(MaterialApp(theme: temaApp(), home: Scaffold(body: TelaEstatisticas(estado: e))));
    await t.pump();
    await t.pump(const Duration(milliseconds: 1200));
  }

  group('estado', () {
    test('hoje entra ao vivo no histórico: tarefas feitas viram vitória e a sequência soma 1', () async {
      final e = await _estado();
      expect(e.hist.length, 4);
      expect(e.histAoVivo.length, 5);
      expect(e.sequenciaAtual, 4);
    });
    test('com tarefa pendente hoje ainda não conta; a sequência vem de ontem', () async {
      final e = await _estado(hojeFeito: false);
      expect(e.histAoVivo.length, 4);
      expect(e.sequenciaAtual, 3);
    });
    test('sem histórico: sequência 0', () async {
      final e = await _estado(hojeFeito: false, comHist: false);
      expect(e.sequenciaAtual, 0);
    });
    test('ehPro é o ponto de ligação da Fase 7 e começa falso', () async {
      expect((await _estado()).ehPro, false);
    });
  });

  group('tela', () {
    testWidgets('mostra título, mês, sequência, "desde o início" e as abas (Mensal por padrão)', (t) async {
      final e = await _estado();
      await montar(t, e);
      expect(find.text('Estatísticas'), findsOneWidget);
      expect(find.text('Novembro de 2026'), findsOneWidget);
      expect(find.text('SEQUÊNCIA ATUAL'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('DESDE O INÍCIO'), findsOneWidget);
      expect(find.text('25'), findsWidgets); // o total e o tile do dia 25
      expect(find.text('tarefas concluídas'), findsOneWidget);
      expect(find.text('dias vencidos'), findsOneWidget);
      expect(find.text('taxa geral'), findsOneWidget);
      expect(find.text('Semanal'), findsOneWidget);
      expect(find.text('Mensal'), findsOneWidget);
      expect(find.text('Anual'), findsOneWidget);
      expect(find.text('HISTÓRICO'), findsOneWidget);
      expect(find.text('· MÊS'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('sem ser Pro: taxa, composição e histórico ficam trancados (selo PRO) e tocar avisa', (t) async {
      final e = await _estado();
      await montar(t, e);
      expect(find.text('PRO'), findsNWidgets(3));
      await t.tap(find.text('PRO').first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Disponível em breve'), findsOneWidget);
      await t.tap(find.text('Entendi'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Disponível em breve'), findsNothing);
    });

    testWidgets('sendo Pro: some o bloqueio e aparecem taxa (100%), composição e o mapa do mês', (t) async {
      final e = await _estado();
      e.ehPro = true;
      await montar(t, e);
      expect(find.text('PRO'), findsNothing);
      expect(find.text('80%'), findsWidgets); // no mês: vitórias em 08, 09, 10 e hoje (ao vivo) e a fuga de 07 = 4 de 5
      expect(find.text('MÊS'), findsOneWidget);
      expect(find.text('COMO FOI O MÊS'), findsOneWidget);
      expect(find.text('venceu'), findsWidgets);
      expect(find.text('30'), findsOneWidget); // novembro tem 30 dias: o último tile
      expect(find.text('31'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('abas Semanal e Anual (com navegação de ano; o ano de hoje não avança)', (t) async {
      final e = await _estado();
      e.ehPro = true;
      await montar(t, e);
      await t.tap(find.text('Semanal'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1300));
      expect(find.text('ÚLTIMOS 7 DIAS'), findsOneWidget);
      expect(find.text('· SEMANA'), findsOneWidget);
      expect(find.text('qua'), findsOneWidget); // 11/11/2026 é quarta, o último rótulo
      expect(find.text('COMO FOI O MÊS'), findsNothing);
      await t.tap(find.text('Anual'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('· ANO'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('jan'), findsOneWidget);
      expect(find.text('dez'), findsOneWidget);
      final centro = t.getCenter(find.text('2026'));
      await t.tapAt(centro + const Offset(52, 0)); // "próximo ano": desabilitado no ano de hoje
      await t.pump();
      expect(find.text('2026'), findsOneWidget);
      await t.tapAt(centro - const Offset(52, 0)); // "ano anterior"
      await t.pump();
      expect(find.text('2025'), findsOneWidget);
      await t.tapAt(t.getCenter(find.text('2025')) + const Offset(52, 0));
      await t.pump();
      expect(find.text('2026'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('sem dados nenhum: tudo zerado, sem erro, em qualquer aba', (t) async {
      final e = await _estado(hojeFeito: false, comHist: false);
      e.ehPro = true;
      await montar(t, e);
      expect(find.text('0%'), findsWidgets);
      for (final aba in ['Semanal', 'Anual', 'Mensal']) {
        await t.tap(find.text(aba));
        await t.pump();
        await t.pump(const Duration(milliseconds: 1300));
        expect(t.takeException(), isNull, reason: aba);
      }
    });

    testWidgets('tela de 360 px de largura não estoura', (t) async {
      final e = await _estado();
      e.ehPro = true;
      await t.binding.setSurfaceSize(const Size(360, 740));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(MaterialApp(theme: temaApp(), home: Scaffold(body: TelaEstatisticas(estado: e))));
      await t.pump(const Duration(milliseconds: 1200));
      for (final aba in ['Semanal', 'Anual', 'Mensal']) {
        await t.tap(find.text(aba));
        await t.pump(const Duration(milliseconds: 1300));
      }
      expect(t.takeException(), isNull);
    });

    testWidgets('em inglês: rótulos e mês', (t) async {
      final e = await _estado(idioma: 'en');
      await montar(t, e);
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('CURRENT STREAK'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('tocar no cartão abre a folha da sequência (número, frase e Compartilhar)', (t) async {
      final e = await _estado();
      await montar(t, e);
      await t.tap(find.text('SEQUÊNCIA ATUAL'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1500));
      expect(find.text('Compartilhar'), findsOneWidget);
      // recorde 4 = sequência 4: "essa é a sua maior sequência"
      expect(find.textContaining('maior sequência'), findsOneWidget);
      await t.tap(find.text('×'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Compartilhar'), findsNothing);
    });

    testWidgets('frase da folha quando falta pouco para o recorde e quando não há sequência', (t) async {
      final e = await _estado(hojeFeito: false);
      // recorde 3 (08, 09, 10) e sequência 3 (ontem): é o recorde
      await montar(t, e);
      await t.tap(find.text('SEQUÊNCIA ATUAL'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1500));
      expect(find.textContaining('maior sequência'), findsOneWidget);
      await t.tap(find.text('×'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      final e2 = await _estado(hojeFeito: false, comHist: false);
      await montar(t, e2);
      await t.tap(find.text('SEQUÊNCIA ATUAL'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1500));
      expect(find.text('Vença hoje pra começar uma sequência'), findsOneWidget);
    });
  });

  group('cartão de compartilhar e resumo do dia', () {
    testWidgets('o cartão sai em PNG 810x1440 (9:16)', (t) async {
      for (final (streak, idioma) in [(32, 'pt'), (0, 'pt'), (1, 'en'), (7, 'pt')]) {
        late Uint8List png;
        await t.runAsync(() async => png = await gerarPngCartaoSequencia(streak: streak, nome: 'Teste', idioma: idioma));
        expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47], reason: 'assinatura PNG');
        late ui.Image img;
        await t.runAsync(() async => img = (await (await ui.instantiateImageCodec(png)).getNextFrame()).image);
        expect([img.width, img.height], [810, 1440]);
        final saida = Platform.environment['CARTAO_SAIDA'];
        if (saida != null) File('$saida/cartao_${streak}_$idioma.png').writeAsBytesSync(png);
      }
    });

    testWidgets('o resumo do dia traz a linha "Sequência" entre Experiência e o estágio', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final e = await _estado();
      late BuildContext ctx;
      await t.pumpWidget(MaterialApp(theme: temaApp(), home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold(body: SizedBox());
      })));
      final f = mostrarResumoDia(ctx, e, nTarefas: 1, ganho: 20);
      await t.pump();
      await t.pump(const Duration(milliseconds: 4000));
      expect(find.text('Sequência'), findsOneWidget);
      expect(find.text('4 dias'), findsOneWidget);
      final y = {for (final r in ['Experiência', 'Sequência', 'Rumo ao estágio 3']) r: t.getTopLeft(find.text(r)).dy};
      expect(y['Experiência']! < y['Sequência']!, true);
      expect(y['Sequência']! < y['Rumo ao estágio 3']!, true);
      await t.tap(find.text('Continuar'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      await f;
      expect(t.takeException(), isNull);
    });
  });
}
