import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona qué herramientas están agregadas al dashboard.
///
/// Quitar una herramienta del dashboard NO elimina sus datos; solo cambia
/// el estado de "agregada" en las preferencias.
class DashboardState extends ChangeNotifier {
  static const _prefsKey = 'scikit.dashboard.added_tools';

  final List<String> _addedTools = [];
  bool _isLoaded = false;

  List<String> get addedTools => List.unmodifiable(_addedTools);

  bool get isLoaded => _isLoaded;

  bool isAdded(String toolId) => _addedTools.contains(toolId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _addedTools
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey) ?? const []);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addTool(String toolId) async {
    if (_addedTools.contains(toolId)) return;
    _addedTools.add(toolId);
    await _persist();
    notifyListeners();
  }

  Future<void> removeTool(String toolId) async {
    _addedTools.remove(toolId);
    await _persist();
    notifyListeners();
  }

  /// Reordena una herramienta arrastrándola. `newIndex` ya llega ajustado
  /// por `onReorderItem` de ReorderableListView.
  Future<void> reorderTool(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _addedTools.length) return;
    final item = _addedTools.removeAt(oldIndex);
    _addedTools.insert(newIndex.clamp(0, _addedTools.length), item);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _addedTools);
  }
}
