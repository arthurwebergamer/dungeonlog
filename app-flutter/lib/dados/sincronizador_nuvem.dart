// Motor da sincronização com a nuvem (Fase 6, parte B): `puxarNuvem`/`empurrarNuvem`/`guardarHistorico`/`marcarSujo`
// do app HTML, sobre o [Armazenamento] (as mesmas chaves do localStorage) e um [RepositorioNuvem]. Dart puro (sem
// widgets nem Firebase): os testes usam a nuvem em memória.
//
// Ciclo de vida, por conta:
//  1. [entrar] (login, ou abrir o app com a sessão salva): lê `saves/{uid}` do servidor e aplica a regra
//     [decidirNuvem] direto no armazenamento, ANTES de o jogo abrir os dados da conta. Sem rede: o jogo segue local e
//     uma nova tentativa é agendada (5 s, 15 s, 30 s, 1 min, 2 min, depois a cada 5 min, e ao voltar para o app).
//  2. Enquanto a decisão não deu certo NADA sobe (nunca sobrescreve a nuvem sem tê-la lido).
//  3. Cada alteração de verdade do jogo ([alterou]) já deixou o marcador "sujo" no aparelho; o envio é coalescido
//     ([atraso], 3 s) e só um vai por vez (o seguinte espera; nunca dois `setDoc` da mesma conta em paralelo, a
//     corrida que o original documenta). O toque do jogador nunca espera rede.
//  4. Envio confirmado e nenhuma alteração nova no meio → apaga o "sujo". Falhou → fica, e tenta de novo depois.
//  5. [sair] espera o último envio (até 4 s) ANTES de o login cair (depois a regra negaria o `setDoc`).
import 'dart:async';
import 'dart:convert';

import '../dominio/nuvem.dart';
import '../dominio/save.dart' show chaveSave, chaveConta;
import 'armazenamento.dart';
import 'nuvem.dart';

/// Como foi o [SincronizadorNuvem.entrar].
class ResultadoEntrada {
  const ResultadoEntrada({required this.lido, this.nuvemTemSave = false, this.decisao, this.puxou = false, this.erro});

  /// Conseguiu ler a nuvem (a decisão foi tomada).
  final bool lido;

  /// A nuvem tem um save começado (só vale com [lido]).
  final bool nuvemTemSave;
  final DecisaoNuvem? decisao;

  /// A nuvem venceu e foi gravada no aparelho.
  final bool puxou;

  /// Código do erro quando não leu (`timeout`, `unavailable`, `permission-denied`...). Nunca contém dados do jogador.
  final String? erro;
}

class SincronizadorNuvem {
  SincronizadorNuvem({
    required this.repo,
    required this.armazenamento,
    this.atraso = const Duration(seconds: 3),
    this.limiteGravacao = const Duration(seconds: 15),
    List<Duration>? esperas,
    int Function()? agoraMs,
  })  : esperas = esperas ?? const [Duration(seconds: 5), Duration(seconds: 15), Duration(seconds: 30), Duration(minutes: 1), Duration(minutes: 2), Duration(minutes: 5)],
        _agoraMs = agoraMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final RepositorioNuvem repo;
  final Armazenamento armazenamento;

  /// Quanto esperar depois da última alteração antes de subir (coalesce várias alterações num `setDoc`).
  final Duration atraso;

  /// Teto de espera por um `setDoc` (sem rede o Firestore pode demorar a desistir).
  final Duration limiteGravacao;

  /// Esperas entre tentativas (a última se repete).
  final List<Duration> esperas;
  final int Function() _agoraMs;

  /// Uma decisão feita DEPOIS de o jogo abrir (nova tentativa em segundo plano) baixou a nuvem: quem guarda o estado em
  /// memória precisa reler o armazenamento JÁ (é chamado antes de qualquer outra coisa poder gravar).
  void Function()? aoPuxarEmSegundoPlano;

  /// Resultado de `entitlements/{uid}` (só quando a leitura deu certo: sem rede nunca rebaixa nem promove).
  void Function(PlanoServidor plano)? aoLerPlano;

  String? _uid;
  String? get uid => _uid;
  bool _pronto = false;

