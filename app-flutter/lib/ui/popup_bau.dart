// Pop-up "Baú do Tesouro" (mostrarBauLoot do original, ~12443): folha que sobe com o baú que foi tocado, que
// "abre" meio segundo depois, e os itens entrando um a um. Medidas e cores do CSS computado de play/ (.baupop).
import 'package:flutter/material.dart';

import '../dominio/catalogo.dart';
import 'estado_jogo.dart';
import 'folhas.dart';
import 'itens_ui.dart';
import 'sheet_md.dart' show FilaPopups;
import 'particulas.dart';
import 'tema.dart';

/// Imagem do baú: [variante] é 'padrao' ou 't0'..'t3' (tier do baú trancado).
String imagemBau(String variante, {required bool aberto}) => 'assets/img/baus/${variante}_${aberto ? 'aberto' : 'fechado'}.png';

/// Mostra o que saiu do baú. [variante]: 'padrao' (baú do dia e baú extra) ou 't0'..'t3'.
Future<void> mostrarBauLoot(BuildContext context, EstadoJogo estado, List<ItemCatalogo> ganhos, {String variante = 'padrao'}) {
  if (ganhos.isEmpty) return Future.value();
  // na fila dos popups: não abre por cima de "subiu de nível", estágio, resumo etc.
  return FilaPopups.enfileirar(() async {
    if (!context.mounted) return;
    await abrirFolhaDesfocada<void>(
      context,
      (_) => _PopupBau(estado: estado, ganhos: ganhos, variante: variante),
      desfoque: 5,
      veu: const Color(0x8C000000), // .baubg: rgba(0,0,0,.55)
    );
  });
}

class _PopupBau extends StatefulWidget {
  const _PopupBau({required this.estado, required this.ganhos, required this.variante});
  final EstadoJogo estado;
  final List<ItemCatalogo> ganhos;
  final String variante;
  @override
  State<_PopupBau> createState() => _PopupBauState();
}

class _PopupBauState extends State<_PopupBau> with SingleTickerProviderStateMixin {
  // 0 a 550 ms: baú fechado; depois abre com um pulo (0,4 s) e os cartões entram a cada 130 ms (0,32 s cada)
  static const _espera = 550;
  late final int _total = _espera + 400 + widget.ganhos.length * 130 + 320;
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: _total))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _trecho(int inicioMs, int duracaoMs) => ((_c.value * _total - inicioMs) / duracaoMs).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.86),
      padding: EdgeInsets.fromLTRB(20, 30, 20, 22 + MediaQuery.of(context).viewPadding.bottom),
      decoration: const BoxDecoration(
        color: corPainel2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: corLinha, width: 0.8)),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        const Positioned.fill(child: ExplosaoParticulas()),
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: corLinha, borderRadius: BorderRadius.circular(2)))),
        ),
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final abriu = _c.value * _total >= _espera;
            final pulo = _trecho(_espera, 400);
            // @keyframes bauPulo: 0% normal, 45% scale(1.2) rotate(-4deg), 100% normal (ease)
            final p = Curves.ease.transform(pulo);
            final sobe = p < 0.45 ? p / 0.45 : 1 - (p - 0.45) / 0.55;
            return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(
                child: Transform.rotate(
                  angle: -0.0698 * sobe,
                  child: Transform.scale(
                    scale: 1 + 0.2 * sobe,
                    child: Image.asset(imagemBau(widget.variante, aberto: abriu), width: 68, height: 68, filterQuality: FilterQuality.none, gaplessPlayback: true),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('BAÚ DO TESOURO', textAlign: TextAlign.center, style: TextStyle(fontFamily: fontePixel, fontSize: 11, letterSpacing: 1.5, color: Colors.white, height: 1.25)),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (var i = 0; i < widget.ganhos.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      Builder(builder: (_) {
                        final t = Curves.ease.transform(_trecho(_espera + i * 130, 320));
                        return Opacity(
                          opacity: t,
                          child: Transform.translate(offset: Offset(0, 6 * (1 - t)), child: _CartaoGanho(estado: e, item: widget.ganhos[i])),
                        );
                      }),
                    ],
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              BotaoFolha('Continuar', raio: 11, tamanho: 13, padding: 10.7, aoTocar: () => Navigator.pop(context)),
            ]);
          },
        ),
      ]),
    );
  }
}

/// Cartão de um item ganho (.baucard): caixinha escura com o sprite, nome, raridade e o encantamento.
class _CartaoGanho extends StatelessWidget {
  const _CartaoGanho({required this.estado, required this.item});
  final EstadoJogo estado;
  final ItemCatalogo item;
  @override
  Widget build(BuildContext context) {
    final cor = corRaridade[item.raridade.clamp(0, 7)];
    final a = item.afixo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 0.8)),
      child: Row(children: [
        CaixaItem(estado: estado, item: item, lado: 34, sprite: 22, raio: 8, borda: null),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(item.nomeNoIdioma(estado.idioma), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: corTexto, height: 1.24)),
            const SizedBox(height: 1),
            Text(nomeRaridade(item.raridade, estado.idioma).toUpperCase(), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.525, color: cor, height: 1.22)),
            if (a != null) ...[
              const SizedBox(height: 2),
              Text('${nomeAfixo(a)} · ${efeitoAfixo(a)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: corAfixo(a), height: 1.27)),
            ],
          ]),
        ),
      ]),
    );
  }
}
