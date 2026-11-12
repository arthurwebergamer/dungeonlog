// O motor dos golpes precisa devolver herói, arma e monstro à posição de repouso ao terminar, golpe após golpe.
import 'package:dungeonlog_flutter/ui/golpes_fx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const g = GeometriaGolpe(heroi: Rect.fromLTWH(60, 56, 83, 87), monstro: Rect.fromLTWH(230, 61, 78, 82), arena: Size(362, 188));

  testWidgets('cada estilo termina em repouso e o golpe seguinte também roda (arma equipada)', (tester) async {
    final motor = MotorGolpe(tester);
    addTearDown(motor.dispose);
    final vistos = <String>{};
    for (var i = 0; i < 14; i++) {
      final fim = i % 7 == 6;
      final dif = const ['trivial', 'media', 'dificil', 'media', 'facil', 'media', 'dificil'][i % 7];
      motor.golpear(g: g, dif: dif, fim: fim, distancia: false);
      expect(motor.emAndamento, isTrue, reason: 'golpe #$i começou');
      // meio do golpe: algo se mexeu (herói ou arma saiu do repouso) pelo menos uma vez
      var mexeu = false;
      for (var t = 0; t < 40; t++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (motor.heroi != Offset.zero || motor.armaGraus != 8 || motor.monstro != Offset.zero) mexeu = true;
      }
      expect(mexeu, isTrue, reason: 'golpe #$i (dif $dif, fim $fim) mexeu o herói/arma');
      await tester.pump(const Duration(milliseconds: 500));
      expect(motor.emAndamento, isFalse, reason: 'golpe #$i terminou');
      expect(motor.heroi, Offset.zero, reason: 'herói volta ao lugar (golpe #$i)');
      expect(motor.heroiEscalaX, 1);
      expect(motor.heroiOpacidade, 1);
      expect(motor.armaGraus, 8, reason: 'a espada volta a 8 graus (golpe #$i)');
      expect(motor.monstro, Offset.zero);
      vistos.add('$i');
    }
    expect(vistos.length, 14);
  });

  testWidgets('arma de longo alcance e a cena do monstro que escapou também terminam em repouso', (tester) async {
    final motor = MotorGolpe(tester);
    addTearDown(motor.dispose);
    motor.golpear(g: g, dif: 'media', fim: false, distancia: true);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    expect(motor.heroi, Offset.zero);
    motor.escapada(g, 3);
    for (var t = 0; t < 90; t++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(motor.emAndamento, isFalse);
    expect(motor.heroi, Offset.zero);
    expect(motor.monstro, Offset.zero);
  });
}
