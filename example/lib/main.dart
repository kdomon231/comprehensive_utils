import 'package:comprehensive_utils/comprehensive_utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DistinctSubject<String> _userNameSubject = DistinctSubject<String>();

  @override
  void dispose() {
    _userNameSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            const Text('userName:'),
            AsyncBuilder<String>(
              stream: _userNameSubject.stream,
              initial: '',
              builder: (context, value, child) => Text(
                value!,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // the value will be added to Stream if it differs from the previous one
          _userNameSubject.add('Random user');
        },
        tooltip: 'Set userName',
        child: const Icon(Icons.add),
      ),
    );
  }
}
