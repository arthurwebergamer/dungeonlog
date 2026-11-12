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
  }

  bool ativo = true;
  double volume = 0.55;
  final Set<AudioPlayer> _vivos = {};

  @override
  void tocar(String nome, {double progresso = 0}) {
    if (!ativo || volume <= 0) return;
    if (nome == 'clique' || nome == 'soltar') return; // sem som de toque (como no original)
    final arquivo = nome == 'roletaTick' ? 'roletaTick${(progresso.clamp(0.0, 1.0) * 5).round()}' : nome;
    try {
      // um tocador novo a cada efeito: reaproveitar o mesmo depois de `stop()` fazia o som sair só na primeira vez
      final j = AudioPlayer();
      _vivos.add(j);
      void soltar() {
        if (_vivos.remove(j)) j.dispose();
      }

      j.onPlayerComplete.first.then((_) => soltar()).catchError((Object _) {});
      Future<void>.delayed(const Duration(seconds: 4), soltar); // rede de segurança se o fim não vier
      j.setReleaseMode(ReleaseMode.release);
      j.play(AssetSource('sons/$arquivo.wav'), volume: volume).catchError((Object _) => soltar());
    } catch (_) {}
  }
}
