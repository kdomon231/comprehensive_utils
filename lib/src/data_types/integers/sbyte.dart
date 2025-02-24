import 'package:comprehensive_utils/src/data_types/integers/signed_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with signed 8-bit integers.
///
/// This extension type allows for easy conversion of integers to signed 8-bit integers and vice versa.
/// It implements the [num] interface.
extension type const SByte._(int value) implements SignedInteger {
  /// Constructs a [SByte] from an [int] value.
  ///
  /// If the value is greater than 127, it will be truncated to 8 bits.
  /// If the value is less than -128, it will be truncated to 8 bits.
  SByte([int value = 0]) : value = value.toSigned(8);

  /// Adds the given [other] value to this [SByte] and returns the result.
  ///
  /// If the result is greater than 127, it will be truncated to 8 bits.
  /// If the result is less than -128, it will be truncated to 8 bits.
  @redeclare
  SByte operator +(int other) => SByte(value + other);

  /// Subtracts the given [other] value from this [SByte] and returns the result.
  ///
  /// If the result is greater than 127, it will be truncated to 8 bits.
  /// If the result is less than -128, it will be truncated to 8 bits.
  @redeclare
  SByte operator -(int other) => SByte(value - other);

  /// Returns the bitwise negation of this [SByte].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying
  /// signed 8-bit integer.
  SByte operator ~() => SByte(~value);
}
