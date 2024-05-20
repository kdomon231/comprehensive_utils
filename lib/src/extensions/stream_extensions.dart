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

extension StreamAsyncExtensions<T> on Stream<T> {
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
