import 'package:comprehensive_utils/src/data_types/integers/signed_integer.dart';
import 'package:meta/meta.dart';

/// Extension type on [int] that provides methods for working with signed 16-bit integers.
///
/// This extension type allows for easy conversion of integers to signed 16-bit integers and vice versa.
/// It implements the [num] interface.
extension type const Short._(int value) implements SignedInteger {
  /// Constructs a [Short] from an [int] value.
  ///
  /// If the value is greater than 32767, it will be truncated to 16 bits.
  Short([int value = 0]) : value = value.toSigned(16);

  /// Adds the given [other] value to this [Short] and returns the result.
  ///
  /// If the result is greater than 32767, it will be truncated to 16 bits.
  @redeclare
  Short operator +(int other) => Short(value + other);

  /// Returns the bitwise negation of this [Short].
  ///
  /// This is equivalent to performing a bitwise NOT operation on the underlying
  /// unsigned 16-bit integer.
  Short operator ~() => Short(~value);
}
