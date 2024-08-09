import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routine/db/entities/daily_workout.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/goal.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> addExercise(Exercise exercise) async {
    final isar = await db;
    await isar.writeTxn(() => isar.exercises.put(exercise));
  }

  Future<void> addGoal(Goal goal) async {
    final isar = await db;
    await isar.writeTxn(() => isar.goals.put(goal));
  }

  Future<void> addDailyWorkout(DailyWorkout dailyWorkout) async {
    final isar = await db;
    await isar.writeTxn(() => isar.dailyWorkouts.put(dailyWorkout));
  }

  Future<DailyWorkout?> getDailyWorkout(DateTime date) async {
    final isar = await db;
    return isar.dailyWorkouts.where().filter().dateEqualTo(date).findFirst();
  }

  Future<List<Goal>> getAllGoals() async {
    final isar = await db;
    return isar.goals.where().findAll();
  }

  Future<List<Exercise>> getAllExercises() async {
    final isar = await db;
    return isar.exercises.where().findAll();
  }

  Future<List<DailyWorkout>> getAllDailyWorkouts() async {
    final isar = await db;
    return isar.dailyWorkouts.where().findAll();
  }

  Stream<List<Exercise>> exerciseStream() async* {
    final isar = await db;
    yield* isar.exercises.where().watch(fireImmediately: true);
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [ExerciseSchema, GoalSchema, DailyWorkoutSchema],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> close() async {
    final isar = await db;
    await isar.close();
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
