// Estado do jogo da aba Tarefas (ChangeNotifier). Junta o save v3, a vida e os contadores da conta e aplica as
// regras de play/index.html: alternar() (~6388), criar() (~6759), terminarDia() (~2860), verificarVirada() (~10721).
// Toda regra de conta vem de lib/dominio (testada contra o JS); aqui só a orquestração e a gravação.
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../dados/armazenamento.dart';
import '../dominio/catalogo.dart';
import '../dominio/dados_jogo.dart';
import '../dominio/datas.dart';
import '../dominio/economia.dart';
import '../dominio/js_compat.dart';
import '../dominio/loot.dart';
import '../dominio/regras.dart';
import '../dominio/save.dart';
import '../dominio/tarefa.dart';
import '../dominio/vida.dart';

const _chaveVida = 'questlog.vida.v1';
const _chaveDescanso = 'questlog.descanso.v1';
const _chaveConcluidas = 'questlog.tarefasConcluidas.v1';
const _chaveTemaArena = 'questlog.temaArena.v1';
const _chaveBauDia = 'questlog.bauDia.v1';

/// O que a virada do dia causou, para a interface avisar uma vez.
class EventoVirada {
  final int largadas;
  final int dano;
  final bool caiu;
  final int moedasPerdidas;
  final bool vitoriaAutomatica;
  const EventoVirada({required this.largadas, required this.dano, required this.caiu, required this.moedasPerdidas, required this.vitoriaAutomatica});
}

/// Ganho de uma conclusão (para o aviso "+XP +moedas").
class GanhoTarefa {
  final int xp;
  final int moedas;
  final bool subiuNivel;
  final int nivel;
  final bool parcial; // toque de uma tarefa com meta > 1 que ainda não completou
  const GanhoTarefa({required this.xp, required this.moedas, required this.subiuNivel, required this.nivel, required this.parcial});
}

class ModoTarefa {
  ModoTarefa._();
  static const hoje = 'hoje';
  static const repete = 'repete';
  static const mensal = 'mensal';
  static const anual = 'anual';
}

class EstadoJogo extends ChangeNotifier {
  EstadoJogo({
    required this.dados,
    required this.armazenamento,
    DateTime Function()? agora,
    this.idioma = 'pt',
    this.uid,
    this.personagem = 'pj1',
    Random? aleatorio,
  })  : _agora = agora ?? DateTime.now,
        _aleatorio = aleatorio ?? Random();

  final DadosJogo dados;
  final Armazenamento armazenamento;
  final String idioma;
  final String? uid;
  final String personagem;
  final DateTime Function() _agora;
  final Random _aleatorio;

  late SaveV3 save;
  int vida = 0;
  String? ultimoDia;
  List<String> descanso = [];
  int totalConcluidas = 0;

  /// Baú do dia (`questlog.bauDia.v1`): `{dia, padrao:{ids,aberto}, especial, extra}`. Só o padrão existe por enquanto.
  Map<String, dynamic>? bauDia;
  EventoVirada? eventoPendente;
  final AcumuladorMoedas _acumulador = AcumuladorMoedas();

  Catalogo get catalogo => dados.catalogo;

  // ---------- inicialização ----------
  Future<void> iniciar() async {
    final bruto = armazenamento.ler(chaveSave(uid: uid, personagem: personagem));
    final semente = _aleatorio.nextInt(64);
    final carregado = SaveV3.carregar(bruto, catalogo, idioma: idioma, sementeAtual: semente);
    save = carregado ?? SaveV3.padrao(catalogo, idioma: idioma, semente: semente);

    final v = _lerJson(chaveConta(_chaveVida, uid: uid, personagem: personagem));
    int? vidaSalva;
    if (v is Map && v['vida'] is num) {
      vidaSalva = (v['vida'] as num).toInt();
      ultimoDia = v['ultimoDia'] is String && (v['ultimoDia'] as String).isNotEmpty ? v['ultimoDia'] as String : null;
    }
    vida = vidaSalva ?? vidaMaxima;

    final d = _lerJson(chaveConta(_chaveDescanso, uid: uid, personagem: personagem));
    descanso = d is List ? [for (final x in d) if (x is String) x] : [];
    totalConcluidas =
        numeroOu0(armazenamento.ler(chaveConta(_chaveConcluidas, uid: uid, personagem: personagem))).toInt();

    final b = _lerJson(chaveConta(_chaveBauDia, uid: uid, personagem: personagem));
    bauDia = b is Map ? Map<String, dynamic>.from(b) : null;

    verificarDia();
    _garantirBau();
    await _salvarTudo();
  }

