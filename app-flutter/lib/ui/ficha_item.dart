// Ficha do item (.isheet do original) e as telas da Forja dentro dela: escolha dos tesouros, roleta do
// encantamento (tira vertical que desacelera) e resultado "Atual / Novo". Espelha abrirFicha() (~8743),
// forjaRoleta() (~8910) e abrirForja() (~8943) de play/index.html; as regras ficam em EstadoJogo.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/catalogo.dart';
import '../dominio/economia.dart';
import '../dominio/forja.dart';
import '../dominio/loot.dart' show afixoRolar;
import '../dominio/regras.dart' show precoVenda;
import 'estado_jogo.dart';
import 'flutuante.dart';
import 'folhas.dart';
import 'itens_ui.dart';
import 'som.dart';
import 'tema.dart';

/// Abre a ficha de [item]. [origem] é o centro do ícone tocado na grade: é dali que sobem os avisos de usar e vender.
Future<void> abrirFichaItem(BuildContext context, EstadoJogo estado, ItemCatalogo item, {Offset? origem}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xB80A0712), // .sheetbg: rgba(10,7,18,.72)
      elevation: 0,
      builder: (_) => FichaItem(estado: estado, item: item, origem: origem),
    );

class FichaItem extends StatefulWidget {
  const FichaItem({super.key, required this.estado, required this.item, this.origem});
  final EstadoJogo estado;
  final ItemCatalogo item;
  final Offset? origem;
  @override
  State<FichaItem> createState() => _FichaItemState();
}

const _ordemTelas = {'item': 0, 'sel': 1, 'rol': 2, 'res': 3};

class _FichaItemState extends State<FichaItem> {
  late ItemCatalogo _item = widget.item;
  String _tela = 'item'; // item | sel | rol | res (TELAS_FICHA)
  bool _paraFrente = true;
  final List<int> _sel = [];
  Afixo? _novo;
  List<Afixo> _tira = const [];
  bool _travado = false; // um toque só nos botões do resultado
  final _chaveCaixa = GlobalKey();

  EstadoJogo get e => widget.estado;

  void _irPara(String tela) => setState(() {
        _paraFrente = _ordemTelas[tela]! >= _ordemTelas[_tela]!;
        _tela = tela;
      });

  Offset? get _ponto => widget.origem ?? (_chaveCaixa.currentContext == null ? null : centroDe(_chaveCaixa.currentContext!));

  bool get _grimorio => _item.tipo == 'chave' && _item.nome == 'Grimório';

  // ---------- ações da ficha ----------
  void _equipar() {
    HapticFeedback.mediumImpact();
    final ponto = _ponto;
    final ficou = e.equipar(_item.id);
    if (ficou != null) flutuanteTexto(context, ponto, ficou ? 'EQUIPADO' : 'DESEQUIPADO');
    Navigator.pop(context);
  }

  void _usar() {
    HapticFeedback.mediumImpact();
    final ponto = _ponto;
    final it = _item;
    if (e.usarItem(it.id) != null) {
      // mesma prioridade do original: vida, depois XP, depois moedas
      flutuanteTexto(context, ponto, it.cura != 0 ? '+${it.cura} HP' : (it.bonusXp != 0 ? '+${it.bonusXp.toInt()} XP' : '+${it.bonusMoedas.toInt()} MOEDAS'));
    }
    Navigator.pop(context);
  }

  void _vender() {
    HapticFeedback.mediumImpact();
    final ponto = _ponto;
    final preco = e.venderItem(_item.id);
    if (preco != null) flutuanteMoedas(context, ponto, preco);
    Navigator.pop(context);
  }

  // ---------- forja ----------
  void _forjar() {
    final it = _item;
    if (_sel.length < custoForja(it.rer)) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.heavyImpact();
    final novo = e.forjarSortear(it.id, List<int>.from(_sel));
    if (novo == null) return;
    // a tira é só enfeite: 28 encantamentos ao acaso e o sorteado na antepenúltima linha
    final r = math.Random();
    final tira = List<Afixo>.generate(_Roleta.linhas, (_) => afixoRolar(it.raridade, null, pNegForjaBase, r.nextDouble));
    tira[_Roleta.linhas - 3] = novo;
    setState(() {
      _novo = novo;
      _tira = tira;
    });
    _irPara('rol');
  }

