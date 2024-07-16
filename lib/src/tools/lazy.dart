import 'dart:async';

import 'package:flutter/foundation.dart';

/// A generic class that allows lazy initialization of a value.
///
/// The [Lazy] class provides a way to delay the computation of a value until it is actually needed.
/// It takes a factory function as a parameter, which will be called to compute the value when it is first requested.
/// The computed value is then cached and returned on subsequent requests.
abstract final class Lazy<T> {
  /// Creates a new instance of [Lazy] with the given factory function.
  ///
  /// The [factory] parameter is a function that will be called to compute the value when it is first requested.
  /// It should return the value to be cached.
  factory Lazy(ValueGetter<T> factory) = _Lazy<T, T>;

  /// Creates a new instance of [Lazy] that computes a [Future] value.
  ///
  /// The [factory] parameter is a function that will be called to compute the value when it is first requested.
  /// It should return a [Future] that will complete with the value to be cached.
  static Lazy<FutureOr<T>> async<T>(AsyncValueGetter<T> factory) =>
      _LazyAsync<T>(factory);

  /// Returns the computed value.
  ///
  /// If the value has not been computed yet, it will be computed by calling the factory function provided in the constructor.
  /// The computed value is then cached and returned on subsequent requests.
  T get value;
}

base class _Lazy<T, G extends T> implements Lazy<T> {
  _Lazy(this._factory);

  final ValueGetter<G> _factory;
  T? _value;

  @override
  T get value => _value ??= _factory();
}

final class _LazyAsync<T> extends _Lazy<FutureOr<T>, Future<T>> {
  _LazyAsync(super.factory);

  @override
  FutureOr<T> get value =>
      _value ??= _factory().then((value) => _value = value);
}
