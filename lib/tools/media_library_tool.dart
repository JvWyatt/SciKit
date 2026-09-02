import 'package:flutter/material.dart';

import '../features/media_library/screens/media_library_screen.dart';
import 'tool_definition.dart';

/// Primera herramienta de SCIKIT: Biblioteca de Medios.
class MediaLibraryTool extends ToolDefinition {
  const MediaLibraryTool();

  static const _id = 'media_library';

  @override
  String get id => _id;

  @override
  String get name => 'Biblioteca de Medios';

  @override
  String get description =>
      'Guarda fórmulas de medios y calcula las cantidades necesarias para preparar diferentes volúmenes.';

  @override
  IconData get icon => Icons.science;

  @override
  Widget buildScreen(BuildContext context) => const MediaLibraryScreen();
}
