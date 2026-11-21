// Tutorial guiado (o "TOUR" do original, play/index.html ~13586, módulo "DIALOGO POR TELA"): os 9 passos, o registro de
// telas já vistas (`questlog.tutorialTelas.v2`) e a posição do cartão do herói na tela.
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show Rect;

/// Telas que o tutorial cobre (as chaves do registro).
const telasTutorial = ['tarefas', 'inventario', 'loja', 'perfil', 'estatisticas'];

/// Onde o original guarda quais telas já tiveram o tutorial. É uma chave do APARELHO (não entra em
/// `CHAVES_SECUNDARIAS_CONTA`): vale para todos os heróis e contas deste aparelho.
const chaveTutorialTelas = 'questlog.tutorialTelas.v2';

/// Lê o registro (`JSON.parse(bruto) || {}`): qualquer coisa que não seja um objeto vira vazio.
Map<String, bool> lerTelasVistas(String? bruto) {
  if (bruto == null || bruto.isEmpty) return {};
  try {
    final j = jsonDecode(bruto);
    if (j is! Map) return {};
    return {for (final e in j.entries) if (e.key is String && e.value != null && e.value != false && e.value != 0 && e.value != '') e.key as String: true};
  } catch (_) {
    return {};
  }
}

String gravarTelasVistas(Map<String, bool> vistas) => jsonEncode(vistas);

/// O que o passo espera do jogador: nada (só informa), abrir a folha de nova tarefa, criar a tarefa ou concluí-la.
enum EsperaTour { nenhuma, abrir, criar, concluir }

/// Um passo do tour. [alvos] são ids de elementos (a interface mapeia cada id para um widget real; vários = a união deles).
class PassoTour {
  const PassoTour({
    required this.aba,
    required this.alvos,
    required this.titulo,
    required this.tituloEn,
    required this.sub,
    required this.subEn,
    this.espera = EsperaTour.nenhuma,
    this.leve = false,
    this.rolar = false,
  });

  /// Índice da aba na barra (0 Tarefas, 1 Inventário, 2 Loja, 3 Perfil, 4 Estatísticas).
  final int aba;
  final List<String> alvos;
  final String titulo, tituloEn, sub, subEn;
  final EsperaTour espera;

  /// Escurecimento mais leve (a 50%): o jogador precisa ver o golpe acontecendo.
  final bool leve;

  /// Rola até o alvo antes de medir.
  final bool rolar;

  String tSub(String l) => l == 'en' ? subEn : sub;
  String tTitulo(String l) => l == 'en' ? tituloEn : titulo;
  bool get interativo => espera != EsperaTour.nenhuma;
}

const passosTour = <PassoTour>[
  PassoTour(
    aba: 0, alvos: ['addbtn'], espera: EsperaTour.abrir,
    titulo: 'Crie sua 1ª tarefa', tituloEn: 'Create your 1st task',
    sub: 'Toque em + Adicionar pra criar sua primeira tarefa.', subEn: 'Tap + Add to create your first task.',
  ),
  PassoTour(
    aba: 0, alvos: ['input', 'save'], espera: EsperaTour.criar,
    titulo: 'Escreva a tarefa', tituloEn: 'Write the task',
    sub: 'Escreva a tarefa e toque em Criar tarefa.', subEn: 'Write the task and tap Create task.',
  ),
  PassoTour(
    aba: 0, alvos: ['tarefaBox'], espera: EsperaTour.concluir, leve: true, rolar: true,
    titulo: 'Agora conclua', tituloEn: 'Now finish it',
    sub: 'Agora toque na caixinha e veja o monstro apanhar.', subEn: 'Now tap the box and watch the monster take a hit.',
  ),
  PassoTour(
    aba: 0, alvos: ['restbtn'],
    titulo: 'Dia de descanso', tituloEn: 'Rest day',
    sub: 'Doente ou sem condições? Toque na lua pra descansar: sem dano e sem perder a sequência.',
    subEn: 'Sick or not up to it? Tap the moon to rest: no damage and your streak stays safe.',
  ),
  PassoTour(
    aba: 1, alvos: ['equipbox'],
    titulo: 'Equipe seus itens', tituloEn: 'Equip your items',
    sub: 'Aqui ficam seus itens. Itens bons dão mais XP e moedas.', subEn: 'Your items live here. Good ones boost your XP and coins.',
  ),
  PassoTour(
    aba: 2, alvos: ['lojaLinha'],
    titulo: 'A loja renova todo dia', tituloEn: 'The shop restocks daily',
    sub: 'A loja renova todo dia. Compre equipamentos com suas moedas.', subEn: 'The shop restocks daily. Buy gear with your coins.',
  ),
  PassoTour(
    aba: 3, alvos: ['prevConquistas', 'prevBestiario'], rolar: true,
    titulo: 'Conquistas e bestiário', tituloEn: 'Achievements and bestiary',
    sub: 'Aqui ficam suas conquistas e o bestiário, com todos os monstros que você já derrotou.',
    subEn: 'Your achievements and the bestiary live here, with every monster you have defeated.',
  ),
  PassoTour(
    aba: 3, alvos: ['perfilCfgBtn'], rolar: true,
    titulo: 'Configurações', tituloEn: 'Settings',
    sub: 'Na engrenagem você muda herói, tema, idioma, sons e pode rever este tutorial.',
    subEn: 'The gear lets you change hero, theme, language, sounds, and replay this tutorial.',
  ),
  PassoTour(
    aba: 4, alvos: ['estCardPrincipal'],
    titulo: 'Sua sequência de vitórias', tituloEn: 'Your win streak',
    sub: 'Essa é sua sequência de vitórias. A tocha cresce a cada dia vencido.',
    subEn: 'This is your win streak. The torch grows with every won day.',
  ),
];

