import 'package:flutter/material.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/isar_service.dart';

class CreateExerciseDialog extends StatefulWidget {
  final IsarService service;

  const CreateExerciseDialog({super.key, required this.service});

  @override
  State<CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<CreateExerciseDialog> {
  late String? name = '';
  late ExerciseCategory? category;
  late ExerciseType? type;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceBright,
          title: const Text('Add new Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => name = value,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownMenu<ExerciseCategory>(
                  width: 220,
                  label: const Text('Category'),
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                  ),
                  dropdownMenuEntries: ExerciseCategory.values
                      .map((category) => DropdownMenuEntry(
                            value: category,
                            label: category.toString().split('.').last,
                          ))
                      .toList(),
                  controller: _categoryController,
                  onSelected: (value) => setState(() {
                    _categoryController.text = value.toString().split('.').last;
                    category = value;
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownMenu<ExerciseType>(
                  width: 220,
                  label: const Text('Type'),
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                  ),
                  dropdownMenuEntries: ExerciseType.values
                      .map((type) => DropdownMenuEntry(
                            value: type,
                            label: type.toString().split('.').last,
                          ))
                      .toList(),
                  controller: _typeController,
                  onSelected: (value) => setState(() {
                    _typeController.text = value.toString().split('.').last;
                    type = value;
                  }),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => {
                if (name != null && category != null && type != null)
                  widget.service.addExercise(Exercise()
                    ..name = name!
                    ..category = category as ExerciseCategory
                    ..type = type as ExerciseType),
                Navigator.pop(context, 'Save')
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      child: const Text('Add new Exercise'),
    );
  }
}
