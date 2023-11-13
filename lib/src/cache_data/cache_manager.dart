import 'dart:async';

import 'package:comprehensive_utils/src/cache_data/cache_instance.dart';
import 'package:flutter/foundation.dart';

class CacheManager {
  CacheManager();

  final Map<String, CacheInstance<Object?>> _caches =
      <String, CacheInstance<Object?>>{};

  CacheHolder<T> getBase<T>(String key, Duration timeToLive) {
    final cache = _tryRetrieve<T, CacheHolder<T>>(key);
    return cache ?? CacheHolder<T>(_caches, key, timeToLive);
  }

  CacheHolder<T> retrieveBase<T>(String key) => _caches[key]! as CacheHolder<T>;

  CacheConsumer<T> getConsumer<T>(
      String key, Duration timeToLive, Future<T> Function() callback) {
    final cache = _tryRetrieve<T, CacheConsumer<T>>(key);
    return cache ?? CacheConsumer<T>(_caches, key, timeToLive, callback);
  }

  CacheConsumer<T> retrieveConsumer<T>(String key) =>
      _caches[key]! as CacheConsumer<T>;

  R? _tryRetrieve<T, R extends CacheInstance<T>>(String key) {
    final instance = _caches[key];
    if (instance != null) {
      if (instance is R) {
        return instance;
      }
      instance.invalidate();
    }
    return null;
  }

  void remove(String key) => _caches.remove(key)?.invalidate();

  @mustCallSuper
  void onDispose() {
    _caches
      ..forEach((_, value) => value.invalidate())
      ..clear();
  }
}
