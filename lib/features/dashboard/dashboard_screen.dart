import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/dashboard_state.dart';
import '../../tools/tool_definition.dart';
import '../../tools/tool_registry.dart';
import 'add_tool_screen.dart';
import 'settings_screen.dart';

/// Pantalla principal de SCIKIT.
///
/// Solo barra superior (título) y contenido (estado vacío o lista de
/// herramientas). Sin barra de navegación inferior ni pestañas.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardState>();
    final tools = dashboard.addedTools
        .map(ToolRegistry.byId)
        .whereType<ToolDefinition>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sci-Kit',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Agregar herramienta',
            icon: const Icon(Icons.add),
            onPressed: () => _openAddTool(context),
          ),
        ],
      ),
      body: tools.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'Tu espacio de herramientas científicas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                for (final tool in tools) ...[
                  _ToolCard(tool: tool),
                  const SizedBox(height: 12),
                ],
                if (dashboard.addedTools.length < ToolRegistry.available.length) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _openAddTool(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar herramienta'),
                  ),
                ],
              ],
            ),
    );
  }

  void _openAddTool(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddToolScreen()),
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
            Icon(Icons.science_outlined, size: 72, color: scheme.primary),
            const SizedBox(height: 24),
            Text(
              'Tu espacio de herramientas científicas',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no has agregado ninguna herramienta.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AddToolScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar herramienta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});

  final ToolDefinition tool;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dashboard = context.read<DashboardState>();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTool(context),
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
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Información',
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfo(context),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones',
                onSelected: (value) {
                  if (value == 'remove') {
                    _confirmRemove(context, dashboard);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'remove',
                    child: ListTile(
                      leading: Icon(Icons.remove_circle_outline),
                      title: Text('Quitar del dashboard'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTool(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => tool.buildScreen(context)),
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
        content: Text(tool.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
      BuildContext context, DashboardState dashboard) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Quitar herramienta?'),
        content: const Text(
          'La herramienta se quitará del dashboard, pero sus datos se conservarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await dashboard.removeTool(tool.id);
    }
  }
}
