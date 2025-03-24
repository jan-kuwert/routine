import 'package:isar/isar.dart';

part 'goal.g.dart';

enum GoalType {
  sport,
  other,
}

@Collection()
class Goal {
  Id id = Isar.autoIncrement;

  late String title;

  late DateTime start;

  late DateTime end;

  late double progress = 0;

  late bool pinned = false;

  @enumerated
  late GoalType type;

  late List<ExerciseTarget> targets;

  Goal({
    required this.title,
    required this.start,
    required this.end,
    required this.type,
    this.targets = const [],
  });
}

@Embedded()
class ExerciseTarget {
  late String exercise;
  late double target;
}
