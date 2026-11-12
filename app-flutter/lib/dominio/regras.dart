// Regras de XP, moedas, nível, bônus de equipamento, estágio e monstro do dia.
// Espelha play/index.html: xpDaTarefa/moedasDaTarefa/recompensaVitoria/precoVenda (~2725 a 2750),
// xpNecessario/progresso (~3356), bonusItem/bonusEquip/afixoSoma (~8379 a 8414), estagioAtual (~3489),
// poolMonstrosFiltrado/monstroDoDia/monstroDoDiaEm (~3441, ~3618).
import 'catalogo.dart';
import 'economia.dart';
import 'js_compat.dart';

/// Equipado: slot -> id do item (ou null).
typedef Equipado = Map<String, dynamic>;

class BonusEquip {
  final int m; // % de moedas
  final int x; // % de XP
  const BonusEquip(this.m, this.x);
  double get multMoedas => 1 + m / 100;
  double get multXp => 1 + x / 100;
}

/// `bonusItem(it)`: bônus de um item (equipamento usa a tabela por raridade, mantendo o sinal de maldição).
({int m, int x}) bonusItem(ItemCatalogo it) {
  if (!slotsEquip.contains(it.tipo)) return (m: it.bonusMoedas.toInt(), x: it.bonusXp.toInt());
  final b = bonusPorTipo[it.tipo];
  if (b == null) return (m: 0, x: 0);
  final r = it.raridade;
  return (
    m: it.bonusMoedas < 0 ? -jsRound(b.m[r] * 0.8) : b.m[r],
    x: it.bonusXp < 0 ? -jsRound(b.x[r] * 0.8) : b.x[r],
  );
}

/// `afixoSoma(k)`: soma do afixo entre os slots equipados, limitada pelo teto.
int afixoSoma(Catalogo cat, Equipado equipado, String k) {
  var t = 0;
  for (final s in slotsEquip) {
    final it = cat.item(equipado[s]);
    final a = it?.afixo;
    if (a != null && a.tipo == k) t += a.valor;
  }
  final teto = afixoTeto[k]!;
  return t.clamp(-teto, teto);
}

/// `bonusEquip()`
BonusEquip bonusEquip(Catalogo cat, Equipado equipado) {
  var m = 0, x = 0;
  for (final s in slotsEquip) {
    final it = cat.item(equipado[s]);
    if (it == null) continue;
    final b = bonusItem(it);
    m += b.m;
    x += b.x;
  }
  m += afixoSoma(cat, equipado, 'gan');
  x += afixoSoma(cat, equipado, 'est');
  return BonusEquip(m, x);
}

/// `xpDaTarefa(ordem, dif)`: [ordem] = quantas tarefas já foram concluídas hoje, incluindo esta (1 = primeira).
int xpDaTarefa(int ordem, Object? dif, {double multXp = 1}) {
  final base = Eco.xpPorTarefa * (ordem > Eco.xpTarefasCheias ? Eco.xpDecaimento : 1);
  final v = jsRound(base * multXp * multDif(dif ?? difPadrao));
  return v < 1 ? 1 : v;
}

/// `moedasDaTarefa(dif)` guarda o resto fracionário entre chamadas (só em memória, como no JS).
class AcumuladorMoedas {
  double _resto = 0;
  int moedasDaTarefa(Object? dif, {double multMoedas = 1}) {
    final bruto = Eco.moedasPorTarefa * multMoedas * multDif(dif ?? difPadrao) + _resto;
    var inteiro = bruto.floor();
    if (inteiro < 1) inteiro = 1;
    _resto = bruto - inteiro;
    return inteiro;
  }
}

/// `recompensaVitoria(nTarefas)`
int recompensaVitoria(int nTarefas, {double multMoedas = 1}) {
  final contadas = nTarefas < Eco.moedasVitoriaTeto ? nTarefas : Eco.moedasVitoriaTeto;
  final bruto = Eco.moedasVitoriaBase + Eco.moedasVitoriaPorTarefa * contadas;
  final v = jsRound(bruto * multMoedas);
  return v < 1 ? 1 : v;
}

