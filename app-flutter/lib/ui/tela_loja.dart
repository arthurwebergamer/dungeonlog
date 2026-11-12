// Aba Loja no visual do app original (#viewLoja): cabeçalho com "renova em Nh", pílula do saldo, abas
// Comprar/Vender, linhas dos itens (oferta do dia, travado por nível, esgotado, sem moedas) e a folha de
// confirmação. Medidas e cores do CSS computado de play/ em 390x844; regras em EstadoJogo
// (garantirEstoque/comprar/venderItem/venderTesouros), espelho do bloco LOJA de play/index.html (~9553 a 9790).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/catalogo.dart';
import '../dominio/economia.dart';
import '../dominio/loja.dart';
import '../dominio/regras.dart' show afixoSoma, precoVenda;
import 'estado_jogo.dart';
import 'flutuante.dart';
import 'folhas.dart';
import 'icones.dart';
import 'itens_ui.dart';
import 'tema.dart';
import 'topo.dart';

/// `horasAteVirar()`: quanto falta para a prateleira renovar (meia-noite).
String horasAteVirar([DateTime? agora]) {
  final a = agora ?? DateTime.now();
  final meiaNoite = DateTime(a.year, a.month, a.day + 1);
  final h = (meiaNoite.difference(a).inMilliseconds / 3600000).ceil();
  return h <= 1 ? 'renova em menos de 1h' : 'renova em ${h}h';
}

/// Folha "Comprar / Vender" com o item no meio (`pedirConfirmacao` com item). Devolve true se confirmou.
Future<bool?> pedirConfirmacaoItem(BuildContext context, EstadoJogo estado, ItemCatalogo item, {required String verbo, required String texto}) =>
    abrirFolhaDesfocada<bool>(
      context,
      (ctx) => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 8, 16, 18 + MediaQuery.of(ctx).viewPadding.bottom),
        decoration: const BoxDecoration(
          color: corFicha,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: corFichaLinha, width: 0.8)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 6),
          Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: corFichaLinha, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Text(verbo.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.54, color: corApagado, height: 1.3)),
          const SizedBox(height: 4),
          CabecalhoItem(
            estado: estado,
            item: item,
            etiqueta: '${nomeRaridade(item.raridade, estado.idioma)} · ${nomeTipo(item.tipo)}',
            bordaCaixa: corRaridade[item.raridade.clamp(0, 7)],
          ),
          const SizedBox(height: 12),
          Text(texto, style: const TextStyle(fontSize: 13, height: 1.5, color: corApagado)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: BotaoFolha('Cancelar', fundo: corPoco, cor: corTexto, borda: corFichaLinha, tamanho: 14, aoTocar: () => Navigator.pop(ctx, false))),
            const SizedBox(width: 9),
            Expanded(child: BotaoFolha(verbo, tamanho: 14, borda: Colors.white, aoTocar: () => Navigator.pop(ctx, true))),
          ]),
        ]),
      ),
    );

