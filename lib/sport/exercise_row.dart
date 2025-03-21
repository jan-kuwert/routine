import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routine/routine_icon_pack_icons.dart';

class ExerciseRow extends StatefulWidget {
  final String title;
  final int goal;
  final int button1Value;
  final int button2Value;
  final Function(double) onProgressChange;

  const ExerciseRow({
    super.key,
    required this.title, // title of the exercise like 'Pushup'
    required this.goal, // the goal of the exercise like '50' reps or '3:00'
    required this.button1Value, // value of increment button 1
    required this.button2Value,
    required this.onProgressChange, // callback to update the progress in parent
  });

  @override
  State<ExerciseRow> createState() => ExerciseRowState();
}

class ExerciseRowState extends State<ExerciseRow> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  int get button1Value => widget.button1Value;
  int get button2Value => widget.button2Value;
  int get goal => widget.goal;
  String get title => widget.title;

  int counter = 0;

  void _increment(int increment) async {
    int value = counter + increment;
    _updateCounter(value);
  }

  void _updateCounter(int value) async {
    setState(() {
      counter = value;
      _controller.text = value.toString();
      widget.onProgressChange(counter / goal > 1.0 ? 1.0 : counter / goal);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: counter.toString());
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Form(
                      child: IntrinsicWidth(
                        child: TextFormField(
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: _controller,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _updateCounter(
                                value.isEmpty ? 0 : int.parse(value));
                          },
                        ),
                      ),
                    ),
                    Text(
                      '/$goal $title',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      softWrap: true,
                    ),
                    if (counter >= goal)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(RoutineIconPack.check, color: Colors.green),
                      ),
                  ],
                ),
              ),
              OverflowBar(
                spacing: 4.0,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primaryContainer),
                    ),
                    onPressed: () {
                      _increment(button1Value);
                    },
                    child: Text('+$button1Value'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primaryContainer),
                    ),
                    onPressed: () {
                      _increment(button2Value);
                    },
                    child: Text('+$button2Value'),
                  ),
                  if (counter < goal)
                    IconButton(
                      icon: const Icon(RoutineIconPack.check),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primaryContainer),
                      ),
                      onPressed: () {
                        _increment(goal - counter);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        if (counter < goal)
          LinearProgressIndicator(
            value: counter / goal,
            minHeight: 7.0,
            borderRadius: BorderRadius.circular(20.0),
          ),
      ],
    );
  }
}
