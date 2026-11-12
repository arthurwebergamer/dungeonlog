// Tabelas do equipamento desenhado no herói da arena e dos ícones de arma escura, extraídas de play/index.html
// (window.EQ_BB, ARMA_GRIP, ARMA_AJUSTE, ARMA_ESCURA) para assets/dados/equip_arena.json por tools/extrair_assets.mjs.
import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter/widgets.dart';

class EquipArena {
  EquipArena({required this.eqBB, required this.armaGrip, required this.armaAjuste, required this.armaEscura, required this.spritesEscuros, required this.cadeado});

  /// Retângulo real do desenho de cada peça na célula 32x32: `[x0, y0, x1, y1]`, por id do item.
  final Map<int, List<double>> eqBB;

  /// Ponto do cabo de cada arma corpo a corpo na célula 32x32: `[gx, gy]`, por id do item.
  final Map<int, List<double>> armaGrip;

  /// Ajuste fino `[dx, dy]` (px da arena) depois da medição automática.
  final Map<int, List<double>> armaAjuste;

  /// Ids das armas de cor escura (clareadas na mão do herói).
  final Set<int> armaEscura;

  /// Índices na folha de sprites dessas armas (clareadas nos ícones).
  final Set<int> spritesEscuros;

  /// Cadeado do baú trancado: retângulos `[x, y, largura, altura, cor]` numa grade 12x14.
  final List<(Rect, Color)> cadeado;

  factory EquipArena.vazio() => EquipArena(eqBB: {}, armaGrip: {}, armaAjuste: {}, armaEscura: {}, spritesEscuros: {}, cadeado: []);

  factory EquipArena.deTexto(String texto) {
    final j = jsonDecode(texto) as Map<String, dynamic>;
    Map<int, List<double>> tabela(String k) => {
          for (final e in ((j[k] as Map?) ?? const {}).entries) int.parse(e.key as String): [for (final v in e.value as List) (v as num).toDouble()],
        };
    Set<int> conjunto(String k) => {for (final v in (j[k] as List?) ?? const []) (v as num).toInt()};
    final cad = <(Rect, Color)>[];
    final c = j['cadeado'];
    if (c is Map && c['rects'] is List) {
      for (final r in c['rects'] as List) {
        final l = r as List;
        final hex = (l[4] as String).replaceFirst('#', '');
        cad.add((
          Rect.fromLTWH((l[0] as num).toDouble(), (l[1] as num).toDouble(), (l[2] as num).toDouble(), (l[3] as num).toDouble()),
          Color(0xFF000000 | int.parse(hex, radix: 16)),
        ));
      }
    }
    return EquipArena(
      eqBB: tabela('eqBB'),
      armaGrip: tabela('armaGrip'),
      armaAjuste: tabela('armaAjuste'),
      armaEscura: conjunto('armaEscura'),
      spritesEscuros: conjunto('spritesEscuros'),
      cadeado: cad,
    );
  }

  /// Tabelas em uso (vazias até [carregar] terminar; o app carrega antes de abrir a primeira tela).
  static EquipArena atual = EquipArena.vazio();

  static Future<void> carregar([AssetBundle? bundle]) async {
    atual = EquipArena.deTexto(await (bundle ?? rootBundle).loadString('assets/dados/equip_arena.json'));
  }
}
