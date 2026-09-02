import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tools/tool_definition.dart';
import '../../tools/tool_registry.dart';
import '../../state/dashboard_state.dart';

/// Pantalla para agregar una herramienta desde las disponibles.
class AddToolScreen extends StatelessWidget {
  const AddToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar herramienta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            for (final tool in ToolRegistry.available) ...[
              _ToolCard(tool: tool, isAdded: dashboard.isAdded(tool.id)),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.isAdded});

  final ToolDefinition tool;
  final bool isAdded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dashboard = context.read<DashboardState>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(tool.icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tool.name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Información',
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfo(context),
            ),
            if (isAdded)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle, color: Colors.green),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton(
                  onPressed: () => dashboard.addTool(tool.id),
                  child: const Text('Agregar'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(tool.icon),
        ),
        title: Text(tool.name),
        content: Text(tool.description, textAlign: TextAlign.start),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
