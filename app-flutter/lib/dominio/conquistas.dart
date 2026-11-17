// Conquistas V2 (a lista curada e plana que o app original usa hoje): 18 marcos que desbloqueiam sozinhos quando o
// contexto do jogo bate a meta. Espelha play/index.html (~15069 a 15900): CATEGORIAS, IDS_CURADOS_V2, montarContexto,
// melhorSequenciaDeVitorias, checarDesbloqueiosV2. Não há resgate nem XP de recompensa na V2 (o sistema de resgate da V1
// continua no arquivo, mas nenhum botão o chama).
//
// Chaves (por conta e herói): `questlog.conquistasDesbloqueadasV2.v1` ({id: 'AAAA-MM-DD'}) e `questlog.conquistasVistasV2.v1`
// (lista de ids já vistos, para a bolinha e a etiqueta NOVO).
import 'catalogo.dart';
import 'datas.dart';
import 'historico.dart';

class ContextoConq {
  const ContextoConq({
    required this.melhorSequencia,
    required this.totalMortos,
    required this.distintosMortos,
    required this.totalMonstrosCatalogo,
    required this.nivel,
    required this.tarefasConcluidas,
    required this.itensVistos,
    required this.raridadesObtidas,
    required this.temGrimorio,
    required this.totalItensCatalogo,
  });
  final int melhorSequencia;
  final int totalMortos;
  final int distintosMortos;
  final int totalMonstrosCatalogo;
  final int nivel;
  final int tarefasConcluidas;
  final int itensVistos;
  final int raridadesObtidas;
  final bool temGrimorio;
  final int totalItensCatalogo;
}

class Conquista {
  const Conquista({
    required this.id,
    required this.categoria,
    required this.nome,
    required this.nomeEn,
    required this.cor,
    required this.meta,
    required this.valor,
    required this.req,
    required this.reqEn,
  });
  final String id;

  /// 'sequencia', 'monstros', 'nivel', 'tarefas' ou 'itens' (escolhe o ícone).
  final String categoria;
  final String nome;
  final String nomeEn;

  /// Cor da categoria, 0xRRGGBB.
  final int cor;
  final int Function(ContextoConq) meta;
  final int Function(ContextoConq) valor;
  final String Function(ContextoConq) req;
  final String Function(ContextoConq) reqEn;

  String nomeNoIdioma(String idioma) => idioma == 'en' ? nomeEn : nome;
  String reqNoIdioma(String idioma, ContextoConq c) => idioma == 'en' ? reqEn(c) : req(c);
}

Conquista _c(String id, String cat, int cor, String nome, String nomeEn, String req, String reqEn,
        {required int meta, required int Function(ContextoConq) valor}) =>
    Conquista(id: id, categoria: cat, nome: nome, nomeEn: nomeEn, cor: cor, meta: (_) => meta, valor: valor, req: (_) => req, reqEn: (_) => reqEn);

const _corSeq = 0xE5698A, _corMon = 0xB57BE8, _corNiv = 0xF2C94C, _corTar = 0x63C99A, _corIte = 0x5AA9F2;

/// As 18 conquistas, na ordem em que o original as lista (`IDS_CURADOS_V2`).
final List<Conquista> conquistasV2 = [
  _c('sequencia:0', 'sequencia', _corSeq, 'Primeiro Passo', 'First Step', 'Vença 1 dia seguido', 'Win 1 day in a row', meta: 1, valor: (c) => c.melhorSequencia),
  _c('sequencia:1', 'sequencia', _corSeq, 'Pegando o Jeito', 'Getting the Hang', 'Vença 5 dias seguidos', 'Win 5 days in a row', meta: 5, valor: (c) => c.melhorSequencia),
  _c('sequencia:2', 'sequencia', _corSeq, 'Consistência', 'Consistency', 'Vença 15 dias seguidos', 'Win 15 days in a row', meta: 15, valor: (c) => c.melhorSequencia),
  _c('sequencia:5', 'sequencia', _corSeq, 'Disciplina Absoluta', 'Absolute Discipline', 'Vença 60 dias seguidos', 'Win 60 days in a row', meta: 60, valor: (c) => c.melhorSequencia),
  _c('monstros:0', 'monstros', _corMon, 'Primeiro Sangue', 'First Blood', 'Derrote seu 1º monstro', 'Defeat your 1st monster', meta: 1, valor: (c) => c.totalMortos),
  _c('monstros:2', 'monstros', _corMon, 'Exterminador', 'Exterminator', 'Derrote 10 monstros', 'Defeat 10 monsters', meta: 10, valor: (c) => c.totalMortos),
  _c('monstros:6', 'monstros', _corMon, 'Lenda da Caçada', 'Legend of the Hunt', 'Derrote 60 monstros', 'Defeat 60 monsters', meta: 60, valor: (c) => c.totalMortos),
  Conquista(
    id: 'monstros:9',
    categoria: 'monstros',
    nome: 'Bestiário Completo',
    nomeEn: 'Complete Bestiary',
    cor: _corMon,
    meta: (c) => c.totalMonstrosCatalogo,
    valor: (c) => c.distintosMortos,
    req: (c) => 'Derrote todos os ${c.totalMonstrosCatalogo} monstros ao menos 1x',
    reqEn: (c) => 'Defeat all ${c.totalMonstrosCatalogo} monsters at least once',
  ),
  _c('nivel:0', 'nivel', _corNiv, 'Início da Jornada', 'Journey Begins', 'Alcance o nível II', 'Reach level II', meta: 2, valor: (c) => c.nivel),
  _c('nivel:2', 'nivel', _corNiv, 'Veterano', 'Veteran', 'Alcance o nível X', 'Reach level X', meta: 10, valor: (c) => c.nivel),
  _c('nivel:7', 'nivel', _corNiv, 'Ascensão', 'Ascension', 'Alcance o nível L', 'Reach level L', meta: 50, valor: (c) => c.nivel),
  _c('tarefas:0', 'tarefas', _corTar, 'Primeira Vitória', 'First Win', 'Conclua sua 1ª tarefa', 'Complete your 1st task', meta: 1, valor: (c) => c.tarefasConcluidas),
  _c('tarefas:2', 'tarefas', _corTar, 'Produtivo', 'Productive', 'Conclua 20 tarefas', 'Complete 20 tasks', meta: 20, valor: (c) => c.tarefasConcluidas),
  _c('tarefas:5', 'tarefas', _corTar, 'Imparável', 'Unstoppable', 'Conclua 50 tarefas', 'Complete 50 tasks', meta: 50, valor: (c) => c.tarefasConcluidas),
  _c('itens:0', 'itens', _corIte, 'Primeira Descoberta', 'First Discovery', 'Obtenha seu 1º item', 'Obtain your 1st item', meta: 1, valor: (c) => c.itensVistos),
  _c('itens:2', 'itens', _corIte, 'O Livro Proibido', 'The Forbidden Book', 'Obtenha o Grimório', 'Obtain the Grimoire', meta: 1, valor: (c) => c.temGrimorio ? 1 : 0),
  _c('itens:4', 'itens', _corIte, 'Explorador', 'Explorer', 'Descubra 20 itens distintos', 'Discover 20 distinct items', meta: 20, valor: (c) => c.itensVistos),
  Conquista(
    id: 'itens:8',
    categoria: 'itens',
    nome: 'Mestre do Grimório',
    nomeEn: 'Grimoire Master',
    cor: _corIte,
    meta: (c) => c.totalItensCatalogo,
    valor: (c) => c.itensVistos,
    req: (c) => 'Descubra todos os ${c.totalItensCatalogo} itens',
    reqEn: (c) => 'Discover all ${c.totalItensCatalogo} items',
  ),
];

