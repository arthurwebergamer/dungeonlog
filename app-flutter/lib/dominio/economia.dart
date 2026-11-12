// Economia do jogo. Espelha `ECO`, `BONUS`, `DIFS` e `AFX_TETO` de play/index.html (linhas ~2377 a 2442,
// 2622 e 3203). Se o balanceamento mudar no HTML, anote em PARIDADE.md e atualize aqui.

class Eco {
  Eco._();
  // experiência
  static const double xpPorTarefa = 28;
  static const int xpTarefasCheias = 10;
  static const double xpDecaimento = 0.50;
  // dificuldade
  static const double difTrivial = 0.50;
  static const double difFacil = 1.00;
  static const double difMedia = 1.50;
  static const double difDificil = 2.25;
  // vida
  static const double vidaBase = 40;
  static const double vidaPorNivel = 8;
  static const double danoPorTarefa = 6;
  static const int curaPorTarefa = 2;
  static const double curaVitoria = 0.25;
  static const double penalidadeMorte = 0.50;
  // moedas
  static const double moedasPorTarefa = 3;
  static const double moedasVitoriaBase = 16;
  static const double moedasVitoriaPorTarefa = 5;
  static const int moedasVitoriaTeto = 6;
  // loja
  static const double lojaMargem = 2.20;
  static const int lojaVagas = 8;
  static const int lojaConsumiveis = 2;
  static const int lojaRarosMin = 2;
  static const double lojaDesconto = 0.70;
  static const int lojaNivelPorRaridade = 2;
  static const double lojaMargemConsumivel = 3.60;
  // itens
  static const double taxaVenda = 0.50;
  static const double taxaVendaTesouro = 1.00;
  static const int lootBase = 1;
  static const int lootExtraCada = 5;
  static const int lootMax = 3;
  static const List<List<int>> lootPorEstagio = [[1, 1], [2, 3], [3, 4], [4, 4]];
  static const List<double> sorteEstagio = [0, 0.20, 0.40, 0.60];
  // baú trancado
  static const double chanceBauTrancadoMin = 0.20;
  static const double chanceBauTrancadoMax = 0.40;
  // níveis
  static const int nivelBase = 100;
  static const int nivelIncremento = 60;
}

/// Tarefas concluídas no total para cruzar de um estágio ao próximo.
const List<int> limiaresEstagio = [10, 30, 70];

const List<String> slotsEquip = ['arma', 'armadura', 'elmo', 'escudo', 'acess'];

/// Bônus percentual de cada equipamento por tipo e raridade (índice 0 a 7).
class BonusTipo {
  final List<int> x; // % de XP
  final List<int> m; // % de moedas
  const BonusTipo(this.x, this.m);
}

const Map<String, BonusTipo> bonusPorTipo = {
  'arma': BonusTipo([5, 10, 17, 22, 26, 40, 50, 50], [3, 6, 10, 13, 16, 25, 31, 31]),
  'armadura': BonusTipo([3, 6, 10, 12, 15, 24, 30, 30], [1, 2, 3, 4, 5, 8, 10, 10]),
  'elmo': BonusTipo([2, 5, 8, 10, 13, 20, 25, 25], [1, 2, 3, 4, 5, 8, 10, 10]),
  'escudo': BonusTipo([2, 4, 7, 9, 11, 13, 16, 16], [2, 4, 6, 8, 10, 16, 20, 20]),
  'acess': BonusTipo([3, 6, 10, 13, 16, 26, 32, 32], [4, 8, 13, 16, 20, 32, 40, 40]),
};

/// Tipos de afixo (chaves de `AFIXOS`).
const List<String> afixoChaves = ['gan', 'est', 'sor', 'bar', 'bau', 'abu', 'tes', 'tex'];

/// Teto da soma de cada afixo entre os slots equipados (`AFX_TETO`).
const Map<String, int> afixoTeto = {'gan': 25, 'est': 25, 'sor': 10, 'bar': 10, 'bau': 10, 'abu': 15, 'tes': 20, 'tex': 15};

class Dificuldade {
  final String id;
  final int pips;
  final double mult;
  const Dificuldade(this.id, this.pips, this.mult);
}

const List<Dificuldade> dificuldades = [
  Dificuldade('trivial', 1, Eco.difTrivial),
  Dificuldade('facil', 2, Eco.difFacil),
  Dificuldade('media', 3, Eco.difMedia),
  Dificuldade('dificil', 4, Eco.difDificil),
];
const String difPadrao = 'media';

/// `difDe(t)`: sempre devolve um id válido.
String difDe(Object? id) => dificuldades.any((d) => d.id == id) ? id as String : difPadrao;

/// `multDif(id)`: id desconhecido cai na dificuldade padrão.
double multDif(Object? id) {
  final d = dificuldades.firstWhere((x) => x.id == id, orElse: () => dificuldades.firstWhere((x) => x.id == difPadrao));
  return d.mult > 0 ? d.mult : 1;
}
