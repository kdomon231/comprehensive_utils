import 'dart:async';

import 'package:comprehensive_utils/src/streams/distinct_connectable_stream.dart';
import 'package:comprehensive_utils/src/streams/distinct_subject.dart';

extension StreamDistinctExtensions<T> on Stream<T> {
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

/// Extension on Stream to add the `takeUntilFuture` method.
///
/// This method creates a new Stream that emits events from the original Stream until a Future completes.
/// After that, the new Stream is closed.
extension StreamAsyncExtensions<T> on Stream<T> {
  /// Creates a new Stream that emits events from the original Stream until a Future completes.
  ///
  /// The new Stream is closed after the Future completes.
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
}
