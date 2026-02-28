import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'task_api_service.dart';
import 'auth_api_service.dart';

class TaskService {
  static const String _localTasksKey = 'local_tasks_data';
  static const String _cloudTasksKey = 'cloud_tasks_data';

  final TaskApiService _taskApiService = TaskApiService();
  final AuthApiService _authApiService = AuthApiService();

  // Determine which storage to use
  Future<bool> _isLoggedIn() async {
    return await _authApiService.isLoggedIn();
  }

  String get _tasksKey => _localTasksKey;

  Future<List<Task>> loadTasks() async {
    final isLoggedIn = await _isLoggedIn();

    if (isLoggedIn) {
      // Load from API
      try {
        return await _taskApiService.getTasks();
      } catch (e) {
        print('Failed to load tasks from API: $e');
        // Fallback to local storage
        return await _loadFromLocal();
      }
    } else {
      // Load from local storage
      return await _loadFromLocal();
    }
  }

  Future<List<Task>> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null) return [];

    final List<dynamic> decoded = jsonDecode(tasksJson);
    return decoded.map((e) => Task.fromJson(e)).toList();
  }

  Future<void> saveTask(Task task) async {
    final isLoggedIn = await _isLoggedIn();

    if (isLoggedIn) {
      // Save to API
      try {
        await _taskApiService.createTask(task);
      } catch (e) {
        print('Failed to save task to API: $e');
        // Fallback to local storage
        await _saveToLocal(task);
      }
    } else {
      // Save to local storage
      await _saveToLocal(task);
    }
  }

  Future<void> _saveToLocal(Task task) async {
    final tasks = await _loadFromLocal();
    tasks.add(task);
    await _saveListToLocal(tasks);
  }

  Future<void> updateTask(Task task) async {
    final isLoggedIn = await _isLoggedIn();

    if (isLoggedIn) {
      // Update via API
      try {
        await _taskApiService.updateTask(task.id, task);
      } catch (e) {
        print('Failed to update task via API: $e');
        // Fallback to local storage
        await _updateInLocal(task);
      }
    } else {
      // Update in local storage
      await _updateInLocal(task);
    }
  }

  Future<void> _updateInLocal(Task task) async {
    final tasks = await _loadFromLocal();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveListToLocal(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    final isLoggedIn = await _isLoggedIn();

    if (isLoggedIn) {
      // Delete via API
      try {
        await _taskApiService.deleteTask(id);
      } catch (e) {
        print('Failed to delete task via API: $e');
        // Fallback to local storage
        await _deleteFromLocal(id);
      }
    } else {
      // Delete from local storage
      await _deleteFromLocal(id);
    }
  }

  Future<void> _deleteFromLocal(String id) async {
    final tasks = await _loadFromLocal();
    tasks.removeWhere((t) => t.id == id);
    await _saveListToLocal(tasks);
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final isLoggedIn = await _isLoggedIn();

    if (isLoggedIn) {
      // Toggle via API
      try {
        await _taskApiService.toggleTaskCompletion(task);
      } catch (e) {
        print('Failed to toggle task completion via API: $e');
        // Fallback to local storage
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        await _updateInLocal(updatedTask);
      }
    } else {
      // Toggle in local storage
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _updateInLocal(updatedTask);
    }
  }

  Future<void> _saveListToLocal(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, encoded);
  }
}
