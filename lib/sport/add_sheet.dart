import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:routine/db/entities/exercise.dart';
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

  final TextEditingController _exerciseController = TextEditingController();

  final DateTime _workoutDate = DateTime.now();
  final DateTime _goalStartDate = DateTime.now();
  final DateTime _goalEndDate = DateTime.now();

  late String _selectedType = 'Workout';
  final List<String> _selectedExercises = [];

  late Future<List<Exercise>> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = widget.service.getAllExercises();
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
                          if (_selectedType == 'Workout')
                            const Icon(RoutineIconPack.exercise)
                          else if (_selectedType == 'Goal')
                            const Icon(RoutineIconPack.emoji_events),
                          const SizedBox(width: 8.0),
                          Text(
                            'Add a ${_selectedType.toLowerCase()}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
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
                                  dateLabel: 'Date'),
                            ),
                          ],
                        ),
                      if (_selectedType == 'Goal')
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
                                        dateLabel: 'End Date'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 8.0,
                      ),
                      FutureBuilder<List<Exercise>>(
                        future: widget.service.getAllExercises(),
                        builder:
                            (context, AsyncSnapshot<List<Exercise>> snapshot) {
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
                            );
                          }

                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedExercises.isNotEmpty)
                        ..._selectedExercises.map((exercise) => Padding(
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
                                      flex: 3,
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
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Reps',
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
                                  ],
                                ),
                              ),
                            )),
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
                            // if (_selectedType == 'Workout') {
                            //   widget.service.addWorkout(Workout()
                            //     ..date = _workoutDate
                            //     ..exercises = _selectedExercises);
                            // } else if (_selectedType == 'Goal') {
                            //   widget.service.addGoal(Goal()
                            //     ..name = _nameController.text
                            //     ..startDate = _goalStartDate
                            //     ..endDate = _goalEndDate
                            //     ..exercises = _selectedExercises);
                            // }
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
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
