// Dados estáticos extraídos de play/assets.js e play/index.html (ver tools/extrair_assets.mjs):
// monstros, heróis, cenários (temas da arena), itens e textos PT/EN. Sem dependência do Flutter.
import 'dart:convert';

import 'catalogo.dart';

class Monstro {
  final String nome;
  final String nomeEn;
  final String? bioma; // null = vale em qualquer cenário
  final String img; // caminho do asset
  const Monstro(this.nome, this.nomeEn, this.bioma, this.img);
  factory Monstro.deJson(Map<String, dynamic> j) =>
      Monstro(j['nome'] as String, (j['nome_en'] ?? j['nome']) as String, j['bioma'] as String?, j['img'] as String);
  String nomeNoIdioma(String idioma) => idioma == 'en' ? nomeEn : nome;
}

class Heroi {
  final String nome;
  final String nomeEn;
  final String img;
  final String? imgArena;
  const Heroi(this.nome, this.nomeEn, this.img, this.imgArena);
  factory Heroi.deJson(Map<String, dynamic> j) =>
      Heroi(j['nome'] as String, (j['nome_en'] ?? j['nome']) as String, j['img'] as String, j['imgArena'] as String?);
  String nomeNoIdioma(String idioma) => idioma == 'en' ? nomeEn : nome;
}

class TemaArena {
  final String id;
  final String nome;
  final String nomeEn;
  final bool gratuito;
  final String? arte;
  final String? arteEstagio;
  final Map<String, dynamic>? desbloqueioGratis;
  final Map<String, dynamic> bruto;
  const TemaArena(this.id, this.nome, this.nomeEn, this.gratuito, this.arte, this.arteEstagio, this.desbloqueioGratis, this.bruto);
  factory TemaArena.deJson(Map<String, dynamic> j) => TemaArena(
        j['id'] as String,
        j['nome'] as String,
        (j['nome_en'] ?? j['nome']) as String,
        j['gratuito'] == true,
        j['arte'] as String?,
        j['arteEstagio'] as String?,
        j['desbloqueioGratis'] == null ? null : Map<String, dynamic>.from(j['desbloqueioGratis'] as Map),
        j,
      );
}

/// Folha de sprites dos itens: 16 colunas x 27 linhas de tiles 32x32. `sprite` do item = índice na folha.
class FolhaItens {
  final String arquivo;
  final int colunas;
  final int linhas;
  final int tile;
  const FolhaItens(this.arquivo, this.colunas, this.linhas, this.tile);
  ({int x, int y}) origem(int sprite) => (x: (sprite % colunas) * tile, y: (sprite ~/ colunas) * tile);
}

/// `TRADUCOES`: chave -> {pt, en}.
class Traducoes {
  final Map<String, Map<String, String>> _m;
  Traducoes(this._m);
  factory Traducoes.deJson(Map<String, dynamic> j) => Traducoes({
        for (final e in j.entries) e.key: {for (final l in (e.value as Map).entries) l.key as String: l.value as String},
      });
  int get tamanho => _m.length;
  Iterable<String> get chaves => _m.keys;

  /// Texto da chave no idioma; cai no PT e depois na própria chave.
  String t(String chave, [String idioma = 'pt']) => _m[chave]?[idioma] ?? _m[chave]?['pt'] ?? chave;
}

class DadosJogo {
  final List<Monstro> monstros;
  final List<Heroi> herois;
  final List<TemaArena> temas;
  final Catalogo catalogo;
  final FolhaItens folha;
  final Traducoes traducoes;
  DadosJogo(this.monstros, this.herois, this.temas, this.catalogo, this.folha, this.traducoes);

  /// Monta tudo a partir do TEXTO dos cinco JSON de `assets/dados/`.
  factory DadosJogo.deTextos({
    required String monstros,
    required String herois,
    required String temas,
    required String itens,
    required String traducoes,
  }) {
    final it = jsonDecode(itens) as Map<String, dynamic>;
    final f = it['sheet'] as Map<String, dynamic>;
    return DadosJogo(
      [for (final m in jsonDecode(monstros) as List) Monstro.deJson(Map<String, dynamic>.from(m as Map))],
      [for (final h in jsonDecode(herois) as List) Heroi.deJson(Map<String, dynamic>.from(h as Map))],
      [for (final t in jsonDecode(temas) as List) TemaArena.deJson(Map<String, dynamic>.from(t as Map))],
      Catalogo.deLinhas([for (final l in it['linhas'] as List) List<dynamic>.from(l as List)]),
      FolhaItens(f['arquivo'] as String, f['colunas'] as int, f['linhas'] as int, f['tile'] as int),
      Traducoes.deJson(Map<String, dynamic>.from(jsonDecode(traducoes) as Map)),
    );
  }

  /// Biomas dos monstros, na ordem do catálogo (entrada de `poolMonstros`).
  List<String?> get biomasDosMonstros => [for (final m in monstros) m.bioma];

  /// `biomaDoEstagio(estagio)`: o id do tema na posição do estágio (1 a 4).
  String? biomaDoEstagio(int estagio) => (estagio >= 1 && estagio <= temas.length) ? temas[estagio - 1].id : null;
}
