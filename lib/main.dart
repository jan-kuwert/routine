import 'package:flutter/material.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/home/home_page.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/settings/settings_controller.dart';
import 'package:routine/settings/settings_service.dart';
import 'package:routine/settings/settings_view.dart';
import 'package:routine/sport/sport_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final service = IsarService();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routine',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
        useMaterial3: true,
      ),
      supportedLocales: const <Locale>[Locale('en', 'DE')],
      home: const MyHomePage(title: 'Home'),
      initialRoute: '/',
      routes: {
        '/home': (context) => HomePage(
              service: service,
            ),
        '/settings': (context) =>
            SettingsView(controller: SettingsController(SettingsService())),
      },
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
  final service = IsarService();
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        /// Home page
        HomePage(service: service),
        SportPage(service: service),
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
              child: Text('Birthdays page'),
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(RoutineIconPack.home),
            selectedIcon:
                Icon(RoutineIconPack.home_filled, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(RoutineIconPack.exercise),
            selectedIcon:
                Icon(RoutineIconPack.exercise_filled, color: Colors.white),
            label: 'Sport',
          ),
          NavigationDestination(
            icon: Icon(RoutineIconPack.done_outline),
            selectedIcon:
                Icon(RoutineIconPack.done_outline_filled, color: Colors.white),
            label: 'Todo',
          ),
          NavigationDestination(
            icon: Icon(RoutineIconPack.cake),
            selectedIcon:
                Icon(RoutineIconPack.cake_filled, color: Colors.white),
            label: 'Birthdays',
          ),
          NavigationDestination(
            icon: Icon(RoutineIconPack.experiment),
            selectedIcon:
                Icon(RoutineIconPack.experiment_filled, color: Colors.white),
            label: 'Lab',
          ),
        ],
      ),
    );
  }
}
