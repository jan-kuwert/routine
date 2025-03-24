import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:routine/components/daily_card.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/db/isar_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final service = IsarService();

  Future<List<Workout>> _getWorkoutHistory() async {
    return service.getWorkoutsBeforeDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Workout>>(
          future: _getWorkoutHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No past workouts'));
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final workout = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: DailyCard(
                      title: DateFormat.yMMMMd().format(workout.date),
                      service: service,
                      workout: workout,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
