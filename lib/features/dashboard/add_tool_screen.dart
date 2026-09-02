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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final tool in ToolRegistry.available) ...[
            _ToolCard(tool: tool, isAdded: dashboard.isAdded(tool.id)),
            const SizedBox(height: 12),
          ],
        ],
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(tool.icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    tool.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isAdded)
              const Icon(Icons.check_circle,
                  color: Colors.green)
            else
              FilledButton(
                onPressed: () => dashboard.addTool(tool.id),
                child: const Text('Agregar'),
              ),
          ],
        ),
      ),
    );
  }
}
