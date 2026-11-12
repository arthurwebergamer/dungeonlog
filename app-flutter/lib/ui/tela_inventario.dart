// Aba Inventário no visual do app original (#viewInventario): cabeçalho com a contagem, caixa dos 5 slots com o
// ícone fantasma do slot vazio e a linha de bônus, busca, filtros (com os subfiltros de equipamento) e a grade.
// Medidas e cores do CSS computado de play/ em 390x844; regras em renderInventario() (play/index.html ~8611).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/catalogo.dart';
import '../dominio/economia.dart';
import 'estado_jogo.dart';
import 'ficha_item.dart';
import 'flutuante.dart';
import 'folhas.dart';
import 'icones.dart';
import 'itens_ui.dart';
import 'tema.dart';
import 'topo.dart';

export 'ficha_item.dart' show FichaItem, abrirFichaItem;
export 'itens_ui.dart';

/// SUBCATS_EQUIP: subcategorias de equipamento (armas por tipo + as demais peças).
const subcategoriasEquip = [
  ('espada', 'Espadas'), ('adaga', 'Adagas'), ('machado', 'Machados'), ('haste', 'Lanças e hastes'),
  ('impacto', 'Maças e martelos'), ('arco', 'Arcos'), ('besta', 'Bestas e fundas'), ('magico', 'Cajados e varinhas'),
  ('escudo', 'Escudos'), ('elmo', 'Elmos'), ('armadura', 'Armaduras'), ('acess', 'Acessórios'),
];

/// `subcatEquip(nome, tipo)`: a subcategoria sai do nome em português do item base.
String subcatEquip(String nome, String tipo) {
  if (tipo != 'arma') return tipo; // escudo | elmo | armadura | acess
  bool tem(String padrao) => RegExp(padrao, caseSensitive: false).hasMatch(nome);
  if (tem(r'^Arco')) return 'arco';
  if (tem(r'^(Besta|Arbalesta|Zarabatana|Estilingue|Funda)')) return 'besta';
  if (tem(r'Cajado|Varinha|Bast[aã]o Arcano|Cetro')) return 'magico';
  if (tem(r'Adaga|Faca')) return 'adaga';
  if (tem(r'Machad|Tomahawk|Bardiche')) return 'machado';
  if (tem(r'Lan[cç]a|Alabarda|Tridente|Trishula|Glaive|Foice|Lajatang|Bord[aã]o|Chicote')) return 'haste';
  if (tem(r'Ma[cç]a|Maca|Mangual|Martelo|Clava|Taco|Estrela|Flagelo')) return 'impacto';
  return 'espada';
}

/// `semAcento()`: minúsculas sem acento, para a busca.
String semAcento(String? t) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçñ', para = 'aaaaaeeeeiiiiooooouuuucn';
  final s = StringBuffer();
  for (final ch in (t ?? '').toLowerCase().split('')) {
    final i = de.indexOf(ch);
    s.write(i < 0 ? ch : para[i]);
  }
  return s.toString();
}

/// SPRITE_SLOT: sprite genérico usado como fantasma no slot vazio.
const _spriteSlot = {'arma': 66, 'armadura': 70, 'elmo': 63, 'escudo': 128, 'acess': 102};
const _chaveSlot = {'arma': 'inv.slotArma', 'armadura': 'inv.slotPeito', 'elmo': 'inv.slotElmo', 'escudo': 'inv.slotEscudo', 'acess': 'inv.slotAcess'};

