import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

class ObservableTimer extends RestartableTimer {
  factory ObservableTimer(Duration duration, VoidCallback callback) {
    final Stopwatch stopwatch = Stopwatch();
    final timer = ObservableTimer._(
      duration,
      () {
        stopwatch.stop();
        callback.call();
      },
      stopwatch,
    );
    stopwatch.start();
    return timer;
  }

  ObservableTimer._(super.duration, super.callback, this._stopwatch);

  final Stopwatch _stopwatch;

  Duration get elapsedTime => _stopwatch.elapsed;

  @override
  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    super.reset();
    _stopwatch.start();
  }

  @override
  void cancel() {
    super.cancel();
    _stopwatch.stop();
  }
}
