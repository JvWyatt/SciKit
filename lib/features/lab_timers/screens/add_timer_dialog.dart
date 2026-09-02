import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/lab_timers_state.dart';

enum _TimerUnit { seconds, minutes, hours }

class AddTimerDialog extends StatefulWidget {
  const AddTimerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const AddTimerDialog(),
    );
  }

  @override
  State<AddTimerDialog> createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends State<AddTimerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  _TimerUnit _unit = _TimerUnit.minutes;
  static const _unitLabel = {
    _TimerUnit.seconds: 'segundos',
    _TimerUnit.minutes: 'minutos',
    _TimerUnit.hours: 'horas',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final name = _nameController.text.trim();
    final value = double.parse(_durationController.text.trim());
    final multiplier = switch (_unit) {
      _TimerUnit.seconds => 1,
      _TimerUnit.minutes => 60,
      _TimerUnit.hours => 3600,
    };
    final seconds = (value * multiplier).round();
    context.read<LabTimersState>().add(
      name: name,
      duration: Duration(seconds: seconds),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar temporizador'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre del proceso',
                  prefixIcon: Icon(Icons.science_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre no puede estar vacío.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (v) {
                  final val = double.tryParse(
                    (v ?? '').trim().replaceAll(',', '.'),
                  );
                  if (val == null) {
                    return 'Introduce una duración válida.';
                  }
                  if (val <= 0) {
                    return 'Debe ser mayor que cero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<_TimerUnit>(
                initialValue: _unit,
                decoration: const InputDecoration(
                  labelText: 'Unidad de tiempo',
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: _TimerUnit.values
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(_unitLabel[u]!),
                      ),
                    )
                    .toList(),
                onChanged: (u) => setState(() => _unit = u!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Agregar')),
      ],
    );
  }
}
