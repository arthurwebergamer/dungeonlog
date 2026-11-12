// Peças visuais dos itens, comuns a Inventário, Loja, Forja e baús: cores de raridade e de encantamento, nomes,
// textos de efeito e o sprite da folha. Valores copiados de play/index.html (COR_RAR, AFIXOS, afxEfeito...) e do
// CSS computado do original no tema grafite.
import 'package:flutter/material.dart';

import '../dominio/catalogo.dart';
import '../dominio/economia.dart';
import '../dominio/regras.dart' show bonusItem;
import 'equip_arena.dart';
import 'estado_jogo.dart';
import 'tema.dart';

const corPoco = Color(0xFF1C1C1C); // --poco (fundo das caixas de ícone)
const corFicha = Color(0xFF251E38); // fundo da ficha do item e da confirmação (.isheet / #confirmSheet)
const corFichaLinha = Color(0xFF3B3257);

/// COR_RAR: cor do texto de raridade.
const corRaridade = [
  Color(0xFF8779A8), Color(0xFF63C99A), Color(0xFF5AA9F2), Color(0xFFF05AB5),
  Color(0xFFB57BE8), Color(0xFFF2A65A), Color(0xFFE5484D), Color(0xFF5AE0D8),
];

/// Borda das células por raridade (.r0 a .r7): a comum é mais apagada que a cor do texto.
const corBordaRaridade = [
  Color(0xFF4A4066), Color(0xFF63C99A), Color(0xFF5AA9F2), Color(0xFFF05AB5),
  Color(0xFFB57BE8), Color(0xFFF2A65A), Color(0xFFE5484D), Color(0xFF5AE0D8),
];

/// Brilho em volta das células lendárias, ancestrais e únicas.
List<BoxShadow>? brilhoRaridade(int r) => switch (r) {
      5 => const [BoxShadow(color: Color(0x4DF2A65A), blurRadius: 10)],
      6 => const [BoxShadow(color: Color(0x61E5484D), blurRadius: 12)],
      7 => const [BoxShadow(color: Color(0x4D5AE0D8), blurRadius: 10)],
      _ => null,
    };

const _nomesRaridadePt = ['Comum', 'Incomum', 'Raro', 'Superior', 'Épico', 'Lendário', 'Ancestral', 'Único'];
const _nomesRaridadeEn = ['Common', 'Uncommon', 'Rare', 'Superior', 'Epic', 'Legendary', 'Ancestral', 'Unique'];
const _nomesRaridadeFem = ['Comum', 'Incomum', 'Rara', 'Superior', 'Épica', 'Lendária', 'Ancestral', 'Única'];
String nomeRaridade(int r, String idioma) => (idioma == 'en' ? _nomesRaridadeEn : _nomesRaridadePt)[r.clamp(0, 7)];
String nomeRaridadeFem(int r) => _nomesRaridadeFem[r.clamp(0, 7)];

const _nomesTipo = {
  'arma': 'Arma', 'armadura': 'Armadura', 'elmo': 'Elmo', 'escudo': 'Escudo', 'acess': 'Acessório',
  'cons': 'Consumível', 'tesouro': 'Tesouro', 'chave': 'Item-chave',
};
String nomeTipo(String tipo) => _nomesTipo[tipo] ?? tipo;

// ---------- encantamentos (afixos) ----------
const _nomesAfixo = {
  'gan': 'Ganancioso', 'est': 'Estudioso', 'sor': 'Sortudo', 'bar': 'Barganhista',
  'bau': 'Caçador de Baús', 'abu': 'Abundante', 'tes': 'Garimpeiro', 'tex': 'Tesoureiro',
};
const _nomesAfixoNeg = {
  'gan': 'Maldição da Pobreza', 'est': 'Maldição da Ignorância', 'sor': 'Maldição do Azar', 'bar': 'Maldição do Desperdício',
};
const _sufixos = {
  'gan': 'do Ganancioso', 'est': 'do Estudioso', 'sor': 'do Sortudo', 'bar': 'do Barganhista',
  'bau': 'do Caçador de Baús', 'abu': 'da Abundância', 'tes': 'do Garimpeiro', 'tex': 'do Tesoureiro',
};
const _sufixosNeg = {'gan': 'da Pobreza', 'est': 'da Ignorância', 'sor': 'do Azar', 'bar': 'do Desperdício'};

/// --afx-*: cor de cada encantamento (o "gan" usa o --gold do tema).
const _coresAfixo = {
  'gan': corOuro, 'est': Color(0xFF7FB8FF), 'sor': Color(0xFF8FE3A0), 'bar': Color(0xFFFFB070),
  'bau': Color(0xFFE6A8FF), 'abu': Color(0xFFFF8F8F), 'tes': Color(0xFF7FE0D6), 'tex': Color(0xFFB8E65C),
};

