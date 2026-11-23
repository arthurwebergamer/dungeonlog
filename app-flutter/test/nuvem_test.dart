// Fase 6 (parte B): sincronização do save com a nuvem, com a nuvem EM MEMÓRIA (nenhum teste inicia o Firebase).
// Os fluxos do pedido: (a) conta nova + convidado, (b) baixar, (c) local mais novo/velho/igual, (d) convidado em conta
// que já existe, (e) sem rede / permissão, (f) vários heróis, (g) histórico, (h) excluir, (i) sair, (j) trocar de aparelho.
// A paridade com o JS real está em nuvem_paridade_test.dart.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/dados/conta.dart';
import 'package:dungeonlog_flutter/dados/conta_falsa.dart';
import 'package:dungeonlog_flutter/dados/nuvem.dart';
import 'package:dungeonlog_flutter/dados/sincronizador_nuvem.dart';
import 'package:dungeonlog_flutter/dominio/dados_jogo.dart';
import 'package:dungeonlog_flutter/dominio/nuvem.dart';
import 'package:dungeonlog_flutter/dominio/save.dart';
import 'package:dungeonlog_flutter/ui/estado_jogo.dart';
import 'package:flutter_test/flutter_test.dart';

DadosJogo? _cacheDados;
DadosJogo _dados() {
  String l(String n) => File('assets/dados/$n.json').readAsStringSync();
  return _cacheDados ??= DadosJogo.deTextos(monstros: l('monstros'), herois: l('herois'), temas: l('temas_arena'), itens: l('itens'), traducoes: l('traducoes'));
}

final DateTime _hoje = DateTime(2026, 11, 11, 10);
final int _hojeMs = _hoje.millisecondsSinceEpoch;

UsuarioConta _nova(String uid) => UsuarioConta(uid: uid, email: '$uid@x.com', contaNova: true, emailVerificado: true, criadoEm: DateTime.utc(2026, 11, 11));
UsuarioConta _existente(String uid) => UsuarioConta(uid: uid, email: '$uid@x.com', emailVerificado: true, criadoEm: DateTime.utc(2026, 1, 1));

/// Um save v3 começado (como o app HTML grava).
String _saveJs({required String nome, num xp = 0, int? salvoEm, int heroi = 0}) => jsonEncode({
      'versao': 3,
      'tarefas': [
        {'texto': 'tarefa de $nome', 'tipo': 'repete', 'dias': [0, 1, 2, 3, 4, 5, 6], 'feitaEm': null, 'dif': 'media', 'meta': 1}
      ],
      'inventario': [],
      'variantes': [],
      'afixos': 2,
      'equipado': {'arma': null, 'armadura': null, 'elmo': null, 'escudo': null, 'acess': null},
      'xpTotal': xp,
      'moedas': 7,
      'derrotadoEm': null,
      'nomeHeroi': nome,
      'heroi': heroi,
      'semente': 3,
      if (salvoEm != null) 'salvoEm': salvoEm,
      'comecou': true,
    });

/// Um aparelho: armazenamento próprio, motor da nuvem e o estado do jogo.
class _Aparelho {
  _Aparelho(this.repo, {ArmazenamentoMemoria? arm, ServicoContaFalso? conta, String? uid})
      : arm = arm ?? ArmazenamentoMemoria(),
        conta = conta ?? ServicoContaFalso() {
    sync = SincronizadorNuvem(repo: repo, armazenamento: this.arm, atraso: const Duration(milliseconds: 20), agoraMs: () => relogio, esperas: const [Duration(milliseconds: 30)]);
    e = EstadoJogo(dados: _dados(), armazenamento: this.arm, agora: () => DateTime.fromMillisecondsSinceEpoch(relogio), aleatorio: Random(1), conta: this.conta, uid: uid, nuvem: sync);
  }
  final RepositorioNuvem repo;
  final ArmazenamentoMemoria arm;
  final ServicoContaFalso conta;
  late final SincronizadorNuvem sync;
  late final EstadoJogo e;
  int relogio = _hojeMs;

  /// O app abrindo (com ou sem sessão salva): a mesma ordem do `_Carregador`.
  Future<void> abrir() async {
    await e.sincronizarAoAbrir();
    await e.abrirDonoAtual();
  }

  /// Espera o atraso do envio e tudo que estiver em voo.
  Future<void> assentar() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await sync.esperarOcioso();
  }

  String? save(String uid, [String pj = 'pj1']) => arm.ler(chaveSave(uid: uid, personagem: pj));
  bool sujo(String uid) => arm.ler(chaveSujo(uid)) != null;
}