class TelaInventario extends StatefulWidget {
  const TelaInventario({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaInventario> createState() => _TelaInventarioState();
}

class _TelaInventarioState extends State<TelaInventario> {
  String _filtro = 'tudo';
  String _sub = 'todos';
  String _busca = '';

  EstadoJogo get e => widget.estado;

  static const _filtros = [
    ('tudo', 'inv.filtroTudo'),
    ('equip', 'inv.filtroEquip'),
    ('cons', 'inv.filtroCons'),
    ('tesouro', 'inv.filtroTesouro'),
    ('chave', 'inv.filtroChave'),
  ];

  String _subDe(ItemCatalogo it) => subcatEquip(it.nome, it.tipo);

  bool _passa(ItemCatalogo it, String termo) {
    if (termo.isNotEmpty) {
      final a = it.afixo;
      final achou = semAcento(it.nomeNoIdioma(e.idioma)).contains(termo) ||
          semAcento(it.nome).contains(termo) ||
          semAcento(it.nomeEn).contains(termo) ||
          (a != null && semAcento(nomeAfixo(a)).contains(termo));
      if (!achou) return false;
    }
    return switch (_filtro) {
      'tudo' => true,
      'equip' => slotsEquip.contains(it.tipo) && (_sub == 'todos' || _subDe(it) == _sub),
      _ => it.tipo == _filtro,
    };
  }

  void _abrirFicha(ItemCatalogo it, BuildContext origem) {
    HapticFeedback.selectionClick();
    abrirFichaItem(context, e, it, origem: centroDe(origem));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final t = e.dados.traducoes;
        final inv = <(ItemCatalogo, int)>[];
        var total = 0;
        final contSub = <String>{};
        for (final sl in e.save.inventario) {
          final it = e.catalogo.item(sl['id']);
          if (it == null) continue;
          final q = ((sl['q'] as num?) ?? 1).toInt();
          inv.add((it, q));
          total += q;
          if (slotsEquip.contains(it.tipo)) contSub.add(_subDe(it));
        }
        if (_sub != 'todos' && !contSub.contains(_sub)) _sub = 'todos';
        final termo = semAcento(_busca).trim();
        // mais raro primeiro; no empate fica a ordem do inventário (o sort do JS é estável)
        final visiveis = [for (var i = 0; i < inv.length; i++) if (_passa(inv[i].$1, termo)) i]
          ..sort((a, b) {
            final r = inv[b].$1.raridade.compareTo(inv[a].$1.raridade);
            return r != 0 ? r : a.compareTo(b);
          });
        final semNada = inv.isEmpty;

        final cabecalho = Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: CabecalhoAba(t.t('inv.titulo', e.idioma), '$total ${total == 1 ? 'item' : 'itens'}'),
        );

        return SafeArea(
          bottom: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TopoApp(estado: e),
            if (semNada) ...[
              cabecalho,
              Expanded(child: _MochilaVazia(titulo: t.t('inv.mochilaVazia', e.idioma), texto: t.t('inv.mochilaVaziaDesc', e.idioma))),
            ] else
              Expanded(
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: cabecalho),
                  SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: _CaixaEquip(estado: e, aoTocar: _abrirFicha))),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      child: _CampoBusca(aoMudar: (v) => setState(() => _busca = v)),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _FaixaFixa(
                      altura: 44,
                      child: ColoredBox(
                        color: corFundo,
                        child: _LinhaPilulas(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          filhos: [
                            for (final (id, chave) in _filtros)
                              PilulaFiltro(t.t(chave, e.idioma), ativa: _filtro == id, aoTocar: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _filtro = id;
                                  _sub = 'todos';
                                });
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (_filtro == 'equip')
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          height: 24,
                          child: _LinhaPilulas(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            filhos: [
                              for (final (id, nome) in [('todos', 'Todos'), ...subcategoriasEquip.where((c) => contSub.contains(c.$1))])
                                PilulaFiltro(nome, pequena: true, ativa: _sub == id, aoTocar: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _sub = id);
                                }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (visiveis.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                        child: Text('Nada nesta categoria.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: corApagado)),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8),
                        delegate: SliverChildBuilderDelegate(
                          childCount: visiveis.length,
                          (_, i) {
                            final (it, q) = inv[visiveis[i]];
                            return _CelulaItem(estado: e, item: it, q: q, aoTocar: (ctx) => _abrirFicha(it, ctx));
                          },
                        ),
                      ),
                    ),
                ]),
              ),
          ]),
        );
      },
    );
  }
}

/// Faixa de altura fixa que fica presa no topo da rolagem (filtros com `position: sticky`).
class _FaixaFixa extends SliverPersistentHeaderDelegate {
  _FaixaFixa({required this.altura, required this.child});
  final double altura;
  final Widget child;
  @override
  double get minExtent => altura;
  @override
  double get maxExtent => altura;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);
  @override
  bool shouldRebuild(_FaixaFixa o) => true;
}

/// Linha de pílulas que rola para o lado, com 7px de vão.
class _LinhaPilulas extends StatelessWidget {
  const _LinhaPilulas({required this.filhos, required this.padding});
  final List<Widget> filhos;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(children: [
          for (var i = 0; i < filhos.length; i++) ...[if (i > 0) const SizedBox(width: 7), filhos[i]],
        ]),
      );
}

/// Campo de busca em pílula (.invbusca input).
class _CampoBusca extends StatelessWidget {
  const _CampoBusca({required this.aoMudar});
  final ValueChanged<String> aoMudar;
  @override
  Widget build(BuildContext context) => Container(
        height: 33.6,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(999), border: Border.all(color: corLinha, width: 0.8)),
        child: TextField(
          onChanged: aoMudar,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 13, color: corTexto, height: 1.25),
          cursorWidth: 1.5,
          decoration: const InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: 'Buscar item...',
            hintStyle: TextStyle(fontSize: 13, color: corApagado, height: 1.25),
          ),
        ),
      );
}

/// Estado sem nenhum item (.vazio).
class _MochilaVazia extends StatelessWidget {
  const _MochilaVazia({required this.titulo, required this.texto});
  final String titulo;
  final String texto;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Opacity(opacity: 0.45, child: Icone(IconeApp.inventario, tamanho: 46, cor: corApagado)),
            const SizedBox(height: 9),
            Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: corSuave)),
            const SizedBox(height: 9),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.55, color: corApagado)),
            ),
          ]),
        ),
      );
}

