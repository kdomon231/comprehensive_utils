import 'dart:async';

import 'package:comprehensive_utils/src/cache_data/cache_instance.dart';
import 'package:flutter/foundation.dart';

/// Manages caching of objects with specified time-to-live durations.
base mixin class CacheManager {
  CacheManager();

  final Map<String, CacheInstance<Object?>> _caches =
      <String, CacheInstance<Object?>>{};

  /// Retrieves the base cache for a specific [key].
  ///
  /// If cache for the [key] does not exist, creates a new cache with provided [timeToLive].
  ///
  /// Parameters:
  /// - key: The key for the cache.
  /// - timeToLive: The duration after which the cache will expire.
  CacheHolder<T> getBase<T>(String key, Duration timeToLive) {
    final cache = _tryRetrieve<T, CacheHolder<T>>(key);
    return cache ?? CacheHolder<T>(_caches, key, timeToLive);
  }

  /// Retrieves the base cache for a specific [key].
  CacheHolder<T> retrieveBase<T>(String key) => _caches[key]! as CacheHolder<T>;

  /// Retrieves the consumer cache for a specific [key].
  ///
  /// If cache for the [key] does not exist, creates a new cache with provided [timeToLive] and [callback].
  ///
  /// Parameters:
  /// - key: The key for the cache.
  /// - timeToLive: The duration after which the cache will expire.
  /// - callback: The function for fetching data.
  CacheConsumer<T> getConsumer<T>(
      String key, Duration timeToLive, Future<T> Function() callback) {
    final cache = _tryRetrieve<T, CacheConsumer<T>>(key);
    return cache ?? CacheConsumer<T>(_caches, key, timeToLive, callback);
  }

  /// Retrieves the consumer cache for a specific [key].
  CacheConsumer<T> retrieveConsumer<T>(String key) =>
      _caches[key]! as CacheConsumer<T>;

  // Tries to retrieve a cache instance for a specific key and type.
  // If the instance is not of the specified type, invalidates the instance.
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

  /// Removes a `CacheInstance` for a specific [key] and invalidates it.
  void remove(String key) => _caches.remove(key)?.invalidate();

  /// Invalidates and removes every existing `CacheInstance`.
  @mustCallSuper
  void onDispose() {
    _caches
      ..forEach((_, value) => value.invalidate())
      ..clear();
  }
}
