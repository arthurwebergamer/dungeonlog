// Folha "Nova tarefa": texto, repetição (hoje / dias da semana / mensal / anual), dificuldade e vezes por dia.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dominio/economia.dart';
import '../dominio/tarefa.dart';
import 'estado_jogo.dart';
import 'tema.dart';

const _nomesDia = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
const _nomesDiaLongo = ['domingo', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'];
const _meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
const _nomesDif = {'trivial': 'Trivial', 'facil': 'Fácil', 'media': 'Média', 'dificil': 'Difícil'};

/// Abre a folha e cria a tarefa no [estado] quando o jogador confirma.
Future<void> abrirNovaTarefa(BuildContext context, EstadoJogo estado, {Tarefa? editar}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: corCard,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => FolhaNovaTarefa(estado: estado, editar: editar),
  );
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
  late final Set<int> _dias;
  int _diaMes = 1;
  int _diaAno = 1;
  int _mesAno = 1;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _dias = {agora.weekday % 7};
    _diaMes = agora.day;
    _diaAno = agora.day;
    _mesAno = agora.month;
    final t = widget.editar;
    if (t != null) {
      _ctrl.text = t.texto ?? '';
      _dif = t.dif;
      _meta = t.meta;
    }
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _valido => _ctrl.text.trim().isNotEmpty && (_modo != ModoTarefa.repete || _dias.isNotEmpty);

  Widget _rotulo(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(t, style: const TextStyle(fontSize: 11, color: corTexto2, letterSpacing: 1)),
      );

  Widget _chip(String rot, bool sel, VoidCallback aoTocar) => ChoiceChip(
        label: Text(rot),
        selected: sel,
        onSelected: (_) {
          HapticFeedback.selectionClick();
          aoTocar();
        },
      );

  void _criar() {
    if (!_valido) return;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 14),
          Text(widget.editar == null ? 'Nova tarefa' : 'Editar tarefa', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _criar(),
            decoration: InputDecoration(
              hintText: 'O que precisa ser feito?',
              filled: true,
              fillColor: corFundo,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          if (widget.editar == null) ...[
          _rotulo('REPETIR'),
          Wrap(spacing: 8, children: [
            _chip('Só hoje', _modo == ModoTarefa.hoje, () => setState(() => _modo = ModoTarefa.hoje)),
            _chip('Dias da semana', _modo == ModoTarefa.repete, () => setState(() => _modo = ModoTarefa.repete)),
            _chip('Todo mês', _modo == ModoTarefa.mensal, () => setState(() => _modo = ModoTarefa.mensal)),
            _chip('Todo ano', _modo == ModoTarefa.anual, () => setState(() => _modo = ModoTarefa.anual)),
          ]),
          if (_modo == ModoTarefa.repete) ...[
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (var i = 0; i < 7; i++)
                Tooltip(
                  message: _nomesDiaLongo[i],
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _dias.contains(i) ? _dias.remove(i) : _dias.add(i));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _dias.contains(i) ? corDestaque : corFundo,
                      ),
                      child: Text(_nomesDia[i], style: TextStyle(fontWeight: FontWeight.w700, color: _dias.contains(i) ? Colors.black : Colors.white70)),
                    ),
                  ),
                ),
            ]),
          ],
          if (_modo == ModoTarefa.mensal) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Text('No dia '),
              DropdownButton<int>(
                value: _diaMes,
                items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
                onChanged: (v) => setState(() => _diaMes = v ?? _diaMes),
              ),
              const Text(' de cada mês'),
            ]),
          ],
          if (_modo == ModoTarefa.anual) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Text('Em '),
              DropdownButton<int>(
                value: _diaAno,
                items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
                onChanged: (v) => setState(() => _diaAno = v ?? _diaAno),
              ),
              const Text(' de '),
              DropdownButton<int>(
                value: _mesAno,
                items: [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(_meses[m - 1]))],
                onChanged: (v) => setState(() => _mesAno = v ?? _mesAno),
              ),
            ]),
          ],
          ],
          _rotulo('DIFICULDADE'),
          Wrap(spacing: 8, children: [
            for (final d in dificuldades) _chip(_nomesDif[d.id]!, _dif == d.id, () => setState(() => _dif = d.id)),
          ]),
          _rotulo('VEZES POR DIA'),
          Row(children: [
            IconButton.filledTonal(onPressed: _meta > 1 ? () => setState(() => _meta--) : null, icon: const Icon(Icons.remove)),
            SizedBox(width: 48, child: Center(child: Text('$_meta', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))),
            IconButton.filledTonal(onPressed: _meta < 9 ? () => setState(() => _meta++) : null, icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.all(14)),
              onPressed: _valido ? _criar : null,
              child: Text(widget.editar == null ? 'Criar tarefa' : 'Salvar'),
            ),
          ),
        ]),
      ),
    );
  }
}
