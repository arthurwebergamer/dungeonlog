// Tarefa do save. Guarda o mapa JSON original para não perder nenhum campo (inclusive os que o Dart ainda
// não conhece): o app novo e o antigo precisam conseguir ler o save um do outro.
//
// Campos conhecidos: texto, tipo (hoje|repete|mensal|anual), data, dias, diaMes, diaAno, mesAno, feitaEm,
// dif, meta, corBox, categoriaId, pulaEm, vezesData, vezesN.
import 'economia.dart';

class Tarefa {
  final Map<String, dynamic> dados;
  Tarefa(this.dados);

  factory Tarefa.deJson(Map<String, dynamic> json) => Tarefa(Map<String, dynamic>.from(json));

  String? get texto => dados['texto'] is String ? dados['texto'] as String : null;
  String? get tipo => dados['tipo'] is String ? dados['tipo'] as String : null;
  String? get feitaEm => dados['feitaEm'] is String ? dados['feitaEm'] as String : null;
  String get dif => difDe(dados['dif']);

  /// Vezes por dia (`meta`); 1 quando ausente ou menor que 2.
  int get meta {
    final m = dados['meta'];
    return (m is num && m > 1) ? m.round() : 1;
  }

  Map<String, dynamic> paraJson() => dados;
}
