import 'package:comprehensive_utils/src/data_types/integers/signed_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with signed bytes.
///
/// This extension type allows for easy conversion of integers to signed bytes and vice versa.
/// It implements the [num] interface.
extension type const SByte._(int value) implements SignedInteger {
  /// Constructs a [SByte] from an [int] value.
  ///
  /// If the value is greater than 255, it will be truncated to signed 8-bit integer.
  SByte([int value = 0]) : value = value.toSigned(8);

  /// Adds the given [other] value to this [SByte] and returns the result.
  ///
  /// If the result is greater than 255, it will be truncated to signed 8-bit integer.
  @redeclare
  SByte operator +(int other) => SByte(value + other);

  /// Returns the bitwise negation of this [SByte].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying
  /// unsigned 8-bit integer.
  SByte operator ~() => SByte(~value);
}
