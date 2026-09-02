import 'package:flutter_test/flutter_test.dart';
import 'package:scikit/features/lab_timers/models/lab_timer.dart';
import 'package:scikit/features/lab_timers/state/lab_timers_state.dart';

void main() {
  group('LabTimer.formatted', () {
    test('formatea horas, minutos y segundos', () {
      final t = LabTimer(id: 1, name: 'Incubación', totalSeconds: 872);
      t.remainingSeconds = 872;
      expect(t.formatted, '00:14:32');
    });

    test('formato con horas de dos dígitos', () {
      final t = LabTimer(id: 1, name: 'T', totalSeconds: 3661);
      t.remainingSeconds = 3661;
      expect(t.formatted, '01:01:01');
    });

    test('cero se muestra como 00:00:00', () {
      final t = LabTimer(id: 1, name: 'T', totalSeconds: 10);
      t.remainingSeconds = 0;
      expect(t.formatted, '00:00:00');
    });
  });

  group('LabTimersState', () {
    test('add crea un temporizador en estado idle', () {
      final state = LabTimersState();
      final t = state.add(name: 'Incubación', duration: const Duration(minutes: 14));
      expect(state.timers.length, 1);
      expect(t.status, TimerStatus.idle);
      expect(t.totalSeconds, 14 * 60);
      expect(t.remainingSeconds, 14 * 60);
      state.dispose();
    });

    test('add inserta varios temporizadores', () {
      final state = LabTimersState();
      state.add(name: 'A', duration: const Duration(seconds: 10));
      state.add(name: 'B', duration: const Duration(hours: 1));
      expect(state.timers.length, 2);
      state.dispose();
    });

    test('remove elimina el temporizador indicado', () {
      final state = LabTimersState();
      final a = state.add(name: 'A', duration: const Duration(seconds: 10));
      state.add(name: 'B', duration: const Duration(seconds: 20));
      state.remove(a.id);
      expect(state.timers.length, 1);
      expect(state.timers.first.name, 'B');
      state.dispose();
    });

    test('start pone el temporizador en running', () {
      final state = LabTimersState();
      final t = state.add(name: 'Incubación', duration: const Duration(minutes: 5));
      state.start(t.id);
      expect(t.status, TimerStatus.running);
      state.dispose();
    });

    test('pause detiene y conserva tiempo restante', () {
      final state = LabTimersState();
      final t = state.add(name: 'Incubación', duration: const Duration(minutes: 5));
      state.start(t.id);
      final remainingBefore = t.remainingSeconds;
      state.pause(t.id);
      expect(t.status, TimerStatus.paused);
      expect(t.remainingSeconds, lessThanOrEqualTo(remainingBefore));
      state.dispose();
    });

    test('resume reanuda un temporizador pausado', () {
      final state = LabTimersState();
      final t = state.add(name: 'Incubación', duration: const Duration(minutes: 5));
      state.start(t.id);
      state.pause(t.id);
      expect(t.status, TimerStatus.paused);
      state.resume(t.id);
      expect(t.status, TimerStatus.running);
      state.dispose();
    });

    test('restart vuelve al estado idle con el tiempo completo', () {
      final state = LabTimersState();
      final t = state.add(name: 'Incubación', duration: const Duration(minutes: 5));
      state.start(t.id);
      state.pause(t.id);
      state.restart(t.id);
      expect(t.status, TimerStatus.idle);
      expect(t.remainingSeconds, t.totalSeconds);
      state.dispose();
    });

    test('tiempo restante se actualiza mientras corre', () async {
      final state = LabTimersState();
      final t = state.add(name: 'Incubación', duration: const Duration(seconds: 60));
      state.start(t.id);
      // Múltiples ticks (250ms) cruzando al menos un segundo del conteo.
      await Future<void>.delayed(const Duration(milliseconds: 1600));
      expect(t.remainingSeconds, lessThan(60));
      expect(t.remainingSeconds, greaterThanOrEqualTo(57));
      state.dispose();
    });

    test('timeout natural → finished', () async {
      final state = LabTimersState();
      final t = state.add(name: 'Corto', duration: const Duration(milliseconds: 100));
      state.start(t.id);
      // Varios ticks (250ms cada uno) con margen amplio.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(t.status, TimerStatus.finished);
      expect(t.remainingSeconds, 0);
      state.dispose();
    });

    test('restart de un temporizador finalizado lo recupera', () async {
      final state = LabTimersState();
      final t = state.add(name: 'Corto', duration: const Duration(milliseconds: 100));
      state.start(t.id);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(t.status, TimerStatus.finished);
      state.restart(t.id);
      expect(t.status, TimerStatus.idle);
      state.dispose();
    });
  });
}
