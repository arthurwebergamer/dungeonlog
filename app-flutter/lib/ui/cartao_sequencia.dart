// Cartão de compartilhar a sequência (`gerarCardCompartilhamento` do original): imagem 9:16 de 810x1440 com o fundo do app,
// um brilho atrás da tocha, "DUNGEONLOG", o nome do herói, a tocha (maior quanto maior a sequência) e o número de dias.
//
// No original isso é um <canvas>; aqui é desenhado direto num `Canvas` fora da tela (PictureRecorder), sem montar widgets,
// exportado em PNG e entregue ao compartilhamento do sistema (`share_plus`, arquivo `dungeonlog-sequencia.png`).
// Usa as cores do tema ativo no momento, como o original (que lê as variáveis CSS).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../dominio/estatisticas.dart';
import 'tema.dart';
import 'tocha_est.dart';

const double cartaoLargura = 810, cartaoAltura = 1440;

/// A cor do número, igual à do app (`corDoStreakCanvas`): mistura as variáveis do tema.
Color corDoNumeroSequencia(int streak) {
  final m = corDoStreak(streak);
  if (m == null) return corApagado;
  Color v(String n) => switch (n) {
        'accent' => corAccent,
        'gold' => corOuro,
        _ => corTexto,
      };
  if (m.de == 'gold') return corOuro;
  return Color.lerp(v(m.de), v(m.para), m.pct / 100)!;
}

/// Quadro do sprite da tocha (o 2º, parado), como `drawImage(img, 16, 0, 16, 32, ...)` do original.
Future<ui.Image> carregarTocha() async {
  final dados = await rootBundle.load(folhaTochaEst);
  final codec = await ui.instantiateImageCodec(dados.buffer.asUint8List());
  return (await codec.getNextFrame()).image;
}

void _texto(
  Canvas canvas,
  String texto,
  double xCentro,
  double yBase, {
  required String familia,
  required double tamanho,
  required Color cor,
  FontWeight peso = FontWeight.w400,
  double espaco = 0,
}) {
  final tp = TextPainter(
    text: TextSpan(text: texto, style: TextStyle(fontFamily: familia, fontSize: tamanho, fontWeight: peso, color: cor, letterSpacing: espaco, height: 1)),
    textDirection: TextDirection.ltr,
  )..layout();
  // fillText(texto, x, y) com textAlign center: x é o meio e y a linha de base
  tp.paint(canvas, Offset(xCentro - tp.width / 2, yBase - tp.computeDistanceToActualBaseline(TextBaseline.alphabetic)));
}

/// Desenha o cartão. [nome] já normalizado (`nomeHeroiNorm`); [tocha] vem de [carregarTocha].
ui.Picture desenharCartaoSequencia({required int streak, required String nome, required String idioma, required ui.Image tocha}) {
  const w = cartaoLargura, h = cartaoAltura;
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec, const Rect.fromLTWH(0, 0, w, h));

  // fundo plano do app e o brilho do accent atrás da tocha
  canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = corFundo);
  const glowX = w / 2, glowY = h * 0.40, glowR = 340.0;
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, w, h),
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(glowX, glowY),
        glowR,
        [corAccent.withValues(alpha: 0.32), const Color(0x00000000)],
      ),
  );

  // marca (só texto, fonte pixel) e o nome do herói
  _texto(canvas, 'DUNGEONLOG', w / 2, 90, familia: fontePixel, tamanho: 28, cor: corApagado, espaco: 10);
  _texto(canvas, nome, w / 2, 175, familia: 'Outfit', tamanho: 48, cor: corTexto, peso: FontWeight.w600);

  // tocha: só o 2º quadro, ampliada sem suavização e centrada no brilho
  final escala = escalaTochaCompartilhar(streak);
  final tw = 16 * 4 * escala, th = 32 * 4 * escala;
  final destino = Rect.fromLTWH(w / 2 - tw / 2, glowY - th * 0.5, tw, th);
  final pincel = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;
  if (streak == 0) pincel.colorFilter = filtroTochaApagada; // grayscale(1) brightness(.55)
  canvas.drawImageRect(tocha, const Rect.fromLTWH(16, 0, 16, 32), destino, pincel);

  // número e legenda
  _texto(canvas, '$streak', w / 2, h * 0.82, familia: fontePixel, tamanho: 130, cor: corDoNumeroSequencia(streak), peso: FontWeight.w700);
  final en = idioma == 'en';
  final lbl = streak == 1 ? (en ? 'day in a row' : 'dia seguido') : (en ? 'days in a row' : 'dias seguidos');
  _texto(canvas, '$streak $lbl', w / 2, h * 0.82 + 46, familia: 'Outfit', tamanho: 30, cor: corSuave);
  return rec.endRecording();
}

/// O PNG do cartão (810x1440).
Future<Uint8List> gerarPngCartaoSequencia({required int streak, required String nome, required String idioma}) async {
  final tocha = await carregarTocha();
  final img = await desenharCartaoSequencia(streak: streak, nome: nome, idioma: idioma, tocha: tocha).toImage(cartaoLargura.toInt(), cartaoAltura.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  tocha.dispose();
  return bytes!.buffer.asUint8List();
}

/// "Compartilhar": gera o cartão e abre a folha de compartilhamento do sistema com a imagem e o texto do original.
/// Devolve false se o compartilhamento falhou (para a tela avisar); cancelar a folha não é erro.
Future<bool> compartilharSequencia({required int streak, required String nome, required String idioma}) async {
  final png = await gerarPngCartaoSequencia(streak: streak, nome: nome, idioma: idioma);
  final texto = idioma == 'en' ? 'Check out my Dungeonlog streak!' : 'Olha minha sequência no Dungeonlog!';
  try {
    await SharePlus.instance.share(ShareParams(
      text: texto,
      files: [XFile.fromData(png, mimeType: 'image/png', name: 'dungeonlog-sequencia.png')],
      fileNameOverrides: const ['dungeonlog-sequencia.png'],
    ));
    return true;
  } catch (_) {
    return false;
  }
}
