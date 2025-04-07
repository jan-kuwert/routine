import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:routine/db/firebase/exercise.dart';
import 'package:routine/db/firebase/goal.dart';
import 'package:routine/db/firebase/workout.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ---------------------          ---------------------
  // ---------------------   User   ---------------------
  // ---------------------          ---------------------
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get a reference to a user's document
  DocumentReference getUserDocument() {
    if (currentUserId == null) {
      throw Exception('No authenticated user found');
    }
    return _firestore.collection('users').doc(currentUserId);
  }

  // Example: Create or update user profile
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await getUserDocument().set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Example: Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final snapshot = await getUserDocument().get();
    return snapshot.data() as Map<String, dynamic>?;
  }
  // ---------------------              ---------------------
  // ---------------------   Exercises   ---------------------
  // ---------------------              ---------------------

// Add an exercise to the user's exercises collection
  Future<DocumentReference> addExercise(Exercise exercise) async {
    return await getUserDocument().collection('exercises').add({
      ...exercise.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Exercise?> getExerciseByName(String name) async {
    final querySnapshot = await getUserDocument()
        .collection('exercises')
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Exercise.fromFirestore(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  // Get all exercises
  Future<List<Exercise>> getAllExercises() async {
    final querySnapshot = await getUserDocument()
        .collection('exercises')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Exercise.fromFirestore(doc))
        .toList();
  }

  // ---------------------              ---------------------
  // ---------------------   Workouts   ---------------------
  // ---------------------              ---------------------

  // Add a workout to the user's workouts collection
  Future<DocumentReference> addWorkout(Workout workout) async {
    return await getUserDocument().collection('workouts').add({
      ...workout.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateWorkoutCounter(
      String workoutId, String exerciseName, double value) async {
    final workoutDoc =
        await getUserDocument().collection('workouts').doc(workoutId).get();

    if (!workoutDoc.exists) {
      throw ArgumentError('Workout not found');
    }

    final workout = Workout.fromFirestore(workoutDoc);
    final exercises = List<Map<String, dynamic>>.from(
        workout.exercises.map((e) => e.toMap()));

    final exerciseIndex =
        exercises.indexWhere((e) => e['exerciseName'] == exerciseName);
    if (exerciseIndex == -1) {
      throw ArgumentError('Exercise not found in workout');
    }

    exercises[exerciseIndex]['counter'] = value;

    await getUserDocument().collection('workouts').doc(workoutId).update(
        {'exercises': exercises, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // Get workouts after a specific date
  Future<List<Workout>> getWorkoutsAfterDate(Timestamp timestamp) async {
    final querySnapshot = await getUserDocument()
        .collection('workouts')
        .where('timestamp', isGreaterThan: timestamp)
        .orderBy('timestamp', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => Workout.fromFirestore(
              doc,
            ))
        .toList();
  }

// Get workouts before a specific date
  Future<List<Workout>> getWorkoutsBeforeDate(Timestamp timestamp) async {
    final querySnapshot = await getUserDocument()
        .collection('workouts')
        .where('timestamp', isLessThan: timestamp)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }
  // ---------------------           ---------------------
  // ---------------------   Goals   ---------------------
  // ---------------------           ---------------------

  // Add a goal to the user's goals collection
  Future<DocumentReference> addGoal(Goal goal) async {
    return await getUserDocument().collection('goals').add({
      ...goal.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all goals
  Future<List<Goal>> getAllGoals() async {
    final querySnapshot = await getUserDocument()
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => Goal.fromFirestore(doc)).toList();
  }
}
