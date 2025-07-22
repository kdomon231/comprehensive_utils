import 'dart:async';

import 'package:comprehensive_utils/src/streams/distinct_connectable_stream.dart';
import 'package:comprehensive_utils/src/streams/distinct_subject.dart';
import 'package:rxdart/streams.dart';

extension StreamDistinctExtensions<T> on Stream<T> {
  /// Creates a `DistinctValueConnectableStream` that emits distinct values from this stream.
  ///
  /// The [equals] function is used to determine if two values are equal. If it is not provided,
  /// the `==` operator is used.
  DistinctValueConnectableStream<T> publishDistinctValue([
    bool Function(T, T)? equals,
  ]) =>
      DistinctValueConnectableStream<T>(this, sync: true, equals: equals);

  /// Creates a `DistinctValueConnectableStream` that emits distinct values from this stream,
  /// starting with the provided [seedValue].
  ///
  /// The [equals] function is used to determine if two values are equal. If it is not provided,
  /// the `==` operator is used.
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

  /// Creates a `DistinctValueStream` that emits distinct values from this stream,
  /// and automatically manages the subscription and cancellation of the underlying stream.
  ///
  /// The [equals] function is used to determine if two values are equal. If it is not provided,
  /// the `==` operator is used.
  ///
  /// Returns a `DistinctValueStream` that emits distinct values from this stream.
  DistinctValueStream<T> shareDistinctValue([bool Function(T, T)? equals]) =>
      publishDistinctValue(equals).refCount();

  /// Creates a `DistinctValueStream` that emits distinct values from this stream,
  /// starting with the provided [seedValue], and automatically manages the subscription
  /// and cancellation of the underlying stream.
  ///
  /// The [equals] function is used to determine if two values are equal. If it is not provided,
  /// the `==` operator is used.
  DistinctValueStream<T> shareDistinctValueSeeded(
    T seedValue, [
    bool Function(T, T)? equals,
  ]) =>
      publishDistinctValueSeeded(seedValue, equals).refCount();

  /// Maps the values of this stream to a new stream of type [R], while ensuring that only distinct
  /// values are emitted.
  ///
  /// If the original stream is a `ValueStream` containing value,
  /// the new stream will start with that value converted to type [R].
  ///
  /// The [convert] function is used to convert each value of this stream to a value of type [R].
  /// The [equals] function is used to determine if two values of type [R] are equal. If it is not
  /// provided, the `==` operator is used.
  ///
  /// Returns a `DistinctValueStream` that emits distinct values of type [R], and automatically
  /// manages the subscription and cancellation of the underlying stream.
  DistinctValueStream<R> mapDistinctValue<R>(R Function(T event) convert,
      [bool Function(R, R)? equals]) {
    if (this case final ValueStream<T> stream when stream.hasValue) {
      return DistinctValueConnectableStream<R>.seeded(
        stream.map(convert),
        convert(stream.value),
        sync: true,
        equals: equals,
      ).refCount();
    }
    return DistinctValueConnectableStream<R>(map(convert),
            sync: true, equals: equals)
        .refCount();
  }
}

extension StreamAsyncExtensions<T> on Stream<T> {
  /// Creates a new `Stream` that emits events from the original `Stream` until the `Future` [trigger] completes.
  ///
  /// The new Stream is closed after the Future completes or when the original Stream is closed.
  /// If the Future completes with an error, the new Stream emits that error and is closed.
  ///
  /// The new Stream is a broadcast Stream if the original Stream is a broadcast Stream.
  Stream<T> takeUntilFuture(Future<void> trigger) {
    final controller = isBroadcast
        ? StreamController<T>.broadcast(sync: true)
        : StreamController<T>(sync: true);

    StreamSubscription<T>? subscription;
    bool isDone = false;
    trigger.then(
      (_) {
        if (isDone) {
          return;
        }
        isDone = true;
        subscription?.cancel();
        controller.close();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isDone) {
          return;
        }
        isDone = true;
        controller
          ..addError(error, stackTrace)
          ..close();
      },
    );

    controller.onListen = () {
      if (isDone) {
        return;
      }
      subscription = listen(
        controller.add,
        onError: controller.addError,
        onDone: () {
          if (isDone) {
            return;
          }
          isDone = true;
          controller.close();
        },
      );
      if (!isBroadcast) {
        controller
          ..onPause = subscription!.pause
          ..onResume = subscription!.resume;
      }
      controller.onCancel = () {
        if (isDone) {
          return null;
        }
        final toCancel = subscription!;
        subscription = null;
        return toCancel.cancel();
      };
    };
    return controller.stream;
  }

  /// Returns the first element of type `R` in the stream.
  ///
  /// Listens to the stream and completes with the first element that is an instance of `R`.
  /// If no such element is found and the stream ends:
  /// - Returns `orElse()` if provided,
  /// - Otherwise throws a `StateError`.
  ///
  /// Stops listening after the first match or on error.
  ///
  /// Example:
  /// ```dart
  /// final result = await stream.firstWhereType<String>();
  /// ```
  ///
  /// Throws:
  /// - `StateError` if no match and `orElse` is null.
  /// - Any error thrown by `orElse()`.
  Future<R> firstWhereType<R>({R Function()? orElse}) {
    final completer = Completer<R>();
    final subscription = listen(
      null,
      onDone: () {
        if (orElse == null) {
          completer.completeError(StateError('No element'), StackTrace.current);
        } else {
          try {
            final replacement = orElse();
            completer.complete(replacement);
          } catch (e, s) {
            completer.completeError(e, s);
          }
        }
      },
      onError: completer.completeError,
      cancelOnError: true,
    );
    subscription.onData((data) {
      if (data is R) {
        subscription.cancel().whenComplete(() => completer.complete(data));
      }
    });
    return completer.future;
  }
}