  void _fecharForja(Afixo? afixo) {
    if (_travado) return;
    _travado = true;
    HapticFeedback.mediumImpact();
    final id = e.forjarConfirmar(_item.id, afixo);
    if (id == null) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _item = e.catalogo.item(id)!;
      _sel.clear();
      _novo = null;
      _travado = false;
    });
    _irPara('item');
  }

  // ---------- montagem ----------
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: e,
      builder: (ctx, _) {
        final it = _item;
        final forja = _tela != 'item';
        final mq = MediaQuery.of(ctx);
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: mq.size.height - mq.viewPadding.top - 12),
          padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + mq.viewPadding.bottom),
          decoration: const BoxDecoration(
            color: corFicha,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: corLinha, width: 0.8)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _Troca(
                chave: '${forja ? 'forja' : 'item'}-${it.id}',
                paraFrente: _paraFrente,
                child: CabecalhoItem(
                  key: forja ? null : _chaveCaixa,
                  estado: e,
                  item: it,
                  emLinha: forja,
                  etiqueta: forja ? 'Forja · ${nomeRaridade(it.raridade, e.idioma)}' : '${nomeRaridade(it.raridade, e.idioma)} · ${nomeTipo(it.tipo)}',
                ),
              ),
              const SizedBox(height: 13),
              _Troca(
                chave: '$_tela-${it.id}',
                paraFrente: _paraFrente,
                atraso: 0.13,
                child: switch (_tela) {
                  'sel' => _corpoSelecao(ctx, it),
                  'rol' => _Roleta(estado: e, tira: _tira, aoTerminar: () => _irPara('res')),
                  'res' => _corpoResultado(it),
                  _ => _corpoItem(it),
                },
              ),
              const SizedBox(height: 15),
              _Troca(
                chave: '${_tela == 'rol' ? 'sel' : _tela}-${it.id}',
                paraFrente: _paraFrente,
                atraso: 0.23,
                child: _acoes(it),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _corpoItem(ItemCatalogo it) {
    final q = e.quantidadeDe(it.id);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (rotulo, valor) in bonusDoItem(it)) _LinhaBonus(rotulo: rotulo, valor: valor),
      if (slotsEquip.contains(it.tipo) && it.afixo != null) _LinhaBonus(afixo: it.afixo),
      const _Separador(),
      if (it.tipo == 'chave' && !_grimorio)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Text('Usada automaticamente pra destrancar um baú trancado na Arena',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: corApagado, height: 1.26)),
        ),
      if (!_grimorio) _LinhaApagada('Vende por', '${precoVenda(it.tipo, it.valor)} moedas'),
      if (q > 1) _LinhaApagada('Quantidade', '$q'),
    ]);
  }

  Widget _corpoSelecao(BuildContext ctx, ItemCatalogo it) {
    final custo = custoForja(it.rer);
    final tesouros = <(ItemCatalogo, int)>[];
    for (final sl in e.save.inventario) {
      final t = e.catalogo.item(sl['id']);
      if (t != null && t.tipo == 'tesouro') tesouros.add((t, ((sl['q'] as num?) ?? 0).toInt()));
    }
    // mais raro primeiro, depois o de maior valor; empate mantém a ordem do inventário
    final ordem = [for (var i = 0; i < tesouros.length; i++) i]
      ..sort((a, b) {
        final x = tesouros[a].$1, y = tesouros[b].$1;
        var c = y.raridade.compareTo(x.raridade);
        if (c == 0) c = y.valor.compareTo(x.valor);
        return c != 0 ? c : a.compareTo(b);
      });
    final pronto = _sel.length == custo;
    final alturaGrade = (MediaQuery.of(ctx).size.height - 560).clamp(96.0, 176.0);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _Separador(texto: 'Encantamento atual'),
      _LinhaAfixo(estado: e, afixo: it.afixo, estilo: _EstiloLinha.atual),
      const _Separador(),
      _Separador(texto: 'Ofereça $custo ${custo > 1 ? 'tesouros' : 'tesouro'}'),
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var k = 0; k < custo; k++) ...[
            if (k > 0) const SizedBox(width: 10),
            GestureDetector(
              onTap: k < _sel.length ? () => setState(() => _sel.removeAt(k)) : null,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: corPoco, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 1.6)),
                child: k < _sel.length ? Sprite(estado: e, sprite: e.catalogo.item(_sel[k])!.sprite, tamanho: 32, clarear: false) : null,
              ),
            ),
          ],
        ]),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 6),
        child: Text(
          pronto ? 'Chance de maldição: ${(pNegForja(e.catalogo, _sel) * 100).round()}%' : 'Toque nos tesouros abaixo pra escolher',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: corApagado, height: 1.26),
        ),
      ),
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alturaGrade),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(2),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
              for (final i in ordem)
                Builder(builder: (_) {
                  final (t, q) = tesouros[i];
                  final usados = _sel.where((x) => x == t.id).length;
                  final pode = usados < q && _sel.length < custo;
                  return GestureDetector(
                    onTap: pode
                        ? () {
                            HapticFeedback.selectionClick();
                            setState(() => _sel.add(t.id));
                          }
                        : null,
                    child: Opacity(
                      opacity: pode ? 1 : 0.3,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: corPoco,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: corRaridade[t.raridade.clamp(0, 7)], width: 1.6),
                        ),
                        child: Stack(alignment: Alignment.center, children: [
                          SpriteItem(estado: e, item: t, tamanho: 32),
                          Positioned(right: 3, bottom: 1, child: Text('${q - usados}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: corTexto, height: 1.28))),
                        ]),
                      ),
                    ),
                  );
                }),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _corpoResultado(ItemCatalogo it) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const _Separador(texto: 'Atual'),
        _LinhaAfixo(estado: e, afixo: it.afixo, estilo: _EstiloLinha.atual),
        _Separador(texto: 'Novo · ${nomeAfixo(_novo!)}'),
        _Pulso(child: _LinhaAfixo(estado: e, afixo: _novo, estilo: _EstiloLinha.escolhida, novo: true)),
      ]);

  Widget _acoes(ItemCatalogo it) {
    final q = e.quantidadeDe(it.id);
    final equip = slotsEquip.contains(it.tipo);
    final botoes = switch (_tela) {
      'sel' || 'rol' => [
          _BotaoFicha(_tela == 'rol' ? 'Forjando…' : 'Forjar',
              primario: true, opacidade: _tela == 'rol' ? 0.4 : (_sel.length == custoForja(it.rer) ? 1 : 0.45), aoTocar: _tela == 'rol' ? null : _forjar),
          _BotaoFicha('Voltar', opacidade: _tela == 'rol' ? 0.4 : 1, aoTocar: _tela == 'rol' ? null : () => _irPara('item')),
        ],
      'res' => [
          _BotaoFicha('Ficar com o novo', primario: true, aoTocar: () => _fecharForja(_novo)),
          _BotaoFicha('Manter atual', aoTocar: () => _fecharForja(it.afixo)),
        ],
      _ => [
          if (equip && q > 0) _BotaoFicha(e.equipado(it.id) ? 'Desequipar' : 'Equipar', primario: true, aoTocar: _equipar),
          if (it.tipo == 'cons' && q > 0) _BotaoFicha('Usar', primario: true, aoTocar: _usar),
          if (equip && q > 0)
            _BotaoFicha('Forjar', aoTocar: () {
              _sel.clear();
              _irPara('sel');
            }),
          if (!_grimorio && q > 0) _BotaoFicha('Vender', primario: true, aoTocar: _vender),
        ],
    };
    return Row(children: [
      for (var i = 0; i < botoes.length; i++) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: botoes[i])],
    ]);
  }
}

