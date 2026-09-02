import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/lab_timer.dart';

class LabTimersState extends ChangeNotifier {
  final List<LabTimer> _timers = [];
  Timer? _ticker;
  int _nextId = 1;

  List<LabTimer> get timers => List.unmodifiable(_timers);

  LabTimer add({required String name, required Duration duration}) {
    final timer = LabTimer(
      id: _nextId++,
      name: name,
      totalSeconds: duration.inSeconds,
    );
    _timers.insert(0, timer);
    notifyListeners();
    return timer;
  }

  void remove(int id) {
    _timers.removeWhere((t) => t.id == id);
    if (_timers.every((t) => !t.isRunning)) {
      _stopTicker();
    }
    notifyListeners();
  }

  void start(int id) {
    final timer = _find(id);
    if (timer == null || timer.isFinished) {
      return;
    }
    if (timer.isRunning) {
      return;
    }
    final remaining = timer.remainingSeconds;
    if (remaining <= 0) {
      timer.status = TimerStatus.finished;
      notifyListeners();
      return;
    }
    timer.status = TimerStatus.running;
    timer.endAt = _now() + remaining * 1000;
    _ensureTicker();
    notifyListeners();
  }

  void pause(int id) {
    final timer = _find(id);
    if (timer == null || !timer.isRunning) {
      return;
    }
    _refreshRemaining(timer);
    timer.status = TimerStatus.paused;
    timer.endAt = null;
    if (_timers.every((t) => !t.isRunning)) {
      _stopTicker();
    }
    notifyListeners();
  }

  void resume(int id) {
    final timer = _find(id);
    if (timer == null || timer.status != TimerStatus.paused) {
      return;
    }
    if (timer.remainingSeconds <= 0) {
      timer.status = TimerStatus.finished;
      timer.endAt = null;
      _stopTicker();
      notifyListeners();
      return;
    }
    timer.status = TimerStatus.running;
    timer.endAt = _now() + timer.remainingSeconds * 1000;
    _ensureTicker();
    notifyListeners();
  }

  void restart(int id) {
    final timer = _find(id);
    if (timer == null) {
      return;
    }
    timer.remainingSeconds = timer.totalSeconds;
    timer.status = TimerStatus.idle;
    timer.endAt = null;
    if (_timers.every((t) => !t.isRunning)) {
      _stopTicker();
    }
    notifyListeners();
  }

  LabTimer? _find(int id) {
    for (final t in _timers) {
      if (t.id == id) {
        return t;
      }
    }
    return null;
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  void _ensureTicker() {
    if (_ticker != null) {
      return;
    }
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    var anyRunning = false;
    for (final timer in _timers) {
      if (timer.isRunning) {
        _refreshRemaining(timer);
        if (timer.isRunning) {
          anyRunning = true;
        }
      }
    }
    if (!anyRunning) {
      _stopTicker();
    }
    notifyListeners();
  }

  void _refreshRemaining(LabTimer timer) {
    final endAt = timer.endAt;
    if (endAt == null) {
      return;
    }
    final remainingMl = endAt - _now();
    if (remainingMl <= 0) {
      timer.remainingSeconds = 0;
      timer.status = TimerStatus.finished;
      timer.endAt = null;
    } else {
      timer.remainingSeconds = (remainingMl / 1000).ceil();
    }
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
