// Telas cheias do Perfil que contam a história do herói: Conquistas (V2, lista plana com data), Bestiário (grade dos 63
// monstros, silhueta para os não descobertos), Grimório (catálogo dos itens) e as fichas curtas de monstro e de item.
// Medidas do CSS computado de play/ em 390x844 (renderConquistasV2, renderBestiario, renderGrimorio, abrirFicha*).
import 'package:flutter/material.dart';

import '../dominio/conquistas.dart';
import '../dominio/historico.dart';
import '../dominio/regras.dart' show bonusItem;
import '../dominio/economia.dart' show slotsEquip;
import 'cfg_base.dart';
import 'icones.dart' show pixel;
import 'estado_jogo.dart';
import 'folhas.dart';
import 'itens_ui.dart';
import 'tema.dart';

// ---------------------------------------------------------------- Conquistas
void abrirConquistas(BuildContext context, EstadoJogo e) {
  // `renderConquistasV2()`: confere o que acabou de bater e só depois marca tudo como visto
  if (e.checarConquistas()) e.persistir();
  final vistasAntes = {...e.conqVistas};
  abrirTelaCfg<void>(context, (_) => _TelaConquistas(estado: e, vistasAntes: vistasAntes));
  // abrir a tela = "marcar como visto" (a etiqueta NOVO usa o conjunto de antes)
  WidgetsBinding.instance.addPostFrameCallback((_) => e.marcarConquistasVistas());
}

class _TelaConquistas extends StatelessWidget {
  const _TelaConquistas({required this.estado, required this.vistasAntes});
  final EstadoJogo estado;
  final Set<String> vistasAntes;

  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final en = e.idioma == 'en';
        final ctx = e.contextoConquistas;
        final feitas = <(Conquista, String)>[];
        final faltam = <Conquista>[];
        for (final c in conquistasV2) {
          final d = e.conqDesbloq[c.id];
          if (d != null) {
            feitas.add((c, d));
          } else {
            faltam.add(c);
          }
        }
        // mais recente primeiro; a ordenação do JS é estável (empate mantém a ordem da lista)
        final pos = {for (var i = 0; i < feitas.length; i++) feitas[i].$1.id: i};
        feitas.sort((a, b) {
          final c = b.$2.compareTo(a.$2);
          return c != 0 ? c : pos[a.$1.id]!.compareTo(pos[b.$1.id]!);
        });
        Widget linha(Conquista c, String? data, bool novo, bool ultima) => _LinhaConquista(
              nome: c.nomeNoIdioma(e.idioma),
              desc: c.reqNoIdioma(e.idioma, ctx),
              data: data == null ? null : formatarDataBR(data),
              novo: novo,
              novoTexto: en ? 'NEW' : 'NOVO',
              trancada: data == null,
              ultima: ultima,
            );
        return CfgTela(
          titulo: tr(e, 'perfil.conquistas'),
          estado: e,
          filhos: [
            CfgSecao(en ? 'My achievements' : 'Minhas conquistas', primeira: true),
            if (feitas.isEmpty)
              _Vazio(en ? 'None yet -- keep playing!' : 'Nenhuma ainda -- continue jogando!')
            else
              for (var i = 0; i < feitas.length; i++) linha(feitas[i].$1, feitas[i].$2, !vistasAntes.contains(feitas[i].$1.id), false),
            CfgSecao(en ? 'Not unlocked' : 'Não desbloqueadas'),
            if (faltam.isEmpty)
              _Vazio(en ? 'You unlocked them all!' : 'Você desbloqueou todas!')
            else
              for (var i = 0; i < faltam.length; i++) linha(faltam[i], null, false, i == faltam.length - 1),
          ],
        );
      },
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio(this.texto);
  final String texto;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(texto, style: TextStyle(fontSize: 11.5, color: corApagado, height: 1.26)));
}

class _LinhaConquista extends StatelessWidget {
  const _LinhaConquista({required this.nome, required this.desc, required this.data, required this.novo, required this.novoTexto, required this.trancada, required this.ultima});
  final String nome;
  final String desc;
  final String? data;
  final bool novo;
  final String novoTexto;
  final bool trancada;
  final bool ultima;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(novo ? 9 : 2, 11, 2, 11),
      decoration: BoxDecoration(
        border: Border(
          left: novo ? BorderSide(color: corVida, width: 2.4) : BorderSide.none,
          bottom: ultima ? BorderSide.none : BorderSide(color: corLinha, width: 0.8),
        ),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Text(nome, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: trancada ? corSuave : corTexto, height: 1.24))),
              if (novo) ...[
                const SizedBox(width: 6),
                Container(
                  height: 15,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: corVida, borderRadius: BorderRadius.circular(999)),
                  child: Text(novoTexto, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.24, color: Colors.white, height: 1.2)),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            Text(desc, style: TextStyle(fontSize: 13, color: corSuave, height: 1.23)),
          ]),
        ),
        if (data != null) ...[
          const SizedBox(width: 12),
          Text(data!, style: TextStyle(fontFamily: fontePixel, fontSize: 9.5, color: corApagado)),
        ],
      ]),
    );
  }
}

