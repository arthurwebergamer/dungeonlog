// Armazenamento chave/valor de texto, o equivalente do localStorage do app atual (mesmas chaves e mesmo JSON).
import 'package:shared_preferences/shared_preferences.dart';

abstract class Armazenamento {
  String? ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> remover(String chave);
}

/// Em memória (testes).
class ArmazenamentoMemoria implements Armazenamento {
  final Map<String, String> dados = {};
  @override
  String? ler(String chave) => dados[chave];
  @override
  Future<void> gravar(String chave, String valor) async => dados[chave] = valor;
  @override
  Future<void> remover(String chave) async => dados.remove(chave);
}

/// No aparelho (SharedPreferences). Carrega tudo na abertura, então a leitura é síncrona.
class ArmazenamentoLocal implements Armazenamento {
  final SharedPreferences _p;
  ArmazenamentoLocal._(this._p);
  static Future<ArmazenamentoLocal> abrir() async => ArmazenamentoLocal._(await SharedPreferences.getInstance());

  @override
  String? ler(String chave) => _p.getString(chave);
  @override
  Future<void> gravar(String chave, String valor) async => _p.setString(chave, valor);
  @override
  Future<void> remover(String chave) async => _p.remove(chave);
}
