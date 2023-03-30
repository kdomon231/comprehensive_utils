import 'package:comprehensive_utils/comprehensive_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = GetStream<int>();

  test('Test stream', () {
    controller
      ..add(0)
      ..listen((event) {
        expect(event, 0);
      });
    expect(controller.value, 0);

    final subscription = controller.listen((event) {});

    expect(controller.length, 2);

    subscription.cancel();

    expect(controller.length, 1);
  });
}
