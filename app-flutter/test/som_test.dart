// O som tem que sair TODA vez, inclusive em toques rápidos e depois de muitos usos (bug: saía só na primeira).
import 'dart:async';

import 'package:dungeonlog_flutter/dados/armazenamento.dart';
import 'package:dungeonlog_flutter/ui/som.dart';
import 'package:flutter_test/flutter_test.dart';

class _Falso implements TocadorSom {
  _Falso(this.registro);
  final List<_Falso> registro;
  String? arquivo;
  int vezesTocado = 0;
  bool descartado = false;
  final _fim = Completer<void>();

  @override
  Future<void> preparar(String a, double volume) async {
    await Future<void>.delayed(const Duration(milliseconds: 20)); // carregar leva um tempinho
    arquivo = a;
  }

  @override
  Future<void> tocar() async {
    if (arquivo == null) throw StateError('tocar() sem preparar');
    if (descartado) throw StateError('tocador já descartado');
    vezesTocado++;
    Timer(const Duration(milliseconds: 100), () {
      if (!_fim.isCompleted) _fim.complete();
    });
  }

  @override
  Future<void> tocarDireto(String a, double volume) async {
    arquivo = a;
    await tocar();
  }

  @override
  Future<void> get terminou => _fim.future;

  @override
  Future<void> descartar() async => descartado = true;
}

void main() {
  test('todo toque produz som: 60 efeitos seguidos, devagar e em rajada, sem reaproveitar tocador', () async {
    final criados = <_Falso>[];
    final som = SomAudio(ArmazenamentoMemoria(), fabrica: () {
      final t = _Falso(criados);
      criados.add(t);
      return t;
    });
    await Future<void>.delayed(const Duration(milliseconds: 200)); // pré-carregamento inicial
    expect(criados.where((t) => t.arquivo != null).length, greaterThanOrEqualTo(SomAudio.quentes.length));

    // devagar: um golpe a cada 150 ms
    for (var i = 0; i < 20; i++) {
      som.tocar('golpe');
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    // rajada: 20 toques sem esperar
    for (var i = 0; i < 20; i++) {
      som.tocar('golpe');
    }
    // efeito raro e de outro tipo
    for (var i = 0; i < 10; i++) {
      som.tocar('estagioNovo');
      som.tocar('semMoedas');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final golpes = criados.where((t) => t.arquivo == 'golpe' && t.vezesTocado > 0).toList();
    expect(golpes.fold<int>(0, (a, t) => a + t.vezesTocado), 40, reason: 'cada um dos 40 toques de golpe saiu');
    expect(golpes.every((t) => t.vezesTocado == 1), isTrue, reason: 'nenhum tocador é usado duas vezes');
    expect(criados.where((t) => t.arquivo == 'estagioNovo' && t.vezesTocado == 1).length, 10);
    expect(criados.where((t) => t.arquivo == 'semMoedas' && t.vezesTocado == 1).length, 10);
    expect(criados.where((t) => t.vezesTocado > 1), isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 5500)); // a rede de segurança solta o que sobrou
    expect(criados.where((t) => t.vezesTocado > 0 && !t.descartado), isEmpty, reason: 'tocadores usados são descartados');
    // depois de tudo isso, ainda sai som (os "prontos" foram repostos)
    som.tocar('golpe');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(criados.where((t) => t.arquivo == 'golpe' && t.vezesTocado == 1).length, 41);
  });

  test('mudo ou volume zero não toca; clique e soltar não tocam (como no original)', () async {
    final criados = <_Falso>[];
    final som = SomAudio(ArmazenamentoMemoria(), fabrica: () {
      final t = _Falso(criados);
      criados.add(t);
      return t;
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    som.tocar('clique');
    som.tocar('soltar');
    som.ativo = false;
    som.tocar('golpe');
    som.ativo = true;
    som.volume = 0;
    som.tocar('golpe');
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(criados.where((t) => t.vezesTocado > 0), isEmpty);
  });
}
