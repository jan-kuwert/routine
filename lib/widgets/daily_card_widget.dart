import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routine/routine_icon_pack_icons.dart';

class DailyCardWidget extends StatefulWidget {
  final String title;

  const DailyCardWidget({
    super.key,
    required this.title,
  });

  @override
  State<DailyCardWidget> createState() => _DailyCardWidgetState();
}

class _DailyCardWidgetState extends State<DailyCardWidget> {
  late TextEditingController _pullupController;
  late FocusNode _focusNode;

  final int buttonValue5 = 5;
  final int buttonValue10 = 10;
  final int buttonValue15 = 15;

  int pushupCounter = 0;
  int maxPushups = 50;
  int pullupCounter = 0;
  int maxPullups = 25;

  void _incrementPushups(int value) async {
    setState(() {
      if (pushupCounter <= maxPushups - value) {
        pushupCounter += value;
      } else {
        pushupCounter = maxPushups;
      }
    });
  }

  void _incrementPullups(int value) async {
    setState(() {
      if (pullupCounter <= maxPullups - value) {
        pullupCounter += value;
      } else {
        pullupCounter = maxPullups;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pullupController = TextEditingController(text: pullupCounter.toString());
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
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18.0)),
                if (((pushupCounter / maxPushups + pullupCounter / maxPullups) /
                        2) ==
                    1)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      RoutineIconPack.done_all,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            Text(
                '${(((pushupCounter / maxPushups + pullupCounter / maxPullups) / 2) * 100).round()}%',
                style: const TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: LinearProgressIndicator(
                  value: (pushupCounter / maxPushups +
                          pullupCounter / maxPullups) /
                      2,
                  minHeight: 1.0,
                  color: const Color.fromARGB(10, 0, 0, 0),
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _focusNode.requestFocus();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter some text';
                                                }
                                                return null;
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    2),
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '/$maxPushups Pushups',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                          softWrap: true,
                                        ),
                                        if (pushupCounter == maxPushups)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(RoutineIconPack.check,
                                                color: Colors.green),
                                          ),
                                      ],
                                    ),
                                  ),
                                  ButtonBar(
                                    children: [
                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  const Color.fromARGB(
                                                      25, 0, 0, 0)),
                                        ),
                                        onPressed: () {
                                          _incrementPushups(buttonValue10);
                                        },
                                        child: Text('+$buttonValue10'),
                                      ),
                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  const Color.fromARGB(
                                                      25, 0, 0, 0)),
                                        ),
                                        onPressed: () {
                                          _incrementPushups(buttonValue15);
                                        },
                                        child: Text('+$buttonValue15'),
                                      ),
                                      if (pushupCounter < maxPushups)
                                        IconButton(
                                          icon:
                                              const Icon(RoutineIconPack.check),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    const Color.fromARGB(
                                                        25, 0, 0, 0)),
                                          ),
                                          onPressed: () {
                                            _incrementPushups(
                                                maxPushups - pushupCounter);
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (pushupCounter < maxPushups)
                              LinearProgressIndicator(
                                value: pushupCounter / maxPushups,
                                minHeight: 7.0,
                                borderRadius: BorderRadius.circular(20.0),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
