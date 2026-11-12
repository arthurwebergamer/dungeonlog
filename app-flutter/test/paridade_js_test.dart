// Paridade com o app atual: cada caso abaixo foi calculado pelo JS de play/index.html
// (ver tools/gerar_casos_js.mjs -> test/fixtures/casos_js.json) e o Dart precisa dar o mesmo resultado.
//
// Rodar:  flutter test        (a partir de app-flutter/)
// Regerar os casos:  node app-flutter/tools/gerar_casos_js.mjs   (a partir da raiz do repositório)
import 'dart:convert';
import 'dart:io';

import 'package:dungeonlog_flutter/dominio/catalogo.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/datas.dart';
import 'package:dungeonlog_flutter/dominio/economia.dart';
import 'package:dungeonlog_flutter/dominio/regras.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/dominio/tarefa.dart';
import 'package:dungeonlog_flutter/dominio/vida.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json(String caminho) => jsonDecode(File(caminho).readAsStringSync()) as Map<String, dynamic>;

late Map<String, dynamic> casos;
late DadosJogo dados;
late List<List<dynamic>> linhasItens;

Catalogo catalogoNovo() => Catalogo.deLinhas([for (final l in linhasItens) List<dynamic>.from(l)]);

Equipado equipadoDe(Object? m) => Map<String, dynamic>.from(m as Map);

/// Descreve um item pelo que importa (base, afixo, forjas), sem depender do id da variante.
Object? descItem(Catalogo cat, Object? id) {
  if (id == null) return null;
  final it = cat.item(id);
  if (it == null) return {'invalido': id};
  return {
    'base': it.base,
    'afx': it.afixo == null ? null : [it.afixo!.tipo, it.afixo!.valor],
    'rer': it.rer,
  };
}

List<Object?> lista(Object? o) => (o as List).toList();

