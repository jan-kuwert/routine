import 'package:flutter/material.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/home/home_page.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/settings/settings_controller.dart';
import 'package:routine/settings/settings_service.dart';
import 'package:routine/settings/settings_view.dart';
import 'package:routine/sport/sport_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings(); // Add this line

  runApp(MyApp(settingsController: settingsController));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.settingsController});

  final service = IsarService();

  final SettingsController settingsController;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'Routine',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,
            supportedLocales: const <Locale>[Locale('en', 'DE')],
            home: const MyHomePage(title: 'Home'),
            initialRoute: '/',
            routes: {
              '/home': (context) => HomePage(
                    service: service,
                  ),
              '/settings': (context) =>
                  SettingsView(controller: settingsController),
            },
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
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
