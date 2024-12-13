import 'package:flutter/material.dart';
import 'package:tasksync/models/task.dart';
import 'package:tasksync/services/task_service.dart';
import 'package:tasksync/services/auth_service.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskService taskService;
  final AuthService authService;

  const AddTaskDialog({
    super.key,
    required this.taskService,
    required this.authService,
  });

  @override
  AddTaskDialogState createState() => AddTaskDialogState();
}

class AddTaskDialogState extends State<AddTaskDialog> {
  final _taskController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _cancelAdd() {
    Navigator.pop(context);
    _taskController.clear();
    _priority = TaskPriority.medium;
  }

  Future<void> _addTask() async {
    if (_taskController.text.isNotEmpty) {
      try {
        await widget.taskService.addTask(
          _taskController.text,
          widget.authService.currentUser!.uid,
          _priority,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add task')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text(
        'Add New Task',
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Priority',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TaskPriority>(
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(0),
                  ),
                ),
                showSelectedIcon: false,
                segments: TaskPriority.values.map((priority) {
                  final isSelected = priority == _priority;
                  return ButtonSegment<TaskPriority>(
                    value: priority,
                    label: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? priority.color.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priority.label,
                        style: TextStyle(
                          color: isSelected
                              ? priority.color
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                selected: {_priority},
                onSelectionChanged: (Set<TaskPriority> selected) {
                  setState(() => _priority = selected.first);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _cancelAdd,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _addTask,
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
