import 'dart:async';

import 'package:comprehensive_utils/src/common/typedefs.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

/// Modified version of [AsyncBuilder] from https://pub.dev/packages/async_builder
///
/// A Widget that builds depending on the state of a [Future] or [Stream].
///
/// AsyncBuilder must be given either a [future] or [stream], not both.
///
/// This is similar to [FutureBuilder] and [StreamBuilder] but accepts separate
/// callbacks for each state. Just like the built in builders, the [future] or
/// [stream] should not be created at build time because it would restart
/// every time the ancestor is rebuilt.
///
/// If [stream] is an rxdart [ValueStream] with an existing value, that value
/// will be available on the first build. Otherwise when no data is available
/// this builds either [waiting] if provided, or [builder] with a null value.
///
/// If [initial] is provided, it is used in place of the value before one is
/// available.
///
/// If [retain] is true, the current value is retained when the [stream] or
/// [future] instances change. Otherwise when [retain] is false or omitted, the
/// value is reset.
///
/// If the asynchronous operation completes with an error this builds [error].
/// If [error] is not provided [reportError] is called with the [FlutterErrorDetails].
///
/// When [stream] closes and [closed] is provided, [closed] is built with the
/// last value emitted.
///
/// If [pause] is true, the [StreamSubscription] used to listen to [stream] is
/// paused.
///
/// If the [child] parameter is not null, the same [child] widget is passed
/// back to this [WidgetValueBuilder] and should typically be incorporated
/// in the returned widget tree.
///
/// Example using [future]:
///
/// ```dart
/// AsyncBuilder<String>(
///   future: myFuture,
///   waiting: (context) => Text('Loading...'),
///   builder: (context, value) => Text('$value'),
///   error: (context, error, stackTrace) => Text('Error! $error'),
/// )
/// ```
///
/// Example using [stream]:
///
/// ```dart
/// AsyncBuilder<String>(
///   stream: myStream,
///   waiting: (context) => Text('Loading...'),
///   builder: (context, value) => Text('$value'),
///   error: (context, error, stackTrace) => Text('Error! $error'),
///   closed: (context, value) => Text('$value (closed)'),
/// )
/// ```
class AsyncBuilder<T> extends StatefulWidget {
  /// Creates a widget that builds depending on the state of a [Future] or [Stream].
  const AsyncBuilder({
    required this.builder,
    this.stream,
    this.future,
    this.initial,
    this.waiting,
    this.error,
    this.closed,
    this.retain = true,
    this.pause = false,
    bool? silent,
    this.keepAlive = false,
    this.reportError = FlutterError.reportError,
    this.child,
    super.key,
  })  : silent = silent ?? error != null,
        assert(!((future != null) && (stream != null)),
            'AsyncBuilder should be given either a stream or future'),
        assert(future == null || closed == null,
            'AsyncBuilder should not be given both a future and closed builder');

  @override
  State<StatefulWidget> createState() => _AsyncBuilderState<T>();

  /// The default value builder.
  final WidgetValueBuilder<T> builder;

  /// If provided, this is the stream the widget listens to.
  final Stream<T>? stream;

  /// If provided, this is the future the widget listens to.
  final Future<T>? future;

  /// The initial value used before one is available.
  final T? initial;

  /// The builder that should be called when no data is available.
  final WidgetBuilder? waiting;

  /// The builder that should be called when an error was thrown by the future
  /// or stream.
  final ErrorBuilderFn? error;

  /// The builder that should be called when the stream is closed.
  final WidgetValueBuilder<T>? closed;

  /// Whether or not the current value should be retained when the [stream] or
  /// [future] instances change.
  final bool retain;

  /// Whether or not to suppress printing errors to the console.
  final bool silent;

  /// Whether or not to pause the stream subscription.
  final bool pause;

  /// Whether or not we should send a keep alive
  /// notification with [AutomaticKeepAliveClientMixin].
  final bool keepAlive;

  /// If provided, overrides the function that prints errors to the console.
  final ErrorReporterFn reportError;

  /// A independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree the
  /// [builder] builds depends on the value of the [stream] or [future].
  final Widget? child;
}

class _AsyncBuilderState<T> extends State<AsyncBuilder<T>>
    with AutomaticKeepAliveClientMixin {
  T? _lastValue;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _hasFired = false;
  bool _isClosed = false;
  StreamSubscription<T>? _subscription;

  void _cancel() {
    if (!widget.retain) {
      _lastValue = null;
      _lastError = null;
      _lastStackTrace = null;
      _hasFired = false;
    }
    _isClosed = false;
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    _lastError = error;
    _lastStackTrace = stackTrace;
    if (widget.error != null && mounted) {
      setState(() {});
    }
    if (!widget.silent) {
      widget.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          context: ErrorDescription('While updating AsyncBuilder'),
        ),
      );
    }
  }

  void _initFuture(Future<T> future) {
    _cancel();
    future.then(
      (T value) {
        if (future != widget.future || !mounted) {
          return; // Skip if future changed
        }
        setState(() {
          _lastValue = value;
          _hasFired = true;
        });
      },
      onError: _handleError,
    );
  }

  void _updatePause() {
    if (_subscription case final subscription?) {
      if (widget.pause) {
        if (!subscription.isPaused) {
          subscription.pause();
        }
      } else if (subscription.isPaused) {
        subscription.resume();
      }
    }
  }

  void _initStream(Stream<T> stream) {
    _cancel();
    bool skipFirst = false;
    if (stream is ValueStream<T> && stream.hasValue) {
      skipFirst = true;
      _hasFired = true;
      _lastValue = stream.value;
    }
    _subscription = stream.listen(
      (T event) {
        if (skipFirst) {
          skipFirst = false;
          return;
        }
        setState(() {
          _hasFired = true;
          _lastValue = event;
        });
      },
      onDone: () {
        _isClosed = true;
        if (widget.closed != null) {
          setState(() {});
        }
      },
      onError: _handleError,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.future case final future?) {
      _initFuture(future);
    } else if (widget.stream case final stream?) {
      _initStream(stream);
      _updatePause();
    }
  }

  @override
  void didUpdateWidget(AsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.future case final future?) {
      if (future != oldWidget.future) {
        _initFuture(future);
      }
    } else if (widget.stream case final stream?) {
      if (stream != oldWidget.stream) {
        _initStream(stream);
      }
    } else {
      _cancel();
    }

    _updatePause();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_lastError != null && widget.error != null) {
      return widget.error!(context, _lastError!, _lastStackTrace);
    }

    if (_isClosed && widget.closed != null) {
      return widget.closed!(
          context, _hasFired ? _lastValue : widget.initial, widget.child);
    }

    if (!_hasFired && widget.waiting != null) {
      return widget.waiting!(context);
    }

    return widget.builder(
        context, _hasFired ? _lastValue : widget.initial, widget.child);
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
