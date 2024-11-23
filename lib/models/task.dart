class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final String userId;
  final double position;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'position': position,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    try {
      return Task(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        isCompleted: map['isCompleted'] ?? false,
        createdAt: DateTime.parse(map['createdAt'] as String),
        userId: map['userId'] ?? '',
        position: (map['position'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      print('Error creating Task from map: $e');
      rethrow;
    }
  }
}
