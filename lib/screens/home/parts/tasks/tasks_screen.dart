import 'package:flutter/material.dart';
import 'package:tasksync/services/task_service.dart';
import 'package:tasksync/models/task.dart';

class TasksScreen extends StatefulWidget {
  final TaskService taskService;
  final String userId;
  final VoidCallback onAddTask;

  const TasksScreen({
    super.key,
    required this.taskService,
    required this.userId,
    required this.onAddTask,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _taskController = TextEditingController();

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final tasks =
        (await widget.taskService.getTasks(widget.userId).first).toList();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Task item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);

    await widget.taskService.reorderTasks(tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Task>>(
        stream: widget.taskService.getTasks(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first task',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final task = snapshot.data![index];
              return KeyedSubtree(
                key: Key(task.id),
                child: Dismissible(
                  key: Key(task.id),
                  onDismissed: (_) {
                    final deletedTask = task;
                    widget.taskService.deleteTask(task.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            widget.taskService.addTask(
                              deletedTask.title,
                              deletedTask.userId,
                            );
                          },
                        ),
                      ),
                    );
                  },
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
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
                          onChanged: (_) => widget.taskService.toggleTaskStatus(
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
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
