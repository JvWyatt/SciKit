enum TimerStatus { idle, running, paused, finished }

class LabTimer {
  LabTimer({required this.id, required this.name, required this.totalSeconds})
    : remainingSeconds = totalSeconds,
      status = TimerStatus.idle;

  final int id;
  final String name;
  final int totalSeconds;

  int remainingSeconds;
  TimerStatus status;

  /// Marca de tiempo absoluta (millis) cuando se inició o reanudó.
  /// Cuando [status] es running, se usa `endAt - now` para el tiempo restante.
  int? endAt;

  bool get isRunning => status == TimerStatus.running;
  bool get isFinished => status == TimerStatus.finished;

  String get formatted {
    final total = remainingSeconds < 0 ? 0 : remainingSeconds;
    final h = (total ~/ 3600).toString().padLeft(2, '0');
    final m = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
