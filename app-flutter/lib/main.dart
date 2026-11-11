import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xFF13101C),
  ));
  runApp(const DungeonlogApp());
}

const bg = Color(0xFF1A1526);
const card = Color(0xFF241D35);
const accent = Color(0xFFE5A05C);

class DungeonlogApp extends StatelessWidget {
  const DungeonlogApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dungeonlog (Flutter)',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: bg,
          colorScheme: const ColorScheme.dark(primary: accent, surface: card),
          useMaterial3: true,
        ),
        home: const Home(),
      );
}

class Tarefa {
  Tarefa(this.nome, this.dif, {this.feita = false});
  String nome;
  int dif; // 1..4
  bool feita;
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Tarefa> tarefas = [
    Tarefa('Beber agua', 1),
    Tarefa('Estudar 30 min', 2),
    Tarefa('Treinar', 3),
    Tarefa('Arrumar o quarto', 2),
    Tarefa('Ler 10 paginas', 1),
  ];
  int xp = 0;
  int moedas = 0;

  void alternar(Tarefa t) {
    HapticFeedback.selectionClick();
    setState(() {
      t.feita = !t.feita;
      final ganho = 10 * t.dif;
      xp += t.feita ? ganho : -ganho;
      moedas += t.feita ? t.dif : -t.dif;
      if (xp < 0) xp = 0;
      if (moedas < 0) moedas = 0;
    });
  }

  Future<void> adicionar() async {
    HapticFeedback.selectionClick();
    final nova = await showModalBottomSheet<Tarefa>(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => const NovaTarefa(),
    );
    if (nova != null) setState(() => tarefas.insert(0, nova));
  }

  @override
  Widget build(BuildContext context) {
    final nivel = xp ~/ 100 + 1;
    final prog = (xp % 100) / 100;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Row(children: [
              const CircleAvatar(radius: 20, backgroundColor: card, child: Icon(Icons.shield, color: accent)),
              const SizedBox(width: 10),
              Text('Nivel $nivel', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.paid, color: accent),
              const SizedBox(width: 6),
              Text('$moedas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: prog),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                    value: v, minHeight: 10, backgroundColor: card, color: accent),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tarefas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: tarefas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final t = tarefas[i];
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: t.feita ? 0.5 : 1,
                    child: Material(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => alternar(t),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                t.feita ? Icons.check_circle : Icons.radio_button_unchecked,
                                key: ValueKey(t.feita),
                                color: t.feita ? accent : Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(t.nome,
                                  style: TextStyle(
                                      fontSize: 16,
                                      decoration: t.feita ? TextDecoration.lineThrough : null)),
                            ),
                            Text('◆' * t.dif, style: const TextStyle(color: accent, fontSize: 12)),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: adicionar,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}

class NovaTarefa extends StatefulWidget {
  const NovaTarefa({super.key});
  @override
  State<NovaTarefa> createState() => _NovaTarefaState();
}

class _NovaTarefaState extends State<NovaTarefa> {
  final ctrl = TextEditingController();
  int dif = 2;
  String rep = 'Hoje';

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  Widget chips<T>(List<T> itens, T atual, String Function(T) rot, void Function(T) sel) => Wrap(
        spacing: 8,
        children: [
          for (final i in itens)
            ChoiceChip(
              label: Text(rot(i)),
              selected: i == atual,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                setState(() => sel(i));
              },
            )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)))),
        const SizedBox(height: 14),
        const Text('Nova tarefa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'O que precisa ser feito?',
            filled: true,
            fillColor: bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),
        const Text('REPETIR', style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1)),
        const SizedBox(height: 6),
        chips<String>(['Hoje', 'Semana', 'Mes', 'Ano'], rep, (s) => s, (s) => rep = s),
        const SizedBox(height: 14),
        const Text('DIFICULDADE', style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1)),
        const SizedBox(height: 6),
        chips<int>([1, 2, 3, 4], dif, (d) => ['Trivial', 'Facil', 'Medio', 'Dificil'][d - 1], (d) => dif = d),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.all(14)),
            onPressed: () {
              final nome = ctrl.text.trim();
              if (nome.isEmpty) return;
              HapticFeedback.mediumImpact();
              Navigator.pop(context, Tarefa(nome, dif));
            },
            child: const Text('Criar tarefa'),
          ),
        ),
      ]),
    );
  }
}
