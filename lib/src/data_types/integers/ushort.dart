import 'package:comprehensive_utils/src/data_types/integers/unsigned_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with unsigned 16-bit integers.
///
/// This extension type allows for easy conversion of integers to unsigned 16-bit integers and vice versa.
/// It implements the [num] interface.
extension type const UShort._(int value) implements UnsignedInteger {
  /// Constructs a [UShort] from an [int] value.
  ///
  /// If the value is negative or greater than 65535, it will be converted to its 16-bit unsigned representation.
  UShort([int value = 0]) : value = value.toUnsigned(16);

  /// Returns the sum of this [UShort] and the given [other] value.
  ///
  /// The result is also a [UShort] and is calculated by adding the underlying integer values.
  @redeclare
  UShort operator +(int other) => UShort(value + other);

  /// Returns the difference of this [UShort] and the given [other] value.
  ///
  /// The result is also a [UShort] and is calculated by subtracting the underlying integer values.
  @redeclare
  UShort operator -(int other) => UShort(value - other);

  /// Returns the bitwise negation of this [UShort].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying integer value.
  UShort operator ~() => UShort(~value);
}
