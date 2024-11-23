import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasksync/models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('position')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    });
  }

  Future<void> addTask(String title, String userId) async {
    final QuerySnapshot querySnapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('position', descending: true)
        .limit(1)
        .get();

    double position = 0;
    if (querySnapshot.docs.isNotEmpty) {
      position = (querySnapshot.docs.first.data()
              as Map<String, dynamic>)['position'] +
          1;
    }

    await _firestore.collection('tasks').add({
      'title': title,
      'isCompleted': false,
      'createdAt': DateTime.now().toIso8601String(),
      'userId': userId,
      'position': position,
    });
  }

  Future<void> reorderTask(String taskId, double newPosition) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'position': newPosition,
    });
  }

  Future<void> reorderTasks(List<Task> tasks) async {
    final batch = _firestore.batch();

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final taskRef = _firestore.collection('tasks').doc(task.id);
      batch.update(taskRef, {'position': i.toDouble()});
    }

    await batch.commit();
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}
