import 'dart:async';

import 'package:comprehensive_utils/src/cache_data/value_cache.dart';

sealed class CacheInstance<T> {
  const CacheInstance._(this._cache);

  final ValueCache<T> _cache;

  FutureOr<T>? get cachedValue => _cache.cachedValue;

  void setValue(FutureOr<T> value) => _cache.setValue(value);

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

  Future<T> fetchData() => _cache.fetch(_callback);
}