/// AFX_SP: sprite da folha que representa cada encantamento na forja.
const spriteAfixo = {'gan': 49, 'est': 77, 'sor': 42, 'bar': 86, 'tes': 1, 'tex': 1, 'bau': 16, 'abu': 118};

Color corAfixo(Afixo a) => a.valor < 0 ? corVida : (_coresAfixo[a.tipo] ?? corOuro);

/// `afxNome()`
String nomeAfixo(Afixo a) => (a.valor < 0 ? _nomesAfixoNeg[a.tipo] : _nomesAfixo[a.tipo]) ?? a.tipo;

/// `afxEfeito()`
String efeitoAfixo(Afixo a) {
  final v = a.valor.abs();
  if (a.valor < 0) {
    return switch (a.tipo) {
      'gan' => '-$v% moedas ganhas',
      'est' => '-$v% XP ganho',
      'sor' => '-$v% sorte nos baús',
      _ => '+$v% preço na loja',
    };
  }
  return switch (a.tipo) {
    'gan' => '+$v% moedas ganhas',
    'est' => '+$v% XP ganho',
    'sor' => '+$v% sorte nos baús',
    'bar' => '$v% de desconto na loja',
    'bau' => '+$v% chance de baú trancado',
    'abu' => '+$v% chance de baú extra',
    'tes' => '+$v% chance de tesouro',
    _ => '+$v% chance de tesouro extra',
  };
}

/// `nomeComAfixo()`: "Peitoral do Sortudo".
String nomeComAfixo(ItemCatalogo it, String idioma) {
  final a = it.afixo;
  final nome = it.nomeNoIdioma(idioma);
  if (a == null) return nome;
  final suf = a.valor < 0 ? _sufixosNeg[a.tipo] : _sufixos[a.tipo];
  return suf == null ? nome : '$nome $suf';
}

/// Bônus do item em pedaços `(rótulo, valor)`, como `textoBonus()` e as linhas `.irow` da ficha.
List<(String, String)> bonusDoItem(ItemCatalogo it) {
  final b = bonusItem(it);
  final l = <(String, String)>[];
  if (it.tipo == 'cons') {
    if (b.x != 0) l.add(('XP', '+${b.x}'));
    if (b.m != 0) l.add(('Moedas', '+${b.m}'));
    if (it.cura != 0) l.add(('HP', '+${it.cura}'));
  } else if (slotsEquip.contains(it.tipo)) {
    if (b.x != 0) l.add(('XP', '${b.x > 0 ? '+' : ''}${b.x}%'));
    if (b.m != 0) l.add(('Moedas', '${b.m > 0 ? '+' : ''}${b.m}%'));
  }
  return l;
}

// ---------- sprites ----------
// `filter: brightness(1.6) contrast(1.05)` das armas escuras (.pxi.armaEscura)
const _filtroArmaEscura = ColorFilter.matrix(<double>[
  1.68, 0, 0, 0, -6.375, //
  0, 1.68, 0, 0, -6.375, //
  0, 0, 1.68, 0, -6.375, //
  0, 0, 0, 1, 0,
]);
// `filter: grayscale(1) brightness(.62)` do ícone fantasma do slot vazio (.eslot .fantasma)
const _filtroFantasma = ColorFilter.matrix(<double>[
  0.1318, 0.4434, 0.0448, 0, 0, //
  0.1318, 0.4434, 0.0448, 0, 0, //
  0.1318, 0.4434, 0.0448, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// Um tile da folha de sprites (16 x 27 tiles de 32 px) desenhado em [tamanho] (ou [largura] x [altura]), sem suavização.
class Sprite extends StatelessWidget {
  const Sprite({super.key, required this.estado, required this.sprite, this.tamanho = 32, this.largura, this.altura, this.fantasma = false, this.clarear});
  final EstadoJogo estado;
  final int sprite;
  final double tamanho;
  final double? largura;
  final double? altura;

  /// Ícone apagado do slot vazio.
  final bool fantasma;

  /// Clareia como arma escura; null = decide pelo índice do sprite (`ehSpriteArmaEscura`).
  final bool? clarear;

  @override
  Widget build(BuildContext context) {
    final f = estado.dados.folha;
    final w = largura ?? tamanho, h = altura ?? tamanho;
    final c = sprite % f.colunas, l = sprite ~/ f.colunas;
    Widget img = SizedBox(
      width: w,
      height: h,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          minHeight: 0,
          maxWidth: w * f.colunas,
          maxHeight: h * f.linhas,
          child: Transform.translate(
            offset: Offset(-c * w, -l * h),
            child: Image.asset(f.arquivo, width: w * f.colunas, height: h * f.linhas, fit: BoxFit.fill, filterQuality: FilterQuality.none, gaplessPlayback: true),
          ),
        ),
      ),
    );
    if (fantasma) return Opacity(opacity: 0.30, child: ColorFiltered(colorFilter: _filtroFantasma, child: img));
    if (clarear ?? EquipArena.atual.spritesEscuros.contains(sprite)) img = ColorFiltered(colorFilter: _filtroArmaEscura, child: img);
    return img;
  }
}

