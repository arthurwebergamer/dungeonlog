// Testes da aba Tarefas: estado do jogo (regras da Fase 1) e uma passada pela tela.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/ui/app.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:dungeonlog_flutter/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DadosJogo carregarDados() {
  String l(String n) => File('assets/dados/$n.json').readAsStringSync();
  return DadosJogo.deTextos(monstros: l('monstros'), herois: l('herois'), temas: l('temas_arena'), itens: l('itens'), traducoes: l('traducoes'));
}

Future<EstadoJogo> novoEstado(ArmazenamentoMemoria arm, {DateTime? agora}) async {
  final relogio = agora ?? DateTime(2026, 11, 11, 10);
  final e = EstadoJogo(dados: carregarDados(), armazenamento: arm, agora: () => relogio, aleatorio: Random(1));
  await e.iniciar();
  return e;
}

void main() {
  test('jogo novo: sem tarefas, vida cheia e save v3 gravado', () async {
    final arm = ArmazenamentoMemoria();
    final e = await novoEstado(arm);
    expect(e.tarefasDeHoje, isEmpty);
    expect(e.nivel, 1);
    expect(e.vida, 40);
    expect(e.save.moedas, 0);
    final salvo = jsonDecode(arm.ler(chaveSave())!) as Map<String, dynamic>;
    expect(salvo['versao'], 3);
    expect(salvo['comecou'], true);
    expect(salvo['afixos'], 2);
    expect(arm.ler('questlog.vida.v1.pj.pj1'), isNotNull);
  });

  test('criar e concluir tarefa: XP e moedas como no JS (média = 42 XP e 4 moedas)', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    expect(e.criarTarefa(texto: '  Ler  ', modo: ModoTarefa.hoje, dif: 'media'), isTrue);
    final t = e.tarefasDeHoje.single;
    expect(t.texto, 'Ler');
    final g = e.concluir(t)!;
    expect((g.xp, g.moedas, g.parcial), (42, 4, false));
    expect(e.save.xpTotal, 42);
    expect(e.save.moedas, 4);
    expect(e.feitaHoje(t), isTrue);
    expect(e.totalConcluidas, 1);
    expect(e.concluir(t), isNull, reason: 'concluída não conclui de novo');
  });

  test('o resto de moeda passa para a próxima tarefa (4,5 + 0,5 = 5)', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    for (final n in ['a', 'b']) {
      e.criarTarefa(texto: n, modo: ModoTarefa.hoje, dif: 'media');
    }
    final ts = e.tarefasDeHoje;
    expect(e.concluir(ts[0])!.moedas, 4);
    expect(e.concluir(ts[1])!.moedas, 5);
  });

  test('a partir da 11ª tarefa do dia o XP cai pela metade', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    for (var i = 0; i < 11; i++) {
      e.criarTarefa(texto: 't$i', modo: ModoTarefa.hoje, dif: 'media');
    }
    final xps = [for (final t in e.tarefasDeHoje) e.concluir(t)!.xp];
    expect(xps.take(10), everyElement(42));
    expect(xps.last, 21);
  });

  test('tarefa com meta 3: toques parciais dividem o ganho e só o último conclui', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    e.criarTarefa(texto: 'Água', modo: ModoTarefa.hoje, dif: 'media', meta: 3);
    final t = e.tarefasDeHoje.single;
    final a = e.concluir(t)!, b = e.concluir(t)!;
    expect((a.parcial, b.parcial, a.xp), (true, true, 14));
    expect(e.feitaHoje(t), isFalse);
    expect(e.totalConcluidas, 0, reason: 'parcial não conta para o estágio');
    final c = e.concluir(t)!;
    expect((c.parcial, c.xp), (false, 14));
    expect(e.feitaHoje(t), isTrue);
    expect(e.totalConcluidas, 1);
  });

  test('terminar dia: derrota o monstro, paga a vitória e bloqueia novas tarefas', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    expect(e.podeTerminarDia, isFalse);
    e.criarTarefa(texto: 'a', modo: ModoTarefa.hoje, dif: 'facil');
    e.criarTarefa(texto: 'b', modo: ModoTarefa.hoje, dif: 'facil');
    e.concluir(e.tarefasDeHoje[0]);
    expect(e.podeTerminarDia, isFalse, reason: 'ainda há pendente');
    e.concluir(e.tarefasDeHoje[1]);
    expect(e.podeTerminarDia, isTrue);
    final antes = e.save.moedas;
    expect(e.terminarDia(), 26, reason: '16 + 5 x 2 tarefas');
    expect(e.save.moedas, antes + 26);
    expect(e.derrotado, isTrue);
    expect(e.podeTerminarDia, isFalse);
    expect(e.criarTarefa(texto: 'c', modo: ModoTarefa.hoje, dif: 'facil'), isFalse);
  });

  test('o save reabre igual (mesmo armazenamento)', () async {
    final arm = ArmazenamentoMemoria();
    final e1 = await novoEstado(arm);
    e1.criarTarefa(texto: 'Treinar', modo: ModoTarefa.repete, dif: 'dificil', dias: [0, 1, 2, 3, 4, 5, 6]);
    e1.concluir(e1.tarefasDeHoje.single);
    final e2 = await novoEstado(arm);
    expect(e2.save.xpTotal, e1.save.xpTotal);
    expect(e2.save.moedas, e1.save.moedas);
    expect(e2.save.semente, e1.save.semente);
    expect(e2.tarefasDeHoje.single.texto, 'Treinar');
    expect(e2.feitaHoje(e2.tarefasDeHoje.single), isTrue);
    expect(e2.totalConcluidas, 1);
  });

  test('virada do dia: tarefa difícil largada tira 14 de vida e avisa', () async {
    final arm = ArmazenamentoMemoria();
    arm.dados[chaveSave()] = jsonEncode({
      'versao': 3, 'afixos': 2, 'comecou': true, 'semente': 5,
      'tarefas': [
        {'texto': 'Treinar', 'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6], 'feitaEm': null, 'dif': 'dificil'}
      ],
    });
    arm.dados['questlog.vida.v1.pj.pj1'] = jsonEncode({'vida': 40, 'ultimoDia': '2026-11-10'});
    final e = await novoEstado(arm);
    expect(e.vida, 26, reason: '6 x 2,25 = 13,5 -> 14');
    final ev = e.consumirEvento()!;
    expect((ev.largadas, ev.dano, ev.caiu), (1, 14, false));
    expect(e.ultimoDia, '2026-11-11');
    expect(e.consumirEvento(), isNull);
  });

  test('apagar só hoje pula a tarefa recorrente neste dia; apagar todas remove', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    e.criarTarefa(texto: 'Diária', modo: ModoTarefa.repete, dif: 'facil', dias: [0, 1, 2, 3, 4, 5, 6]);
    e.criarTarefa(texto: 'Única', modo: ModoTarefa.hoje, dif: 'facil');
    e.apagarTarefa(e.tarefasDeHoje.first, soHoje: true);
    expect(e.tarefasDeHoje.map((t) => t.texto), ['Única']);
    expect(e.save.tarefas.length, 2, reason: 'a diária continua existindo, só pulada hoje');
    e.apagarTarefa(e.tarefasDeHoje.single);
    expect(e.save.tarefas.length, 1);
  });

  test('recusa tarefa sem texto ou sem dias', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    expect(e.criarTarefa(texto: '   ', modo: ModoTarefa.hoje, dif: 'media'), isFalse);
    expect(e.criarTarefa(texto: 'x', modo: ModoTarefa.repete, dif: 'media'), isFalse);
  });

  testWidgets('tela: criar uma tarefa, concluir e ver o ganho', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late EstadoJogo e;
    await tester.runAsync(() async => e = await novoEstado(ArmazenamentoMemoria()));
    await tester.pumpWidget(MaterialApp(theme: temaApp(), home: Casca(estado: e)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Nenhuma tarefa para hoje.\nToque em Adicionar para criar a primeira.'), findsOneWidget);

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Estudar');
    await tester.pump();
    await tester.tap(find.text('Criar tarefa'));
    await tester.pumpAndSettle();
    expect(find.text('Estudar'), findsOneWidget);

    await tester.tap(find.text('Estudar'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('+42 XP'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Terminar dia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
