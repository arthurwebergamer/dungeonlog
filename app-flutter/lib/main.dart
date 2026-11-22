import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dados/conta.dart';
import 'dados/conta_falsa.dart' show ServicoContaIndisponivel;
import 'dados/conta_firebase.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xFF323232),
  ));
  // Firebase Auth (lê o google-services.json do Android). Se não iniciar, o app abre igual, só sem login.
  ServicoConta conta;
  try {
    conta = await ServicoContaFirebase.iniciar();
  } catch (_) {
    conta = const ServicoContaIndisponivel();
  }
  runApp(DungeonlogApp(conta: conta));
}
