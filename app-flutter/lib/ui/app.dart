// Raiz do app: carrega dados e save, e mostra a barra de navegação (5 abas; só Tarefas está pronta nesta fase).
import 'package:flutter/material.dart';

import '../dados/armazenamento.dart';
import '../dados/carregador_assets.dart';
import 'estado_jogo.dart';
import 'tela_tarefas.dart';
import 'tema.dart';

class DungeonlogApp extends StatelessWidget {
  const DungeonlogApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dungeonlog',
        theme: temaApp(),
        home: const _Carregador(),
      );
}

class _Carregador extends StatefulWidget {
  const _Carregador();
  @override
  State<_Carregador> createState() => _CarregadorState();
}

class _CarregadorState extends State<_Carregador> {
  late final Future<EstadoJogo> _futuro = _iniciar();

  Future<EstadoJogo> _iniciar() async {
    final dados = await carregarDadosJogo();
    final arm = await ArmazenamentoLocal.abrir();
    final estado = EstadoJogo(dados: dados, armazenamento: arm);
    await estado.iniciar();
    return estado;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<EstadoJogo>(
        future: _futuro,
        builder: (_, snap) {
          if (snap.hasError) {
            return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Erro ao carregar:\n${snap.error}'))));
          }
          if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator(color: corDestaque)));
          return Casca(estado: snap.data!);
        },
      );
}

class Casca extends StatefulWidget {
  const Casca({super.key, required this.estado});
  final EstadoJogo estado;
  @override
  State<Casca> createState() => _CascaState();
}

class _CascaState extends State<Casca> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.estado.dados.traducoes;
    final idioma = widget.estado.idioma;
    const futuras = {1: 'Fase 2', 2: 'Fase 2', 3: 'Fase 3', 4: 'Fase 4'};
    return Scaffold(
      body: IndexedStack(index: _aba, children: [
        TelaTarefas(estado: widget.estado),
        for (final i in [1, 2, 3, 4]) Center(child: Text('Em breve (${futuras[i]})', style: const TextStyle(color: corTexto2))),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.checklist), label: t.t('nav.tarefas', idioma)),
          NavigationDestination(icon: const Icon(Icons.backpack_outlined), label: t.t('nav.inventario', idioma)),
          NavigationDestination(icon: const Icon(Icons.storefront_outlined), label: t.t('nav.loja', idioma)),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: t.t('nav.perfil', idioma)),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: t.t('nav.estatisticas', idioma)),
        ],
      ),
    );
  }
}
