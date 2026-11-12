// "Golpes variados" do original (play/index.html ~20388): 5 estilos de golpe corpo a corpo (Lâmina/relâmpago, Combo,
// Lâmina arremessada, Vulto e Crítico), espada girando, corte em pixel art na cor da raridade da arma, partículas,
// tremor da arena e flash. As receitas são as mesmas do JS, rodando num pequeno motor de animações por tempo.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'som.dart';
import 'tela_inventario.dart' show corRaridade;

/// Pedido de golpe vindo da tela (toque na caixa de uma tarefa).
class GolpeControlador extends ChangeNotifier {
  String dif = 'media';
  bool fim = false;
  int contador = 0;
  int contadorEscapada = 0;
  int contadorPoof = 0;

  /// Durante a vitória o monstro some na nuvem (opacity 0) e só volta quando o estado vira "derrotado".
  bool monstroOculto = false;

  /// `mostrarPoofMonstro()`: nuvem branca no lugar do monstro e o sprite escondido.
  void poof() {
    monstroOculto = true;
    contadorPoof++;
    notifyListeners();
  }

  void mostrarMonstro() {
    monstroOculto = false;
    notifyListeners();
  }

  int escapadas = 0;

  /// Duração aproximada da cena (ms), para a tela esperar antes do popup.
  static int duracaoEscapada(int n) => 500 + n * (5200 / n).clamp(150, 650).round() + 450;

  /// "Monstro escapou": o monstro do dia perdido bate no herói, uma vez por tarefa largada.
  void escapar(int n) {
    escapadas = n;
    contadorEscapada++;
    notifyListeners();
  }

  /// [fim]: última tarefa do dia (golpe crítico).
  void golpear({String dif = 'media', bool fim = false}) {
    this.dif = dif;
    this.fim = fim;
    contador++;
    notifyListeners();
  }
}

class _Cancelado implements Exception {
  const _Cancelado();
}

/// Uma animação de propriedades (`el.animate(...)` do JS): quadros-chave com easing por intervalo.
class _Anim {
  _Anim(this.alvo, this.inicio, this.dur, this.kf, this.curva, {this.passos, this.preencher = true});
  final String alvo;
  final double inicio;
  final double dur;
  final List<(double, List<double>)> kf;
  final Curve curva;
  final int? passos;
  final bool preencher; // fill: forwards

  List<double>? valor(double agora) {
    if (agora < inicio) return null;
    var p = dur <= 0 ? 1.0 : (agora - inicio) / dur;
    if (p >= 1) {
      if (!preencher) return null;
      return kf.last.$2;
    }
    if (passos != null) p = (p * passos!).floor() / passos!;
    for (var i = 0; i < kf.length - 1; i++) {
      final a = kf[i], b = kf[i + 1];
      if (p <= b.$1) {
        final u = b.$1 == a.$1 ? 1.0 : ((p - a.$1) / (b.$1 - a.$1)).clamp(0.0, 1.0);
        final e = passos != null ? u : curva.transform(u);
        return [for (var k = 0; k < a.$2.length; k++) a.$2[k] + (b.$2[k] - a.$2[k]) * e];
      }
    }
    return kf.last.$2;
  }
}

class _Particula {
  _Particula(this.inicio, this.x, this.y, this.gx, this.gy, this.tam, this.cor, this.dur, this.grav);
  final double inicio, x, y, gx, gy, tam, dur, grav;
  final Color cor;
}

class _Corte {
  _Corte(this.inicio, this.x, this.y, this.ang, this.tam, this.r);
  final double inicio, x, y, tam;
  final int ang, r;
}

class _Flash {
  _Flash(this.inicio, this.alfa, this.dur);
  final double inicio, alfa, dur;
}

class _Vinheta {
  _Vinheta(this.inicio, this.sobe, this.segura);
  final double inicio, sobe, segura;
}

class _Poof {
  _Poof(this.inicio, this.x, this.y);
  final double inicio, x, y;
}

class _Lamina {
  _Lamina(this.inicio, this.x0, this.y0, this.dx, this.r);
  final double inicio, x0, y0, dx;
  final int r;
}

const _cinzaPreto = Color(0xFF1A1030);

