import 'package:flutter/material.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';
import 'package:routine/sport/date_input.dart';
import 'package:routine/sport/select_dialog.dart';

class AddSheet extends StatefulWidget {
  final IsarService service;

  const AddSheet({super.key, required this.service});

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

  late bool _fabMenu = false;

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

  // void _showFloatingActionButtons(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Scaffold(
  //         floatingActionButton: Column(
  //           children: [
  //             Column(
  //               children: [
  //                 FloatingActionButton(
  //                   onPressed: () => _showBottomSheet(context),
  //                   tooltip: 'Increment',
  //                   child: const Icon(RoutineIconPack.add),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 const Text('Main Action'),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 FloatingActionButton(
  //                   mini: true,
  //                   onPressed: () => _showBottomSheet(context),
  //                   tooltip: 'Increment',
  //                   child: const Icon(RoutineIconPack.add),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 const Text('Secondary Action'),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _showFloatingActionButtons(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        tooltip: 'Increment',
        child: const Icon(RoutineIconPack.home),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _fabMenu = true,
      tooltip: 'Increment',
      child: const Icon(RoutineIconPack.add),
    );
    if (_fabMenu) {
      Stack(
        children: [
          // Your main content goes here
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _showBottomSheet(context),
                  tooltip: 'Secondary Action',
                  child: const Icon(RoutineIconPack.add),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () => _showBottomSheet(context),
                  tooltip: 'Main Action',
                  child: const Icon(RoutineIconPack.home),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
