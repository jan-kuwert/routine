import 'package:cloud_firestore/cloud_firestore.dart';

class Birthday {
  final String id;
  final String name;
  final DateTime date;
  final bool isSynced; // Whether this birthday was synced from contacts
  final bool isHidden; // Whether this birthday is hidden

  Birthday({
    required this.id,
    required this.name,
    required this.date,
    this.isSynced = false,
    this.isHidden = false,
  });

  factory Birthday.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Birthday(
      id: snapshot.id,
      name: data['name'],
      date: (data['date'] as Timestamp).toDate(),
      isSynced: data['isSynced'] ?? false,
      isHidden: data['isHidden'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'isSynced': isSynced,
      'isHidden': isHidden,
    };
  }

  Birthday copyWith({
    String? id,
    String? name,
    DateTime? date,
    bool? isSynced,
    bool? isHidden,
  }) {
    return Birthday(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
