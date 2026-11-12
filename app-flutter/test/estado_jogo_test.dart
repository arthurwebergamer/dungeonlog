// Testes da aba Tarefas: estado do jogo (regras da Fase 1) e uma passada pela tela.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/dominio/tarefa.dart';
import 'package:dungeonlog_flutter/ui/app.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:dungeonlog_flutter/ui/folha_nova_tarefa.dart';
import 'package:dungeonlog_flutter/ui/tela_tarefas.dart';
import 'package:dungeonlog_flutter/ui/tela_inventario.dart';
import 'package:dungeonlog_flutter/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Carrega as fontes reais do app (sem isso o teste usa a fonte quadrada de teste, bem mais larga que a Outfit).
Future<void> carregarFontes() async {
  Future<void> familia(String nome, List<String> arquivos) async {
    final l = FontLoader(nome);
    for (final a in arquivos) {
      l.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$a').readAsBytesSync())));
    }
    await l.load();
  }

  await familia('Outfit', ['Outfit-Regular.ttf', 'Outfit-Medium.ttf', 'Outfit-SemiBold.ttf', 'Outfit-Bold.ttf']);
  await familia('Silkscreen', ['Silkscreen-Regular.ttf']);
}

void main() {
  setUpAll(carregarFontes);

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

  test('editar tarefa muda texto, dificuldade e meta (e ajusta as vezes já feitas)', () async {
    final arm = ArmazenamentoMemoria();
    final e = await novoEstado(arm);
    e.criarTarefa(texto: 'Água', modo: ModoTarefa.hoje, dif: 'facil', meta: 4);
    final t = e.tarefasDeHoje.single;
    e.concluir(t);
    e.concluir(t);
    expect(e.editarTarefa(t, texto: '  Beber água  ', dif: 'dificil', meta: 2), isTrue);
    expect((t.texto, t.dif, t.meta, t.dados['vezesN']), ('Beber água', 'dificil', 2, 2));
    expect(e.editarTarefa(t, texto: ' ', dif: 'facil', meta: 1), isFalse);
    final e2 = await novoEstado(arm);
    expect(e2.tarefasDeHoje.single.texto, 'Beber água');
  });

  test('recusa tarefa sem texto ou sem dias', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    expect(e.criarTarefa(texto: '   ', modo: ModoTarefa.hoje, dif: 'media'), isFalse);
    expect(e.criarTarefa(texto: 'x', modo: ModoTarefa.repete, dif: 'media'), isFalse);
  });

  test('reordenar: grava "ordem" de 10 em 10 nas pendentes e a lista segue essa ordem', () async {
    final arm = ArmazenamentoMemoria();
    final e = await novoEstado(arm);
    for (final n in ['a', 'b', 'c']) {
      e.criarTarefa(texto: n, modo: ModoTarefa.hoje, dif: 'media');
    }
    expect(e.pendentesDeHoje.map((t) => t.texto), ['a', 'b', 'c']);
    e.reordenar(2, 0);
    expect(e.pendentesDeHoje.map((t) => t.texto), ['c', 'a', 'b']);
    expect(e.pendentesDeHoje.map((t) => t.dados['ordem']), [0, 10, 20]);
    e.reordenar(0, 5); // fora da lista: nada muda
    expect(e.pendentesDeHoje.map((t) => t.texto), ['c', 'a', 'b']);
    // concluída sai das pendentes; a ordem sobrevive ao recarregar
    e.concluir(e.pendentesDeHoje.first);
    expect(e.pendentesDeHoje.map((t) => t.texto), ['a', 'b']);
    final e2 = await novoEstado(arm);
    expect(e2.pendentesDeHoje.map((t) => t.texto), ['a', 'b']);
    // tarefa nova (sem "ordem") entra pela posição no save x 10, como no JS
    e2.criarTarefa(texto: 'd', modo: ModoTarefa.hoje, dif: 'media');
    expect(e2.pendentesDeHoje.map((t) => t.texto), ['a', 'b', 'd']);
  });

  test('descanso: liga e desliga o dia, grava a lista e concluir tarefa cancela', () async {
    final arm = ArmazenamentoMemoria();
    final e = await novoEstado(arm);
    e.criarTarefa(texto: 'a', modo: ModoTarefa.hoje, dif: 'media');
    expect(e.descansando, isFalse);
    e.definirDescanso(true);
    e.definirDescanso(true); // não duplica a data
    expect(e.descansando, isTrue);
    expect(jsonDecode(arm.ler('questlog.descanso.v1.pj.pj1')!), [e.hoje]);
    expect(e.podeTerminarDia, isFalse);
    e.definirDescanso(false);
    expect(e.descansando, isFalse);
    expect(jsonDecode(arm.ler('questlog.descanso.v1.pj.pj1')!), isEmpty);
    e.definirDescanso(true);
    e.concluir(e.tarefasDeHoje.single);
    expect(e.descansando, isFalse, reason: 'concluir tarefa cancela o descanso do dia');
    // depois que o monstro cai não dá mais para descansar (o botão some no original)
    e.terminarDia();
    e.definirDescanso(true);
    expect(e.descansando, isFalse);
  });

  test('rótulo de repetição e numeral romano como no original', () {
    expect(rotuloTarefa(Tarefa({'tipo': 'hoje'})), 'só hoje');
    expect(rotuloTarefa(Tarefa({'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6]})), 'todo dia');
    expect(rotuloTarefa(Tarefa({'tipo': 'repete', 'dias': [3, 1]})), 'seg, qua');
    expect(rotuloTarefa(Tarefa({'tipo': 'mensal', 'diaMes': 12})), 'todo dia 12');
    expect(rotuloTarefa(Tarefa({'tipo': 'anual', 'diaAno': 12, 'mesAno': 11})), '12 de nov');
    expect([1, 2, 4, 9, 14, 40].map(romano), ['I', 'II', 'IV', 'IX', 'XIV', 'XL']);
  });


  test('vencer o dia gera o baú: itens vão para o inventário e abrir só vale uma vez', () async {
    final arm = ArmazenamentoMemoria();
    final e = await novoEstado(arm);
    expect(e.bauPadraoFechado, isFalse);
    e.criarTarefa(texto: 'a', modo: ModoTarefa.hoje, dif: 'facil');
    e.concluir(e.tarefasDeHoje.single);
    e.terminarDia();
    expect(e.bauPadraoFechado, isTrue);
    final total = e.save.inventario.fold<int>(0, (a, sl) => a + (sl['q'] as int));
    expect(total, inInclusiveRange(1, 2), reason: 'estágio 1: 1 item (+ tesouro extra só com Tesoureiro)');
    final itens = e.abrirBauPadrao()!;
    expect(itens.length, total);
    expect(e.bauPadraoFechado, isFalse);
    expect(e.abrirBauPadrao(), isNull);
    final e2 = await novoEstado(arm);
    expect(e2.bauPadraoFechado, isFalse, reason: 'o estado do baú é salvo');
    expect(e2.save.inventario.length, e.save.inventario.length);
  });

  test('equipar, usar e vender', () async {
    final e = await novoEstado(ArmazenamentoMemoria());
    final cat = e.catalogo;
    final arma = [for (var i = 0; i < cat.baseN; i++) if (cat.item(i)!.tipo == 'arma' && !cat.item(i)!.morto) i].first;
    final pocao = [for (var i = 0; i < cat.baseN; i++) if (cat.item(i)!.tipo == 'cons' && cat.item(i)!.cura > 0 && !cat.item(i)!.morto) i].first;
    e.save.inventario.addAll([
      {'id': arma, 'q': 1},
      {'id': pocao, 'q': 2},
    ]);
    expect(e.equipar(arma), isTrue);
    expect(e.equipado(arma), isTrue);
    expect(e.equipar(arma), isFalse, reason: 'tocar de novo desequipa');
    expect(e.equipar(arma), isTrue);
    e.vida = 5;
    e.usarItem(pocao);
    expect(e.vida, greaterThan(5));
    expect(e.quantidadeDe(pocao), 1);
    final moedas = e.save.moedas;
    final preco = e.venderItem(arma)!;
    expect(e.save.moedas, moedas + preco);
    expect(e.quantidadeDe(arma), 0);
    expect(e.equipado(arma), isFalse, reason: 'vender a última cópia desequipa');
    expect(e.venderItem(arma), isNull);
  });

  testWidgets('tela: inventário mostra itens e abre a ficha sem estourar o layout', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late EstadoJogo e;
    await tester.runAsync(() async => e = await novoEstado(ArmazenamentoMemoria()));
    final cat = e.catalogo;
    final arma = [for (var i = 0; i < cat.baseN; i++) if (cat.item(i)!.tipo == 'arma' && !cat.item(i)!.morto) i].first;
    e.save.inventario.add({'id': arma, 'q': 1});
    e.equipar(arma);
    await tester.pumpWidget(MaterialApp(theme: temaApp(), home: Scaffold(body: TelaInventario(estado: e))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Inventário'), findsOneWidget);
    await tester.tap(find.byType(SpriteItem).last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Desequipar'), findsOneWidget);
    expect(find.textContaining('Vender por'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tela: criar uma tarefa, concluir e ver o ganho', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late EstadoJogo e;
    await tester.runAsync(() async => e = await novoEstado(ArmazenamentoMemoria()));
    await tester.pumpWidget(MaterialApp(theme: temaApp(), home: Casca(estado: e)));
    // a arena tem animações em laço (tochas, herói): os testes avançam o relógio com pump() em vez de pumpAndSettle()
    Future<void> esperar([int ms = 600]) async {
      await tester.pump();
      await tester.pump(Duration(milliseconds: ms));
    }

    await esperar(300);
    expect(find.textContaining('está à espreita.\nAdicione tarefas para encarar.'), findsOneWidget);
    expect(find.text('Nível I'), findsOneWidget);
    expect(find.text('0 de 0 concluídas'), findsOneWidget);

    await tester.tap(find.text('+ Adicionar'));
    await esperar();
    await tester.enterText(find.byType(TextField), 'Estudar');
    await tester.pump();
    await tester.tap(find.text('Criar tarefa'));
    await esperar();
    expect(find.text('Estudar'), findsOneWidget);
    expect(find.text('só hoje'), findsOneWidget);

    // tocar no corpo do cartão abre o editor (como no original); concluir é só pela caixa
    await tester.tap(find.text('Estudar'));
    await esperar();
    expect(find.text('Salvar alterações'), findsOneWidget);
    await tester.tapAt(const Offset(195, 40)); // fora da folha: fecha
    await esperar();
    expect(find.text('Salvar alterações'), findsNothing);

    await tester.tap(find.byType(CaixaTarefa));
    await esperar(400); // caixa verde (80 ms) + saída do cartão (200 ms)
    expect(find.textContaining('+42 XP'), findsOneWidget);
    expect(find.text('Estudar'), findsNothing, reason: 'concluída sai da lista');
    expect(find.text('1 de 1 concluídas'), findsOneWidget);
    await esperar(2000);
    expect(find.text('Terminar dia'), findsOneWidget);

    await tester.tap(find.text('Terminar dia'));
    await esperar();
    expect(find.textContaining('derrotado'), findsWidgets);
    await tester.tap(find.text('Continuar'));
    await esperar();
    expect(find.text('DIA VENCIDO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tela: o X apaga direto a tarefa de um dia e pergunta na que se repete', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late EstadoJogo e;
    await tester.runAsync(() async => e = await novoEstado(ArmazenamentoMemoria()));
    e.criarTarefa(texto: 'Avulsa', modo: ModoTarefa.hoje, dif: 'media');
    e.criarTarefa(texto: 'Diária', modo: ModoTarefa.repete, dif: 'media', dias: [0, 1, 2, 3, 4, 5, 6], meta: 4);
    await tester.pumpWidget(MaterialApp(theme: temaApp(), home: Casca(estado: e)));
    Future<void> esperar([int ms = 600]) async {
      await tester.pump();
      await tester.pump(Duration(milliseconds: ms));
    }

    await esperar(300);
    expect(find.text('todo dia'), findsOneWidget);
    expect(find.text('0/4'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Apagar tarefa').first);
    await esperar();
    expect(find.text('Avulsa'), findsNothing);
    expect(e.save.tarefas.length, 1);

    await tester.tap(find.bySemanticsLabel('Apagar tarefa').first);
    await esperar();
    expect(find.text('Essa tarefa se repete (todo dia). Apagar só hoje ou em todos os dias?'), findsOneWidget);
    await tester.tap(find.text('Só hoje'));
    await esperar();
    expect(find.text('Diária'), findsNothing);
    expect(e.save.tarefas.single.dados['pulaEm'], [e.hoje], reason: 'só hoje: a tarefa fica no save e pula o dia');

    // descanso: a lua abre a confirmação e o subtítulo muda
    await tester.tap(find.bySemanticsLabel('Descansar'));
    await esperar();
    await tester.tap(find.text('Descansar hoje'));
    await esperar();
    expect(e.descansando, isTrue);
    expect(find.text('Descansando hoje — progresso protegido'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
