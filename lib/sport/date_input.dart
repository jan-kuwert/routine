import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';

class DateInputWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final String dateLabel;
  final Function(DateTime) onDateChanged;

  const DateInputWidget({
    super.key,
    required this.selectedDate,
    required this.dateLabel,
    required this.onDateChanged,
  });

  @override
  State<DateInputWidget> createState() => _DateInputWidgetState();
}

class _DateInputWidgetState extends State<DateInputWidget> {
  late TextEditingController _dateController;
  final FocusNode _dateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
        text: widget.selectedDate != null
            ? "${widget.selectedDate!.day}.${widget.selectedDate!.month}.${widget.selectedDate!.year}"
            : "");
    _dateFocusNode.addListener(() {
      if (_dateFocusNode.hasFocus) {
        _selectDate();
      }
    });
  }

  @override
  void didUpdateWidget(DateInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _dateController.text = widget.selectedDate != null
          ? "${widget.selectedDate!.day}.${widget.selectedDate!.month}.${widget.selectedDate!.year}"
          : "";
    }
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
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2130),
      locale: const Locale('en', 'DE'),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}.${picked.month}.${picked.year}";
      });
      widget.onDateChanged(picked);
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
            suffixIcon: IconButton(
              icon: ThemedIcon(Symbols.calendar_today_rounded),
              onPressed: _selectDate,
            ),
          ),
        ),
      ],
    );
  }
}
