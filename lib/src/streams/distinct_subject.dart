// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:comprehensive_utils/src/mixins/add_stream_mixin.dart';
import 'package:comprehensive_utils/src/mixins/distinct_mixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/transformers/start_with_error.dart';
import 'package:rxdart/src/utils/empty.dart';

class DistinctSubject<T> extends Subject<T>
    implements BehaviorSubject<T>, DistinctValueStream<T> {
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
      Rx.defer<T>(_deferStream(wrapper, controller), reusable: true),
      wrapper,
    );
  }

  DistinctSubject._(
    super.controller,
    super.stream,
    this._wrapper,
  ) : _controller = controller;

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
      Rx.defer<T>(_deferStream(wrapper, controller), reusable: true),
      wrapper,
    );
  }

  final _Wrapper<T> _wrapper;
  final StreamController<T> _controller;

  static Stream<T> Function() _deferStream<T>(
    _Wrapper<T> wrapper,
    StreamController<T> controller,
  ) =>
      () {
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
          return controller.stream
              .transform(StartWithStreamTransformer<T>(value as T));
        }

        return controller.stream;
      };

  @override
  DistinctValueStream<T> get stream => _DistinctSubjectStream(this);

  @override
  bool get hasValue => isNotEmpty(_wrapper.value);

  @override
  T? get valueOrNull => unbox(_wrapper.value);

  @override
  T get value {
    final value = _wrapper.value;
    if (isNotEmpty(value)) {
      return value as T;
    }
    throw ValueStreamError.hasNoValue();
  }

  @override
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

  @override
  StreamNotification<T>? get lastEventOrNull {
    // data event
    if (_wrapper.isValue) {
      return StreamNotification.data(_wrapper.value as T);
    }

    // error event
    final errorAndSt = _wrapper.errorAndStackTrace;
    if (errorAndSt != null) {
      return ErrorNotification(errorAndSt);
    }

    // no event
    return null;
  }

  @override
  void add(T event) {
    if (_wrapper.isAddingStreamItems) {
      throw StateError(
        'You cannot add items while items are being added from addStream',
      );
    }
    _add(event);
  }

  void _add(T event) => _wrapper.handleData(event, _onAddHandled, _addError);

  void _onAddHandled(T event) {
    if (!_controller.isClosed) {
      _wrapper.setValue(event);
    }

    // if the controller is closed, calling add() will throw an StateError.
    // that is expected behavior.
    _controller.add(event);
  }

  @override
  void onAdd(T event) =>
      _wrapper.handleData(event, _wrapper.setValue, _addError);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_wrapper.isAddingStreamItems) {
      throw StateError(
        'You cannot add an error while items are being added from addStream',
      );
    }
    _addError(error, stackTrace);
  }

  void _addError(Object error, [StackTrace? stackTrace]) {
    if (!_controller.isClosed) {
      onAddError(error, stackTrace);
    }

    // if the controller is closed, calling addError() will throw an StateError.
    // that is expected behavior.
    _controller.addError(error, stackTrace);
  }

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) =>
      _wrapper.setError(error, stackTrace);

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) =>
      _wrapper.addStream(source, _add, _addError, cancelOnError: cancelOnError);
}

class _Wrapper<T> with DistinctMixin<T>, AddStreamMixin<T> {
  _Wrapper([this.equals]) : isValue = false;

  _Wrapper.seeded(this._value, [this.equals]) : isValue = true;

  var _value = EMPTY;
  bool isValue;
  @override
  final bool Function(T, T)? equals;
  ErrorAndStackTrace? errorAndStackTrace;

  @override
  Object? get value => _value;

  void setValue(T event) {
    _value = event;
    isValue = true;
  }

  void setError(Object error, StackTrace? stackTrace) {
    errorAndStackTrace = ErrorAndStackTrace(error, stackTrace);
    isValue = false;
  }
}

class _DistinctSubjectStream<T> extends Stream<T>
    implements DistinctValueStream<T> {
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
    return other is _DistinctSubjectStream &&
        identical(other._subject, _subject);
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

  @override
  StreamNotification<T>? get lastEventOrNull => _subject.lastEventOrNull;
}

abstract class DistinctValueStream<T> implements ValueStream<T> {}
