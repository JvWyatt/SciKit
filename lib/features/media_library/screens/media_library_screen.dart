import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/medium.dart';
import '../state/media_library_state.dart';
import 'medium_edit_screen.dart';
import 'medium_prepare_screen.dart';

class MediaLibraryScreen extends StatelessWidget {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Medios'),
        actions: [
          IconButton(
            tooltip: 'Agregar medio',
            icon: const Icon(Icons.add),
            onPressed: () => _openEditor(context),
          ),
        ],
      ),
      body: const _MediaListBody(),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MediumEditScreen(medium: null),
      ),
    );
  }
}

class _MediaListBody extends StatelessWidget {
  const _MediaListBody();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaLibraryState>();

    if (!state.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.media.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.media.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final medium = state.media[index];
        return _MediumCard(
          medium: medium,
          onPrepare: () => _openPrepare(context, medium),
          onEdit: () => _openEditorFor(context, medium),
          onDelete: () => _confirmDelete(context, medium),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Medium medium) async {
    final state = context.read<MediaLibraryState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar medio?'),
        content: Text(
          'Se eliminará "${medium.name}" y su fórmula. Esta acción no se puede deshacer.',
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
      await state.deleteMedium(medium.id);
    }
  }

  void _openPrepare(BuildContext context, Medium medium) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MediumPrepareScreen(medium: medium),
      ),
    );
  }

  void _openEditorFor(BuildContext context, Medium medium) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MediumEditScreen(medium: medium),
      ),
    );
  }
}

class _MediumCard extends StatelessWidget {
  const _MediumCard({
    required this.medium,
    required this.onPrepare,
    required this.onEdit,
    required this.onDelete,
  });

  final Medium medium;
  final VoidCallback onPrepare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: const Icon(Icons.science),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medium.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Preparar',
              icon: const Icon(Icons.science_outlined),
              onPressed: onPrepare,
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              color: scheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              'Sin medios guardados',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un medio para guardar su fórmula y calcular cantidades de preparación.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MediumEditScreen(medium: null),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar medio'),
            ),
          ],
        ),
      ),
    );
  }
}
