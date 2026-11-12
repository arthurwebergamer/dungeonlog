// Efeitos sonoros do jogo (os mesmos do original: tocarSom() em play/index.html, receitas em tools/gerar_sons.mjs).
// `Som.atual` começa mudo (testes); o app troca por [SomAudio] ao abrir. Preferência salva em `questlog.sfx.v1`
// ({ativo, volume}, padrão ligado a 0,55), a mesma chave do original.
//
// Como o som sai sempre e sem atraso: cada efeito usa um tocador USADO UMA SÓ VEZ (reaproveitar um tocador depois de
// tocar fazia o som sumir na segunda vez), e para os efeitos frequentes já ficam 2 tocadores com o arquivo carregado
// esperando; ao usar um, o app prepara outro no lugar. Se os preparados acabarem (toques muito rápidos), cria um na hora.
import 'dart:async';
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

/// Um tocador de um único uso. A implementação real usa o `audioplayers`; os testes usam uma falsa.
abstract class TocadorSom {
  /// Carrega o arquivo para tocar depois (sem tocar).
  Future<void> preparar(String arquivo, double volume);

  /// Toca o que foi preparado.
  Future<void> tocar();

  /// Carrega e toca de uma vez (quando não havia nenhum preparado).
  Future<void> tocarDireto(String arquivo, double volume);

  /// Completa quando o som termina.
  Future<void> get terminou;

  Future<void> descartar();
}

class _TocadorReal implements TocadorSom {
  final AudioPlayer _p = AudioPlayer();

  @override
  Future<void> preparar(String arquivo, double volume) async {
    await _p.setReleaseMode(ReleaseMode.stop);
    await _p.setVolume(volume);
    await _p.setSource(AssetSource('sons/$arquivo.wav'));
  }

  @override
  Future<void> tocar() => _p.resume();

  @override
  Future<void> tocarDireto(String arquivo, double volume) => _p.play(AssetSource('sons/$arquivo.wav'), volume: volume);

  @override
  Future<void> get terminou => _p.onPlayerComplete.first;

  @override
  Future<void> descartar() => _p.dispose();
}

class SomAudio implements Som {
  SomAudio(Armazenamento arm, {TocadorSom Function()? fabrica}) : _fabrica = fabrica ?? _TocadorReal.new {
    try {
      final s = arm.ler('questlog.sfx.v1');
      final j = s == null ? null : jsonDecode(s);
      if (j is Map) {
        if (j['ativo'] is bool) ativo = j['ativo'] as bool;
        if (j['volume'] is num) volume = (j['volume'] as num).toDouble().clamp(0.0, 1.0);
      }
    } catch (_) {}
    for (final nome in quentes) {
      _reabastecer(nome);
    }
  }

  final TocadorSom Function() _fabrica;
  bool ativo = true;
  double volume = 0.55;

  /// Efeitos frequentes (os que o jogador ouve a cada toque): ficam com tocadores prontos.
  static const quentes = ['golpe', 'tarefa', 'levelup', 'loot', 'equipar', 'usar', 'venda', 'compra', 'semMoedas', 'danoHeroi'];
  static const _prontosPorEfeito = 2;

  final Map<String, List<TocadorSom>> _prontos = {};
  final Map<String, int> _preparando = {};

  /// Mantém [_prontosPorEfeito] tocadores carregados esperando o efeito [nome].
  void _reabastecer(String nome) {
    final lista = _prontos.putIfAbsent(nome, () => []);
    final emPreparo = _preparando[nome] ?? 0;
    final faltam = _prontosPorEfeito - lista.length - emPreparo;
    for (var i = 0; i < faltam; i++) {
      _preparando[nome] = (_preparando[nome] ?? 0) + 1;
      () async {
        final t = _fabrica();
        try {
          await t.preparar(nome, volume);
          lista.add(t);
        } catch (_) {
          unawaited(t.descartar().catchError((Object _) {}));
        } finally {
          _preparando[nome] = (_preparando[nome] ?? 1) - 1;
        }
      }();
    }
  }

  void _soltarDepois(TocadorSom t) {
    var feito = false;
    void soltar() {
      if (feito) return;
      feito = true;
      t.descartar().catchError((Object _) {});
    }

    t.terminou.then((_) => soltar()).catchError((Object _) {});
    Future<void>.delayed(const Duration(seconds: 5), soltar); // rede de segurança
  }

  @override
  void tocar(String nome, {double progresso = 0}) {
    if (!ativo || volume <= 0) return;
    if (nome == 'clique' || nome == 'soltar') return; // sem som de toque (como no original)
    final arquivo = nome == 'roletaTick' ? 'roletaTick${(progresso.clamp(0.0, 1.0) * 5).round()}' : nome;
    try {
      final lista = _prontos[arquivo];
      if (lista != null && lista.isNotEmpty) {
        final t = lista.removeAt(0);
        _soltarDepois(t);
        t.tocar().catchError((Object _) {});
        _reabastecer(arquivo); // já deixa outro pronto para o próximo toque
        return;
      }
      // nenhum pronto (efeito raro ou toques muito rápidos): tocador novo na hora
      final t = _fabrica();
      _soltarDepois(t);
      t.tocarDireto(arquivo, volume).catchError((Object _) {});
      if (quentes.contains(arquivo)) _reabastecer(arquivo);
    } catch (_) {}
  }
}
