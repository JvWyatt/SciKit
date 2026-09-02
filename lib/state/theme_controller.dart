import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'scikit.theme.mode';

  AppThemeMode _mode = AppThemeMode.system;
  bool _isLoaded = false;

  AppThemeMode get mode => _mode;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefsKey);
    _mode = AppThemeMode.system;
    for (final m in AppThemeMode.values) {
      if (m.name == value) {
        _mode = m;
        break;
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
    notifyListeners();
  }
}
