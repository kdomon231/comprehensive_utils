import 'package:async/async.dart';
import 'package:comprehensive_utils/src/extensions/stream_extensions.dart';
import 'package:comprehensive_utils/src/streams/distinct_subject.dart';

class DistinctStreamCompleter<T> extends StreamCompleter<T> {
  DistinctStreamCompleter([this.equals]);

  final bool Function(T, T)? equals;

  @override
  late final DistinctValueStream<T> stream =
      super.stream.shareDistinctValue(equals);
}