  /// A nuvem desta conta já foi lida nesta sessão (só então os envios saem).
  bool get pronto => _pronto;
  bool _pausado = false;
  int _seq = 0;
  int _geracao = 0;
  Timer? _timerEnvio;
  Timer? _timerTentativa;
  Timer? _timerReenvio;
  int _tentativas = 0;
  int _reenvios = 0;
  bool _decidindo = false;
  Future<void>? _emVoo;
  bool _deNovo = false;
  final Set<Future<void>> _pendentes = {};

  /// Envios que falharam seguidos e o código do último erro (diagnóstico; sem dados do jogador).
  int falhasSeguidas = 0;
  String? ultimoErro;

  Armazenamento get _arm => armazenamento;
  String _ms() => '${_agoraMs()}';

  bool _sujo(String uid) => _arm.ler(chaveSujo(uid)) != null;
  String _ativo(String uid) {
    final p = _arm.ler(chavePersonagemAtivoConta(uid));
    return p == null || p.isEmpty ? 'pj1' : p;
  }

  void _rastrear(Future<void> f) {
    late final Future<void> g;
    g = f.catchError((Object _) {}).whenComplete(() => _pendentes.remove(g));
    _pendentes.add(g);
  }

  /// Espera tudo que está em andamento (envios, histórico, leituras). Não espera os temporizadores (ver [descarregar]).
  Future<void> esperarOcioso() async {
    while (_pendentes.isNotEmpty) {
      await Future.wait(_pendentes.toList());
    }
  }

  void _cancelarTimers() {
    _timerEnvio?.cancel();
    _timerTentativa?.cancel();
    _timerReenvio?.cancel();
    _timerEnvio = _timerTentativa = _timerReenvio = null;
  }

  // ---------------------------------------------------------------- entrar / sair
  /// Liga a conta [uid] e decide local x nuvem (ver o topo do arquivo). [limite]: quanto esperar pela leitura antes de
  /// desistir desta vez (a tentativa seguinte vai em segundo plano).
  Future<ResultadoEntrada> entrar(String uid, {Duration limite = const Duration(seconds: 10)}) async {
    if (_uid != null && _uid != uid) await sair();
    _cancelarTimers();
    _uid = uid;
    _pronto = false;
    _pausado = false;
    _tentativas = 0;
    _reenvios = 0;
    final ger = ++_geracao;
    _lerPlano(uid, ger);
    final r = await _decidir(uid, ger, limite, segundoPlano: false);
    if (!r.lido && ger == _geracao) _agendarTentativa();
    return r;
  }

  /// "Sair": sobe o que falta (esperando até [limite]) e desliga a conta. Chamar ANTES de deslogar.
  Future<void> sair({Duration limite = const Duration(seconds: 4)}) async {
    await descarregar(limite: limite);
    parar();
  }

  /// Desliga sem subir nada (excluir conta, ou conta que sumiu).
  void parar() {
    _geracao++;
    _cancelarTimers();
    _uid = null;
    _pronto = false;
    _pausado = false;
  }

  /// Segura os envios (excluir conta: nada pode recriar `saves/{uid}` enquanto ele é apagado). Espera o envio em voo.
  Future<void> pausar({Duration limite = const Duration(seconds: 4)}) async {
    _pausado = true;
    _cancelarTimers();
    final f = _emVoo;
    if (f != null) {
      try {
        await f.timeout(limite);
      } catch (_) {}
    }
  }

  /// Desfaz [pausar] (a exclusão falhou ou foi cancelada).
  void retomar() {
    _pausado = false;
    final u = _uid;
    if (u != null && _pronto && _sujo(u)) _agendarEnvio();
  }

  // ---------------------------------------------------------------- alterações e envio
  /// O jogo gravou uma alteração de verdade na conta [uid] (o marcador "sujo" já está no aparelho).
  void alterou(String uid) {
    if (uid != _uid) return;
    _seq++;
    if (!_pronto || _pausado) return;
    _agendarEnvio();
  }

  void _agendarEnvio() {
    _timerEnvio?.cancel();
    _timerEnvio = Timer(atraso, () {
      _timerEnvio = null;
      _rastrear(_bombear());
    });
  }