/// Troca de tela da ficha (`fichaTransicao`): a parte nova entra deslizando 26px e clareando; a antiga some na hora.
class _Troca extends StatelessWidget {
  const _Troca({required this.chave, required this.paraFrente, required this.child, this.atraso = 0});
  final String chave;
  final bool paraFrente;
  final Widget child;

  /// Fração da duração em que esta parte espera para começar (o corpo e os botões entram um pouco depois).
  final double atraso;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 440),
        reverseDuration: Duration.zero,
        layoutBuilder: (atual, _) => atual ?? const SizedBox.shrink(),
        transitionBuilder: (filho, anim) {
          final curva = CurvedAnimation(parent: anim, curve: Interval(atraso, (atraso + 0.77).clamp(0.0, 1.0), curve: const Cubic(0.2, 0.8, 0.2, 1)));
          return AnimatedBuilder(
            animation: curva,
            builder: (_, f) => Opacity(
              opacity: curva.value.clamp(0.0, 1.0),
              child: Transform.translate(offset: Offset((paraFrente ? 26 : -26) * (1 - curva.value), 0), child: f),
            ),
            child: filho,
          );
        },
        child: KeyedSubtree(key: ValueKey(chave), child: child),
      );
}

/// Botão da ficha (.iacts button): branco (primário) ou cinza com borda clara (Forjar, Voltar, Manter atual).
class _BotaoFicha extends StatelessWidget {
  const _BotaoFicha(this.texto, {required this.aoTocar, this.primario = false, this.opacidade = 1});
  final String texto;
  final VoidCallback? aoTocar;
  final bool primario;
  final double opacidade;
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacidade,
        child: Toque(
          aoTocar: aoTocar,
          child: Container(
            height: 39.6,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: primario ? Colors.white : const Color(0xFF404040), // color-mix(accent 16%, poço)
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: primario ? Colors.white : const Color(0xA6FFFFFF), width: 0.8),
            ),
            child: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primario ? corFundo : Colors.white, height: 1.26)),
          ),
        ),
      );
}