class TelaLoja extends StatefulWidget {
  const TelaLoja({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<TelaLoja> createState() => _TelaLojaState();
}

class _TelaLojaState extends State<TelaLoja> {
  String _aba = 'comprar';

  EstadoJogo get e => widget.estado;

  @override
  void initState() {
    super.initState();
    e.garantirEstoque();
  }

  Future<void> _comprar(int i, BuildContext caixa) async {
    final v = e.lojaEstoque[i];
    final it = e.catalogo.item(v.id)!;
    HapticFeedback.selectionClick();
    final ok = await pedirConfirmacaoItem(context, e, it, verbo: 'Comprar', texto: 'Custa ${e.precoNaLoja(v)} moedas.');
    if (ok != true || !mounted) return;
    final ponto = caixa.mounted ? centroDe(caixa) : null;
    if (e.comprar(i) == 'ok') {
      HapticFeedback.mediumImpact();
      flutuanteTexto(context, ponto, 'COMPROU ${it.nomeNoIdioma(e.idioma).toUpperCase()}');
    }
  }

  Future<void> _vender(ItemCatalogo it, BuildContext caixa) async {
    HapticFeedback.selectionClick();
    final ok = await pedirConfirmacaoItem(context, e, it, verbo: 'Vender', texto: 'Você recebe ${precoVenda(it.tipo, it.valor)} moedas.');
    if (ok != true || !mounted) return;
    final ponto = caixa.mounted ? centroDe(caixa) : null; // antes de a lista redesenhar
    final preco = e.venderItem(it.id);
    if (preco != null) {
      HapticFeedback.mediumImpact();
      flutuanteMoedas(context, ponto, preco);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        e.garantirEstoque();
        final t = e.dados.traducoes;
        final legenda = _aba == 'comprar' ? horasAteVirar() : (e.save.inventario.isEmpty ? '' : 'Recompra por ${(Eco.taxaVenda * 100).round()}% do valor');
        return SafeArea(
          bottom: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TopoApp(estado: e),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                children: [
                  CabecalhoAba(t.t('nav.loja', e.idioma), legenda),
                  const SizedBox(height: 14),
                  Row(children: [
                    _Saldo(moedas: e.save.moedas.toInt(), rotulo: t.t('inv.moedasMinusculo', e.idioma)),
                    const Spacer(),
                    PilulaFiltro(t.t('loja.comprar', e.idioma), ativa: _aba == 'comprar', aoTocar: () => setState(() => _aba = 'comprar')),
                    const SizedBox(width: 6),
                    PilulaFiltro(t.t('loja.vender', e.idioma), ativa: _aba == 'vender', aoTocar: () => setState(() => _aba = 'vender')),
                  ]),
                  const SizedBox(height: 12),
                  ...(_aba == 'comprar' ? _compra() : _venda()),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  /// `textoBonus(it)`: "XP +5% · Moedas +3%" (equipamento) ou "+15 XP · +10 moedas" (consumível).
  InlineSpan? _bonus(ItemCatalogo it) {
    const forte = TextStyle(fontWeight: FontWeight.w600, color: corSuave);
    final partes = <List<InlineSpan>>[];
    for (final (rotulo, valor) in bonusDoItem(it)) {
      if (it.tipo == 'cons') {
        if (rotulo == 'HP') continue; // o original só lista XP e moedas na loja
        partes.add(rotulo == 'XP' ? [TextSpan(text: '$valor XP', style: forte)] : [TextSpan(text: valor, style: forte), const TextSpan(text: ' moedas')]);
      } else {
        partes.add([TextSpan(text: '$rotulo '), TextSpan(text: valor, style: forte)]);
      }
    }
    if (partes.isEmpty) return null;
    return TextSpan(children: [
      for (var i = 0; i < partes.length; i++) ...[if (i > 0) const TextSpan(text: ' · '), ...partes[i]],
    ]);
  }

  List<Widget> _compra() {
    final linhas = <Widget>[];
    for (var i = 0; i < e.lojaEstoque.length; i++) {
      final v = e.lojaEstoque[i];
      final it = e.catalogo.item(v.id)!;
      final preco = e.precoNaLoja(v);
      final exigido = nivelMinimo(it.raridade);
      final vendido = e.lojaVendidos.contains(i);
      final travado = e.nivel < exigido;
      final semGrana = e.save.moedas < preco;
      final bloqueio = vendido ? 'Esgotado' : (travado ? 'Nível ${romano(exigido)}' : (semGrana ? 'Sem moedas' : null));
      linhas.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _LinhaLoja(
          estado: e,
          item: it,
          oferta: v.oferta,
          opacidade: vendido ? 0.38 : (travado ? 0.5 : 1),
          bonus: _bonus(it),
          precoCheio: v.oferta ? precoLoja(it, false, desconto: descontoLoja(afixoSoma(e.catalogo, e.save.equipado, 'bar'))) : null,
          preco: '$preco',
          botao: bloqueio ?? 'Comprar',
          estiloBotao: bloqueio == null ? _EstiloBotao.primario : _EstiloBotao.apagado,
          aoTocar: bloqueio == null ? (caixa) => _comprar(i, caixa) : (_) => HapticFeedback.lightImpact(),
        ),
      ));
    }
    return linhas;
  }

  List<Widget> _venda() {
    const nota = TextStyle(fontSize: 11.5, height: 1.5, color: corApagado);
    if (e.save.inventario.isEmpty) {
      return const [Padding(padding: EdgeInsets.only(top: 14, bottom: 4), child: Text('Mochila vazia. Derrote o monstro do dia para conseguir espólio.', textAlign: TextAlign.center, style: nota))];
    }
    final itens = <(ItemCatalogo, int)>[];
    for (final sl in e.save.inventario) {
      final it = e.catalogo.item(sl['id']);
      if (it == null || (it.tipo == 'chave' && it.nome == 'Grimório')) continue;
      itens.add((it, ((sl['q'] as num?) ?? 1).toInt()));
    }
    if (itens.isEmpty) {
      return const [Padding(padding: EdgeInsets.only(top: 14, bottom: 4), child: Text('Só há itens-chave na mochila. Eles não podem ser vendidos.', textAlign: TextAlign.center, style: nota))];
    }
    // tesouros primeiro, depois o mais raro; empate mantém a ordem da mochila
    final ordem = [for (var i = 0; i < itens.length; i++) i]
      ..sort((a, b) {
        final x = itens[a].$1, y = itens[b].$1;
        if ((x.tipo == 'tesouro') != (y.tipo == 'tesouro')) return x.tipo == 'tesouro' ? -1 : 1;
        final r = y.raridade.compareTo(x.raridade);
        return r != 0 ? r : a.compareTo(b);
      });
    var totalTesouros = 0;
    var temTesouro = false;
    for (final (it, q) in itens) {
      if (it.tipo == 'tesouro') {
        temTesouro = true;
        totalTesouros += precoVenda(it.tipo, it.valor) * q;
      }
    }
    return [
      for (final i in ordem)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _LinhaLoja(
            estado: e,
            item: itens[i].$1,
            quantidade: itens[i].$2,
            bonus: itens[i].$2 == 1 && e.equipado(itens[i].$1.id) ? const TextSpan(text: 'em uso — será desequipado') : null,
            preco: '+${precoVenda(itens[i].$1.tipo, itens[i].$1.valor)}',
            botao: 'Vender',
            estiloBotao: _EstiloBotao.secundario,
            aoTocar: (caixa) => _vender(itens[i].$1, caixa),
          ),
        ),
      if (temTesouro)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Toque(
            aoTocar: () {
              HapticFeedback.mediumImpact();
              e.venderTesouros();
            },
            child: CustomPaint(
              painter: const _Tracejado(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('Vender todos os tesouros  ·  +$totalTesouros moedas',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: corOuro, height: 1.3)),
              ),
            ),
          ),
        ),
    ];
  }
}

/// Pílula do saldo (.saldo): pilha de moedas, número e "moedas".
class _Saldo extends StatelessWidget {
  const _Saldo({required this.moedas, required this.rotulo});
  final int moedas;
  final String rotulo;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0x1AF5BE4A),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x38F5BE4A), width: 0.8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          pixel('assets/img/ui/moedas.png', largura: 28, altura: 28),
          const SizedBox(width: 5),
          Text('$moedas', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: corOuro, height: 1.25)),
          const SizedBox(width: 5),
          Text(rotulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: corOuro, height: 1.25)),
        ]),
      );
}