  /// Sobe agora o que estiver pendente (app indo para o fundo, sair). Espera no máximo [limite].
  Future<void> descarregar({Duration limite = const Duration(seconds: 4)}) async {
    final u = _uid;
    _timerEnvio?.cancel();
    _timerEnvio = null;
    if (u == null || !_pronto || _pausado) return;
    if (!_sujo(u) && _emVoo == null) return;
    final f = _bombear();
    _rastrear(f);
    try {
      await f.timeout(limite);
    } catch (_) {}
  }

  /// O app voltou para a frente: se a nuvem ainda não foi lida, tenta agora; se há algo para subir, sobe.
  void aoVoltar() {
    final u = _uid;
    if (u == null || _pausado) return;
    if (!_pronto) {
      if (!_decidindo) {
        _timerTentativa?.cancel();
        _rastrear(_tentarDecidir());
      }
    } else if (_sujo(u)) {
      _rastrear(_bombear());
    }
  }

  /// Um envio por vez; o que chegar durante o voo sai logo depois, com o estado mais novo.
  /// O laço é PRESO à conta e à geração em que nasceu (revisão extra): um envio que ficou em voo depois de "Sair" nunca
  /// continua na conta que entrou em seguida (subiria o save local dela antes de a nuvem dela ser lida).
  Future<void> _bombear() {
    final uid = _uid;
    if (!_pronto || _pausado || uid == null) return Future.value();
    final atual = _emVoo;
    if (atual != null && _emVooGer == _geracao) {
      _deNovo = true;
      return atual;
    }
    final ger = _geracao;
    final f = _laco(uid, ger);
    _emVoo = f;
    _emVooGer = ger;
    return f.whenComplete(() {
      if (identical(_emVoo, f)) _emVoo = null;
    });
  }

  int _emVooGer = -1;
  bool _vivo(int ger) => ger == _geracao && _pronto && !_pausado;

  Future<void> _laco(String uid, int ger) async {
    do {
      _deNovo = false;
      final ok = await _empurrar(uid, ger);
      if (!ok) {
        if (ger == _geracao) _agendarReenvio();
        return;
      }
    } while (_deNovo && _vivo(ger));
  }

  /// `empurrarNuvem`: sobe o save e as extras do herói ATIVO da conta [uid]. Devolve false se falhou.
  Future<bool> _empurrar(String uid, int ger) async {
    if (!_vivo(ger)) return true;
    final pj = _ativo(uid);
    final data = _arm.ler(chaveSave(uid: uid, personagem: pj));
    if (!saveComecado(data)) return true; // SEGURO: nunca sobe um save vazio (o original subia `data: ''`)
    final extras = montarExtras(_arm.ler, uid: uid, pj: pj);
    final seq = _seq;
    final em = _agoraMs();
    try {
      await repo.gravarSave(uid, DocSave(data: data, extras: extras, atualizadoEm: em, pj: pj)).timeout(limiteGravacao);
    } catch (e) {
      falhasSeguidas++;
      ultimoErro = e is ErroNuvem ? e.codigo : (e is TimeoutException ? 'timeout' : 'erro');
      return false;
    }
    falhasSeguidas = 0;
    ultimoErro = null;
    _reenvios = 0;
    if (seq == _seq) await _arm.remover(chaveSujo(uid)); // nada mudou durante o envio: a nuvem está igual ao aparelho
    await _arm.gravar(chaveSincronizado(uid), '$em');
    await _arm.gravar(chaveBaseNuvem(uid), '$em');
    _rastrear(_historico(uid, data!, extras)); // sem esperar: não atrasa nem derruba o envio principal
    return true;
  }

  void _agendarReenvio() {
    if (_pausado || _uid == null) return;
    final d = esperas[_reenvios < esperas.length ? _reenvios : esperas.length - 1];
    _reenvios++;
    _timerReenvio?.cancel();
    _timerReenvio = Timer(d, () {
      _timerReenvio = null;
      _rastrear(_bombear());
    });
  }

