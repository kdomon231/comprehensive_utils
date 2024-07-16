import 'dart:typed_data';

import 'package:meta/meta.dart';

extension type const Float._(double value) implements num {
  Float([double value = 0]) : value = (Float32List(1)..[0] = value)[0];

  @redeclare
  Float operator +(double other) => Float(value + other);

  @redeclare
  double toDouble() => value;
}
