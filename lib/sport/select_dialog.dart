import 'package:flutter/material.dart';
import 'package:routine/db/entities/exercise.dart';

class SelectDialog extends StatefulWidget {
  final List<Exercise> list;
  final List<String> selectedList;
  final String title;

  const SelectDialog(
      {super.key,
      required this.list, //list of items to display
      required this.selectedList, //saves the selected items
      required this.title});

  @override
  State<SelectDialog> createState() => _SelectDialogState();
}

class _SelectDialogState extends State<SelectDialog> {
  //save all the checkbox values
  late List<bool?> _checkboxValues;

  @override
  void initState() {
    super.initState();
    _checkboxValues = List<bool>.filled(widget.list.length, false);
  }

  void _showExerciseSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.title),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.list.map((exercise) {
                  return CheckboxListTile(
                    value: false,
                    title: Text(exercise.name),
                    onChanged: (value) => setState(() {
                      _checkboxValues[0] = value;
                      if (value == true) {
                        widget.selectedList.add(exercise.name);
                      } else {
                        widget.selectedList.remove(exercise.name);
                      }
                    }),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: const Text(
        '...more',
      ),
      selected: false,
      onSelected: (bool selected) {
        _showExerciseSelectionDialog(context);
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }
}
