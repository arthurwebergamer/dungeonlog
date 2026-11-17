// Configurações (engrenagem do Perfil): a tela principal e as sub-telas Heróis, Editar herói, Novo herói, Aparência,
// Preferências, Idioma e Gerenciar conta. Espelha os blocos "PERFIL — SUB-ABAS" e "PLANO PRO" de play/index.html
// (~11216 a 12120) e as `.cfgOverlay` de play/style.css. O que depende de conta, nuvem ou compra (criar conta, plano,
// excluir conta) aparece igual ao original, mas desabilitado, com o aviso "disponível em breve" (Fases 6 e 7).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dominio/save.dart' show nomeHeroiNorm, nomePadraoHeroi;
import 'cfg_base.dart';
import 'estado_jogo.dart';
import 'folhas.dart';
import 'icones.dart';
import 'som.dart';
import 'svg_icone.dart';
import 'tema.dart';
import 'vibra.dart';

/// Endereço das páginas legais (muda para /en/... em inglês: `atualizarLinksLegais`).
String urlLegal(String qual, String idioma) => 'https://dungeonlog.weberlabs.com.br/${idioma == 'en' ? 'en/' : ''}$qual';

Future<void> _abrirUrl(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
}

/// Aviso para o que ainda não existe no Flutter: conta, nuvem e plano Pro.
Future<void> avisoEmBreve(BuildContext context, EstadoJogo e, {String? pro}) {
  final en = e.idioma == 'en';
  return mostrarAviso(
    context,
    selo: pro != null ? 'PRO' : null,
    titulo: en ? 'Coming soon' : 'Disponível em breve',
    texto: pro != null
        ? (en ? '$pro needs the Pro plan, which arrives in a later version of the app.' : '$pro depende do plano Pro, que chega numa próxima versão do app.')
        : (en ? 'Accounts and cloud save arrive in a later version of the app.' : 'Conta e salvamento na nuvem chegam numa próxima versão do app.'),
    botao: en ? 'OK' : 'Entendi',
  );
}

/// Herói trocado com a cortina do original (`trocarPersonagemComTransicao`): escurece, troca por baixo e revela.
Future<void> trocarHeroiComCortina(BuildContext context, EstadoJogo e, String id, {VoidCallback? aoTrocar}) async {
  Som.atual.tocar('trocarHeroi');
  final overlay = Overlay.of(context, rootOverlay: true);
  final c = AnimationController(vsync: Navigator.of(context), duration: const Duration(milliseconds: 220));
  final entrada = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: AnimatedBuilder(animation: c, builder: (_, __) => Opacity(opacity: Curves.easeOutCubic.transform(c.value), child: ColoredBox(color: corFundo, child: const SizedBox.expand()))),
    ),
  );
  overlay.insert(entrada);
  try {
    await c.forward();
    await e.trocarPersonagem(id);
    aoTrocar?.call();
    await c.reverse();
  } finally {
    entrada.remove();
    c.dispose();
  }
}

void abrirConfiguracoes(BuildContext context, EstadoJogo e) => abrirTelaCfg<void>(context, (_) => _TelaConfig(estado: e));

String _nomeDoTema(EstadoJogo e) {
  final p = Paleta.porId(e.temaCorId) ?? Paleta.grafite;
  return e.idioma == 'en' ? p.nomeEn : p.nome;
}

String _resumoFeedback(EstadoJogo e) => e.idioma == 'en' ? (e.vibracaoLigada ? 'Vibrate' : 'Off') : (e.vibracaoLigada ? 'Vibrar' : 'Desativado');

