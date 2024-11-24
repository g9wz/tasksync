import 'package:flutter/material.dart';
import 'package:tasksync/screens/home/parts/tasks/dialogs/add_task_dialog.dart';
import 'package:tasksync/screens/home/parts/tasks/tasks_screen.dart';
import 'package:tasksync/screens/home/parts/profile/profile_screen.dart';
import 'package:tasksync/services/auth_service.dart';
import 'package:tasksync/services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskService = TaskService();
  final _authService = AuthService();
  int _selectedIndex = 0;

  Future<void> _showAddTaskDialog() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    }

    await showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        taskService: _taskService,
        authService: _authService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Tasks' : 'Profile'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TasksScreen(
            taskService: _taskService,
            userId: _authService.currentUser!.uid,
            onAddTask: _showAddTaskDialog,
          ),
          ProfileScreen(
            authService: _authService,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 90,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(0, Icons.format_list_bulleted, 'Tasks'),
            _buildNavBarItem(1, Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.only(
        left: index == 0 ? 0 : 48.0,
        right: index == 1 ? 0 : 48.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            color: _selectedIndex == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
            onPressed: () => setState(() => _selectedIndex = index),
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
