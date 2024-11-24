import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final String userId;
  final double position;
  final TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
    required this.position,
    this.priority = TaskPriority.medium,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'position': position,
      'priority': priority.name,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    try {
      return Task(
        id: map['id'] as String,
        title: map['title'] as String,
        isCompleted: map['isCompleted'] as bool,
        createdAt: DateTime.parse(map['createdAt'] as String),
        userId: map['userId'] as String,
        position: (map['position'] as num).toDouble(),
        priority: map['priority'] != null
            ? TaskPriority.values.firstWhere(
                (e) => e.name == map['priority'],
                orElse: () => TaskPriority.medium,
              )
            : TaskPriority.medium,
      );
    } catch (e) {
      throw Exception('Error creating Task from map: $e');
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}
