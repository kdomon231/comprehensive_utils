import 'package:comprehensive_utils/src/data_types/integers/unsigned_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with bytes.
///
/// This extension type allows for easy conversion of integers to bytes and vice versa.
/// It implements the [num] interface.
extension type const Byte._(int value) implements UnsignedInteger {
  /// Constructs a [Byte] from an [int] value.
  ///
  /// If the value is greater than 255, it will be truncated to 8 bits.
  Byte([int value = 0]) : value = value.toUnsigned(8);

  /// Adds the given [other] value to this [Byte] and returns the result.
  ///
  /// If the result is greater than 255, it will be truncated to 8 bits.
  @redeclare
  Byte operator +(int other) => Byte(value + other);

  /// Returns the bitwise negation of this [Byte].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying
  /// unsigned 8-bit integer.
  Byte operator ~() => Byte(~value);
}
