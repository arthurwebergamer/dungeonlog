// Tema e cores do app. O tema padrão é o "grafite" do app original (play/style.css, :root[data-tema="grafite"]); os outros
// (branco, laranja, dourado, esmeralda, terracota) vêm de :root[data-tema=...] do mesmo CSS. A paleta em uso é global e
// mutável: `Paleta.atual = ...` e a raiz do app se reconstrói (ver `reconstruirTudo`).
// Os valores do grafite foram lidos do CSS computado do original em 390x844.
import 'package:flutter/material.dart';

/// Uma paleta: as variáveis de cor de `TEMA_VARS` do original que o app usa.
class Paleta {
  const Paleta({
    required this.id,
    required this.nome,
    required this.nomeEn,
    required this.pro,
    required this.bolinha,
    required this.bg,
    required this.panel,
    required this.panel2,
    required this.panel3,
    required this.line,
    required this.text,
    required this.muted,
    required this.dim,
    required this.accent,
    required this.selBg,
    required this.gold,
    required this.poco,
    required this.claro,
  });
  final String id;
  final String nome;
  final String nomeEn;
  final bool pro;

  /// Cor da bolinha na lista de Aparência.
  final Color bolinha;
  final Color bg, panel, panel2, panel3, line, text, muted, dim, accent, selBg, gold, poco;

  /// Tema claro (branco): inverte o brilho do sistema.
  final bool claro;

  static const grafite = Paleta(
    id: 'grafite', nome: 'Escuro', nomeEn: 'Dark', pro: false, bolinha: Color(0xFF8E8E96),
    bg: Color(0xFF282828), panel: Color(0xFF323232), panel2: Color(0xFF3D3D3D), panel3: Color(0xFF494949),
    line: Color(0xFF5C5C5C), text: Color(0xFFFAFAFA), muted: Color(0xFFC2C2C2), dim: Color(0xFF909090),
    accent: Color(0xFFFFFFFF), selBg: Color(0xFF4A4A4A), gold: Color(0xFFE8E8E8), poco: Color(0xFF1C1C1C), claro: false,
  );
  static const branco = Paleta(
    id: 'branco', nome: 'Branco', nomeEn: 'White', pro: false, bolinha: Color(0xFFFFFFFF),
    bg: Color(0xFFD2D0CB), panel: Color(0xFFDBD9D4), panel2: Color(0xFFCECCC7), panel3: Color(0xFFC2BFB8),
    line: Color(0xFFB6B3AC), text: Color(0xFF2E2C29), muted: Color(0xFF5A564F), dim: Color(0xFF7F7B73),
    accent: Color(0xFF2E2C29), selBg: Color(0xFFC2BFB8), gold: Color(0xFF5C5650), poco: Color(0xFFE9E7E3), claro: true,
  );
  static const laranja = Paleta(
    id: 'padrao', nome: 'Laranja', nomeEn: 'Orange', pro: false, bolinha: Color(0xFFF2A65A),
    bg: Color(0xFF1A1526), panel: Color(0xFF1A1526), panel2: Color(0xFF251E38), panel3: Color(0xFF2A2240),
    line: Color(0xFF3B3057), text: Color(0xFFF5F0E9), muted: Color(0xFFB9AED2), dim: Color(0xFF8779A8),
    accent: Color(0xFFF2A65A), selBg: Color(0xFF342A50), gold: Color(0xFFF2C94C), poco: Color(0xFF1F1930), claro: false,
  );
  static const dourado = Paleta(
    id: 'pergaminho', nome: 'Dourado', nomeEn: 'Gold', pro: false, bolinha: Color(0xFFC9A961),
    bg: Color(0xFF0F1216), panel: Color(0xFF0F1216), panel2: Color(0xFF151A20), panel3: Color(0xFF1D2318),
    line: Color(0xFF232A33), text: Color(0xFFE6E9ED), muted: Color(0xFF8A93A0), dim: Color(0xFF5A6470),
    accent: Color(0xFFC9A961), selBg: Color(0xFF242A1B), gold: Color(0xFFC9A961), poco: Color(0xFF0A0C0F), claro: false,
  );
  static const esmeralda = Paleta(
    id: 'esmeralda', nome: 'Esmeralda', nomeEn: 'Emerald', pro: true, bolinha: Color(0xFF22C55E),
    bg: Color(0xFF12161A), panel: Color(0xFF12161A), panel2: Color(0xFF1A2025), panel3: Color(0xFF232A30),
    line: Color(0xFF37414A), text: Color(0xFFEAF1EE), muted: Color(0xFF9DB0A8), dim: Color(0xFF66766E),
    accent: Color(0xFF22C55E), selBg: Color(0xFF1D3327), gold: Color(0xFFD9C15C), poco: Color(0xFF0B0D0F), claro: false,
  );
  static const terracota = Paleta(
    id: 'terracota', nome: 'Terracota', nomeEn: 'Terracotta', pro: true, bolinha: Color(0xFFC96A4A),
    bg: Color(0xFF10161C), panel: Color(0xFF10161C), panel2: Color(0xFF18212A), panel3: Color(0xFF212C37),
    line: Color(0xFF354655), text: Color(0xFFEDEEEF), muted: Color(0xFF9DACB9), dim: Color(0xFF647686),
    accent: Color(0xFFC96A4A), selBg: Color(0xFF3D2318), gold: Color(0xFFD9A45C), poco: Color(0xFF0B1116), claro: false,
  );

