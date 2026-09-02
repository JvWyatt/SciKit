import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/component.dart';
import '../../../models/measurement_unit.dart';
import '../../../models/medium.dart';
import '../state/media_library_state.dart';

class MediumEditScreen extends StatefulWidget {
  const MediumEditScreen({super.key, this.medium});

  final Medium? medium;

  bool get isEditing => medium != null;

  @override
  State<MediumEditScreen> createState() => _MediumEditScreenState();
}

class _BuilderComponent {
  _BuilderComponent({required String name, required double amount, required this.unit})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: _formatAmount(amount));

  final TextEditingController nameController;
  final TextEditingController amountController;
  ComponentUnit unit;

  static String _formatAmount(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class _MediumEditScreenState extends State<MediumEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _baseVolumeController;
  late VolumeUnit _baseVolumeUnit;
  late final List<_BuilderComponent> _components;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final medium = widget.medium;
    _nameController = TextEditingController(text: medium?.name ?? '');
    _baseVolumeController = TextEditingController(
      text: medium != null ? _BuilderComponent._formatAmount(medium.baseVolume) : '',
    );
    _baseVolumeUnit = medium?.baseVolumeUnit ?? VolumeUnit.ml;
    _components = (medium?.components ?? [])
        .map((c) => _BuilderComponent(
              name: c.name,
              amount: c.amount,
              unit: c.unit,
            ))
        .toList();
    if (_components.isEmpty) {
      _addComponent();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseVolumeController.dispose();
    for (final c in _components) {
      c.nameController.dispose();
      c.amountController.dispose();
    }
    super.dispose();
  }

  void _addComponent() {
    setState(() {
      _components.add(_BuilderComponent(name: '', amount: 0, unit: ComponentUnit.g));
    });
  }

  void _removeComponent(int index) {
    setState(() {
      _components[index].nameController.dispose();
      _components[index].amountController.dispose();
      _components.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final baseVolume = double.parse(_baseVolumeController.text.trim());
    final components = <Component>[];

    for (final c in _components) {
      final compName = c.nameController.text.trim();
      final amount = double.parse(c.amountController.text.trim());
      components.add(Component(name: compName, amount: amount, unit: c.unit));
    }

    final state = context.read<MediaLibraryState>();
    setState(() => _isSaving = true);
    try {
      if (widget.isEditing) {
        await state.updateMedium(
          widget.medium!.id,
          name: name,
          baseVolume: baseVolume,
          baseVolumeUnit: _baseVolumeUnit,
          components: components,
        );
      } else {
        await state.createMedium(
          name: name,
          baseVolume: baseVolume,
          baseVolumeUnit: _baseVolumeUnit,
          components: components,
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    final state = context.read<MediaLibraryState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar medio?'),
        content: Text(
          'Se eliminará "${widget.medium!.name}" y su fórmula. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await state.deleteMedium(widget.medium!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar medio' : 'Nuevo medio'),
        actions: [
          if (widget.isEditing)
            IconButton(
              tooltip: 'Eliminar medio',
              icon: const Icon(Icons.delete_outline),
              onPressed: _isSaving ? null : _delete,
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text('Información general',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del medio',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'El nombre no puede estar vacío.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _baseVolumeController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Volumen base',
                            prefixIcon: Icon(Icons.speed_outlined),
                          ),
                          validator: (v) {
                            final val =
                                double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                            if (val == null) {
                              return 'Introduce un volumen válido.';
                            }
                            if (val <= 0) {
                              return 'Debe ser mayor que cero.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<VolumeUnit>(
                          initialValue: _baseVolumeUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unidad',
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          items: VolumeUnit.values
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u.label)))
                              .toList(),
                          onChanged: (u) => setState(() => _baseVolumeUnit = u!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Componentes', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  ..._components.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ComponentEditor(
                        component: entry.value,
                        canRemove: _components.length > 1,
                        onRemove: () => _removeComponent(index),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: _addComponent,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar componente'),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: Text(
                        widget.isEditing ? 'Guardar cambios' : 'Crear medio'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}

class _ComponentEditor extends StatelessWidget {
  const _ComponentEditor({
    required this.component,
    required this.canRemove,
    required this.onRemove,
  });

  final _BuilderComponent component;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: component.nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Componente',
                      prefixIcon: Icon(Icons.science_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                  ),
                ),
                IconButton(
                  tooltip: 'Eliminar componente',
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: component.amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (v) {
                      final val =
                          double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                      if (val == null) {
                        return 'Número válido';
                      }
                      if (val <= 0) {
                        return '> 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<ComponentUnit>(
                    initialValue: component.unit,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    items: ComponentUnit.values
                        .map((u) =>
                            DropdownMenuItem(value: u, child: Text(u.label)))
                        .toList(),
                    onChanged: (u) => component.unit = u!,
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
