// Ícone SVG do original (extraído de play/index.html para svg_dados.dart), pintado com a cor dada em `currentColor`.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'svg_dados.dart';

class IconeSvg extends StatelessWidget {
  const IconeSvg(this.nome, {super.key, this.tamanho = 22, required this.cor});
  final String nome;
  final double tamanho;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final svg = svgDados[nome];
    if (svg == null) return SizedBox.square(dimension: tamanho);
    return SvgPicture.string(
      svg,
      width: tamanho,
      height: tamanho,
      theme: SvgTheme(currentColor: cor),
      colorMapper: null,
    );
  }
}
