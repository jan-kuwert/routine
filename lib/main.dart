import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/home/home_view.dart';
import 'package:routine/login/email_verification_screen.dart';
import 'package:routine/login/login_view.dart';
import 'package:routine/login/signup_view.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/settings/settings_controller.dart';
import 'package:routine/settings/settings_service.dart';
import 'package:routine/settings/settings_view.dart';
import 'package:routine/sport/sport_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    demoProjectId: "demo-routine",
  );
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings(); // Add this line

  runApp(
    MaterialSymbolsTheme(
      child: MyApp(settingsController: settingsController),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.settingsController});

  final firestoreService = FirestoreService();

  final SettingsController settingsController;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'Routine',
            themeMode: settingsController.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: settingsController.colorSchemeSeed),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: settingsController.colorSchemeSeed,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            supportedLocales: const <Locale>[Locale('en', 'DE')],
            initialRoute: '/',
            routes: {
              '/': (context) => StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final user = snapshot.data;

                      if (user != null) {
                        // Check if email is verified
                        if (!user.emailVerified) {
                          return const EmailVerificationView();
                        }
                        return AppView(firestoreService: firestoreService);
                      }

                      return const LoginView();
                    },
                  ),
              '/home': (context) => HomeView(
                    firestoreService: firestoreService,
                  ),
              '/settings': (context) =>
                  SettingsView(controller: settingsController),
              '/login': (context) => const LoginView(),
              '/signup': (context) => const SignupView(),
              '/email-verification': (context) => const EmailVerificationView(),
            },
          );
        });
  }
}

class AppView extends StatefulWidget {
  final FirestoreService firestoreService;
  const AppView({super.key, required this.firestoreService});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  FirestoreService get firestoreService => widget.firestoreService;
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        HomeView(firestoreService: firestoreService),
        SportView(firestoreService: firestoreService),
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
        destinations: <Widget>[
          NavigationDestination(
            icon: ThemedIcon(Symbols.home_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(Symbols.home_filled_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: ThemedIcon(Symbols.exercise_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(Symbols.exercise_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
            label: 'Sport',
          ),
          NavigationDestination(
            icon: ThemedIcon(Symbols.assignment_turned_in_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(Symbols.assignment_turned_in_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
            label: 'Todo',
          ),
          NavigationDestination(
            icon: ThemedIcon(Symbols.cake_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(Symbols.cake_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
            label: 'Birthdays',
          ),
          NavigationDestination(
            icon: ThemedIcon(Symbols.experiment_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(Symbols.experiment_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
            label: 'Lab',
          ),
        ],
      ),
    );
  }
}