/// O sprite de um item do catálogo.
class SpriteItem extends StatelessWidget {
  const SpriteItem({super.key, required this.estado, required this.item, this.tamanho = 32});
  final EstadoJogo estado;
  final ItemCatalogo item;
  final double tamanho;
  @override
  Widget build(BuildContext context) => Sprite(estado: estado, sprite: item.sprite, tamanho: tamanho);
}

/// Caixa escura com o ícone do item (.ibox 60, .lbox 46, .baubox 34...).
class CaixaItem extends StatelessWidget {
  const CaixaItem({super.key, required this.estado, required this.item, this.lado = 60, this.sprite = 44, this.raio = 12, this.borda = corLinha});
  final EstadoJogo estado;
  final ItemCatalogo item;
  final double lado;
  final double sprite;
  final double raio;
  final Color? borda;
  @override
  Widget build(BuildContext context) => Container(
        width: lado,
        height: lado,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: corPoco, borderRadius: BorderRadius.circular(raio), border: borda == null ? null : Border.all(color: borda!, width: 0.8)),
        child: SpriteItem(estado: estado, item: item, tamanho: sprite),
      );
}

/// Pílula "RARO · ARMADURA" da ficha (.imeta.tag): texto na cor da raridade, fundo a 16% e borda a 35% dela.
class EtiquetaRaridade extends StatelessWidget {
  const EtiquetaRaridade(this.texto, {super.key, required this.cor});
  final String texto;
  final Color cor;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cor.withValues(alpha: 0.35), width: 0.8),
        ),
        child: Text(texto.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.88, color: cor, height: 1.3)),
      );
}

/// Nome do item na ficha (.iname): Cormorant Garamond itálico 20px na cor da raridade.
/// Fonte variável (eixo de peso): pedimos 500.
TextStyle estiloNomeItem(Color cor) => TextStyle(
      fontFamily: 'Cormorant Garamond',
      fontFamilyFallback: const ['serif'],
      fontStyle: FontStyle.italic,
      fontVariations: const [FontVariation('wght', 500)],
      fontSize: 20,
      height: 1.15,
      color: cor,
    );

/// Cabeçalho da ficha (.ihead.eqh): caixa do ícone, nome e etiqueta; em coluna (ficha) ou em linha (forja).
class CabecalhoItem extends StatelessWidget {
  const CabecalhoItem({super.key, required this.estado, required this.item, required this.etiqueta, this.emLinha = false, this.bordaCaixa = corLinha});
  final EstadoJogo estado;
  final ItemCatalogo item;
  final String etiqueta;
  final bool emLinha;
  final Color bordaCaixa;

  @override
  Widget build(BuildContext context) {
    final cor = corRaridade[item.raridade.clamp(0, 7)];
    final caixa = CaixaItem(estado: estado, item: item, borda: bordaCaixa);
    final nome = Text(nomeComAfixo(item, estado.idioma), textAlign: emLinha ? TextAlign.left : TextAlign.center, style: estiloNomeItem(cor));
    final tag = EtiquetaRaridade(etiqueta, cor: cor);
    if (emLinha) {
      return Row(children: [
        caixa,
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [nome, const SizedBox(height: 6), tag])),
      ]);
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [caixa, const SizedBox(height: 8), nome, const SizedBox(height: 6), tag]);
  }
}

/// Pílula de filtro (.invfiltros button / .lojatabs button).
class PilulaFiltro extends StatelessWidget {
  const PilulaFiltro(this.texto, {super.key, required this.ativa, required this.aoTocar, this.pequena = false});
  final String texto;
  final bool ativa;
  final VoidCallback aoTocar;
  final bool pequena;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: aoTocar,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: pequena ? 10 : 12, vertical: pequena ? 4 : 5),
          decoration: BoxDecoration(
            color: ativa ? Colors.white : corPainel3,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ativa ? Colors.white : corLinha, width: 0.8),
          ),
          child: Text(texto, style: TextStyle(fontSize: pequena ? 11 : 11.5, fontWeight: FontWeight.w600, color: ativa ? corFundo : corApagado, height: 1.26)),
        ),
      );
}

/// Cabeçalho das abas (.vhead): título à esquerda, legenda apagada à direita.
class CabecalhoAba extends StatelessWidget {
  const CabecalhoAba(this.titulo, this.legenda, {super.key});
  final String titulo;
  final String legenda;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: corTexto, height: 1.25)),
        const Spacer(),
        Text(legenda, style: const TextStyle(fontSize: 12, color: corApagado)),
      ]);
}
