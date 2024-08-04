import 'package:flutter/material.dart';
import 'package:routine/routine_font_icons.dart';

class DailyCardWidget extends StatefulWidget {
  const DailyCardWidget({super.key});

  @override
  State<DailyCardWidget> createState() => _DailyCardWidgetState();
}

class _DailyCardWidgetState extends State<DailyCardWidget> {
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
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: LinearProgressIndicator(
              value:
                  (pushupCounter / maxPushups + pullupCounter / maxPullups) / 2,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '$pushupCounter/$maxPushups Pushups',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                                softWrap: true,
                              ),
                            ),
                            if (pushupCounter == maxPushups)
                              const Icon(
                                RoutineFont.check,
                                color: Colors.green,
                              )
                            else
                              ButtonBar(
                                children: [
                                  if (pushupCounter <
                                      maxPushups - buttonValue10)
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
                                  if (pushupCounter <
                                      maxPushups - buttonValue15)
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
                                  IconButton(
                                    icon: const Icon(RoutineFont.check),
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all<
                                              Color>(
                                          const Color.fromARGB(25, 0, 0, 0)),
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
                        if (pushupCounter != maxPushups)
                          LinearProgressIndicator(
                            value: pushupCounter / maxPushups,
                            minHeight: 7.0,
                            borderRadius: BorderRadius.circular(20.0),
                          )
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '$pullupCounter/$maxPullups Pullups',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                            softWrap: true,
                          ),
                        ),
                        if (pullupCounter == maxPullups)
                          const Icon(
                            RoutineFont.check,
                            color: Colors.green,
                          )
                        else
                          ButtonBar(
                            children: [
                              if (pullupCounter < maxPullups - buttonValue5)
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                            const Color.fromARGB(25, 0, 0, 0)),
                                  ),
                                  onPressed: () {
                                    _incrementPullups(buttonValue5);
                                  },
                                  child: Text('+$buttonValue5'),
                                ),
                              if (pullupCounter < maxPullups - buttonValue10)
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                            const Color.fromARGB(25, 0, 0, 0)),
                                  ),
                                  onPressed: () {
                                    _incrementPullups(buttonValue10);
                                  },
                                  child: Text('+$buttonValue10'),
                                ),
                              IconButton(
                                icon: const Icon(RoutineFont.check),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          const Color.fromARGB(25, 0, 0, 0)),
                                ),
                                onPressed: () {
                                  _incrementPullups(maxPullups - pullupCounter);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (pushupCounter != maxPushups)
                      LinearProgressIndicator(
                        value: pullupCounter / maxPullups,
                        minHeight: 7.0,
                        borderRadius: BorderRadius.circular(20.0),
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
