// Paridade das conquistas V2, da sequência de vitórias, do histórico e do nível do Grimório contra o JS
// (casos de tools/gerar_casos_js.mjs: as funções reais do index.html rodando num sandbox).
import 'dart:convert';
import 'dart:io';

import 'package:dungeonlog_flutter/dominio/catalogo.dart';
import 'package:dungeonlog_flutter/dominio/conquistas.dart';
import 'package:dungeonlog_flutter/dominio/historico.dart';
import 'package:dungeonlog_flutter/dominio/regras.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final casos = jsonDecode(File('test/fixtures/casos_js.json').readAsStringSync()) as Map<String, dynamic>;
  final linhas = ((jsonDecode(File('assets/dados/itens.json').readAsStringSync()) as Map)['linhas'] as List)
      .map((l) => List<dynamic>.from(l as List))
      .toList();
  final cat = Catalogo.deLinhas(linhas);
  final idGrim = idGrimorioDe(cat);

  test('definições: ids, nomes, cores e textos iguais ao JS', () {
    final defs = (casos['conquistasDefs'] as List).cast<Map<String, dynamic>>();
    expect(defs.length, 18);
    expect([for (final c in conquistasV2) c.id], casos['conquistasIds']);
    for (var i = 0; i < defs.length; i++) {
      final d = defs[i], c = conquistasV2[i];
      expect(c.id, d['id']);
      expect(c.nome, d['nome'], reason: c.id);
      expect(c.nomeEn, d['nome_en'], reason: c.id);
      expect('#${c.cor.toRadixString(16).toUpperCase()}', d['cor'], reason: c.id);
    }
  });

  test('o id do Grimório e os níveis de entrega', () {
    final g = casos['grimorio'] as Map<String, dynamic>;
    expect(idGrim, g['idGrimorio']);
    for (final n in (g['niveis'] as List).cast<Map<String, dynamic>>()) {
      expect(nivelDoGrimorio(n['s'] as num), n['nivel'], reason: 'semente ${n['s']}');
    }
  });

  final lista = (casos['conquistas'] as List).cast<Map<String, dynamic>>();
  test('250 casos nos fixtures', () => expect(lista.length, 250));
  for (var n = 0; n < lista.length; n++) {
    final c = lista[n];
    test('conquistas #$n', () {
      final hist = [for (final h in (c['hist'] as List)) EntradaHist.deJson(h)!];
      final vistos = {for (final v in (c['vistos'] as List)) (v as num).toInt()};
      expect(melhorSequenciaDeVitorias(hist), c['seq'], reason: 'sequência');
      for (final comHoje in [true, false]) {
        final ctx = montarContextoConq(
          hist: hist,
          hoje: '2026-11-11',
          monstroDeHojeSeVencido: comHoje && c['venceu'] == true ? (c['idxHoje'] as num).toInt() : null,
          totalMonstros: 63,
          nivel: progresso(c['xp'] as num).nivel,
          tarefasConcluidas: (c['total'] as num).toInt(),
          vistos: vistos,
          catalogo: cat,
          idGrimorio: idGrim,
        );
        final j = (comHoje ? c['ctx'] : c['ctxSem']) as Map<String, dynamic>;
        expect(ctx.melhorSequencia, j['melhorSequencia'], reason: 'melhorSequencia hoje=$comHoje');
        expect(ctx.totalMortos, j['totalMortos'], reason: 'totalMortos hoje=$comHoje');
        expect(ctx.distintosMortos, j['distintosMortos'], reason: 'distintosMortos hoje=$comHoje');
        expect(ctx.totalMonstrosCatalogo, j['totalMonstrosCatalogo']);
        expect(ctx.nivel, j['nivel']);
        expect(ctx.tarefasConcluidas, j['tarefasConcluidas']);
        expect(ctx.itensVistos, j['itensVistos']);
        expect(ctx.raridadesObtidas, j['raridadesObtidas']);
        expect(ctx.temGrimorio, j['temGrimorio']);
        expect(ctx.totalItensCatalogo, j['totalItensCatalogo']);
        if (comHoje) {
          final res = (c['resolvidas'] as List).cast<Map<String, dynamic>>();
          for (var i = 0; i < res.length; i++) {
            final q = conquistasV2[i];
            expect(q.id, res[i]['id']);
            expect(q.meta(ctx), res[i]['meta'], reason: '${q.id} meta');
            expect(q.valor(ctx), res[i]['valor'], reason: '${q.id} valor');
            expect(q.req(ctx), res[i]['req'], reason: '${q.id} req');
            expect(q.reqEn(ctx), res[i]['req_en'], reason: '${q.id} req_en');
          }
        }
      }
    });
  }

  group('histórico (regras próprias)', () {
    test('resultado do dia', () {
      expect(resultadoDoDia(descanso: true, totalTarefas: 3, largadas: 1), 'descanso');
      expect(resultadoDoDia(descanso: false, totalTarefas: 0, largadas: 0), 'sem_tarefa');
      expect(resultadoDoDia(descanso: false, totalTarefas: 3, largadas: 1), 'fuga');
      expect(resultadoDoDia(descanso: false, totalTarefas: 3, largadas: 0), 'vitoria');
    });
    test('bestiário: vitórias distintas e o monstro de hoje', () {
      final h = [
        const EntradaHist(data: '2026-11-01', resultado: 'vitoria', monstroId: 4, tarefas: 2),
        const EntradaHist(data: '2026-11-02', resultado: 'fuga', monstroId: 5, tarefas: 2),
        const EntradaHist(data: '2026-11-03', resultado: 'vitoria', monstroId: 4, tarefas: 2),
      ];
      expect(monstrosDerrotados(h), {4});
      expect(monstrosDerrotados(h, monstroDeHojeSeVencido: 9), {4, 9});
      final f = fichaDoMonstro(h, 4);
      expect(f.vezes, 2);
      expect(f.primeira, '2026-11-01');
      expect(formatarDataBR('2026-11-01'), '01/11/2026');
      expect(formatarDataBR(null), '—');
    });
    test('prévia: últimos monstros vistos, sem repetir, do mais recente', () {
      final h = [
        const EntradaHist(data: '2026-11-01', resultado: 'vitoria', monstroId: 1, tarefas: 1),
        const EntradaHist(data: '2026-11-03', resultado: 'vitoria', monstroId: 2, tarefas: 1),
        const EntradaHist(data: '2026-11-04', resultado: 'vitoria', monstroId: 1, tarefas: 1),
      ];
      expect(ultimosMonstrosVistos(h, hoje: '2026-11-10'), [1, 2]);
      expect(ultimosMonstrosVistos(h, hoje: '2026-11-10', monstroDeHojeSeVencido: 7), [7, 1, 2]);
    });
  });
}
