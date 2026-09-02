import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Apariencia', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<AppThemeMode>(
              groupValue: themeController.mode,
              onChanged: (mode) {
                if (mode != null) {
                  themeController.setMode(mode);
                }
              },
              child: Column(
                children: [
                  for (final mode in AppThemeMode.values)
                    RadioListTile<AppThemeMode>(
                      value: mode,
                      title: Text(switch (mode) {
                        AppThemeMode.system => 'Seguir el tema del sistema',
                        AppThemeMode.light => 'Tema claro',
                        AppThemeMode.dark => 'Tema oscuro',
                      }),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
