import 'package:flutter/material.dart';
import 'package:routine/routine_icon_pack_icons.dart';

class GoalCardWidget extends StatefulWidget {
  final String title;
  late bool pinned;

  GoalCardWidget({super.key, required this.title, this.pinned = false});

  @override
  State<GoalCardWidget> createState() => _GoalCardWidgetState();
}

class _GoalCardWidgetState extends State<GoalCardWidget> {
  final double progress = 0.33;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 18.0)),
            IconButton(
              icon: Icon(
                widget.pinned ? RoutineIconPack.keep_off : RoutineIconPack.keep,
              ),
              onPressed: () {
                setState(() {
                  widget.pinned = !(widget.pinned);
                });
              },
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 3.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: Icon(
                          RoutineIconPack.emoji_events,
                          size: 24.0,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '50 Pushups/Day for 30 Days',
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text('Progress: 500/1500'),
                          ),
                          Text('33%')
                        ],
                      ),
                      LinearProgressIndicator(
                        value: 0.33,
                        minHeight: 10.0,
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Icon(RoutineIconPack.local_fire_department,
                        size: 28.0, color: Color(0xFFFF8F0F)),
                    Text('10 Days Streak!'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
