import 'dart:async';

import 'package:comprehensive_utils/src/cache_data/value_cache.dart';

/// Represents a cache instance that stores a value of type [T].
sealed class CacheInstance<T> {
  const CacheInstance._(this._cache);

  final ValueCache<T> _cache;

  /// Returns the cached value if a valid one exists.
  FutureOr<T>? get cachedValue => _cache.cachedValue;

  /// Sets the value of the cache to the provided [value].
  void setValue(FutureOr<T> value) => _cache.setValue(value);

  /// Invalidates the cache, clearing the stored value
  void invalidate() => _cache.invalidate();
}

final class CacheHolder<T> extends CacheInstance<T> {
  factory CacheHolder(Map<String, CacheInstance<Object?>> caches, String key,
      Duration timeToLive) {
    final instance = CacheHolder._(ValueCache<T>(timeToLive));
    caches[key] = instance;
    return instance;
  }

  const CacheHolder._(super.cache) : super._();

  /// Returns the cached value if a valid one exists,
  /// otherwise fetches the data using the provided [callback].
  Future<T> fetchData(Future<T> Function() callback) => _cache.fetch(callback);
}

final class CacheConsumer<T> extends CacheInstance<T> {
  factory CacheConsumer(
    Map<String, CacheInstance<Object?>> caches,
    String key,
    Duration timeToLive,
    Future<T> Function() callback,
  ) {
    final instance = CacheConsumer._(ValueCache<T>(timeToLive), callback);
    caches[key] = instance;
    return instance;
  }

  const CacheConsumer._(super.cache, this._callback) : super._();

  final Future<T> Function() _callback;

  /// Returns the cached value if a valid one exists,
  /// otherwise fetches the data using the stored [_callback].
  Future<T> fetchData() => _cache.fetch(_callback);
}
