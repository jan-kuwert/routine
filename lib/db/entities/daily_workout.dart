import 'package:isar/isar.dart';

import 'exercise.dart';

part 'daily_workout.g.dart';

@Collection()
class DailyWorkout {
  Id id = Isar.autoIncrement;

  late DateTime date = DateTime.now();

  final exercises = IsarLinks<Exercise>();

  late double progress = 0;
}