// ---------------------------------------------------------------- Bestiário
void abrirBestiario(BuildContext context, EstadoJogo e) => abrirTelaCfg<void>(context, (_) => _TelaBestiario(estado: e));

/// Silhueta de um sprite ainda não descoberto: tudo preto a 32% (`filter:brightness(0);opacity:.32`).
Widget silhueta(Widget filho) => Opacity(
      opacity: 0.32,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]),
        child: filho,
      ),
    );

class _TelaBestiario extends StatelessWidget {
  const _TelaBestiario({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final en = e.idioma == 'en';
        final derrotados = e.monstrosDerrotadosIds;
        final total = e.dados.monstros.length;
        return CfgTela(
          titulo: tr(e, 'perfil.bestiario'),
          estado: e,
          filhos: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(en ? '${derrotados.length} of $total monsters defeated' : '${derrotados.length} de $total monstros derrotados',
                  style: TextStyle(fontSize: 12, color: corApagado, height: 1.26)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: total,
              itemBuilder: (_, i) {
                final m = e.dados.monstros[i];
                final ok = derrotados.contains(i);
                return Toque(
                  aoTocar: () => ok ? abrirFichaMonstro(context, e, i) : abrirFichaMonstroOculto(context, e, i),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                    decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 0.8)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 36, height: 36, child: ok ? pixel(m.img) : silhueta(pixel(m.img))),
                      if (ok) ...[
                        const SizedBox(height: 4),
                        Text(m.nomeNoIdioma(e.idioma), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: corSuave, height: 1.2)),
                      ],
                    ]),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- fichas curtas
/// Ficha só de leitura (`#ficha` do Grimório e do Bestiário): caixa do ícone, nome, linha de tipo, chips e "Fechar".
Future<void> abrirFichaCurta(
  BuildContext context, {
  required Widget caixa,
  required String nome,
  required String meta,
  Color? corMeta,
  required List<String> chips,
  required String fechar,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xB80A0712),
      elevation: 0,
      builder: (ctx) => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + MediaQuery.of(ctx).viewPadding.bottom),
        decoration: BoxDecoration(
          color: corFicha,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: corLinha, width: 0.8)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: corPoco, borderRadius: BorderRadius.circular(12), border: Border.all(color: corLinha, width: 0.8)),
              child: caixa,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(nome, style: estiloNomeItem(corTexto).copyWith(fontSize: 22, height: 1.15)),
                const SizedBox(height: 3),
                Text(meta.toUpperCase(), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.46, color: corMeta ?? corTexto, height: 1.25)),
              ]),
            ),
          ]),
          const SizedBox(height: 13),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in chips)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: corPoco, borderRadius: BorderRadius.circular(8), border: Border.all(color: corLinha, width: 0.8)),
                child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: corSuave, height: 1.25)),
              ),
          ]),
          const SizedBox(height: 15),
          Toque(
            aoTocar: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.alphaBlend(corAccent.withValues(alpha: 0.16), corPoco),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: corAccent.withValues(alpha: 0.65), width: 0.8),
              ),
              child: Text(fechar, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: corAccent, height: 1.25)),
            ),
          ),
        ]),
      ),
    );

/// `abrirFichaMonstro(idx)`: quantas vezes foi derrotado e a data da primeira.
Future<void> abrirFichaMonstro(BuildContext context, EstadoJogo e, int idx) {
  final en = e.idioma == 'en';
  final m = e.dados.monstros[idx];
  final f = fichaDoMonstro(e.hist, idx, hojeSeVencido: e.derrotado && e.monstroDoDiaIdx == idx ? e.hoje : null);
  return abrirFichaCurta(
    context,
    caixa: pixel(m.img, largura: 44, altura: 44),
    nome: m.nomeNoIdioma(e.idioma),
    meta: en ? 'Defeated ${f.vezes} ${f.vezes == 1 ? 'time' : 'times'}' : 'Derrotado ${f.vezes} ${f.vezes == 1 ? 'vez' : 'vezes'}',
    chips: [(en ? 'First time: ' : 'Primeira vez: ') + formatarDataBR(f.primeira)],
    fechar: en ? 'Close' : 'Fechar',
  );
}

/// Versão "mistério": o monstro ainda não derrotado aparece em silhueta e o resto vira "?".
Future<void> abrirFichaMonstroOculto(BuildContext context, EstadoJogo e, int idx) => abrirFichaCurta(
      context,
      caixa: silhueta(pixel(e.dados.monstros[idx].img, largura: 44, altura: 44)),
      nome: '?',
      meta: '?',
      chips: const ['?'],
      fechar: e.idioma == 'en' ? 'Close' : 'Fechar',
    );