/// `melhorSequenciaDeVitorias(hist)`: maior sequência de dias consecutivos com vitória; descanso congela.
int melhorSequenciaDeVitorias(List<EntradaHist> hist) {
  final ord = [...hist];
  final pos = {for (var i = 0; i < ord.length; i++) ord[i]: i};
  ord.sort((a, b) {
    final c = a.data.compareTo(b.data);
    return c != 0 ? c : pos[a]!.compareTo(pos[b]!);
  });
  var atual = 0, melhor = 0;
  String? anterior;
  for (final h in ord) {
    final seguido = anterior != null && diffDias(h.data, anterior) == 1;
    if (h.resultado == 'descanso') {
      anterior = h.data;
      continue;
    }
    if (h.resultado == 'vitoria') {
      atual = seguido ? atual + 1 : 1;
      if (atual > melhor) melhor = atual;
    } else {
      atual = 0;
    }
    anterior = h.data;
  }
  return melhor;
}

/// `montarContexto(true)`: [monstroDeHojeSeVencido] entra como uma vitória sintética de hoje (nunca é gravada).
ContextoConq montarContextoConq({
  required List<EntradaHist> hist,
  required String hoje,
  int? monstroDeHojeSeVencido,
  required int totalMonstros,
  required int nivel,
  required int tarefasConcluidas,
  required Set<int> vistos,
  required Catalogo catalogo,
  required int idGrimorio,
}) {
  var h = hist;
  if (monstroDeHojeSeVencido != null && monstroDeHojeSeVencido >= 0) {
    h = [...hist, EntradaHist(data: hoje, resultado: 'vitoria', monstroId: monstroDeHojeSeVencido, tarefas: 0)];
  }
  final vit = [for (final e in h) if (e.resultado == 'vitoria') e];
  final rars = <int>{};
  for (final id in vistos) {
    final it = catalogo.item(id);
    if (it != null) rars.add(it.raridade);
  }
  var totalItens = 0;
  for (var i = 0; i < catalogo.baseN; i++) {
    if (!catalogo.item(i)!.morto) totalItens++;
  }
  return ContextoConq(
    melhorSequencia: melhorSequenciaDeVitorias(h),
    totalMortos: vit.length,
    distintosMortos: {for (final e in vit) e.monstroId}.length,
    totalMonstrosCatalogo: totalMonstros,
    nivel: nivel,
    tarefasConcluidas: tarefasConcluidas,
    itensVistos: vistos.length,
    raridadesObtidas: rars.length,
    temGrimorio: idGrimorio >= 0 && vistos.contains(idGrimorio),
    totalItensCatalogo: totalItens,
  );
}

/// `checarDesbloqueiosV2`: devolve os ids que acabaram de bater a meta (e ainda não estavam desbloqueados).
List<String> novosDesbloqueios(ContextoConq ctx, Map<String, String> desbloqueios) =>
    [for (final c in conquistasV2) if (!desbloqueios.containsKey(c.id) && c.valor(ctx) >= c.meta(ctx)) c.id];

/// Nível em que o Grimório cai (`NIVEL_GRIMORIO = 4 + (semente % 4)`): IV, V, VI ou VII, por save.
int nivelDoGrimorio(num semente) => 4 + (semente.toInt() % 4);

/// `ID_GRIMORIO`: índice do item "Grimório" no catálogo base (-1 se não existir).
int idGrimorioDe(Catalogo cat) {
  for (var i = 0; i < cat.baseN; i++) {
    if (cat.item(i)!.nome == 'Grimório') return i;
  }
  return -1;
}
