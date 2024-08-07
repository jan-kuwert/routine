import 'package:isar/isar.dart';

import 'exercise.dart';

part 'goal.g.dart';

@Collection()
class Goal {
  Id id = Isar.autoIncrement;

  late String title;

  late DateTime start;

  late DateTime end;

  final exercises = IsarLinks<Exercise>();
}
