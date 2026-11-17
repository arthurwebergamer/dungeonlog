// Vibração (feedback tátil) do app: um único ponto, para a preferência "Feedback tátil" de Configurações valer em todo o app.
// Preferência guardada em `questlog.sfx.v1` (campo `feedback`: 'vibrar' ou 'desativado'), a mesma chave do original.
import 'package:flutter/services.dart';

class Vibra {
  Vibra._();

  /// Ligada por padrão (o original vibra a menos que o jogador desligue).
  static bool ligada = true;

  static void toque() {
    if (ligada) HapticFeedback.selectionClick();
  }

  static void leve() {
    if (ligada) HapticFeedback.lightImpact();
  }

  static void media() {
    if (ligada) HapticFeedback.mediumImpact();
  }

  static void forte() {
    if (ligada) HapticFeedback.heavyImpact();
  }
}
