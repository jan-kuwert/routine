import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String id;
  final DateTime date;
  final double totalProgress;
  final List<ExerciseEntry> exercises;

  Workout({
    required this.id,
    required this.date,
    this.totalProgress = 0,
    required this.exercises,
  });

  factory Workout.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Workout(
      id: snapshot.id,
      date: (data['timestamp'] as Timestamp).toDate(),
      totalProgress: (data['totalProgress'] as num).toDouble(),
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(date),
      'totalProgress': totalProgress,
      'exercises': exercises.map((entry) => entry.toMap()).toList(),
    };
  }
}

class ExerciseEntry {
  final String exerciseName;
  final double counter;
  final double target;
  final DateTime created;
  final DateTime updated;

  ExerciseEntry({
    required this.exerciseName,
    this.counter = 0,
    required this.target,
    DateTime? created,
    DateTime? updated,
  })  : created = created ?? DateTime.now(),
        updated = updated ?? DateTime.now();

  factory ExerciseEntry.fromMap(Map<String, dynamic> map) {
    return ExerciseEntry(
      exerciseName: map['exerciseName'],
      counter: (map['counter'] as num).toDouble(),
      target: (map['target'] as num).toDouble(),
      created: (map['created'] as Timestamp).toDate(),
      updated: (map['updated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'counter': counter,
      'target': target,
      'created': Timestamp.fromDate(created),
      'updated': Timestamp.fromDate(updated),
    };
  }

  ExerciseEntry copyWith({
    String? exerciseName,
    double? counter,
    double? target,
    DateTime? created,
    DateTime? updated,
  }) {
    return ExerciseEntry(
      exerciseName: exerciseName ?? this.exerciseName,
      counter: counter ?? this.counter,
      target: target ?? this.target,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
