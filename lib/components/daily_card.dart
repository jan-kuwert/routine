import 'package:flutter/material.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/sport/exercise_row.dart';

class DailyCard extends StatefulWidget {
  final IsarService service;
  final String title; // Title of the card
  final Workout workout; // The workout for the day
  final List<Exercise> exerciseList; // List of all exercises
  // Whether the user can interact with the workout like adding values etc., only current day is active
  final bool active; // Whether the card is interactive

  const DailyCard({
    super.key,
    required this.title,
    required this.workout,
    required this.service,
    this.active = false,
    this.exerciseList = const [],
  });

  @override
  State<DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends State<DailyCard> {
  String get title => widget.title;
  Workout get workout => widget.workout;
  List<Exercise> get exerciseList => widget.exerciseList;
  bool get active => widget.active;

  // Keys to access the state of each ExerciseRow widget to interact with them
  late List<GlobalKey<ExerciseRowState>> _exerciseRowKeys;

  // save each exercise progress to calculate the total progress
  final Map<String, double> _exerciseProgress = {};
  double totalProgress = 0.0;

  void _updateProgress(String exerciseName, double progress) {
    _exerciseProgress[exerciseName] = progress;

    debugPrint('Progress: $_exerciseProgress');

    totalProgress = _exerciseProgress.values.reduce((a, b) => a + b) /
        workout.exercises.length;
    setState(() {}); // Only rebuild when total progress changes
  }

  @override
  void initState() {
    super.initState();
    _exerciseRowKeys = <GlobalKey<ExerciseRowState>>[
      for (var i = 0; i < workout.exercises.length; i++)
        GlobalKey<ExerciseRowState>(),
    ];
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
                Text(title, style: const TextStyle(fontSize: 18.0)),
                if (workout.exercises.isNotEmpty && totalProgress >= 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      RoutineIconPack.done_all,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            if (workout.exercises.isNotEmpty)
              Text('${(totalProgress * 100).round()}%',
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
                child: workout.exercises.isNotEmpty
                    ? LinearProgressIndicator(
                        value: totalProgress,
                        minHeight: 1.0,
                        color: const Color.fromARGB(5, 0, 0, 0),
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    : Container(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: workout.exercises.isNotEmpty
                    ? Column(
                        children: [
                          Column(
                            spacing: 20.0,
                            children: [
                              for (var exerciseEntry in workout.exercises)
                                ExerciseRow(
                                    key: _exerciseRowKeys[workout.exercises
                                        .indexOf(exerciseEntry)],
                                    active: active,
                                    workoutId: workout.id,
                                    title: exerciseEntry.exerciseName[0]
                                            .toUpperCase() +
                                        exerciseEntry.exerciseName.substring(1),
                                    goal: exerciseEntry.target,
                                    counter: exerciseEntry.counter,
                                    increments: (exerciseList.isNotEmpty)
                                        ? (exerciseList
                                            .firstWhere((element) =>
                                                element.name ==
                                                exerciseEntry.exerciseName)
                                            .increments)
                                        : [],
                                    onProgressChange: (progress) =>
                                        _updateProgress(
                                            exerciseEntry.exerciseName,
                                            progress)),
                            ],
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