  /// Na ordem da lista de Aparência.
  static const todas = [branco, grafite, laranja, dourado, esmeralda, terracota];

  /// A paleta em uso.
  static Paleta atual = grafite;

  static Paleta? porId(String? id) {
    for (final p in todas) {
      if (p.id == id) return p;
    }
    return null;
  }
}

Color get corFundo => Paleta.atual.bg; // --bg
Color get corPainel => Paleta.atual.panel; // --panel (campos, barra de navegação)
Color get corPainel2 => Paleta.atual.panel2; // --panel-2 (cartão de vida/XP, folhas)
Color get corPainel3 => Paleta.atual.panel3; // --panel-3 (cartão de tarefa)
Color get corLinha => Paleta.atual.line; // --line
Color get corTexto => Paleta.atual.text; // --text
Color get corSuave => Paleta.atual.muted; // --muted
Color get corApagado => Paleta.atual.dim; // --dim
Color get corOuro => Paleta.atual.gold; // --gold (no grafite é cinza claro)
Color get corAtivo => Paleta.atual.selBg; // botão/pílula selecionada (--sel-bg)

/// --accent: destaque do tema (branco no grafite). Botões primários, interruptor ligado, aba ativa.
Color get corAccent => Paleta.atual.accent;

/// Texto sobre o accent (escuro nos temas escuros, claro no branco).
Color get corSobreAccent => Paleta.atual.claro ? const Color(0xFFD2D0CB) : Paleta.atual.bg;

/// Avisa a raiz do app que a paleta mudou (ela reconstrói tudo; ver `DungeonlogApp`).
final ValueNotifier<int> temaMudou = ValueNotifier<int>(0);

/// Efeito CRT ligado (a raiz desenha as linhas de varredura por cima de tudo).
final ValueNotifier<bool> crtAtivo = ValueNotifier<bool>(false);

const corVida = Color(0xFFF45781); // vida e --perigo (não muda com o tema)
const corVerde = Color(0xFF63C99A); // --verde
const corXpA = Color(0xFFF2A65A); // barra de XP: laranja ->
const corXpB = Color(0xFFF2C94C); // -> amarelo
const corFaixaVitoria = Color(0xFFFFD65A);
const corDescanso = Color(0xFF3A3F55); // botão da lua
const corDescansoTexto = Color(0xFFCDD6FF);
const corDescansoAtivo = Color(0xFF4D5A8F);
const corVeu = Color(0xAD0A0712); // fundo atrás das folhas: rgba(10,7,18,.68)

// nomes antigos, ainda usados em alguns pontos
Color get corCard => corPainel2;
Color get corDestaque => Colors.white;
Color get corTexto2 => corApagado;

const fontePixel = 'Silkscreen';

/// Algarismos de largura fixa (`font-variant-numeric: tabular-nums` dos contadores do original).
const algarismosFixos = [FontFeature.tabularFigures()];

ThemeData temaApp() => ThemeData(
      brightness: Paleta.atual.claro ? Brightness.light : Brightness.dark,
      fontFamily: 'Outfit',
      scaffoldBackgroundColor: corFundo,
      colorScheme: Paleta.atual.claro
          ? ColorScheme.light(primary: corAccent, surface: corPainel2, onSurface: corTexto)
          : ColorScheme.dark(primary: corAccent, surface: corPainel2, onSurface: corTexto),
      useMaterial3: true,
      // o Material 3 põe espaçamento entre letras e altura de linha próprios no texto padrão; o original usa a Outfit "crua"
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 16, letterSpacing: 0, height: 1.26, color: corTexto),
        bodyLarge: TextStyle(fontSize: 16, letterSpacing: 0, height: 1.26, color: corTexto),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(cursorColor: corAccent, selectionColor: const Color(0x55FFFFFF), selectionHandleColor: corAccent),
    );

/// Reconstrói todos os widgets embaixo de [context] (a paleta é global: depois de `Paleta.atual = ...` tudo relê as cores).
/// Mantém o estado dos widgets (rolagem, telas abertas); só refaz o desenho.
void reconstruirTudo(BuildContext context) {
  void refaz(Element el) {
    el.markNeedsBuild();
    el.visitChildren(refaz);
  }

  (context as Element).visitChildren(refaz);
}

/// Cor do losango de dificuldade (1 a 4): trivial, fácil, média, difícil.
Color corDificuldade(int pips) => [const Color(0xFF7E8BA3), corVerde, const Color(0xFFF2C94C), corVida][(pips - 1).clamp(0, 3)];

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