enum _EstiloBotao { primario, secundario, apagado }

/// Linha da loja (.lrow): caixa do ícone, nome / raridade / bônus, preço com a moeda e o botão.
class _LinhaLoja extends StatefulWidget {
  const _LinhaLoja({
    required this.estado,
    required this.item,
    required this.preco,
    required this.botao,
    required this.estiloBotao,
    required this.aoTocar,
    this.oferta = false,
    this.opacidade = 1,
    this.bonus,
    this.precoCheio,
    this.quantidade = 1,
  });
  final EstadoJogo estado;
  final ItemCatalogo item;
  final String preco;
  final String botao;
  final _EstiloBotao estiloBotao;

  /// Recebe o contexto da caixa do ícone (de onde sobe o aviso flutuante).
  final void Function(BuildContext caixa) aoTocar;
  final bool oferta;
  final double opacidade;
  final InlineSpan? bonus;
  final int? precoCheio;
  final int quantidade;

  @override
  State<_LinhaLoja> createState() => _LinhaLojaState();
}

class _LinhaLojaState extends State<_LinhaLoja> {
  final _caixa = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final estado = widget.estado, item = widget.item, oferta = widget.oferta, bonus = widget.bonus;
    final precoCheio = widget.precoCheio, quantidade = widget.quantidade, preco = widget.preco, botao = widget.botao;
    final cor = corRaridade[item.raridade.clamp(0, 7)];
    final (fundoBotao, bordaBotao, textoBotao) = switch (widget.estiloBotao) {
      _EstiloBotao.primario => (Colors.white, Colors.white, corFundo),
      _EstiloBotao.secundario => (corPoco, corLinha, corSuave),
      _EstiloBotao.apagado => (corPoco, corLinha, corApagado),
    };
    return Opacity(
      opacity: widget.opacidade,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: corPainel3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: oferta ? corOuro : corLinha, width: 0.8),
            boxShadow: oferta ? const [BoxShadow(color: Color(0x24F2C94C), blurRadius: 10)] : null,
          ),
          child: Row(children: [
            CaixaItem(key: _caixa, estado: estado, item: item, lado: 46, sprite: 32, raio: 10),
            const SizedBox(width: 11),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: item.nomeNoIdioma(estado.idioma)),
                    if (quantidade > 1) TextSpan(text: ' ×$quantidade', style: const TextStyle(fontSize: 11, color: corApagado)),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: corTexto, height: 1.25),
                ),
                const SizedBox(height: 2),
                Text('${nomeRaridade(item.raridade, estado.idioma)} · ${nomeTipo(item.tipo)}'.toUpperCase(),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: cor, height: 1.28)),
                if (bonus != null) ...[
                  const SizedBox(height: 3),
                  Text.rich(bonus, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: corApagado, height: 1.3)),
                ],
              ]),
            ),
            const SizedBox(width: 11),
            Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: 24,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (precoCheio != null) ...[
                    Text('$precoCheio',
                        style: const TextStyle(
                            fontSize: 10.5, fontWeight: FontWeight.w500, color: corApagado, decoration: TextDecoration.lineThrough, decorationColor: corApagado, fontFeatures: algarismosFixos)),
                    const SizedBox(width: 4),
                  ],
                  Text(preco, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: corOuro, fontFeatures: algarismosFixos)),
                  const SizedBox(width: 2),
                  pixel('assets/img/ui/moedas.png', largura: 24, altura: 24),
                ]),
              ),
              const SizedBox(height: 5),
              Toque(
                aoTocar: () => widget.aoTocar(_caixa.currentContext ?? context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: fundoBotao, borderRadius: BorderRadius.circular(9), border: Border.all(color: bordaBotao, width: 0.8)),
                  child: Text(botao, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textoBotao, height: 1.27)),
                ),
              ),
            ]),
          ]),
        ),
        if (oferta)
          Positioned(
            left: 11,
            top: -7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: corOuro, borderRadius: BorderRadius.circular(999)),
              child: const Text('OFERTA DO DIA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.72, color: corFundo, height: 1.25)),
            ),
          ),
      ]),
    );
  }
}

/// Fundo do botão "Vender todos os tesouros" (.lbulk): poço com borda tracejada.
class _Tracejado extends CustomPainter {
  const _Tracejado();
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.4), const Radius.circular(11));
    canvas.drawRRect(r, Paint()..color = corPoco);
    final traco = Paint()
      ..color = corLinha
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final m in (Path()..addRRect(r)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 4.8) {
        canvas.drawPath(m.extractPath(d, (d + 2.4).clamp(0, m.length)), traco);
      }
    }
  }

  @override
  bool shouldRepaint(_Tracejado oldDelegate) => false;
}
