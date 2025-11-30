import 'package:cloud_firestore/cloud_firestore.dart';

class Subtask {
  String title;
  bool isCompleted;

  Subtask({
    required this.title,
    this.isCompleted = false,
  });

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

class Todo {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final List<Subtask> subtasks;
  final int order;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? listId;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.subtasks = const [],
    required this.order,
    DateTime? createdAt,
    this.completedAt,
    this.listId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Todo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Todo(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] ?? false,
      subtasks: (data['subtasks'] as List<dynamic>?)
              ?.map((e) => Subtask.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      listId: data['listId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'listId': listId,
    };
  }

  Todo copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    List<Subtask>? subtasks,
    int? order,
    DateTime? completedAt,
    String? listId,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      order: order ?? this.order,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      listId: listId ?? this.listId,
    );
  }
}
