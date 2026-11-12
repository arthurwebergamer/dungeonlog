// Carrega os dados do jogo dos assets do app (assets/dados/*.json). Camada de dados: depende do Flutter.
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../dominio/dados_jogo.dart';

Future<DadosJogo> carregarDadosJogo([AssetBundle? bundle]) async {
  final b = bundle ?? rootBundle;
  final r = await Future.wait([
    b.loadString('assets/dados/monstros.json'),
    b.loadString('assets/dados/herois.json'),
    b.loadString('assets/dados/temas_arena.json'),
    b.loadString('assets/dados/itens.json'),
    b.loadString('assets/dados/traducoes.json'),
  ]);
  return DadosJogo.deTextos(monstros: r[0], herois: r[1], temas: r[2], itens: r[3], traducoes: r[4]);
}
