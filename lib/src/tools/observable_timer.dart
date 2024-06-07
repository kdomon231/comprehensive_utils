import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

/// A timer that can be observed for elapsed time and can be reset or canceled.
///
/// This class is a wrapper around [RestartableTimer] that adds the ability to observe the elapsed time.
class ObservableTimer extends RestartableTimer {
  /// Creates a new `ObservableTimer` that will call [callback] after [duration] has elapsed.
  ///
  /// The [callback] will be called with no arguments.
  factory ObservableTimer(Duration duration, VoidCallback callback) {
    final Stopwatch stopwatch = Stopwatch();
    // Create a new ObservableTimer that will call [callback] when the timer expires.
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

  // The stopwatch used to track the elapsed time.
  final Stopwatch _stopwatch;

  /// The elapsed time since the timer was created or last reset.
  Duration get elapsedTime => _stopwatch.elapsed;

  /// Resets the timer to its initial state.
  ///
  /// If the timer is currently running, it will be stopped and restarted.
  @override
  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    super.reset();
    _stopwatch.start();
  }

  /// Cancels the timer and stops tracking the elapsed time.
  @override
  void cancel() {
    super.cancel();
    _stopwatch.stop();
  }
}
