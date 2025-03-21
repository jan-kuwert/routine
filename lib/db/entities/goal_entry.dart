import 'package:isar/isar.dart';

import 'exercise.dart';

part 'goal_entry.g.dart';

@Collection()
class GoalEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date = DateTime.now();
  late int goal;

  // Link to the exercise
  final exercise = IsarLink<Exercise>();
}