/// Caixa de equipamento (.equipbox): os 5 slots e a linha "Moedas +N%  XP +N%".
class _CaixaEquip extends StatelessWidget {
  const _CaixaEquip({required this.estado, required this.aoTocar});
  final EstadoJogo estado;
  final void Function(ItemCatalogo, BuildContext) aoTocar;

  @override
  Widget build(BuildContext context) {
    final b = estado.bonus;
    String pct(int v) => '${v >= 0 ? '+' : ''}$v%';
    const rotulo = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: corApagado, height: 1.25);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(14), border: Border.all(color: corLinha, width: 0.8)),
      child: Column(children: [
        Row(children: [
          for (var i = 0; i < slotsEquip.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _Slot(estado: estado, slot: slotsEquip[i], aoTocar: aoTocar)),
          ],
        ]),
        Container(
          margin: const EdgeInsets.only(top: 11),
          padding: const EdgeInsets.only(top: 9),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: corLinha, width: 0.8))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text.rich(TextSpan(style: rotulo, children: [
              TextSpan(text: '${estado.dados.traducoes.t('inv.moedas', estado.idioma)} '),
              TextSpan(text: pct(b.m), style: const TextStyle(fontWeight: FontWeight.w700, color: corOuro)),
            ])),
            const SizedBox(width: 14),
            Text.rich(TextSpan(style: rotulo, children: [
              const TextSpan(text: 'XP '),
              TextSpan(text: pct(b.x), style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            ])),
          ]),
        ),
      ]),
    );
  }
}

/// Um slot (.eslot): tracejado com o ícone fantasma e o rótulo quando vazio; borda da raridade e o sprite quando cheio.
class _Slot extends StatelessWidget {
  const _Slot({required this.estado, required this.slot, required this.aoTocar});
  final EstadoJogo estado;
  final String slot;
  final void Function(ItemCatalogo, BuildContext) aoTocar;

  @override
  Widget build(BuildContext context) {
    final id = estado.save.equipado[slot];
    final it = id is num ? estado.catalogo.item(id) : null;
    if (it != null) {
      return GestureDetector(
        onTap: () => aoTocar(it, context),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: corPoco,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: corBordaRaridade[it.raridade.clamp(0, 7)], width: 0.8),
              boxShadow: brilhoRaridade(it.raridade),
            ),
            child: SpriteItem(estado: estado, item: it, tamanho: 34),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: const _BordaTracejada(cor: corLinha, raio: 10, fundo: corPoco),
        child: Stack(alignment: Alignment.center, children: [
          Sprite(estado: estado, sprite: _spriteSlot[slot]!, tamanho: 26, fantasma: true, clarear: false),
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            child: Text(
              estado.dados.traducoes.t(_chaveSlot[slot]!, estado.idioma).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, letterSpacing: 0.24, color: corApagado, height: 1.3),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Fundo com borda tracejada de cantos redondos (`border: 1px dashed`).
class _BordaTracejada extends CustomPainter {
  const _BordaTracejada({required this.cor, required this.raio, required this.fundo});
  final Color cor;
  final double raio;
  final Color fundo;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.4), Radius.circular(raio));
    canvas.drawRRect(r, Paint()..color = fundo);
    final traco = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final m in (Path()..addRRect(r)).computeMetrics()) {
      const cheio = 2.4, vao = 2.4;
      for (var d = 0.0; d < m.length; d += cheio + vao) {
        canvas.drawPath(m.extractPath(d, (d + cheio).clamp(0, m.length)), traco);
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejada o) => o.cor != cor || o.raio != raio || o.fundo != fundo;
}

/// Célula da grade (.cel): sprite 32, quantidade no canto e a bolinha verde de "equipado".
class _CelulaItem extends StatelessWidget {
  const _CelulaItem({required this.estado, required this.item, required this.q, required this.aoTocar});
  final EstadoJogo estado;
  final ItemCatalogo item;
  final int q;
  final void Function(BuildContext) aoTocar;

  @override
  Widget build(BuildContext context) {
    final r = item.raridade.clamp(0, 7);
    return Toque(
      aoTocar: () => aoTocar(context),
      escala: 0.94,
      child: Container(
        decoration: BoxDecoration(
          color: corPainel3,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: corBordaRaridade[r], width: 0.8),
          boxShadow: brilhoRaridade(r),
        ),
        child: Stack(alignment: Alignment.center, children: [
          SpriteItem(estado: estado, item: item, tamanho: 32),
          if (q > 1)
            Positioned(
              right: 3,
              bottom: 2,
              child: Text('$q',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: corTexto, height: 1.28, shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(0, 1))])),
            ),
          if (estado.equipado(item.id))
            const Positioned(left: 3, top: 3, child: SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: corVerde, shape: BoxShape.circle)))),
        ]),
      ),
    );
  }
}
