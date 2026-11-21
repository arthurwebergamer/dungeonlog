// Estado do jogo da aba Tarefas (ChangeNotifier). Junta o save v3, a vida e os contadores da conta e aplica as
// regras de play/index.html: alternar() (~6388), criar() (~6759), terminarDia() (~2860), verificarVirada() (~10721).
// Toda regra de conta vem de lib/dominio (testada contra o JS); aqui só a orquestração e a gravação.
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../dados/armazenamento.dart';
import '../dominio/bau.dart';
import '../dominio/catalogo.dart';
import '../dominio/conquistas.dart';
import '../dominio/historico.dart';
import '../dominio/dados_jogo.dart';
import '../dominio/datas.dart';
import '../dominio/economia.dart';
import '../dominio/estatisticas.dart';
import '../dominio/forja.dart';
import '../dominio/js_compat.dart';
import '../dominio/loja.dart';
import '../dominio/regras.dart';
import '../dominio/regras.dart' as regras show monstroDoDiaEm;
import '../dominio/save.dart';
import '../dominio/tarefa.dart';
import '../dominio/vida.dart';
import 'som.dart';
import 'tema.dart' show crtAtivo;
import 'vibra.dart';

const _chaveVida = 'questlog.vida.v1';
const _chaveDescanso = 'questlog.descanso.v1';
const _chaveConcluidas = 'questlog.tarefasConcluidas.v1';
const _chaveTemaArena = 'questlog.temaArena.v1';
const _chaveBauDia = 'questlog.bauDia.v1';
const _chaveResumoDia = 'questlog.resumoDia.v1';
const _chaveCerimonia = 'questlog.estagioCerimoniaMostrada.v1';
const _chaveDicaArrastar = 'questlog.dicaArrastar.v1';
const _chavePity = 'questlog.bauSemEspecial.v1';
const _chaveLoja = 'questlog.loja.v1';
const _chaveHist = 'questlog.hist.v1';
const _chaveVistos = 'questlog.itensVistos.v1';
const _chaveConqDesbloq = 'questlog.conquistasDesbloqueadasV2.v1';
const _chaveConqVistas = 'questlog.conquistasVistasV2.v1';
const chaveIdiomaApp = 'questlog.idioma.v1';
const chaveSfx = 'questlog.sfx.v1';
const chaveCrt = 'questlog.crt.v1';
const chaveTema = 'questlog.tema.v1';
const chaveGolpesVariados = 'questlog.golpesVariados.v1';
const chaveNotificacoes = 'questlog.notificacoes.v1';

/// O que a virada do dia causou, para a interface avisar uma vez.
class EventoVirada {
  final int largadas;
  final int dano;
  final bool caiu;
  final int moedasPerdidas;
  final bool vitoriaAutomatica;
  final List<Tarefa> tarefas; // as que escaparam (para a lista do popup)
  final String? diaVirada; // o dia que fechou (o monstro dele é quem fugiu)
  const EventoVirada({
    required this.largadas,
    required this.dano,
    required this.caiu,
    required this.moedasPerdidas,
    required this.vitoriaAutomatica,
    this.tarefas = const [],
    this.diaVirada,
  });
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

/// O que a tela cheia "Estágio concluído" precisa mostrar.
class CerimoniaEstagio {
  final int concluido; // estágio que o jogador acabou de terminar
  final TemaArena tema; // cenário novo
  final TemaArena anterior;
  final int? alvo; // tarefas do estágio concluído (ex.: 10)
  final List<Monstro> monstros;
  final bool todosBiomas;
  const CerimoniaEstagio({required this.concluido, required this.tema, required this.anterior, required this.alvo, required this.monstros, required this.todosBiomas});
}

/// Um herói da conta (`questlog.personagens.v1`): id, nome dado na criação e data.
class Personagem {
  final String id;
  final String? nome;
  final String? criadoEm;
  const Personagem(this.id, this.nome, [this.criadoEm]);
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
  String idioma;
  final String? uid;
  String personagem;
  final DateTime Function() _agora;
  final Random _aleatorio;

  late SaveV3 save;
  int vida = 0;
  String? ultimoDia;
  List<String> descanso = [];
  int totalConcluidas = 0;

  /// Baú do dia (`questlog.bauDia.v1`): `{dia, padrao:{ids,aberto}, especial, extra}`. Só o padrão existe por enquanto.
  Map<String, dynamic>? bauDia;

  /// Dias vencidos seguidos sem baú especial (garantia aos 6).
  int pity = 0;

  /// Histórico permanente de dias (`questlog.hist.v1`), a fonte do Bestiário e das Conquistas.
  List<EntradaHist> hist = [];

  /// Itens já obtidos alguma vez, pelo id BASE (`questlog.itensVistos.v1`): o catálogo do Grimório.
  Set<int> itensVistos = {};

  /// Conquistas desbloqueadas {id: data} e as que o jogador já viu (bolinha e etiqueta NOVO).
  Map<String, String> conqDesbloq = {};
  Set<String> conqVistas = {};

