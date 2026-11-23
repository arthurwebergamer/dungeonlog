// Sincronização do save com a nuvem (Fase 6, parte B): as regras PURAS, sem Firebase nem relógio de verdade.
//
// Formato (o mesmo do app HTML, play/index.html, `empurrarNuvem`/`puxarNuvem`/`guardarHistorico`, ~18770-18937):
//   saves/{uid}                  { data, extras, atualizadoEm }       (+ `pj`, só o Flutter grava; o HTML ignora)
//   saves/{uid}/historico/h{0..5} { data, extras, em }   a cada 30 min, rodando
//   saves/{uid}/historico/d{0..13}{ data, extras, em }   1x por dia (dia UTC % 14)
//   entitlements/{uid}           só LEITURA (proVitalicio, assinaturaAte, assinaturaProduto)
//
//  - `data`   = o texto do save v3 do herói ATIVO (`localStorage[chaveSaveAtual()]`), sem mexer em nada.
//  - `extras` = {chaveBase: texto} das chaves de `CHAVES_SECUNDARIAS_CONTA` do herói ativo que existem no aparelho,
//               menos `questlog.dia.v1` (deslocamento de dia do menu de debug: nunca sobe nem desce).
//
// A REGRA DE DECISÃO está em [decidirNuvem] e a tabela completa em FASE6.md ("Parte B").
import 'dart:convert';

import 'js_compat.dart' show numeroOu0;
import 'save.dart' show chaveConta;

/// `CHAVES_SECUNDARIAS_CONTA` do original, na mesma ordem (play/index.html ~2120). Toda chave por conta e por herói que
/// é progresso de jogo. Muitas o Flutter ainda não usa (atributos, trial, hpMonstro...): mesmo assim descem da nuvem e
/// sobem de volta intactas, para o app HTML na mesma conta não perder nada.
const List<String> chavesSecundariasConta = [
  'questlog.atrib.v1',
  'questlog.bauDia.v1',
  'questlog.bauLog.v1',
  'questlog.bauSemEspecial.v1',
  'questlog.celebracaoDiaMostrada.v1',
  'questlog.conquistasDesbloqueadasV2.v1',
  'questlog.conquistasResgatadas.v1',
  'questlog.conquistasVistasV2.v1',
  'questlog.dia.v1',
  'questlog.descanso.v1',
  'questlog.estagioCerimoniaMostrada.v1',
  'questlog.hist.v1',
  'questlog.hpMonstro.v1',
  'questlog.itensVistos.v1',
  'questlog.loja.v1',
  'questlog.tarefasConcluidas.v1',
  'questlog.temaArena.v1',
  'questlog.temasDesbloqueados.v1',
  'questlog.trial.v1',
  'questlog.vida.v1',
];

/// Só do aparelho (debug "avançar dia"): nunca vai nem vem da nuvem.
const String chaveDiaDebug = 'questlog.dia.v1';

/// Folga do relógio entre aparelhos: o local só vence se for mais de 2 s mais novo (`tLocal > tNuvem + 2000`).
const int folgaRelogioMs = 2000;

// ---------- chaves locais da sincronização (por conta; mesmos nomes do original) ----------
/// "Há alteração local que ainda não chegou na nuvem" (`questlog.sujo.v1.uid.<uid>`, valor = ms).
String chaveSujo(String uid) => 'questlog.sujo.v1.uid.$uid';

/// Últimas 3 cópias do save local antes de a nuvem sobrescrever (`guardarBackupLocal`): `[{em, data, extras}]`.
String chaveBackupLocal(String uid) => 'questlog.backupLocal.v1.uid.$uid';

/// Base dos marcadores do histórico na nuvem (`.h` último h, `.d` último d, `.n` próximo h).
String chaveHistNuvem(String uid) => 'questlog.histNuvem.v1.uid.$uid';

/// SÓ DO FLUTTER: ms da última vez que este aparelho falou com sucesso com a nuvem desta conta (leu ou gravou o save).
/// Sem ele a conta "nunca sincronizou aqui" e a regra usa a proteção de progresso (ver [decidirNuvem]).
String chaveSincronizado(String uid) => 'questlog.nuvemSync.v1.uid.$uid';

/// SÓ DO FLUTTER: o `atualizadoEm` de `saves/{uid}` na última vez que este aparelho leu ou gravou a nuvem (texto vazio =
/// sem documento/sem carimbo). Se a nuvem lida tiver outro, alguém gravou depois (ver `nuvemMudou` em [decidirNuvem]).
/// Compara o valor exato (não relógios), então não depende do relógio de nenhum aparelho.
String chaveBaseNuvem(String uid) => 'questlog.nuvemBase.v1.uid.$uid';

