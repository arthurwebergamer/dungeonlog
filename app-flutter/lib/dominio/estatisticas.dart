// Regras da aba Estatísticas (Fase 4), em Dart puro. Espelham o módulo de estatísticas de play/index.html (~7443 a 8052):
// estStreakAtual, estRecorde, estHistComHojeAoVivo, renderEstatisticas (as contas), renderUltimos7Dias, renderDonutMes,
// renderMapaDoMes, renderHistoricoSemana e renderHistoricoAno. O histórico (`EntradaHist`) e o recorde
// (`melhorSequenciaDeVitorias`, idêntico a `estRecorde`) vêm da Fase 3 e NÃO são duplicados aqui.
//
// A aritmética de datas é feita sobre o calendário (dia civil, em UTC), nunca sobre o relógio local: não depende do fuso
// do aparelho nem de horário de verão. O JS soma 24 h a "AAAA-MM-DDT12:00:00" local, que dá o mesmo dia civil.
import 'conquistas.dart' show melhorSequenciaDeVitorias;
import 'historico.dart';
import 'js_compat.dart';

/// Resultados de um dia no histórico.
const resVitoria = 'vitoria';
const resFuga = 'fuga';
const resDescanso = 'descanso';
const resSemTarefa = 'sem_tarefa';

/// (ano, mês 1-12, dia) de "AAAA-MM-DD". Null se não for esse formato.
({int a, int m, int d})? partesIso(String iso) {
  final p = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (p == null) return null;
  return (a: int.parse(p[1]!), m: int.parse(p[2]!), d: int.parse(p[3]!));
}

String _doisDig(int n) => n.toString().padLeft(2, '0');
String isoDeCivil(int a, int m, int d) => '${a.toString().padLeft(4, '0')}-${_doisDig(m)}-${_doisDig(d)}';

/// Soma [n] dias (pode ser negativo) a uma data ISO, pelo calendário.
String isoMaisDias(String iso, int n) {
  final p = partesIso(iso)!;
  final x = DateTime.utc(p.a, p.m, p.d + n);
  return isoDeCivil(x.year, x.month, x.day);
}

/// Dia da semana como `Date.getDay()`: 0 = domingo ... 6 = sábado.
int diaSemanaIso(String iso) {
  final p = partesIso(iso)!;
  return DateTime.utc(p.a, p.m, p.d).weekday % 7;
}

int diasNoMesCivil(int ano, int mes) => DateTime.utc(ano, mes + 1, 0).day;

Map<String, String> _porData(List<EntradaHist> hist) {
  // `new Map(hist.map(h => [h.data, h.resultado]))`: se a data repete, vale a última
  final m = <String, String>{};
  for (final h in hist) {
    m[h.data] = h.resultado;
  }
  return m;
}

/// `estStreakAtual(hist)`: dias seguidos de vitória terminando hoje (ou ontem, se hoje ainda não tem registro).
/// Dia de descanso não soma nem quebra.
int estStreakAtual(List<EntradaHist> hist, String hoje) {
  final porData = _porData(hist);
  var cursor = hoje;
  if (!porData.containsKey(cursor)) cursor = isoMaisDias(cursor, -1);
  var streak = 0;
  while (porData[cursor] == resVitoria || porData[cursor] == resDescanso) {
    if (porData[cursor] == resVitoria) streak++;
    cursor = isoMaisDias(cursor, -1);
  }
  return streak;
}

/// `estRecorde(hist)`: é a mesma regra de `melhorSequenciaDeVitorias` (Fase 3).
int estRecorde(List<EntradaHist> hist) => melhorSequenciaDeVitorias(hist);