/// Linha de bônus (.irow): "◆ +10% XP" centrado; com [afixo], o efeito do encantamento na cor dele.
class _LinhaBonus extends StatelessWidget {
  const _LinhaBonus({this.rotulo, this.valor, this.afixo});
  final String? rotulo;
  final String? valor;
  final Afixo? afixo;
  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 15, color: corTexto, height: 1.28);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(padding: EdgeInsets.only(left: 2), child: Text('◆', style: TextStyle(fontSize: 7, color: corApagado, height: 1.3))),
        const SizedBox(width: 6),
        if (afixo != null)
          Flexible(child: Text(efeitoAfixo(afixo!), style: base.copyWith(fontWeight: FontWeight.w600, color: corAfixo(afixo!))))
        else ...[
          Text(valor!, style: base.copyWith(fontWeight: FontWeight.w600, color: valor!.startsWith('-') ? corVida : corTexto, fontFeatures: algarismosFixos)),
          const SizedBox(width: 6),
          Text(rotulo!, style: base),
        ],
      ]),
    );
  }
}

/// Linha apagada (.irow.dim): "Vende por 23 moedas", "Quantidade 3".
class _LinhaApagada extends StatelessWidget {
  const _LinhaApagada(this.rotulo, this.valor);
  final String rotulo;
  final String valor;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(rotulo, style: const TextStyle(fontSize: 12, color: corApagado, height: 1.27)),
          const SizedBox(width: 5),
          Text(valor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: corApagado, height: 1.27, fontFeatures: algarismosFixos)),
        ]),
      );
}

/// Separador (.isep): risco fino; com [texto], o rótulo em maiúsculas embaixo do risco.
class _Separador extends StatelessWidget {
  const _Separador({this.texto});
  final String? texto;
  @override
  Widget build(BuildContext context) {
    if (texto == null) {
      return Container(margin: const EdgeInsets.only(top: 8, bottom: 4), height: 0.8, color: corLinha);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: corLinha, width: 0.8))),
      child: Text(texto!.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: corApagado, height: 1.28)),
    );
  }
}

enum _EstiloLinha { normal, atual, apagada, escolhida }

/// Linha de encantamento da forja (.rolRow): ícone numa caixa e o efeito na cor do encantamento.
class _LinhaAfixo extends StatelessWidget {
  const _LinhaAfixo({required this.estado, required this.afixo, required this.estilo, this.novo = false, this.naTira = false});
  final EstadoJogo estado;
  final Afixo? afixo;
  final _EstiloLinha estilo;
  final bool novo;

  /// Na tira da roleta as linhas têm 52px de altura (padding 4/8).
  final bool naTira;

