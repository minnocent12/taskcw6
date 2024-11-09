import 'package:cloud_firestore/cloud_firestore.dart';

class SubTask {
  String? id; // Add the id field
  String timeFrame;
  String details;

  SubTask({
    this.id, // Make id optional, as it will be set after Firestore operation
    required this.timeFrame,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'timeFrame': timeFrame,
      'details': details,
    };
  }

  static SubTask fromMap(Map<String, dynamic> map, String id) {
    return SubTask(
      id: id, // Capture the id from Firestore
      timeFrame: map['timeFrame'] ?? '',
      details: map['details'] ?? '',
    );
  }
}

class Task {
  String id;
  String name;
  bool isCompleted;
  String priority;
  DateTime dueDate;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.priority = 'Medium',
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      name: map['name'],
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 'Medium',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
    );
  }
}
