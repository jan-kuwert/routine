import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:routine/components/goal_card.dart';
import 'package:routine/db/entities/goal.dart';
import 'package:routine/services/firestore_service.dart';

class GoalHistoryScreen extends StatefulWidget {
  const GoalHistoryScreen({super.key});

  @override
  State<GoalHistoryScreen> createState() => _GoalHistoryScreenState();
}

class _GoalHistoryScreenState extends State<GoalHistoryScreen> {
  final firestoreService = FirestoreService();

  Future<List<Goal>> _getAllGoals() async {
    return firestoreService.getAllGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('All Goals'),
          ),
          FutureBuilder<List<Goal>>(
            future: _getAllGoals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No past workouts')),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goal = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                        child: GoalCard(
                          title:
                              '${DateFormat.MMMMd().format(goal.start)} - ${DateFormat.yMMMMd().format(goal.end)}',
                        ),
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