void main() {
  setUpAll(() {
    casos = _json('test/fixtures/casos_js.json');
    final d = 'assets/dados/';
    dados = DadosJogo.deTextos(
      monstros: File('${d}monstros.json').readAsStringSync(),
      herois: File('${d}herois.json').readAsStringSync(),
      temas: File('${d}temas_arena.json').readAsStringSync(),
      itens: File('${d}itens.json').readAsStringSync(),
      traducoes: File('${d}traducoes.json').readAsStringSync(),
    );
    linhasItens = [for (final l in (_json('${d}itens.json')['linhas'] as List)) List<dynamic>.from(l as List)];
  });

  group('dados extraídos', () {
    test('quantidades batem com o assets.js', () {
      expect(dados.monstros.length, casos['nMonstros']);
      expect(dados.herois.length, 8);
      expect(dados.catalogo.baseN, casos['geradoCom']['baseN']);
      expect(dados.temas.map((t) => t.id), casos['temasArena']);
      expect(dados.traducoes.tamanho, greaterThanOrEqualTo(295));
      expect(dados.traducoes.t('nav.tarefas'), 'Tarefas');
      expect(dados.traducoes.t('nav.tarefas', 'en'), 'Tasks');
    });

    test('todas as imagens apontadas existem', () {
      final caminhos = <String>[
        for (final m in dados.monstros) m.img,
        for (final h in dados.herois) ...[h.img, if (h.imgArena != null) h.imgArena!],
        for (final t in dados.temas) ...[if (t.arte != null) t.arte!, if (t.arteEstagio != null) t.arteEstagio!],
        dados.folha.arquivo,
        'assets/img/arena/tile.png',
      ];
      for (final c in caminhos) {
        expect(File(c).existsSync(), isTrue, reason: c);
      }
    });

    test('folha de sprites: 16x27 tiles de 32 px e todos os sprites cabem', () {
      expect(dados.folha.colunas * dados.folha.linhas, 432);
      for (var i = 0; i < dados.catalogo.baseN; i++) {
        final s = dados.catalogo.item(i)!.sprite;
        expect(s >= 0 && s < 432, isTrue, reason: 'item $i sprite $s');
      }
    });
  });

  group('constantes de economia', () {
    test('ECO, BONUS, AFX_TETO, dificuldades e limiares', () {
      final c = casos['constantes'] as Map<String, dynamic>;
      final eco = c['ECO'] as Map<String, dynamic>;
      final dart = <String, Object>{
        'xpPorTarefa': Eco.xpPorTarefa, 'xpTarefasCheias': Eco.xpTarefasCheias, 'xpDecaimento': Eco.xpDecaimento,
        'difTrivial': Eco.difTrivial, 'difFacil': Eco.difFacil, 'difMedia': Eco.difMedia, 'difDificil': Eco.difDificil,
        'vidaBase': Eco.vidaBase, 'vidaPorNivel': Eco.vidaPorNivel, 'danoPorTarefa': Eco.danoPorTarefa,
        'curaPorTarefa': Eco.curaPorTarefa, 'curaVitoria': Eco.curaVitoria, 'penalidadeMorte': Eco.penalidadeMorte,
        'moedasPorTarefa': Eco.moedasPorTarefa, 'moedasVitoriaBase': Eco.moedasVitoriaBase,
        'moedasVitoriaPorTarefa': Eco.moedasVitoriaPorTarefa, 'moedasVitoriaTeto': Eco.moedasVitoriaTeto,
        'lojaMargem': Eco.lojaMargem, 'lojaVagas': Eco.lojaVagas, 'lojaConsumiveis': Eco.lojaConsumiveis,
        'lojaRarosMin': Eco.lojaRarosMin, 'lojaDesconto': Eco.lojaDesconto, 'lojaNivelPorRaridade': Eco.lojaNivelPorRaridade,
        'lojaMargemConsumivel': Eco.lojaMargemConsumivel, 'taxaVenda': Eco.taxaVenda, 'taxaVendaTesouro': Eco.taxaVendaTesouro,
        'lootBase': Eco.lootBase, 'lootExtraCada': Eco.lootExtraCada, 'lootMax': Eco.lootMax,
        'lootPorEstagio': Eco.lootPorEstagio, 'sorteEstagio': Eco.sorteEstagio,
        'chanceBauTrancadoMin': Eco.chanceBauTrancadoMin, 'chanceBauTrancadoMax': Eco.chanceBauTrancadoMax,
        'nivelBase': Eco.nivelBase, 'nivelIncremento': Eco.nivelIncremento,
      };
      expect(dart.keys.toSet(), eco.keys.toSet(), reason: 'chaves de ECO');
      for (final k in eco.keys) {
        expect(dart[k], eco[k], reason: 'ECO.$k');
      }
      final bonus = c['BONUS'] as Map<String, dynamic>;
      expect(bonusPorTipo.keys.toSet(), bonus.keys.toSet());
      for (final k in bonus.keys) {
        expect(bonusPorTipo[k]!.x, bonus[k]['x'], reason: 'BONUS.$k.x');
        expect(bonusPorTipo[k]!.m, bonus[k]['m'], reason: 'BONUS.$k.m');
      }
      expect(afixoTeto, c['AFX_TETO']);
      expect(limiaresEstagio, c['LIMIARES_ESTAGIO']);
      expect(slotsEquip, c['SLOTS']);
      expect(difPadrao, c['DIF_PADRAO']);
      final difs = c['DIFS'] as List;
      expect(dificuldades.length, difs.length);
      for (var i = 0; i < difs.length; i++) {
        expect(dificuldades[i].id, difs[i]['id']);
        expect(dificuldades[i].pips, difs[i]['pips']);
        expect(dificuldades[i].mult, c['ECO'][difs[i]['eco']]);
      }
    });
  });

  group('equipamento, XP e moedas', () {
    for (final cfg in (casos0()['equipamento'] as List)) {
      test('config "${cfg['nome']}"', () {
        final cat = catalogoNovo();
        cat.restaurarVariantes(cfg['variantes']);
        final eq = equipadoDe(cfg['equipado']);
        final b = bonusEquip(cat, eq);
        expect({'m': b.m, 'x': b.x}, cfg['bonus']);
        expect(b.multXp, cfg['multXP']);
        expect(b.multMoedas, cfg['multMoedas']);
        for (final c in cfg['xp'] as List) {
          expect(xpDaTarefa(c['ordem'], c['dif'], multXp: b.multXp), c['xp'], reason: 'xp ordem ${c['ordem']} dif ${c['dif']}');
        }
        for (final c in cfg['vitoria'] as List) {
          expect(recompensaVitoria(c['n'], multMoedas: b.multMoedas), c['moedas'], reason: 'vitória n=${c['n']}');
        }
        for (final s in cfg['moedasSeqs'] as List) {
          final ac = AcumuladorMoedas();
          final difs = s['difs'] as List;
          final esperado = s['moedas'] as List;
          for (var i = 0; i < difs.length; i++) {
            expect(ac.moedasDaTarefa(difs[i], multMoedas: b.multMoedas), esperado[i], reason: 'moedas #$i dif ${difs[i]}');
          }
        }
      });
    }

    test('bônus de cada item do catálogo (equipamento por raridade, maldição, consumível)', () {
      final cat = catalogoNovo();
      for (final c in casos['bonusItens'] as List) {
        final b = bonusItem(cat.item(c['id'])!);
        expect({'m': b.m, 'x': b.x}, {'m': c['m'], 'x': c['x']}, reason: 'item ${c['id']}');
      }
    });

    test('preço de venda', () {
      final cat = catalogoNovo();
      for (final c in casos['venda'] as List) {
        final it = cat.item(c['id'])!;
        expect(precoVenda(it.tipo, it.valor), c['preco'], reason: 'item ${c['id']}');
      }
    });

    test('ganho por conclusão com meta (vezes por dia)', () {
      for (final c in casos['ganhoMeta'] as List) {
        final g = ganhoPorConclusao(ordem: c['ordem'], dif: c['dif'], meta: c['meta'], acumulador: AcumuladorMoedas());
        expect({'xp': g.xp, 'moedas': g.moedas}, {'xp': c['xp'], 'moedas': c['moedas']}, reason: '$c');
      }
    });
  });

  group('nível e vida', () {
    test('xpNecessario', () {
      for (final c in casos['xpNecessario'] as List) {
        expect(xpNecessario(c['nivel']), c['xp']);
      }
    });
    test('progresso(xpTotal)', () {
      for (final c in casos['nivel'] as List) {
        if (c['xp'] is! num) continue;
        final p = progresso(c['xp'] as num);
        expect({'nivel': p.nivel, 'resto': p.resto, 'meta': p.meta}, c['progresso'], reason: 'xp ${c['xp']}');
      }
    });
    test('vida máxima por nível', () {
      for (final c in casos['vidaMax'] as List) {
        expect(vidaMax(progresso(c['xp'] as num).nivel), c['vidaMax'], reason: 'xp ${c['xp']}');
      }
    });
  });

  group('datas', () {
    test('isoDe', () {
      for (final c in casos['isoDe'] as List) {
        expect(isoDe(DateTime(c['y'], c['m'], c['d'], 23, 59)), c['iso']);
        expect(isoDe(DateTime(c['y'], c['m'], c['d'], 0, 1)), c['isoManha']);
      }
    });
    test('diffDias', () {
      for (final c in casos['diffDias'] as List) {
        expect(diffDias(c['a'], c['b']), c['dias'], reason: '${c['a']} - ${c['b']}');
      }
    });
    test('ocorreNoDia em 28 meses para cada tipo de tarefa', () {
      final oc = casos['ocorrencias'] as Map<String, dynamic>;
      final dias = <String>[];
      for (var d = DateTime.utc(2023, 12, 1); !d.isAfter(DateTime.utc(2026, 3, 31)); d = d.add(const Duration(days: 1))) {
        dias.add(d.toIso8601String().substring(0, 10));
      }
      expect(dias.first, oc['de']);
      expect(dias.last, oc['ate']);
      for (final c in oc['tarefas'] as List) {
        final t = Tarefa.deJson(Map<String, dynamic>.from(c['tarefa'] as Map));
        final datas = [for (final d in dias) if (ocorreNoDia(t, d)) d];
        expect(datas, c['datas'], reason: 'tarefa ${c['tarefa']}');
      }
    });
  });

  group('robustez (achados da revisão independente)', () {
    test('data inexistente rola como no JS e tarefa diária vale nela', () {
      expect(diffDias('2026-02-30', '2026-02-28'), 2);
      expect(ocorreNoDia(Tarefa.deJson({'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6]}), '2026-02-30'), isTrue);
    });
    test('verificarVirada não lança com data/feitaEm inválidos', () {
      final tarefas = [
        Tarefa.deJson({'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6], 'dif': 'dificil', 'feitaEm': false}),
        Tarefa.deJson({'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6], 'feitaEm': 0}),
      ];
      for (final ud in ['2026-02-30', '2026-11-1', 'lixo']) {
        final r = verificarVirada(
            hoje: '2026-11-05', ultimoDia: ud, vida: 40, xpTotal: 0, moedas: 10, derrotadoEm: null, tarefas: tarefas, descansando: (_) => false);
        expect(r.ultimoDia, '2026-11-05', reason: ud);
      }
      expect(verificarVirada(hoje: '2026-03-05', ultimoDia: '2026-02-30', vida: 40, xpTotal: 0, moedas: 0, derrotadoEm: null, tarefas: [tarefas[0]], descansando: (_) => false).vida, 26);
    });
    test('save com slot sem q não perde o save inteiro', () {
      final cat = catalogoNovo();
      final s = SaveV3.carregar(
          jsonEncode({'comecou': true, 'afixos': 1, 'variantes': [[0, 'gan', 2, 0], [0, 'est', 3, 0]], 'inventario': [{'id': 319}, {'id': 320, 'q': 2}]}),
          cat, sementeAtual: 7);
      expect(s, isNotNull);
    });
    test('curar respeita a vida máxima', () {
      expect(curar(vida: 10, vidaMaxima: 40, cura: 2), 12);
      expect(curar(vida: 39, vidaMaxima: 40, cura: 2), 40);
      expect(curar(vida: 10, vidaMaxima: 40, cura: 0), 10);
    });
  });

  group('estágio', () {
    test('estagioAtual, progressoEstagio e bioma', () {
      for (final c in casos['estagio'] as List) {
        final total = c['total'] as int;
        expect(estagioAtual(total), c['estagio'], reason: 'total $total');
        expect(progressoEstagio(total), c['progresso'], reason: 'total $total');
        expect(dados.biomaDoEstagio(estagioAtual(total)), c['bioma']);
      }
    });
  });

  group('dias corridos e monstro do dia, em vários fusos', () {
    for (final f in casos0()['fusos'] as List) {
      test('fuso ${f['tz']}', () {
        final biomas = dados.biomasDosMonstros;
        for (final d in f['datas'] as List) {
          final y = d['y'] as int, m = d['m'] as int, dd = d['d'] as int;
          final dc = diasCorridosComFuso(y, m, dd, d['offsetMinutosLeste']);
          expect(dc, d['diasCorridos'], reason: '$y-$m-$dd');
          final hoje = '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${dd.toString().padLeft(2, '0')}';
          for (final c in d['monstros'] as List) {
            final pool = poolMonstros(biomas, c['bioma']);
            expect(pool.length, c['pool'], reason: 'pool ${c['bioma']}');
            final semente = c['semente'] as int;
            expect(monstroDoDia(pool: pool, totalMonstros: dados.monstros.length, diasCorridos: dc, semente: semente), c['hoje'],
                reason: '${f['tz']} $hoje ${c['bioma']} semente $semente');
            for (final e in c['em'] as List) {
              expect(
                monstroDoDiaEm(
                  pool: pool, totalMonstros: dados.monstros.length, diasCorridos: dc,
                  diasAteHoje: diffDias(e['iso'], hoje), semente: semente,
                ),
                e['idx'],
                reason: '${f['tz']} $hoje -> ${e['iso']} ${c['bioma']} semente $semente',
              );
            }
          }
        }
      });
    }

    test('com o fuso do aparelho, diasCorridos(DateTime) bate com a conta explícita', () {
      final agora = DateTime(2026, 11, 11, 10);
      final off = DateTime(2026, 11, 11).timeZoneOffset.inMinutes;
      expect(diasCorridos(agora), diasCorridosComFuso(2026, 11, 11, off));
    });
  });

  group('save versão 3', () {
    for (final c in casos0()['saves'] as List) {
      test('carregar e salvar: ${c['nome']}', () {
        for (final r in c['resultados'] as List) {
          final cat = catalogoNovo();
          final s = SaveV3.carregar(c['entrada'] as String?, cat, idioma: r['idioma'], sementeAtual: 7);
          expect(s != null, r['carregou'], reason: '${c['nome']} carregou');
          if (s == null) continue;
          final e = r['estado'] as Map<String, dynamic>;
          expect(s.tarefas.map((t) => t.paraJson()).toList(), e['tarefas'], reason: 'tarefas');
          expect(s.xpTotal, e['xpTotal']);
          expect(s.moedas, e['moedas']);
          expect(s.derrotadoEm, e['derrotadoEm']);
          expect(s.nomeHeroi, e['nomeHeroi']);
          expect(s.heroi, e['heroiEscolhido']);
          expect(s.semente, e['semente']);
          expect([for (final sl in s.inventario) {'item': descItem(cat, sl['id']), 'q': sl['q']}], e['inventario'], reason: 'inventário');
          expect({for (final k in slotsEquip) k: descItem(cat, s.equipado[k])}, e['equipado'], reason: 'equipado');
          // o JSON que o Dart grava é idêntico ao que o JS grava
          final json = jsonDecode(jsonEncode(s.paraJson(cat, salvoEm: 1700000000000)));
          expect(json, r['salvo'], reason: 'JSON salvo');
        }
      });
    }

    test('chaves de armazenamento por conta e personagem', () {
      for (final c in casos['chaves'] as List) {
        expect(chaveSave(uid: c['uid'], personagem: c['pj']), c['save']);
        expect(chaveConta('questlog.vida.v1', uid: c['uid'], personagem: c['pj']), c['vida']);
        expect(chaveConta('questlog.descanso.v1', uid: c['uid'], personagem: c['pj']), c['descanso']);
      }
    });
  });

  group('virada do dia e vida (bloco "Vida do herói" do JS)', () {
    final cenarios = casos0()['virada'] as List;
    test('${cenarios.length} cenários', () {
      var quedas = 0, vitorias = 0;
      for (var i = 0; i < cenarios.length; i++) {
        final c = cenarios[i] as Map<String, dynamic>;
        final e = c['entrada'] as Map<String, dynamic>;
        final s = c['saida'] as Map<String, dynamic>;
        final cat = catalogoNovo();
        cat.restaurarVariantes(e['variantes']);
        final eq = equipadoDe(e['equipado']);
        final bonus = bonusEquip(cat, eq);
        final descanso = List<String>.from(e['descanso'] as List);
        final r = verificarVirada(
          hoje: e['hoje'],
          ultimoDia: e['ultimoDia'],
          vida: e['vida'],
          xpTotal: e['xpTotal'],
          moedas: e['moedas'],
          derrotadoEm: e['derrotadoEm'],
          tarefas: [for (final t in e['tarefas'] as List) Tarefa.deJson(Map<String, dynamic>.from(t as Map))],
          descansando: descanso.contains,
          multMoedas: bonus.multMoedas,
        );
        final rotulo = 'cenário $i (${jsonEncode(e)})';
        expect(r.vida, s['vida'], reason: 'vida; $rotulo');
        expect(vidaMax(progresso(e['xpTotal'] as num).nivel), s['vidaMax'], reason: 'vidaMax; $rotulo');
        expect(r.ultimoDia, s['ultimoDia'], reason: 'ultimoDia; $rotulo');
        expect(r.moedas, s['moedas'], reason: 'moedas; $rotulo');
        expect(r.historico.map((h) => [h.data, h.total, h.largadas, h.descansou]).toList(), s['historico'], reason: 'histórico; $rotulo');
        if (r.caiu) quedas++;
        if (r.vitoriaAutomatica) vitorias++;
      }
      // garante que os cenários exercitam os caminhos raros
      expect(quedas, greaterThan(5));
      expect(vitorias, greaterThan(3));
    });
  });
}

// `group`/`test` são montados em tempo de definição, antes do setUpAll: lê o JSON uma vez por arquivo.
Map<String, dynamic>? _cache;
Map<String, dynamic> casos0() => _cache ??= _json('test/fixtures/casos_js.json');
