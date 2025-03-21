import 'package:isar/isar.dart';
import 'package:routine/db/entities/workout_entry.dart';

import 'exercise.dart';

part 'workout.g.dart';

@Collection()
class Workout {
  Id id = Isar.autoIncrement;

  late DateTime date = DateTime.now();

  late double totalProgress = 0;

  var exercises = IsarLinks<Exercise>();

  final workoutEntry = IsarLinks<WorkoutEntry>();
}
