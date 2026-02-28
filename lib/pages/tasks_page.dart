import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskService.loadTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask(String title, String priority, String time) async {
    // Parse priority string to Priority enum
    Priority priorityEnum = Priority.medium;
    if (priority.contains('高') || priority.toLowerCase() == 'high') {
      priorityEnum = Priority.high;
    } else if (priority.contains('低') || priority.toLowerCase() == 'low') {
      priorityEnum = Priority.low;
    }

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      priority: priorityEnum,
      timeRange: time,
    );
    await _taskService.saveTask(newTask);
    _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    await _taskService.deleteTask(id);
    _loadTasks();
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final priorityController = TextEditingController(text: '中优先级');
    final timeController = TextEditingController(text: '09:00 - 10:00');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增任务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '任务名称'),
            ),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(labelText: '优先级'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: '时间段'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addTask(
                  titleController.text,
                  priorityController.text,
                  timeController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务列表'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('暂无任务，快去添加吧！'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (_, index) {
                    final t = _tasks[index];
                    return Dismissible(
                      key: Key(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteTask(t.id),
                      child: ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(t.timeRange ?? ''),
                        trailing: Chip(
                          label: Text(t.priority.displayName, style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFFEFF6FF),
                          labelStyle: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: _tasks.length,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add),
      ),
    );
  }
}