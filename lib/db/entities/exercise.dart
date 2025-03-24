import 'package:isar/isar.dart';

part 'exercise.g.dart';

enum ExerciseType {
  repetitions,
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

  late List<int> increments;

  @enumerated
  late ExerciseCategory category;

  @enumerated
  late ExerciseType type;

  Exercise({
    required this.name,
    required this.category,
    this.type = ExerciseType.repetitions,
    this.increments = const [],
  });
}
