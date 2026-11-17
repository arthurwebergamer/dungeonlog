// Peças das telas em tela cheia do Perfil (as `.cfgOverlay` do original): cabeçalho com voltar, rótulo de seção, cartão
// de linhas, linha de configuração e interruptor. Medidas do CSS computado de play/ em 390x844.
import 'package:flutter/material.dart';

import 'estado_jogo.dart';
import 'folhas.dart';
import 'svg_icone.dart';
import 'tema.dart';

/// Abre uma tela cheia por cima da atual (a `.cfgOverlay`: entra com um leve deslize de 14 px e aparece em 0,22 s).
Future<T?> abrirTelaCfg<T>(BuildContext context, WidgetBuilder builder) => Navigator.of(context).push<T>(PageRouteBuilder<T>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, _, __) => builder(ctx),
      transitionsBuilder: (ctx, anim, _, filho) {
        final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: AnimatedBuilder(animation: c, child: filho, builder: (_, f) => Transform.translate(offset: Offset(14 * (1 - c.value), 0), child: f)),
        );
      },
    ));

/// Texto de uma chave no idioma do app (cai no PT e depois na própria chave).
String tr(EstadoJogo e, String chave) => e.dados.traducoes.t(chave, e.idioma);

/// Tela cheia com cabeçalho (voltar + título, `.cfgovhead`) e corpo rolável com 16 px de borda (`.cfgovcorpo`).
class CfgTela extends StatelessWidget {
  const CfgTela({super.key, required this.titulo, required this.estado, required this.filhos, this.aoVoltar});
  final String titulo;
  final EstadoJogo estado;
  final List<Widget> filhos;
  final VoidCallback? aoVoltar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: corFundo,
      child: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: SizedBox(
              height: 36,
              child: Row(children: [
                Semantics(
                  button: true,
                  label: tr(estado, 'acao.voltar'),
                  child: Toque(
                    aoTocar: aoVoltar ?? () => Navigator.of(context).maybePop(),
                    child: SizedBox(width: 36, height: 36, child: Center(child: IconeSvg('voltar', tamanho: 22, cor: corTexto))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: corTexto, height: 1.25))),
              ]),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewPadding.bottom),
              children: filhos,
            ),
          ),
        ]),
      ),
    );
  }
}

/// Rótulo de seção (`.edsec` dentro da tela): 12 px, 700, maiúsculas, espaçado, apagado.
class CfgSecao extends StatelessWidget {
  const CfgSecao(this.texto, {super.key, this.primeira = false});
  final String texto;
  final bool primeira;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(6, primeira ? 0 : 18, 6, 8),
        child: Text(texto.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.44, color: corApagado, height: 1.26)),
      );
}

/// Cartão arredondado com linhas e divisórias (`.cfgcard`): fundo painel-2, raio 18, margem de baixo 6.
class CfgCartao extends StatelessWidget {
  const CfgCartao({super.key, required this.filhos, this.divisorEsq = 54, this.margemBaixo = 6});
  final List<Widget> filhos;

  /// Onde começa a divisória (54 nas linhas com ícone, 16 nas listas de tema).
  final double divisorEsq;
  final double margemBaixo;
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: margemBaixo),
        decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (var i = 0; i < filhos.length; i++) ...[
            if (i > 0) Padding(padding: EdgeInsets.only(left: divisorEsq), child: Container(height: 1, color: corLinha)),
            filhos[i],
          ],
        ]),
      );
}

/// Botão pequeno de borda fina (`.cfgbtn`): "Criar conta", "Renomear", "Ver todas".
class CfgBotao extends StatelessWidget {
  const CfgBotao(this.texto, {super.key, required this.aoTocar, this.habilitado = true});
  final String texto;
  final VoidCallback? aoTocar;
  final bool habilitado;
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: habilitado ? 1 : 0.45,
        child: Toque(
          aoTocar: habilitado ? aoTocar : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: corAtivo, width: 0.8)),
            child: Text(texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: corAccent, height: 1.26)),
          ),
        ),
      );
}

/// Uma linha de configuração (`.cfgrow` dentro de `.cfgcard`): ícone de 24 px, título (15/500) com subtítulo opcional,
/// valor à direita, controle (botão/interruptor) e seta.
class CfgLinha extends StatelessWidget {
  const CfgLinha({
    super.key,
    this.icone,
    required this.titulo,
    this.subtitulo,
    this.valor,
    this.controle,
    this.seta = false,
    this.setaExterna = false,
    this.aoTocar,
    this.apagada = false,
  });
  final String? icone;
  final String titulo;
  final String? subtitulo;
  final String? valor;
  final Widget? controle;
  final bool seta;
  final bool setaExterna;
  final VoidCallback? aoTocar;

  /// Linha desabilitada (conta/nuvem/Pro, que ainda não existem): mesma aparência, mais apagada.
  final bool apagada;

  @override
  Widget build(BuildContext context) {
    final corpo = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(children: [
          if (icone != null) ...[SizedBox(width: 24, height: 24, child: Center(child: IconeSvg(icone!, tamanho: 22, cor: corApagado))), const SizedBox(width: 14)],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: corTexto, height: 1.2)),
              if (subtitulo != null) ...[const SizedBox(height: 2), Text(subtitulo!, style: TextStyle(fontSize: 12, color: corApagado, height: 1.26))],
            ]),
          ),
          if (valor != null) ...[const SizedBox(width: 14), Text(valor!, style: TextStyle(fontSize: 13, color: corApagado, height: 1.26))],
          if (controle != null) ...[const SizedBox(width: 14), controle!],
          if (seta || setaExterna) ...[const SizedBox(width: 14), IconeSvg(setaExterna ? 'externo' : 'seta', tamanho: 18, cor: corApagado)],
        ]),
      ),
    );
    final c = apagada ? Opacity(opacity: 0.55, child: corpo) : corpo;
    if (aoTocar == null) return c;
    return Toque(aoTocar: aoTocar, child: c);
  }
}

/// Interruptor (`.swch`): trilho 46x26, bolinha de 20. Cores fixas do original (cinza), valem em qualquer tema.
class Interruptor extends StatelessWidget {
  const Interruptor({super.key, required this.ligado, required this.aoMudar, this.habilitado = true});
  final bool ligado;
  final ValueChanged<bool>? aoMudar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: ligado,
      child: Opacity(
        opacity: habilitado ? 1 : 0.45,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: habilitado && aoMudar != null ? () => aoMudar!(!ligado) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: ligado ? const Color(0xFF8B8B90) : const Color(0x47808084), borderRadius: BorderRadius.circular(999)),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: ligado ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(width: 20, height: 20, decoration: BoxDecoration(color: ligado ? const Color(0xFFF2F2F4) : const Color(0xFF9A9AA0), shape: BoxShape.circle)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bolinha de notificação (`.conqbadge`): 16 px de altura, rosa, número em Silkscreen 9 px.
class BolinhaAviso extends StatelessWidget {
  const BolinhaAviso(this.n, {super.key});
  final int n;
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 16),
        height: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: corVida, borderRadius: BorderRadius.circular(999)),
        child: Text(n > 9 ? '9+' : '$n', style: const TextStyle(fontFamily: fontePixel, fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
      );
}