  // ---------------------------------------------------------------- decisão (puxarNuvem)
  void _agendarTentativa() {
    if (_uid == null) return;
    final d = esperas[_tentativas < esperas.length ? _tentativas : esperas.length - 1];
    _tentativas++;
    _timerTentativa?.cancel();
    _timerTentativa = Timer(d, () {
      _timerTentativa = null;
      _rastrear(_tentarDecidir());
    });
  }

  Future<void> _tentarDecidir() async {
    final uid = _uid;
    if (uid == null || _pronto) return;
    final ger = _geracao;
    final r = await _decidir(uid, ger, const Duration(seconds: 10), segundoPlano: true);
    if (!r.lido && ger == _geracao && !_pronto) _agendarTentativa();
  }

  Future<ResultadoEntrada> _decidir(String uid, int ger, Duration limite, {required bool segundoPlano}) async {
    _decidindo = true;
    DocSave? doc;
    try {
      doc = await repo.lerSave(uid).timeout(limite);
    } catch (e) {
      return ResultadoEntrada(lido: false, erro: e is ErroNuvem ? e.codigo : (e is TimeoutException ? 'timeout' : 'erro'));
    } finally {
      _decidindo = false;
    }
    if (ger != _geracao) return const ResultadoEntrada(lido: false, erro: 'cancelado');
    return _aplicar(uid, doc, segundoPlano: segundoPlano);
  }

  /// Aplica a regra com o estado do aparelho DESTE instante (lido depois da rede, então uma alteração feita durante a
  /// leitura já conta como "sujo"). Tudo que mexe no armazenamento é disparado antes de qualquer `await`.
  Future<ResultadoEntrada> _aplicar(String uid, DocSave? doc, {required bool segundoPlano}) async {
    final ativo = _ativo(uid);
    final alvo = doc?.pj ?? ativo; // documento do HTML não diz o herói: vale o ativo do aparelho (como no original)
    final mesmo = alvo == ativo;
    final sujo = _sujo(uid);
    final jaSinc = _arm.ler(chaveSincronizado(uid)) != null;
    final carimbo = '${doc?.atualizadoEm ?? ''}';
    final base = _arm.ler(chaveBaseNuvem(uid)); // null = aparelho de antes da base: comportamento antigo (regra 1)
    final kAlvo = chaveSave(uid: uid, personagem: alvo);
    final local = _arm.ler(kAlvo);
    final dec = decidirNuvem(sujo: sujo && mesmo, jaSincronizou: jaSinc, nuvemMudou: base != null && base != carimbo, local: local, nuvem: doc?.data);
    final gravs = <Future<void>>[];
    var puxou = false, subir = false, sujar = false;
    switch (dec.acao) {
      case AcaoNuvem.puxar:
        if (dec.backupLocal && local != null && local.isNotEmpty) gravs.add(_backupLocal(uid, alvo, local));
        const kh = 'questlog.hist.v1';
        final histLocal = _arm.ler(chaveConta(kh, uid: uid, personagem: alvo));
        if (mesmo) gravs.add(_arm.remover(chaveSujo(uid)));
        gravs.add(_arm.gravar(kAlvo, doc!.data!));
        gravacoesDeExtras(doc.extras, uid: uid, pj: alvo).forEach((k, v) => gravs.add(_arm.gravar(k, v)));
        // dias fechados só neste aparelho não somem (o `recarregarHistoricoNuvem` do original)
        if (doc.extras.containsKey(kh)) {
          final m = mesclarHist(doc.extras[kh], histLocal);
          if (m != null) {
            gravs.add(_arm.gravar(chaveConta(kh, uid: uid, personagem: alvo), m));
            if (mesmo) sujar = true;
          }
        }
        _garantirNaLista(uid, alvo, gravs);
        if (!mesmo && !saveComecado(_arm.ler(chaveSave(uid: uid, personagem: ativo)))) {
          gravs.add(_arm.gravar(chavePersonagemAtivoConta(uid), alvo)); // aparelho sem herói jogado: abre o da nuvem
        }
        puxou = true;
      case AcaoNuvem.empurrar:
        if (dec.nuvemNoHistorico && doc?.data != null) _rastrear(_historico(uid, doc!.data!, doc.extras, forcar: true));
        if (mesmo) subir = true;
      case AcaoNuvem.nada:
        break;
    }
    if (!mesmo && sujo) subir = true; // a nuvem tinha outro herói: o ativo, alterado aqui, sobe (o outro ficou guardado)
    if (sujar) {
      gravs.add(_arm.gravar(chaveSujo(uid), _ms()));
      _seq++;
      subir = true;
    }
    gravs.add(_arm.gravar(chaveSincronizado(uid), _ms()));
    gravs.add(_arm.gravar(chaveBaseNuvem(uid), carimbo));
    _pronto = true;
    _tentativas = 0;
    if (puxou && segundoPlano) aoPuxarEmSegundoPlano?.call();
    await Future.wait(gravs);
    if (subir || _sujo(uid)) _rastrear(_bombear());
    return ResultadoEntrada(lido: true, nuvemTemSave: saveComecado(doc?.data), decisao: dec, puxou: puxou);
  }