Color _hex(String h) => Color(0xFF000000 | int.parse(h.substring(1), radix: 16));

Color _misturar(Color c, double w) {
  int f(double v) => (v * 255 + (255 - v * 255) * w).round().clamp(0, 255);
  return Color.fromARGB(255, f(c.r), f(c.g), f(c.b));
}

List<Color> _pal(int r) {
  final c = corRaridade[r.clamp(0, 7)];
  return r == 0 ? [Colors.white, c] : [_misturar(c, 0.82), c];
}

List<Color> _spR(int r) {
  final p = _pal(r);
  return [p[0], p[1], p[1], Colors.white];
}

/// Pixels do corte (`slashSheet`): 5 quadros de 28x28, cacheados por (ângulo, raridade).
final Map<String, List<List<(int, int, Color)>>> _cacheCorte = {};
List<List<(int, int, Color)>> _quadrosCorte(int ang, int r) {
  return _cacheCorte.putIfAbsent('$ang|$r', () {
    final rnd = math.Random(ang * 31 + r);
    double rr(double a, double b) => a + rnd.nextDouble() * (b - a);
    const n = 28, quadros = 5;
    final pal = _pal(r);
    final a = ang * math.pi / 180, ca = math.cos(a), sa = math.sin(a);
    (double, double) p(double t) {
      final x = (1 - t) * (1 - t) * 2 + 2 * (1 - t) * t * 12 + t * t * 25;
      final y = (1 - t) * (1 - t) * 25 + 2 * (1 - t) * t * 10 + t * t * 3;
      final dx = x - 14, dy = y - 14;
      return (14 + dx * ca - dy * sa, 14 + dx * sa + dy * ca);
    }

    final out = <List<(int, int, Color)>>[];
    for (var f = 0; f < quadros; f++) {
      final px = <(int, int, Color)>[];
      void dot(double x, double y, double raio, Color cl) {
        final q = raio.ceil();
        for (var j = -q; j <= q; j++) {
          for (var i = -q; i <= q; i++) {
            if (i * i + j * j <= raio * raio + .3) px.add(((x + i).round(), (y + j).round(), cl));
          }
        }
      }

      final head = f < 3 ? (f + 1) / 3 : 1.0, tail = f < 3 ? 0.0 : (f - 2) * .38;
      for (var layer = 0; layer < 3; layer++) {
        for (var s = tail; s <= head; s += .012) {
          final denom = (1 - tail) == 0 ? 1.0 : (1 - tail);
          final w = .45 + 1.35 * math.sin(math.pi * ((s - tail) / denom).clamp(0.0, 1.0)) * (f >= 3 ? .8 : 1);
          final (x, y) = p(s);
          final cl = [_cinzaPreto, pal[1], pal[0]][layer];
          final raio = [w + 1, w, math.max(.4, w - .9)][layer];
          dot(x, y, raio, cl);
        }
      }
      if (f >= 3) {
        px.clear();
        for (var k = 0; k < 7; k++) {
          final s = rr(.15, .95);
          final (x, y) = p(s);
          dot(x + rr(-3, 3), y + rr(-3, 3), .6, k % 2 == 1 ? pal[0] : pal[1]);
        }
      }
      out.add(px);
    }
    return out;
  });
}

/// A lâmina em meia-lua arremessada (`laminaImg`): 22x26.
final Map<int, List<(int, int, Color)>> _cacheLamina = {};
List<(int, int, Color)> _pixelsLamina(int r) => _cacheLamina.putIfAbsent(r, () {
      final p = _pal(r);
      final out = <(int, int, Color)>[];
      for (var y = 0; y < 26; y++) {
        for (var x = 0; x < 22; x++) {
          final d1 = math.sqrt(math.pow(x - 4, 2) + math.pow(y - 13, 2)), d2 = math.sqrt(math.pow(x - 11, 2) + math.pow(y - 13, 2));
          if (d1 <= 13 && d2 >= 9.4) {
            final edge = d1 > 11.4 || d2 < 10.6;
            out.add((x, y, (d1 > 12 || d2 < 10) ? _cinzaPreto : (edge ? p[1] : p[0])));
          }
        }
      }
      return out;
    });

