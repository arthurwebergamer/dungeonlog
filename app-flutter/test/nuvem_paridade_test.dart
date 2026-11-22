// Fase 6 (parte B): paridade da sincronização com o JS REAL do app HTML.
// tools/gerar_casos_nuvem.mjs roda puxarNuvem/empurrarNuvem/guardarHistorico/lerSalvoEm de play/index.html num
// sandbox do Node e grava test/fixtures/casos_nuvem_js.json; aqui o mesmo cenário passa pelo SincronizadorNuvem (com a
// nuvem em memória) e o resultado tem de ser o mesmo. Onde o Dart escolhe o lado seguro de propósito (tabela em
// FASE6.md), o caso cai numa classe de divergência DECLARADA pela entrada (nunca pelo resultado do Dart) e o teste
// confere a regra segura no lugar.
import 'dart:convert';
import 'dart:io';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dados/nuvem.dart';
import 'package:dungeonlog_flutter/dados/sincronizador_nuvem.dart';
import 'package:dungeonlog_flutter/dominio/nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixture() => jsonDecode(File('test/fixtures/casos_nuvem_js.json').readAsStringSync()) as Map<String, dynamic>;

const _uid = 'U';
const _kSave = 'questlog.v1.uid.U.pj.pj1';
String _kc(String b) => '$b.uid.U.pj.pj1';
const _chavesObservadas = ['questlog.vida.v1', 'questlog.hist.v1', 'questlog.dia.v1', 'questlog.trial.v1', 'questlog.atrib.v1', 'questlog.naoListada.v1'];
const _extrasLocal = {
  'questlog.vida.v1': '{"vida":12,"ultimoDia":"2026-01-03"}',
  'questlog.hist.v1': '[{"data":"2026-01-01","resultado":"fuga","monstroId":2,"tarefas":2}]',
  'questlog.dia.v1': '2',
  'questlog.atrib.v1': '{"forca":1}',
};
const _t = 1763700000000;

/// Roda o caso no Dart e devolve a saída no mesmo formato do JSON do JS.
Future<Map<String, dynamic>> _rodarDart(Map<String, dynamic> caso, int agora) async {
  final ent = caso['entrada'] as Map<String, dynamic>;
  final vl = ent['local'] as String?;
  final nuvem = ent['nuvem'] as Map<String, dynamic>?;
  final arm = ArmazenamentoMemoria();
  if (vl != null) arm.dados[_kSave] = vl;
  _extrasLocal.forEach((k, v) => arm.dados[_kc(k)] = v);
  if (caso['sujo'] == true) arm.dados[chaveSujo(_uid)] = '$_t';
  // O HTML não tem a noção "nunca sincronizou aqui": para ele toda conta já sincronizou. Mesma premissa aqui.
  arm.dados[chaveSincronizado(_uid)] = '$_t';
  final repo = RepositorioNuvemMemoria();
  if (nuvem != null) {
    repo.saves[_uid] = docSaveDeMapa({'data': nuvem['data'], if (nuvem['extras'] != null) 'extras': nuvem['extras'], 'atualizadoEm': _t});
  }
  final s = SincronizadorNuvem(repo: repo, armazenamento: arm, agoraMs: () => agora, atraso: Duration.zero);
  await s.entrar(_uid);
  await s.esperarOcioso();
  s.parar();
  final antiga = nuvem?['data'] as String?;
  final gravou = repo.gravacoesSave > 0;
  List<String> backups() {
    final b = arm.ler(chaveBackupLocal(_uid));
    return b == null ? [] : [for (final x in jsonDecode(b) as List) (x as Map)['data'] as String];
  }

  return {
    'localSave': arm.ler(_kSave),
    'localExtras': {for (final k in _chavesObservadas) k: arm.ler(_kc(k))},
    'backups': backups(),
    'empurrou': gravou ? {'data': repo.saves[_uid]!.data, 'extras': repo.saves[_uid]!.extras} : null,
    'nuvemData': repo.saves[_uid]?.data,
    'historicoComNuvemAntiga': antiga != null && (repo.historico[_uid]?.values.any((h) => h.data == antiga) ?? false),
    'sujoDepois': arm.ler(chaveSujo(_uid)) != null,
  };
}

