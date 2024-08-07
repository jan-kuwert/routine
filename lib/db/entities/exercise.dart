import 'package:isar/isar.dart';

import 'daily_workout.dart';

part 'exercise.g.dart';

enum ExerciseType {
  count,
  time,
}

@Collection()
class Exercise {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late ExerciseType type;

  @Backlink(to: "exercises")
  final dailyWorkouts = IsarLinks<DailyWorkout>();
}
