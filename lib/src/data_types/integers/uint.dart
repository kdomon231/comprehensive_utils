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
  /// If the value is greater than 2^32 - 1, it will be truncated to 32 bits.
  UInt([int value = 0]) : value = value.toUnsigned(32);

  /// Returns the sum of this [UInt] and the given [other] value.
  ///
  /// The result is also an unsigned 32-bit integer.
  @redeclare
  UInt operator +(int other) => UInt(value + other);

  /// Returns the difference of this [UInt] and the given [other] value.
  ///
  /// The result is also an unsigned 32-bit integer.
  @redeclare
  UInt operator -(int other) => UInt(value - other);

  /// Returns the bitwise NOT of this [UInt].
  ///
  /// The result is also an unsigned 32-bit integer.
  UInt operator ~() => UInt(~value);
}
