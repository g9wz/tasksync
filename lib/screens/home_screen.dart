import 'package:flutter/material.dart';
import 'package:tasksync/services/auth_service.dart';
import 'package:tasksync/services/task_service.dart';
import 'package:tasksync/models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskService = TaskService();
  final _authService = AuthService();
  final _taskController = TextEditingController();

  Future<void> _addTask() async {
    if (_taskController.text.isNotEmpty) {
      await _taskService.addTask(
          _taskController.text, _authService.currentUser!.uid);
      _taskController.clear();
    }
  }

  void _cancelAdd() {
    _taskController.clear();
  }

  Future<void> _showAddTaskDialog() async {
    _taskController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              hintText: 'Enter task description',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            autofocus: true,
            maxLines: 2,
            minLines: 1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _cancelAdd,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addTask();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final tasks =
        (await _taskService.getTasks(_authService.currentUser!.uid).first)
            .toList();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Task item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);

    await _taskService.reorderTasks(tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskSync'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkResponse(
              onTap: _authService.signOut,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.logout,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _taskService.getTasks(_authService.currentUser!.uid),
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
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final task = snapshot.data![index];
              return KeyedSubtree(
                key: Key(task.id),
                child: Dismissible(
                  key: Key(task.id),
                  onDismissed: (_) => _taskService.deleteTask(task.id),
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
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => _taskService.toggleTaskStatus(
                          task.id,
                          task.isCompleted,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
