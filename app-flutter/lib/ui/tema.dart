// Tema e cores do app: tema padrão "grafite" do app original (play/style.css, :root[data-tema="grafite"]).
// Os valores foram lidos do CSS computado do original em 390x844.
import 'package:flutter/material.dart';

const corFundo = Color(0xFF282828); // --bg
const corPainel = Color(0xFF323232); // --panel (campos, barra de navegação)
const corPainel2 = Color(0xFF3D3D3D); // --panel-2 (cartão de vida/XP, folhas)
const corPainel3 = Color(0xFF494949); // --panel-3 (cartão de tarefa)
const corLinha = Color(0xFF5C5C5C); // --line
const corTexto = Color(0xFFFAFAFA); // --text
const corSuave = Color(0xFFC2C2C2); // --muted
const corApagado = Color(0xFF909090); // --dim
const corOuro = Color(0xFFE8E8E8); // --gold (no grafite é cinza claro)
const corAtivo = Color(0xFF4A4A4A); // botão/pílula selecionada
const corVida = Color(0xFFF45781); // vida e --perigo
const corVerde = Color(0xFF63C99A); // --verde
const corXpA = Color(0xFFF2A65A); // barra de XP: laranja ->
const corXpB = Color(0xFFF2C94C); // -> amarelo
const corFaixaVitoria = Color(0xFFFFD65A);
const corDescanso = Color(0xFF3A3F55); // botão da lua
const corDescansoTexto = Color(0xFFCDD6FF);
const corDescansoAtivo = Color(0xFF4D5A8F);
const corVeu = Color(0xAD0A0712); // fundo atrás das folhas: rgba(10,7,18,.68)

// nomes antigos, ainda usados em alguns pontos
const corCard = corPainel2;
const corDestaque = Colors.white;
const corTexto2 = corApagado;

const fontePixel = 'Silkscreen';

/// Algarismos de largura fixa (`font-variant-numeric: tabular-nums` dos contadores do original).
const algarismosFixos = [FontFeature.tabularFigures()];

ThemeData temaApp() => ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Outfit',
      scaffoldBackgroundColor: corFundo,
      colorScheme: const ColorScheme.dark(primary: Colors.white, surface: corPainel2, onSurface: corTexto),
      useMaterial3: true,
      // o Material 3 põe espaçamento entre letras e altura de linha próprios no texto padrão; o original usa a Outfit "crua"
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, letterSpacing: 0, height: 1.26, color: corTexto),
        bodyLarge: TextStyle(fontSize: 16, letterSpacing: 0, height: 1.26, color: corTexto),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white, selectionColor: Color(0x55FFFFFF), selectionHandleColor: Colors.white),
    );

/// Cor do losango de dificuldade (1 a 4): trivial, fácil, média, difícil.
Color corDificuldade(int pips) => const [Color(0xFF7E8BA3), corVerde, Color(0xFFF2C94C), corVida][(pips - 1).clamp(0, 3)];

/// Numeral romano do nível (`romano()` do app original).
String romano(int n) {
  if (n < 1) return 'I';
  const t = [(1000, 'M'), (900, 'CM'), (500, 'D'), (400, 'CD'), (100, 'C'), (90, 'XC'), (50, 'L'), (40, 'XL'), (10, 'X'), (9, 'IX'), (5, 'V'), (4, 'IV'), (1, 'I')];
  final s = StringBuffer();
  for (final (v, letra) in t) {
    while (n >= v) {
      s.write(letra);
      n -= v;
    }
  }
  return s.toString();
}
