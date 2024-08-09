import 'package:isar/isar.dart';

import 'daily_workout.dart';

part 'exercise.g.dart';

enum ExerciseType {
  count,
  time,
}

enum ExerciseCategory { upperBody, lowerBody, core, fullBody, other }

@Collection()
class Exercise {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late ExerciseCategory category;

  @enumerated
  late ExerciseType type;

  @Backlink(to: "exercises")
  final dailyWorkouts = IsarLinks<DailyWorkout>();
}
