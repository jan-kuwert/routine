import 'package:flutter/material.dart';
import 'package:routine/home/home_page.dart';
import 'package:routine/routine_font_icons.dart';
import 'package:routine/sport/sport_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // TRY THIS: Try changing the color here to a specific color (to
      //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      //   // change color while the other colors stay the same.
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),

      body: <Widget>[
        /// Home page
        const HomePage(),
        const SportPage(),
        const Card(
          shadowColor: Colors.transparent,
          margin: EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text('Todo page'),
            ),
          ),
        ),
        const Card(
          shadowColor: Colors.transparent,
          margin: EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text('Lab page'),
            ),
          ),
        ),
      ][currentPageIndex],

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(RoutineFont.home),
            selectedIcon: Icon(RoutineFont.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(RoutineFont.exercise),
            selectedIcon: Icon(RoutineFont.exercise, color: Colors.white),
            label: 'Sport',
          ),
          NavigationDestination(
            icon: Icon(RoutineFont.done_outline),
            selectedIcon: Icon(RoutineFont.done_outline, color: Colors.white),
            label: 'Todo',
          ),
          NavigationDestination(
            icon: Icon(RoutineFont.experiment),
            selectedIcon: Icon(RoutineFont.experiment, color: Colors.white),
            label: 'Lab',
          ),
        ],
      ),
    );
  }
}
