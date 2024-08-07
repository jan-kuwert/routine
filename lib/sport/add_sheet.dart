import 'package:flutter/material.dart';
import 'package:routine/db/isar_service.dart';
import 'package:routine/routine_icon_pack_icons.dart';
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
  String _selectedType = 'Workout';
  String? _selectedExerciseType;
  late final List<String> _selectedExercises = [];
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
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            TextField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: DatePickerDialog(
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2130)
                                    .add(const Duration(days: 30)),
                                initialDate: DateTime.now(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: _selectedExercises
                                  .map(
                                    (exercise) => ListTile(
                                      title: Text(exercise),
                                      trailing: IconButton(
                                        icon:
                                            const Icon(RoutineIconPack.delete),
                                        onPressed: () {
                                          setState(() {
                                            _selectedExercises.remove(exercise);
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            SelectDialog(
                              list: _exercises,
                              selectedList: _selectedExercises,
                              title: 'Add Exercise(s)',
                            ),
                          ],
                        ),
                      if (_selectedType == 'Goal')
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Goal Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
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
    return FloatingActionButton(
      onPressed: () => _showBottomSheet(context),
      tooltip: 'Increment',
      child: const Icon(RoutineIconPack.add),
    );
  }
}
