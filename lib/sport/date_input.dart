import 'package:flutter/material.dart';

class DateInputWidget extends StatefulWidget {
  final DateTime selectedDate;
  final String dateLabel;

  const DateInputWidget(
      {super.key, required this.selectedDate, required this.dateLabel});

  @override
  State<DateInputWidget> createState() => _DateInputWidgetState();
}

class _DateInputWidgetState extends State<DateInputWidget> {
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _dateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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
        // widget.selectedDate = picked;
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
          readOnly: true,
          focusNode: _dateFocusNode,
          decoration: InputDecoration(
            labelText: widget.dateLabel,
            border: InputBorder.none,
          ),
        ),
        // Other widgets...
      ],
    );
  }
}
