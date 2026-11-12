// Raiz do app: carrega dados e save, e mostra a barra de navegação do app original (5 ícones; só Tarefas está pronta nesta fase).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dados/armazenamento.dart';
import '../dados/carregador_assets.dart';
import 'estado_jogo.dart';
import 'icones.dart';
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
          if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)));
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
    const futuras = {1: 'Fase 2', 2: 'Fase 2', 3: 'Fase 3', 4: 'Fase 4'};
    return Scaffold(
      body: IndexedStack(index: _aba, children: [
        TelaTarefas(estado: widget.estado),
        for (final i in [1, 2, 3, 4]) Center(child: Text('Em breve (${futuras[i]})', style: const TextStyle(color: corApagado))),
      ]),
      bottomNavigationBar: BarraNavegacao(
        estado: widget.estado,
        aba: _aba,
        aoTrocar: (i) {
          HapticFeedback.selectionClick();
          setState(() => _aba = i);
        },
      ),
    );
  }
}

/// Barra inferior do app original (#nav): 5 ícones sem rótulo e uma pílula cinza que desliza até a aba ativa.
class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({super.key, required this.estado, required this.aba, required this.aoTrocar});
  final EstadoJogo estado;
  final int aba;
  final ValueChanged<int> aoTrocar;

  static const _icones = [IconeApp.tarefas, IconeApp.inventario, IconeApp.loja, IconeApp.perfil, IconeApp.estatisticas];
  static const _chaves = ['nav.tarefas', 'nav.inventario', 'nav.loja', 'nav.perfil', 'nav.estatisticas'];

  @override
  Widget build(BuildContext context) {
    final t = estado.dados.traducoes;
    return Container(
      decoration: const BoxDecoration(color: corPainel, border: Border(top: BorderSide(color: corLinha, width: 0.8))),
      padding: EdgeInsets.fromLTRB(8, 6, 8, 6 + MediaQuery.of(context).viewPadding.bottom),
      child: SizedBox(
        height: 54,
        child: LayoutBuilder(builder: (_, c) {
          final largura = c.maxWidth / 5;
          return Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: largura * aba + (largura - 62) / 2,
              top: 2,
              width: 62,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: corAtivo,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x24FFFFFF), width: 0.8),
                  boxShadow: const [BoxShadow(color: Color(0x14FFFFFF), blurRadius: 10)],
                ),
              ),
            ),
            Row(children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == aba,
                    label: t.t(_chaves[i], estado.idioma),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => aoTrocar(i),
                      child: Center(child: Icone(_icones[i], tamanho: 26, cor: i == aba ? Colors.white : corApagado)),
                    ),
                  ),
                ),
            ]),
          ]);
        }),
      ),
    );
  }
}
