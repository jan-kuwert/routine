import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/goal.dart';
import 'package:routine/db/entities/workout.dart';
import 'package:routine/db/entities/workout_entry.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> addExercise(Exercise exercise) async {
    final isar = await db;
    // Convert exercise name to lowercase for consistency
    exercise.name = exercise.name.toLowerCase().trim();

    // Check if an exercise with the same name already exists
    final existingExercise =
        await isar.exercises.filter().nameEqualTo(exercise.name).findFirst();

    // If an exercise with the same name exists, return without adding
    if (existingExercise != null) {
      return debugPrint('Exercise with name ${exercise.name} already exists');
    }
    await isar.writeTxn(() => isar.exercises.put(exercise));
  }

  Future<void> addGoal(Goal goal) async {
    final isar = await db;
    await isar.writeTxn(() => isar.goals.put(goal));
  }

  Future<void> addWorkout(Workout workout) async {
    final isar = await db;
    await isar.writeTxn(() => isar.workouts.put(workout));
  }

  Future<Workout?> getWorkout(DateTime date) async {
    final isar = await db;
    return isar.workouts.where().filter().dateEqualTo(date).findFirst();
  }

  Future<List<Goal>> getAllGoals() async {
    final isar = await db;
    return isar.goals.where().findAll();
  }

  Future<List<Exercise>> getAllExercises() async {
    final isar = await db;
    return isar.exercises.where().sortByCategory().findAll();
  }

  Future<List<Workout>> getAllWorkouts() async {
    final isar = await db;
    return isar.workouts.where().findAll();
  }

  Stream<List<Exercise>> exerciseStream() async* {
    final isar = await db;
    yield* isar.exercises.where().watch(fireImmediately: true);
  }

  Future<void> addWorkoutEntry(WorkoutEntry entry) async {
    final isar = await db;
    await isar.writeTxn(() => isar.workoutEntrys.put(entry));
  }

  Future<List<WorkoutEntry>> getEntriesForExercise(Exercise exercise) async {
    final isar = await db;
    return isar.workoutEntrys.filter().exercise((q) {
      return q.idEqualTo(exercise.id);
    }).findAll();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return Isar.open(
        [
          ExerciseSchema,
          GoalSchema,
          WorkoutSchema,
          WorkoutEntrySchema
        ],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> close() async {
    final isar = await db;
    isar.close();
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
