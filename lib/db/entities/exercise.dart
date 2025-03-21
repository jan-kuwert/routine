import 'package:isar/isar.dart';

import 'workout.dart';

part 'exercise.g.dart';

enum ExerciseType {
  repititons,
  duration,
}

enum ExerciseCategory {
  chest,
  back,
  arms,
  legs,
  core,
  fullBody,
  stretch,
  other
}

@Collection()
class Exercise {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late ExerciseCategory category;

  @enumerated
  late ExerciseType type;

  @Backlink(to: "exercises")
  final dailyWorkouts = IsarLinks<Workout>();
}
