import 'package:flutter/foundation.dart';

extension OnTapShortcut<T> on ValueChanged<T> {
  /// Extension (syntactic sugar) on `void Function(T value)` to provide a convenient way
  /// to assign possible nullable Function to eg. widget's property.
  ///
  /// This is a shorthand for calling `callback != null ? callback : null`.
  ///
  /// Example usage:
  /// ```dart
  /// ValueSetter<int>? onItemTap;
  /// [...]
  /// ListTile(
  ///   onTap: onItemTap?.apply(entry.entity),
  ///   title: Text(entry.entity.name),
  /// ),
  /// ```
  VoidCallback apply(T value) => () => this.call(value);
}

extension OnTapShortcutAsync<T> on AsyncValueSetter<T> {
  /// Extension (syntactic sugar) on `Future<void> Function(T value)` to provide a convenient way
  /// to assign possible nullable async Function to eg. widget's property.
  ///
  /// This is a shorthand for calling `callback != null ? callback : null`.
  ///
  /// Example usage:
  /// ```dart
  /// AsyncValueSetter<int>? onItemTap;
  /// [...]
  /// ListTile(
  ///   onTap: onItemTap?.apply(entry.entity),
  ///   title: Text(entry.entity.name),
  /// ),
  /// ```
  AsyncCallback apply(T value) => () => this.call(value);
}
