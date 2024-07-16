import 'package:comprehensive_utils/src/data_types/integers/unsigned_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with unsigned 64-bit integers.
///
/// This extension type allows for easy conversion of integers to unsigned 64-bit integers and vice versa.
/// It implements the [num] interface.
extension type const ULong._(int value) implements UnsignedInteger {
  /// Constructs a [ULong] from an [int] value.
  ///
  /// If the value is negative, it will be converted to its 64-bit unsigned representation.
  ULong([int value = 0]) : value = value.toUnsigned(64);

  /// Adds the given [other] value to this [ULong] and returns the result.
  ///
  /// If the result is greater than 2^64 - 1, it will be truncated to 64 bits.
  @redeclare
  ULong operator +(int other) => ULong(value + other);

  /// Returns the bitwise negation of this [ULong].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying
  /// unsigned 64-bit integer.
  ULong operator ~() => ULong(~value);
}
