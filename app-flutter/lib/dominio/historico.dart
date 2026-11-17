// Histórico permanente de dias (`questlog.hist.v1`) e o que o Bestiário e as Conquistas leem dele.
// Espelha o bloco HISTORICO de play/index.html (~14711 a 14850): `registrarHistorico` e a entrada
// `{data, resultado, monstroId, tarefas}`. A Fase 4 (Estatísticas) usa o mesmo formato.
import 'dart:convert';

import 'datas.dart';

class EntradaHist {
  const EntradaHist({required this.data, required this.resultado, required this.monstroId, required this.tarefas});
  final String data;

  /// 'vitoria', 'fuga', 'sem_tarefa' ou 'descanso'.
  final String resultado;

  /// Índice do monstro daquele dia no catálogo (null se não deu para calcular).
  final int? monstroId;
  final int tarefas;

  Map<String, dynamic> paraJson() => {'data': data, 'resultado': resultado, 'monstroId': monstroId, 'tarefas': tarefas};

  static EntradaHist? deJson(Object? j) {
    if (j is! Map || j['data'] is! String) return null;
    final m = j['monstroId'];
    final t = j['tarefas'];
    return EntradaHist(
      data: j['data'] as String,
      resultado: j['resultado'] is String ? j['resultado'] as String : '',
      monstroId: m is num ? m.toInt() : null,
      tarefas: t is num ? t.toInt() : 0,
    );
  }
}

/// Classifica o dia que fechou (`registrarHistorico`): descanso, sem tarefa, fuga (alguma largada) ou vitória.
String resultadoDoDia({required bool descanso, required int totalTarefas, required int largadas}) {
  if (descanso) return 'descanso';
  if (totalTarefas == 0) return 'sem_tarefa';
  if (largadas > 0) return 'fuga';
  return 'vitoria';
}

List<EntradaHist> lerHistorico(String? bruto) {
  if (bruto == null) return [];
  try {
    final d = jsonDecode(bruto);
    if (d is! List) return [];
    final r = <EntradaHist>[];
    for (final e in d) {
      final x = EntradaHist.deJson(e);
      if (x != null) r.add(x);
    }
    return r;
  } catch (_) {
    return [];
  }
}

String gravarHistorico(List<EntradaHist> l) => jsonEncode([for (final e in l) e.paraJson()]);

/// Monstros derrotados (vitórias do histórico) + o de hoje se o dia já foi vencido (`renderBestiario`, sem persistir).
Set<int> monstrosDerrotados(List<EntradaHist> hist, {int? monstroDeHojeSeVencido}) {
  final s = <int>{for (final h in hist) if (h.resultado == 'vitoria' && h.monstroId != null) h.monstroId!};
  if (monstroDeHojeSeVencido != null && monstroDeHojeSeVencido >= 0) s.add(monstroDeHojeSeVencido);
  return s;
}

/// Os últimos [n] monstros vistos, do mais recente (prévia do Bestiário no Perfil: `renderPreviewsPerfil`).
List<int> ultimosMonstrosVistos(List<EntradaHist> hist, {required String hoje, int? monstroDeHojeSeVencido, int n = 6}) {
  final vit = [for (final h in hist) if (h.resultado == 'vitoria' && h.monstroId != null) h];
  if (monstroDeHojeSeVencido != null && monstroDeHojeSeVencido >= 0 && !vit.any((v) => v.data == hoje)) {
    vit.add(EntradaHist(data: hoje, resultado: 'vitoria', monstroId: monstroDeHojeSeVencido, tarefas: 0));
  }
  // sort estável por data decrescente (o JS ordena de forma estável)
  final idx = {for (var i = 0; i < vit.length; i++) vit[i]: i};
  vit.sort((a, b) {
    final c = b.data.compareTo(a.data);
    return c != 0 ? c : idx[a]!.compareTo(idx[b]!);
  });
  final vistos = <int>[];
  final ja = <int>{};
  for (final v in vit) {
    if (!ja.add(v.monstroId!)) continue;
    vistos.add(v.monstroId!);
    if (vistos.length >= n) break;
  }
  return vistos;
}

/// Vitórias de um monstro (para a ficha: quantas vezes e a data da primeira), com o dia de hoje se for o caso.
({int vezes, String? primeira}) fichaDoMonstro(List<EntradaHist> hist, int idx, {String? hojeSeVencido}) {
  final datas = [for (final h in hist) if (h.monstroId == idx && h.resultado == 'vitoria') h.data];
  if (hojeSeVencido != null) datas.add(hojeSeVencido);
  if (datas.isEmpty) return (vezes: 0, primeira: null);
  var menor = datas.first;
  for (final d in datas) {
    if (d.compareTo(menor) < 0) menor = d;
  }
  return (vezes: datas.length, primeira: menor);
}

/// `formatarDataBR`: AAAA-MM-DD vira DD/MM/AAAA; vazio vira "—".
String formatarDataBR(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final p = iso.split('-');
  if (p.length < 3) return '${p.length > 2 ? p[2] : 'undefined'}/${p.length > 1 ? p[1] : 'undefined'}/${p[0]}';
  return '${p[2]}/${p[1]}/${p[0]}';
}

/// "Recuperação" do JS: se ontem não tem registro mas as tarefas dele estão todas feitas em ontem, grava vitória.
bool deveRecuperarOntem({required List<EntradaHist> hist, required String ontem, required int totalOntem, required bool todasFeitas}) =>
    !hist.any((h) => h.data == ontem) && totalOntem > 0 && todasFeitas;

String diaAnteriorIso(String hoje) => isoDe(DateTime.parse('${hoje}T12:00:00').subtract(const Duration(days: 1)));
