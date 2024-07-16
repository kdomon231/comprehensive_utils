import 'dart:async';

import 'package:async/async.dart';

/// A cache that stores a value for a certain amount of time.
///
/// The value can be fetched from a callback function. If the value is not yet
/// cached, it will be fetched and stored for future use. If the value is already
/// cached, it will be returned immediately.
class ValueCache<T> {
  /// Creates a `ValueCache` with a specified time-to-live.
  ///
  /// The `timeToLive` parameter specifies how long the cached value should be
  /// kept before it is invalidated.
  ValueCache(Duration timeToLive) {
    _timer = RestartableTimer(timeToLive, invalidate)..cancel();
  }

  late final RestartableTimer _timer;
  FutureOr<T>? _cachedValueFuture;

  /// Getter to access the cached value.
  FutureOr<T>? get cachedValue => _cachedValueFuture;

  /// Returns the cached value if available, otherwise fetches the value using the provided [callback].
  /// The fetched value will be cached for future use.
  Future<T> fetch(Future<T> Function() callback) async {
    return _cachedValueFuture ??= callback()
      ..whenComplete(_startStaleTimer).ignore();
  }

  /// Sets a new value in the cache and resets the stale timer.
  void setValue(FutureOr<T> data) {
    _timer.cancel();
    _cachedValueFuture = data;
    _startStaleTimer();
  }

  /// Invalidates the cache by canceling the timer and clearing the cached value.
  void invalidate() {
    _timer.cancel();
    _cachedValueFuture = null;
  }

  void _startStaleTimer() => _timer.reset();
}
