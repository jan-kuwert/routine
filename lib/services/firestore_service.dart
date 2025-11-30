import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:routine/db/entities/exercise.dart';
import 'package:routine/db/entities/goal.dart';
import 'package:routine/db/entities/todo.dart';
import 'package:routine/db/entities/todo_list.dart';
import 'package:routine/db/entities/workout.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton pattern (optional, but IsarService was often used as instance)
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  String? get currentUserId => _auth.currentUser?.uid;

  DocumentReference _userDoc() {
    if (currentUserId == null) {
      throw Exception('No authenticated user found');
    }
    return _firestore.collection('users').doc(currentUserId);
  }

  // ----------------------------------------------------------------
  // Exercises
  // ----------------------------------------------------------------

  Future<void> addExercise(Exercise exercise) async {
    // Check for existing (case insensitive)
    final normalizedName = exercise.name.toLowerCase().trim();
    final existing = await _userDoc()
        .collection('exercises')
        .where('name_lowercase', isEqualTo: normalizedName)
        .get();

    if (existing.docs.isNotEmpty) {
      debugPrint('Exercise with name ${exercise.name} already exists');
      return;
    }

    await _userDoc().collection('exercises').add({
      ...exercise.toFirestore(),
      'name_lowercase': normalizedName, // Helper for querying
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Exercise>> getAllExercises() async {
    final snapshot = await _userDoc()
        .collection('exercises')
        .orderBy('category') // Sort by category to match Isar
        .get();
    return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
  }

  Stream<List<Exercise>> exerciseStream() {
    return _userDoc()
        .collection('exercises')
        .orderBy('category')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList());
  }

  Future<Exercise?> getExerciseByName(String name) async {
    // Try exact match first or lowercase match
    final snapshot = await _userDoc()
        .collection('exercises')
        .where('name_lowercase', isEqualTo: name.toLowerCase().trim())
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Exercise.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  // ----------------------------------------------------------------
  // Workouts
  // ----------------------------------------------------------------

  Future<void> deleteExercise(String exerciseId) async {
    await _userDoc().collection('exercises').doc(exerciseId).delete();
  }

  Future<void> addWorkout(Workout workout) async {
    final existingWorkout = await getWorkout(workout.date);
    
    if (existingWorkout != null) {
      throw 'A workout for this date already exists. Please edit the existing workout.';
    } else {
      await _userDoc().collection('workouts').add({
        ...workout.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    final existingWorkoutOnDate = await getWorkout(workout.date);
    if (existingWorkoutOnDate != null && existingWorkoutOnDate.id != workout.id) {
      throw 'A workout for this date already exists. Please merge manually if needed.';
    }
    
    await _userDoc().collection('workouts').doc(workout.id).update(workout.toFirestore());
  }

  Future<List<Workout>> getAllWorkouts() async {
    final snapshot = await _userDoc().collection('workouts').get();
    return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  Stream<List<Workout>> workoutStream() {
    return _userDoc()
        .collection('workouts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList());
  }

  Future<Workout?> getWorkout(DateTime date) async {
    // Precise date matching in Firestore is hard if stored as Timestamp.
    // We'll look for a range covering the whole day.
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _userDoc()
        .collection('workouts')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Workout.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Stream<List<Workout>> workoutsAfterDateStream(DateTime date) {
    return _userDoc()
        .collection('workouts')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(date))
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList());
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _userDoc().collection('workouts').doc(workoutId).delete();
  }
  
  Future<List<Workout>> getWorkoutsAfterDate(DateTime date) async {
    final snapshot = await _userDoc()
        .collection('workouts')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(date))
        .get();
    return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  Future<List<Workout>> getWorkoutsBeforeDate(DateTime date) async {
    final snapshot = await _userDoc()
        .collection('workouts')
        .where('timestamp', isLessThan: Timestamp.fromDate(date))
        .get();
    return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  Future<void> updateWorkoutCounter(
      String workoutId, String exerciseName, double value) async {
    final workoutRef = _userDoc().collection('workouts').doc(workoutId);
    final snapshot = await workoutRef.get();

    if (!snapshot.exists) {
      throw ArgumentError('Workout not found');
    }

    final workoutData = snapshot.data()!;
    final exercises = List<Map<String, dynamic>>.from(
        workoutData['exercises'] as List<dynamic>);

    final index =
        exercises.indexWhere((e) => e['exerciseName'] == exerciseName);
    if (index != -1) {
      exercises[index]['counter'] = value;
      exercises[index]['updated'] = Timestamp.now(); // Update timestamp
      await workoutRef.update({'exercises': exercises});
    }
  }

  Future<void> addExerciseEntry(Workout workout, ExerciseEntry entry) async {
    await addExerciseEntries(workout, [entry]);
  }

  Future<void> addExerciseEntries(
      Workout workout, List<ExerciseEntry> entries) async {
    final workoutRef = _userDoc().collection('workouts').doc(workout.id);
    
    // We need to use FieldValue.arrayUnion but that only works if we have the exact map.
    // Since we want to append, it's safer to read-modify-write or use arrayUnion with exact object.
    // Simpler:
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(workoutRef);
      if (!snapshot.exists) return;

      final currentExercises = List<Map<String, dynamic>>.from(
          snapshot.data()!['exercises'] as List<dynamic>);
      
      for (var entry in entries) {
        currentExercises.add(entry.toMap());
      }

      transaction.update(workoutRef, {'exercises': currentExercises});
    });
  }

  // ----------------------------------------------------------------
  // Goals
  // ----------------------------------------------------------------

  Future<void> addGoal(Goal goal) async {
    await _userDoc().collection('goals').add({
      ...goal.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGoal(Goal goal) async {
    await _userDoc().collection('goals').doc(goal.id).update(goal.toFirestore());
  }

  Future<List<Goal>> getAllGoals() async {
    final snapshot = await _userDoc()
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Goal.fromFirestore(doc)).toList();
  }

  // ----------------------------------------------------------------
  // Todo Lists
  // ----------------------------------------------------------------

  Future<void> addTodoList(TodoList list) async {
    await _userDoc().collection('todo_lists').add({
      ...list.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTodoList(TodoList list) async {
    await _userDoc()
        .collection('todo_lists')
        .doc(list.id)
        .update(list.toFirestore());
  }

  Future<void> deleteTodoList(String listId) async {
    await _userDoc().collection('todo_lists').doc(listId).delete();

    // Delete todos in this list
    final todos = await _userDoc()
        .collection('todos')
        .where('listId', isEqualTo: listId)
        .get();
    for (var doc in todos.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<TodoList>> getTodoListsStream() {
    return _userDoc()
        .collection('todo_lists')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TodoList.fromFirestore(doc)).toList());
  }

  // ----------------------------------------------------------------
  // Todos
  // ----------------------------------------------------------------

  Future<void> addTodo(Todo todo) async {
    await _userDoc().collection('todos').add({
      ...todo.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTodo(Todo todo) async {
    await _userDoc()
        .collection('todos')
        .doc(todo.id)
        .update(todo.toFirestore());
  }

  Future<void> deleteTodo(String todoId) async {
    await _userDoc().collection('todos').doc(todoId).delete();
  }

  Stream<List<Todo>> getTodosStream({String? listId, bool filterByList = false}) {
    Query query =
        _userDoc().collection('todos').where('isCompleted', isEqualTo: false);

    if (filterByList) {
      if (listId == null) {
        query = query.where('listId', isNull: true);
      } else {
        query = query.where('listId', isEqualTo: listId);
      }
    }

    return query
        .orderBy('order')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Todo.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }

  Stream<List<Todo>> getCompletedTodosStream({String? listId, bool filterByList = false}) {
    Query query =
        _userDoc().collection('todos').where('isCompleted', isEqualTo: true);

    if (filterByList) {
      if (listId == null) {
        query = query.where('listId', isNull: true);
      } else {
        query = query.where('listId', isEqualTo: listId);
      }
    }

    return query
        .orderBy('completedAt', descending: true)
        .limit(50) // Limit history for performance
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Todo.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }

  Future<void> reorderTodos(List<Todo> todos) async {
    final batch = _firestore.batch();
    for (int i = 0; i < todos.length; i++) {
      final todoRef = _userDoc().collection('todos').doc(todos[i].id);
      batch.update(todoRef, {'order': i});
    }
    await batch.commit();
  }

  // ----------------------------------------------------------------
  // Maintenance
  // ----------------------------------------------------------------
  
  Future<void> cleanDb() async {
    // DANGEROUS: Only for dev/test
    // Deleting subcollections is not automatic in Firestore. 
    // You have to delete documents one by one.
    // Implementation skipped for safety/complexity, usually not needed in production.
  }
}
