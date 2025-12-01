import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalType {
  total,
  daily,
}

class Goal {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final double progress;
  final bool pinned;
  final GoalType type;
  final List<ExerciseTarget> targets;

  Goal({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.progress = 0,
    this.pinned = false,
    required this.type,
    this.targets = const [],
  });

  factory Goal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Goal(
      id: snapshot.id,
      title: data['title'],
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
      progress: (data['progress'] as num).toDouble(),
      pinned: data['pinned'] ?? false,
      type: GoalType.values.firstWhere((e) => e.toString() == data['type'],
          orElse: () => GoalType.total),
      targets: (data['targets'] as List<dynamic>?)
              ?.map((e) => ExerciseTarget.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'progress': progress,
      'pinned': pinned,
      'type': type.toString(),
      'targets': targets.map((target) => target.toMap()).toList(),
    };
  }
}

class ExerciseTarget {
  final String exercise;
  final double target;

  ExerciseTarget({
    required this.exercise,
    this.target = 0,
  });

  factory ExerciseTarget.fromMap(Map<String, dynamic> map) {
    return ExerciseTarget(
      exercise: map['exercise'],
      target: (map['target'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exercise': exercise,
      'target': target,
    };
  }
}
