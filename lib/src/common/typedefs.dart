import 'package:flutter/widgets.dart';

/// Signature for a function that builds a widget from a value.
typedef WidgetValueBuilder<T> = Widget Function(
    BuildContext context, T? value, Widget? child);

/// Signature for a function that builds a widget from a value.
typedef ValueBuilderFn<T> = Widget Function(BuildContext context, T? value);

/// Signature for a function that builds a widget from an exception.
typedef ErrorBuilderFn = Widget Function(
    BuildContext context, Object error, StackTrace? stackTrace);

/// Signature for a function that reports a flutter error, e.g. [FlutterError.reportError].
typedef ErrorReporterFn = void Function(FlutterErrorDetails details);

typedef IndexedListItemBuilder<T> = Widget Function(
    BuildContext context, int index, T? value);

typedef LoadNextPage = Future<bool> Function(int pageNumber, int pageSize);
