import 'dart:math' as math;

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
            const SizedBox(height: 16),
            _InputsCard(state: state),
            const SizedBox(height: 16),
            if (result != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _ResultCard(result: result),
              ),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatefulWidget {
  const _CounterCard({required this.state});

  final NeubauerState state;

  @override
  State<_CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<_CounterCard> {
  late final TextEditingController _manualController;

  @override
  void initState() {
    super.initState();
    _manualController = TextEditingController(text: '${widget.state.totalCells}');
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _applyManual() {
    final value = int.tryParse(_manualController.text.trim());
    widget.state.setTotalCells(value ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = widget.state;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _manualController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Conteo',
                border: UnderlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (_) => _applyManual(),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.totalCells} células',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 64,
                    child: FilledButton.tonal(
                      onPressed: state.decrementCell,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '−',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 64,
                    child: FilledButton(
                      onPressed: state.incrementCell,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '+1',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            Text(
              'Cuadrantes contados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<NeubauerSquares>(
              segments: [
                for (final s in NeubauerSquares.values)
                  ButtonSegment(
                    value: s,
                    label: Text('${s.count}'),
                    tooltip: '${s.count} cuadrante(s)',
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

enum _DilutionMode { normal, power }

class _DilutionField extends StatefulWidget {
  const _DilutionField({required this.state});

  final NeubauerState state;

  @override
  State<_DilutionField> createState() => _DilutionFieldState();
}

class _DilutionFieldState extends State<_DilutionField> {
  _DilutionMode _mode = _DilutionMode.normal;
  late final TextEditingController _controller;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatForMode(_mode, widget.state.dilution),
    );
    _syncControllerFromDilution();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _powerMode => _mode == _DilutionMode.power;

  String _format(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String _formatForMode(_DilutionMode mode, double value) {
    if (mode == _DilutionMode.power) {
      final exp = (math.log(value) / math.log(10)).round();
      if (value > 0 && (math.pow(10, exp).toDouble() - value).abs() < 1e-9) {
        return '$exp';
      }
      return '0';
    }
    return _format(value);
  }

  void _switchMode(_DilutionMode mode) {
    final dilution = _currentFactor();
    setState(() => _mode = mode);
    _controller.text = _formatForMode(mode, dilution ?? widget.state.dilution);
  }

  double? _currentFactor() {
    final text = _controller.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null || value <= 0) return null;
    return _powerMode ? math.pow(10, value.toInt()).toDouble() : value;
  }

  void _submit() {
    final factor = _currentFactor();
    if (factor == null) {
      setState(() => _invalid = true);
    } else {
      setState(() => _invalid = false);
      widget.state.setDilution(factor);
    }
  }

  void _syncControllerFromDilution() {
    _controller.text = _formatForMode(_mode, widget.state.dilution);
  }

  @override
  Widget build(BuildContext context) {
    final hint = _powerMode
        ? 'n → 2'
        : '1, 2, 10, 100…';
    final prefix = _powerMode ? '10 ^ (' : null;
    final suffix = _powerMode ? ')' : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Factor de dilución',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<_DilutionMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: _DilutionMode.normal, label: Text('Número')),
            ButtonSegment(
              value: _DilutionMode.power,
              label: Text('10 ^ (n)'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => _switchMode(s.first),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 180,
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _powerMode ? 'Exponente' : 'Valor',
              hintText: hint,
              prefixIcon: const Icon(Icons.science_outlined),
              prefixText: prefix,
              suffixText: suffix,
              errorText: _invalid ? 'Debe ser un número mayor que cero.' : null,
            ),
            onChanged: (_) {
              if (_invalid) setState(() => _invalid = false);
            },
            onSubmitted: (_) => _submit(),
            onEditingComplete: _submit,
          ),
        ),
      ],
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
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${result.formattedConcentration} células/mL',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _ResultRow(
                        label: 'Cél. contadas',
                        value: '${result.totalCells}',
                      ),
                      _ResultRow(
                        label: 'Prom. por cuadr.',
                        value: result.formattedAverage,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _ResultRow(
                        label: 'Cuadrante',
                        value: '${result.squares}',
                      ),
                      _ResultRow(
                        label: 'Fx de dilución',
                        value: _format(result.dilution),
                      ),
                    ],
                  ),
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

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$label:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
