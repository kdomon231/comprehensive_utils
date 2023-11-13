import 'dart:async';

import 'package:async/async.dart';

class ValueCache<T> {
  ValueCache(this._timeToLive) {
    _timer = RestartableTimer(_timeToLive, invalidate)..cancel();
  }

  final Duration _timeToLive;
  late final RestartableTimer _timer;
  FutureOr<T>? _cachedValueFuture;

  FutureOr<T>? get cachedValue => _cachedValueFuture;

  Future<T> fetch(Future<T> Function() callback) async {
    return _cachedValueFuture ??= callback()
      ..whenComplete(_startStaleTimer).ignore();
  }

  void setValue(FutureOr<T> data) {
    _timer.cancel();
    _cachedValueFuture = data;
    _startStaleTimer();
  }

  void invalidate() {
    _timer.cancel();
    _cachedValueFuture = null;
  }

  void _startStaleTimer() => _timer.reset();
}
