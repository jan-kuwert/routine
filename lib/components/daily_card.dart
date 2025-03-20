import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/sport/exercise_row.dart';

class DailyCard extends StatefulWidget {
  final String title;

  const DailyCard({
    super.key,
    required this.title,
  });

  @override
  State<DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends State<DailyCard> {
  final String jsonPath = 'assets/exercises.json';

  static const exerciseNames = ['pushups', 'pullups'];
  late Map<String, dynamic> exercises = {};

  final List<GlobalKey<ExerciseRowState>> _exerciseRowKeys =
      <GlobalKey<ExerciseRowState>>[
    for (var i = 0; i < exerciseNames.length; i++)
      GlobalKey<ExerciseRowState>(),
  ];

  @override
  void initState() {
    super.initState();
    // We need to use Future.delayed because context isn't available immediately in initState
    Future.microtask(() => loadExercises());
  }

  Future<void> loadExercises() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/exercises.json');
      final dynamic decoded = json.decode(jsonString);
      for (var i = 0; i < decoded.length; i++) {
        if (decoded[i] is Map && exerciseNames.contains(decoded[i]['name'])) {
          final String type = decoded[i]['name'];
          decoded[i].remove('name');
          exercises[type] = decoded[i];
        }
      }
      debugPrint('Loaded Exercises: $exercises');

      setState(() {
        exercises = exercises;
      });
    } catch (e) {
      debugPrint('Error loading Exercises: $e');
      exercises = {};
    }
  }

  // Getter for progress calculation
  double get totalProgress {
    double totalCounter = 0;
    for (var exercise in exercises.entries) {
      totalCounter += _exerciseRowKeys[exerciseNames.indexOf(exercise.key)]
              .currentState
              ?.counter ??
          0;
    }
    return totalCounter;
  }

  int pushupCounter = 0;
  int maxPushups = 50;
  int pullupCounter = 0;
  int maxPullups = 25;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18.0)),
                if (exerciseNames.isNotEmpty &&
                    ((pushupCounter / maxPushups + pullupCounter / maxPullups) /
                            2) ==
                        1)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      RoutineIconPack.done_all,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            if (exerciseNames.isNotEmpty)
              Text(
                  '${(((pushupCounter / maxPushups + pullupCounter / maxPullups) / 2) * 100).round()}%',
                  style: const TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: exerciseNames.isNotEmpty
                    ? LinearProgressIndicator(
                        value: (pushupCounter / maxPushups +
                                pullupCounter / maxPullups) /
                            2,
                        minHeight: 1.0,
                        color: const Color.fromARGB(10, 0, 0, 0),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    : Container(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: exerciseNames.isNotEmpty
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                spacing: 10.0,
                                children: [
                                  for (var exercise in exercises.entries)
                                    ExerciseRow(
                                      key: _exerciseRowKeys[
                                          exerciseNames.indexOf(exercise.key)],
                                      title: exercise.key[0].toUpperCase() +
                                          exercise.key.substring(1),
                                      max: exercise.value['max'] ?? 0,
                                      button1Value:
                                          (exercise.value['button1value'] ?? 0),
                                      button2Value:
                                          (exercise.value['button2value'] ?? 0),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'No exercises planned',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
