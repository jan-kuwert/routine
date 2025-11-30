import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/goal.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/sport/date_input.dart';
import 'package:routine/sport/select_dialog.dart';

class WorkoutGoalSheet extends StatefulWidget {
  final FirestoreService firestoreService;
  final Workout? workout;
  final Goal? goal;

  const WorkoutGoalSheet({
    super.key,
    required this.firestoreService,
    this.workout,
    this.goal,
  });

  @override
  State<WorkoutGoalSheet> createState() => _WorkoutGoalSheetState();
}

class _WorkoutGoalSheetState extends State<WorkoutGoalSheet> {
  FirestoreService get firestoreService => widget.firestoreService;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalTypeController = TextEditingController();

  DateTime? _workoutDate;
  DateTime _goalStartDate = DateTime.now();
  DateTime _goalEndDate = DateTime.now();

  late String _selectedType = 'Workout';
  final List<String> _selectedExercises = [];
  final Map<String, TextEditingController> _exerciseControllers = {};
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _selectedType = 'Workout';
      _workoutDate = widget.workout!.date;
      for (var entry in widget.workout!.exercises) {
        _selectedExercises.add(entry.exerciseName);
        _exerciseControllers[entry.exerciseName] =
            TextEditingController(text: entry.target.toString());
      }
    } else if (widget.goal != null) {
      _selectedType = 'Goal';
      _nameController.text = widget.goal!.title;
      _goalStartDate = widget.goal!.start;
      _goalEndDate = widget.goal!.end;
      _goalTypeController.text = widget.goal!.type.toString().split('.').last;
      for (var target in widget.goal!.targets) {
        _selectedExercises.add(target.exercise);
        _exerciseControllers[target.exercise] =
            TextEditingController(text: target.target.toString());
      }
    } else {
      _goalTypeController.text = GoalType.sport.toString().split('.').last;
    }
  }

  List<ExerciseTarget> _getTargets() {
    final List<ExerciseTarget> targets = [];
    for (var exercise in _selectedExercises) {
      final value = _exerciseControllers[exercise]!.text.replaceAll(',', '.');
      final target = double.parse(value);
      if (target <= 0) {
        throw Exception('Target value must be greater than 0');
      }
      targets.add(ExerciseTarget(exercise: exercise, target: target));
    }
    return targets;
  }

  List<ExerciseEntry> _getExercises() {
    final List<ExerciseEntry> exercises = [];
    for (var exerciseName in _selectedExercises) {
      final value =
          _exerciseControllers[exerciseName]!.text.replaceAll(',', '.');

      final target = double.parse(value);
      if (target <= 0) {
        throw Exception('Target value must be greater than 0');
      }

      double currentCounter = 0;
      if (widget.workout != null) {
        final existingEntry = widget.workout!.exercises
            .firstWhereOrNull((e) => e.exerciseName == exerciseName);
        if (existingEntry != null) {
          currentCounter = existingEntry.counter;
        }
      }

      exercises.add(ExerciseEntry(
          exerciseName: exerciseName, counter: currentCounter, target: target));
    }
    return exercises;
  }

  bool _isFormValid() {
    if (_selectedType == 'Workout') {
      if (_workoutDate == null) return false;
      if (_selectedExercises.isEmpty) return false;

      for (var exercise in _selectedExercises) {
        final controller = _exerciseControllers[exercise];
        if (controller == null || controller.text.isEmpty) return false;
      }
      return true;
    } else {
      // Goal validation
      if (_nameController.text.isEmpty) return false;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8.0),
                  Text(
                    widget.workout != null
                        ? 'Edit workout'
                        : widget.goal != null
                            ? 'Edit goal'
                            : 'Add new ${_selectedType.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 4),
                  if (_selectedType == 'Workout')
                    const ThemedIcon(Symbols.exercise_rounded)
                  else
                    const ThemedIcon(Symbols.emoji_events_rounded),
                ],
              ),
              const SizedBox(height: 30),
              if (_selectedType == 'Workout')
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DateInputWidget(
                        selectedDate: _workoutDate,
                        dateLabel: 'Date',
                        onDateChanged: (DateTime date) {
                          setState(() {
                            _workoutDate = date;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              if (_selectedType == 'Goal')
                Column(
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Goal Title',
                                border: InputBorder.none,
                                floatingLabelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.only(left: 8.0),
                          alignment: Alignment.center,
                          child: DropdownMenu<GoalType>(
                            label: const Text('Type'),
                            inputDecorationTheme: const InputDecorationTheme(
                              border: InputBorder.none,
                            ),
                            dropdownMenuEntries: GoalType.values
                                .map((type) => DropdownMenuEntry(
                                      value: type,
                                      label: type.toString().split('.').last,
                                    ))
                                .toList(),
                            controller: _goalTypeController,
                            onSelected: (GoalType? type) {
                              setState(() {
                                _goalTypeController.text =
                                    type.toString().split('.').last;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DateInputWidget(
                              selectedDate: _goalStartDate,
                              dateLabel: 'Start Date',
                              onDateChanged: (DateTime date) {
                                setState(() {
                                  _goalStartDate = date;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DateInputWidget(
                              selectedDate: _goalEndDate,
                              dateLabel: 'End Date',
                              onDateChanged: (DateTime date) {
                                setState(() {
                                  _goalEndDate = date;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(
                height: 8.0,
              ),
              if (_goalTypeController.text ==
                      GoalType.sport.toString().split('.').last ||
                  _selectedType == 'Workout')
                FutureBuilder<List<Exercise>>(
                  future: firestoreService.getAllExercises(),
                  builder: (context, AsyncSnapshot<List<Exercise>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Create a map for O(1) lookup
                    final exerciseMap = {
                      for (var ex in snapshot.data!) ex.name: ex
                    };

                    return Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...snapshot.data!.take(5).map(
                                    (exercise) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: FilterChip(
                                        label: Text(exercise.name),
                                        selected: _selectedExercises
                                            .contains(exercise.name),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              if (!_selectedExercises
                                                  .contains(exercise.name)) {
                                                _selectedExercises
                                                    .add(exercise.name);
                                              }
                                            } else {
                                              _selectedExercises
                                                  .remove(exercise.name);
                                              _exerciseControllers
                                                  .remove(exercise.name);
                                            }
                                          });
                                        },
                                        selectedColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerLow,
                                      ),
                                    ),
                                  ),
                              SelectDialog(
                                list: snapshot.data!,
                                selectedList: _selectedExercises,
                                title: 'Select Exercise(s)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedExercises.isNotEmpty)
                          Column(
                            children: _selectedExercises.map((exercise) {
                              final exerciseData = exerciseMap[exercise];
                              if (exerciseData == null) {
                                return const SizedBox.shrink();
                              }

                              // Initialize controller if not exists
                              if (!_exerciseControllers.containsKey(exercise)) {
                                _exerciseControllers[exercise] =
                                    TextEditingController();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          exercise[0].toUpperCase() +
                                              exercise.substring(1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHigh,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: TextField(
                                            controller:
                                                _exerciseControllers[exercise],
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              exerciseData.type ==
                                                      ExerciseType.repetitions
                                                  ? FilteringTextInputFormatter
                                                      .digitsOnly
                                                  : FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'[1-9][0-9]*[,.]?[0-9]*'))
                                            ],
                                            decoration: InputDecoration(
                                              labelText: exerciseData.type ==
                                                      ExerciseType.duration
                                                  ? 'Duration (min)'
                                                  : 'Reps',
                                              border: InputBorder.none,
                                              floatingLabelStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 16),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 16.0), // Increased font size
                    ),
                  ),
                  onPressed: _isFormValid()
                      ? () async {
                          try {
                            setState(() {
                              errorMessage = null;
                            });

                            if (_selectedType == 'Workout') {
                              // Validate workout date
                              final now = DateTime.now();
                              final minDate =
                                  now.subtract(const Duration(days: 365));
                              final maxDate =
                                  now.add(const Duration(days: 365));

                              if (_workoutDate!.isBefore(minDate) ||
                                  _workoutDate!.isAfter(maxDate)) {
                                throw Exception(
                                    'Workout date must be within one year from today');
                              }

                              if (widget.workout != null) {
                                // Update existing workout
                                await firestoreService.updateWorkout(Workout(
                                  id: widget.workout!.id,
                                  date: _workoutDate!,
                                  exercises: _getExercises(),
                                ));
                              } else {
                                // Create new workout
                                await firestoreService.addWorkout(Workout(
                                  id: '',
                                  date: _workoutDate!,
                                  exercises: _getExercises(),
                                ));
                              }
                            } else if (_selectedType == 'Goal') {
                              // Validate goal dates
                              if (_goalEndDate.isBefore(_goalStartDate)) {
                                throw Exception(
                                    'End date must be after start date');
                              }

                              final daysDifference = _goalEndDate
                                  .difference(_goalStartDate)
                                  .inDays;
                              if (daysDifference > 365) {
                                throw Exception(
                                    'Goal duration cannot exceed one year');
                              }

                              if (widget.goal != null) {
                                await firestoreService.updateGoal(
                                  Goal(
                                    id: widget.goal!.id,
                                    title: _nameController.text,
                                    start: _goalStartDate,
                                    end: _goalEndDate,
                                    type: GoalType.sport,
                                    targets: _getTargets(),
                                  ),
                                );
                              } else {
                                await firestoreService.addGoal(
                                  Goal(
                                    id: '',
                                    title: _nameController.text,
                                    start: _goalStartDate,
                                    end: _goalEndDate,
                                    type: GoalType.sport,
                                    targets: _getTargets(),
                                  ),
                                );
                              }
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            setState(() {
                              errorMessage = e.toString();
                            });
                          }
                        }
                      : null,
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddSheet extends StatefulWidget {
  final FirestoreService firestoreService;
  final GlobalKey<ExpandableFabState> fabKey;

  const AddSheet(
      {super.key, required this.firestoreService, required this.fabKey});

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  FirestoreService get firestoreService => widget.firestoreService;

  @override
  void initState() {
    super.initState();
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      sheetAnimationStyle: AnimationStyle(curve: const ElasticInCurve()),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return WorkoutGoalSheet(
          firestoreService: firestoreService,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: widget.fabKey,
      type: ExpandableFabType.up,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHigh
            .withValues(alpha: .9),
      ),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const ThemedIcon(Symbols.add_rounded),
        fabSize: ExpandableFabSize.regular,
      ),
      closeButtonBuilder: FloatingActionButtonBuilder(
        size: 56,
        builder: (BuildContext context, void Function()? onPressed,
            Animation<double> progress) {
          return const Text('');
        },
      ),
      childrenOffset: const Offset(0, -70),
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      children: [
        Row(
          children: [
            const Text('Workout'),
            const SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () => {
                _showBottomSheet(context),
                widget.fabKey.currentState!.toggle()
              },
              tooltip: 'Add Exercise',
              child: const ThemedIcon(Symbols.exercise_rounded),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Goal'),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FloatingActionButton.small(
                onPressed: () => {
                  _showBottomSheet(context),
                  widget.fabKey.currentState!.toggle()
                },
                tooltip: 'Add Goal',
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                child: const ThemedIcon(Symbols.emoji_events_rounded),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
