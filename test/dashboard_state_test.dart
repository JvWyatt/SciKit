import 'package:flutter_test/flutter_test.dart';
import 'package:scikit/state/dashboard_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DashboardState> loadedState(List<String> initial) async {
    SharedPreferences.setMockInitialValues(
      {'scikit.dashboard.added_tools': initial},
    );
    final state = DashboardState();
    await state.load();
    return state;
  }

  group('DashboardState.reorderTool', () {
    test('mueve un elemento hacia abajo', () async {
      final state = await loadedState(['a', 'b', 'c']);
      await state.reorderTool(0, 2);
      expect(state.addedTools, ['b', 'c', 'a']);
    });

    test('mueve un elemento hacia arriba', () async {
      final state = await loadedState(['a', 'b', 'c']);
      await state.reorderTool(2, 0);
      expect(state.addedTools, ['c', 'a', 'b']);
    });

    test('persiste el nuevo orden recargando', () async {
      final state = await loadedState(['a', 'b', 'c']);
      await state.reorderTool(1, 0);
      expect(state.addedTools, ['b', 'a', 'c']);

      final reloaded = DashboardState();
      await reloaded.load();
      expect(reloaded.addedTools, ['b', 'a', 'c']);
    });

    test('no rompe el estado con índice inválido', () async {
      final state = await loadedState(['a', 'b']);
      await state.reorderTool(5, 0);
      expect(state.addedTools, ['a', 'b']);
    });
  });

  group('DashboardState.addTool/removeTool', () {
    test('addTool respeta el orden y no duplica', () async {
      final state = await loadedState(const []);
      await state.addTool('a');
      await state.addTool('b');
      await state.addTool('a');
      expect(state.addedTools, ['a', 'b']);
    });

    test('removeTool quita sin afectar el orden restante', () async {
      final state = await loadedState(['a', 'b', 'c']);
      await state.removeTool('b');
      expect(state.addedTools, ['a', 'c']);
    });
  });
}
