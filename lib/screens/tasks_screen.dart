import 'package:flutter/material.dart';
import 'package:tasksync/services/task_service.dart';
import 'package:tasksync/models/task.dart';

class TasksScreen extends StatelessWidget {
  final TaskService taskService;
  final String userId;
  final Function(int, int) onReorder;

  const TasksScreen({
    super.key,
    required this.taskService,
    required this.userId,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: taskService.getTasks(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No tasks yet. Add your first task!'),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final task = snapshot.data![index];
            return KeyedSubtree(
              key: Key(task.id),
              child: Dismissible(
                key: Key(task.id),
                onDismissed: (_) => taskService.deleteTask(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 28,
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: Transform.translate(
                      offset: const Offset(8, 0),
                      child: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => taskService.toggleTaskStatus(
                          task.id,
                          task.isCompleted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
