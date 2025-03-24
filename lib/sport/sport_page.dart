import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:routine/components/daily_card.dart';
import 'package:routine/components/goal_card.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/goal.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/sport/create_exercise_dialog.dart';
import 'package:routine/sport/goal_history.dart';
import 'package:routine/sport/new_workout_goal.dart';
import 'package:routine/sport/workout_history.dart';

class SportPage extends StatefulWidget {
  final IsarService service;

  const SportPage({super.key, required this.service});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  late Future<List<Workout>> workouts;
  final String jsonPath = 'assets/exercises.json';
  late List<Exercise> exerciseList = [];

  Future<void> _addExercisesFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/exercises.json');
      final dynamic decoded = json.decode(jsonString);
      for (var i = 0; i < decoded.length; i++) {
        if (decoded[i] is Map) {
          widget.service.addExercise(Exercise(
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
    final exercises = await widget.service.getAllExercises();
    setState(() {
      exerciseList = exercises;
    });
  }

  String _getDailyCardTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    final compareDate = DateTime(date.year, date.month, date.day);
    debugPrint('Compare Date: $compareDate');
    if (compareDate == today) {
      return 'Today';
    } else if (compareDate == tomorrow) {
      return 'Tomorrow';
    } else if (compareDate == yesterday) {
      return 'Yesterday';
    }

    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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
                  icon: const Icon(RoutineIconPack.emoji_events),
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
                  icon: const Icon(RoutineIconPack.history),
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
                    GoalCard(title: 'Active Goal'),
                    FutureBuilder<List<Workout>>(
                      future: widget.service.getWorkoutsAfterDate(
                          DateTime.now().subtract(const Duration(days: 1))),
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
                                  title: _getDailyCardTitle(workout.date),
                                  service: widget.service,
                                  workout: workout,
                                  exerciseList: exerciseList,
                                  active: (_getDailyCardTitle(workout.date) ==
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
            SliverToBoxAdapter(
              child: Center(
                  child: CreateExerciseDialog(
                service: widget.service,
              )),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: AddSheet(service: widget.service, fabKey: _fabKey),
    );
  }
}
