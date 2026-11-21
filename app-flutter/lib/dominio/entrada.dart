// Regras e textos da ENTRADA do app (abertura, carrossel de apresentação, quiz de categoria, login e configuração do
// herói). Tudo vem de play/index.html: o idioma padrão do aparelho (script do <head>, ~111), o carrossel (SLIDES,
// ~17400), o quiz (CATEGORIAS_ONBOARDING, ~17628) e a configuração do herói (mostrarSetupPersonagemENome, ~7225).

/// Chave onde o original guarda a resposta do quiz (as categorias de tarefa estão desligadas, mas a resposta é gravada).
const chaveCategoriaOnboarding = 'questlog.onboarding.categoria.v1';

/// Marca "joga sem conta" (o login real, na Fase 6, usa isto para migrar o progresso do convidado para a conta nova).
const chaveConvidado = 'questlog.convidado.v1';

/// Idioma padrão na primeira abertura (o script do `<head>` do original): PT se o primeiro idioma do aparelho é pt-BR
/// ou "pt" sem região, ou se pt-BR aparece em qualquer posição da lista; senão EN (pt-PT sozinho continua EN).
/// [idiomas] são as etiquetas do aparelho em ordem de preferência ("pt-BR", "en-US"...).
String idiomaPadraoDoAparelho(List<String> idiomas) {
  final lista = [for (final l in idiomas) l.toLowerCase()];
  final primeiro = lista.isEmpty ? '' : lista.first;
  final ehPt = primeiro.startsWith('pt-br') || primeiro == 'pt' || lista.any((l) => l.startsWith('pt-br'));
  return ehPt ? 'pt' : 'en';
}

/// Texto da abertura ("Carregando a masmorra..."): só EN se a língua do aparelho NÃO começa com "pt"
/// (o `<script>` logo depois do `#bootSplash` olha `navigator.language`, não a preferência do app).
String textoAbertura(String? linguaDoAparelho) {
  final l = (linguaDoAparelho == null || linguaDoAparelho.isEmpty) ? 'pt' : linguaDoAparelho;
  return RegExp(r'^pt', caseSensitive: false).hasMatch(l) ? 'Carregando a masmorra...' : 'Loading the dungeon...';
}

/// Tipos de ilustração dos slides.
enum TipoSlide { monstro, quizCategoria, heroi, conquistasPreview, golpeAnim }

/// Um slide do carrossel (`SLIDES`). O quinto leva ao login.
class SlideOnb {
  const SlideOnb({
    required this.numero,
    required this.tipo,
    required this.fraca,
    required this.fracaEn,
    required this.titulo,
    required this.tituloEn,
    required this.botao,
    required this.botaoEn,
    this.texto = '',
    this.textoEn = '',
    this.idx = 0,
  });
  final int numero; // 1 a 5 (data-slide)
  final TipoSlide tipo;
  final String fraca, fracaEn, titulo, tituloEn, texto, textoEn, botao, botaoEn;

  /// Monstro (índice no catálogo) ou herói do slide.
  final int idx;

  String tFraca(String l) => l == 'en' ? fracaEn : fraca;
  String tTitulo(String l) => l == 'en' ? tituloEn : titulo;
  String tTexto(String l) => l == 'en' ? textoEn : texto;
  String tBotao(String l) => l == 'en' ? botaoEn : botao;
}

