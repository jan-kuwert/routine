import 'package:flutter/material.dart';

class DateInputWidget extends StatefulWidget {
  final DateTime selectedDate;

  const DateInputWidget({super.key, required this.selectedDate});

  @override
  State<DateInputWidget> createState() => _DateInputWidgetState();
}

class _DateInputWidgetState extends State<DateInputWidget> {
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _dateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.selectedDate;
    _dateFocusNode.addListener(() {
      if (_dateFocusNode.hasFocus) {
        _selectDate();
      }
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _dateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2130),
    );
    if (picked != null) {
      setState(() {
        // setState(() {
        //   widget.selectedDate = picked;
        // });
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
    _dateFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _dateController,
          focusNode: _dateFocusNode,
          decoration: const InputDecoration(
            labelText: 'Date',
            border: OutlineInputBorder(),
          ),
        ),
        // Other widgets...
      ],
    );
  }
}
