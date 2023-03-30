import 'dart:async';

import 'package:comprehensive_utils/src/streams/distinct_subject.dart';
import 'package:rxdart/rxdart.dart';

abstract class _AbstractDistinctConnectableStream<T, S extends Subject<T>,
    R extends Stream<T>> extends AbstractConnectableStream<T, S, R> {
  _AbstractDistinctConnectableStream(
    super.source,
    super.subject,
  )   : assert(subject is R, 'Wrong Type'),
        _subject = subject;
  final S _subject;
}

class DistinctValueConnectableStream<T>
    extends _AbstractDistinctConnectableStream<T, DistinctSubject<T>,
        DistinctValueStream<T>> implements DistinctValueStream<T> {
  DistinctValueConnectableStream(Stream<T> source,
      {bool sync = false, bool Function(T, T)? equals})
      : super(source, DistinctSubject<T>(sync: sync, equals: equals));

  DistinctValueConnectableStream.seeded(Stream<T> source, T seedValue,
      {bool sync = false, bool Function(T, T)? equals})
      : super(source,
            DistinctSubject<T>.seeded(seedValue, sync: sync, equals: equals));

  @override
  bool get hasValue => _subject.hasValue;

  @override
  T get value => _subject.value;

  @override
  T? get valueOrNull => _subject.valueOrNull;

  @override
  Object get error => _subject.error;

  @override
  Object? get errorOrNull => _subject.errorOrNull;

  @override
  bool get hasError => _subject.hasError;

  @override
  StackTrace? get stackTrace => _subject.stackTrace;
}
