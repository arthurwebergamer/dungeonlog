// Datas do jogo. Espelha isoDe, diffDias, diasCorridos e ocorreNoDia de play/index.html (~2809 a 2831, 3319 a 3345, 3435).
// Datas do app são strings ISO locais "AAAA-MM-DD"; o dia "de jogo" é o dia do relógio do aparelho.
import 'js_compat.dart';
import 'tarefa.dart';

final RegExp _reIso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// ISO -> DateTime local ao meio-dia (como `new Date(iso + 'T12:00:00')`). Null se a data não existir.
DateTime? isoParaMeioDia(String iso) {
  final m = _reIso.firstMatch(iso);
  if (m == null) return null;
  final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
  // como o V8: mês 1-12 e dia 1-31 valem, e dia inexistente (2026-02-30) rola para o mês seguinte
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
  return DateTime(y, mo, d, 12);
}

/// `isoDe(d)`: data local de [d] como "AAAA-MM-DD".
String isoDe(DateTime d) {
  final l = d.toLocal();
  return '${l.year.toString().padLeft(4, '0')}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
}

/// `diffDias(a, b)`: A - B em dias inteiros; 0 se alguma data for inválida.
int diffDias(String isoA, String isoB) {
  final a = isoParaMeioDia(isoA), b = isoParaMeioDia(isoB);
  if (a == null || b == null) return 0;
  return jsRound((a.millisecondsSinceEpoch - b.millisecondsSinceEpoch) / 86400000);
}

/// ISO do dia seguinte (soma 24h ao meio-dia, como o JS).
String proximoDiaIso(String iso) => isoDe(isoParaMeioDia(iso)!.add(const Duration(days: 1)));

/// Dia da semana como no JS (`getDay`): 0 = domingo ... 6 = sábado. Null se a data for inválida.
int? diaDaSemanaIso(String iso) {
  final d = isoParaMeioDia(iso);
  return d == null ? null : d.weekday % 7;
}

/// `diasCorridos()` com o fuso explícito (minutos a LESTE de UTC). Reproduz a conta do JS,
/// `floor(meia-noite local em ms / 86400000)`, inclusive o desvio de um dia em fusos a leste de UTC
/// (por isso o monstro do dia é o mesmo em todos os aparelhos de um mesmo fuso, como hoje).
int diasCorridosComFuso(int ano, int mes, int dia, int offsetMinutosLeste) {
  final msUtc = DateTime.utc(ano, mes, dia).millisecondsSinceEpoch;
  return divPiso(msUtc - offsetMinutosLeste * 60000, 86400000);
}

/// `diasCorridos()` para uma data local qualquer (usa o fuso do aparelho).
int diasCorridos(DateTime agora) {
  final meiaNoite = DateTime(agora.year, agora.month, agora.day);
  return divPiso(meiaNoite.millisecondsSinceEpoch, 86400000);
}

int _diasNoMes(int ano, int mes) => DateTime(ano, mes + 1, 0).day;

bool diaMesOcorreNoDia(Tarefa t, String iso) {
  final d = isoParaMeioDia(iso);
  if (d == null) return false;
  final diaMes = numeroOu0(t.dados['diaMes']);
  final alvo = _min(diaMes == 0 ? 1 : diaMes, _diasNoMes(d.year, d.month));
  return d.day == alvo;
}

bool anualOcorreNoDia(Tarefa t, String iso) {
  final d = isoParaMeioDia(iso);
  if (d == null) return false;
  final mes = numeroOu0(t.dados['mesAno']);
  final mesAlvo = _min(_max(mes == 0 ? 1 : mes, 1), 12).toInt();
  if (d.month != mesAlvo) return false;
  final dia = numeroOu0(t.dados['diaAno']);
  final alvo = _min(dia == 0 ? 1 : dia, _diasNoMes(d.year, mesAlvo));
  return d.day == alvo;
}

num _min(num a, num b) => a < b ? a : b;
num _max(num a, num b) => a > b ? a : b;

/// `ocorreNoDia(t, iso)`: a tarefa vale nesse dia?
bool ocorreNoDia(Tarefa t, String iso) {
  final pula = t.dados['pulaEm'];
  if (pula is List && pula.contains(iso)) return false;
  final tipo = t.dados['tipo'];
  if (tipo == 'hoje') return t.dados['data'] == iso;
  if (tipo == 'mensal') return diaMesOcorreNoDia(t, iso);
  if (tipo == 'anual') return anualOcorreNoDia(t, iso);
  final dow = diaDaSemanaIso(iso);
  if (dow == null) return false;
  final dias = t.dados['dias'];
  return dias is List && dias.any((x) => x is num && x == dow);
}

bool feitaEm(Tarefa t, String iso) => t.dados['feitaEm'] == iso;
