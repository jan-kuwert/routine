import 'package:cloud_firestore/cloud_firestore.dart';

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

class Exercise {
  final String id;
  final String name;
  final List<int> increments;
  final ExerciseCategory category;
  final ExerciseType type;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.type = ExerciseType.repetitions,
    this.increments = const [],
  });

  factory Exercise.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Exercise(
      id: snapshot.id,
      name: data['name'],
      category: ExerciseCategory.values.firstWhere(
          (e) => e.toString() == data['category'],
          orElse: () => ExerciseCategory.other),
      type: ExerciseType.values.firstWhere((e) => e.toString() == data['type'],
          orElse: () => ExerciseType.repetitions),
      increments: List<int>.from(data['increments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category.toString(),
      'type': type.toString(),
      'increments': increments,
    };
  }
}
