import 'dart:async';
import 'dart:collection';

import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:collection/collection.dart';
import 'package:comprehensive_utils/comprehensive_utils.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nil/nil.dart';
import 'package:rxdart/rxdart.dart';

class FluentListView<T> extends StatelessWidget {
  const FluentListView({
    required Stream<Iterable<T>> stream,
    required this.itemBuilder,
    this.waiting = _nilWaiting,
    this.error = _nilError,
    this.closed = _nilClosed,
    this.initial = const IListConst([]),
    this.retain = false,
    this.pause = false,
    this.silent,
    this.keepAlive = false,
    this.reportError,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemComparator,
    bool ignoreOrder = false,
    super.key,
  })  : _stream = stream,
        _equality = ignoreOrder ? _equalsUnordered<T> : _equals<T>,
        assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both.',
        );

  final Stream<Iterable<T>> _stream;
  final Widget Function(BuildContext) waiting;
  final Widget Function(BuildContext, int, T?) itemBuilder;
  final Widget Function(BuildContext, Object, StackTrace?) error;
  final Widget Function(BuildContext, IList<T>?) closed;
  final IList<T> initial;
  final bool retain;
  final bool pause;
  final bool? silent;
  final bool keepAlive;
  final void Function(FlutterErrorDetails)? reportError;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final bool Function(T, T)? itemComparator;
  final bool Function(IList<T>, IList<T>, {bool Function(T, T)? itemEquality})
      _equality;

  @override
  Widget build(BuildContext context) {
    // probably bug in SliverChildBuilderDelegate, temporary solution
    bool skipRestoration = false;
    return InitBuilder.arg<ValueStream<IList<T>>, Stream<Iterable<T>>>(
      getter: _getValueStream<T>,
      arg: _stream,
      disposer: (stream) => stream.drain(),
      builder: (context, stream) {
        return _DistinctBuilder<IList<T>>(
          waiting: waiting,
          error: error,
          closed: closed,
          initial: initial,
          retain: retain,
          pause: pause,
          silent: silent,
          keepAlive: keepAlive,
          reportError: reportError,
          stream: stream!.shareDistinctValue((list1, list2) {
            skipRestoration = retain && list2.length < list1.length;
            return _equality(list1, list2, itemEquality: itemComparator);
          }),
          builder: (context, value) {
            return _ListViewBase(
              itemCount: value!.length,
              scrollDirection: scrollDirection,
              reverse: reverse,
              controller: controller,
              primary: primary,
              physics: physics,
              shrinkWrap: shrinkWrap,
              padding: padding,
              itemExtent: itemExtent,
              prototypeItem: prototypeItem,
              cacheExtent: cacheExtent,
              dragStartBehavior: dragStartBehavior,
              keyboardDismissBehavior: keyboardDismissBehavior,
              restorationId: restorationId,
              clipBehavior: clipBehavior,
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _DistinctBuilder<T>(
                    key: ValueKey<T>(value[index]),
                    waiting: _nilWaiting,
                    error: _nilError,
                    closed: _nilClosed,
                    retain: retain,
                    pause: pause,
                    silent: true,
                    keepAlive: keepAlive,
                    stream: stream
                        .map((event) => event[index])
                        .shareDistinctValue(),
                    builder: (context, item) =>
                        itemBuilder(context, index, item),
                  );
                },
                findChildIndexCallback: (key) {
                  if (skipRestoration) {
                    return null;
                  }
                  final index = value
                      .indexWhere((item) => item == (key as ValueKey<T>).value);
                  return index == -1 ? null : index;
                },
                childCount: value.length,
                addAutomaticKeepAlives: addAutomaticKeepAlives,
                addRepaintBoundaries: addRepaintBoundaries,
                addSemanticIndexes: addSemanticIndexes,
              ),
            );
          },
        );
      },
    );
  }

  static bool _equals<T>(IList<T> list1, IList<T> list2,
      {bool Function(T, T)? itemEquality}) {
    final length = list1.length;
    if (length != list2.length) {
      return false;
    }
    itemEquality ??= const DefaultEquality<Never>().equals;
    for (int i = 0; i < length; i++) {
      if (!itemEquality(list1[i], list2[i])) {
        return false;
      }
    }
    return true;
  }

  static bool _equalsUnordered<T>(IList<T> elements1, IList<T> elements2,
      {bool Function(T, T)? itemEquality}) {
    const defaultEquality = DefaultEquality<Never>();
    final counts = HashMap<T, int>(
      equals: itemEquality ?? defaultEquality.equals,
      hashCode: defaultEquality.hash,
      isValidKey: defaultEquality.isValidKey,
    );
    var length = 0;
    for (final e in elements1) {
      final count = counts[e] ?? 0;
      counts[e] = count + 1;
      length++;
    }
    for (final e in elements2) {
      final count = counts[e];
      if (count == null || count == 0) {
        return false;
      }
      counts[e] = count - 1;
      length--;
    }
    return length == 0;
  }

  static Widget _nilWaiting(BuildContext _) => const Nil();

  static Widget _nilClosed(BuildContext _, Object? __) => const Nil();

  static Widget _nilError(BuildContext _, Object __, StackTrace? ___) {
    return const Nil();
  }
}

