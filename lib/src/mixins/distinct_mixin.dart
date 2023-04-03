// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:rxdart/src/utils/empty.dart';

mixin DistinctMixin<T> {
  abstract final bool Function(T, T)? equals;

  Object? get value;

  void handleData(T inputEvent, void Function(T) add,
      void Function(Object error, [StackTrace? stackTrace]) addError) {
    final previous = value;
    if (identical(previous, EMPTY)) {
      // First event. Cannot use [_equals].
      add(inputEvent);
    } else {
      final T previousEvent = previous as T;
      final equals = this.equals;
      final bool isEqual;
      try {
        if (equals == null) {
          isEqual = previousEvent == inputEvent;
        } else {
          isEqual = equals(previousEvent, inputEvent);
        }
      } catch (e, s) {
        final AsyncError? replacement = Zone.current.errorCallback(e, s);
        addError(replacement?.error ?? e, replacement?.stackTrace ?? s);
        return;
      }
      if (!isEqual) {
        add(inputEvent);
      }
    }
  }
}
