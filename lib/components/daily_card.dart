import 'package:routine/sport/new_workout_goal.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/sport/exercise_row.dart';

class DailyCard extends StatefulWidget {
  final FirestoreService firestoreService;
  final String title; // Title of the card
  final Workout workout; // The workout for the day
  final List<Exercise> exerciseList; // List of all exercises
  // Whether the user can interact with the workout like adding values etc., only current day is active
  final bool active; // Whether the card is interactive
  final bool showDateTitle; // Whether to show the date title text

  const DailyCard({
    super.key,
    required this.title,
    required this.workout,
    required this.firestoreService,
    this.active = false,
    this.showDateTitle = true,
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

  bool get showDateTitle => widget.showDateTitle;

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
  void didUpdateWidget(DailyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.workout.exercises.length != _exerciseRowKeys.length) {
      if (widget.workout.exercises.length > _exerciseRowKeys.length) {
        _exerciseRowKeys.addAll(
          List.generate(
            widget.workout.exercises.length - _exerciseRowKeys.length,
            (_) => GlobalKey<ExerciseRowState>(),
          ),
        );
      } else {
        _exerciseRowKeys =
            _exerciseRowKeys.sublist(0, widget.workout.exercises.length);
      }
    }
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
                if (showDateTitle)
                  Text(title, style: const TextStyle(fontSize: 18.0)),
                if (workout.exercises.isNotEmpty && totalProgress >= 1)
                  Padding(
                    padding: showDateTitle ? const EdgeInsets.only(left: 8.0) : EdgeInsets.zero,
                    child: const ThemedIcon(
                      Symbols.done_all,
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
        child: GestureDetector(
          onLongPress: () {
            // Show options menu on long press
            showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              sheetAnimationStyle:
                                  AnimationStyle(curve: const ElasticInCurve()),
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return WorkoutGoalSheet(
                                  firestoreService: widget.firestoreService,
                                  workout: workout,
                                );
                              },
                            );
                          },
                          icon: const ThemedIcon(Symbols.edit_rounded, size: 24),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            foregroundColor:
                                Theme.of(context).colorScheme.onErrorContainer,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Workout'),
                                content: const Text(
                                    'Are you sure you want to delete this workout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await widget.firestoreService
                                  .deleteWorkout(workout.id);
                            }
                          },
                          icon: const ThemedIcon(Symbols.delete_rounded, size: 24),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                                  Builder(
                                    builder: (context) {
                                      // Find the exercise definition to get the unit
                                      final exerciseDef = exerciseList.isNotEmpty
                                          ? exerciseList.firstWhere(
                                              (e) => e.name == exerciseEntry.exerciseName,
                                              orElse: () => Exercise(
                                                  id: '',
                                                  name: exerciseEntry.exerciseName,
                                                  category: ExerciseCategory.other),
                                            )
                                          : null;
                                          
                                      final unit = (exerciseDef?.type ?? ExerciseType.repetitions) == ExerciseType.duration ? 'min' : '';

                                      return ExerciseRow(
                                        key: _exerciseRowKeys[
                                            workout.exercises.indexOf(exerciseEntry)],
                                        active: active,
                                        workoutId: workout.id,
                                        title: exerciseEntry.exerciseName[0].toUpperCase() +
                                            exerciseEntry.exerciseName.substring(1),
                                        exerciseName: exerciseEntry.exerciseName,
                                        goal: exerciseEntry.target,
                                        counter: exerciseEntry.counter,
                                        increments: exerciseDef?.increments ?? [],
                                        onProgressChange: (progress) =>
                                            _updateProgress(
                                                exerciseEntry.exerciseName, progress),
                                        unit: unit, // Pass the unit to ExerciseRow
                                      );
                                    }
                                  ),
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
      ),
    ]);
  }
}
