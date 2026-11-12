// Aba Inventário: slots de equipamento, filtros, grade de itens e a ficha do item (equipar, usar, vender).
// Regras em EstadoJogo (equipar/usarItem/venderItem), espelho de play/index.html (~8417 a 8466).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/catalogo.dart';
import '../dominio/economia.dart';
import '../dominio/regras.dart' show precoVenda;
import 'estado_jogo.dart';
import 'folhas.dart';
import 'tema.dart';

const corRaridade = [
  Color(0xFF8779A8), Color(0xFF63C99A), Color(0xFF5AA9F2), Color(0xFFF05AB5),
  Color(0xFFB57BE8), Color(0xFFF2A65A), Color(0xFFE5484D), Color(0xFF5AE0D8),
];
const _nomesRaridadePt = ['Comum', 'Incomum', 'Raro', 'Superior', 'Épico', 'Lendário', 'Ancestral', 'Único'];
const _nomesRaridadeEn = ['Common', 'Uncommon', 'Rare', 'Superior', 'Epic', 'Legendary', 'Ancestral', 'Unique'];
const _nomesTipoPt = {
  'arma': 'Arma', 'armadura': 'Armadura', 'elmo': 'Elmo', 'escudo': 'Escudo', 'acess': 'Acessório',
  'cons': 'Consumível', 'tesouro': 'Tesouro', 'chave': 'Item-chave',
};
const _nomesAfixo = {
  'gan': 'Ganancioso', 'est': 'Estudioso', 'sor': 'Sortudo', 'bar': 'Barganhista',
  'bau': 'Caçador de Baús', 'abu': 'Abundante', 'tes': 'Garimpeiro', 'tex': 'Tesoureiro',
};

String nomeRaridade(int r, String idioma) => (idioma == 'en' ? _nomesRaridadeEn : _nomesRaridadePt)[r.clamp(0, 7)];

String _efeitoAfixo(Afixo a) {
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

String _nomeAfixo(Afixo a) {
  if (a.valor < 0) {
    return switch (a.tipo) {
      'gan' => 'Maldição da Pobreza',
      'est' => 'Maldição da Ignorância',
      'sor' => 'Maldição do Azar',
      _ => 'Maldição do Desperdício',
    };
  }
  return _nomesAfixo[a.tipo] ?? a.tipo;
}

/// Um tile da folha de sprites (16 x 27 tiles de 32 px) desenhado em [tamanho].
class SpriteItem extends StatelessWidget {
  const SpriteItem({super.key, required this.estado, required this.item, this.tamanho = 40});
  final EstadoJogo estado;
  final ItemCatalogo item;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final f = estado.dados.folha;
    final c = item.sprite % f.colunas, l = item.sprite ~/ f.colunas;
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          minHeight: 0,
          maxWidth: tamanho * f.colunas,
          maxHeight: tamanho * f.linhas,
          child: Transform.translate(
            offset: Offset(-c * tamanho, -l * tamanho),
            child: Image.asset(
              f.arquivo,
              width: tamanho * f.colunas,
              height: tamanho * f.linhas,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      ),
    );
  }
}

class TelaInventario extends StatefulWidget {
  const TelaInventario({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaInventario> createState() => _TelaInventarioState();
}

class _TelaInventarioState extends State<TelaInventario> {
  String _filtro = 'tudo';
  String _busca = '';

  static const _filtros = [
    ('tudo', 'Tudo'),
    ('equip', 'Equipamento'),
    ('cons', 'Consumíveis'),
    ('tesouro', 'Tesouros'),
    ('chave', 'Chaves'),
  ];

  bool _passa(ItemCatalogo it) {
    final okFiltro = switch (_filtro) {
      'equip' => slotsEquip.contains(it.tipo),
      'cons' => it.tipo == 'cons',
      'tesouro' => it.tipo == 'tesouro',
      'chave' => it.tipo == 'chave',
      _ => true,
    };
    if (!okFiltro) return false;
    if (_busca.isEmpty) return true;
    return it.nomeNoIdioma(widget.estado.idioma).toLowerCase().contains(_busca.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    return ListenableBuilder(
      listenable: e,
      builder: (_, __) {
        final itens = <(ItemCatalogo, int)>[];
        for (final sl in e.save.inventario) {
          final it = e.catalogo.item(sl['id']);
          if (it != null && _passa(it)) itens.add((it, ((sl['q'] as num?) ?? 1).toInt()));
        }
        itens.sort((a, b) {
          final r = b.$1.raridade.compareTo(a.$1.raridade);
          return r != 0 ? r : a.$1.nome.compareTo(b.$1.nome);
        });
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Inventário', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _Slots(estado: e, aoTocar: (it) => _abrirFicha(it)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _busca = v),
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  isDense: true,
                  filled: true,
                  fillColor: corPainel,
                  prefixIcon: const Icon(Icons.search, size: 20, color: corApagado),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (final (id, nome) in _filtros)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(nome),
                        selected: _filtro == id,
                        showCheckmark: false,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _filtro = id);
                        },
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: itens.isEmpty
                    ? const Center(child: Text('Nada por aqui.', style: TextStyle(color: corApagado)))
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8),
                        itemCount: itens.length,
                        itemBuilder: (_, i) => _CelulaItem(estado: e, item: itens[i].$1, q: itens[i].$2, aoTocar: () => _abrirFicha(itens[i].$1)),
                      ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _abrirFicha(ItemCatalogo it) {
    HapticFeedback.selectionClick();
    abrirFolha<void>(context, (ctx) => FichaItem(estado: widget.estado, item: it));
  }
}

class _CelulaItem extends StatelessWidget {
  const _CelulaItem({required this.estado, required this.item, required this.q, required this.aoTocar});
  final EstadoJogo estado;
  final ItemCatalogo item;
  final int q;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final equipado = estado.equipado(item.id);
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        decoration: BoxDecoration(
          color: corPainel3,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: corRaridade[item.raridade.clamp(0, 7)].withValues(alpha: 0.75), width: equipado ? 2 : 1),
        ),
        child: Stack(alignment: Alignment.center, children: [
          SpriteItem(estado: estado, item: item, tamanho: 38),
          if (q > 1)
            Positioned(right: 4, bottom: 2, child: Text('×$q', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
          if (item.afixo != null)
            Positioned(
              left: 4,
              top: 2,
              child: Text('✦', style: TextStyle(fontSize: 11, color: item.afixo!.valor < 0 ? corVida : corXpB)),
            ),
        ]),
      ),
    );
  }
}

class _Slots extends StatelessWidget {
  const _Slots({required this.estado, required this.aoTocar});
  final EstadoJogo estado;
  final ValueChanged<ItemCatalogo> aoTocar;