/// ATENÇÃO com [ordem]: na conclusão (última vez da meta) conta a própria tarefa (já feita hoje = ordem);
/// no toque PARCIAL de uma tarefa com meta>1 o JS usa a ordem SEM contar a tarefa atual (`ordemParcial`, alternar ~6418).
/// XP e moedas de uma conclusão de tarefa com `meta` vezes por dia (expressões de `alternar()`): o ganho é dividido pela meta.
({int xp, int moedas}) ganhoPorConclusao({
  required int ordem,
  required Object? dif,
  required int meta,
  required AcumuladorMoedas acumulador,
  double multXp = 1,
  double multMoedas = 1,
}) {
  final xp = xpDaTarefa(ordem, dif, multXp: multXp);
  final mo = acumulador.moedasDaTarefa(dif, multMoedas: multMoedas);
  if (meta <= 1) return (xp: xp, moedas: mo);
  int div(int v) {
    final r = jsRound(v / meta);
    return r < 1 ? 1 : r;
  }
  return (xp: div(xp), moedas: div(mo));
}

/// `precoVenda(it)`
int precoVenda(String tipo, int valor) {
  final taxa = tipo == 'tesouro' ? Eco.taxaVendaTesouro : Eco.taxaVenda;
  final v = jsRound(valor * taxa);
  return v < 1 ? 1 : v;
}

/// XP necessário para sair do nível [n].
int xpNecessario(int n) => Eco.nivelBase + (n - 1) * Eco.nivelIncremento;

class Progresso {
  final int nivel;
  final num resto;
  final int meta;
  const Progresso(this.nivel, this.resto, this.meta);
}

/// `progresso()`
Progresso progresso(num xpTotal) {
  var nivel = 1;
  num resto = xpTotal;
  while (resto >= xpNecessario(nivel)) {
    resto -= xpNecessario(nivel);
    nivel++;
  }
  return Progresso(nivel, resto, xpNecessario(nivel));
}

/// `estagioAtual()` a partir do total de tarefas concluídas (1 a 4).
int estagioAtual(int totalConcluidas) {
  var estagio = 1;
  for (var i = 0; i < limiaresEstagio.length; i++) {
    if (totalConcluidas >= limiaresEstagio[i]) {
      estagio = i + 2;
    } else {
      break;
    }
  }
  return estagio;
}

/// `progressoEstagio()`: 0 a 1 dentro do estágio atual.
double progressoEstagio(int totalConcluidas) {
  final estagio = estagioAtual(totalConcluidas);
  if (estagio >= 4) return 1;
  final inicio = estagio == 1 ? 0 : limiaresEstagio[estagio - 2];
  final alvo = limiaresEstagio[estagio - 1];
  if (alvo == inicio) return 1;
  final p = (totalConcluidas - inicio) / (alvo - inicio);
  return p.clamp(0.0, 1.0);
}

/// `poolMonstrosFiltrado()`: índices dos monstros do bioma exibido (os sem bioma valem em todos).
List<int> poolMonstros(List<String?> biomasDosMonstros, String? biomaExibido) {
  if (biomaExibido == null) return [for (var i = 0; i < biomasDosMonstros.length; i++) i];
  return [
    for (var i = 0; i < biomasDosMonstros.length; i++)
      if (biomasDosMonstros[i] == null || biomasDosMonstros[i] == biomaExibido) i,
  ];
}

/// `monstroDoDia()`: índice do monstro de hoje. [diasCorridos] vem de `diasCorridos(...)`.
int monstroDoDia({required List<int> pool, required int totalMonstros, required int diasCorridos, required int semente}) {
  final n = pool.isEmpty ? totalMonstros : pool.length;
  final i = (diasCorridos + semente) % n;
  return pool.isEmpty ? i : pool[i];
}

/// `monstroDoDiaEm(iso)`: mesmo ciclo para outro dia; [diasAteHoje] = diffDias(iso, hoje).
int monstroDoDiaEm({required List<int> pool, required int totalMonstros, required int diasCorridos, required int diasAteHoje, required int semente}) {
  final n = pool.isEmpty ? totalMonstros : pool.length;
  final idx = (((diasCorridos + diasAteHoje + semente) % n) + n) % n;
  return pool.isEmpty ? idx : pool[idx];
}
