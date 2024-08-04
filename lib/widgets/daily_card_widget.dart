import 'package:flutter/material.dart';
import 'package:routine/routine_font_icons.dart';

class DailyCardWidget extends StatelessWidget {
  final double progress = 0.33;

  const DailyCardWidget({super.key});

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
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('10/50 Pushups'),
                      ),
                      ButtonBar(
                        children: [
                          TextButton.icon(
                            label: const Text('10'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {},
                          ),
                          TextButton.icon(
                            label: const Text('15'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: 0.2,
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
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('10/25 Pullups'),
                      ),
                      ButtonBar(
                        children: [
                          TextButton.icon(
                            label: const Text('5'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {},
                          ),
                          TextButton.icon(
                            label: const Text('10'),
                            icon: const Icon(RoutineFont.add),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: 0.4,
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
