import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/birthday/birthday_view.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/home/home_view.dart';
import 'package:routine/lab/lab_view.dart';
import 'package:routine/login/email_verification_screen.dart';
import 'package:routine/login/login_view.dart';
import 'package:routine/login/signup_view.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/services/notification_service.dart';
import 'package:routine/settings/settings_controller.dart';
import 'package:routine/settings/settings_service.dart';
import 'package:routine/settings/settings_view.dart';
import 'package:routine/sport/exercise_selection_view.dart';
import 'package:routine/sport/sport_view.dart';
import 'package:routine/todo/todo_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Only use emulators if you are running them locally
  if (kDebugMode) {
    try {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    } catch (e) {
      print('Error initializing emulators: $e');
    }
  }

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings(); // Add this line

  runApp(
    MaterialSymbolsTheme(child: MyApp(settingsController: settingsController)),
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
              seedColor: settingsController.colorSchemeSeed,
            ),
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
                      if (!user.emailVerified && !user.isAnonymous) {
                        return const EmailVerificationView();
                      }
                      return AppView(
                        firestoreService: firestoreService,
                        settingsController: settingsController,
                      );
                    }

                    // If no user, show LoginView
                    return const LoginView();
                  },
                ),
            '/home': (context) => HomeView(
                  firestoreService: firestoreService,
                  settingsController: settingsController,
                ),
            '/settings': (context) =>
                SettingsView(controller: settingsController),
            '/login': (context) => const LoginView(),
            '/signup': (context) => const SignupView(),
            '/email-verification': (context) => const EmailVerificationView(),
            ExerciseSelectionView.routeName: (context) =>
                const ExerciseSelectionView(),
          },
        );
      },
    );
  }
}

class AppView extends StatefulWidget {
  final FirestoreService firestoreService;
  final SettingsController settingsController;

  const AppView({
    super.key,
    required this.firestoreService,
    required this.settingsController,
  });

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  FirestoreService get firestoreService => widget.firestoreService;
  SettingsController get settingsController => widget.settingsController;
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, child) {
        final destinations = <NavigationDestination>[
          NavigationDestination(
            icon: const ThemedIcon(Symbols.home_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(
                Symbols.home_filled_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const ThemedIcon(Symbols.exercise_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(
                Symbols.exercise_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            label: 'Sport',
          ),
          NavigationDestination(
            icon: const ThemedIcon(Symbols.assignment_turned_in_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(
                Symbols.assignment_turned_in_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            label: 'Todo',
          ),
          if (settingsController.isBirthdayEnabled)
            NavigationDestination(
              icon: const ThemedIcon(Symbols.cake_rounded),
              selectedIcon: MaterialSymbolsTheme(
                fill: 1,
                child: ThemedIcon(
                  Symbols.cake_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              label: 'Birthdays',
            ),
          NavigationDestination(
            icon: const ThemedIcon(Symbols.experiment_rounded),
            selectedIcon: MaterialSymbolsTheme(
              fill: 1,
              child: ThemedIcon(
                Symbols.experiment_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            label: 'Lab',
          ),
        ];

        final pages = <Widget>[
          HomeView(
            firestoreService: firestoreService,
            settingsController: settingsController,
            onNavigateToSport: () {
              setState(() {
                currentPageIndex = 1; // Navigate to Sport tab
              });
            },
            onNavigateToTodo: () {
              setState(() {
                currentPageIndex = 2; // Navigate to Todo tab
              });
            },
            onNavigateToBirthday: () {
              setState(() {
                // Navigate to Birthday tab (index 3 if birthday is enabled)
                currentPageIndex = settingsController.isBirthdayEnabled ? 3 : 2;
              });
            },
          ),
          SportView(firestoreService: firestoreService),
          TodoView(firestoreService: firestoreService),
          if (settingsController.isBirthdayEnabled)
            BirthdayView(firestoreService: firestoreService),
          const LabView(),
        ];

        // Ensure index is valid
        if (currentPageIndex >= pages.length) {
          currentPageIndex = pages.length - 1;
        }

        return Scaffold(
          body: pages[currentPageIndex],
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            selectedIndex: currentPageIndex,
            destinations: destinations,
          ),
        );
      },
    );
  }
}
