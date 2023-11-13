import 'package:flutter/foundation.dart';

extension OnTapShortcut<T> on ValueSetter<T> {
  VoidCallback apply(T value) => () => this.call(value);
}

extension OnTapShortcutAsync<T> on AsyncValueSetter<T> {
  AsyncCallback apply(T value) => () => this.call(value);
}
