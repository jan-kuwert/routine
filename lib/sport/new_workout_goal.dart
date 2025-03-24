import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/goal.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/sport/date_input.dart';
import 'package:routine/sport/select_dialog.dart';

class AddSheet extends StatefulWidget {
  final IsarService service;
  final GlobalKey<ExpandableFabState> fabKey;

  const AddSheet({super.key, required this.service, required this.fabKey});

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalTypeController = TextEditingController();

  DateTime _workoutDate = DateTime.now();
  DateTime _goalStartDate = DateTime.now();
  DateTime _goalEndDate = DateTime.now();

  late String _selectedType = 'Workout';
  final List<String> _selectedExercises = [];
  final Map<String, TextEditingController> _exerciseControllers = {};

  List<ExerciseTarget> _getTargets() {
    final List<ExerciseTarget> targets = [];
    for (var exercise in _selectedExercises) {
      final value = _exerciseControllers[exercise]!.text.replaceAll(',', '.');
      targets.add(ExerciseTarget()
        ..exercise = exercise
        ..target = double.parse(value));
    }
    return targets;
  }

  List<ExerciseEntry> _getExercises() {
    final List<ExerciseEntry> exercises = [];
    for (var exercise in _selectedExercises) {
      final value = _exerciseControllers[exercise]!.text.replaceAll(',', '.');

      exercises.add(ExerciseEntry()
        ..exerciseName = exercise
        ..counter = 0
        ..target = double.parse(value));
    }
    return exercises;
  }

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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                          if (_selectedType == 'Workout')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Add new ${_selectedType.toLowerCase()}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(width: 4),
                                const Icon(RoutineIconPack.exercise),
                              ],
                            )
                          else if (_selectedType == 'Goal')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Set new ${_selectedType.toLowerCase()}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(width: 4),
                                const Icon(RoutineIconPack.emoji_events),
                              ],
                            )
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (_selectedType == 'Workout')
                        Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 100),
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
                                    inputDecorationTheme:
                                        const InputDecorationTheme(
                                      border: InputBorder.none,
                                    ),
                                    dropdownMenuEntries: GoalType.values
                                        .map((type) => DropdownMenuEntry(
                                              value: type,
                                              label: type
                                                  .toString()
                                                  .split('.')
                                                  .last,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
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
                        Column(
                          children: [
                            const Divider(),
                            const SizedBox(
                              height: 8.0,
                            ),
                            FutureBuilder<List<Exercise>>(
                              future: widget.service.getAllExercises(),
                              builder: (context,
                                  AsyncSnapshot<List<Exercise>> snapshot) {
                                if (snapshot.hasData) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ...snapshot.data!.take(5).map(
                                              (exercise) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: FilterChip(
                                                  label: Text(exercise.name),
                                                  selected: _selectedExercises
                                                      .contains(exercise.name),
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      if (selected) {
                                                        _selectedExercises
                                                            .add(exercise.name);
                                                      } else {
                                                        _selectedExercises
                                                            .remove(
                                                                exercise.name);
                                                      }
                                                    });
                                                  },
                                                  selectedColor: Theme.of(
                                                          context)
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                                  backgroundColor:
                                                      Theme.of(context)
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
                                  );
                                }

                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_selectedExercises.isNotEmpty)
                              Column(
                                children: _selectedExercises
                                    .map((exercise) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerLow,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8.0),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHigh,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: FutureBuilder<
                                                              Exercise?>(
                                                          future: widget.service
                                                              .getExerciseByName(
                                                                  exercise),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (!snapshot
                                                                .hasData) {
                                                              return const CircularProgressIndicator();
                                                            }
                                                            final exerciseData =
                                                                snapshot.data!;
                                                            // Use a controller based on the exercise name
                                                            final controller =
                                                                TextEditingController();
                                                            // Store in a map in the parent widget if it doesn't exist yet
                                                            if (!_exerciseControllers
                                                                .containsKey(
                                                                    exercise)) {
                                                              _exerciseControllers[
                                                                      exercise] =
                                                                  controller;
                                                            }
                                                            return TextField(
                                                              controller:
                                                                  _exerciseControllers[
                                                                      exercise],
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              inputFormatters: [
                                                                exerciseData.type ==
                                                                        ExerciseType
                                                                            .repetitions
                                                                    ? FilteringTextInputFormatter
                                                                        .digitsOnly
                                                                    : FilteringTextInputFormatter
                                                                        .allow(RegExp(
                                                                            r'[1-9][0-9]*[,.]?[0-9]*'))
                                                              ],
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText: exerciseData
                                                                            .type ==
                                                                        ExerciseType
                                                                            .duration
                                                                    ? 'Duration (min)'
                                                                    : 'Reps',
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                floatingLabelStyle:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                ),
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                // Ensure empty field doesn't remain in the form
                                                                if (value
                                                                    .isEmpty) {
                                                                  _exerciseControllers[
                                                                          exercise]!
                                                                      .text = "1";
                                                                }
                                                              },
                                                            );
                                                          })),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: ButtonStyle(
                            textStyle: WidgetStateProperty.all<TextStyle>(
                              const TextStyle(
                                  fontSize: 16.0), // Increased font size
                            ),
                          ),
                          onPressed: () {
                            if (_selectedType == 'Workout') {
                              widget.service.addWorkout(Workout(
                                date: _workoutDate,
                                exercises: _getExercises(),
                              ));
                            } else if (_selectedType == 'Goal') {
                              widget.service.addGoal(
                                Goal(
                                  title: _nameController.text,
                                  start: _goalStartDate,
                                  end: _goalEndDate,
                                  type: GoalType.sport,
                                  targets: _getTargets(),
                                ),
                              );
                            }
                            Navigator.pop(context);
                          },
                          child: Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
        child: const Icon(RoutineIconPack.add),
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
                setState(() {
                  _selectedType = 'Workout';
                }),
                widget.fabKey.currentState!.toggle()
              },
              tooltip: 'Add Exercise',
              child: const Icon(RoutineIconPack.exercise),
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
                  setState(() {
                    _selectedType = 'Goal';
                  }),
                  widget.fabKey.currentState!.toggle()
                },
                tooltip: 'Add Goal',
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                child: const Icon(RoutineIconPack.emoji_events),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