  /// Loja: dia do estoque, vagas e posições já compradas (`questlog.loja.v1`).
  String? lojaDia;
  List<VagaLoja> lojaEstoque = [];
  List<int> lojaVendidos = [];
  EventoVirada? eventoPendente;
  final AcumuladorMoedas _acumulador = AcumuladorMoedas();

  Catalogo get catalogo => dados.catalogo;

  // ---------- inicialização ----------
  /// Herói ativo (a raiz do app usa para refazer as telas quando ele muda).
  final ValueNotifier<String> personagemAtivo = ValueNotifier<String>('pj1');

  Future<void> iniciar() async {
    // reinicia o que vive só na memória (iniciar() também roda ao trocar de herói)
    ultimoDia = null;
    eventoPendente = null;
    _temaPreview = null;
    bauDia = null;
    lojaDia = null;
    lojaEstoque = [];
    lojaVendidos = [];
    final bruto = armazenamento.ler(chaveSave(uid: uid, personagem: personagem));
    final semente = _aleatorio.nextInt(64);
    final carregado = SaveV3.carregar(bruto, catalogo, idioma: idioma, sementeAtual: semente);
    save = carregado ?? SaveV3.padrao(catalogo, idioma: idioma, semente: semente);
    if (carregado == null && pendenteNovo != null) {
      // herói recém-criado: já nasce com o nome e o sprite escolhidos
      if (pendenteNovo!.nome != null) save.nomeHeroi = pendenteNovo!.nome!;
      save.heroi = pendenteNovo!.heroi;
    }
    pendenteNovo = null;

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

    pity = numeroOu0(armazenamento.ler(chaveConta(_chavePity, uid: uid, personagem: personagem))).toInt();
    final lj = _lerJson(chaveConta(_chaveLoja, uid: uid, personagem: personagem));
    if (lj is Map) {
      lojaDia = lj['dia'] is String ? lj['dia'] as String : null;
      lojaEstoque = [
        if (lj['estoque'] is List)
          for (final e in lj['estoque'] as List)
            if (e is Map && catalogo.existe(e['id'])) VagaLoja((e['id'] as num).toInt(), e['o'] == 1 || e['o'] == true)
      ];
      lojaVendidos = [if (lj['vendidos'] is List) for (final v in lj['vendidos'] as List) if (v is num) v.toInt()];
    }

    hist = lerHistorico(armazenamento.ler(chaveConta(_chaveHist, uid: uid, personagem: personagem)));
    final vs = _lerJson(chaveConta(_chaveVistos, uid: uid, personagem: personagem));
    itensVistos = {if (vs is List) for (final v in vs) if (v is num) v.toInt()};
    // migração do original: quem já tinha itens no inventário não pode ver tudo como "nunca visto"
    for (final sl in save.inventario) {
      final id = sl['id'];
      if (id is num) itensVistos.add(id.toInt());
    }
    final cd = _lerJson(chaveConta(_chaveConqDesbloq, uid: uid, personagem: personagem));
    conqDesbloq = {if (cd is Map) for (final e in cd.entries) if (e.key is String && e.value is String) e.key as String: e.value as String};
    final cv = _lerJson(chaveConta(_chaveConqVistas, uid: uid, personagem: personagem));
    conqVistas = {if (cv is List) for (final v in cv) if (v is String) v};
    _carregarPersonagens();
    personagemAtivo.value = personagem;

    final temaSalvo = armazenamento.ler(chaveConta(_chaveTemaArena, uid: uid, personagem: personagem));
    if (estagio > 1 && estagioCerimoniaMostrada >= estagio && temaSalvo == null && estagio <= dados.temas.length) {
      armazenamento.gravar(chaveConta(_chaveTemaArena, uid: uid, personagem: personagem), dados.temas[estagio - 1].id);
    }

    verificarDia();
    _recuperarOntem();
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

  // ---------- estágios e cenário da arena ----------
  /// `estagioAtual()`: 1 a 4, pelas tarefas concluídas no total.
  int get estagio => estagioAtual(totalConcluidas);

  /// Tarefas que faltam para o próximo estágio (0 no último).
  int get faltamParaProximoEstagio {
    if (estagio >= 4) return 0;
    final f = limiaresEstagio[estagio - 1] - totalConcluidas;
    return f < 0 ? 0 : f;
  }

  /// Muda a cada vez que a aba Tarefas volta à tela (o selo de estágio reaparece).
  int seloTick = 0;
  void piscarSelo() {
    seloTick++;
    notifyListeners();
  }

  /// `estagioCerimoniaMostradaAte()`: maior estágio cuja cerimônia o jogador já viu (padrão 1).
  int get estagioCerimoniaMostrada {
    final n = numeroOu0(armazenamento.ler(chaveConta(_chaveCerimonia, uid: uid, personagem: personagem))).toInt();
    return n < 1 ? 1 : n;
  }

  bool get cerimoniaPendente => estagio > estagioCerimoniaMostrada;

  /// `temaArenaDesbloqueado(t)`: o cenário `i` (a posição na lista é o número do estágio, menos 1).
  bool temaDesbloqueado(int i) {
    if (i <= 0 || i >= dados.temas.length) return true;
    final v = dados.temas[i].desbloqueioGratis?['valor'];
    final lim = v is num ? v.toInt() : limiaresEstagio[i - 1];
    return totalConcluidas >= lim;
  }

  String? _temaPreview; // cenário trancado que o jogador deixou aparecer arrastando (não é salvo)
  String get temaExibidoId => _temaPreview ?? temaArenaId;
  int get indiceTemaExibido {
    final i = dados.temas.indexWhere((t) => t.id == temaExibidoId);
    return i < 0 ? 0 : i;
  }

  /// Pouso do arrasto: grava o cenário se estiver liberado; trancado só aparece como prévia.
  void pousarTema(int i) {
    final t = dados.temas[i];
    if (temaDesbloqueado(i)) {
      armazenamento.gravar(chaveConta(_chaveTemaArena, uid: uid, personagem: personagem), t.id);
      _temaPreview = null;
    } else {
      _temaPreview = t.id;
    }
    armazenamento.gravar(chaveConta(_chaveDicaArrastar, uid: uid, personagem: personagem), '99'); // já descobriu o gesto
    notifyListeners();
  }

  /// Qualquer ação em Tarefas desfaz a prévia de um cenário trancado (como o `renderTemaArena()` do original).
  void limparPreviewTema() {
    if (_temaPreview == null) return;
    _temaPreview = null;
    notifyListeners();
  }

  /// No estágio máximo o selo vira a dica "Arraste pra trocar de bioma", só nas 3 primeiras aberturas.
  bool consumirDicaArrastar() {
    final k = chaveConta(_chaveDicaArrastar, uid: uid, personagem: personagem);
    final n = numeroOu0(armazenamento.ler(k)).toInt();
    if (n >= 3) return false;
    armazenamento.gravar(k, '${n + 1}');
    return true;
  }

  /// Dados da cerimônia "Estágio concluído". Chamar ao MOSTRAR: já grava o cenário novo e marca a cerimônia como vista.
  CerimoniaEstagio? iniciarCerimonia() {
    if (!cerimoniaPendente) return null;
    final est = estagio;
    final tema = dados.temas[(est - 1).clamp(0, dados.temas.length - 1)];
    final concluido = est - 1;
    final anterior = dados.temas[(concluido - 1).clamp(0, dados.temas.length - 1)];
    armazenamento.gravar(chaveConta(_chaveTemaArena, uid: uid, personagem: personagem), tema.id);
    armazenamento.gravar(chaveConta(_chaveCerimonia, uid: uid, personagem: personagem), '$est');
    _temaPreview = null;
    final ehUltimo = tema.id == dados.temas.last.id;
    final kTodos = chaveConta('questlog.avisoTodosBiomas.v1', uid: uid, personagem: personagem);
    final jaAvisado = armazenamento.ler(kTodos) == 'true';
    if (ehUltimo && !jaAvisado) armazenamento.gravar(kTodos, 'true');
    notifyListeners();
    return CerimoniaEstagio(
      concluido: concluido,
      tema: tema,
      anterior: anterior,
      alvo: concluido >= 1 && concluido <= limiaresEstagio.length ? limiaresEstagio[concluido - 1] : null,
      monstros: [for (final m in dados.monstros) if (m.bioma == tema.id) m].take(4).toList(),
      todosBiomas: ehUltimo && !jaAvisado,
    );
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
    for (final d in r.historico) {
      _registrarHistorico(d);
    }
    final mudou = r.ultimoDia != ultimoDia || r.historico.isNotEmpty || r.vida != vida || r.moedas != save.moedas;
    vida = r.vida;
    ultimoDia = r.ultimoDia;
    save.moedas = r.moedas;
    if (r.danoAplicado > 0 || r.vitoriaAutomatica) {
      if (r.largadas.isNotEmpty) Som.atual.tocar('fuga');
      if (r.danoAplicado > 0) Som.atual.tocar('danoHeroi');
      if (r.caiu) Som.atual.tocar('morte');
      eventoPendente = EventoVirada(
        largadas: r.largadas.length,
        dano: r.danoAplicado,
        caiu: r.caiu,
        moedasPerdidas: r.moedasPerdidas,
        vitoriaAutomatica: r.vitoriaAutomatica,
        tarefas: r.largadas,
        diaVirada: r.diaQueVirou,
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
    _snapXpDoDia();
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
        Som.atual.tocar('golpe');
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
    Som.atual.tocar('golpe');
    return GanhoTarefa(xp: g.xp, moedas: g.moedas, subiuNivel: nivel > nivelAntes, nivel: nivel, parcial: false);
  }

  /// `snap()` do resumo do dia: guarda o XP total no primeiro toque de tarefa do dia.
  void _snapXpDoDia() {
    final k = chaveConta(_chaveResumoDia, uid: uid, personagem: personagem);
    final s = _lerJson(k);
    if (s is Map && s['dia'] == hoje) return;
    armazenamento.gravar(k, jsonEncode({'dia': hoje, 'xp0': save.xpTotal}));
  }

  /// XP ganho hoje (XP total agora menos o do primeiro toque do dia).
  int get xpDoDia {
    final s = _lerJson(chaveConta(_chaveResumoDia, uid: uid, personagem: personagem));
    if (s is! Map || s['dia'] != hoje || s['xp0'] is! num) return 0;
    final d = save.xpTotal - (s['xp0'] as num);
    return d < 0 ? 0 : d.toInt();
  }

  /// Monstro de um dia passado (`monstroDoDiaEm(iso)`), o que fugiu na virada.
  Monstro monstroDoDiaEm(String iso) {
    final pool = poolMonstros(dados.biomasDosMonstros, temaArenaId);
    final i = regras.monstroDoDiaEm(
      pool: pool,
      totalMonstros: dados.monstros.length,
      diasCorridos: diasCorridos(_agora()),
      diasAteHoje: diffDias(iso, hoje),
      semente: save.semente.toInt(),
    );
    return dados.monstros[i];
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
    String? corBox,
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
    final cor = hexValido(corBox);
    if (cor != null) base['corBox'] = cor;
    save.tarefas.add(Tarefa(base));
    Som.atual.tocar('tarefa');
    _salvarTudo();
    notifyListeners();
    return true;
  }

  /// Edita texto, dificuldade e vezes por dia (a recorrência não muda aqui).
  bool editarTarefa(Tarefa t, {required String texto, required String dif, required int meta, String? corBox}) {
    final tx = texto.trim();
    if (tx.isEmpty || !save.tarefas.contains(t)) return false;
    final m = meta < 1 ? 1 : (meta > 9 ? 9 : meta);
    t.dados['texto'] = tx;
    t.dados['dif'] = difDe(dif);
    t.dados['meta'] = m;
    final cor = hexValido(corBox);
    if (cor != null) {
      t.dados['corBox'] = cor;
    } else {
      t.dados.remove('corBox');
    }
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
    _marcarVisto(id);
    for (final sl in save.inventario) {
      if (sl['id'] == id) {
        sl['q'] = ((sl['q'] as num?) ?? 0).toInt() + 1;
        return;
      }
    }
    save.inventario.add({'id': id, 'q': 1});
  }

  int get _estagio => estagioAtual(totalConcluidas);

  int _pips(Tarefa t) => dificuldades.firstWhere((d) => d.id == difDe(t.dif), orElse: () => dificuldades.firstWhere((d) => d.id == difPadrao)).pips;

  /// `garantirBauDia()`: com o monstro caído e sem baú de hoje, sorteia padrão/especial/extra e credita o que é imediato.
  void _garantirBau() {
    if (!derrotado) return;
    if (bauDia != null && bauDia!['dia'] == hoje) return;
    final doDia = tarefasDeHoje;
    final g = gerarBauDia(
      catalogo,
      _aleatorio.nextDouble,
      dia: hoje,
      nTarefas: doDia.length,
      estagio: _estagio,
      media: mediaDif([for (final t in doDia) _pips(t)]),
      pityAtual: pity,
      afixoTes: afixoSoma(catalogo, _equipado, 'tes'),
      afixoTex: afixoSoma(catalogo, _equipado, 'tex'),
      afixoBau: afixoSoma(catalogo, _equipado, 'bau'),
      afixoAbu: afixoSoma(catalogo, _equipado, 'abu'),
    );
    g.creditar.forEach(_darItem);
    pity = g.pity;
    bauDia = g.estado;
    Som.atual.tocar('poofBau');
  }

  /// O baú [qual] ('padrao', 'especial' ou 'extra') existe hoje e ainda está fechado?
  bool bauFechado(String qual) {
    final b = bauDia;
    if (b == null || b['dia'] != hoje || b[qual] is! Map) return false;
    return (b[qual] as Map)['aberto'] != true;
  }

  bool get bauPadraoFechado => bauFechado('padrao');

  /// Raridade mínima da chave pedida pelo baú especial (null se não há baú especial fechado).
  int? get tierBauEspecial => bauFechado('especial') ? ((bauDia!['especial'] as Map)['tier'] as num).toInt() : null;

  /// Id da chave do inventário que abre o baú especial hoje (null = sem chave).
  int? get chaveDoEspecial {
    final t = tierBauEspecial;
    return t == null ? null : chaveParaDestravar(catalogo, save.inventario, t);
  }

  /// `abrirBauPadrao/Extra/Especial()`. Devolve os itens para o popup; null se não há o que abrir.
  /// O especial exige uma chave (gasta uma) e só então credita os itens.
  List<ItemCatalogo>? abrirBau(String qual) {
    if (!bauFechado(qual)) return null;
    final p = bauDia![qual] as Map;
    final ids = [for (final i in (p['ids'] as List)) (i as num).toInt()];
    if (qual == 'especial') {
      final chave = chaveDoEspecial;
      if (chave == null) return null;
      _tirarItem(chave);
      ids.forEach(_darItem);
    }
    p['aberto'] = true;
    _salvarTudo();
    notifyListeners();
    return [for (final i in ids) catalogo.item(i)!];
  }

  List<ItemCatalogo>? abrirBauPadrao() => abrirBau('padrao');

  // ---------- loja ----------
  int get _afixoBar => afixoSoma(catalogo, _equipado, 'bar');
  int precoNaLoja(VagaLoja v) => precoLoja(catalogo.item(v.id)!, v.oferta, desconto: descontoLoja(_afixoBar));

  /// `garantirEstoque()`: refaz a prateleira na virada do dia (ou se o formato salvo não confere).
  void garantirEstoque() {
    final vagas = Eco.lojaVagas < 1 ? 1 : Eco.lojaVagas;
    final nCons = Eco.lojaConsumiveis < vagas ? Eco.lojaConsumiveis : vagas;
    var formatoOk = lojaEstoque.length == vagas;
    if (formatoOk) {
      for (var i = 0; i < lojaEstoque.length; i++) {
        final it = catalogo.item(lojaEstoque[i].id)!;
        if (it.morto || (it.tipo == 'cons') != (i >= vagas - nCons)) formatoOk = false;
      }
    }
    if (lojaDia != hoje || lojaEstoque.isEmpty || !formatoOk) {
      lojaDia = hoje;
      lojaEstoque = montarEstoque(catalogo, diasCorridos: diasCorridos(_agora()), semente: save.semente, nivel: nivel);
      lojaVendidos = [];
      _salvarTudo();
    }
  }

  /// `comprar(i)`. Resultado: 'ok', 'nivel' (falta nível), 'moedas' ou 'invalido'.
  String comprar(int i) {
    garantirEstoque();
    if (i < 0 || i >= lojaEstoque.length || lojaVendidos.contains(i)) return 'invalido';
    final v = lojaEstoque[i];
    final it = catalogo.item(v.id)!;
    if (nivel < nivelMinimo(it.raridade)) {
      Som.atual.tocar('semMoedas');
      return 'nivel';
    }
    final preco = precoNaLoja(v);
    if (save.moedas < preco) {
      Som.atual.tocar('semMoedas');
      return 'moedas';
    }
    save.moedas -= preco;
    _darItem(v.id);
    lojaVendidos.add(i);
    _salvarTudo();
    notifyListeners();
    Som.atual.tocar('compra');
    return 'ok';
  }

  /// `venderTesouros()`: vende todos os tesouros de uma vez. Devolve (quantidade, moedas).
  (int, int) venderTesouros() {
    var qtd = 0, total = 0;
    final restantes = <Map<String, dynamic>>[];
    for (final sl in save.inventario) {
      final it = catalogo.item(sl['id']);
      if (it != null && it.tipo == 'tesouro') {
        final q = ((sl['q'] as num?) ?? 0).toInt();
        total += precoVenda(it.tipo, it.valor) * q;
        qtd += q;
      } else {
        restantes.add(sl);
      }
    }
    if (qtd == 0) return (0, 0);
    save.inventario
      ..clear()
      ..addAll(restantes);
    save.moedas += total;
    _salvarTudo();
    notifyListeners();
    Som.atual.tocar('venda');
    return (qtd, total);
  }

  // ---------- forja ----------
  int tesourosDisponiveis() => [
        for (final sl in save.inventario)
          if (catalogo.item(sl['id'])?.tipo == 'tesouro') ((sl['q'] as num?) ?? 0).toInt()
      ].fold(0, (a, b) => a + b);

  /// Gasta os tesouros [sel] e sorteia o novo afixo (`fgo`). Null se a seleção não vale.
  Afixo? forjarSortear(int id, List<int> sel) {
    final it = catalogo.item(id);
    if (it == null || !slotsEquip.contains(it.tipo) || quantidadeDe(id) == 0) return null;
    if (sel.length != custoForja(it.rer)) return null;
    final tem = <int, int>{};
    for (final s in sel) {
      tem[s] = (tem[s] ?? 0) + 1;
      if (catalogo.item(s)?.tipo != 'tesouro' || quantidadeDe(s) < tem[s]!) return null;
    }
    final novo = sortearAfixoForja(catalogo, id, sel, _aleatorio.nextDouble);
    sel.forEach(_tirarItem);
    _salvarTudo();
    notifyListeners();
    return novo;
  }

  /// Fecha a forja (`fnovo`/`fatual`): troca o item por uma variante com [afixo] e uma passagem a mais pela forja.
  /// Devolve o id novo (null se o item já não está no inventário).
  int? forjarConfirmar(int id, Afixo? afixo) {
    final it = catalogo.item(id);
    if (it == null || quantidadeDe(id) == 0) return null;
    final idNovo = catalogo.variante(it.base, afixo, it.rer + 1);
    final eqs = [for (final k in slotsEquip) if (_equipado[k] == id) k];
    _tirarItem(id);
    _darItem(idNovo);
    for (final k in eqs) {
      _equipado[k] = idNovo;
    }
    _salvarTudo();
    notifyListeners();
    return idNovo;
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
    Som.atual.tocar(_equipado[it.tipo] == id ? 'equipar' : 'desequipar');
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
    Som.atual.tocar('usar');
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
    Som.atual.tocar('venda');
    return preco;
  }

  // ---------- histórico, Grimório, conquistas ----------
  /// `estHistComHojeAoVivo(hoje)`: o histórico gravado só ganha o dia na virada; aqui hoje entra "ao vivo" (sem gravar)
  /// como descanso ou, se todas as tarefas de hoje estão feitas, como vitória. É a base das Estatísticas.
  List<EntradaHist> get histAoVivo {
    final doDia = tarefasDeHoje;
    return estHistComHojeAoVivo(
      hist: hist,
      hoje: hoje,
      descansando: descansando,
      totalTarefasHoje: doDia.length,
      todasFeitasHoje: doDia.every(feitaHoje),
    );
  }

  /// `estStreakAtual(estHistComHojeAoVivo(hoje))`: a sequência atual (Estatísticas e linha "Sequência" do resumo do dia).
  int get sequenciaAtual => estStreakAtual(histAoVivo, hoje);

  /// `monstroIdDoDia(iso)`: índice do monstro daquele dia (o histórico guarda isto em cada entrada).
  int monstroIdDoDia(String iso) {
    final pool = poolMonstros(dados.biomasDosMonstros, temaArenaId);
    return regras.monstroDoDiaEm(
      pool: pool,
      totalMonstros: dados.monstros.length,
      diasCorridos: diasCorridos(_agora()),
      diasAteHoje: diffDias(iso, hoje),
      semente: save.semente.toInt(),
    );
  }

  /// `registrarHistorico(iso, total, largadas, descanso)`: grava o dia que fechou (uma vez por data).
  void _registrarHistorico(RegistroDia d) {
    if (d.data.isEmpty || hist.any((h) => h.data == d.data)) return;
    hist.add(EntradaHist(
      data: d.data,
      resultado: resultadoDoDia(descanso: d.descansou, totalTarefas: d.total, largadas: d.largadas),
      monstroId: monstroIdDoDia(d.data),
      tarefas: d.total,
    ));
  }

  /// Recuperação do original: se ontem não tem registro mas as tarefas dele estão todas feitas em ontem, o dia foi
  /// vencido de verdade e só não foi gravado. Grava como vitória (nunca inventa fuga).
  void _recuperarOntem() {
    final ontem = diaAnteriorIso(hoje);
    final doDia = [for (final t in save.tarefas) if (ocorreNoDia(t, ontem)) t];
    if (deveRecuperarOntem(hist: hist, ontem: ontem, totalOntem: doDia.length, todasFeitas: doDia.every((t) => t.feitaEm == ontem))) {
      _registrarHistorico(RegistroDia(ontem, doDia.length, 0, false));
    }
  }

  /// Marca o item (pelo id base) como descoberto no Grimório.
  void _marcarVisto(int id) => itensVistos.add(catalogo.baseDe(id));

  int get idGrimorio => idGrimorioDe(catalogo);

  /// Entrega do Grimório no marco de nível (IV a VII, por herói): chamada ao mostrar o "Nível alcançado".
  /// Devolve true se acabou de dar o item (a tela mostra "Você encontrou Grimório").
  bool entregarGrimorioSe(int nivel) {
    final g = idGrimorio;
    if (g < 0 || nivel != nivelDoGrimorio(save.semente)) return false;
    _darItem(g);
    Som.atual.tocar('grimorio');
    _salvarTudo();
    notifyListeners();
    return true;
  }

  int? get _monstroDeHojeSeVencido => derrotado ? monstroDoDiaIdx : null;

  ContextoConq get contextoConquistas => montarContextoConq(
        hist: hist,
        hoje: hoje,
        monstroDeHojeSeVencido: _monstroDeHojeSeVencido,
        totalMonstros: dados.monstros.length,
        nivel: nivel,
        tarefasConcluidas: totalConcluidas,
        vistos: itensVistos,
        catalogo: catalogo,
        idGrimorio: idGrimorio,
      );

  /// `checarDesbloqueiosV2()`: desbloqueia sozinho as conquistas cuja meta bateu (sem resgate nem XP na V2).
  bool checarConquistas() {
    final novos = novosDesbloqueios(contextoConquistas, conqDesbloq);
    for (final id in novos) {
      conqDesbloq[id] = hoje;
    }
    return novos.isNotEmpty;
  }

  /// Quantas foram desbloqueadas e o jogador ainda não viu (a bolinha do Perfil e do "Ver todas").
  int get conquistasNaoVistas => conqDesbloq.keys.where((id) => !conqVistas.contains(id)).length;

  /// Abrir a tela de Conquistas marca tudo como visto (a etiqueta NOVO usa o conjunto de antes).
  void marcarConquistasVistas() {
    var mudou = false;
    for (final id in conqDesbloq.keys) {
      if (conqVistas.add(id)) mudou = true;
    }
    if (mudou) {
      armazenamento.gravar(chaveConta(_chaveConqVistas, uid: uid, personagem: personagem), jsonEncode(conqVistas.toList()));
      notifyListeners();
    }
  }

  /// Bestiário: monstros derrotados (inclui o de hoje se o dia já foi vencido; nada disso é gravado).
  Set<int> get monstrosDerrotadosIds => monstrosDerrotados(hist, monstroDeHojeSeVencido: _monstroDeHojeSeVencido);

  // ---------- preferências do aparelho (Configurações) ----------
  Map<String, dynamic> _sfx() {
    final j = _lerJson(chaveSfx);
    return j is Map ? Map<String, dynamic>.from(j) : {};
  }

  void _gravarSfx(Map<String, dynamic> m) =>
      armazenamento.gravar(chaveSfx, jsonEncode({'ativo': m['ativo'] ?? true, 'volume': m['volume'] ?? 0.55, 'feedback': m['feedback'] ?? 'vibrar'}));

  bool get somLigado => _sfx()['ativo'] is bool ? _sfx()['ativo'] as bool : true;
  bool get vibracaoLigada => _sfx()['feedback'] != 'desativado' && _sfx()['feedback'] != 'som';

  void definirSom(bool v) {
    _gravarSfx({..._sfx(), 'ativo': v});
    final s = Som.atual;
    if (s is SomAudio) s.ativo = v;
    notifyListeners();
  }

  void definirVibracao(bool v) {
    _gravarSfx({..._sfx(), 'feedback': v ? 'vibrar' : 'desativado'});
    Vibra.ligada = v;
    notifyListeners();
  }

  /// Efeito CRT: '1' ligado, '0' desligado; sem escolha = desligado (padrão do original).
  bool get crtLigado => armazenamento.ler(chaveCrt) == '1';
  void definirCrt(bool v) {
    armazenamento.gravar(chaveCrt, v ? '1' : '0');
    crtAtivo.value = v;
    notifyListeners();
  }

  /// Golpes variados: ligado a menos que esteja '0'.
  bool get golpesVariados => armazenamento.ler(chaveGolpesVariados) != '0';
  void definirGolpesVariados(bool v) {
    armazenamento.gravar(chaveGolpesVariados, v ? '1' : '0');
    notifyListeners();
  }

  /// Notificações: só a preferência local por enquanto (o push de verdade é da Fase 7).
  bool get notificacoesLigadas => armazenamento.ler(chaveNotificacoes) == '1';
  void definirNotificacoes(bool v) {
    armazenamento.gravar(chaveNotificacoes, v ? '1' : '0');
    notifyListeners();
  }

  void definirIdioma(String lang) {
    final l = lang == 'en' ? 'en' : 'pt';
    if (l == idioma) return;
    idioma = l;
    armazenamento.gravar(chaveIdiomaApp, l);
    notifyListeners();
  }

  /// Tema de cor guardado ('grafite' é o padrão).
  String get temaCorId => armazenamento.ler(chaveTema) ?? 'grafite';
  void definirTemaCor(String id) {
    armazenamento.gravar(chaveTema, id);
    notifyListeners();
  }

  // ---------- heróis (personagens da conta) ----------
  /// "É Pro?" só passa a valer na Fase 7 (compra); até lá ninguém assina. PONTO DE LIGAÇÃO da Fase 7: é este valor
  /// (`assinaturaAtiva()` do original) que destrava os cartões de Estatísticas (taxa, composição, 7 dias e histórico),
  /// os temas Pro e mais de um herói. Trocar para `true` (e chamar `notifyListeners`) já mostra tudo destravado.
  bool ehPro = false;
  int get limitePersonagens => ehPro ? 4 : 1;

  List<Personagem> personagens = [const Personagem('pj1', null)];

  /// Nome e sprite escolhidos na criação de um herói novo, aplicados quando o save dele nasce.
  ({String? nome, int heroi})? pendenteNovo;

  String get _chavePersonagens => uid != null && uid!.isNotEmpty ? 'questlog.personagens.v1.uid.$uid' : 'questlog.personagens.v1';
  String get _chavePersonagemAtivo => uid != null && uid!.isNotEmpty ? 'questlog.personagemAtivo.v1.uid.$uid' : 'questlog.personagemAtivo.v1';

  void _carregarPersonagens() {
    final j = _lerJson(_chavePersonagens);
    final l = <Personagem>[];
    if (j is List) {
      for (final p in j) {
        if (p is Map && p['id'] is String) {
          l.add(Personagem(p['id'] as String, p['nome'] is String ? p['nome'] as String : null, p['criadoEm'] is String ? p['criadoEm'] as String : null));
        }
      }
    }
    personagens = l.isEmpty ? [const Personagem('pj1', null)] : l;
  }

  void _gravarPersonagens() => armazenamento.gravar(
      _chavePersonagens, jsonEncode([for (final p in personagens) {'id': p.id, 'nome': p.nome, 'criadoEm': p.criadoEm}]));

  /// `espiarSaveDe(id)`: nome e sprite de OUTRO herói sem trocar (a lista de heróis). Null se ainda não começou.
  ({String nome, int heroi})? espiarSaveDe(String id) {
    try {
      final bruto = armazenamento.ler(chaveSave(uid: uid, personagem: id));
      if (bruto == null) return null;
      final d = jsonDecode(bruto);
      if (d is! Map || d['comecou'] != true) return null;
      return (nome: nomeHeroiNorm(d['nomeHeroi'], idioma), heroi: numeroOu0(d['heroi']).toInt());
    } catch (_) {
      return null;
    }
  }

  /// Nome mostrado de um herói na lista: o do próprio save (o do ativo é o atual), senão o dado na criação.
  /// (O original preferia o nome da criação, que ficava velho depois de renomear.)
  String nomeDoPersonagem(Personagem p) {
    if (p.id == personagem) return nomeHeroiNorm(save.nomeHeroi, idioma);
    final s = espiarSaveDe(p.id);
    return s?.nome ?? p.nome ?? nomePadraoHeroi(idioma);
  }

  int spriteDoPersonagem(Personagem p) => p.id == personagem ? save.heroi.toInt() : (espiarSaveDe(p.id)?.heroi ?? 0);

  /// `trocarPersonagem(id)`: muda o herói ativo e recarrega tudo dele.
  Future<bool> trocarPersonagem(String id) async {
    if (!personagens.any((p) => p.id == id) || id == personagem) return false;
    await _salvarTudo();
    personagem = id;
    await armazenamento.gravar(_chavePersonagemAtivo, id);
    await iniciar();
    notifyListeners();
    return true;
  }

  /// `criarPersonagem(nome, heroiIdx)`: herói novo (limite 1 grátis, 4 Pro). Já fica ativo, com nome e sprite.
  Future<bool> criarPersonagem(String nome, int heroiIdx) async {
    if (personagens.length >= limitePersonagens) return false;
    await _salvarTudo();
    final id = 'pj${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    final nomeFinal = nome.trim().isEmpty ? null : nome.trim();
    personagens = [...personagens, Personagem(id, nomeFinal, _agora().toUtc().toIso8601String())];
    _gravarPersonagens();
    personagem = id;
    await armazenamento.gravar(_chavePersonagemAtivo, id);
    // o save do herói novo ainda não existe: iniciar() cai no estado padrão e já grava com o nome e o sprite escolhidos
    pendenteNovo = (nome: nomeFinal, heroi: heroiIdx);
    await iniciar();
    notifyListeners();
    return true;
  }

  /// `excluirPersonagem(id)`: apaga o save e as chaves secundárias do herói (precisa sobrar um e não pode ser o ativo).
  Future<bool> excluirPersonagem(String id) async {
    if (personagens.length < 2 || !personagens.any((p) => p.id == id) || id == personagem) return false;
    final sufixo = '.pj.$id';
    final temUid = uid != null && uid!.isNotEmpty;
    final uidTag = temUid ? '.uid.$uid.' : null;
    for (final k in armazenamento.chaves().toList()) {
      if (!k.endsWith(sufixo)) continue;
      if (uidTag != null ? !k.contains(uidTag) : k.contains('.uid.')) continue;
      await armazenamento.remover(k);
    }
    personagens = [for (final p in personagens) if (p.id != id) p];
    _gravarPersonagens();
    notifyListeners();
    return true;
  }

  /// Renomear o herói ativo (vazio volta ao nome padrão).
  void renomearHeroi(String nome) {
    final v = nome.trim();
    save.nomeHeroi = v.isEmpty ? nomePadraoHeroi(idioma) : v;
    _salvarTudo();
    notifyListeners();
  }

  /// Troca o sprite do herói ativo.
  void escolherSprite(int i) {
    if (i < 0 || i >= dados.herois.length) return;
    save.heroi = i;
    _salvarTudo();
    notifyListeners();
  }

  /// Grava tudo agora (telas que mudam estado sem passar por uma ação do jogo, como abrir Conquistas).
  Future<void> persistir() => _salvarTudo();

  // ---------- gravação ----------
  Future<void> _salvarTudo() async {
    _temaPreview = null; // qualquer ação em Tarefas desfaz a prévia de um cenário trancado
    checarConquistas();
    final ms = _agora().millisecondsSinceEpoch;
    // as quatro gravações saem juntas (cada uma já atualiza o cache na hora), sem esperar uma pela outra
    await Future.wait([
      armazenamento.gravar(chaveSave(uid: uid, personagem: personagem), jsonEncode(save.paraJson(catalogo, salvoEm: ms))),
      armazenamento.gravar(chaveConta(_chaveVida, uid: uid, personagem: personagem), jsonEncode({'vida': vida, 'ultimoDia': ultimoDia})),
      armazenamento.gravar(chaveConta(_chaveDescanso, uid: uid, personagem: personagem), jsonEncode(descanso)),
      armazenamento.gravar(chaveConta(_chaveConcluidas, uid: uid, personagem: personagem), '$totalConcluidas'),
      if (bauDia != null) armazenamento.gravar(chaveConta(_chaveBauDia, uid: uid, personagem: personagem), jsonEncode(bauDia)),
      armazenamento.gravar(chaveConta(_chavePity, uid: uid, personagem: personagem), '$pity'),
      armazenamento.gravar(chaveConta(_chaveHist, uid: uid, personagem: personagem), gravarHistorico(hist)),
      armazenamento.gravar(chaveConta(_chaveVistos, uid: uid, personagem: personagem), jsonEncode(itensVistos.toList()..sort())),
      armazenamento.gravar(chaveConta(_chaveConqDesbloq, uid: uid, personagem: personagem), jsonEncode(conqDesbloq)),
      if (lojaDia != null)
        armazenamento.gravar(
          chaveConta(_chaveLoja, uid: uid, personagem: personagem),
          jsonEncode({'dia': lojaDia, 'estoque': [for (final v in lojaEstoque) {'id': v.id, 'o': v.oferta ? 1 : 0}], 'vendidos': lojaVendidos}),
        ),
    ]);
  }
}
