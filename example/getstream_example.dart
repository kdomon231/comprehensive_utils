import 'package:comprehensive_utils/comprehensive_utils.dart';

Future<void> main() async {
  final controller = GetStream<int>()
    ..listen(
      (event) {
        print('change number to $event');
      },
      onError: (err, s) {
        print(err);
      },
      cancelOnError: true,
    )
    ..add(2)
    ..add(3)
    ..add(4)
    ..add(5)
    ..add(6);
  print('listeners == 1? ${controller.length}');
  final subs = controller.listen((event) {
    print('change number to $event');
  });
  controller.add(2);
  print('listeners == 2? ${controller.length}');

  await subs.cancel();

  controller
    ..add(2)
    ..addError('error, A error ocurred')
    ..add(5);
  print('listeners == 0? ${controller.length}');
  controller.close();
}