/// `estHistComHojeAoVivo(hoje)`: o histórico gravado só ganha o dia na virada; aqui hoje entra "ao vivo" (sem gravar)
/// como descanso, se for dia de descanso, ou como vitória, se há tarefas hoje e todas estão feitas.
List<EntradaHist> estHistComHojeAoVivo({
  required List<EntradaHist> hist,
  required String hoje,
  required bool descansando,
  required int totalTarefasHoje,
  required bool todasFeitasHoje,
}) {
  if (hist.any((h) => h.data == hoje)) return hist;
  if (descansando) return [...hist, EntradaHist(data: hoje, resultado: resDescanso, monstroId: null, tarefas: 0)];
  if (totalTarefasHoje > 0 && todasFeitasHoje) {
    return [...hist, EntradaHist(data: hoje, resultado: resVitoria, monstroId: null, tarefas: totalTarefasHoje)];
  }
  return hist;
}

/// Qual frase vai sob o número da sequência (`estStreakLbl`).
enum RotuloSequencia { vencaHoje, recordeAtual, faltaUm, faltam }

class ResumoEst {
  const ResumoEst({
    required this.streak,
    required this.recorde,
    required this.rotulo,
    required this.faltam,
    required this.vitoriasTotal,
    required this.fugasTotal,
    required this.taxaGeral,
    required this.vitoriasMes,
    required this.fugasMes,
    required this.semTarefaMes,
    required this.descansoMes,
    required this.taxaMes,
    required this.totalMes,
  });
  final int streak, recorde;
  final RotuloSequencia rotulo;
  final int faltam;

  /// "Desde o início": dias vencidos e a taxa geral (vitórias / (vitórias + fugas)).
  final int vitoriasTotal, fugasTotal, taxaGeral;

  /// Composição do mês de hoje (donut e legenda) e a taxa (anel).
  final int vitoriasMes, fugasMes, semTarefaMes, descansoMes, taxaMes;

  /// `total` do donut: soma das quatro categorias.
  final int totalMes;
}

/// As contas de `renderEstatisticas` (cabeçalho, "desde o início", anel e donut do mês de [hoje]).
ResumoEst resumoEstatisticas(List<EntradaHist> hist, String hoje) {
  final streak = estStreakAtual(hist, hoje);
  final recorde = estRecorde(hist);
  final RotuloSequencia rotulo;
  var faltam = 0;
  if (recorde == 0) {
    rotulo = RotuloSequencia.vencaHoje;
  } else if (streak >= recorde) {
    rotulo = RotuloSequencia.recordeAtual;
  } else {
    faltam = recorde - streak;
    rotulo = faltam == 1 ? RotuloSequencia.faltaUm : RotuloSequencia.faltam;
  }
  final vit = hist.where((h) => h.resultado == resVitoria).length;
  final fug = hist.where((h) => h.resultado == resFuga).length;
  final taxaGeral = vit + fug > 0 ? jsRound(vit / (vit + fug) * 100) : 0;

  final prefixo = hoje.substring(0, 7); // "AAAA-MM"
  final doMes = hist.where((h) => h.data.startsWith(prefixo)).toList();
  int conta(String r) => doMes.where((h) => h.resultado == r).length;
  final vM = conta(resVitoria), fM = conta(resFuga), sM = conta(resSemTarefa), dM = conta(resDescanso);
  final taxaMes = vM + fM > 0 ? jsRound(vM / (vM + fM) * 100) : 0;
  return ResumoEst(
    streak: streak,
    recorde: recorde,
    rotulo: rotulo,
    faltam: faltam,
    vitoriasTotal: vit,
    fugasTotal: fug,
    taxaGeral: taxaGeral,
    vitoriasMes: vM,
    fugasMes: fM,
    semTarefaMes: sM,
    descansoMes: dM,
    taxaMes: taxaMes,
    totalMes: vM + fM + sM + dM,
  );
}

/// Dia do mapa (mês ou semana): o número do dia e o resultado (null = sem registro / ainda não chegou).
class DiaMapa {
  const DiaMapa(this.dia, this.resultado, {this.iso = ''});
  final int dia;
  final String? resultado;
  final String iso;
}

