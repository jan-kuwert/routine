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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: Text('$pushupCounter/$maxPushups Pushups'),
                      ),
                      ButtonBar(
                        children: [
                          TextButton.icon(
                            label: Text('$buttonValue10'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {
                              _incrementPushups(buttonValue10);
                            },
                          ),
                          TextButton.icon(
                            label: Text('$buttonValue15'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {
                              _incrementPushups(buttonValue15);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: pushupCounter / maxPushups,
                    minHeight: 10.0,
                    borderRadius: BorderRadius.circular(20.0),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('$pullupCounter/$maxPullups Pullups'),
                      ),
                      ButtonBar(
                        children: [
                          TextButton.icon(
                            label: Text('$buttonValue5'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {
                              _incrementPullups(buttonValue5);
                            },
                          ),
                          TextButton.icon(
                            label: Text('$buttonValue10'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {
                              _incrementPullups(buttonValue10);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: pullupCounter / maxPullups,
                    minHeight: 10.0,
                    borderRadius: BorderRadius.circular(20.0),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
