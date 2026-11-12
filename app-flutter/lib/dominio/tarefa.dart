// Tarefa do save. Guarda o mapa JSON original para não perder nenhum campo (inclusive os que o Dart ainda
// não conhece): o app novo e o antigo precisam conseguir ler o save um do outro.
//
// Campos conhecidos: texto, tipo (hoje|repete|mensal|anual), data, dias, diaMes, diaAno, mesAno, feitaEm,
// dif, meta, corBox, categoriaId, pulaEm, vezesData, vezesN.
import 'economia.dart';

/// Cores prontas da tarefa (`CORES_PRESET`).
const List<String> coresPreset = ['#F2A65A', '#F2C94C', '#63C99A', '#5AB4EC', '#B47EE5', '#F45781', '#E6E9ED', '#8779A8'];

/// `hexValido(v)`: aceita com ou sem "#", 3 ou 6 dígitos; devolve com "#" ou null.
String? hexValido(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  var s = v.trim();
  if (s[0] != '#') s = '#$s';
  return RegExp(r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(s) ? s : null;
}

class Tarefa {
  final Map<String, dynamic> dados;
  Tarefa(this.dados);

  factory Tarefa.deJson(Map<String, dynamic> json) => Tarefa(Map<String, dynamic>.from(json));

  String? get texto => dados['texto'] is String ? dados['texto'] as String : null;
  String? get tipo => dados['tipo'] is String ? dados['tipo'] as String : null;
  String? get feitaEm => dados['feitaEm'] is String ? dados['feitaEm'] as String : null;
  String get dif => difDe(dados['dif']);

  /// `corBox`: cor escolhida para a tarefa (hex "#RRGGBB"); null quando não há ou não é válida.
  String? get corBox => hexValido(dados['corBox'] is String ? dados['corBox'] as String : null);

  /// Vezes por dia (`meta`); 1 quando ausente ou menor que 2.
  int get meta {
    final m = dados['meta'];
    return (m is num && m > 1) ? m.round() : 1;
  }

  Map<String, dynamic> paraJson() => dados;
}