/// `renderMapaDoMes(hist, ano, mes)`: um tile por dia do mês; só dias até hoje mostram resultado.
List<DiaMapa> mapaDoMes(List<EntradaHist> hist, int ano, int mes, String hoje) {
  final porData = _porData(hist);
  final n = diasNoMesCivil(ano, mes);
  return [
    for (var d = 1; d <= n; d++)
      () {
        final iso = isoDeCivil(ano, mes, d);
        return DiaMapa(d, iso.compareTo(hoje) <= 0 ? porData[iso] : null, iso: iso);
      }(),
  ];
}

/// `renderHistoricoSemana(hist)`: os 7 dias terminando hoje (do mais antigo para hoje). Hoje aparece mesmo sem registro.
List<DiaMapa> mapaDaSemana(List<EntradaHist> hist, String hoje) {
  final porData = _porData(hist);
  return [
    for (var i = 6; i >= 0; i--)
      () {
        final iso = isoMaisDias(hoje, -i);
        return DiaMapa(partesIso(iso)!.d, porData[iso], iso: iso);
      }(),
  ];
}

/// `renderHistoricoAno(hist, ano)`: para cada mês (1 a 12), o resultado de cada dia (null = neutro, inclusive o futuro).
/// Só vitória, fuga e descanso têm cor; sem_tarefa fica neutro.
List<List<String?>> mapaDoAno(List<EntradaHist> hist, int ano, String hoje) {
  final porData = _porData(hist);
  return [
    for (var m = 1; m <= 12; m++)
      [
        for (var d = 1; d <= diasNoMesCivil(ano, m); d++)
          () {
            final iso = isoDeCivil(ano, m, d);
            if (iso.compareTo(hoje) > 0) return null;
            final r = porData[iso];
            return (r == resVitoria || r == resFuga || r == resDescanso) ? r : null;
          }(),
      ],
  ];
}

/// Ponto do gráfico dos últimos 7 dias: posição no viewBox 300x80 e a opacidade do círculo (alpha da cor de destaque).
class PontoGrafico {
  const PontoGrafico(this.x, this.y, this.alfa);
  final double x, y, alfa;
  @override
  bool operator ==(Object o) => o is PontoGrafico && o.x == x && o.y == y && o.alfa == alfa;
  @override
  int get hashCode => Object.hash(x, y, alfa);
}

class Grafico7 {
  const Grafico7(this.pontos, this.diasSemana);

  /// Hoje sem resultado ("em andamento") não gera ponto, para a linha não despencar.
  final List<PontoGrafico> pontos;

  /// `getDay()` de cada um dos 7 rótulos (0 = domingo), do mais antigo para hoje.
  final List<int> diasSemana;
}

const double grafLargura = 300, grafAltura = 80, grafYVitoria = 8, grafYFuga = 45, grafYVazio = 72;

/// `renderUltimos7Dias(hist)`: vitória no topo, fuga no meio, sem registro na base (menos hoje em andamento).
Grafico7 ultimos7Dias(List<EntradaHist> hist, String hoje) {
  final porData = _porData(hist);
  final pontos = <PontoGrafico>[];
  final dias = <int>[];
  for (var i = 6; i >= 0; i--) {
    final iso = isoMaisDias(hoje, -i);
    final r = porData[iso];
    final x = (6 - i) * (grafLargura / 6);
    final emAndamento = i == 0 && r == null;
    if (!emAndamento) {
      var y = grafYVazio, alfa = 0.18;
      if (r == resVitoria) {
        y = grafYVitoria;
        alfa = 1;
      } else if (r == resFuga) {
        y = grafYFuga;
        alfa = 0.45;
      }
      pontos.add(PontoGrafico(x, y, alfa));
    }
    dias.add(diaSemanaIso(iso));
  }
  return Grafico7(pontos, dias);
}

/// `escalaTocha(streak)` do popup da sequência (e da tocha do cartão): 1x até 1 dia, 1,9x em 7, 2,75x de 30 em diante.
double escalaTocha(int streak) {
  const min = 1.0, meio = 1.9, max = 2.75;
  if (streak <= 1) return min;
  if (streak <= 7) return min + (streak - 1) / 6 * (meio - min);
  if (streak <= 30) return meio + (streak - 7) / 23 * (max - meio);
  return max;
}

