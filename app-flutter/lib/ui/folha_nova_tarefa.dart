// Folha "Nova tarefa" / "Editar tarefa" no visual do app original (#addSheet / #edSheet): campo de texto,
// repetição (Hoje / Semana / Mês / Ano), dificuldade com losangos e vezes por dia.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/economia.dart';
import '../dominio/tarefa.dart';
import 'estado_jogo.dart';
import 'folhas.dart';
import 'icones.dart';
import 'tema.dart';

const _letrasDia = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
const _nomesDiaLongo = ['domingo', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'];
const _siglasDia = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb'];
const _meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
const _nomesDif = {'trivial': 'Trivial', 'facil': 'Fácil', 'media': 'Média', 'dificil': 'Difícil'};

/// `rotulo(t)` do app original: "só hoje", "todo dia", "seg, qua", "todo dia 12", "12 de nov".
String rotuloTarefa(Tarefa t) {
  final d = t.dados;
  int n(String k) => (d[k] is num) ? (d[k] as num).toInt() : 1;
  switch (t.tipo) {
    case 'hoje':
      return 'só hoje';
    case 'mensal':
      return 'todo dia ${n('diaMes')}';
    case 'anual':
      return '${n('diaAno')} de ${_meses[(n('mesAno') - 1).clamp(0, 11)]}';
  }
  final dias = [for (final x in (d['dias'] as List? ?? const [])) if (x is num) x.toInt()]..sort();
  if (dias.length == 7) return 'todo dia';
  return dias.map((x) => _siglasDia[x.clamp(0, 6)]).join(', ');
}

/// `apagarTarefaPerguntando()`: tarefa que se repete pergunta "só hoje" ou "todos os dias"; a de um dia só apaga direto.
Future<void> apagarTarefaPerguntando(BuildContext context, EstadoJogo estado, Tarefa t) async {
  if (!estado.ehRecorrente(t)) {
    estado.apagarTarefa(t);
    return;
  }
  final soHoje = await perguntarApagarRecorrente(context, rotuloTarefa(t));
  if (soHoje != null) estado.apagarTarefa(t, soHoje: soHoje);
}

/// Abre a folha e cria (ou edita) a tarefa no [estado] quando o jogador confirma.
Future<void> abrirNovaTarefa(BuildContext context, EstadoJogo estado, {Tarefa? editar}) async {
  final apagar = await abrirFolha<bool>(context, (_) => FolhaNovaTarefa(estado: estado, editar: editar));
  if (apagar == true && editar != null && context.mounted) await apagarTarefaPerguntando(context, estado, editar);
}

class FolhaNovaTarefa extends StatefulWidget {
  const FolhaNovaTarefa({super.key, required this.estado, this.editar});
  final EstadoJogo estado;

  /// Se informada, a folha edita esta tarefa (texto, dificuldade e vezes por dia).
  final Tarefa? editar;
  @override
  State<FolhaNovaTarefa> createState() => _FolhaNovaTarefaState();
}

class _FolhaNovaTarefaState extends State<FolhaNovaTarefa> {
  final _ctrl = TextEditingController();
  String _modo = ModoTarefa.hoje;
  String _dif = difPadrao;
  int _meta = 1;
  final Set<int> _dias = {};
  int _diaMes = 1;
  int _diaAno = 1;
  int _mesAno = 1;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.parse(widget.estado.hoje);
    _diaMes = hoje.day;
    _diaAno = hoje.day;
    _mesAno = hoje.month;
    final t = widget.editar;
    if (t != null) {
      _ctrl.text = t.texto ?? '';
      _dif = t.dif;
      _meta = t.meta;
    }
    _ctrl.addListener(() {
      if (_dica != null) setState(() => _dica = null);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _dica; // aviso rosa acima do botão (.saveHint), como o tentarCriar() do original

  void _mudar(VoidCallback f) {
    HapticFeedback.selectionClick();
    setState(() {
      f();
      _dica = null;
    });
  }

  void _criar() {
    final falta = _ctrl.text.trim().isEmpty
        ? 'Dê um nome à tarefa'
        : (widget.editar == null && _modo == ModoTarefa.repete && _dias.isEmpty ? 'Escolha pelo menos um dia' : null);
    if (falta != null) {
      HapticFeedback.heavyImpact();
      setState(() => _dica = falta);
      return;
    }
    final t = widget.editar;
    final ok = t != null
        ? widget.estado.editarTarefa(t, texto: _ctrl.text, dif: _dif, meta: _meta)
        : widget.estado.criarTarefa(
            texto: _ctrl.text,
            modo: _modo,
            dif: _dif,
            meta: _meta,
            dias: (_dias.toList()..sort()),
            diaMes: _diaMes,
            diaAno: _diaAno,
            mesAno: _mesAno,
          );
    if (ok) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    }
  }

  // ---------- peças ----------
  Widget _campo() => TextField(
        controller: _ctrl,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _criar(),
        style: const TextStyle(fontSize: 15, color: corTexto),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'O que precisa ser feito?',
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF757575)),
          isDense: true,
          filled: true,
          fillColor: corPainel,
          contentPadding: const EdgeInsets.all(13),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: corLinha, width: 0.8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Colors.white, width: 0.8)),
        ),
      );

  /// Botão de alternativa (.mode / .day): escuro com borda; selecionado fica cinza claro.
  Widget _opcao(String rot, bool sel, VoidCallback aoTocar, {double altura = 32.8, double raio = 8, bool pixel = false, String? dica}) => Expanded(
        child: Toque(
          rotulo: dica,
          aoTocar: () => _mudar(aoTocar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: altura,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? corAtivo : corPainel,
              borderRadius: BorderRadius.circular(raio),
              border: Border.all(color: sel ? corAtivo : corLinha, width: 0.8),
            ),
            child: Text(
              rot,
              style: pixel
                  ? TextStyle(fontFamily: fontePixel, fontSize: 8, color: sel ? Colors.white : corApagado)
                  : TextStyle(fontSize: 12, color: sel ? Colors.white : corSuave),
            ),
          ),
        ),
      );

  Widget _linha(List<Widget> filhos, double vao) => Row(children: [
        for (var i = 0; i < filhos.length; i++) ...[if (i > 0) SizedBox(width: vao), filhos[i]],
      ]);

  Widget _botaoPasso(String sinal, VoidCallback? aoTocar, String rotulo) => Opacity(
        opacity: aoTocar == null ? 0.35 : 1,
        child: Toque(
          rotulo: rotulo,
          aoTocar: aoTocar == null ? null : () => _mudar(aoTocar),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: corPainel, borderRadius: BorderRadius.circular(10), border: Border.all(color: corLinha, width: 0.8)),
            child: Text(sinal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1)),
          ),
        ),
      );

  /// Linha "−  valor  +" (.vezesrow).
  Widget _passo({required String valor, String? sufixo, required VoidCallback? menos, required VoidCallback? mais}) => Row(children: [
        _botaoPasso('−', menos, 'Diminuir'),
        Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            if (sufixo != null) ...[const SizedBox(width: 5), Text(sufixo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))],
          ]),
        ),
        _botaoPasso('+', mais, 'Aumentar'),
      ]);

  Widget _dificuldades() => _linha([
        for (final d in dificuldades)
          Expanded(
            child: Toque(
              aoTocar: () => _mudar(() => _dif = d.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: 56,
                decoration: BoxDecoration(
                  color: _dif == d.id ? corAtivo : corPainel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _dif == d.id ? Colors.white : corLinha, width: 0.8),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Losangos(d.pips, cor: _dif == d.id ? corDificuldade(d.pips) : corApagado),
                  const SizedBox(height: 6),
                  Text(
                    _nomesDif[d.id]!,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1,
                      fontWeight: _dif == d.id ? FontWeight.w600 : FontWeight.w500,
                      color: _dif == d.id ? corDificuldade(d.pips) : corSuave,
                    ),
                  ),
                ]),
              ),
            ),
          ),
      ], 6);

  List<Widget> _repeticao() => [
        const RotuloSecao('Repetição'),
        const SizedBox(height: 7),
        _linha([
          _opcao('Hoje', _modo == ModoTarefa.hoje, () => _modo = ModoTarefa.hoje),
          _opcao('Semana', _modo == ModoTarefa.repete, () => _modo = ModoTarefa.repete),
          _opcao('Mês', _modo == ModoTarefa.mensal, () => _modo = ModoTarefa.mensal),
          _opcao('Ano', _modo == ModoTarefa.anual, () => _modo = ModoTarefa.anual),
        ], 6),
        if (_modo == ModoTarefa.repete) ...[
          const SizedBox(height: 7),
          _linha([
            for (var i = 0; i < 7; i++)
              _opcao(_letrasDia[i], _dias.contains(i), () => _dias.contains(i) ? _dias.remove(i) : _dias.add(i), altura: 28, raio: 7, pixel: true, dica: _nomesDiaLongo[i]),
          ], 4),
        ],
        if (_modo == ModoTarefa.mensal) ...[
          const SizedBox(height: 10),
          const RotuloSecao('Todo dia'),
          const SizedBox(height: 7),
          _passo(valor: '$_diaMes', menos: () => _diaMes = _diaMes <= 1 ? 31 : _diaMes - 1, mais: () => _diaMes = _diaMes >= 31 ? 1 : _diaMes + 1),
        ],
        if (_modo == ModoTarefa.anual) ...[
          const SizedBox(height: 10),
          const RotuloSecao('Dia e mês'),
          const SizedBox(height: 7),
          _passo(valor: '$_diaAno', menos: () => _diaAno = _diaAno <= 1 ? 31 : _diaAno - 1, mais: () => _diaAno = _diaAno >= 31 ? 1 : _diaAno + 1),
          const SizedBox(height: 7),
          _passo(valor: _meses[_mesAno - 1], menos: () => _mesAno = _mesAno <= 1 ? 12 : _mesAno - 1, mais: () => _mesAno = _mesAno >= 12 ? 1 : _mesAno + 1),
        ],
      ];

  @override
  Widget build(BuildContext context) {
    final editando = widget.editar != null;
    final vao = SizedBox(height: editando ? 16 : 10);
    return Folha(titulo: editando ? 'Editar tarefa' : 'Nova tarefa', filhos: [
      _campo(),
      vao,
      if (!editando) ...[..._repeticao(), vao],
      const RotuloSecao('Dificuldade'),
      const SizedBox(height: 7),
      _dificuldades(),
      vao,
      const RotuloSecao('Vezes por dia'),
      const SizedBox(height: 7),
      _passo(valor: '$_meta', sufixo: '×', menos: _meta > 1 ? () => _meta-- : null, mais: _meta < 9 ? () => _meta++ : null),
      if (_dica != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(_dica!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: corVida)),
        ),
      SizedBox(height: editando ? 20 : 24),
      if (!editando)
        BotaoFolha('Criar tarefa', aoTocar: _criar)
      else
        Row(children: [
          Expanded(child: BotaoFolha('Salvar alterações', aoTocar: _criar)),
          const SizedBox(width: 9),
          Toque(
            rotulo: 'Apagar tarefa',
            aoTocar: () => Navigator.pop(context, true),
            child: Container(
              width: 54,
              height: 47.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x59F45781), width: 0.8)),
              child: const Text('×', style: TextStyle(fontSize: 23, color: corVida, height: 1)),
            ),
          ),
        ]),
    ]);
  }
}
