import 'package:meta/meta.dart';

extension type const UnsignedInteger(int value) implements num {
  /// Returns `false`, as a [UnsignedInteger] is never `NaN`.
  @redeclare
  bool get isNaN => false;

  /// Returns `false`, as a [UnsignedInteger] is never negative.
  @redeclare
  bool get isNegative => false;

  /// Returns `false`, as a [UnsignedInteger] is never infinite.
  @redeclare
  bool get isInfinite => false;

  /// Returns `true`, as a [UnsignedInteger] is always finite.
  @redeclare
  bool get isFinite => true;

  /// Returns the underlying integer value of this [UnsignedInteger].
  @redeclare
  int toInt() => value;
}