/// `escalaTochaCompartilhar(streak)`: a tocha do cartão 9:16 é maior (a única protagonista).
double escalaTochaCompartilhar(int streak) {
  const min = 1.8, meio = 2.9, max = 3.6;
  if (streak <= 1) return min;
  if (streak <= 7) return min + (streak - 1) / 6 * (meio - min);
  if (streak <= 30) return meio + (streak - 7) / 23 * (max - meio);
  return max;
}

/// Como `corDoStreak(streak)` mistura as cores: 0 = sem sequência (cor "dim"); senão `de` misturado a `para` em [pct]%
/// (`color-mix(in srgb, para pct%, de)`). Os nomes são as variáveis do tema: 'text', 'accent' e 'gold'.
class MisturaCor {
  const MisturaCor(this.de, this.para, this.pct);
  final String de, para;
  final int pct;
  @override
  bool operator ==(Object o) => o is MisturaCor && o.de == de && o.para == para && o.pct == pct;
  @override
  int get hashCode => Object.hash(de, para, pct);
}

/// `corDoStreak(streak)`. Retorna null para "dim" (sequência zero) e a mistura para os demais casos
/// (`MisturaCor('gold','gold',0)` quando passa de 30).
MisturaCor? corDoStreak(int streak) {
  if (streak <= 0) return null;
  if (streak < 7) return MisturaCor('text', 'accent', jsRound((streak - 1) / 6 * 100));
  if (streak < 30) return MisturaCor('accent', 'gold', jsRound((streak - 7) / 23 * 100));
  return const MisturaCor('gold', 'gold', 0);
}

/// Ano de hoje e o mês, de uma data ISO.
({int ano, int mes}) anoMesDe(String iso) {
  final p = partesIso(iso)!;
  return (ano: p.a, mes: p.m);
}

/// Como o anel da taxa pinta a trilha: sem nada (0%), o arco em degradê (1 a 99%) ou o anel todo cheio (100%).
enum TrilhaAnel { nenhuma, arco, cheia }

TrilhaAnel trilhaDoAnel(int taxa) => taxa == 0 ? TrilhaAnel.nenhuma : (taxa >= 100 ? TrilhaAnel.cheia : TrilhaAnel.arco);

/// Fatias do donut (em %, acumuladas): vitória até [vit], fuga até [fuga], descanso até [desc]; o resto é "sem tarefa".
/// Sem nenhum dia ([total] 0) o donut inteiro fica neutro.
({double vit, double fuga, double desc}) fatiasDonut(int vitorias, int fugas, int descansos, int total) {
  if (total == 0) return (vit: 0, fuga: 0, desc: 0);
  final pVit = vitorias / total * 100;
  final pFuga = pVit + fugas / total * 100;
  final pDesc = pFuga + descansos / total * 100;
  return (vit: pVit, fuga: pFuga, desc: pDesc);
}

/// Largura (%) da barrinha de cada linha da legenda do donut.
double larguraBarra(int n, int total) => total > 0 ? n / total * 100 : 0;

const _mesesPt = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
const _mesesEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/// "Novembro de 2026" / "November 2026": `toLocaleDateString(pt-BR | en-US, {month:'long', year:'numeric'})` com a 1ª letra maiúscula.
String rotuloMesAno(int ano, int mes, String idioma) {
  if (idioma == 'en') return '${_mesesEn[mes - 1]} $ano';
  final n = _mesesPt[mes - 1];
  return '${n[0].toUpperCase()}${n.substring(1)} de $ano';
}

const diasSemanaPt = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb'];
const diasSemanaEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/// `NOMES_MES_CURTO` (histórico do ano).
const mesesCurtosPt = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
const mesesCurtosEn = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];

/// Ano mostrado na visão "Anual": o escolhido, ou o de hoje se ainda não escolheu.
int anoEfetivo(int? escolhido, int anoHoje) => escolhido ?? anoHoje;
