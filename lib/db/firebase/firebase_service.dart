import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:routine/db/entities/exercise.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Exercises
  Future<void> addExercise(Exercise exercise) {
    return _db.collection('exercises').add(exercise.toFirestore());
  }

  Stream<List<Exercise>> getExercises() {
    return _db.collection('exercises').orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Exercise.fromFirestore(doc, null))
            .toList());
  }

  // Workouts
  Future<void> addWorkout(Workout workout) {
    return _db.collection('workouts').add(workout.toFirestore());
  }

  Stream<List<Workout>> getWorkouts() {
    return _db
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromFirestore(doc, null))
            .toList());
  }
}
