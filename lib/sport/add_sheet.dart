import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final DateTime _workoutDate = DateTime.now();
  final DateTime _goalStartDate = DateTime.now();
  final DateTime _goalEndDate = DateTime.now();

  late String _selectedType = 'Workout';
  final List<String> _selectedExercises = [];
  final List<String> _exercises = [
    'Push-ups',
    'Sit-ups',
    'Squats',
    'Lunges',
    'Plank',
  ];

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
                      Text(
                        'Add a ${_selectedType.toLowerCase()}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 30),
                      SegmentedButton<String>(
                        segments: const <ButtonSegment<String>>[
                          ButtonSegment<String>(
                            value: 'Workout',
                            label: Text('Workout'),
                            icon: Icon(RoutineIconPack.exercise),
                          ),
                          ButtonSegment<String>(
                            value: 'Goal',
                            label: Text('Goal'),
                            icon: Icon(RoutineIconPack.emoji_events),
                          ),
                        ],
                        selected: <String>{_selectedType},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedType = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      if (_selectedType == 'Workout')
                        Column(
                          children: [
                            DateInputWidget(
                                selectedDate: _workoutDate, dateLabel: 'Date'),
                          ],
                        ),
                      if (_selectedType == 'Goal')
                        Column(
                          children: [
                            TextField(
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
                            const Divider(),
                            DateInputWidget(
                                selectedDate: _goalStartDate,
                                dateLabel: 'Start Date'),
                            const SizedBox(height: 16),
                            DateInputWidget(
                                selectedDate: _goalEndDate,
                                dateLabel: 'End Date'),
                          ],
                        ),
                      const Divider(),
                      const SizedBox(
                        height: 8.0,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _exercises
                              .map(
                                (exercise) => Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: FilterChip(
                                    label: Text(exercise),
                                    selected:
                                        _selectedExercises.contains(exercise),
                                    onSelected: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedExercises.add(exercise);
                                        } else {
                                          _selectedExercises.remove(exercise);
                                        }
                                      });
                                    },
                                    selectedColor:
                                        Theme.of(context).colorScheme.primary,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SelectDialog(
                        list: _exercises,
                        selectedList: _selectedExercises,
                        title: 'Select Exercise(s)',
                      ),
                      const SizedBox(height: 40),
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
        color:
            Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.9),
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