/// Lista de heróis da conta e herói ativo (as mesmas chaves do original e do EstadoJogo).
String chavePersonagensConta(String uid) => 'questlog.personagens.v1.uid.$uid';
String chavePersonagemAtivoConta(String uid) => 'questlog.personagemAtivo.v1.uid.$uid';

/// O documento `saves/{uid}` já lido. [data] vazio/nulo = sem save (o HTML grava `data: ''` quando não há save local).
class DocSave {
  const DocSave({required this.data, this.extras = const {}, this.atualizadoEm, this.pj});
  final String? data;
  final Map<String, String> extras;
  final int? atualizadoEm;

  /// Herói a que [data] pertence (só o Flutter grava; documento do HTML não tem e vale o herói ativo do aparelho).
  final String? pj;

  /// O que vai para o Firestore (o `setDoc` do original + `pj`).
  Map<String, Object?> paraMapa() => {
        'data': data ?? '',
        'extras': extras,
        'atualizadoEm': atualizadoEm,
        if (pj != null) 'pj': pj,
      };
}

final RegExp _rePj = RegExp(r'^pj[0-9a-z]+$');

/// Lê o mapa do Firestore com defesa: `data` só se for texto; `extras` só com valores texto (número/booleano viram
/// texto, como o `localStorage.setItem` faria); `pj` só se tiver a cara de um id de herói.
DocSave docSaveDeMapa(Map<String, Object?> m) {
  final d = m['data'];
  final ex = <String, String>{};
  final e = m['extras'];
  if (e is Map) {
    for (final en in e.entries) {
      final k = en.key, v = en.value;
      if (k is! String) continue;
      if (v is String) {
        ex[k] = v;
      } else if (v is num || v is bool) {
        ex[k] = '$v';
      }
    }
  }
  final a = m['atualizadoEm'];
  final pj = m['pj'];
  return DocSave(
    data: d is String ? d : null,
    extras: ex,
    atualizadoEm: a is num ? a.toInt() : null,
    pj: pj is String && _rePj.hasMatch(pj) ? pj : null,
  );
}

/// `lerSalvoEm(str)`: `Number(JSON.parse(str).salvoEm) || 0` (texto numérico vale; inválido ou ausente = 0).
num lerSalvoEm(String? s) {
  if (s == null) return 0;
  try {
    final d = jsonDecode(s);
    if (d is Map) return numeroOu0(d['salvoEm']);
  } catch (_) {}
  return 0;
}

/// Save "de verdade": JSON válido com `comecou` verdadeiro (o `_carregarBase` do original devolve false sem isso).
bool saveComecado(String? s) {
  if (s == null || s.isEmpty) return false;
  try {
    final d = jsonDecode(s);
    final c = d is Map ? d['comecou'] : null;
    return c != null && c != false && c != 0 && c != '';
  } catch (_) {
    return false;
  }
}

/// XP total do save (medida de progresso; no jogo o XP só sobe). 0 se inválido.
num xpDoSave(String? s) {
  if (s == null) return 0;
  try {
    final d = jsonDecode(s);
    if (d is Map) return numeroOu0(d['xpTotal']);
  } catch (_) {}
  return 0;
}

/// Monta `extras` (o laço de `empurrarNuvem`): as chaves secundárias do herói [pj] da conta [uid] que existem.
Map<String, String> montarExtras(String? Function(String chave) ler, {required String uid, required String pj}) {
  final ex = <String, String>{};
  for (final base in chavesSecundariasConta) {
    if (base == chaveDiaDebug) continue;
    final v = ler(chaveConta(base, uid: uid, personagem: pj));
    if (v != null) ex[base] = v;
  }
  return ex;
}

/// O que gravar no aparelho ao baixar [extras] (o laço de `puxarNuvem`): só o que veio da nuvem, nunca apaga uma chave
/// local que a nuvem não tinha, nunca o dia de debug. Chaves fora da lista oficial são ignoradas.
Map<String, String> gravacoesDeExtras(Map<String, String> extras, {required String uid, required String pj}) => {
      for (final base in chavesSecundariasConta)
        if (base != chaveDiaDebug && extras.containsKey(base)) chaveConta(base, uid: uid, personagem: pj): extras[base]!,
    };