  @override
  Widget build(BuildContext context) {
    final a = afixo;
    return Opacity(
      opacity: switch (estilo) { _EstiloLinha.atual => 0.7, _EstiloLinha.apagada => 0.5, _ => 1 },
      child: Container(
        height: naTira ? 52 : null,
        padding: naTira ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2.4) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: corPoco,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: switch (estilo) { _EstiloLinha.apagada => Colors.transparent, _EstiloLinha.escolhida => corTexto, _ => corLinha },
            width: 1.6,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: corFundo, borderRadius: BorderRadius.circular(12), border: Border.all(color: corLinha, width: 0.8)),
            child: a == null ? null : Sprite(estado: estado, sprite: spriteAfixo[a.tipo] ?? 1, tamanho: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              a == null ? 'Sem encantamento' : efeitoAfixo(a),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: a == null ? FontWeight.w500 : FontWeight.w600, color: a == null ? corApagado : corAfixo(a), height: 1.28),
            ),
          ),
          if (novo) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: corTexto, borderRadius: BorderRadius.circular(5)),
              child: const Text('NOVO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.9, color: corFundo, height: 1.25)),
            ),
          ],
        ]),
      ),
    );
  }
}

/// `@keyframes rolTrava`: um pulso (cresce 3,5% e volta, com um anel que se abre) quando o encantamento "trava".
class _Pulso extends StatelessWidget {
  const _Pulso({required this.child});
  final Widget child;
  static const raio = 14.0;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        builder: (_, t, filho) {
          final sobe = t < 0.4 ? t / 0.4 : 1 - (t - 0.4) / 0.6;
          final anel = (t / 0.4).clamp(0.0, 1.0);
          return Transform.scale(
            scale: 1 + 0.035 * sobe,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(raio),
                boxShadow: t < 0.4 ? [BoxShadow(color: corTexto.withValues(alpha: 0.55 * (1 - anel)), spreadRadius: 6 * anel)] : null,
              ),
              child: filho,
            ),
          );
        },
        child: child,
      );
}

/// Roleta (.rolJan): janela de 292px com uma tira de 28 linhas de 60px que desliza e desacelera até o sorteado
/// (antepenúltima linha) parar dentro da moldura do meio; a moldura pulsa e meio segundo depois vem o resultado.
class _Roleta extends StatefulWidget {
  const _Roleta({required this.estado, required this.tira, required this.aoTerminar});
  final EstadoJogo estado;
  final List<Afixo> tira;
  final VoidCallback aoTerminar;

  static const linhas = 28;
  static const passo = 60.0; // 52 da linha + 8 de vão
  static const alvo = -(linhas - 5) * passo;

  @override
  State<_Roleta> createState() => _RoletaState();
}

class _RoletaState extends State<_Roleta> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  bool _parou = false;
  int _ultima = 0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_tique);
    _c.forward().whenComplete(() async {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Som.atual.tocar('roletaFim');
      setState(() => _parou = true);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) widget.aoTerminar();
    });
  }

  double get _desloc => _Roleta.alvo * (1 - math.pow(1 - _c.value, 1.8));

  // um toque leve a cada linha que passa pela moldura (o "tick" do original)
  void _tique() {
    final linha = (-_desloc / _Roleta.passo).floor();
    if (linha != _ultima) {
      _ultima = linha;
      if (_c.value < 1) {
        HapticFeedback.selectionClick();
        Som.atual.tocar('roletaTick', progresso: _c.value);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moldura = Container(
      height: 52,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: corTexto, width: 1.6)),
    );
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _Separador(texto: 'Sorteando encantamento'),
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 292,
          child: Stack(clipBehavior: Clip.hardEdge, children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, filho) => Positioned(left: 0, right: 0, top: _desloc, height: _Roleta.linhas * _Roleta.passo, child: filho!),
              child: RepaintBoundary(
                child: Column(children: [
                  for (var i = 0; i < widget.tira.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LinhaAfixo(
                        estado: widget.estado,
                        afixo: widget.tira[i],
                        naTira: true,
                        estilo: _parou && i == _Roleta.linhas - 3 ? _EstiloLinha.normal : _EstiloLinha.apagada,
                      ),
                    ),
                ]),
              ),
            ),
            Positioned(left: 0, right: 0, top: 120, child: IgnorePointer(child: _parou ? _Pulso(child: moldura) : moldura)),
          ]),
        ),
      ),
    ]);
  }
}