/// Classe de divergência declarada (pela ENTRADA). null = o Dart tem de ser idêntico ao JS.
String? _classe(Map<String, dynamic> caso) {
  final ent = caso['entrada'] as Map<String, dynamic>;
  final vl = ent['local'] as String?;
  final vn = (ent['nuvem'] as Map<String, dynamic>?)?['data'] as String?;
  final docExiste = ent['nuvem'] != null;
  final sujo = caso['sujo'] == true;
  final lOk = saveComecado(vl), nOk = saveComecado(vn);
  if (sujo && !lOk) return 'S1-sujo-sem-save-local'; // JS sobe `data: ''`/lixo por cima da nuvem
  if (sujo) return 'S2-sujo-copia-nuvem'; // igual ao JS + cópia da nuvem no histórico
  if (!nOk && docExiste) return 'S3-nuvem-sem-save'; // JS baixaria um save não começado / extras sem save
  if (!nOk && lOk) return 'S4-sobe-ja'; // JS só sobe no próximo salvar()
  if (!lOk && vl != null && nOk) return 'S5-local-lixo'; // JS pode subir um save não começado (carimbo mais novo)
  if (lOk && nOk && vl != vn && lerSalvoEm(vl) != 0 && lerSalvoEm(vn) == 0) return 'S6-nuvem-sem-carimbo';
  return null;
}

