// ignore_for_file: avoid_print
import 'dart:async';

import 'package:comprehensive_utils/src/streams/get_stream.dart';
import 'package:comprehensive_utils/src/streams/mini_stream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('run benchmarks', () async {
    print(await newStream());
    print(await stream());
    print(await getStream());
  });
}

const int times = 30000;

int get last => times - 1;

Future<String> getStream() {
  final c = Completer<String>();

  final value = GetStream<int>();
  final timer = Stopwatch()..start();

  value.listen((v) {
    if (last == v) {
      timer.stop();
      c.complete(
        '''$v listeners notified | [GET_STREAM] objs time: ${timer.elapsedMicroseconds}ms''',
      );
    }
  });

  for (var i = 0; i < times; i++) {
    value.add(i);
  }

  return c.future;
}

Future<String> newStream() {
  final c = Completer<String>();
  final value = MiniStream<int>();
  final timer = Stopwatch()..start();

  value.listen((v) {
    if (last == v) {
      timer.stop();
      c.complete(
        '''$v listeners notified | [LIGHT_STREAM] objs time: ${timer.elapsedMicroseconds}ms''',
      );
    }
  });

  for (var i = 0; i < times; i++) {
    value.add(i);
  }

  return c.future;
}

Future<String> stream() {
  final c = Completer<String>();

  // ignore: close_sinks
  final value = StreamController<int>();
  final timer = Stopwatch()..start();

  value.stream.listen((v) {
    if (last == v) {
      timer.stop();
      c.complete(
        '''$v listeners notified | [STREAM] objs time: ${timer.elapsedMicroseconds}ms''',
      );
    }
  });

  for (var i = 0; i < times; i++) {
    value.add(i);
  }

  return c.future;
}
