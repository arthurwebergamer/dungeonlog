// Paridade da aba Estatísticas contra o JS (Fase 4). `tools/gerar_casos_js.mjs` roda as funções reais do index.html
// (estStreakAtual, estRecorde, estHistComHojeAoVivo, renderEstatisticas e os renders do gráfico, donut, mapa do mês,
// semana e ano) contra um DOM falso e grava o que elas escreveram em test/fixtures/casos_js.json. O Dart precisa dar o mesmo.
// O JS foi rodado em vários fusos horários e deu sempre o mesmo resultado; o Dart não depende do fuso (calendário civil).
import 'dart:convert';
import 'dart:io';

import 'package:dungeonlog_flutter/dominio/estatisticas.dart';
import 'package:dungeonlog_flutter/dominio/historico.dart';
import 'package:flutter_test/flutter_test.dart';

/// `color-mix`/`var()` do JS para o mesmo texto, a partir da mistura do Dart.
String _corJs(MisturaCor? m) {
  if (m == null) return 'var(--dim)';
  if (m.de == 'gold') return 'var(--gold)';
  return 'color-mix(in srgb, var(--${m.para}) ${m.pct}%, var(--${m.de}))';
}

String _classeTile(String? r) => switch (r) {
      resVitoria => 'est-tile est-tile-vitoria',
      resDescanso => 'est-tile est-tile-descanso',
      resFuga => 'est-tile est-tile-fuga',
      _ => 'est-tile',
    };

String _tocha(String? r) => switch (r) {
      resVitoria => 'est-tocha est-tocha-estatica|',
      resDescanso => 'est-tocha est-tocha-estatica est-tocha-descanso|',
      resFuga => 'est-tocha est-tocha-estatica est-tocha-apagada|',
      _ => '',
    };

String _tile(DiaMapa d) => '${_tocha(d.resultado)}${_tocha(d.resultado).isEmpty ? '' : ';'}est-tiledia|${d.dia}';

List<List<num>> _pares(String d) {
  final s = d.trim().substring(1).trim(); // tira o "M"
  if (s.isEmpty) return [];
  return [
    for (final p in s.split(RegExp(r'\s*L\s*')).where((x) => x.isNotEmpty)) [for (final n in p.split(',')) num.parse(n)]
  ];
}

double _alfa(String fill) => double.parse(RegExp(r'rgba\(255,255,255,([\d.]+)\)').firstMatch(fill)![1]!);