const slidesOnboarding = <SlideOnb>[
  SlideOnb(
    numero: 1, tipo: TipoSlide.monstro, idx: 38, // Gosma glacial
    fraca: 'Chega de tarefa esquecida', fracaEn: 'No more forgotten tasks',
    titulo: 'Suas tarefas viram uma masmorra pra vencer', tituloEn: 'Your tasks become a dungeon to beat',
    texto: 'Cada pendência é um monstro parado no seu caminho. Complete a tarefa, derrote o monstro.',
    textoEn: 'Every pending task is a monster blocking your way. Finish it, defeat the monster.',
    botao: 'Começar', botaoEn: 'Get started',
  ),
  SlideOnb(
    numero: 2, tipo: TipoSlide.quizCategoria,
    fraca: 'Personalização', fracaEn: 'Personalization',
    titulo: 'O que você mais quer organizar?', tituloEn: 'What do you want to organize most?',
    botao: 'Continuar', botaoEn: 'Continue',
  ),
  SlideOnb(
    numero: 3, tipo: TipoSlide.heroi, idx: 1,
    fraca: 'Todo dia um pouco mais forte', fracaEn: 'A little stronger every day',
    titulo: 'Veja seu herói evoluir a cada tarefa', tituloEn: 'Watch your hero level up with every task',
    texto: 'XP, níveis e cenários novos conforme você avança nos estágios.',
    textoEn: 'XP, levels and new scenery as you advance through stages.',
    botao: 'Continuar', botaoEn: 'Continue',
  ),
  SlideOnb(
    numero: 4, tipo: TipoSlide.conquistasPreview,
    fraca: 'Recompensas por consistência', fracaEn: 'Rewards for consistency',
    titulo: 'Desbloqueie conquistas conforme joga', tituloEn: 'Unlock achievements as you play',
    texto: 'Streaks, marcos e itens raros — cada conquista fica guardada no seu perfil.',
    textoEn: 'Streaks, milestones and rare items — every achievement is saved to your profile.',
    botao: 'Continuar', botaoEn: 'Continue',
  ),
  SlideOnb(
    numero: 5, tipo: TipoSlide.golpeAnim, idx: 22, // Minhoca
    fraca: 'É rápido assim', fracaEn: "It's this quick",
    titulo: 'Marcou como feito. Golpe certeiro.', tituloEn: 'Marked as done. Direct hit.',
    texto: 'Essa é a sensação toda vez que você fecha uma tarefa. Bora começar?',
    textoEn: "That's the feeling every time you finish a task. Let's go?",
    botao: 'Criar minha conta', botaoEn: 'Create my account',
  ),
];

/// Espadas do slide "É rápido assim" (`ESPADAS_OB`): uma por raridade, trocada depois de cada golpe.
const espadasOnboarding = [2, 129, 142, 164, 176];

/// Itens do slide de conquistas: Coroa Real e Diamante (os dois lendários); o terceiro é um cadeado apagado.
const itensConquistasOnboarding = [34, 81];

/// Classe do corte pela raridade da espada (a mesma lista do `golpeOb` do original).
String classeCorteOnboarding(int raridade) =>
    const ['comum', 'incomum', 'raro', 'raro', 'epico', 'lendario', 'lendario', 'lendario'][raridade.clamp(0, 7)];

/// Escala do corte pela raridade (`--escala-slash`).
double escalaCorteOnboarding(int raridade) => const [2.0, 2.2, 2.4, 2.4, 2.6, 2.8, 2.8, 2.8][raridade.clamp(0, 7)];

/// Opção do quiz: id gravado, rótulo e cor.
class CategoriaOnb {
  const CategoriaOnb(this.id, this.rotulo, this.rotuloEn, this.cor);
  final String id, rotulo, rotuloEn;
  final int cor; // 0xRRGGBB
  String t(String l) => l == 'en' ? rotuloEn : rotulo;
}

const categoriasOnboarding = <CategoriaOnb>[
  CategoriaOnb('estudos', 'Estudos', 'Study', 0x63C99A),
  CategoriaOnb('trabalho', 'Trabalho', 'Work', 0x5AA9F2),
  CategoriaOnb('rotina', 'Rotina pessoal', 'Personal routine', 0xE5698A),
  CategoriaOnb('tudo', 'Um pouco de tudo', 'A bit of everything', 0xF2C94C),
];

/// Nome do herói ao fim da configuração: vazio (ou só espaços) não passa; o resto vale como o original
/// (`n = campo.value.trim()`; o campo tem `maxlength=18`).
String? nomeAoFimDoSetup(String digitado) {
  final n = digitado.trim();
  return n.isEmpty ? null : n;
}

/// Tamanho máximo do nome do herói no campo da entrada (`maxlength="18"`).
const maximoNomeHeroi = 18;