// ---------------------------------------------------------------- Grimório
const _roxoFundo = Color(0xFF15111F);
const _roxoCelula = Color(0xFF201A32);
const _roxoBorda = Color(0xFF332A4D);

/// Catálogo de todos os itens: descobertos em cor e com a raridade, os outros em silhueta.
void abrirCatalogoGrimorio(BuildContext context, EstadoJogo e) => Navigator.of(context).push<void>(PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, __) => _TelaGrimorio(estado: e),
      transitionsBuilder: (_, a, __, f) => FadeTransition(opacity: a, child: f),
    ));

class _TelaGrimorio extends StatelessWidget {
  const _TelaGrimorio({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    final en = e.idioma == 'en';
    final cat = e.catalogo;
    final vivos = [for (var i = 0; i < cat.baseN; i++) if (!cat.item(i)!.morto) i];
    return Material(
      color: _roxoFundo,
      child: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(children: [
              Expanded(child: Text(tr(e, 'grim.titulo'), style: estiloNomeItem(const Color(0xFFEFEAFB)).copyWith(fontSize: 22, fontVariations: const [FontVariation('wght', 600)], height: 1.2))),
              Toque(
                aoTocar: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _roxoCelula, borderRadius: BorderRadius.circular(10), border: Border.all(color: _roxoBorda, width: 0.8)),
                  child: const Text('×', style: TextStyle(fontSize: 20, color: Color(0xFFEFEAFB), height: 1.2)),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(en ? '${e.itensVistos.length} of ${vivos.length} items discovered' : '${e.itensVistos.length} de ${vivos.length} itens descobertos',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7C7196), height: 1.26)),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final colunas = c.maxWidth >= 420 ? 5 : 4;
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(16, 6, 16, 24 + MediaQuery.of(context).viewPadding.bottom),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: colunas, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: vivos.length,
                itemBuilder: (_, k) {
                  final id = vivos[k];
                  final it = cat.item(id)!;
                  final desc = e.itensVistos.contains(id);
                  return Toque(
                    aoTocar: () => desc ? abrirFichaGrimorio(context, e, id) : abrirFichaGrimorioOculto(context, e, id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _roxoCelula,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: desc && it.raridade >= 5 ? corBordaRaridade[it.raridade.clamp(0, 7)] : _roxoBorda, width: 0.8),
                        boxShadow: desc ? brilhoRaridade(it.raridade) : null,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        desc ? SpriteItem(estado: e, item: it, tamanho: 36) : silhueta(SpriteItem(estado: e, item: it, tamanho: 36)),
                        if (desc) ...[
                          const SizedBox(height: 4),
                          Text(nomeRaridade(it.raridade, e.idioma).toUpperCase(),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.27, color: corRaridade[it.raridade.clamp(0, 7)], height: 1.25)),
                        ],
                      ]),
                    ),
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }
}

/// `abrirFichaGrimorio(id)`: nome, raridade e tipo, bônus (sem preço: o jogador pode nem ter mais o item).
Future<void> abrirFichaGrimorio(BuildContext context, EstadoJogo e, int id) {
  final it = e.catalogo.item(id)!;
  final en = e.idioma == 'en';
  final bi = bonusItem(it);
  final chips = <String>[];
  if (it.tipo == 'cons') {
    if (bi.x != 0) chips.add(en ? 'Grants ${bi.x} XP' : 'Concede ${bi.x} XP');
    if (bi.m != 0) chips.add(en ? 'Grants ${bi.m} coins' : 'Concede ${bi.m} moedas');
  } else if (slotsEquip.contains(it.tipo)) {
    if (bi.x != 0) chips.add('XP ${bi.x > 0 ? '+' : ''}${bi.x}%');
    if (bi.m != 0) chips.add('${en ? 'Coins ' : 'Moedas '}${bi.m > 0 ? '+' : ''}${bi.m}%');
  }
  if (chips.isEmpty) chips.add(en ? 'No equipment bonus' : 'Sem bônus de equipamento');
  return abrirFichaCurta(
    context,
    caixa: SpriteItem(estado: e, item: it, tamanho: 44),
    nome: it.nomeNoIdioma(e.idioma),
    meta: '${nomeRaridade(it.raridade, e.idioma)} · ${nomeTipo(it.tipo)}',
    corMeta: corRaridade[it.raridade.clamp(0, 7)],
    chips: chips,
    fechar: en ? 'Close' : 'Fechar',
  );
}

/// Versão "mistério" do item ainda não descoberto: só a forma (a mesma silhueta da grade).
Future<void> abrirFichaGrimorioOculto(BuildContext context, EstadoJogo e, int id) => abrirFichaCurta(
      context,
      caixa: silhueta(SpriteItem(estado: e, item: e.catalogo.item(id)!, tamanho: 44)),
      nome: '?',
      meta: '? · ?',
      chips: const ['?'],
      fechar: e.idioma == 'en' ? 'Close' : 'Fechar',
    );
