import '../models/task.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class TaskApiService {
  final ApiService _apiService = ApiService();

  // Get tasks with optional filters
  Future<List<Task>> getTasks({
    String? date,
    String? status,
    String? priority,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;

    final response = await _apiService.get(
      ApiConstants.tasks,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final tasksJson = data['tasks'] as List;
    return tasksJson.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Create a new task
  Future<Task> createTask(Task task) async {
    final response = await _apiService.post(
      ApiConstants.tasks,
      data: task.toJson(),
    );

    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  // Update an existing task
  Future<Task> updateTask(String id, Task task) async {
    final response = await _apiService.put(
      ApiConstants.taskById(id),
      data: task.toJson(),
    );

    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    await _apiService.delete(ApiConstants.taskById(id));
  }

  // Complete a task
  Future<Task> completeTask(String id, {int? actualMinutes}) async {
    final response = await _apiService.patch(
      ApiConstants.completeTask(id),
      data: {
        'is_completed': true,
        if (actualMinutes != null) 'actual_minutes': actualMinutes,
      },
    );

    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  // Toggle task completion
  Future<Task> toggleTaskCompletion(Task task) async {
    final response = await _apiService.patch(
      ApiConstants.completeTask(task.id),
      data: {
        'is_completed': !task.isCompleted,
        if (!task.isCompleted && task.actualMinutes != null)
          'actual_minutes': task.actualMinutes,
      },
    );

    return Task.fromJson(response.data as Map<String, dynamic>);
  }
}