void main() {
  final casos = jsonDecode(File('test/fixtures/casos_js.json').readAsStringSync()) as Map<String, dynamic>;
  final est = casos['estatisticas'] as Map<String, dynamic>;
  final entradas = (est['casos'] as List).cast<Map<String, dynamic>>();
  final saidas = (est['saidas'] as List).cast<Map<String, dynamic>>();

  test('330 casos, em 10 fusos horários (o JS deu o mesmo resultado em todos)', () {
    expect(entradas.length, 330);
    expect(saidas.length, 330);
    expect((est['fusosConferidos'] as List).length, greaterThanOrEqualTo(9));
  });

  test('escala da tocha e cor do número da sequência', () {
    final t = est['tochas'] as Map<String, dynamic>;
    for (final e in (t['escala'] as List)) {
      expect(escalaTocha(e[0] as int), closeTo((e[1] as num).toDouble(), 1e-12), reason: 'escalaTocha(${e[0]})');
    }
    for (final e in (t['escalaCompartilhar'] as List)) {
      expect(escalaTochaCompartilhar(e[0] as int), closeTo((e[1] as num).toDouble(), 1e-12), reason: 'escalaTochaCompartilhar(${e[0]})');
    }
    for (final e in (t['cor'] as List)) {
      expect(_corJs(corDoStreak(e[0] as int)), e[1], reason: 'corDoStreak(${e[0]})');
    }
  });

  for (var n = 0; n < entradas.length; n++) {
    final c = entradas[n];
    final s = saidas[n];
    test('estatísticas #$n (${c['hoje']}, ${c['periodo']}, ${c['lang']}${c['descanso'] == true ? ', descanso' : ''})', () {
      final hoje = c['hoje'] as String;
      final hist = [for (final h in (c['hist'] as List)) EntradaHist.deJson(h)!];
      final tar = c['tarefas'] as Map<String, dynamic>;
      final total = tar['total'] as int;

      // funções soltas
      final soltas = s['soltas'] as Map<String, dynamic>;
      expect(estStreakAtual(hist, hoje), soltas['streak'], reason: 'estStreakAtual');
      expect(estRecorde(hist), soltas['recorde'], reason: 'estRecorde');
      final vivo = estHistComHojeAoVivo(
        hist: hist,
        hoje: hoje,
        descansando: c['descanso'] == true,
        totalTarefasHoje: total,
        todasFeitasHoje: (tar['feitas'] as int) >= total,
      );
      final av = soltas['ao_vivo'] as Map<String, dynamic>;
      expect(vivo.length, av['n'], reason: 'estHistComHojeAoVivo: tamanho');
      expect(vivo.isEmpty ? null : vivo.last.paraJson(), av['ultimo'] == null ? null : EntradaHist.deJson(av['ultimo'])!.paraJson(), reason: 'estHistComHojeAoVivo: último');

      // renderEstatisticas
      final r = resumoEstatisticas(vivo, hoje);
      final seq = s['seq'] as Map<String, dynamic>;
      expect('${r.streak}', seq['streak']);
      expect(_corJs(corDoStreak(r.streak)), seq['cor']);
      expect(double.parse((seq['escala'] as String).replaceAll('scale(', '').replaceAll(')', '')), closeTo(escalaTocha(r.streak), 1e-12));
      expect(seq['apagada'], r.streak == 0);
      final lbl = switch (r.rotulo) {
        RotuloSequencia.vencaHoje => 'est.vencaHoje:{recorde}:{faltam}',
        RotuloSequencia.recordeAtual => 'est.recordeAtual:{recorde}:{faltam}',
        RotuloSequencia.faltaUm => 'est.recordeFaltaUm:${r.recorde}:${r.faltam}',
        RotuloSequencia.faltam => 'est.recordeFaltam:${r.recorde}:${r.faltam}',
      };
      expect(lbl, seq['lbl'], reason: 'rótulo da sequência');
      expect(['${c['total']}', '${r.vitoriasTotal}', '${r.taxaGeral}%'], [for (final x in (s['geral'] as List)) '$x'], reason: 'desde o início');

      final taxa = s['taxa'] as Map<String, dynamic>;
      expect('${r.taxaMes}%', taxa['num']);
      expect('${r.taxaMes}', taxa['pct']);
      final fundo = switch (trilhaDoAnel(r.taxaMes)) {
        TrilhaAnel.nenhuma => 'none',
        TrilhaAnel.arco => '',
        TrilhaAnel.cheia => 'var(--accent)',
      };
      expect(fundo, taxa['fundo'] ?? '', reason: 'trilha do anel');

      final dn = s['donut'] as Map<String, dynamic>;
      expect(['${r.totalMes}', '${r.vitoriasMes}', '${r.fugasMes}', '${r.semTarefaMes}', '${r.descansoMes}'], [dn['total'], dn['v'], dn['f'], dn['s'], dn['d']], reason: 'donut');
      double pct(String w) => double.parse(w.replaceAll('%', ''));
      expect(larguraBarra(r.vitoriasMes, r.totalMes), closeTo(pct(dn['bv']), 1e-9));
      expect(larguraBarra(r.fugasMes, r.totalMes), closeTo(pct(dn['bf']), 1e-9));
      expect(larguraBarra(r.semTarefaMes, r.totalMes), closeTo(pct(dn['bs']), 1e-9));
      expect(larguraBarra(r.descansoMes, r.totalMes), closeTo(pct(dn['bd']), 1e-9));
      final f = fatiasDonut(r.vitoriasMes, r.fugasMes, r.descansoMes, r.totalMes);
      if (r.totalMes == 0) {
        expect(dn['fundo'], 'var(--panel-3)');
      } else {
        // o JS pinta vitória 0..a, fuga a..b, descanso b..c (em %), e o resto com --panel-3
        final nums = [for (final m in RegExp(r'(?<![\w-])(\d+(?:\.\d+)?(?:e[+-]?\d+)?)%').allMatches(dn['fundo'] as String)) double.parse(m[1]!)];
        // 0% a | a b | b c | c 100%   (o "40%" do color-mix e o "100%" final também entram)
        final sem40 = [...nums]..remove(40.0);
        expect(sem40.first, 0);
        expect(sem40[1], closeTo(f.vit, 1e-9));
        expect(sem40[2], closeTo(f.vit, 1e-9));
        expect(sem40[3], closeTo(f.fuga, 1e-9));
        expect(sem40[4], closeTo(f.fuga, 1e-9));
        expect(sem40[5], closeTo(f.desc, 1e-9));
      }

      final p = anoMesDe(hoje);
      expect(rotuloMesAno(p.ano, p.mes, c['lang'] as String), s['mesLabel']);

      // últimos 7 dias
      final g = ultimos7Dias(vivo, hoje);
      final gs = s['graf'] as Map<String, dynamic>;
      expect([for (final q in g.pontos) [q.x, q.y]], [for (final q in _pares(gs['linha'] as String)) [q[0].toDouble(), q[1].toDouble()]], reason: 'linha');
      final circ = (gs['circulos'] as List);
      expect(g.pontos.length, circ.length);
      for (var i = 0; i < circ.length; i++) {
        expect(g.pontos[i].x, double.parse(circ[i][0]), reason: 'cx $i');
        expect(g.pontos[i].y, double.parse(circ[i][1]), reason: 'cy $i');
        expect(g.pontos[i].alfa, _alfa(circ[i][2] as String), reason: 'alfa $i');
      }
      final nomes = c['lang'] == 'en' ? diasSemanaEn : diasSemanaPt;
      final rot = (gs['rotulos'] as List);
      expect([for (final d in g.diasSemana) nomes[d]], [for (final x in rot) x[0]], reason: 'rótulos dos dias');
      expect([for (var i = 0; i < rot.length; i++) i == 6 ? 'hoje' : ''], [for (final x in rot) x[1]]);

      // histórico: mês, semana ou ano
      final mapa = s['mapa'] as List;
      final sw = s['anoSwitch'] as Map<String, dynamic>;
      expect(sw['on'], c['periodo'] == 'ano');
      switch (c['periodo']) {
        case 'mes':
          final tiles = mapaDoMes(vivo, p.ano, p.mes, hoje);
          expect(tiles.length, mapa.length);
          for (var i = 0; i < tiles.length; i++) {
            expect([_classeTile(tiles[i].resultado), _tile(tiles[i])], [mapa[i][0], mapa[i][1]], reason: 'dia ${i + 1}');
          }
        case 'semana':
          final tiles = mapaDaSemana(vivo, hoje);
          expect(tiles.length, 7);
          for (var i = 0; i < 7; i++) {
            expect([_classeTile(tiles[i].resultado), _tile(tiles[i])], [mapa[i][0], mapa[i][1]], reason: 'dia $i');
          }
        default:
          final ano = anoEfetivo(c['anoEsc'] as int?, p.ano);
          expect(sw['num'], '$ano');
          expect(sw['proxDesab'], ano >= p.ano);
          final m = mapaDoAno(vivo, ano, hoje);
          final nm = c['lang'] == 'en' ? mesesCurtosEn : mesesCurtosPt;
          expect(m.length, 12);
          for (var i = 0; i < 12; i++) {
            expect(mapa[i][0], nm[i]);
            expect([for (final x in m[i]) x ?? '.'].join(','), mapa[i][1], reason: 'mês ${i + 1}/$ano');
          }
      }
    });
  }
}
