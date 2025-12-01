import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/goal.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/sport/new_workout_goal.dart';

class GoalCard extends StatefulWidget {
  final Goal goal;
  final FirestoreService firestoreService;

  const GoalCard(
      {super.key, required this.goal, required this.firestoreService});

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  Goal get goal => widget.goal;
  FirestoreService get firestoreService => widget.firestoreService;

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const ThemedIcon(Symbols.edit_rounded),
              title: const Text('Edit Goal'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (context) => WorkoutGoalSheet(
                    firestoreService: firestoreService,
                    goal: goal,
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const ThemedIcon(Symbols.delete_rounded, color: Colors.red),
              title: const Text('Delete Goal',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Goal'),
                    content: const Text(
                        'Are you sure you want to delete this goal?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await firestoreService.deleteGoal(goal.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showMenu,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.title, style: const TextStyle(fontSize: 18.0)),
              IconButton(
                icon: ThemedIcon(
                  goal.pinned ? Symbols.keep_off_rounded : Symbols.keep_rounded,
                ),
                onPressed: () async {
                  await firestoreService.updateGoal(Goal(
                    id: goal.id,
                    title: goal.title,
                    start: goal.start,
                    end: goal.end,
                    type: goal.type,
                    targets: goal.targets,
                    pinned: !goal.pinned,
                    progress: goal.progress,
                  ));
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
              side: goal.pinned
                  ? BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 3.0,
                    )
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: ThemedIcon(
                            Symbols.emoji_events_rounded,
                            size: 24.0,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            goal.targets
                                .map((t) => '${t.target} ${t.exercise}')
                                .join(', '),
                            softWrap: true,
                            style: const TextStyle(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                  'Progress: ${(goal.progress * 100).toInt()}%'),
                            ),
                            Text('${(goal.progress * 100).toInt()}%')
                          ],
                        ),
                        LinearProgressIndicator(
                          value: goal.progress,
                          minHeight: 10.0,
                          borderRadius: BorderRadius.circular(20.0),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
