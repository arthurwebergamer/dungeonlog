// Aba Loja: prateleira do dia (8 vagas, uma em oferta), compra com nível mínimo e venda de itens/tesouros.
// Regras em EstadoJogo (garantirEstoque/comprar/venderTesouros), espelho do bloco LOJA de play/index.html.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/catalogo.dart';
import '../dominio/loja.dart';
import '../dominio/regras.dart' show bonusItem, precoVenda;
import 'estado_jogo.dart';
import 'folhas.dart';
import 'tela_inventario.dart';
import 'tema.dart';

class TelaLoja extends StatefulWidget {
  const TelaLoja({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaLoja> createState() => _TelaLojaState();
}

class _TelaLojaState extends State<TelaLoja> {
  String _aba = 'comprar';
  String? _aviso;

  EstadoJogo get e => widget.estado;

  @override
  void initState() {
    super.initState();
    e.garantirEstoque();
  }

  void _avisar(String t) {
    setState(() => _aviso = t);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _aviso == t) setState(() => _aviso = null);
    });
  }

  String _efeito(ItemCatalogo it) {
    final b = bonusItem(it);
    final p = <String>[];
    if (it.tipo == 'cons') {
      if (b.x != 0) p.add('+${b.x} XP');
      if (b.m != 0) p.add('+${b.m} moedas');
      if (it.cura != 0) p.add('+${it.cura} vida');
    } else {
      if (b.x != 0) p.add('XP ${b.x > 0 ? '+' : ''}${b.x}%');
      if (b.m != 0) p.add('Moedas ${b.m > 0 ? '+' : ''}${b.m}%');
    }
    return p.join(' · ');
  }

  void _comprar(int i) {
    final v = e.lojaEstoque[i];
    final it = e.catalogo.item(v.id)!;
    final exigido = nivelMinimo(it.raridade);
    final preco = e.precoNaLoja(v);
    abrirFolha<void>(
      context,
      (ctx) => Folha(titulo: 'Comprar', filhos: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(14), border: Border.all(color: corRaridade[it.raridade.clamp(0, 7)])),
            child: SpriteItem(estado: e, item: it, tamanho: 54),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.nomeNoIdioma(e.idioma), style: TextStyle(color: corRaridade[it.raridade.clamp(0, 7)], fontWeight: FontWeight.w700, fontSize: 16)),
              Text('${nomeRaridade(it.raridade, e.idioma)} · ${it.tipo}', style: const TextStyle(color: corApagado, fontSize: 13)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        if (_efeito(it).isNotEmpty) Text(_efeito(it), style: const TextStyle(color: corSuave, fontSize: 14)),
        const SizedBox(height: 4),
        Text('Preço: $preco moedas${v.oferta ? ' (oferta do dia)' : ''}', style: const TextStyle(color: corApagado, fontSize: 13)),
        Text('Exige nível ${romano(exigido)}', style: const TextStyle(color: corApagado, fontSize: 13)),
        const SizedBox(height: 14),
        BotaoFolha('Comprar por $preco', aoTocar: () {
          final r = e.comprar(i);
          Navigator.pop(ctx);
          HapticFeedback.mediumImpact();
          _avisar(switch (r) {
            'ok' => 'Comprou ${it.nomeNoIdioma(e.idioma)}',
            'nivel' => 'Exige nível ${romano(exigido)}',
            'moedas' => 'Moedas insuficientes',
            _ => 'Item indisponível',
          });
        }),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: e,
      builder: (_, __) {
        e.garantirEstoque();
        return SafeArea(
          bottom: false,
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(child: Text('Loja', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
                  Text('${e.save.moedas.toInt()} moedas', style: const TextStyle(fontWeight: FontWeight.w700, color: corOuro)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  for (final (id, nome) in const [('comprar', 'Comprar'), ('vender', 'Vender')])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(label: Text(nome), selected: _aba == id, showCheckmark: false, onSelected: (_) => setState(() => _aba = id)),
                    ),
                ]),
                const SizedBox(height: 10),
                Expanded(child: _aba == 'comprar' ? _prateleira() : _venda()),
              ]),
            ),
            if (_aviso != null)
              Positioned(
                left: 24,
                right: 24,
                top: 60,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(999), border: Border.all(color: corLinha)),
                    child: Text(_aviso!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }

  Widget _prateleira() {
    final vagas = e.lojaEstoque;
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.15),
      itemCount: vagas.length,
      itemBuilder: (_, i) {
        final v = vagas[i];
        final it = e.catalogo.item(v.id)!;
        final vendido = e.lojaVendidos.contains(i);
        final travado = e.nivel < nivelMinimo(it.raridade);
        final cor = corRaridade[it.raridade.clamp(0, 7)];
        return GestureDetector(
          onTap: vendido ? null : () => _comprar(i),
          child: Opacity(
            opacity: vendido ? 0.35 : (travado ? 0.6 : 1),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(14), border: Border.all(color: cor.withValues(alpha: 0.8))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  SpriteItem(estado: e, item: it, tamanho: 38),
                  const Spacer(),
                  if (v.oferta) const Text('OFERTA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: corXpB)),
                ]),
                const Spacer(),
                Text(it.nomeNoIdioma(e.idioma), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.15)),
                const SizedBox(height: 3),
                Text(
                  vendido ? 'Vendido' : (travado ? 'Exige nível ${romano(nivelMinimo(it.raridade))}' : '${e.precoNaLoja(v)} moedas'),
                  style: TextStyle(fontSize: 12, color: travado ? corVida : corOuro),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _venda() {
    final itens = <(ItemCatalogo, int)>[];
    for (final sl in e.save.inventario) {
      final it = e.catalogo.item(sl['id']);
      if (it == null || (it.tipo == 'chave' && it.nome == 'Grimório')) continue;
      itens.add((it, ((sl['q'] as num?) ?? 1).toInt()));
    }
    final tesouros = e.tesourosDisponiveis();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (tesouros > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: BotaoFolha('Vender todos os tesouros ($tesouros)', aoTocar: () {
            final (qtd, total) = e.venderTesouros();
            HapticFeedback.mediumImpact();
            if (qtd > 0) _avisar('Vendeu $qtd tesouros  +$total moedas');
          }),
        ),
      Expanded(
        child: itens.isEmpty
            ? const Center(child: Text('Nada para vender.', style: TextStyle(color: corApagado)))
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: itens.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final (it, q) = itens[i];
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(14), border: Border.all(color: corRaridade[it.raridade.clamp(0, 7)].withValues(alpha: 0.6))),
                    child: Row(children: [
                      SpriteItem(estado: e, item: it, tamanho: 36),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${it.nomeNoIdioma(e.idioma)}${q > 1 ? '  ×$q' : ''}', style: const TextStyle(fontWeight: FontWeight.w600))),
                      GestureDetector(
                        onTap: () {
                          final p = e.venderItem(it.id);
                          HapticFeedback.mediumImpact();
                          if (p != null) _avisar('Vendido  +$p moedas');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          child: Text('${precoVenda(it.tipo, it.valor)}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }
}
