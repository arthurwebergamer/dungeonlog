import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dados/conta.dart';
import 'dados/conta_falsa.dart' show ServicoContaIndisponivel;
import 'dados/conta_firebase.dart';
import 'dados/nuvem.dart';
import 'dados/nuvem_firestore.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xFF323232),
  ));
  // Firebase Auth (lê o google-services.json do Android) e Firestore (o save na nuvem, parte B). Se não iniciar, o app
  // abre igual, só sem login e sem nuvem.
  ServicoConta conta;
  RepositorioNuvem? nuvem;
  try {
    final repo = RepositorioNuvemFirestore();
    // excluir conta apaga também saves/{uid} e o histórico (antes de apagar o login, que é quem dá a permissão)
    conta = await ServicoContaFirebase.iniciar(apagarNuvem: repo.apagarTudo);
    RepositorioNuvemFirestore.desligarCacheOffline();
    nuvem = repo;
  } catch (_) {
    conta = const ServicoContaIndisponivel();
  }
  runApp(DungeonlogApp(conta: conta, nuvem: nuvem));
}
