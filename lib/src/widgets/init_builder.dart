import 'package:comprehensive_utils/src/common/typedefs.dart';
import 'package:flutter/widgets.dart';

/// Modified version of [InitBuilder] from https://pub.dev/packages/async_builder
///
/// A widget that initializes a value only when its configuration changes,
/// useful for safe creation of async tasks.
///
/// The default constructor takes a `getter`, `builder`, and `disposer`. The
/// `getter` function is called to initialize the value used in `builder`. In
/// this case InitBuilder only re-initializes the value if the `getter` function
/// changes, you should not pass it an anonymous function directly.
///
/// Alternative constructors [InitBuilder.arg] and [InitBuilder.args] can be used
/// to pass arguments to the `getter`, these will re-initialize the value if
/// either `getter` or the arguments change.
///
/// The basic usage of this widget is to make a separate function outside of
/// build that starts the task and then pass it to InitBuilder, for example:
///
/// ```dart
/// static Future<int> getNumber() async => ...;
///
/// Widget build(context) => InitBuilder<int>(
///   getter: getNumber,
///   builder: (context, future) => AsyncBuilder<int>(
///     future: future,
///     builder: (context, value) => Text('$value'),
///   ),
/// );
/// ```
///
/// You may also want to pass arguments to the getter, for example to query
/// shared preferences:
///
/// ```dart
/// final String prefsKey;
///
/// Widget build(context) => InitBuilder.arg<String, String>(
///   getter: sharedPrefs.getString,
///   arg: prefsKey,
///   builder: (context, future) => AsyncBuilder<String>(
///     future: future,
///     builder: (context, value) => Text('$value'),
///   ),
/// );
/// ```
sealed class InitBuilder<T> extends StatefulWidget {
  /// Factory constructor for a basic [InitBuilder].
  const factory InitBuilder({
    required ValueGetter<T> getter,
    required ValueBuilderFn<T> builder,
    ValueSetter<T>? disposer,
    Key? key,
  }) = _GetterInitBuilder<T>;

  /// Base constructor for internal [InitBuilder] implementations.
  const InitBuilder._({
    required this.builder,
    this.disposer,
    super.key,
  });

  /// Builder that is called with a previously initialized value.
  final ValueBuilderFn<T> builder;

  /// Function that is called with the value when the InitBuilder is being
  /// disposed.
  final ValueSetter<T>? disposer;

  /// Constructor for one argument getters.
  static InitBuilder<T> arg<T, A>({
    required T Function(A) getter,
    required A arg,
    required ValueBuilderFn<T> builder,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _ArgInitBuilder<T, A>(
        getter: getter,
        arg: arg,
        builder: builder,
        disposer: disposer,
        key: key,
      );

  /// Constructor for record type argument getters.
  static InitBuilder<T> args<T, A extends Record>({
    required T Function(A) getter,
    required A args,
    required ValueBuilderFn<T> builder,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _ArgsInitBuilder<T, A>(
        getter: getter,
        args: args,
        builder: builder,
        disposer: disposer,
        key: key,
      );

  /// Called by the widget state to initialize the value.
  T initValue();

  /// Returns true if the value should be re-initialized after a rebuild.
  bool shouldInit(covariant InitBuilder<T> other);

  @override
  State<InitBuilder<T>> createState() => _InitBuilderState<T>();
}

/// State class for InitBuilder that manages the lifecycle of the initialized value.
class _InitBuilderState<T> extends State<InitBuilder<T>> {
  /// The current value initialized by the widget.
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.initValue();
  }

  @override
  void didUpdateWidget(InitBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldInit(oldWidget)) {
      value = widget.initValue();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, value);

  @override
  void dispose() {
    if (widget.disposer case final disposer?) {
      disposer.call(value);
    } else if (value case final DisposableInitData disposableInitData) {
      disposableInitData.dispose();
    }
    super.dispose();
  }
}

/// Implementation of InitBuilder that uses a simple getter function.
final class _GetterInitBuilder<T> extends InitBuilder<T> {
  /// The getter function that provides the initial value.
  const _GetterInitBuilder({
    required this.getter,
    required super.builder,
    super.disposer,
    super.key,
  }) : super._();

  final ValueGetter<T> getter;

  @override
  T initValue() => getter();

  @override
  bool shouldInit(_GetterInitBuilder<T> other) => getter != other.getter;
}

/// Implementation of InitBuilder that uses a getter function with a single argument.
final class _ArgInitBuilder<T, A> extends InitBuilder<T> {
  /// The getter function that takes an argument of type A and returns a value of type T.
  const _ArgInitBuilder({
    required this.getter,
    required this.arg,
    required super.builder,
    super.disposer,
    super.key,
  }) : super._();

  final T Function(A) getter;
  final A arg;

  @override
  T initValue() => getter(arg);

  @override
  bool shouldInit(_ArgInitBuilder<T, A> other) =>
      arg != other.arg || getter != other.getter;
}

/// Implementation of InitBuilder that uses a getter function with multiple arguments (record).
final class _ArgsInitBuilder<T, A extends Record>
    extends _ArgInitBuilder<T, A> {
  /// Creates an InitBuilder with multiple arguments using a record.
  const _ArgsInitBuilder({
    required super.getter,
    required A args,
    required super.builder,
    super.disposer,
    super.key,
  }) : super(arg: args);
}

abstract interface class DisposableInitData {
  void dispose();
}
