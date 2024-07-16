import 'package:comprehensive_utils/src/data_types/integers/unsigned_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with unsigned 32-bit integers.
///
/// This extension type allows for easy conversion of integers to unsigned 32-bit integers and vice versa.
/// It implements the [num] interface.
extension type const UInt._(int value) implements UnsignedInteger {
  /// Constructs a [UInt] from an [int] value.
  ///
  /// If the value is negative, it will be converted to its 32-bit unsigned representation.
  UInt([int value = 0]) : value = value.toUnsigned(32);

  /// Adds the given [other] value to this [UInt] and returns the result.
  ///
  /// If the result is greater than the maximum 32-bit unsigned integer, it will be truncated to unsigned 64-bit integer.
  @redeclare
  UInt operator +(int other) => UInt(value + other);

  /// Returns the bitwise negation of this [UInt].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying
  /// unsigned 32-bit integer.
  UInt operator ~() => UInt(~value);
}
