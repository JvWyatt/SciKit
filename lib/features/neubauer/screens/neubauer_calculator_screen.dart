import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/neubauer_calculator.dart';
import '../state/neubauer_state.dart';

class NeubauerCalculatorScreen extends StatelessWidget {
  const NeubauerCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NeubauerState>();
    final result = state.calculate();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cámara de Neubauer'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NeubauerState>().reset(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _CounterCard(state: state),
            const SizedBox(height: 24),
            _InputsCard(state: state),
            const SizedBox(height: 24),
            if (result != null) _ResultCard(result: result),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.state});

  final NeubauerState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Conteo de células',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '${state.totalCells}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Promedio por cuadro: ${_format(state.average)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: state.incrementCell,
              icon: const Icon(Icons.add),
              label: const Text('Tocar para contar (+1)'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: state.decrementCell,
                  icon: const Icon(Icons.remove),
                  label: const Text('Corregir'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => state.setTotalCells(0),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class _InputsCard extends StatelessWidget {
  const _InputsCard({required this.state});

  final NeubauerState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Parámetros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SegmentedButton<NeubauerSquares>(
              segments: const [
                ButtonSegment(
                  value: NeubauerSquares.four,
                  label: Text('4 cuadros'),
                ),
                ButtonSegment(
                  value: NeubauerSquares.eight,
                  label: Text('8 cuadros'),
                ),
              ],
              selected: {state.squares},
              onSelectionChanged: (s) => state.setSquares(s.first),
            ),
            const SizedBox(height: 16),
            _DilutionField(state: state),
          ],
        ),
      ),
    );
  }
}

class _DilutionField extends StatefulWidget {
  const _DilutionField({required this.state});

  final NeubauerState state;

  @override
  State<_DilutionField> createState() => _DilutionFieldState();
}

class _DilutionFieldState extends State<_DilutionField> {
  late final TextEditingController _controller;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.state.dilution));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _submit() {
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) {
      setState(() => _invalid = true);
    } else {
      setState(() => _invalid = false);
      widget.state.setDilution(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Factor de dilución',
        prefixIcon: const Icon(Icons.science_outlined),
        errorText: _invalid ? 'Debe ser un número mayor que cero.' : null,
      ),
      onFieldSubmitted: (_) => _submit(),
      onEditingComplete: _submit,
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final NeubauerResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Concentración',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${result.formattedConcentration} células/mL',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            _ResultRow(label: 'Conteo total', value: '${result.totalCells}'),
            _ResultRow(label: 'Cuadros', value: '${result.squares}'),
            _ResultRow(
              label: 'Promedio por cuadro',
              value: result.formattedAverage,
            ),
            _ResultRow(
              label: 'Factor de dilución',
              value: _format(result.dilution),
            ),
          ],
        ),
      ),
    );
  }

  String _format(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
