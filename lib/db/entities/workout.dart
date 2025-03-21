import 'package:isar/isar.dart';

part 'workout.g.dart';

@Collection()
class Workout {
  Id id = Isar.autoIncrement;

  late DateTime date;

  late double totalProgress = 0;

  final List<ExerciseEntry> exercises;

  Workout({
    required this.date,
    required this.exercises,
  });
}

@Embedded()
class ExerciseEntry {
  late String exerciseName;
  late double counter = 0;
  late double target;
  late DateTime created = DateTime.now();
  late DateTime updated = DateTime.now();
}
