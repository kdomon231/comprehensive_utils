import 'package:comprehensive_utils/src/streams/distinct_connectable_stream.dart';
import 'package:comprehensive_utils/src/streams/distinct_subject.dart';

extension CustomStreamExtensions<T> on Stream<T> {
  DistinctValueConnectableStream<T> publishDistinctValue([
    bool Function(T, T)? equals,
  ]) =>
      DistinctValueConnectableStream<T>(this, sync: true, equals: equals);

  DistinctValueConnectableStream<T> publishDistinctValueSeeded(
    T seedValue, [
    bool Function(T, T)? equals,
  ]) =>
      DistinctValueConnectableStream<T>.seeded(
        this,
        seedValue,
        sync: true,
        equals: equals,
      );

  DistinctValueStream<T> shareDistinctValue([bool Function(T, T)? equals]) =>
      publishDistinctValue(equals).refCount();

  DistinctValueStream<T> shareDistinctValueSeeded(
    T seedValue, [
    bool Function(T, T)? equals,
  ]) =>
      publishDistinctValueSeeded(seedValue, equals).refCount();
}