/// Geometria da arena que os estilos usam (`ctx()` do JS), em px da própria arena.
class GeometriaGolpe {
  const GeometriaGolpe({required this.heroi, required this.monstro, required this.arena});
  final Rect heroi;
  final Rect monstro;
  final Size arena;
  double get dx => math.max(0, monstro.left - heroi.right - 4);
  Offset get c => Offset(monstro.left + monstro.width / 2, monstro.top + monstro.height * .45);
}

/// O motor: relógio em ms, animações por alvo ('h' herói, 'ho' opacidade do herói, 'a' arma, 'm' monstro, 'ar' arena)
/// e as camadas de efeito. Estilos são funções `async` que usam `esperar`, como o JS.
class MotorGolpe extends ChangeNotifier {
  MotorGolpe(TickerProvider vsync) {
    _ticker = vsync.createTicker(_tique);
  }
  late final Ticker _ticker;
  double agora = 0;
  double _desvio = 0; // o relógio do Ticker recomeça do zero a cada start(); o nosso nunca volta atrás
  int _geracao = 0;
  bool emAndamento = false;
  String? _ultimo;
  final _rnd = math.Random();
  final List<_Anim> _anims = [];
  final List<({double quando, Completer<void> c})> _espera = [];
  final List<_Particula> _parts = [];
  final List<_Corte> _cortes = [];
  final List<_Flash> _flashes = [];
  final List<_Vinheta> _vinhetas = [];
  final List<_Lamina> _laminas = [];
  final List<_Poof> _poofs = [];

  /// Nuvem do monstro derrotado (390 ms): círculos brancos que crescem e somem.
  void poof(double x, double y) {
    _poofs.add(_Poof(agora, x, y));
    _acordar();
  }

  // estado persistente do herói (style.transform do JS no estilo "vulto")
  double baseX = 0;
  double baseEscalaX = 1;
  int raridade = 0;
  bool preferenciaVariada = true;
  double _inicioGolpe = 0;
  int _impactoMs = 300;
  ({GeometriaGolpe g, String dif, bool fim, bool distancia})? _pendente;
  bool _aguardando = false;

  void _tique(Duration d) {
    agora = _desvio + d.inMicroseconds / 1000.0;
    final prontos = _espera.where((e) => e.quando <= agora).toList();
    for (final e in prontos) {
      _espera.remove(e);
      e.c.complete();
    }
    _anims.removeWhere((a) => !a.preencher && agora > a.inicio + a.dur);
    _parts.removeWhere((p) => agora > p.inicio + p.dur);
    _cortes.removeWhere((c) => agora > c.inicio + 300);
    _flashes.removeWhere((f) => agora > f.inicio + f.dur);
    _vinhetas.removeWhere((v) => agora > v.inicio + v.sobe + v.segura + 320);
    _laminas.removeWhere((l) => agora > l.inicio + 300);
    _poofs.removeWhere((p) => agora > p.inicio + 400);
    if (!emAndamento && _espera.isEmpty && _parts.isEmpty && _cortes.isEmpty && _flashes.isEmpty && _vinhetas.isEmpty && _laminas.isEmpty && _poofs.isEmpty && !_temAnimAtiva) {
      _ticker.stop();
    }
    notifyListeners();
  }

  bool get _temAnimAtiva => _anims.any((a) => !a.preencher && agora <= a.inicio + a.dur);