  /// `guardarBackupLocal`: as 3 últimas cópias do save local (com as extras) antes de a nuvem sobrescrever.
  Future<void> _backupLocal(String uid, String pj, String dados) async {
    final k = chaveBackupLocal(uid);
    var lista = <Object?>[];
    try {
      final d = jsonDecode(_arm.ler(k) ?? '[]');
      if (d is List) lista = d;
    } catch (_) {}
    lista.insert(0, {'em': _agoraMs(), 'data': dados, 'extras': montarExtras(_arm.ler, uid: uid, pj: pj)});
    await _arm.gravar(k, jsonEncode(lista.take(3).toList()));
  }

  /// O herói que veio da nuvem precisa estar na lista da conta (senão o jogo não o mostra).
  void _garantirNaLista(String uid, String pj, List<Future<void>> gravs) {
    final k = chavePersonagensConta(uid);
    var l = <Object?>[];
    try {
      final d = jsonDecode(_arm.ler(k) ?? '[]');
      if (d is List) l = d;
    } catch (_) {}
    if (l.isEmpty) {
      if (pj == 'pj1') return; // sem lista gravada o jogo já assume [pj1]
      if (saveComecado(_arm.ler(chaveSave(uid: uid, personagem: 'pj1')))) l.add({'id': 'pj1', 'nome': null, 'criadoEm': null});
    }
    if (l.any((p) => p is Map && p['id'] == pj)) return;
    l.add({'id': pj, 'nome': null, 'criadoEm': null});
    gravs.add(_arm.gravar(k, jsonEncode(l)));
  }

  /// `guardarHistorico`: h{n} a cada 30 min (ou já, se [forcar]) e d{dia%14} 1x por dia. Falha em silêncio.
  /// Os marcadores andam ANTES do envio (como no original: uma falha não faz tentar a cada envio).
  Future<void> _historico(String uid, String data, Map<String, String> extras, {bool forcar = false}) async {
    if (data.isEmpty) return;
    final kb = chaveHistNuvem(uid);
    int lerN(String suf) => int.tryParse(_arm.ler('$kb.$suf') ?? '') ?? 0;
    final agora = _agoraMs();
    final q = docsHistorico(agoraMs: agora, ultH: lerN('h'), ultD: lerN('d'), n: lerN('n'), forcar: forcar);
    final envios = <Future<void>>[];
    if (q.h != null) {
      await _arm.gravar('$kb.h', '$agora');
      await _arm.gravar('$kb.n', '${q.proximoN}');
      envios.add(repo.gravarHistorico(uid, q.h!, data: data, extras: extras, em: agora).timeout(limiteGravacao));
    }
    if (q.d != null) {
      await _arm.gravar('$kb.d', '$agora');
      envios.add(repo.gravarHistorico(uid, q.d!, data: data, extras: extras, em: agora).timeout(limiteGravacao));
    }
    try {
      await Future.wait(envios);
    } catch (_) {}
  }

  void _lerPlano(String uid, int ger) {
    _rastrear(repo.lerPlano(uid).timeout(const Duration(seconds: 10)).then((p) {
      if (ger == _geracao) aoLerPlano?.call(p);
    }));
  }
}
