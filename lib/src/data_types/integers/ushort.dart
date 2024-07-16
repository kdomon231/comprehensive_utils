import 'package:comprehensive_utils/src/data_types/integers/unsigned_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with unsigned 16-bit integers.
///
/// This extension type allows for easy conversion of integers to unsigned 16-bit integers and vice versa.
/// It implements the [num] interface.
extension type const UShort._(int value) implements UnsignedInteger {
  /// Constructs a [UShort] from an [int] value.
  ///
  /// If the value is greater than 65535, it will be truncated to unsigned 16-bit integer.
  UShort([int value = 0]) : value = value.toUnsigned(16);

  /// Adds the given [other] value to this [UShort] and returns the result.
  ///
  /// If the result is greater than 65535, it will be truncated to unsigned 16-bit integer.
  @redeclare
  UShort operator +(int other) => UShort(value + other);

  /// Returns the bitwise negation of this [UShort].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying
  /// unsigned 16-bit integer.
  UShort operator ~() => UShort(~value);
}
