// Pequenos ajustes para o Dart se comportar como o JavaScript do app atual nas contas de jogo.

/// Math.round do JS: arredonda metade para +infinito (Dart arredonda metade para longe do zero).
int jsRound(num x) {
  final f = x.floorToDouble();
  return (x - f >= 0.5 ? f + 1 : f).toInt();
}

/// Equivale a `Number(v) || 0` do JS (NaN, null, undefined, '' viram 0).
num numeroOu0(Object? v) {
  num r;
  if (v is num) {
    r = v;
  } else if (v is String) {
    final s = v.trim();
    r = s.isEmpty ? 0 : (num.tryParse(s) ?? double.nan);
  } else if (v is bool) {
    r = v ? 1 : 0;
  } else {
    r = 0;
  }
  return (r.isNaN) ? 0 : r;
}

/// Divisão inteira com piso (floor), como `Math.floor(a / b)`.
int divPiso(int a, int b) => (a / b).floor();

/// `x` como int quando for inteiro (para o JSON sair igual ao do JS: 345 e não 345.0).
Object normalizaNumero(num x) => (x is double && x.isFinite && x == x.truncateToDouble()) ? x.toInt() : x;
