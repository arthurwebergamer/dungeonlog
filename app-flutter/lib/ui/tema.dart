// Tema e cores do app (reaproveitado do protótipo de fluidez).
import 'package:flutter/material.dart';

const corFundo = Color(0xFF1A1526);
const corCard = Color(0xFF241D35);
const corDestaque = Color(0xFFE5A05C);
const corVida = Color(0xFFE5575F);
const corXp = Color(0xFF5AB4EC);
const corOuro = Color(0xFFF2C94C);
const corTexto2 = Colors.white54;

ThemeData temaApp() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: corFundo,
      colorScheme: const ColorScheme.dark(primary: corDestaque, surface: corCard),
      useMaterial3: true,
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF13101C),
        indicatorColor: Color(0x33E5A05C),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
      ),
    );

/// Cor do losango de dificuldade (1 a 4).
Color corDificuldade(int pips) => const [Color(0xFF8FA3B8), Color(0xFF63C99A), Color(0xFFF2C94C), Color(0xFFF45781)][(pips - 1).clamp(0, 3)];
