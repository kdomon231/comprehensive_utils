import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Extension type on [double] that provides methods for working with floating point numbers.
///
/// This extension type allows for easy conversion of doubles to floating point numbers and vice versa.
/// It implements the [num] interface and provides additional operators for arithmetic operations.
extension type const Float._(double value) implements num {
  /// Constructs a [Float] from a [double] value.
  ///
  /// If no value is provided, it defaults to 0.
  Float([double value = 0]) : value = (Float32List(1)..[0] = value)[0];

  /// Adds the given [other] value to this [Float] and returns the result.
  ///
  /// The result is also a [Float] and is calculated by adding the underlying double values.
  @redeclare
  Float operator +(num other) => Float(value + other);

  /// Subtracts the given [other] value from this [Float] and returns the result.
  ///
  /// The result is also a [Float] and is calculated by subtracting the underlying double values.
  @redeclare
  Float operator -(num other) => Float(value - other);

  /// Returns the underlying double value of this [Float].
  @redeclare
  double toDouble() => value;
}