class _TelaConfig extends StatelessWidget {
  const _TelaConfig({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final en = e.idioma == 'en';
        return CfgTela(
          titulo: tr(e, 'cfg.configuracoes'),
          estado: e,
          filhos: [
            CfgSecao(tr(e, 'cfg.conta'), primeira: true),
            CfgCartao(filhos: [
              CfgLinha(
                icone: 'conta',
                titulo: tr(e, 'cfg.conta'),
                subtitulo: en ? 'Playing without an account' : 'Jogando sem conta',
                controle: CfgBotao(tr(e, 'cfg.criarConta'), aoTocar: () => avisoEmBreve(context, e)),
                seta: true,
                aoTocar: () => abrirTelaCfg<void>(context, (_) => _TelaConta(estado: e)),
              ),
            ]),
            CfgSecao(tr(e, 'cfg.app')),
            CfgCartao(filhos: [
              CfgLinha(icone: 'herois', titulo: tr(e, 'cfg.herois'), seta: true, aoTocar: () => abrirTelaCfg<void>(context, (_) => _TelaHerois(estado: e))),
              CfgLinha(icone: 'aparencia', titulo: tr(e, 'cfg.aparencia'), valor: _nomeDoTema(e), seta: true, aoTocar: () => abrirTelaCfg<void>(context, (_) => _TelaAparencia(estado: e))),
              CfgLinha(icone: 'prefs', titulo: tr(e, 'cfg.preferencias'), valor: _resumoFeedback(e), seta: true, aoTocar: () => abrirTelaCfg<void>(context, (_) => _TelaPrefs(estado: e))),
              CfgLinha(
                icone: 'rever',
                titulo: tr(e, 'cfg.reverTutorial'),
                seta: true,
                // o tutorial guiado é da Fase 5
                aoTocar: () => mostrarAviso(context,
                    titulo: en ? 'Coming soon' : 'Disponível em breve',
                    texto: en ? 'The guided tutorial arrives in a later version of the app.' : 'O tutorial guiado chega numa próxima versão do app.',
                    botao: en ? 'OK' : 'Entendi'),
              ),
            ]),
            CfgSecao(tr(e, 'cfg.legal')),
            CfgCartao(filhos: [
              CfgLinha(icone: 'privacidade', titulo: tr(e, 'cfg.privacidade'), setaExterna: true, aoTocar: () => _abrirUrl(urlLegal('privacy', e.idioma))),
              CfgLinha(icone: 'termos', titulo: tr(e, 'cfg.termosDeUso'), setaExterna: true, aoTocar: () => _abrirUrl(urlLegal('terms', e.idioma))),
            ]),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Conta
class _TelaConta extends StatelessWidget {
  const _TelaConta({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    final en = e.idioma == 'en';
    Widget linha(Widget filho, {bool ultima = false}) => Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
          decoration: BoxDecoration(border: ultima ? null : Border(bottom: BorderSide(color: corLinha, width: 0.8))),
          child: filho,
        );
    return CfgTela(
      titulo: tr(e, 'cfg.gerenciarConta'),
      estado: e,
      filhos: [
        linha(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(e, 'cfg.idDaConta'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: corTexto, height: 1.2)),
          const SizedBox(height: 2),
          Text(en ? 'Playing without an account' : 'Jogando sem conta', style: TextStyle(fontSize: 12, color: corApagado, height: 1.26)),
        ])),
        Toque(
          aoTocar: () => avisoEmBreve(context, e, pro: en ? 'The subscription' : 'A assinatura'),
          child: linha(
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0x12FFFFFF), shape: BoxShape.circle),
                child: Center(child: IconeSvg('assinatura', tamanho: 22, cor: corApagado)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(e, 'cfg.gerenciarAssinatura'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: corTexto, height: 1.2))),
              Text(en ? 'No PRO plan' : 'Sem plano PRO', style: TextStyle(fontSize: 13, color: corApagado)),
              const SizedBox(width: 12),
              IconeSvg('seta', tamanho: 18, cor: corApagado),
            ]),
            ultima: true,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Heróis
class _PilulaPro extends StatelessWidget {
  const _PilulaPro();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: corAccent, borderRadius: BorderRadius.circular(999)),
        child: Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: corSobreAccent, height: 1.25)),
      );
}