/// Onde o cartão do herói fica (`tourPosicionar`). [topo] e [base] são exclusivos: o cartão encosta no topo OU na base.
class PosicaoCartaoTour {
  const PosicaoCartaoTour({required this.esquerda, required this.largura, this.topo, this.base, this.safeTopo = false, this.safeBase = false, required this.largo});
  final double esquerda, largura;

  /// Distância do topo da tela (px), ou null se o cartão encosta na base.
  final double? topo;
  final double? base;

  /// Quando true, a distância vem somada à área segura (12 + topo seguro / 14 + base segura).
  final bool safeTopo, safeBase;

  /// Telas largas (acima de 700 px) usam o cartão ao lado do alvo.
  final bool largo;

  /// `noTopo`: telas estreitas com o cartão no topo (a sombra vai para baixo).
  bool get noTopo => !largo && (topo != null || safeTopo);
}

/// Mesma conta do `tourPosicionar` do original. [alvo] é o retângulo que envolve todos os alvos; [alvos] os de cada um;
/// [alturaCartao] a altura medida do cartão (largura já definida aqui).
PosicaoCartaoTour posicionarCartaoTour({
  required double larguraTela,
  required double alturaTela,
  required double alturaCartao,
  required Rect alvo,
  required List<Rect> alvos,
  double pad = 6,
}) {
  final w = larguraTela, h = alturaTela, ch = alturaCartao;
  final largo = w > 700;
  final cw = largo ? 440.0 : math.min(520.0, w - 24);
  const m = 12.0;
  bool liv(double x, double y) => alvos.every((q) => x + cw < q.left - 10 || x > q.right + 10 || y + ch < q.top - 10 || y > q.bottom + 10);
  bool dentro(double x, double y) => x >= m && y >= m && x + cw <= w - m && y + ch <= h - m;
  final cx = math.max(m, math.min(w - cw - m, alvo.left + alvo.width / 2 - cw / 2));
  final cy = math.max(m, math.min(h - ch - m, alvo.top + alvo.height / 2 - ch / 2));
  final List<(double, double)> cand = largo
      ? [(alvo.right + pad + 20, cy), (alvo.left - pad - 20 - cw, cy), (cx, alvo.bottom + pad + 20), (cx, alvo.top - pad - 20 - ch)]
      : [(cx, h - ch - 14), (cx, m)];
  (double, double)? esc;
  for (final c in cand) {
    if (dentro(c.$1, c.$2) && liv(c.$1, c.$2)) {
      esc = c;
      break;
    }
  }
  if (esc == null) {
    // nada cabe fora do destaque: procura um vão entre os alvos (ex.: entre o campo e o botão Criar do formulário)
    for (var y = m; y + ch <= h - m && esc == null; y += 12) {
      if (liv(cx, y)) esc = (cx, y);
    }
  }
  esc ??= cand.first;
  var nl = esc.$1.roundToDouble();
  var nt = esc.$2.roundToDouble();
  if (!largo) {
    nl = ((w - cw) / 2).roundToDouble();
    if (nt >= h - ch - 20) {
      return PosicaoCartaoTour(esquerda: nl, largura: cw, base: 14, safeBase: true, largo: largo);
    } else if (nt <= m + 1) {
      return PosicaoCartaoTour(esquerda: nl, largura: cw, topo: 12, safeTopo: true, largo: largo);
    }
  }
  return PosicaoCartaoTour(esquerda: nl, largura: cw, topo: nt, largo: largo);
}
