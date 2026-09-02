import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lab_timer.dart';
import '../state/lab_timers_state.dart';
import 'add_timer_dialog.dart';

class LabTimersScreen extends StatelessWidget {
  const LabTimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temporizador'),
        actions: [
          IconButton(
            tooltip: 'Agregar temporizador',
            icon: const Icon(Icons.add),
            onPressed: () => AddTimerDialog.show(context),
          ),
        ],
      ),
      body: const SafeArea(child: _TimerListBody()),
    );
  }
}

class _TimerListBody extends StatelessWidget {
  const _TimerListBody();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LabTimersState>();

    if (state.timers.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.timers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final timer = state.timers[index];
        return _TimerCard(timer: timer);
      },
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.timer});

  final LabTimer timer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.read<LabTimersState>();

    final finished = timer.isFinished;
    final running = timer.isRunning;

    final accentColor = finished
        ? scheme.error
        : (running ? scheme.primary : scheme.onSurfaceVariant);

    return Card(
      color: finished ? scheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    timer.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: finished ? scheme.onErrorContainer : null,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: timer.status),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                timer.formatted,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (finished) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Finalizado',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (finished)
                  FilledButton.icon(
                    onPressed: () => state.restart(timer.id),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reiniciar'),
                  )
                else if (!running)
                  FilledButton.icon(
                    onPressed: () => state.start(timer.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => state.pause(timer.id),
                    icon: const Icon(Icons.pause),
                    label: const Text('Pausar'),
                  ),
                IconButton(
                  tooltip: 'Reiniciar',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () => state.restart(timer.id),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline),
                  color: scheme.error,
                  onPressed: () => _confirmDelete(context, state),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LabTimersState state,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar temporizador?'),
        content: Text('Se eliminará "${timer.name}".'),
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
      state.remove(timer.id);
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TimerStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      TimerStatus.idle => ('Listo', scheme.onSurfaceVariant),
      TimerStatus.running => ('Ejecutando', scheme.primary),
      TimerStatus.paused => ('Pausado', scheme.tertiary),
      TimerStatus.finished => ('Finalizado', scheme.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
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
            Icon(Icons.timer_outlined, size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              'Sin temporizadores',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un temporizador para controlar tiempos de incubación, sedimentación, tinciones y más.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => AddTimerDialog.show(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar temporizador'),
            ),
          ],
        ),
      ),
    );
  }
}
