import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String id;
  final Timestamp date;
  final double totalProgress;
  final List<ExerciseEntry> exercises;

  Workout({
    required this.id,
    required this.date,
    this.totalProgress = 0,
    required this.exercises,
  });

  factory Workout.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Workout(
      id: snapshot.id,
      date: data['date'] as Timestamp,
      totalProgress: (data['totalProgress'] as num).toDouble(),
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'totalProgress': totalProgress,
      'exercises': exercises.map((entry) => entry.toMap()).toList(),
    };
  }
}

class ExerciseEntry {
  final String exerciseName;
  final double counter;
  final double target;
  final Timestamp created;
  final Timestamp updated;

  ExerciseEntry({
    required this.exerciseName,
    this.counter = 0,
    required this.target,
    Timestamp? created,
    Timestamp? updated,
  })  : created = created ?? Timestamp.now(),
        updated = updated ?? Timestamp.now();

  factory ExerciseEntry.fromMap(Map<String, dynamic> map) {
    return ExerciseEntry(
      exerciseName: map['exerciseName'],
      counter: (map['counter'] as num).toDouble(),
      target: (map['target'] as num).toDouble(),
      created: map['created'] as Timestamp,
      updated: map['updated'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'counter': counter,
      'target': target,
      'created': created,
      'updated': updated,
    };
  }
}
