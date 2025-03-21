import 'package:isar/isar.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/workout.dart';

part 'workout_entry.g.dart';

@Collection()
class WorkoutEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late int counter = 0;
  late int goal = 0;
  late DateTime created = DateTime.now();
  late DateTime updated = DateTime.now();

  final workout = IsarLinks<Workout>();

  final exercise = IsarLink<Exercise>();
}