/// Convidado com save começado (escolheu herói e nome) e a marca de convidado.
Future<void> _virarConvidado(_Aparelho a, {String nome = 'Gui'}) async {
  await a.abrir();
  a.e.marcarConvidado();
  await a.e.concluirOnboarding(nome: nome, heroi: 2);
  a.e.criarTarefa(texto: 'ler', modo: ModoTarefa.repete, dif: 'media', dias: const [0, 1, 2, 3, 4, 5, 6]);
  a.e.concluir(a.e.tarefasDeHoje.first);
}

Map<String, dynamic> _json(String? s) => jsonDecode(s!) as Map<String, dynamic>;

void main() {
  group('formato (o mesmo do app HTML)', () {
    test('saves/{uid} = {data, extras, atualizadoEm} (+ pj); extras sem o dia de debug', () {
      final arm = ArmazenamentoMemoria();
      arm.dados['questlog.vida.v1.uid.U.pj.pj1'] = '{"vida":3}';
      arm.dados['questlog.dia.v1.uid.U.pj.pj1'] = '4';
      arm.dados['questlog.trial.v1.uid.U.pj.pj1'] = '{"x":1}';
      arm.dados['questlog.vida.v1.uid.U.pj.pj2'] = 'outro herói';
      arm.dados['questlog.resumoDia.v1.uid.U.pj.pj1'] = 'fora da lista';
      final ex = montarExtras(arm.ler, uid: 'U', pj: 'pj1');
      expect(ex, {'questlog.trial.v1': '{"x":1}', 'questlog.vida.v1': '{"vida":3}'});
      final m = DocSave(data: 'D', extras: ex, atualizadoEm: 5, pj: 'pj1').paraMapa();
      expect(m.keys.toSet(), {'data', 'extras', 'atualizadoEm', 'pj'});
    });

    test('leitura defensiva do documento (tipos errados não quebram)', () {
      final d = docSaveDeMapa({'data': 5, 'extras': {'a': 'x', 'b': 3, 'c': {'z': 1}, 'd': true}, 'atualizadoEm': '1', 'pj': '../x'});
      expect(d.data, isNull);
      expect(d.extras, {'a': 'x', 'b': '3', 'd': 'true'});
      expect(d.atualizadoEm, isNull);
      expect(d.pj, isNull);
    });

    test('entitlements: vitalício ou assinatura no prazo; doc ausente/estranho = sem plano', () {
      expect(planoDeMapa(null).ehPro(10), isFalse);
      expect(planoDeMapa({'proVitalicio': true}).ehPro(10), isTrue);
      expect(planoDeMapa({'proVitalicio': 'true'}).ehPro(10), isFalse);
      expect(planoDeMapa({'assinaturaAte': 20}).ehPro(10), isTrue);
      expect(planoDeMapa({'assinaturaAte': 5}).ehPro(10), isFalse);
    });
  });

  group('regra de decisão (unidade; tabela em FASE6.md)', () {
    final velho = _saveJs(nome: 'V', xp: 10, salvoEm: 1000000);
    final novo = _saveJs(nome: 'N', xp: 5, salvoEm: 1010000);
    DecisaoNuvem d({bool sujo = false, bool jaSinc = true, String? local, String? nuvem}) => decidirNuvem(sujo: sujo, jaSincronizou: jaSinc, local: local, nuvem: nuvem);

    test('local mais novo (> 2 s) sobe e guarda a nuvem no histórico; dentro da folga a nuvem vence', () {
      expect(d(local: novo, nuvem: velho).acao, AcaoNuvem.empurrar);
      expect(d(local: novo, nuvem: velho).nuvemNoHistorico, isTrue);
      expect(d(local: velho, nuvem: novo).acao, AcaoNuvem.puxar);
      expect(d(local: velho, nuvem: novo).backupLocal, isTrue);
      final quase = _saveJs(nome: 'Q', salvoEm: 1001500);
      expect(d(local: quase, nuvem: velho).acao, AcaoNuvem.puxar, reason: '1,5 s mais novo ainda é empate: nuvem');
    });
    test('igual: puxa (só as extras); sujo: sobe', () {
      expect(d(local: velho, nuvem: velho).motivo, '4-igual');
      expect(d(sujo: true, local: velho, nuvem: novo).acao, AcaoNuvem.empurrar);
      expect(d(sujo: true, local: velho, nuvem: novo).nuvemNoHistorico, isTrue);
    });
    test('nunca sobe vazio, nunca baixa vazio', () {
      expect(d(sujo: true, local: null, nuvem: novo).acao, AcaoNuvem.puxar);
      expect(d(sujo: true, local: null, nuvem: null).acao, AcaoNuvem.nada);
      expect(d(local: novo, nuvem: '').acao, AcaoNuvem.empurrar);
      expect(d(local: novo, nuvem: _saveJs(nome: 'x').replaceFirst('"comecou":true', '"comecou":false')).acao, AcaoNuvem.empurrar);
      expect(d(local: null, nuvem: null).acao, AcaoNuvem.nada);
    });
    test('nunca sincronizou aqui: vence o de mais XP, mesmo mais velho', () {
      expect(d(jaSinc: false, local: novo, nuvem: velho).acao, AcaoNuvem.puxar, reason: 'nuvem tem mais XP');
      expect(d(jaSinc: false, sujo: true, local: novo, nuvem: velho).acao, AcaoNuvem.puxar);
      expect(d(jaSinc: true, local: novo, nuvem: velho).acao, AcaoNuvem.empurrar, reason: 'já sincronizou: carimbo (HTML)');
    });
    test('nuvem sem carimbo não sobrescreve local com carimbo', () {
      expect(d(local: velho, nuvem: _saveJs(nome: 'S', xp: 999)).acao, AcaoNuvem.empurrar);
    });
  });

  group('fluxos', () {
    test('(a) conta nova + convidado com progresso: leva o progresso e sobe', () async {
      final repo = RepositorioNuvemMemoria();
      final a = _Aparelho(repo);
      await _virarConvidado(a);
      final temSave = await a.e.entrarNaConta(_nova('U1'));
      await a.assentar();
      expect(temSave, isTrue);
      expect(a.e.save.nomeHeroi, 'Gui');
      final doc = repo.saves['U1']!;
      expect(doc.data, a.save('U1'), reason: 'a nuvem tem exatamente o save local');
      expect(doc.pj, 'pj1');
      expect(doc.extras['questlog.vida.v1'], a.arm.ler('questlog.vida.v1.uid.U1.pj.pj1'));
      expect(doc.extras['questlog.tarefasConcluidas.v1'], '1');
      expect(a.sujo('U1'), isFalse);
      a.sync.parar();
    });

    test('(b) conta existente com save só na nuvem: baixa e dá "Bem-vindo de volta", sem subir nada', () async {
      final repo = RepositorioNuvemMemoria();
      repo.saves['U2'] = DocSave(data: _saveJs(nome: 'Nuvem', xp: 900, salvoEm: _hojeMs - 86400000), extras: {
        'questlog.vida.v1': '{"vida":33,"ultimoDia":"2026-11-11"}',
        'questlog.trial.v1': '{"t":1}',
        'questlog.dia.v1': '9',
      });
      final a = _Aparelho(repo);
      await a.abrir();
      final temSave = await a.e.entrarNaConta(_existente('U2'));
      await a.assentar();
      expect(temSave, isTrue);
      expect(a.e.save.nomeHeroi, 'Nuvem');
      expect(a.e.save.xpTotal, 900);
      expect(a.e.vida, 33);
      expect(a.arm.ler('questlog.trial.v1.uid.U2.pj.pj1'), '{"t":1}', reason: 'chave que o Flutter não usa desce igual');
      expect(a.arm.ler('questlog.dia.v1.uid.U2.pj.pj1'), isNull, reason: 'o dia de debug nunca desce');
      // abrir o save baixado não muda o save (nem o carimbo): no máximo sobe as chaves que o jogo criou com o padrão
      expect(repo.gravacoesSave, lessThanOrEqualTo(1));
      expect(repo.saves['U2']!.data, a.save('U2'));
      expect(lerSalvoEm(a.save('U2')), _hojeMs - 86400000, reason: 'o carimbo continua o da nuvem');
      // e a próxima alteração sobe levando a chave que o Flutter não usa (o app HTML não perde nada)
      a.e.criarTarefa(texto: 'nova', modo: ModoTarefa.hoje, dif: 'facil');
      await a.assentar();
      expect(repo.saves['U2']!.extras['questlog.trial.v1'], '{"t":1}');
      expect(_json(repo.saves['U2']!.data)['tarefas'], hasLength(2));
      a.sync.parar();
    });

    group('(c) login com save local do mesmo usuário', () {
      Future<_Aparelho> preparado(RepositorioNuvemMemoria repo) async {
        final a = _Aparelho(repo);
        await a.abrir();
        await a.e.entrarNaConta(_nova('U3'));
        await a.e.concluirOnboarding(nome: 'Local', heroi: 1);
        await a.assentar();
        expect(repo.saves['U3']!.data, a.save('U3'));
        await a.e.sairDaConta();
        return a;
      }

      test('nuvem mais nova (outro aparelho): baixa, guarda backup do local', () async {
        final repo = RepositorioNuvemMemoria();
        final a = await preparado(repo);
        final localAntes = a.save('U3');
        repo.saves['U3'] = DocSave(data: _saveJs(nome: 'OutroAparelho', xp: 50, salvoEm: _hojeMs + 60000));
        a.relogio = _hojeMs + 120000;
        expect(await a.e.entrarNaConta(_existente('U3')), isTrue);
        await a.assentar();
        expect(a.e.save.nomeHeroi, 'OutroAparelho');
        final bk = jsonDecode(a.arm.ler(chaveBackupLocal('U3'))!) as List;
        expect((bk.first as Map)['data'], localAntes);
        a.sync.parar();
      });

      test('local mais novo: sobe, e a nuvem antiga vai para o histórico', () async {
        final repo = RepositorioNuvemMemoria();
        final a = await preparado(repo);
        final velhaNuvem = _saveJs(nome: 'Velha', xp: 0, salvoEm: _hojeMs - 600000);
        repo.saves['U3'] = DocSave(data: velhaNuvem);
        expect(await a.e.entrarNaConta(_existente('U3')), isTrue);
        await a.assentar();
        expect(a.e.save.nomeHeroi, 'Local');
        expect(repo.saves['U3']!.data, a.save('U3'));
        expect(repo.historico['U3']!.values.any((h) => h.data == velhaNuvem), isTrue);
        a.sync.parar();
      });

      test('igual: não sobe nem guarda backup', () async {
        final repo = RepositorioNuvemMemoria();
        final a = await preparado(repo);
        final n = repo.gravacoesSave;
        expect(await a.e.entrarNaConta(_existente('U3')), isTrue);
        await a.assentar();
        expect(repo.gravacoesSave, n);
        expect(a.arm.ler(chaveBackupLocal('U3')), isNull);
        a.sync.parar();
      });
    });

    group('(d) convidado com progresso entrando em conta que JÁ existe', () {
      test('a nuvem da conta tem save: ela vence; o jogo do convidado fica intacto no aparelho', () async {
        final repo = RepositorioNuvemMemoria();
        repo.saves['U4'] = DocSave(data: _saveJs(nome: 'DaConta', xp: 300, salvoEm: _hojeMs - 1000));
        final a = _Aparelho(repo);
        await _virarConvidado(a);
        final cru = a.arm.ler(chaveSave());
        expect(await a.e.entrarNaConta(_existente('U4')), isTrue, reason: '"Bem-vindo de volta" com o save da nuvem');
        await a.assentar();
        expect(a.e.save.nomeHeroi, 'DaConta');
        expect(a.arm.ler(chaveSave()), cru, reason: 'NÃO apaga o convidado');
        expect(_json(repo.saves['U4']!.data)['nomeHeroi'], 'DaConta', reason: 'o convidado não sobe por cima');
        await a.e.sairDaConta();
        expect(a.e.save.nomeHeroi, 'Gui', reason: '"Sair" volta ao jogo do convidado');
        a.sync.parar();
      });

      test('a conta não tem save em lugar nenhum: o convidado é copiado (cru fica) e sobe', () async {
        final repo = RepositorioNuvemMemoria();
        final a = _Aparelho(repo);
        await _virarConvidado(a);
        final cru = a.arm.ler(chaveSave());
        expect(await a.e.entrarNaConta(_existente('U5')), isTrue);
        await a.assentar();
        expect(a.e.save.nomeHeroi, 'Gui');
        expect(a.arm.ler(chaveSave()), cru, reason: 'as chaves cruas ficam');
        expect(_json(repo.saves['U5']!.data)['nomeHeroi'], 'Gui');
        a.sync.parar();
      });

      test('sem rede no login: copia o convidado; quando a rede volta, vence quem tem mais progresso (a nuvem)', () async {
        final repo = RepositorioNuvemMemoria();
        final daNuvem = _saveJs(nome: 'Veterano', xp: 5000, salvoEm: _hojeMs - 86400000);
        repo.saves['U6'] = DocSave(data: daNuvem);
        repo.falhar = 'unavailable';
        final a = _Aparelho(repo);
        await _virarConvidado(a);
        expect(await a.e.entrarNaConta(_existente('U6')), isTrue);
        expect(a.e.save.nomeHeroi, 'Gui', reason: 'offline: joga com o progresso do convidado');
        a.e.criarTarefa(texto: 'offline', modo: ModoTarefa.hoje, dif: 'facil');
        await a.assentar();
        expect(repo.gravacoesSave, 0, reason: 'nada sobe sem antes ler a nuvem');
        repo.falhar = null;
        a.sync.aoVoltar();
        await a.assentar();
        await a.assentar();
        expect(a.e.save.nomeHeroi, 'Veterano', reason: 'mais XP vence; o jogo recarregou sozinho');
        expect(repo.saves['U6']!.data, daNuvem);
        final bk = jsonDecode(a.arm.ler(chaveBackupLocal('U6'))!) as List;
        expect(_json((bk.first as Map)['data'] as String)['nomeHeroi'], 'Gui', reason: 'o progresso do convidado ficou no backup');
        expect(a.arm.ler(chaveSave()), isNotNull, reason: 'e cru no aparelho');
        a.sync.parar();
      });
    });

    group('(e) sem rede / erro de permissão', () {
      test('login sem rede: jogo segue local, nada trava; volta a rede e o que foi feito sobe', () async {
        final repo = RepositorioNuvemMemoria();
        final a = _Aparelho(repo);
        await a.abrir();
        await a.e.entrarNaConta(_nova('U7'));
        await a.e.concluirOnboarding(nome: 'Ana', heroi: 0);
        await a.assentar();
        await a.e.sairDaConta();
        repo.falhar = 'unavailable';
        expect(await a.e.entrarNaConta(_existente('U7')), isTrue);
        a.e.criarTarefa(texto: 'sem rede', modo: ModoTarefa.hoje, dif: 'facil');
        await a.assentar();
        expect(a.sujo('U7'), isTrue);
        expect(repo.saves['U7']!.data, isNot(a.save('U7')));
        repo.falhar = null;
        await a.assentar(); // a nova tentativa automática (30 ms no teste)
        await a.assentar();
        expect(repo.saves['U7']!.data, a.save('U7'));
        expect(a.sujo('U7'), isFalse);
        a.sync.parar();
      });

      test('gravação negada (regra): o "sujo" fica, tenta de novo e não perde nada', () async {
        final repo = RepositorioNuvemMemoria();
        final a = _Aparelho(repo);
        await a.abrir();
        await a.e.entrarNaConta(_nova('U8'));
        repo.falharEscrita = 'permission-denied';
        await a.e.concluirOnboarding(nome: 'Bia', heroi: 0);
        await a.assentar();
        expect(a.sujo('U8'), isTrue);
        expect(a.sync.ultimoErro, 'permission-denied');
        expect(a.e.save.nomeHeroi, 'Bia');
        repo.falharEscrita = null;
        await a.assentar();
        await a.assentar();
        expect(repo.saves['U8']!.data, a.save('U8'));
        expect(a.sujo('U8'), isFalse);
        a.sync.parar();
      });

      test('abrir o app (sessão salva) sem rede não espera além do limite e não sobe nada', () async {
        final repo = RepositorioNuvemMemoria()..falhar = 'unavailable';
        final arm = ArmazenamentoMemoria();
        arm.dados[chaveSave(uid: 'U9')] = _saveJs(nome: 'Off', salvoEm: _hojeMs - 1000);
        final a = _Aparelho(repo, arm: arm, uid: 'U9');
        await a.abrir();
        expect(a.e.save.nomeHeroi, 'Off');
        await a.assentar();
        expect(repo.gravacoesSave, 0);
        a.sync.parar();
      });
    });

    test('envios coalescidos: várias alterações seguidas = 1 setDoc', () async {
      final repo = RepositorioNuvemMemoria();
      final a = _Aparelho(repo);
      await a.abrir();
      await a.e.entrarNaConta(_nova('C1'));
      await a.e.concluirOnboarding(nome: 'Rápido', heroi: 0);
      await a.assentar();
      final n = repo.gravacoesSave;
      for (var i = 0; i < 8; i++) {
        a.e.criarTarefa(texto: 't$i', modo: ModoTarefa.hoje, dif: 'facil');
      }
      await a.assentar();
      expect(repo.gravacoesSave, n + 1);
      expect(_json(repo.saves['C1']!.data)['tarefas'], hasLength(8));
      a.sync.parar();
    });

    test('abrir o app sem mudar nada não "rejuvenesce" o save (salvoEm) nem sobe', () async {
      final repo = RepositorioNuvemMemoria();
      final a = _Aparelho(repo);
      await a.abrir();
      await a.e.entrarNaConta(_nova('C2'));
      await a.e.concluirOnboarding(nome: 'Parado', heroi: 0);
      await a.assentar();
      final antes = a.save('C2');
      final n = repo.gravacoesSave;
      a.sync.parar();
      final b = _Aparelho(repo, arm: a.arm, uid: 'C2')..relogio = _hojeMs + 3600000;
      await b.abrir();
      await b.assentar();
      expect(b.save('C2'), antes);
      expect(repo.gravacoesSave, n);
      b.sync.parar();
    });

    test('(f) vários heróis: a nuvem guarda o herói ATIVO (com pj); outro aparelho abre esse herói', () async {
      final repo = RepositorioNuvemMemoria();
      final a = _Aparelho(repo);
      await a.abrir();
      await a.e.entrarNaConta(_nova('F1'));
      await a.e.concluirOnboarding(nome: 'Primeiro', heroi: 0);
      a.e.ehPro = true;
      await a.e.criarPersonagem('Segundo', 3);
      a.e.criarTarefa(texto: 'só do segundo', modo: ModoTarefa.hoje, dif: 'facil');
      await a.assentar();
      final pj2 = a.e.personagem;
      expect(repo.saves['F1']!.pj, pj2);
      expect(_json(repo.saves['F1']!.data)['nomeHeroi'], 'Segundo');
      a.sync.parar();

      final b = _Aparelho(repo);
      await b.abrir();
      expect(await b.e.entrarNaConta(_existente('F1')), isTrue);
      await b.assentar();
      expect(b.e.personagem, pj2, reason: 'aparelho novo abre o herói que veio da nuvem');
      expect(b.e.save.nomeHeroi, 'Segundo');
      expect(b.e.personagens.map((p) => p.id), contains(pj2));
      expect(b.save('F1'), isNull, reason: 'o pj1 não é inventado');
      b.sync.parar();
    });

    test('(f) documento do app HTML (sem pj) desce no herói ativo, como no original', () async {
      final repo = RepositorioNuvemMemoria();
      repo.saves['F2'] = DocSave(data: _saveJs(nome: 'DoHtml', xp: 1, salvoEm: _hojeMs));
      final a = _Aparelho(repo);
      await a.abrir();
      await a.e.entrarNaConta(_existente('F2'));
      expect(a.e.personagem, 'pj1');
      expect(a.e.save.nomeHeroi, 'DoHtml');
      a.sync.parar();
    });

    test('(g) histórico na nuvem: h0 e d{dia%14} no primeiro envio; h só de 30 em 30 min', () async {
      final repo = RepositorioNuvemMemoria();
      final a = _Aparelho(repo);
      await a.abrir();
      await a.e.entrarNaConta(_nova('G1'));
      await a.e.concluirOnboarding(nome: 'H', heroi: 0);
      await a.assentar();
      final dia = _hojeMs ~/ 86400000;
      expect(repo.historico['G1']!.keys.toSet(), {'h0', 'd${dia % 14}'});
      expect(repo.historico['G1']!['h0']!.data, repo.saves['G1']!.data);
      a.e.criarTarefa(texto: 'x', modo: ModoTarefa.hoje, dif: 'facil');
      await a.assentar();
      expect(repo.historico['G1']!.keys, hasLength(2), reason: 'menos de 30 min: só o save principal');
      a.relogio += 31 * 60000;
      a.e.criarTarefa(texto: 'y', modo: ModoTarefa.hoje, dif: 'facil');
      await a.assentar();
      expect(repo.historico['G1']!.containsKey('h1'), isTrue);
      a.sync.parar();
    });

    test('(g) histórico dos dias: o dia que só o aparelho tem não some quando a nuvem vence', () async {
      final repo = RepositorioNuvemMemoria();
      final arm = ArmazenamentoMemoria();
      arm.dados[chaveSave(uid: 'G2')] = _saveJs(nome: 'Aqui', salvoEm: _hojeMs - 600000);
      arm.dados['questlog.hist.v1.uid.G2.pj.pj1'] = '[{"data":"2026-11-09","resultado":"vitoria","monstroId":1,"tarefas":1}]';
      arm.dados[chaveSincronizado('G2')] = '1';
      repo.saves['G2'] = DocSave(
        data: _saveJs(nome: 'Nuvem', salvoEm: _hojeMs - 1000),
        extras: {'questlog.hist.v1': '[{"data":"2026-11-08","resultado":"fuga","monstroId":2,"tarefas":3}]'},
      );
      final a = _Aparelho(repo, arm: arm);
      await a.abrir();
      await a.e.entrarNaConta(_existente('G2'));
      await a.assentar();
      expect(a.e.hist.map((h) => h.data), containsAll(['2026-11-08', '2026-11-09']));
      expect(repo.saves['G2']!.extras['questlog.hist.v1'], contains('2026-11-09'), reason: 'subiu de volta');
      a.sync.parar();
    });

    test('(h) excluir conta: apaga saves/{uid} e o histórico; envio pendente não recria nada', () async {
      final repo = RepositorioNuvemMemoria();
      final conta = ServicoContaFalso()..apagarNuvem = repo.apagarTudo;
      final u = conta.criarContaExistente('h@x.com', 'senha1', uid: 'H1');
      final a = _Aparelho(repo, conta: conta);
      await a.abrir();
      await conta.entrar('h@x.com', 'senha1');
      await a.e.entrarNaConta(u);
      await a.e.concluirOnboarding(nome: 'Some', heroi: 0);
      await a.assentar();
      expect(repo.saves['H1'], isNotNull);
      expect(repo.historico['H1'], isNotEmpty);
      a.e.criarTarefa(texto: 'pendente', modo: ModoTarefa.hoje, dif: 'facil'); // envio agendado
      await expectLater(a.e.excluirConta(senha: 'errada'), throwsA(isA<ErroConta>()));
      expect(repo.saves['H1'], isNotNull, reason: 'senha errada: nada apagado');
      await a.e.excluirConta(senha: 'senha1');
      await a.e.aposExcluirConta('H1');
      await a.assentar();
      expect(repo.saves['H1'], isNull);
      expect(repo.historico['H1'], isNull);
      expect(a.arm.chaves().where((k) => k.contains('.uid.H1')), isEmpty);
      expect(a.e.uid, isNull);
    });

    test('(i) sair: o último envio termina ANTES de deslogar (depois a regra negaria)', () async {
      final repo = RepositorioNuvemMemoria()..logado = 'I1';
      final conta = _ContaQueDesliga(repo);
      final a = _Aparelho(repo, conta: conta);
      await a.abrir();
      await a.e.entrarNaConta(_nova('I1'));
      await a.e.concluirOnboarding(nome: 'Sai', heroi: 0);
      await a.assentar();
      a.e.criarTarefa(texto: 'última coisa', modo: ModoTarefa.hoje, dif: 'facil');
      await a.e.sairDaConta(); // sem esperar o atraso: o sair descarrega
      expect(conta.desligou, isTrue);
      expect(_json(repo.saves['I1']!.data)['tarefas'], hasLength(1));
      expect(a.sujo('I1'), isFalse);
      expect(a.e.uid, isNull);
      expect(a.e.ehPro, isFalse);
      a.e.criarTarefa(texto: 'sem conta', modo: ModoTarefa.hoje, dif: 'facil');
      await a.assentar();
      expect(_json(repo.saves['I1']!.data)['tarefas'], hasLength(1), reason: 'depois de sair nada mais sobe');
    });

    test('(j) trocar de aparelho: B baixa; A, parado e com a sessão salva, baixa o que B fez ao abrir', () async {
      final repo = RepositorioNuvemMemoria();
      final a = _Aparelho(repo);
      await a.abrir();
      await a.e.entrarNaConta(_nova('J1'));
      await a.e.concluirOnboarding(nome: 'Viajante', heroi: 0);
      await a.assentar();
      a.sync.parar();

      final b = _Aparelho(repo)..relogio = _hojeMs + 3600000;
      await b.abrir();
      expect(await b.e.entrarNaConta(_existente('J1')), isTrue);
      expect(b.e.save.nomeHeroi, 'Viajante');
      b.e.criarTarefa(texto: 'feita no B', modo: ModoTarefa.hoje, dif: 'facil');
      await b.assentar();
      b.sync.parar();

      final a2 = _Aparelho(repo, arm: a.arm, uid: 'J1')..relogio = _hojeMs + 7200000;
      await a2.abrir();
      await a2.assentar();
      expect(a2.e.save.tarefas.map((t) => t.texto), contains('feita no B'), reason: 'A não subiu o save velho por cima');
      expect(_json(repo.saves['J1']!.data)['tarefas'], hasLength(1));
      a2.sync.parar();
    });

    group('revisão extra (bugs achados na revisão)', () {
      test('abertura lenta + toque no save velho NÃO sobe por cima do progresso feito em outro aparelho', () async {
        final repo = RepositorioNuvemMemoria();
        final a = _Aparelho(repo);
        await a.abrir();
        await a.e.entrarNaConta(_nova('R1'));
        await a.e.concluirOnboarding(nome: 'Parado', heroi: 0);
        await a.assentar();
        final localA = a.save('R1');
        a.sync.parar();
        // outro aparelho (ou o app HTML) jogou bastante nesta conta depois disso
        final doOutro = _saveJs(nome: 'Outro', xp: 900, salvoEm: _hojeMs + 3600000);
        repo.saves['R1'] = DocSave(data: doOutro, atualizadoEm: _hojeMs + 3600000);
        // A abre com a sessão salva e a nuvem lenta (passa do limite de 3 s): abre o save velho e o jogador toca nele
        repo.falhar = 'unavailable';
        final a2 = _Aparelho(repo, arm: a.arm, uid: 'R1')..relogio = _hojeMs + 7200000;
        await a2.abrir();
        expect(a2.e.save.nomeHeroi, 'Parado');
        a2.e.criarTarefa(texto: 'toque no save velho', modo: ModoTarefa.hoje, dif: 'facil');
        expect(a2.sujo('R1'), isTrue);
        repo.falhar = null;
        await a2.assentar(); // nova tentativa em segundo plano lê a nuvem
        await a2.assentar();
        expect(_json(repo.saves['R1']!.data)['nomeHeroi'], 'Outro', reason: 'o progresso do outro aparelho não pode ser sobrescrito');
        expect(a2.e.save.nomeHeroi, 'Outro', reason: 'vence o de mais progresso');
        final bk = jsonDecode(a2.arm.ler(chaveBackupLocal('R1'))!) as List;
        expect(_json((bk.first as Map)['data'] as String)['nomeHeroi'], 'Parado', reason: 'o toque local ficou no backup');
        expect(localA, isNotNull);
        a2.sync.parar();
      });

      test('"sujo" com a nuvem igual à última vista aqui continua subindo (regra 1 do HTML)', () {
        final local = _saveJs(nome: 'L', xp: 1, salvoEm: 1000);
        final nuvem = _saveJs(nome: 'N', xp: 900, salvoEm: 999999);
        expect(decidirNuvem(sujo: true, jaSincronizou: true, local: local, nuvem: nuvem).acao, AcaoNuvem.empurrar);
        final c = decidirNuvem(sujo: true, jaSincronizou: true, nuvemMudou: true, local: local, nuvem: nuvem);
        expect(c.acao, AcaoNuvem.puxar, reason: 'conflito: a nuvem mudou por outro aparelho desde a última vista; vence o progresso');
        expect(c.backupLocal, isTrue);
        // o app HTML parado subiu um save VELHO por cima (sessão restaurada): o local alterado, com mais XP, sobe
        final c2 = decidirNuvem(sujo: true, jaSincronizou: true, nuvemMudou: true, local: nuvem, nuvem: local);
        expect(c2.acao, AcaoNuvem.empurrar);
        expect(c2.nuvemNoHistorico, isTrue);
      });

      test('Sair com envio em voo + entrar em OUTRA conta: nada sobe na conta nova antes de ler a nuvem dela', () async {
        final repo = RepositorioNuvemMemoria();
        final arm = ArmazenamentoMemoria();
        final s = SincronizadorNuvem(repo: repo, armazenamento: arm, atraso: const Duration(milliseconds: 5), agoraMs: () => _hojeMs, esperas: const [Duration(milliseconds: 30)]);
        arm.dados[chaveSave(uid: 'A')] = _saveJs(nome: 'A', salvoEm: _hojeMs - 1000);
        await s.entrar('A');
        await s.esperarOcioso();
        expect(repo.saves['A'], isNotNull);
        // B já foi usada neste aparelho (save velho) e jogou muito em outro lugar depois
        final velhoB = _saveJs(nome: 'Bvelho', xp: 10, salvoEm: _hojeMs - 100000);
        final nuvemB = _saveJs(nome: 'Bnovo', xp: 900, salvoEm: _hojeMs - 5000);
        arm.dados[chaveSave(uid: 'B')] = velhoB;
        arm.dados[chaveSincronizado('B')] = '1';
        repo.saves['B'] = DocSave(data: nuvemB, atualizadoEm: _hojeMs - 5000);
        // A muda e o envio fica preso na rede
        final segA = Completer<void>();
        repo.segurar = segA;
        arm.dados[chaveSave(uid: 'A')] = _saveJs(nome: 'A2', salvoEm: _hojeMs);
        arm.dados[chaveSujo('A')] = '1';
        s.alterou('A');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(repo.chamadas.last, 'gravar saves/A');
        await s.sair(limite: const Duration(milliseconds: 10)); // desiste de esperar; o envio continua em voo
        final segB = Completer<void>();
        repo.segurar = segB;
        final fb = s.entrar('B'); // a leitura de B fica presa também
        segA.complete(); // o envio de A termina
        await Future<void>.delayed(const Duration(milliseconds: 10));
        repo.segurar = null;
        segB.complete();
        await fb;
        await s.esperarOcioso();
        expect(repo.saves['B']!.data, nuvemB, reason: 'o save velho de B não pode ter subido às cegas');
        expect(arm.ler(chaveSave(uid: 'B')), nuvemB);
        s.parar();
      });

      test('excluir conta: apagar a nuvem tem teto de tempo (sem rede o batch nunca termina e a folha travava)', () async {
        final repo = RepositorioNuvemMemoria()..segurar = Completer<void>();
        final apagar = apagarNuvemComLimite(repo, limite: const Duration(milliseconds: 20));
        await expectLater(apagar('X'), throwsA(isA<TimeoutException>()));
      });
    });

    test('Pro vem de entitlements/{uid}; sem rede não muda; sair volta a grátis', () async {
      final repo = RepositorioNuvemMemoria()..planos['P1'] = const PlanoServidor(proVitalicio: true);
      final a = _Aparelho(repo);
      await a.abrir();
      await a.e.entrarNaConta(_existente('P1'));
      await a.assentar();
      expect(a.e.ehPro, isTrue);
      await a.e.sairDaConta();
      expect(a.e.ehPro, isFalse);
      repo.falhar = 'unavailable';
      await a.e.entrarNaConta(_existente('P1'));
      await a.assentar();
      expect(a.e.ehPro, isFalse, reason: 'erro nunca libera Pro');
      a.sync.parar();
    });
  });
}

/// Conta falsa em que deslogar faz a nuvem negar tudo (a regra `request.auth.uid == uid`).
class _ContaQueDesliga extends ServicoContaFalso {
  _ContaQueDesliga(this.repo);
  final RepositorioNuvemMemoria repo;
  bool desligou = false;
  @override
  Future<void> sair() async {
    desligou = true;
    repo.logado = '<ninguém>';
    await super.sair();
  }
}
