// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/transformers/start_with_error.dart';
import 'package:rxdart/src/utils/empty.dart';

class DistinctSubject<T> extends Subject<T> implements DistinctValueStream<T> {
  factory DistinctSubject({
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool Function(T, T)? equals,
  }) {
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>(equals);

    return DistinctSubject<T>._(
      controller,
      Rx.defer<T>(_deferStream(wrapper, controller, sync), reusable: true),
      wrapper,
    );
  }

  DistinctSubject._(
    super.controller,
    super.stream,
    this._wrapper,
  );

  factory DistinctSubject.seeded(
    T seedValue, {
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
    bool Function(T, T)? equals,
  }) {
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>.seeded(seedValue, equals);

    return DistinctSubject<T>._(
      controller,
      Rx.defer<T>(_deferStream(wrapper, controller, sync), reusable: true),
      wrapper,
    );
  }

  final _Wrapper<T> _wrapper;

  static Stream<T> Function() _deferStream<T>(_Wrapper<T> wrapper, StreamController<T> controller, bool sync) => () {
        final errorAndStackTrace = wrapper.errorAndStackTrace;
        if (errorAndStackTrace != null && !wrapper.isValue) {
          return controller.stream.transform(
            StartWithErrorStreamTransformer<T>(
              errorAndStackTrace.error,
              errorAndStackTrace.stackTrace,
            ),
          );
        }

        final value = wrapper.value;
        if (isNotEmpty(value) && wrapper.isValue) {
          return controller.stream.transform(StartWithStreamTransformer<T>(value as T));
        }

        return controller.stream;
      };

  @override
  void add(T event) => _wrapper.handleData(event, super.add, super.addError);

  @override
  void onAdd(T event) => _wrapper.setValue(event);

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) => _wrapper.setError(error, stackTrace);

  @override
  DistinctValueStream<T> get stream => _DistinctSubjectStream(this);

  @override
  bool get hasValue => isNotEmpty(_wrapper.value);

  @override
  T get value {
    final value = _wrapper.value;
    if (isNotEmpty(value)) {
      return value as T;
    }
    throw ValueStreamError.hasNoValue();
  }

  @override
  T? get valueOrNull => unbox(_wrapper.value);

  set value(T newValue) => add(newValue);

  @override
  bool get hasError => _wrapper.errorAndStackTrace != null;

  @override
  Object? get errorOrNull => _wrapper.errorAndStackTrace?.error;

  @override
  Object get error {
    final errorAndSt = _wrapper.errorAndStackTrace;
    if (errorAndSt != null) {
      return errorAndSt.error;
    }
    throw ValueStreamError.hasNoError();
  }

  @override
  StackTrace? get stackTrace => _wrapper.errorAndStackTrace?.stackTrace;
}

class _Wrapper<T> {
  _Wrapper([this.equals]) : isValue = false;

  _Wrapper.seeded(this.value, [this.equals]) : isValue = true;

  // ignore: type_annotate_public_apis
  var value = EMPTY;
  ErrorAndStackTrace? errorAndStackTrace;
  bool isValue;
  final bool Function(T, T)? equals;

  void setValue(T event) {
    value = event;
    isValue = true;
  }

  void handleData(T inputEvent, void Function(T) add, void Function(Object error, [StackTrace? stackTrace]) addError) {
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

  void setError(Object error, StackTrace? stackTrace) {
    errorAndStackTrace = ErrorAndStackTrace(error, stackTrace);
    isValue = false;
  }
}

class _DistinctSubjectStream<T> extends Stream<T> implements DistinctValueStream<T> {
  _DistinctSubjectStream(this._subject);

  final DistinctSubject<T> _subject;

  @override
  bool get isBroadcast => true;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _subject.hashCode ^ 0x35323532;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _DistinctSubjectStream && identical(other._subject, _subject);
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _subject.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  Object get error => _subject.error;

  @override
  Object? get errorOrNull => _subject.errorOrNull;

  @override
  bool get hasError => _subject.hasError;

  @override
  bool get hasValue => _subject.hasValue;

  @override
  StackTrace? get stackTrace => _subject.stackTrace;

  @override
  T get value => _subject.value;

  @override
  T? get valueOrNull => _subject.valueOrNull;
}

abstract class DistinctValueStream<T> implements ValueStream<T> {}
