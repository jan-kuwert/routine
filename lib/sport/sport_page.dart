import 'package:flutter/material.dart';
import 'package:routine/routine_font_icons.dart';

class SportPage extends StatefulWidget {
  const SportPage({super.key});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Page'),
      ),
      body: const Center(
        child: Text('Sport Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(RoutineFont.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
