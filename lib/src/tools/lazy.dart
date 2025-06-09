import 'dart:async';

import 'package:flutter/foundation.dart';

/// A generic class that allows lazy initialization of a value.
///
/// The [Lazy] class provides a way to delay the computation of a value until it is actually needed.
/// It takes a factory function as a parameter, which will be called to compute the value when it is first requested.
/// The computed value is then cached and returned on subsequent requests.
final class Lazy<T> {
  /// Creates a new instance of [Lazy] with the given factory function.
  ///
  /// The [factory] parameter is a function that will be called to compute the value when it is first requested.
  /// It should return the value to be cached.
  Lazy(this._factory);

  /// Creates a new instance of [Lazy] that computes a [Future] value.
  ///
  /// The [factory] parameter is a function that will be called to compute the value when it is first requested.
  /// It should return a [Future] that will complete with the value to be cached.
  static Lazy<Future<T>> async<T>(AsyncValueGetter<T> factory) =>
      _LazyAsync<T>(factory);

  final ValueGetter<T> _factory;
  T? _value;

  /// Returns the computed value.
  ///
  /// If the value has not been computed yet, it will be computed by calling the factory function provided in the constructor.
  /// The computed value is then cached and returned on subsequent requests.
  T get value => _value ??= _factory();
}

final class _LazyAsync<T> extends Lazy<Future<T>> {
  _LazyAsync(super.factory);

  @override
  Future<T> get value => _value ??=
      _factory().then((value) => _value = SynchronousFuture<T>(value));
}
