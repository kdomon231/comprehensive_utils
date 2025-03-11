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
/// Alternative constructors [InitBuilder.arg] to [InitBuilder.arg7] can be used
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
abstract class InitBuilder<T> extends StatefulWidget {
  /// Factory constructor for a basic [InitBuilder].
  const factory InitBuilder({
    required ValueBuilderFn<T> builder,
    required ValueGetter<T> getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) = _GetterInitBuilder<T>;

  /// Base constructor for anything that implements [InitBuilder].
  const InitBuilder.base({
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
    required ValueBuilderFn<T> builder,
    required A arg,
    required T Function(A) getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _ArgInitBuilder<T, A>(
        key: key,
        builder: builder,
        arg: arg,
        getter: getter,
        disposer: disposer,
      );

  /// Constructor for two argument getters.
  static InitBuilder<T> arg2<T, A1, A2>({
    required ValueBuilderFn<T> builder,
    required A1 arg1,
    required A2 arg2,
    required T Function(A1, A2) getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _Arg2InitBuilder<T, A1, A2>(
        key: key,
        builder: builder,
        arg1: arg1,
        arg2: arg2,
        getter: getter,
        disposer: disposer,
      );

  /// Constructor for three argument getters.
  static InitBuilder<T> arg3<T, A1, A2, A3>({
    required ValueBuilderFn<T> builder,
    required A1 arg1,
    required A2 arg2,
    required A3 arg3,
    required T Function(A1, A2, A3) getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _Arg3InitBuilder<T, A1, A2, A3>(
        key: key,
        builder: builder,
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        getter: getter,
        disposer: disposer,
      );

  /// Constructor for four argument getters.
  static InitBuilder<T> arg4<T, A1, A2, A3, A4>({
    required ValueBuilderFn<T> builder,
    required A1 arg1,
    required A2 arg2,
    required A3 arg3,
    required A4 arg4,
    required T Function(A1, A2, A3, A4) getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _Arg4InitBuilder<T, A1, A2, A3, A4>(
        key: key,
        builder: builder,
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        arg4: arg4,
        getter: getter,
        disposer: disposer,
      );

  /// Constructor for five argument getters.
  static InitBuilder<T> arg5<T, A1, A2, A3, A4, A5>({
    required ValueBuilderFn<T> builder,
    required A1 arg1,
    required A2 arg2,
    required A3 arg3,
    required A4 arg4,
    required A5 arg5,
    required T Function(A1, A2, A3, A4, A5) getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _Arg5InitBuilder<T, A1, A2, A3, A4, A5>(
        key: key,
        builder: builder,
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        arg4: arg4,
        arg5: arg5,
        getter: getter,
        disposer: disposer,
      );

  /// Constructor for six argument getters.
  static InitBuilder<T> arg6<T, A1, A2, A3, A4, A5, A6>({
    required ValueBuilderFn<T> builder,
    required A1 arg1,
    required A2 arg2,
    required A3 arg3,
    required A4 arg4,
    required A5 arg5,
    required A6 arg6,
    required T Function(A1, A2, A3, A4, A5, A6) getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _Arg6InitBuilder<T, A1, A2, A3, A4, A5, A6>(
        key: key,
        builder: builder,
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        arg4: arg4,
        arg5: arg5,
        arg6: arg6,
        getter: getter,
        disposer: disposer,
      );

  /// Constructor for seven argument getters.
  static InitBuilder<T> arg7<T, A1, A2, A3, A4, A5, A6, A7>({
    required ValueBuilderFn<T> builder,
    required A1 arg1,
    required A2 arg2,
    required A3 arg3,
    required A4 arg4,
    required A5 arg5,
    required A6 arg6,
    required A7 arg7,
    required T Function(A1, A2, A3, A4, A5, A6, A7) getter,
    ValueSetter<T>? disposer,
    Key? key,
  }) =>
      _Arg7InitBuilder<T, A1, A2, A3, A4, A5, A6, A7>(
        key: key,
        builder: builder,
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        arg4: arg4,
        arg5: arg5,
        arg6: arg6,
        arg7: arg7,
        getter: getter,
        disposer: disposer,
      );

  /// Called by the widget state to initialize the value.
  T initValue();

  /// Returns true if the value should be re-initialized after a rebuild.
  bool shouldInit(covariant InitBuilder<T> other);

  @override
  State<InitBuilder<T>> createState() => _InitBuilderState<T>();
}

class _GetterInitBuilder<T> extends InitBuilder<T> {
  const _GetterInitBuilder({
    required super.builder,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final ValueGetter<T> getter;

  @override
  T initValue() => getter();

  @override
  bool shouldInit(_GetterInitBuilder<T> other) => getter != other.getter;
}

class _ArgInitBuilder<T, A> extends InitBuilder<T> {
  const _ArgInitBuilder({
    required super.builder,
    required this.arg,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final A arg;
  final T Function(A) getter;

  @override
  T initValue() => getter(arg);

  @override
  bool shouldInit(_ArgInitBuilder<T, A> other) =>
      arg != other.arg || getter != other.getter;
}

class _Arg2InitBuilder<T, A1, A2> extends InitBuilder<T> {
  const _Arg2InitBuilder({
    required super.builder,
    required this.arg1,
    required this.arg2,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final A1 arg1;
  final A2 arg2;
  final T Function(A1, A2) getter;

  @override
  T initValue() => getter(arg1, arg2);

  @override
  bool shouldInit(_Arg2InitBuilder<T, A1, A2> other) =>
      arg1 != other.arg1 || arg2 != other.arg2 || getter != other.getter;
}

class _Arg3InitBuilder<T, A1, A2, A3> extends InitBuilder<T> {
  const _Arg3InitBuilder({
    required super.builder,
    required this.arg1,
    required this.arg2,
    required this.arg3,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final T Function(A1, A2, A3) getter;

  @override
  T initValue() => getter(arg1, arg2, arg3);

  @override
  bool shouldInit(_Arg3InitBuilder<T, A1, A2, A3> other) =>
      arg1 != other.arg1 ||
      arg2 != other.arg2 ||
      arg3 != other.arg3 ||
      getter != other.getter;
}

class _Arg4InitBuilder<T, A1, A2, A3, A4> extends InitBuilder<T> {
  const _Arg4InitBuilder({
    required super.builder,
    required this.arg1,
    required this.arg2,
    required this.arg3,
    required this.arg4,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final T Function(A1, A2, A3, A4) getter;

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4);

  @override
  bool shouldInit(_Arg4InitBuilder<T, A1, A2, A3, A4> other) =>
      arg1 != other.arg1 ||
      arg2 != other.arg2 ||
      arg3 != other.arg3 ||
      arg4 != other.arg4 ||
      getter != other.getter;
}

class _Arg5InitBuilder<T, A1, A2, A3, A4, A5> extends InitBuilder<T> {
  const _Arg5InitBuilder({
    required super.builder,
    required this.arg1,
    required this.arg2,
    required this.arg3,
    required this.arg4,
    required this.arg5,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final A5 arg5;
  final T Function(A1, A2, A3, A4, A5) getter;

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4, arg5);

  @override
  bool shouldInit(_Arg5InitBuilder<T, A1, A2, A3, A4, A5> other) =>
      arg1 != other.arg1 ||
      arg2 != other.arg2 ||
      arg3 != other.arg3 ||
      arg4 != other.arg4 ||
      arg5 != other.arg5 ||
      getter != other.getter;
}

class _Arg6InitBuilder<T, A1, A2, A3, A4, A5, A6> extends InitBuilder<T> {
  const _Arg6InitBuilder({
    required super.builder,
    required this.arg1,
    required this.arg2,
    required this.arg3,
    required this.arg4,
    required this.arg5,
    required this.arg6,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final A5 arg5;
  final A6 arg6;
  final T Function(A1, A2, A3, A4, A5, A6) getter;

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4, arg5, arg6);

  @override
  bool shouldInit(_Arg6InitBuilder<T, A1, A2, A3, A4, A5, A6> other) =>
      arg1 != other.arg1 ||
      arg2 != other.arg2 ||
      arg3 != other.arg3 ||
      arg4 != other.arg4 ||
      arg5 != other.arg5 ||
      arg6 != other.arg6 ||
      getter != other.getter;
}

class _Arg7InitBuilder<T, A1, A2, A3, A4, A5, A6, A7> extends InitBuilder<T> {
  const _Arg7InitBuilder({
    required super.builder,
    required this.arg1,
    required this.arg2,
    required this.arg3,
    required this.arg4,
    required this.arg5,
    required this.arg6,
    required this.arg7,
    required this.getter,
    super.disposer,
    super.key,
  }) : super.base();

  final A1 arg1;
  final A2 arg2;
  final A3 arg3;
  final A4 arg4;
  final A5 arg5;
  final A6 arg6;
  final A7 arg7;
  final T Function(A1, A2, A3, A4, A5, A6, A7) getter;

  @override
  T initValue() => getter(arg1, arg2, arg3, arg4, arg5, arg6, arg7);

  @override
  bool shouldInit(_Arg7InitBuilder<T, A1, A2, A3, A4, A5, A6, A7> other) =>
      arg1 != other.arg1 ||
      arg2 != other.arg2 ||
      arg3 != other.arg3 ||
      arg4 != other.arg4 ||
      arg5 != other.arg5 ||
      arg6 != other.arg6 ||
      arg7 != other.arg7 ||
      getter != other.getter;
}

class _InitBuilderState<T> extends State<InitBuilder<T>> {
  T? value;

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
    widget.disposer?.call(value as T);
    super.dispose();
  }
}
