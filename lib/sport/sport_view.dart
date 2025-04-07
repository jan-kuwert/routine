import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/components/daily_card.dart';
import 'package:routine/components/goal_card.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/firebase/exercise.dart';
import 'package:routine/db/firebase/workout.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/sport/goal_history.dart';
import 'package:routine/sport/new_workout_goal.dart';
import 'package:routine/sport/workout_history.dart';

class SportView extends StatefulWidget {
  final FirestoreService firestoreService;

  const SportView({super.key, required this.firestoreService});

  @override
  State<SportView> createState() => _SportViewState();
}

class _SportViewState extends State<SportView> {
  FirestoreService get firestoreService => widget.firestoreService;

  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  late Future<List<Workout>> workouts;
  final String jsonPath = 'assets/exercises.json';
  late List<Exercise> exerciseList = [];

  // Add this to keep track of mounted state for async operations
  bool _isDisposed = false;

  // Override dispose to set the flag when widget is removed
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _addExercisesFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/exercises.json');
      final dynamic decoded = json.decode(jsonString);
      for (var i = 0; i < decoded.length; i++) {
        if (decoded[i] is Map) {
          firestoreService.addExercise(Exercise(
            id: '', // Empty ID that will be replaced by Firestore
            name: decoded[i]['name'] as String,
            category: ExerciseCategory.values.firstWhere(
              (category) =>
                  category.name.toLowerCase() ==
                  decoded[i]['category'].toString().toLowerCase(),
              orElse: () => ExerciseCategory.other,
            ),
            type: ExerciseType.values.firstWhere(
              (type) =>
                  type.name.toLowerCase() ==
                  decoded[i]['type'].toString().toLowerCase(),
              orElse: () => ExerciseType.repetitions,
            ),
            increments: decoded[i].containsKey('increments') &&
                    decoded[i]['increments'] is List &&
                    decoded[i]['increments'].length >= 2
                ? [
                    decoded[i]['increments'][0] as int,
                    decoded[i]['increments'][1] as int
                  ]
                : [],
          ));
        }
      }
      debugPrint('Loaded Exercises: $exerciseList');
    } catch (e) {
      debugPrint('Error adding Exercises: $e');

      exerciseList = [];
    }
  }

  Future<void> getAllExercises() async {
    final exercises = await firestoreService.getAllExercises();

    // Check if widget is still mounted before calling setState
    if (!_isDisposed && mounted) {
      setState(() {
        exerciseList = exercises;
      });
    }
  }

  String _getDailyCardTitle(Timestamp date) {
    // Convert Timestamp to DateTime for comparison
    final dateTime = date.toDate();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    // Create comparable date from the timestamp's DateTime
    final compareDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    debugPrint('Compare Date: $compareDate');
    if (compareDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (compareDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (compareDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    }

    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  @override
  void initState() {
    super.initState();
    // We need to use Future.delayed because context isn't available immediately in initState
    Future.microtask(() => {_addExercisesFromJson(), getAllExercises()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_fabKey.currentState?.isOpen == true) {
            _fabKey.currentState?.toggle();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Sport'),
              actions: [
                IconButton(
                  icon: const ThemedIcon(Symbols.emoji_events_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoalHistoryScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const ThemedIcon(Symbols.history),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutHistoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    GoalCard(title: 'Current Goal'),
                    FutureBuilder<List<Workout>>(
                      future: firestoreService.getWorkoutsAfterDate(
                          Timestamp.fromDate(DateTime.now()
                              .subtract(const Duration(days: 1)))),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No workouts planned');
                        } else {
                          return Column(
                            children: [
                              ...snapshot.data!.map(
                                (workout) => DailyCard(
                                  title: _getDailyCardTitle(workout.timestamp),
                                  firestoreService: firestoreService,
                                  workout: workout,
                                  exerciseList: exerciseList,
                                  active:
                                      (_getDailyCardTitle(workout.timestamp) ==
                                              "Today")
                                          ? true
                                          : false,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton:
          AddSheet(firestoreService: firestoreService, fabKey: _fabKey),
    );
  }
}