/// `recarregarHistoricoNuvem` generalizado: o histórico da nuvem vence por data, e os dias que só o aparelho tem são
/// acrescentados no fim (nunca some um dia fechado aqui). Trabalha no JSON cru (preserva campos desconhecidos).
/// Devolve null se o resultado é o próprio texto da nuvem (nada a acrescentar).
String? mesclarHist(String? nuvem, String? local) {
  List<Object?> lista(String? s) {
    if (s == null) return [];
    try {
      final d = jsonDecode(s);
      return d is List ? d : [];
    } catch (_) {
      return [];
    }
  }

  final n = lista(nuvem), l = lista(local);
  final datas = {for (final e in n) if (e is Map) e['data']};
  final extra = [for (final e in l) if (e is Map && e['data'] is String && !datas.contains(e['data'])) e];
  if (extra.isEmpty) return null;
  return jsonEncode([...n, ...extra]);
}

// ---------- a regra de decisão ----------
enum AcaoNuvem {
  /// O aparelho vence: sobe o save local (a nuvem fica igual ao local).
  empurrar,

  /// A nuvem vence: baixa `data` e `extras` por cima do local.
  puxar,

  /// Nada a fazer (nenhum dos dois tem save).
  nada,
}

class DecisaoNuvem {
  const DecisaoNuvem(this.acao, this.motivo, {this.backupLocal = false, this.nuvemNoHistorico = false});
  final AcaoNuvem acao;

  /// Guardar a cópia do save local (últimas 3) antes de a nuvem sobrescrever (`guardarBackupLocal`).
  final bool backupLocal;

  /// Guardar a cópia da nuvem no histórico (`guardarHistorico(..., forcar=true)`) antes de o local sobrescrever.
  final bool nuvemNoHistorico;

  /// Linha da tabela (para teste e diagnóstico; nunca contém dados do jogador).
  final String motivo;

  @override
  String toString() => 'DecisaoNuvem(${acao.name}, $motivo${backupLocal ? ', backupLocal' : ''}${nuvemNoHistorico ? ', nuvemNoHistorico' : ''})';
}

/// Qual save vence ao entrar na conta (login, ou abrir o app com a sessão salva). Mesma regra do `puxarNuvem` do original,
/// com o lado seguro onde ele é perigoso (marcado SEGURO; ver a tabela em FASE6.md):
///
///  [sujo]: há alteração local que nunca chegou na nuvem. [jaSincronizou]: este aparelho já falou com a nuvem desta conta
///  antes. [local]: o save do herói no aparelho. [nuvem]: `data` do documento (null = sem documento).
///
///  1. sujo e já sincronizou → EMPURRAR (HTML). SEGURO: se o local não é um save começado, não sobe vazio por cima: puxa
///     a nuvem (ou nada). SEGURO: se a nuvem é diferente, a cópia dela vai para o histórico antes.
///  2. nuvem sem save começado (sem doc, `data` vazio, JSON inválido, `comecou` falso) → local começado: EMPURRAR; senão
///     NADA. (HTML: deixa o local e espera o próximo salvar; e baixaria um save não começado por cima — SEGURO não baixa.)
///  3. local sem save começado → PUXAR (backup se havia algum texto local).
///  4. igual (mesmo texto) → PUXAR (só as extras mudam; HTML).
///  5. diferentes, os dois começados:
///     a. nunca sincronizou neste aparelho e os XP diferem → SEGURO: vence o de MAIS progresso (XP), o outro vai para o
///        backup/histórico. (O save daqui pode ter nascido offline/como convidado sem conhecer a nuvem.)
///     b. tLocal e tNuvem ≠ 0 e tLocal > tNuvem + 2 s → EMPURRAR, cópia da nuvem no histórico (HTML).
///     c. tLocal ≠ 0 e tNuvem == 0 → SEGURO: EMPURRAR (save da nuvem sem carimbo é de versão antiga; HTML puxaria).
///     d. senão → PUXAR, backup do local (HTML).
///
///  [nuvemMudou] (revisão extra): o `atualizadoEm` da nuvem NÃO é o da última vez que este aparelho leu/gravou a nuvem
///  (outro aparelho ou o app HTML gravou depois). Com "sujo" isso é CONFLITO: a alteração local foi feita em cima de um
///  save que a nuvem já tinha deixado para trás (ex.: abrir com a nuvem lenta, passar dos 3 s e tocar no save velho).
///  Aí a regra 1 não vale: decide como 5a (mais XP) e depois pelo carimbo; o perdedor vai para backup/histórico.
DecisaoNuvem decidirNuvem({required bool sujo, required bool jaSincronizou, bool nuvemMudou = false, required String? local, required String? nuvem}) {
  final localOk = saveComecado(local);
  final nuvemOk = saveComecado(nuvem);
  final conflito = sujo && jaSincronizou && nuvemMudou;
  if (sujo && jaSincronizou && !conflito) {
    if (!localOk) {
      return nuvemOk
          ? DecisaoNuvem(AcaoNuvem.puxar, '1-sujo-local-vazio', backupLocal: local != null && local.isNotEmpty)
          : const DecisaoNuvem(AcaoNuvem.nada, '1-sujo-nada');
    }
    return DecisaoNuvem(AcaoNuvem.empurrar, '1-sujo', nuvemNoHistorico: nuvemOk && nuvem != local);
  }
  if (!nuvemOk) {
    return localOk ? const DecisaoNuvem(AcaoNuvem.empurrar, '2-nuvem-vazia') : const DecisaoNuvem(AcaoNuvem.nada, '2-nada');
  }
  if (!localOk) return DecisaoNuvem(AcaoNuvem.puxar, '3-local-vazio', backupLocal: local != null && local.isNotEmpty);
  if (local == nuvem) return const DecisaoNuvem(AcaoNuvem.puxar, '4-igual');
  if (!jaSincronizou || conflito) {
    final xl = xpDoSave(local), xn = xpDoSave(nuvem);
    if (xl > xn) return const DecisaoNuvem(AcaoNuvem.empurrar, '5a-mais-xp-local', nuvemNoHistorico: true);
    if (xn > xl) return const DecisaoNuvem(AcaoNuvem.puxar, '5a-mais-xp-nuvem', backupLocal: true);
  }
  final tl = lerSalvoEm(local), tn = lerSalvoEm(nuvem);
  if (tl != 0 && tn != 0 && tl > tn + folgaRelogioMs) {
    return const DecisaoNuvem(AcaoNuvem.empurrar, '5b-local-mais-novo', nuvemNoHistorico: true);
  }
  if (tl != 0 && tn == 0) return const DecisaoNuvem(AcaoNuvem.empurrar, '5c-nuvem-sem-carimbo', nuvemNoHistorico: true);
  return const DecisaoNuvem(AcaoNuvem.puxar, '5d-nuvem', backupLocal: true);
}