ValueStream<IList<T>> _getValueStream<T>(Stream<Iterable<T>> base) =>
    base.map<IList<T>>((event) => event.toIList()).shareDistinctValue();

class _ListViewBase extends BoxScrollView {
  const _ListViewBase({
    required this.childrenDelegate,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    this.itemExtent,
    this.prototypeItem,
    int? itemCount,
    super.cacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super(semanticChildCount: semanticChildCount ?? itemCount);

  final double? itemExtent;
  final Widget? prototypeItem;
  final SliverChildDelegate childrenDelegate;

  @override
  Widget buildChildLayout(BuildContext context) {
    if (itemExtent != null) {
      return SliverFixedExtentList(
        delegate: childrenDelegate,
        itemExtent: itemExtent!,
      );
    } else if (prototypeItem != null) {
      return SliverPrototypeExtentList(
        delegate: childrenDelegate,
        prototypeItem: prototypeItem!,
      );
    }
    return SliverList(delegate: childrenDelegate);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DoubleProperty('itemExtent', itemExtent, defaultValue: null));
  }
}

class _DistinctBuilder<T> extends AsyncBuilder<T> {
  const _DistinctBuilder({
    required super.builder,
    required super.stream,
    super.waiting,
    super.error,
    super.closed,
    super.initial,
    super.retain,
    super.pause,
    super.silent,
    super.keepAlive,
    super.reportError,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DistinctBuilderState<T>();
}

class _DistinctBuilderState<T> extends State<_DistinctBuilder<T>>
    with AutomaticKeepAliveClientMixin {
  T? _lastValue;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _hasFired = false;
  bool _isClosed = false;
  StreamSubscription? _subscription;

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
          stack: stackTrace ?? StackTrace.empty,
          context: ErrorDescription('While updating AsyncBuilder'),
        ),
      );
    }
  }

  void _updatePause() {
    if (_subscription != null) {
      if (widget.pause) {
        if (!_subscription!.isPaused) {
          _subscription!.pause();
        }
      } else if (_subscription!.isPaused) {
        _subscription!.resume();
      }
    }
  }

  void _initStream() {
    _cancel();
    final Stream<T> stream = widget.stream!;
    var skipFirst = false;
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
        if (widget.retain && _lastValue == event) {
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

    if (widget.stream != null) {
      _initStream();
      _updatePause();
    }
  }

  @override
  void didUpdateWidget(_DistinctBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stream != null) {
      if (widget.stream != oldWidget.stream) {
        _initStream();
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
      return widget.closed!(context, _hasFired ? _lastValue : widget.initial);
    }

    if (!_hasFired && widget.waiting != null) {
      return widget.waiting!(context);
    }

    return widget.builder(context, _hasFired ? _lastValue : widget.initial);
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