  void _acordar() {
    if (!_ticker.isActive) {
      _desvio = agora;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _geracao++;
    for (final e in _espera) {
      if (!e.c.isCompleted) e.c.completeError(const _Cancelado());
    }
    _ticker.dispose();
    super.dispose();
  }

  // ---- leitura para a interface ----
  List<double>? _val(String alvo) {
    for (var i = _anims.length - 1; i >= 0; i--) {
      final a = _anims[i];
      if (a.alvo != alvo) continue;
      final v = a.valor(agora);
      if (v != null) return v;
    }
    return null;
  }

  Offset get heroi {
    final v = _val('h');
    return v != null ? Offset(v[0], v[1]) : Offset(baseX, 0);
  }

  double get heroiEscalaX => _val('h') != null ? 1 : baseEscalaX;
  double get heroiOpacidade => _val('ho')?[0] ?? 1;
  double get armaGraus => _val('a')?[0] ?? 8;
  Offset get monstro {
    final v = _val('m');
    return v != null ? Offset(v[0], v[1]) : Offset.zero;
  }

  double get monstroGiro => (_val('m')?[2] ?? 0) * math.pi / 180;
  Offset get arena {
    final v = _val('ar');
    return v != null ? Offset(v[0], v[1]) : Offset.zero;
  }

  // ---- ferramentas dos estilos ----
  Future<void> _esperar(int ms, int g) {
    final c = Completer<void>();
    _espera.add((quando: agora + ms, c: c));
    _acordar();
    return c.future.then((_) {
      if (g != _geracao) throw const _Cancelado();
    });
  }

  Future<void> _an(String alvo, List<List<double>> valores, num ms, {int delay = 0, Curve curva = Curves.easeOut, List<double>? offsets, int? passos, bool preencher = true}) {
    final n = valores.length;
    final kf = [for (var i = 0; i < n; i++) (offsets != null ? offsets[i] : i / (n - 1), valores[i])];
    _anims.add(_Anim(alvo, agora + delay, ms.toDouble(), kf, curva, passos: passos, preencher: preencher));
    _acordar();
    final f = _esperar((delay + ms).round(), _geracao);
    f.ignore(); // quem não espera pelo fim (como no JS) não recebe erro de cancelamento
    return f;
  }

  double _r(double a, double b) => a + _rnd.nextDouble() * (b - a);
  static const _ou = Curves.easeOut;

  void _particulas(double x, double y, int n, List<Color> cores, {double? s, double? dir, double spread = 0, double v0 = 30, double v1 = 80, double t = 520, double grav = 30}) {
    final maxN = 18 - _parts.length;
    n = math.min(n, math.max(0, maxN));
    for (var i = 0; i < n; i++) {
      final ang = dir != null ? dir + _r(-spread, spread) : _r(0, 6.283);
      final v = _r(v0, v1);
      _parts.add(_Particula(agora, x, y, math.cos(ang) * v, math.sin(ang) * v, s ?? _r(3, 6), cores[i % cores.length], t, grav));
    }
  }

  void _corte(GeometriaGolpe g, double x, double y, double ang, double sz) {
    _cortes.add(_Corte(agora, x, y, ((ang) / 15).round() * 15, sz, raridade));
    if (raridade >= 5) _particulas(x, y, (raridade - 4) * 5, _spR(raridade), v0: 25, v1: 70 + raridade * 6, t: 520, s: 4);
  }

  void _tremer(double p, num ms) {
    final f = <List<double>>[];
    for (var i = 0; i < 9; i++) {
      final k = 1 - i / 9;
      f.add([_r(-p, p) * k, _r(-p, p) * k]);
    }
    f.add([0, 0]);
    _an('ar', f, ms, passos: 10, preencher: false);
  }

  void _piscarMonstro(num ms) {
    _an('m', [
      [0, 0, 0],
      [-9, 0, -6],
      [7, 0, 5],
      [-3, 0, -2],
      [0, 0, 0],
    ], 200, offsets: const [0, .22, .5, .78, 1], curva: Curves.easeOut);
  }

  void _flash(double a, double ms) {
    _flashes.add(_Flash(agora, a, ms));
    _acordar();
  }

  void _faiscas(GeometriaGolpe g, int n, {double dir = 3.14, double spread = 1.3, double v0 = 30, double v1 = 90, double t = 480, double? s}) =>
      _particulas(g.c.dx - 10, g.c.dy, n, _spR(raridade), dir: dir, spread: spread, v0: v0, v1: v1, t: t, s: s);

  void _empurrar(double kb, double rot, [num ms = 460]) => _an('m', [
        [0, 0, 0],
        [kb, -6, rot],
        [0, 0, 0],
      ], ms, offsets: const [0, .3, 1], curva: const Cubic(0.2, 0.9, 0.3, 1));

  void _giro(List<double> graus, num ms, {int delay = 0, Curve curva = _ou}) => _an('a', [for (final v in graus) [v]], ms, delay: delay, curva: curva);

  /// Dispara um golpe. [fim] = última tarefa (crítico); [dif] escolhe o estilo; [distancia] = arco/besta (golpe simples).
  void golpear({required GeometriaGolpe g, required String dif, required bool fim, required bool distancia}) {
    if (distancia) {
      _geracao++;
      _anims.removeWhere((a) => true);
      _an('h', [
        [0, 0],
        [60, 0],
        [0, 0],
      ], 480, offsets: const [0, .5, 1], curva: Curves.easeInOut);
      _piscarMonstro(200);
      return;
    }
    if (emAndamento && !fim) {
      // toque logo depois de outro: o golpe atual segue até o impacto e então o próximo sai (antes o segundo toque era perdido)
      final decorrido = agora - _inicioGolpe;
      if (decorrido < _impactoMs) {
        _pendente = (g: g, dif: dif, fim: fim, distancia: distancia);
        if (!_aguardando) {
          _aguardando = true;
          _esperar((_impactoMs - decorrido).round(), _geracao).then((_) {
            _aguardando = false;
            final p = _pendente;
            _pendente = null;
            if (p != null) {
              _geracao++;
              _limpar();
              emAndamento = false;
              golpear(g: p.g, dif: p.dif, fim: p.fim, distancia: p.distancia);
            }
          }).catchError((Object _) {
            _aguardando = false;
            _pendente = null;
          });
        }
        return;
      }
      _geracao++; // já passou do impacto: o próximo golpe entra na hora
      _limpar();
      emAndamento = false;
    }
    if (emAndamento) {
      _geracao++;
      _limpar();
    }
    final nome = fim ? 'crit' : _escolher(dif);
    _ultimo = nome;
    _inicioGolpe = agora;
    _impactoMs = const {'rel': 282, 'combo': 150, 'lamina': 570, 'vulto': 310, 'crit': 405}[nome]!;
    emAndamento = true;
    final gen = ++_geracao;
    Future<void> run;
    switch (nome) {
      case 'combo':
        run = _combo(g, gen);
      case 'lamina':
        run = _lamina(g, gen);
      case 'vulto':
        run = _vulto(g, gen);
      case 'crit':
        run = _crit(g, gen);
      default:
        run = _rel(g, gen);
    }
    final tot = const {'rel': 800, 'combo': 1050, 'lamina': 1050, 'vulto': 1500, 'crit': 1300}[nome]!;
    _esperar(tot + 400, gen).then((_) {
      if (gen == _geracao) {
        _limpar();
        emAndamento = false;
        notifyListeners();
      }
    }).catchError((Object _) {});
    run.catchError((Object e) {
      if (e is! _Cancelado) debugPrint('golpe variado falhou: $e');
    }).then((_) {
      if (gen == _geracao) {
        _limpar();
        emAndamento = false;
        notifyListeners();
      }
    });
  }

  /// `escapadaNaArena`: o monstro avança sobre o herói uma vez por tarefa largada; o herói treme a cada pancada.
  void escapada(GeometriaGolpe g, int n) {
    if (n <= 0) return;
    _geracao++;
    _limpar();
    emAndamento = true;
    final gen = _geracao;
    () async {
      try {
        Som.atual.tocar('fuga');
        await _esperar(500, gen);
        final gap = (5200 / n).clamp(150, 650).round();
        final dur = (gap * 0.9).clamp(130, 480).toDouble();
        final dx = math.max(20.0, g.monstro.left - g.heroi.right + 12);
        for (var i = 0; i < n; i++) {
          _an('m', [
            [0, 0, 0],
            [-dx, 0, 0],
            [-dx, 0, 0],
            [0, 0, 0],
          ], dur, offsets: const [0, .4, .55, 1], curva: Curves.easeOut);
          _esperar((dur * 0.4).round(), gen).then((_) {
            Som.atual.tocar('danoHeroi');
            _an('h', [
              [0, 0],
              [-6, 0],
              [4, 0],
              [0, 0],
            ], 200, offsets: const [0, .33, .66, 1]);
          }).catchError((Object _) {});
          await _esperar(gap, gen);
        }
      } catch (e) {
        if (e is! _Cancelado) debugPrint('escapada falhou: $e');
      } finally {
        if (gen == _geracao) {
          _limpar();
          emAndamento = false;
        }
      }
    }();
  }

  void _limpar() {
    _anims.removeWhere((a) => a.alvo != 'ar' || a.preencher);
    baseX = 0;
    baseEscalaX = 1;
    notifyListeners();
  }

  String _escolher(String dif) {
    if (!preferenciaVariada) return 'rel';
    const pool = {
      'trivial': ['rel', 'lamina'],
      'facil': ['rel', 'lamina'],
      'media': ['vulto', 'combo', 'rel'],
      'dificil': ['combo', 'rel'],
    };
    final base = pool[dif] ?? pool['media']!;
    var p = base.where((s) => s != _ultimo).toList();
    if (p.isEmpty) p = base;
    return p[_rnd.nextInt(p.length)];
  }

  // ---------------- os estilos (portados de ESTILOS no JS) ----------------
  Future<void> _rel(GeometriaGolpe g, int gen) async {
    final dx = g.dx;
    Future<void> w(int ms) => _esperar(ms, gen);
    _giro([8, -72], 160);
    await _an('h', [
      [0, 0],
      [-9, 3],
    ], 160);
    await w(0);
    _giro([-72, 28], 130, curva: const Cubic(0.5, 0, 0.9, 0.4));
    _an('h', [
      [-9, 3],
      [dx, -2],
    ], 130, curva: const Cubic(0.5, 0, 0.9, 0.4));
    await w(122);
    _giro([28, 118], 110, curva: const Cubic(0.2, 0.9, 0.4, 1));
    _piscarMonstro(110);
    _corte(g, g.c.dx - 4, g.c.dy - 2, -8, 96);
    _faiscas(g, 16);
    _tremer(5, 260);
    _empurrar(16, 7, 520);
    await w(95);
    _giro([118, 8], 420, delay: 80);
    await _an('h', [
      [dx, -2],
      [dx + 4, 0],
      [0, 0],
    ], 420, offsets: const [0, .2, 1], curva: const Cubic(0.3, 0.8, 0.3, 1));
  }

  Future<void> _combo(GeometriaGolpe g, int gen) async {
    final dx = g.dx;
    Future<void> w(int ms) => _esperar(ms, gen);
    const sw = [
      [-42.0, -42.0, 98.0],
      [98.0, 98.0, -28.0],
      [-28.0, -88.0, 142.0],
    ];
    const ang = [-20.0, 40.0, -95.0];
    _giro([8, -42], 150);
    _an('h', [
      [0, 0],
      [dx - 6, -3],
    ], 150, curva: const Cubic(0.4, 0, 0.8, 0.5));
    await w(150);
    for (var i = 0; i < 3; i++) {
      final last = i == 2;
      _giro(sw[i], last ? 260 : 150, curva: const Cubic(0.2, 0.9, 0.4, 1));
      _corte(g, g.c.dx - 6, g.c.dy + (i - 1) * 4, ang[i], last ? 110 : 84);
      _piscarMonstro(last ? 130 : 70);
      _an('h', [
        [dx - 6 + (i % 2 == 1 ? 4 : 0), -3],
        [dx + (last ? 10 : 0), last ? -8 : -2],
        [dx - 6, -3],
      ], last ? 260 : 150, offsets: const [0, .3, 1]);
      _faiscas(g, last ? 10 : 4, dir: 3.14 - i * .5, spread: 1, v1: last ? 95 : 55, v0: 25, t: 420);
      _tremer(last ? 9 : 3, last ? 320 : 140);
      if (last) {
        _flash(.55, 200);
        _empurrar(34, 14, 620);
        await w(110);
      } else {
        _an('m', [
          [0, 0, 0],
          [6.0 + i * 3, 0, 0],
          [0, 0, 0],
        ], 200, offsets: const [0, .3, 1]);
        await w(i == 1 ? 150 : 120);
      }
    }
    await w(60);
    _giro([142, 8], 420);
    await _an('h', [
      [dx - 6, -3],
      [0, 0],
    ], 420, curva: const Cubic(0.3, 0.8, 0.3, 1));
  }

  Future<void> _lamina(GeometriaGolpe g, int gen) async {
    Future<void> w(int ms) => _esperar(ms, gen);
    _giro([8, -112], 150);
    await _an('h', [
      [0, 0],
      [-6, 0],
    ], 150);
    _giro([-112, 150], 260, curva: const Cubic(0.3, 0.8, 0.3, 1));
    _an('h', [
      [-6, 0],
      [8, 0],
      [0, 0],
    ], 340, offsets: const [0, .5, 1], curva: const Cubic(0.3, 0.8, 0.3, 1));
    await w(120);
    _giro([150, 8], 300, delay: 60);
    final x0 = g.heroi.left + 70, x1 = g.c.dx - 22;
    _laminas.add(_Lamina(agora, x0, g.heroi.top + 22, x1 - x0, raridade));
    await w(300);
    _piscarMonstro(120);
    _corte(g, g.c.dx, g.c.dy, -30, 100);
    _tremer(5, 240);
    _particulas(g.c.dx, g.c.dy, 14, _spR(raridade), dir: 0, spread: 3.1, v0: 25, v1: 75, t: 480);
    _empurrar(14, 6, 460);
    await w(380);
  }

  Future<void> _vulto(GeometriaGolpe g, int gen) async {
    Future<void> w(int ms) => _esperar(ms, gen);
    final atras = math.min(g.monstro.right - g.heroi.left + 2, g.arena.width - 4 - g.heroi.right);
    final cores = [const Color(0xFFB7A8E8), const Color(0xFF8E84C4), const Color(0xFFECE8FF)];
    void px(double x, double y, int n) => _particulas(x, y, n, cores, v0: 15, v1: 50, t: 420, s: 4, grav: -10);
    px(g.heroi.left + 40, g.heroi.top + 44, 14);
    await _an('ho', [
      [1],
      [0],
    ], 110, passos: 3);
    await w(130);
    baseX = atras;
    baseEscalaX = -1;
    px(g.heroi.left + atras + 40, g.heroi.top + 44, 12);
    _an('ho', [
      [0],
      [1],
    ], 110, passos: 3);
    await w(70);
    const cortes = [
      (-35.0, 0, [-60.0, 60.0]),
      (35.0, 34, [70.0, -50.0]),
      (-90.0, 68, [-50.0, 80.0]),
    ];
    for (final (a, dl, s) in cortes) {
      _esperar(dl, gen).then((_) {
        _corte(g, g.c.dx, g.c.dy, a, 96);
        _piscarMonstro(60);
        _tremer(3, 120);
        _giro(s, 90);
      }).catchError((Object _) {});
    }
    await w(150);
    await w(180);
    _flash(.4, 180);
    _tremer(8, 260);
    _empurrar(-26, -12, 600);
    await w(420);
    _an('ho', [
      [1],
      [0],
    ], 90, passos: 3);
    px(g.heroi.left + atras + 40, g.heroi.top + 44, 10);
    await w(120);
    baseX = 0;
    baseEscalaX = 1;
    _giro([80, 8], 10);
    _an('ho', [
      [0],
      [1],
    ], 160, passos: 4);
    px(g.heroi.left + 40, g.heroi.top + 44, 12);
    await w(200);
  }

  Future<void> _crit(GeometriaGolpe g, int gen) async {
    final dx = g.dx;
    Future<void> w(int ms) => _esperar(ms, gen);
    _vinhetas.add(_Vinheta(agora, 260, 420));
    _giro([8, -118], 260);
    await _an('h', [
      [0, 0],
      [-12, 4],
    ], 260);
    await w(260);
    _an('h', [
      [-12, 4],
      [dx, -2],
    ], 150, curva: const Cubic(0.5, 0, 0.9, 0.4));
    await w(135);
    _giro([-118, 148], 130, curva: const Cubic(0.2, 0.9, 0.4, 1));
    await w(10);
    _piscarMonstro(260);
    _flash(.9, 380);
    _corte(g, g.c.dx - 4, g.c.dy, -18, 150);
    _tremer(12, 420);
    _faiscas(g, 14, spread: 1.6, v0: 40, v1: 130, t: 700, s: 5);
    await w(160);
    _empurrar(30, 14, 300);
    _giro([148, 8], 620, delay: 60);
    await _an('h', [
      [dx, -2],
      [0, 0],
    ], 620, delay: 20, curva: const Cubic(0.3, 0.8, 0.3, 1));
  }

  // ---------------- desenho dos efeitos (por cima da arena) ----------------
  void pintar(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    for (final v in _vinhetas) {
      final t = agora - v.inicio, total = v.sobe + v.segura + 320;
      final o = t < v.sobe ? t / v.sobe : (t < v.sobe + v.segura ? 1.0 : 1 - (t - v.sobe - v.segura) / 320);
      final rect = Offset.zero & size;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(center: const Alignment(0, 0.1), radius: 1.0, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7 * o.clamp(0.0, 1.0))], stops: const [0.35, 1]).createShader(rect),
      );
      if (t > total) continue;
    }
    for (final c in _cortes) {
      final t = (agora - c.inicio) / 300;
      if (t < 0) continue;
      final quadro = (t * 5).floor().clamp(0, 4);
      final k = math.max(2, (c.tam / 28).round()).toDouble();
      final w = 28 * k;
      final ox = c.x - w / 2, oy = c.y - w / 2;
      for (final (x, y, cor) in _quadrosCorte(c.ang, c.r)[quadro]) {
        if (x < 0 || y < 0 || x >= 28 || y >= 28) continue;
        canvas.drawRect(Rect.fromLTWH(ox + x * k, oy + y * k, k, k), p..color = cor);
      }
    }
    for (final l in _laminas) {
      final t = ((agora - l.inicio) / 300).clamp(0.0, 1.0);
      final e = const Cubic(0.4, 0, 0.9, 0.6).transform(t);
      final x = l.x0 + l.dx * e;
      final esc = t < .2 ? .6 + .4 * (t / .2) : 1 + .15 * ((t - .2) / .8);
      final op = t < .2 ? .2 + .8 * (t / .2) : 1.0;
      canvas.save();
      canvas.translate(x + 22, l.y0 + 26);
      canvas.scale(esc);
      for (final (px, py, cor) in _pixelsLamina(l.r)) {
        canvas.drawRect(Rect.fromLTWH(px * 2.0 - 22, py * 2.0 - 26, 2, 2), p..color = cor.withValues(alpha: op));
      }
      canvas.restore();
    }
    for (final q in _parts) {
      final t = ((agora - q.inicio) / q.dur).clamp(0.0, 1.0);
      final tq = (t * 6).floor() / 6; // steps(6)
      double x, y, o;
      if (tq < .5) {
        final u = tq / .5;
        x = q.gx * .6 * u;
        y = (q.gy * .6 - 12) * u;
        o = 1;
      } else {
        final u = (tq - .5) / .5;
        x = q.gx * .6 + (q.gx - q.gx * .6) * u;
        y = (q.gy * .6 - 12) + ((q.gy + q.grav) - (q.gy * .6 - 12)) * u;
        o = 1 - u;
      }
      canvas.drawRect(Rect.fromLTWH(q.x + x, q.y + y, q.tam, q.tam), p..color = q.cor.withValues(alpha: o.clamp(0.0, 1.0)));
    }
    for (final q in _poofs) {
      final t = ((agora - q.inicio) / 390).clamp(0.0, 1.0);
      final o = (t < .15 ? t / .15 : 1 - (t - .15) / .85).clamp(0.0, 1.0);
      for (final (dx, dy, r0) in const [(0.0, 0.0, 30.0), (-18.0, 6.0, 22.0), (18.0, 4.0, 24.0), (-6.0, -14.0, 20.0), (8.0, 14.0, 18.0)]) {
        canvas.drawCircle(Offset(q.x + dx * (0.5 + t), q.y + dy * (0.5 + t)), r0 * (0.4 + 1.1 * t), Paint()..color = Colors.white.withValues(alpha: 0.9 * o));
      }
    }
    for (final f in _flashes) {
      final t = ((agora - f.inicio) / f.dur).clamp(0.0, 1.0);
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white.withValues(alpha: f.alfa * (1 - t)));
    }
  }
}

class PintorGolpe extends CustomPainter {
  PintorGolpe(this.motor) : super(repaint: motor);
  final MotorGolpe motor;
  @override
  void paint(Canvas canvas, Size size) => motor.pintar(canvas, size);
  @override
  bool shouldRepaint(PintorGolpe o) => false;
}
