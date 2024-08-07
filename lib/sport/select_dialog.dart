import 'package:flutter/material.dart';
import 'package:routine/routine_icon_pack_icons.dart';

class SelectDialog extends StatefulWidget {
  final List<String> list;
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
                children: widget.list.asMap().entries.map((entry) {
                  return CheckboxListTile(
                    value: _checkboxValues[entry.key],
                    title: Text(entry.value),
                    onChanged: (value) => setState(() {
                      _checkboxValues[entry.key] = value;
                      if (value == true) {
                        widget.selectedList.add(entry.value);
                      } else {
                        widget.selectedList.remove(entry.value);
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
    return ElevatedButton.icon(
      onPressed: () => _showExerciseSelectionDialog(context),
      label: const Text('Add Exercis(s)'),
      icon: const Icon(RoutineIconPack.add),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
  }
}