  static const _rotulos = {'arma': 'Arma', 'armadura': 'Armadura', 'elmo': 'Elmo', 'escudo': 'Escudo', 'acess': 'Acessório'};

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final s in slotsEquip)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Builder(builder: (_) {
              final id = estado.save.equipado[s];
              final it = id is num ? estado.catalogo.item(id) : null;
              return GestureDetector(
                onTap: it == null ? null : () => aoTocar(it),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: corPainel2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: it == null ? corLinha : corRaridade[it.raridade.clamp(0, 7)], width: 1),
                    ),
                    child: it == null
                        ? Center(child: Text(_rotulos[s]!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, color: corApagado)))
                        : Center(child: SpriteItem(estado: estado, item: it, tamanho: 38)),
                  ),
                ),
              );
            }),
          ),
        ),
    ]);
  }
}

/// Ficha do item: nome, raridade, efeitos e as ações possíveis.
class FichaItem extends StatelessWidget {
  const FichaItem({super.key, required this.estado, required this.item});
  final EstadoJogo estado;
  final ItemCatalogo item;

  List<String> _efeitos() {
    final l = <String>[];
    if (item.bonusMoedas != 0) l.add('${item.bonusMoedas > 0 ? '+' : ''}${item.bonusMoedas}% moedas');
    if (item.bonusXp != 0) l.add('${item.bonusXp > 0 ? '+' : ''}${item.bonusXp}% XP');
    if (item.afixo != null) l.add('${_nomeAfixo(item.afixo!)}: ${_efeitoAfixo(item.afixo!)}');
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (ctx, _) {
        final q = estado.quantidadeDe(item.id);
        final equip = slotsEquip.contains(item.tipo);
        final equipado = estado.equipado(item.id);
        final cor = corRaridade[item.raridade.clamp(0, 7)];
        final preco = precoVenda(item.tipo, item.valor);
        final consumivel = item.tipo == 'cons';
        final efeitos = [
          ..._efeitos(),
          if (consumivel && item.cura != 0) '+${item.cura} de vida',
          if (consumivel && item.bonusXp != 0) '+${item.bonusXp} XP ao usar',
          if (consumivel && item.bonusMoedas != 0) '+${item.bonusMoedas} moedas ao usar',
        ];
        return Folha(titulo: item.nomeNoIdioma(estado.idioma), filhos: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(14), border: Border.all(color: cor)),
              child: SpriteItem(estado: estado, item: item, tamanho: 54),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${nomeRaridade(item.raridade, estado.idioma)} · ${_nomesTipoPt[item.tipo] ?? item.tipo}',
                    style: TextStyle(color: cor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Quantidade: $q', style: const TextStyle(color: corApagado, fontSize: 13)),
              ]),
            ),
          ]),
          if (efeitos.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final t in efeitos) Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(t, style: const TextStyle(fontSize: 14, color: corSuave))),
          ],
          const SizedBox(height: 16),
          if (q > 0 && equip)
            BotaoFolha(equipado ? 'Desequipar' : 'Equipar', aoTocar: () {
              HapticFeedback.mediumImpact();
              estado.equipar(item.id);
              Navigator.pop(ctx);
            }),
          if (q > 0 && consumivel)
            BotaoFolha('Usar', aoTocar: () {
              HapticFeedback.mediumImpact();
              estado.usarItem(item.id);
              if (estado.quantidadeDe(item.id) == 0) Navigator.pop(ctx);
            }),
          if (q > 0 && !(item.tipo == 'chave' && item.nome == 'Grimório')) ...[
            const SizedBox(height: 9),
            BotaoFolha('Vender por $preco', fundo: corPainel, cor: corTexto, borda: corLinha, aoTocar: () {
              HapticFeedback.mediumImpact();
              estado.venderItem(item.id);
              if (estado.quantidadeDe(item.id) == 0) Navigator.pop(ctx);
            }),
          ],
        ]);
      },
    );
  }
}
