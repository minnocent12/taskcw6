import 'package:cloud_firestore/cloud_firestore.dart';

class SubTask {
  String timeFrame;
  String details;

  SubTask({
    required this.timeFrame,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'timeFrame': timeFrame,
      'details': details,
    };
  }

  static SubTask fromMap(Map<String, dynamic> map) {
    return SubTask(
      timeFrame: map['timeFrame'],
      details: map['details'],
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
