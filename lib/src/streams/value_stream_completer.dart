import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';

class ValueStreamCompleter<T> extends StreamCompleter<T> {
  ValueStreamCompleter();

  @override
  late final ValueStream<T> stream = super.stream.shareValue();
}