class _TelaHerois extends StatelessWidget {
  const _TelaHerois({required this.estado});
  final EstadoJogo estado;

  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final en = e.idioma == 'en';
        final cheio = e.personagens.length >= e.limitePersonagens;
        return CfgTela(
          titulo: tr(e, 'cfg.herois'),
          estado: e,
          filhos: [
            CfgSecao(tr(e, 'cfg.personagens'), primeira: true),
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(18)),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                for (var i = 0; i < e.personagens.length; i++) ...[
                  if (i > 0) Padding(padding: const EdgeInsets.only(left: 70), child: Container(height: 1, color: corLinha)),
                  _ItemHeroi(estado: e, p: e.personagens[i]),
                ],
              ]),
            ),
            const SizedBox(height: 6),
            Toque(
              aoTocar: () {
                if (cheio) {
                  // o limite do plano grátis abre o paywall no original (Fase 7)
                  avisoEmBreve(context, e, pro: en ? 'More heroes' : 'Mais heróis');
                } else {
                  abrirTelaCfg<void>(context, (_) => _TelaNovoHeroi(estado: e));
                }
              },
              child: Opacity(
                opacity: cheio && !e.ehPro ? 0.55 : 1,
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: corLinha, width: 0.8)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(en ? '+ New hero' : '+ Novo herói', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cheio && !e.ehPro ? corApagado : corSuave, height: 1.28)),
                    if (!e.ehPro) ...[const SizedBox(width: 6), const _PilulaPro()],
                  ]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ItemHeroi extends StatelessWidget {
  const _ItemHeroi({required this.estado, required this.p});
  final EstadoJogo estado;
  final Personagem p;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    final ativo = p.id == e.personagem;
    final en = e.idioma == 'en';
    final heroi = e.dados.herois[e.spriteDoPersonagem(p).clamp(0, e.dados.herois.length - 1)];
    return Toque(
      aoTocar: ativo ? null : () => trocarHeroiComCortina(context, e, p.id),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: corPainel3, borderRadius: BorderRadius.circular(12)),
              child: Center(child: pixel(heroi.img, largura: 34, altura: 34)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(e.nomeDoPersonagem(p), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: corTexto, height: 1.28)),
                if (ativo) Text(en ? 'active now' : 'ativo agora', style: TextStyle(fontSize: 12, color: corApagado, height: 1.26)),
              ]),
            ),
            if (ativo) ...[const SizedBox(width: 14), IconeSvg('check', tamanho: 22, cor: corTexto)],
            const SizedBox(width: 14),
            Semantics(
              button: true,
              label: en ? 'Edit' : 'Editar',
              child: Toque(
                aoTocar: () {
                  // o lápis edita o herói ATIVO: se for outro, troca primeiro
                  if (ativo) {
                    abrirTelaCfg<void>(context, (_) => _TelaEditarHeroi(estado: e));
                  } else {
                    trocarHeroiComCortina(context, e, p.id, aoTrocar: () => abrirTelaCfg<void>(context, (_) => _TelaEditarHeroi(estado: e)));
                  }
                },
                child: SizedBox(width: 32, height: 32, child: Center(child: IconeSvg('editar', tamanho: 18, cor: corApagado))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Grade de sprites (`.grade` das telas de herói): 3 colunas de 104,8 x 71,2, o escolhido com borda e fundo de seleção.
class _GradeHerois extends StatelessWidget {
  const _GradeHerois({required this.estado, required this.escolhido, required this.aoEscolher});
  final EstadoJogo estado;
  final int escolhido;
  final ValueChanged<int> aoEscolher;
  @override
  Widget build(BuildContext context) {
    final hs = estado.dados.herois;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(18)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 71.2),
        itemCount: hs.length,
        itemBuilder: (_, i) {
          final sel = i == escolhido;
          return Semantics(
            button: true,
            label: hs[i].nomeNoIdioma(estado.idioma),
            child: Toque(
              aoTocar: () => aoEscolher(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? corAtivo : corPainel3,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? corAccent : Colors.transparent, width: 1.6),
                ),
                child: Center(child: pixel(hs[i].img, largura: 52, altura: 52)),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _pedirNome(BuildContext context, EstadoJogo e) {
  final en = e.idioma == 'en';
  final campo = TextEditingController(text: nomeHeroiNorm(e.save.nomeHeroi, e.idioma));
  campo.selection = TextSelection(baseOffset: 0, extentOffset: campo.text.length);
  return abrirFolha<void>(
    context,
    (ctx) => Folha(titulo: en ? 'Choose a new name' : 'Escolha um novo nome', filhos: [
      TextField(
        controller: campo,
        autofocus: true,
        maxLength: 18,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          e.renomearHeroi(campo.text);
          Navigator.pop(ctx);
        },
        style: TextStyle(fontSize: 15, color: corTexto),
        decoration: InputDecoration(
          counterText: '',
          hintText: en ? 'Hero name' : 'Nome do herói',
          hintStyle: TextStyle(color: corApagado),
          filled: true,
          fillColor: corPainel,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: corLinha, width: 0.8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: corAccent, width: 0.8)),
        ),
      ),
      const SizedBox(height: 14),
      BotaoFolha(en ? 'Save' : 'Salvar', aoTocar: () {
        e.renomearHeroi(campo.text);
        Navigator.pop(ctx);
      }),
    ]),
  );
}

class _TelaEditarHeroi extends StatelessWidget {
  const _TelaEditarHeroi({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final en = e.idioma == 'en';
        final podeExcluir = e.personagens.length >= 2;
        return CfgTela(
          titulo: tr(e, 'cfg.editarHeroi'),
          estado: e,
          filhos: [
            CfgCartao(filhos: [
              CfgLinha(
                titulo: tr(e, 'cfg.nomeDoHeroi'),
                subtitulo: nomeHeroiNorm(e.save.nomeHeroi, e.idioma),
                controle: CfgBotao(tr(e, 'cfg.renomear'), aoTocar: () => _pedirNome(context, e)),
              ),
            ]),
            CfgSecao(tr(e, 'cfg.spriteDoHeroi')),
            _GradeHerois(estado: e, escolhido: e.save.heroi.toInt(), aoEscolher: e.escolherSprite),
            if (podeExcluir) ...[
              const SizedBox(height: 24),
              Toque(
                aoTocar: () => _confirmarExcluir(context, e),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: corVida, width: 1.5)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconeSvg('excluir', tamanho: 18, cor: corVida),
                    const SizedBox(width: 8),
                    Text(en ? 'Delete hero' : 'Excluir herói', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: corVida, height: 1.25)),
                  ]),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

Future<void> _confirmarExcluir(BuildContext context, EstadoJogo e) async {
  final en = e.idioma == 'en';
  final nome = nomeHeroiNorm(e.save.nomeHeroi, e.idioma);
  final idExcluir = e.personagem;
  final ok = await abrirFolha<bool>(
    context,
    (ctx) => Folha(titulo: en ? 'Delete hero?' : 'Excluir herói?', filhos: [
      Text(
        en
            ? '"$nome" and all of this hero\'s progress will be lost for good. This can\'t be undone.'
            : '"$nome" e todo o progresso desse herói serão perdidos em definitivo. Não tem volta.',
        style: TextStyle(fontSize: 13, height: 1.5, color: corApagado),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: BotaoFolha(en ? 'Cancel' : 'Cancelar', fundo: corPainel2, cor: corTexto, borda: corLinha, aoTocar: () => Navigator.pop(ctx, false))),
        const SizedBox(width: 9),
        Expanded(child: BotaoFolha(en ? 'Delete hero' : 'Excluir herói', fundo: corVida, cor: Colors.white, aoTocar: () => Navigator.pop(ctx, true))),
      ]),
    ]),
  );
  if (ok != true || !context.mounted) return;
  final outro = e.personagens.firstWhere((p) => p.id != idExcluir);
  // troca para o outro herói (com a cortina) e só depois apaga o save do que saiu
  await trocarHeroiComCortina(context, e, outro.id);
  await e.excluirPersonagem(idExcluir);
  if (context.mounted) Navigator.of(context).maybePop(); // fecha "Editar herói": o herói que ela editava não existe mais
}

class _TelaNovoHeroi extends StatefulWidget {
  const _TelaNovoHeroi({required this.estado});
  final EstadoJogo estado;
  @override
  State<_TelaNovoHeroi> createState() => _TelaNovoHeroiState();
}

class _TelaNovoHeroiState extends State<_TelaNovoHeroi> {
  final _nome = TextEditingController();
  int _sprite = 0;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    final e = widget.estado;
    final ok = await e.criarPersonagem(_nome.text, _sprite);
    if (!mounted) return;
    if (ok) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estado;
    final en = e.idioma == 'en';
    return CfgTela(
      titulo: en ? 'New hero' : 'Novo herói',
      estado: e,
      filhos: [
        CfgSecao(tr(e, 'cfg.nomeDoHeroi'), primeira: true),
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
          decoration: BoxDecoration(color: corPainel2, borderRadius: BorderRadius.circular(18)),
          child: TextField(
            controller: _nome,
            maxLength: 18,
            style: TextStyle(fontSize: 15, color: corTexto),
            decoration: InputDecoration(
              counterText: '',
              hintText: nomePadraoHeroi(e.idioma),
              hintStyle: TextStyle(color: corApagado),
              filled: true,
              fillColor: corPainel2,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: corLinha, width: 0.8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: corAccent, width: 0.8)),
            ),
          ),
        ),
        CfgSecao(tr(e, 'cfg.spriteDoHeroi')),
        _GradeHerois(estado: e, escolhido: _sprite, aoEscolher: (i) => setState(() => _sprite = i)),
        const SizedBox(height: 8),
        Toque(
          aoTocar: _criar,
          child: Container(
            padding: const EdgeInsets.all(14),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), border: Border.all(color: corAccent, width: 0.8)),
            child: Text((en ? 'Create hero' : 'Criar herói').toUpperCase(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.3, color: corAccent, height: 1.25)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Aparência
class _TelaAparencia extends StatelessWidget {
  const _TelaAparencia({required this.estado});
  final EstadoJogo estado;

  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        final atual = Paleta.porId(e.temaCorId) ?? Paleta.grafite;
        return CfgTela(
          titulo: tr(e, 'cfg.aparencia'),
          estado: e,
          filhos: [
            CfgCartao(divisorEsq: 16, filhos: [
              for (final p in Paleta.todas)
                _LinhaTema(
                  p: p,
                  nome: e.idioma == 'en' ? p.nomeEn : p.nome,
                  selecionado: p.id == atual.id,
                  travado: p.pro && !e.ehPro,
                  aoTocar: () => _escolher(context, e, p),
                ),
            ]),
          ],
        );
      },
    );
  }

  void _escolher(BuildContext context, EstadoJogo e, Paleta p) {
    if (p.pro && !e.ehPro) {
      avisoEmBreve(context, e, pro: e.idioma == 'en' ? 'The ${p.nomeEn} theme' : 'O tema ${p.nome}');
      return;
    }
    Vibra.toque();
    aplicarTema(context, e, p);
  }
}

/// Troca o tema de cor: guarda a escolha, muda a paleta global e reconstrói o app inteiro (sem perder o estado das telas).
void aplicarTema(BuildContext context, EstadoJogo e, Paleta p) {
  Paleta.atual = p;
  e.definirTemaCor(p.id);
  temaMudou.value++;
}

class _LinhaTema extends StatelessWidget {
  const _LinhaTema({required this.p, required this.nome, required this.selecionado, required this.travado, required this.aoTocar});
  final Paleta p;
  final String nome;
  final bool selecionado;
  final bool travado;
  final VoidCallback aoTocar;
  @override
  Widget build(BuildContext context) {
    final borda = selecionado ? (p.claro || Paleta.atual.claro ? const Color(0xFF2E2C29) : Colors.white) : const Color(0x8C808080);
    return Toque(
      aoTocar: aoTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(children: [
            Opacity(
              opacity: travado ? 0.7 : 1,
              child: Container(width: 26, height: 26, decoration: BoxDecoration(color: p.bolinha, shape: BoxShape.circle, border: Border.all(color: borda, width: 2))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Opacity(opacity: travado ? 0.7 : 1, child: Text(nome, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: corTexto, height: 1.28)))),
            if (travado) ...[const SizedBox(width: 8), const _PilulaPro()],
            if (selecionado) ...[const SizedBox(width: 14), SizedBox(width: 24, height: 24, child: Center(child: IconeSvg('checkTema', tamanho: 20, cor: corTexto)))],
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Preferências
class _TelaPrefs extends StatelessWidget {
  const _TelaPrefs({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        return CfgTela(
          titulo: tr(e, 'cfg.preferencias'),
          estado: e,
          filhos: [
            CfgSecao(tr(e, 'cfg.geral'), primeira: true),
            CfgCartao(filhos: [
              CfgLinha(
                icone: 'idioma',
                titulo: tr(e, 'cfg.idioma'),
                valor: e.idioma == 'en' ? 'English' : 'Português',
                seta: true,
                aoTocar: () => abrirTelaCfg<void>(context, (_) => _TelaIdioma(estado: e)),
              ),
            ]),
            CfgSecao(tr(e, 'cfg.experiencia')),
            CfgCartao(filhos: [
              CfgLinha(
                icone: 'feedback',
                titulo: tr(e, 'cfg.feedbackDeClique'),
                controle: Interruptor(
                  ligado: e.vibracaoLigada,
                  aoMudar: (v) {
                    e.definirVibracao(v);
                    // feedback imediato só ao LIGAR: o jogador sente a vibração para confirmar que funciona
                    if (v) Vibra.leve();
                  },
                ),
              ),
              CfgLinha(icone: 'som', titulo: tr(e, 'cfg.som'), controle: Interruptor(ligado: e.somLigado, aoMudar: e.definirSom)),
              CfgLinha(icone: 'crt', titulo: tr(e, 'cfg.crt'), controle: Interruptor(ligado: e.crtLigado, aoMudar: e.definirCrt)),
              CfgLinha(icone: 'golpes', titulo: tr(e, 'cfg.golpes'), controle: Interruptor(ligado: e.golpesVariados, aoMudar: e.definirGolpesVariados)),
            ]),
            CfgSecao(tr(e, 'cfg.avisos')),
            CfgCartao(filhos: [
              // só a preferência local; o push de verdade (permissão, token, servidor) é da Fase 7
              CfgLinha(icone: 'notif', titulo: tr(e, 'cfg.notificacoes'), controle: Interruptor(ligado: e.notificacoesLigadas, aoMudar: e.definirNotificacoes)),
            ]),
          ],
        );
      },
    );
  }
}

class _TelaIdioma extends StatelessWidget {
  const _TelaIdioma({required this.estado});
  final EstadoJogo estado;
  @override
  Widget build(BuildContext context) {
    final e = estado;
    return ListenableBuilder(
      listenable: e,
      builder: (context, _) {
        Widget linha(String id, String nome) {
          final sel = e.idioma == id;
          return Toque(
            aoTocar: () {
              Vibra.toque();
              e.definirIdioma(id);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(children: [
                  Expanded(child: Text(nome, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: corTexto, height: 1.28))),
                  if (sel) IconeSvg('check', tamanho: 20, cor: corTexto),
                ]),
              ),
            ),
          );
        }

        return CfgTela(
          titulo: tr(e, 'cfg.idioma'),
          estado: e,
          filhos: [
            CfgCartao(divisorEsq: 16, filhos: [linha('pt', 'Português'), linha('en', 'English')]),
          ],
        );
      },
    );
  }
}