// ---------- histórico na nuvem (`guardarHistorico`) ----------
/// Quais documentos de histórico gravar agora. [ultH]/[ultD] = ms do último h/d gravado, [n] = contador de h.
/// h{n%6} a cada 30 min (ou sempre, se [forcar]); d{dia%14} se o dia UTC mudou desde o último d.
({String? h, String? d, int proximoN}) docsHistorico({required int agoraMs, required int ultH, required int ultD, required int n, bool forcar = false}) {
  final dia = agoraMs ~/ 86400000;
  String? h;
  var prox = n;
  if (forcar || agoraMs - ultH >= 30 * 60 * 1000) {
    final i = n % 6;
    h = 'h$i';
    prox = i + 1;
  }
  final d = (ultD ~/ 86400000) != dia ? 'd${dia % 14}' : null;
  return (h: h, d: d, proximoN: prox);
}

/// Todos os ids possíveis de `saves/{uid}/historico` (para apagar a conta inteira).
const List<String> idsHistorico = ['h0', 'h1', 'h2', 'h3', 'h4', 'h5', 'd0', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8', 'd9', 'd10', 'd11', 'd12', 'd13'];

// ---------- entitlements/{uid} (só leitura) ----------
class PlanoServidor {
  const PlanoServidor({this.proVitalicio = false, this.assinaturaAte = 0, this.assinaturaProduto = ''});
  final bool proVitalicio;
  final int assinaturaAte;
  final String assinaturaProduto;

  /// `assinaturaAtiva()` vinda do servidor: vitalício ou assinatura ainda no prazo.
  bool ehPro(int agoraMs) => proVitalicio || assinaturaAte > agoraMs;
}

/// `puxarEntitlement`: doc ausente = sem plano. `proVitalicio` só vale se for exatamente true.
PlanoServidor planoDeMapa(Map<String, Object?>? m) {
  if (m == null) return const PlanoServidor();
  final a = m['assinaturaAte'];
  final p = m['assinaturaProduto'];
  return PlanoServidor(
    proVitalicio: m['proVitalicio'] == true,
    assinaturaAte: a is num && a.isFinite ? a.toInt() : (a is String ? (int.tryParse(a) ?? 0) : 0),
    assinaturaProduto: p == null ? '' : '$p',
  );
}
