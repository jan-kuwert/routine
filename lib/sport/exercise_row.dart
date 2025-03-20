import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routine/routine_icon_pack_icons.dart';

class ExerciseRow extends StatefulWidget {
  final String title;
  final int max;
  final int button1Value;
  final int button2Value;

  const ExerciseRow({
    super.key,
    required this.title,
    required this.max,
    required this.button1Value,
    required this.button2Value,
  });

  @override
  State<ExerciseRow> createState() => _ExerciseRowState();
}

class _ExerciseRowState extends State<ExerciseRow> {
  late TextEditingController _pullupController;
  late FocusNode _focusNode;

  int get button1Value => widget.button1Value;
  int get button2Value => widget.button2Value;
  int get max => widget.max;
  String get title => widget.title;

  int counter = 0;

  void _increment(int value) async {
    setState(() {
      if (counter <= max - value) {
        counter += value;
      } else {
        counter = max;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pullupController = TextEditingController(text: counter.toString());
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _pullupController.dispose();
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
                          controller: _pullupController,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    Text(
                      '/$max $title',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      softWrap: true,
                    ),
                    if (counter == max)
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
                          const Color.fromARGB(25, 0, 0, 0)),
                    ),
                    onPressed: () {
                      _increment(button1Value);
                    },
                    child: Text('+$button1Value'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(25, 0, 0, 0)),
                    ),
                    onPressed: () {
                      _increment(button2Value);
                    },
                    child: Text('+$button2Value'),
                  ),
                  if (counter < max)
                    IconButton(
                      icon: const Icon(RoutineIconPack.check),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(25, 0, 0, 0)),
                      ),
                      onPressed: () {
                        _increment(max - counter);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        if (counter < max)
          LinearProgressIndicator(
            value: counter / max,
            minHeight: 7.0,
            borderRadius: BorderRadius.circular(20.0),
          ),
      ],
    );
  }
}
