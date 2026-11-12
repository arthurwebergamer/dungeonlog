// Vida do herói e virada do dia. Espelha o bloco "VIDA DO HEROI" de play/index.html (~10583 a 10904):
// vidaMax, curar, ferir e verificarVirada. As animações e pop-ups ficam para a interface; aqui só o estado.
import 'datas.dart';
import 'economia.dart';
import 'js_compat.dart';
import 'regras.dart';
import 'tarefa.dart';

/// `vidaMax()` para o nível dado.
int vidaMax(int nivel) {
  final v = jsRound(Eco.vidaBase + Eco.vidaPorNivel * (nivel - 1));
  return v < 1 ? 1 : v;
}

/// Quantas tarefas (de [tarefas]) valem em [iso] e não foram feitas nesse dia.
List<Tarefa> pendentesEm(List<Tarefa> tarefas, String iso) =>
    [for (final t in tarefas) if (ocorreNoDia(t, iso) && t.feitaEm != iso) t];

List<Tarefa> tarefasEm(List<Tarefa> tarefas, String iso) => [for (final t in tarefas) if (ocorreNoDia(t, iso)) t];

/// Um dia que fechou, para o histórico (data, total de tarefas, tarefas largadas, descanso).
class RegistroDia {
  final String data;
  final int total;
  final int largadas;
  final bool descansou;
  const RegistroDia(this.data, this.total, this.largadas, this.descansou);
  @override
  String toString() => '[$data,$total,$largadas,$descansou]';
}

class ResultadoVirada {
  final int vida;
  final String? ultimoDia;
  final int moedas;
  final List<RegistroDia> historico;
  final int danoAplicado; // 0 se não houve dano
  final bool caiu; // vida zerou (perdeu parte das moedas)
  final int moedasPerdidas;
  final bool vitoriaAutomatica; // dia todo concluído sem "Terminar dia": moedas e cura creditadas
  final List<Tarefa> largadas;
  final String? diaQueVirou;
  const ResultadoVirada({
    required this.vida,
    required this.ultimoDia,
    required this.moedas,
    required this.historico,
    required this.danoAplicado,
    required this.caiu,
    required this.moedasPerdidas,
    required this.vitoriaAutomatica,
    required this.largadas,
    required this.diaQueVirou,
  });
}

/// `curar(n)`: soma vida até o máximo. Uso: [Eco.curaPorTarefa] a cada conclusão (não no toque parcial de meta)
/// e `jsRound(vidaMax * Eco.curaVitoria)` na transição para vitória do dia.
int curar({required int vida, required int vidaMaxima, required int cura}) =>
    cura <= 0 ? vida : (vida + cura > vidaMaxima ? vidaMaxima : vida + cura);

/// Resultado de `ferir(n)` sobre a vida.
({int vida, int moedas, bool caiu, int moedasPerdidas}) ferir({
  required int vida,
  required int moedas,
  required int vidaMaxima,
  required int dano,
  bool quedaNaFila = false,
}) {
  vida -= dano;
  if (vida <= 0) {
    vida = vidaMaxima;
    if (quedaNaFila) return (vida: vida, moedas: moedas, caiu: true, moedasPerdidas: 0);
    final perdidas = (moedas * Eco.penalidadeMorte).floor();
    return (vida: vida, moedas: moedas - perdidas, caiu: true, moedasPerdidas: perdidas);
  }
  return (vida: vida, moedas: moedas, caiu: false, moedasPerdidas: 0);
}

/// `verificarVirada()`: roda ao abrir o app e quando o dia muda.
///
/// - [vida] null = nunca gravada (começa cheia). [ultimoDia] null = primeira abertura.
/// - Só o último dia visto causa dano; os dias pulados entram no histórico, sem dano (voltar nunca pode ser pior que não sair).
/// - [descansando] diz se um dia está marcado como descanso.
/// - [multMoedas] é o multiplicador de moedas do equipamento (usado na vitória automática).
ResultadoVirada verificarVirada({
  required String hoje,
  required String? ultimoDia,
  required int? vida,
  required num xpTotal,
  required int moedas,
  required String? derrotadoEm,
  required List<Tarefa> tarefas,
  required bool Function(String iso) descansando,
  double multMoedas = 1,
  bool quedaNaFila = false,
}) {
  final max = vidaMax(progresso(xpTotal).nivel);
  var v = (vida ?? max).clamp(0, max);
  ResultadoVirada semMudanca(String? ud) => ResultadoVirada(
        vida: v, ultimoDia: ud, moedas: moedas, historico: const [], danoAplicado: 0, caiu: false,
        moedasPerdidas: 0, vitoriaAutomatica: false, largadas: const [], diaQueVirou: null);

  if (ultimoDia == null) return semMudanca(hoje);
  if (ultimoDia == hoje) return semMudanca(ultimoDia);
  // relógio andou para trás: só ressincroniza, nunca pune
  if (ultimoDia.compareTo(hoje) > 0) return semMudanca(hoje);

  final descansou = descansando(ultimoDia);
  final largadas = descansou ? <Tarefa>[] : pendentesEm(tarefas, ultimoDia);
  final diaVirada = ultimoDia;
  var dano = 0.0;
  for (final t in largadas) {
    dano += Eco.danoPorTarefa * multDif(difDe(t.dados['dif']));
  }

  final historico = <RegistroDia>[RegistroDia(ultimoDia, tarefasEm(tarefas, ultimoDia).length, largadas.length, descansou)];
  var d = isoParaMeioDia(diaVirada) == null ? hoje : proximoDiaIso(diaVirada); // data inválida: o JS aborta o laço (try/catch)
  for (var n = 0; d.compareTo(hoje) < 0 && n < 366; n++) {
    final descD = descansando(d);
    historico.add(RegistroDia(d, tarefasEm(tarefas, d).length, descD ? 0 : pendentesEm(tarefas, d).length, descD));
    if (isoParaMeioDia(d) == null) break;
    d = proximoDiaIso(d);
  }

  var mo = moedas;
  var vitoriaAuto = false;
  final totalDiaVirada = tarefasEm(tarefas, diaVirada).length;
  if (!descansou && largadas.isEmpty && totalDiaVirada > 0 && derrotadoEm != diaVirada) {
    mo += recompensaVitoria(totalDiaVirada, multMoedas: multMoedas);
    final cura = jsRound(max * Eco.curaVitoria);
    if (cura > 0) v = (v + cura) > max ? max : v + cura;
    vitoriaAuto = true;
  }

  var danoAplicado = 0;
  var caiu = false;
  var perdidas = 0;
  if (dano > 0) {
    danoAplicado = jsRound(dano) < 1 ? 1 : jsRound(dano);
    final r = ferir(vida: v, moedas: mo, vidaMaxima: max, dano: danoAplicado, quedaNaFila: quedaNaFila);
    v = r.vida;
    mo = r.moedas;
    caiu = r.caiu;
    perdidas = r.moedasPerdidas;
  }

  return ResultadoVirada(
    vida: v, ultimoDia: hoje, moedas: mo, historico: historico, danoAplicado: danoAplicado, caiu: caiu,
    moedasPerdidas: perdidas, vitoriaAutomatica: vitoriaAuto, largadas: largadas, diaQueVirou: diaVirada,
  );
}
