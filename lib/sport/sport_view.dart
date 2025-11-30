
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:routine/components/daily_card.dart';
import 'package:routine/components/goal_card.dart';
import 'package:routine/custom_icons.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/services/firestore_service.dart';
import 'package:routine/sport/goal_history.dart';
import 'package:routine/sport/new_workout_goal.dart';
import 'package:routine/sport/workout_history.dart';

class SportView extends StatefulWidget {
  final FirestoreService firestoreService;

  const SportView({super.key, required this.firestoreService});

  @override
  State<SportView> createState() => _SportViewState();
}

class _SportViewState extends State<SportView> {
  FirestoreService get firestoreService => widget.firestoreService;

  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  late Future<List<Workout>> workouts;
  final String jsonPath = 'assets/exercises.json';
  late List<Exercise> exerciseList = [];

  // Add this to keep track of mounted state for async operations
  bool _isDisposed = false;

  // Override dispose to set the flag when widget is removed
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> getAllExercises() async {
    try {
      if (firestoreService.currentUserId == null) {
        debugPrint('User not authenticated yet, skipping getAllExercises');
        return;
      }
      final exercises = await firestoreService.getAllExercises();

      // Check if widget is still mounted before calling setState
      if (!_isDisposed && mounted) {
        setState(() {
          exerciseList = exercises;
        });
      }
    } catch (e) {
      debugPrint('Error getting exercises: $e');
    }
  }

  String _getDailyCardTitle(DateTime date) {
    final dateTime = date;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    // Create comparable date from the timestamp's DateTime
    final compareDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    debugPrint('Compare Date: $compareDate');
    if (compareDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (compareDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (compareDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    }

    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  @override
  void initState() {
    super.initState();
    // We need to use Future.delayed because context isn't available immediately in initState
    Future.microtask(() => {getAllExercises()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_fabKey.currentState?.isOpen == true) {
            _fabKey.currentState?.toggle();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Sport'),
              actions: [
                IconButton(
                  icon: const ThemedIcon(Symbols.emoji_events_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoalHistoryScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const ThemedIcon(Symbols.history),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutHistoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    GoalCard(title: 'Current Goal'),
                    StreamBuilder<List<Workout>>(
                      stream: firestoreService.currentUserId != null
                          ? firestoreService.workoutsAfterDateStream(
                              DateTime.now().subtract(const Duration(days: 1)))
                          : const Stream.empty(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No workouts planned');
                        } else {
                          // Group workouts by date
                          final workouts = snapshot.data!;
                          final Map<String, List<Workout>> groupedWorkouts = {};
                          for (var workout in workouts) {
                            final dateTitle = _getDailyCardTitle(workout.date);
                            if (!groupedWorkouts.containsKey(dateTitle)) {
                              groupedWorkouts[dateTitle] = [];
                            }
                            groupedWorkouts[dateTitle]!.add(workout);
                          }

                          return Column(
                            children: groupedWorkouts.entries.map((entry) {
                              final dateTitle = entry.key;
                              final groupWorkouts = entry.value;
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 8.0),
                                    child: Text(
                                      dateTitle,
                                      style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ...groupWorkouts.map((workout) => DailyCard(
                                        title: dateTitle,
                                        showDateTitle: false,
                                        firestoreService: firestoreService,
                                        workout: workout,
                                        exerciseList: exerciseList,
                                        active: (dateTitle == "Today"),
                                      )),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton:
          AddSheet(firestoreService: firestoreService, fabKey: _fabKey),
    );
  }
}
