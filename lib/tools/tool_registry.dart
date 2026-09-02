import 'lab_timers_tool.dart';
import 'media_library_tool.dart';
import 'neubauer_tool.dart';
import 'tool_definition.dart';

/// Registro central de herramientas disponibles en SCIKIT.
///
/// Para agregar una herramienta nueva en el futuro, basta con:
/// 1. Definir una subclase de [ToolDefinition].
/// 2. Añadirla a la lista [available].
/// 3. Proveer su estado/persistencia si lo necesita.
class ToolRegistry {
  ToolRegistry._();

  static const List<ToolDefinition> available = [
    MediaLibraryTool(),
    LabTimersTool(),
    NeubauerTool(),
  ];

  static ToolDefinition? byId(String id) {
    for (final tool in available) {
      if (tool.id == id) {
        return tool;
      }
    }
    return null;
  }
}