  Object? _lerJson(String chave) {
    try {
      final s = armazenamento.ler(chave);
      return s == null ? null : jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  // ---------- leituras ----------
  String get hoje => isoDe(_agora());
  Equipado get _equipado => save.equipado;
  BonusEquip get bonus => bonusEquip(catalogo, _equipado);
  Progresso get progressoAtual => progresso(save.xpTotal);
  int get nivel => progressoAtual.nivel;
  int get vidaMaxima => vidaMax(nivel);
  bool get derrotado => save.derrotadoEm == hoje;
  bool get descansando => descanso.contains(hoje);

  List<Tarefa> get tarefasDeHoje => [for (final t in save.tarefas) if (ocorreNoDia(t, hoje)) t];
  bool feitaHoje(Tarefa t) => t.feitaEm == hoje;
  int get nFeitasHoje => tarefasDeHoje.where(feitaHoje).length;
  int get nPendentesHoje => tarefasDeHoje.length - nFeitasHoje;

  /// Pendentes de hoje na ordem da lista, como o render() do JS: campo "ordem"; sem ele vale a posição no save x 10.
  List<Tarefa> get pendentesDeHoje {
    num ordemDe(Tarefa t) {
      final o = t.dados['ordem'];
      return o is num ? o : save.tarefas.indexOf(t) * 10;
    }

    final l = [for (final t in tarefasDeHoje) if (!feitaHoje(t)) t];
    final pos = {for (var i = 0; i < l.length; i++) l[i]: i};
    l.sort((x, y) {
      final c = ordemDe(x).compareTo(ordemDe(y));
      return c != 0 ? c : pos[x]!.compareTo(pos[y]!); // empate mantém a ordem do save
    });
    return l;
  }

  /// Vida do monstro do dia, 0 a 1 (fração de tarefas ainda pendentes; 0 = derrotado).
  double get vidaMonstro {
    if (derrotado) return 0;
    final n = tarefasDeHoje.length;
    return n == 0 ? 1 : nPendentesHoje / n;
  }

  String get temaArenaId {
    final salvo = armazenamento.ler(chaveConta(_chaveTemaArena, uid: uid, personagem: personagem));
    return (salvo != null && dados.temas.any((t) => t.id == salvo)) ? salvo : dados.temas.first.id;
  }

  /// `monstroDoDia()`: índice no catálogo de monstros.
  int get monstroDoDiaIdx {
    final pool = poolMonstros(dados.biomasDosMonstros, temaArenaId);
    final d = _agora();
    return monstroDoDia(pool: pool, totalMonstros: dados.monstros.length, diasCorridos: diasCorridos(d), semente: save.semente);
  }

  Monstro get monstro => dados.monstros[monstroDoDiaIdx];
  Heroi get heroi {
    final i = save.heroi.toInt();
    return dados.herois[(i >= 0 && i < dados.herois.length) ? i : 0];
  }

  /// `podeTerminarDia()`: zero pendentes, ao menos uma concluída, monstro ainda de pé, fora do descanso.
  bool get podeTerminarDia => !descansando && !derrotado && nPendentesHoje == 0 && nFeitasHoje > 0;

  /// O app atual bloqueia criar tarefa depois que o monstro caiu.
  bool get podeCriarTarefa => !derrotado;

  // ---------- virada do dia ----------
  /// Roda ao abrir o app e ao voltar do segundo plano.
  void verificarDia() {
    final r = verificarVirada(
      hoje: hoje,
      ultimoDia: ultimoDia,
      vida: vida,
      xpTotal: save.xpTotal,
      moedas: save.moedas.toInt(),
      derrotadoEm: save.derrotadoEm,
      tarefas: save.tarefas,
      descansando: descanso.contains,
      multMoedas: bonus.multMoedas,
    );
    final mudou = r.ultimoDia != ultimoDia || r.vida != vida || r.moedas != save.moedas;
    vida = r.vida;
    ultimoDia = r.ultimoDia;
    save.moedas = r.moedas;
    if (r.danoAplicado > 0 || r.vitoriaAutomatica) {
      eventoPendente = EventoVirada(
        largadas: r.largadas.length,
        dano: r.danoAplicado,
        caiu: r.caiu,
        moedasPerdidas: r.moedasPerdidas,
        vitoriaAutomatica: r.vitoriaAutomatica,
      );
    }
    if (mudou) {
      _salvarTudo();
      notifyListeners();
    }
  }

  EventoVirada? consumirEvento() {
    final e = eventoPendente;
    eventoPendente = null;
    return e;
  }

  // ---------- ações ----------
  /// `alternar(i)`: concluir uma tarefa (o app atual não tem desfazer). Devolve null se nada mudou.
  GanhoTarefa? concluir(Tarefa t) {
    if (!tarefasDeHoje.contains(t) || feitaHoje(t)) return null;
    if (descansando) {
      descanso = [for (final d in descanso) if (d != hoje) d]; // concluir tarefa cancela o descanso do dia
    }
    final meta = t.meta;
    final dif = t.dif;
    final nivelAntes = nivel;
    final b = bonus;

    if (meta > 1) {
      if (t.dados['vezesData'] != hoje) {
        t.dados['vezesData'] = hoje;
        t.dados['vezesN'] = 0;
      }
      final vezes = ((t.dados['vezesN'] as num?)?.toInt() ?? 0) + 1;
      t.dados['vezesN'] = vezes < meta ? vezes : meta;
      if (vezes < meta) {
        // toque parcial: ordem SEM contar esta tarefa (como o JS), sem cura e sem contar no estágio
        final g = ganhoPorConclusao(
            ordem: nFeitasHoje, dif: dif, meta: meta, acumulador: _acumulador, multXp: b.multXp, multMoedas: b.multMoedas);
        _aplicarGanho(g.xp, g.moedas);
        _salvarTudo();
        notifyListeners();
        return GanhoTarefa(xp: g.xp, moedas: g.moedas, subiuNivel: nivel > nivelAntes, nivel: nivel, parcial: true);
      }
    }

    t.dados['feitaEm'] = hoje;
    final g = ganhoPorConclusao(
        ordem: nFeitasHoje, dif: dif, meta: meta, acumulador: _acumulador, multXp: b.multXp, multMoedas: b.multMoedas);
    _aplicarGanho(g.xp, g.moedas);
    vida = curar(vida: vida, vidaMaxima: vidaMaxima, cura: Eco.curaPorTarefa);
    totalConcluidas++;
    _salvarTudo();
    notifyListeners();
    return GanhoTarefa(xp: g.xp, moedas: g.moedas, subiuNivel: nivel > nivelAntes, nivel: nivel, parcial: false);
  }

  void _aplicarGanho(int xp, int moedas) {
    save.xpTotal += xp;
    save.moedas += moedas;
  }

  /// `terminarDia()`: derrota o monstro do dia, paga a recompensa de vitória e cura. Devolve as moedas ganhas.
  int? terminarDia() {
    if (!podeTerminarDia) return null;
    final ganho = recompensaVitoria(tarefasDeHoje.length, multMoedas: bonus.multMoedas);
    save.moedas += ganho;
    save.derrotadoEm = hoje;
    vida = curar(vida: vida, vidaMaxima: vidaMaxima, cura: jsRound(vidaMaxima * Eco.curaVitoria));
    _garantirBau();
    _salvarTudo();
    notifyListeners();
    return ganho;
  }

  /// `criar()`: valida como o JS e devolve false se não criou.
  bool criarTarefa({
    required String texto,
    required String modo,
    required String dif,
    int meta = 1,
    List<int> dias = const [],
    int diaMes = 1,
    int diaAno = 1,
    int mesAno = 1,
  }) {
    final t = texto.trim();
    if (derrotado || t.isEmpty) return false;
    if (modo == ModoTarefa.repete && dias.isEmpty) return false;
    final base = <String, dynamic>{'texto': t};
    switch (modo) {
      case ModoTarefa.hoje:
        base.addAll({'tipo': 'hoje', 'data': hoje});
      case ModoTarefa.mensal:
        base.addAll({'tipo': 'mensal', 'diaMes': diaMes});
      case ModoTarefa.anual:
        base.addAll({'tipo': 'anual', 'diaAno': diaAno, 'mesAno': mesAno});
      default:
        base.addAll({'tipo': 'repete', 'dias': [...dias]});
    }
    base.addAll({'feitaEm': null, 'dif': difDe(dif), 'meta': meta < 1 ? 1 : (meta > 9 ? 9 : meta)});
    save.tarefas.add(Tarefa(base));
    _salvarTudo();
    notifyListeners();
    return true;
  }

  /// Edita texto, dificuldade e vezes por dia (a recorrência não muda aqui).
  bool editarTarefa(Tarefa t, {required String texto, required String dif, required int meta}) {
    final tx = texto.trim();
    if (tx.isEmpty || !save.tarefas.contains(t)) return false;
    final m = meta < 1 ? 1 : (meta > 9 ? 9 : meta);
    t.dados['texto'] = tx;
    t.dados['dif'] = difDe(dif);
    t.dados['meta'] = m;
    final vezes = (t.dados['vezesN'] as num?)?.toInt();
    if (vezes != null && vezes > m) t.dados['vezesN'] = m;
    _salvarTudo();
    notifyListeners();
    return true;
  }

  /// Apaga uma tarefa. Em tarefa recorrente, [soHoje] só a pula neste dia.
  void apagarTarefa(Tarefa t, {bool soHoje = false}) {
    if (soHoje && t.tipo != 'hoje') {
      final l = [...((t.dados['pulaEm'] as List?) ?? const [])];
      if (!l.contains(hoje)) l.add(hoje);
      t.dados['pulaEm'] = l;
    } else {
      save.tarefas.remove(t);
    }
    _salvarTudo();
    notifyListeners();
  }

  bool ehRecorrente(Tarefa t) => t.tipo != 'hoje';

  /// Arrastar para reordenar (soltar() do JS): grava a ordem visual nas pendentes, de 10 em 10.
  /// [de] e [para] são posições em [pendentesDeHoje] ([para] já é a posição final).
  void reordenar(int de, int para) {
    final l = pendentesDeHoje;
    if (de < 0 || de >= l.length || para < 0 || para >= l.length || de == para) return;
    l.insert(para, l.removeAt(de));
    for (var i = 0; i < l.length; i++) {
      l[i].dados['ordem'] = i * 10;
    }
    _salvarTudo();
    notifyListeners();
  }

  /// definirDescanso() do JS: marca ou desmarca o dia de descanso (lista ordenada, no máximo 400 datas).
  void definirDescanso(bool ligado) {
    if (ligado && derrotado) return; // o botão some depois que o monstro cai
    final l = [for (final d in descanso) if (d != hoje) d];
    if (ligado) l.add(hoje);
    l.sort();
    descanso = l.length > 400 ? l.sublist(l.length - 400) : l;
    _salvarTudo();
    notifyListeners();
  }

  // ---------- baú do dia, inventário ----------
  /// `darItem(id, 1)`: empilha por id (equipamento já vem como variante do sorteio).
  void _darItem(int id) {
    for (final sl in save.inventario) {
      if (sl['id'] == id) {
        sl['q'] = ((sl['q'] as num?) ?? 0).toInt() + 1;
        return;
      }
    }
    save.inventario.add({'id': id, 'q': 1});
  }

  int get _estagio => estagioAtual(totalConcluidas);

  /// `garantirBauDia()`: com o monstro caído e sem baú de hoje, sorteia o padrão e já credita os itens.
  void _garantirBau() {
    if (!derrotado) return;
    if (bauDia != null && bauDia!['dia'] == hoje) return;
    final ids = sortearLootDoDia(
      catalogo,
      _aleatorio.nextDouble,
      nTarefas: tarefasDeHoje.length,
      estagio: _estagio,
      afixoTes: afixoSoma(catalogo, _equipado, 'tes'),
      afixoTex: afixoSoma(catalogo, _equipado, 'tex'),
    );
    ids.forEach(_darItem);
    bauDia = {
      'dia': hoje,
      'padrao': {'ids': ids, 'aberto': false},
      'especial': null,
      'extra': null,
    };
  }

  /// Baú padrão de hoje ainda fechado?
  bool get bauPadraoFechado {
    final b = bauDia;
    return b != null && b['dia'] == hoje && b['padrao'] is Map && (b['padrao'] as Map)['aberto'] != true;
  }

  /// `abrirBauPadrao()`: marca como aberto e devolve os itens para o popup (null se não há o que abrir).
  List<ItemCatalogo>? abrirBauPadrao() {
    if (!bauPadraoFechado) return null;
    final p = bauDia!['padrao'] as Map;
    final ids = [for (final i in (p['ids'] as List)) (i as num).toInt()];
    p['aberto'] = true;
    _salvarTudo();
    notifyListeners();
    return [for (final i in ids) catalogo.item(i)!];
  }

  int quantidadeDe(int id) {
    for (final sl in save.inventario) {
      if (sl['id'] == id) return ((sl['q'] as num?) ?? 0).toInt();
    }
    return 0;
  }

  void _tirarItem(int id) {
    final i = save.inventario.indexWhere((sl) => sl['id'] == id);
    if (i < 0) return;
    final q = ((save.inventario[i]['q'] as num?) ?? 0).toInt() - 1;
    if (q <= 0) {
      save.inventario.removeAt(i);
      for (final s in slotsEquip) {
        if (_equipado[s] == id) _equipado[s] = null;
      }
    } else {
      save.inventario[i]['q'] = q;
    }
  }

  bool equipado(int id) => _equipado.values.contains(id);

  /// `equipar(id)`: coloca no slot do tipo, ou tira se já estava equipado. Devolve true se ficou equipado.
  bool? equipar(int id) {
    final it = catalogo.item(id);
    if (it == null || !slotsEquip.contains(it.tipo) || quantidadeDe(id) == 0) return null;
    _equipado[it.tipo] = _equipado[it.tipo] == id ? null : id;
    _salvarTudo();
    notifyListeners();
    return _equipado[it.tipo] == id;
  }

  /// `usarItem(id)`: consumível dá XP, moedas e/ou cura e some um da pilha.
  GanhoTarefa? usarItem(int id) {
    final it = catalogo.item(id);
    if (it == null || it.tipo != 'cons' || quantidadeDe(id) == 0) return null;
    final nivelAntes = nivel;
    if (it.bonusXp != 0) save.xpTotal += it.bonusXp.toInt();
    if (it.bonusMoedas != 0) save.moedas += it.bonusMoedas.toInt();
    if (it.cura != 0) vida = vida + it.cura > vidaMaxima ? vidaMaxima : vida + it.cura;
    _tirarItem(id);
    _salvarTudo();
    notifyListeners();
    return GanhoTarefa(xp: it.bonusXp.toInt(), moedas: it.bonusMoedas.toInt(), subiuNivel: nivel > nivelAntes, nivel: nivel, parcial: false);
  }

  /// `venderItem(id)`: paga o preço de venda e tira um. Devolve as moedas (null se não vendeu).
  int? venderItem(int id) {
    final it = catalogo.item(id);
    if (it == null || quantidadeDe(id) == 0) return null;
    if (it.tipo == 'chave' && it.nome == 'Grimório') return null; // item único, não se vende
    final preco = precoVenda(it.tipo, it.valor);
    save.moedas += preco;
    _tirarItem(id);
    _salvarTudo();
    notifyListeners();
    return preco;
  }

  // ---------- gravação ----------
  Future<void> _salvarTudo() async {
    final ms = _agora().millisecondsSinceEpoch;
    // as quatro gravações saem juntas (cada uma já atualiza o cache na hora), sem esperar uma pela outra
    await Future.wait([
      armazenamento.gravar(chaveSave(uid: uid, personagem: personagem), jsonEncode(save.paraJson(catalogo, salvoEm: ms))),
      armazenamento.gravar(chaveConta(_chaveVida, uid: uid, personagem: personagem), jsonEncode({'vida': vida, 'ultimoDia': ultimoDia})),
      armazenamento.gravar(chaveConta(_chaveDescanso, uid: uid, personagem: personagem), jsonEncode(descanso)),
      armazenamento.gravar(chaveConta(_chaveConcluidas, uid: uid, personagem: personagem), '$totalConcluidas'),
      if (bauDia != null) armazenamento.gravar(chaveConta(_chaveBauDia, uid: uid, personagem: personagem), jsonEncode(bauDia)),
    ]);
  }
}
