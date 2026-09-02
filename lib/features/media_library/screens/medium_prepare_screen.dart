import 'package:flutter/material.dart';

import '../../../logic/preparation_calculator.dart';
import '../../../models/measurement_unit.dart';
import '../../../models/medium.dart';

class MediumPrepareScreen extends StatefulWidget {
  const MediumPrepareScreen({super.key, required this.medium});

  final Medium medium;

  @override
  State<MediumPrepareScreen> createState() => _MediumPrepareScreenState();
}

class _MediumPrepareScreenState extends State<MediumPrepareScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _volumeController;
  late VolumeUnit _volumeUnit;
  List<ComponentResult>? _results;

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController();
    _volumeUnit = VolumeUnit.ml;
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final volume = double.parse(_volumeController.text.trim());
    final results = PreparationCalculator.calculate(
      baseVolumeMl: widget.medium.baseVolumeMl,
      components: widget.medium.components,
      desiredVolume: volume,
      desiredUnit: _volumeUnit,
    );
    setState(() {
      _results = results;
    });
  }

  String get _resultHeader {
    final unit = _volumeUnit.label;
    final value = PreparationCalculator.formatAmount(
      double.parse(_volumeController.text.trim()),
    );
    return 'Para preparar $value $unit de ${widget.medium.name}:';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Preparar: ${widget.medium.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Volumen a preparar',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _volumeController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Volumen a preparar',
                        prefixIcon: Icon(Icons.speed_outlined),
                      ),
                      validator: (v) {
                        final val = double.tryParse(
                            (v ?? '').trim().replaceAll(',', '.'));
                        if (val == null) {
                          return 'Introduce un volumen válido.';
                        }
                        if (val <= 0) {
                          return 'Debe ser mayor que cero.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _calculate(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<VolumeUnit>(
                      initialValue: _volumeUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: VolumeUnit.values
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u.label)))
                          .toList(),
                      onChanged: (u) => setState(() => _volumeUnit = u!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calcular'),
            ),
            if (_results != null) ...[
              const SizedBox(height: 32),
              Text(
                _resultHeader,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _ResultTable(results: _results!),
              const SizedBox(height: 8),
              Text(
                'Cálculo basado en un volumen base de '
                '${_formatBaseVolume()}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBaseVolume() {
    final value = PreparationCalculator.formatAmount(widget.medium.baseVolume);
    return '$value ${widget.medium.baseVolumeUnit.label}';
  }
}

class _ResultTable extends StatelessWidget {
  const _ResultTable({required this.results});

  final List<ComponentResult> results;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < results.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        results[i].component.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${PreparationCalculator.formatAmount(results[i].amount)} '
                      '${results[i].unitLabel}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