void main() {
  final fx = _fixture();
  final agora = fx['agora'] as int;
  final casos = (fx['casos'] as List).cast<Map<String, dynamic>>();

  test('lista de chaves secundárias = CHAVES_SECUNDARIAS_CONTA do JS (mesma ordem)', () {
    expect(chavesSecundariasConta, fx['chavesSecundarias']);
  });

  test('lerSalvoEm = JS', () {
    for (final c in (fx['lerSalvoEm'] as List).cast<Map<String, dynamic>>()) {
      expect(lerSalvoEm(c['entrada'] as String?), c['saida'], reason: '${c['entrada']}');
    }
  });

  test('guardarHistorico: mesmos documentos (h/d) e marcadores que o JS', () {
    for (final c in (fx['historico'] as List).cast<Map<String, dynamic>>()) {
      final q = docsHistorico(agoraMs: c['agora'] as int, ultH: c['ultH'] as int, ultD: c['ultD'] as int, n: c['n'] as int, forcar: c['forcar'] as bool);
      expect([if (q.h != null) q.h, if (q.d != null) q.d], c['ids'], reason: '$c');
      final m = c['marcadores'] as Map<String, dynamic>;
      if (q.h != null) expect('${q.proximoN}', m['n'], reason: '$c');
    }
  });

  group('puxarNuvem/empurrarNuvem: ${casos.length} cenários do JS real', () {
    var identicos = 0;
    final porClasse = <String, int>{};
    for (final caso in casos) {
      final nome = 'local=${caso['local']} nuvem=${caso['nuvem']} sujo=${caso['sujo']} extras=${caso['comExtras']}';
      test(nome, () async {
        final js = caso['saida'] as Map<String, dynamic>;
        final dart = await _rodarDart(caso, agora);
        final ent = caso['entrada'] as Map<String, dynamic>;
        final vl = ent['local'] as String?;
        final nv = ent['nuvem'] as Map<String, dynamic>?;
        final vn = nv?['data'] as String?;
        final classe = _classe(caso);
        porClasse[classe ?? 'identico'] = (porClasse[classe ?? 'identico'] ?? 0) + 1;

        // Regras de segurança que valem SEMPRE no Dart:
        final enviado = (dart['empurrou'] as Map?)?['data'] as String?;
        if (enviado != null) expect(saveComecado(enviado), isTrue, reason: 'nunca sobe save vazio/não começado');
        if (saveComecado(vl)) expect(saveComecado(dart['localSave'] as String?), isTrue, reason: 'save local começado nunca vira vazio');
        if (vl != null && vl.isNotEmpty && dart['localSave'] != vl) {
          expect((dart['backups'] as List).contains(vl), isTrue, reason: 'local sobrescrito tem cópia no backup');
        }
        if (saveComecado(vn) && dart['nuvemData'] != vn && !(dart['localSave'] == vn)) {
          expect(dart['historicoComNuvemAntiga'], isTrue, reason: 'nuvem sobrescrita tem cópia no histórico');
        }
        expect((dart['localExtras'] as Map)['questlog.dia.v1'], _extrasLocal['questlog.dia.v1'], reason: 'dia de debug nunca desce');
        if (dart['empurrou'] != null) expect(((dart['empurrou'] as Map)['extras'] as Map).containsKey('questlog.dia.v1'), isFalse);

        // A nuvem venceu e trouxe histórico: o Dart acrescenta o dia que só o aparelho tinha e sobe de volta.
        // (o JS baixou as extras da nuvem = a vida local virou a da nuvem; a nuvem do teste não tem o dia 2026-01-01)
        Map<String, dynamic> esperado = js;
        final nuvemExtras = nv?['extras'] as Map?;
        final jsBaixouExtras = nuvemExtras != null && (js['localExtras'] as Map)['questlog.vida.v1'] == nuvemExtras['questlog.vida.v1'];
        if (jsBaixouExtras) {
          final mesclado = mesclarHist(nuvemExtras['questlog.hist.v1'] as String, _extrasLocal['questlog.hist.v1']);
          esperado = jsonDecode(jsonEncode(js)) as Map<String, dynamic>;
          final le = esperado['localExtras'] as Map;
          le['questlog.hist.v1'] = mesclado;
          esperado['sujoDepois'] = false; // o histórico mesclado subiu de volta
          esperado['empurrou'] = {
            'data': js['localSave'],
            'extras': {
              for (final b in chavesSecundariasConta)
                if (b != 'questlog.dia.v1' && le[b] != null) b: le[b],
            },
          };
          esperado['nuvemData'] = js['localSave'];
          esperado['historicoComNuvemAntiga'] = true; // o envio de volta alimenta o histórico com esse mesmo save
        }

        switch (classe) {
          case null:
            identicos++;
            expect(dart, esperado, reason: 'idêntico ao JS');
          case 'S2-sujo-copia-nuvem':
            final e2 = Map.of(esperado)..remove('historicoComNuvemAntiga');
            final d2 = Map.of(dart)..remove('historicoComNuvemAntiga');
            expect(d2, e2, reason: 'mesmo resultado do JS (o local sobe)');
            // nuvem diferente: cópia forçada antes; igual: o próprio envio alimenta o histórico com o mesmo texto
            expect(dart['historicoComNuvemAntiga'], saveComecado(vn), reason: 'e a nuvem vai para o histórico');
          case 'S1-sujo-sem-save-local':
            if (saveComecado(vn)) {
              expect(dart['localSave'], vn, reason: 'sem save local: baixa a nuvem em vez de subir vazio');
              expect(dart['nuvemData'], vn);
            } else {
              expect(dart['localSave'], vl);
              expect(dart['empurrou'], isNull);
              expect(dart['nuvemData'], vn);
            }
          case 'S3-nuvem-sem-save':
          case 'S4-sobe-ja':
            if (saveComecado(vl)) {
              expect(dart['localSave'], vl, reason: 'save local começado fica');
              expect((dart['empurrou'] as Map)['data'], vl, reason: 'e sobe já');
              expect((dart['localExtras'] as Map)['questlog.vida.v1'], _extrasLocal['questlog.vida.v1'], reason: 'extras de uma nuvem sem save não descem');
            } else {
              expect(dart['localSave'], vl, reason: 'nada a fazer');
              expect(dart['empurrou'], isNull);
            }
          case 'S5-local-lixo':
            expect(dart['localSave'], vn, reason: 'local sem save começado: a nuvem desce (o JS podia subir o lixo)');
            expect(dart['backups'], [vl]);
          case 'S6-nuvem-sem-carimbo':
            expect(dart['localSave'], vl, reason: 'local com carimbo vence nuvem sem carimbo (o JS baixaria)');
            expect((dart['empurrou'] as Map)['data'], vl);
            expect(dart['historicoComNuvemAntiga'], isTrue);
        }
      });
    }
    tearDownAll(() {
      // ignore: avoid_print
      print('paridade nuvem: $identicos idênticos ao JS; divergências declaradas: $porClasse');
    });
  });
}
