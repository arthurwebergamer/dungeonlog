// Efeitos sonoros do jogo (os mesmos do original: tocarSom() em play/index.html, receitas em tools/gerar_sons.mjs).
// `Som.atual` começa mudo (testes); o app troca por [SomAudio] ao abrir. Preferência salva em `questlog.sfx.v1`
// ({ativo, volume}, padrão ligado a 0,55), a mesma chave do original.
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';

import '../dados/armazenamento.dart';

abstract class Som {
  static Som atual = SomMudo();

  /// Toca o efeito [nome]. [progresso] (0 a 1) só vale para `roletaTick`.
  void tocar(String nome, {double progresso = 0});
}

class SomMudo implements Som {
  @override
  void tocar(String nome, {double progresso = 0}) {}
}

class SomAudio implements Som {
  SomAudio(Armazenamento arm) {
    try {
      final s = arm.ler('questlog.sfx.v1');
      final j = s == null ? null : jsonDecode(s);
      if (j is Map) {
        if (j['ativo'] is bool) ativo = j['ativo'] as bool;
        if (j['volume'] is num) volume = (j['volume'] as num).toDouble().clamp(0.0, 1.0);
      }
    } catch (_) {}
    _precarregar();
  }

  bool ativo = true;
  double volume = 0.55;

  /// Efeitos usados o tempo todo: ficam carregados em 2 tocadores cada (para sons seguidos se sobreporem).
  static const _quentes = [
    'golpe', 'tarefa', 'levelup', 'loot', 'equipar', 'desequipar', 'usar', 'venda', 'compra', 'semMoedas',
    'danoHeroi', 'poofBau', 'bauTrancado', 'roletaTick0', 'roletaTick1', 'roletaTick2', 'roletaTick3', 'roletaTick4', 'roletaTick5',
  ];
  final Map<String, List<AudioPlayer>> _pool = {};
  final Map<String, int> _vez = {};
  final Set<AudioPlayer> _vivos = {};

  Future<void> _precarregar() async {
    for (final nome in _quentes) {
      try {
        final lista = <AudioPlayer>[];
        for (var i = 0; i < 2; i++) {
          final p = AudioPlayer();
          await p.setReleaseMode(ReleaseMode.stop);
          await p.setSource(AssetSource('sons/$nome.wav'));
          lista.add(p);
        }
        _pool[nome] = lista;
      } catch (_) {}
    }
  }

  @override
  void tocar(String nome, {double progresso = 0}) {
    if (!ativo || volume <= 0) return;
    if (nome == 'clique' || nome == 'soltar') return; // sem som de toque (como no original)
    final arquivo = nome == 'roletaTick' ? 'roletaTick${(progresso.clamp(0.0, 1.0) * 5).round()}' : nome;
    try {
      final lista = _pool[arquivo];
      if (lista != null && lista.isNotEmpty) {
        final k = (_vez[arquivo] ?? 0) % lista.length;
        _vez[arquivo] = k + 1;
        final p = lista[k];
        p.setVolume(volume);
        p.seek(Duration.zero).then((_) => p.resume()).catchError((Object _) {});
        return;
      }
      // efeito raro (ainda não carregado): tocador próprio, descartado no fim
      final j = AudioPlayer();
      _vivos.add(j);
      void soltar() {
        if (_vivos.remove(j)) j.dispose();
      }

      j.onPlayerComplete.first.then((_) => soltar()).catchError((Object _) {});
      Future<void>.delayed(const Duration(seconds: 4), soltar);
      j.play(AssetSource('sons/$arquivo.wav'), volume: volume).catchError((Object _) => soltar());
    } catch (_) {}
  }
}
