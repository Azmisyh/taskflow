import '../models/task.dart';
import '../models/category.dart';
import 'mock_api_service.dart';

class TaskService {
  final MockApiService _apiService = MockApiService();

  Future<List<Task>> getTasks(String userId) async {
    return await _apiService.getTasks(userId);
  }

  Future<Task?> getTaskById(String taskId, String userId) async {
    return await _apiService.getTaskById(taskId, userId);
  }

  Future<List<Task>> getTasksByStatus(String userId, bool? isCompleted) async {
    final tasks = await getTasks(userId);
    if (isCompleted == null) {
      return tasks;
    }
    return tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  Future<Task> createTask({
    required String userId,
    required String title,
    required String description,
    required String categoryId,
    DateTime? deadline,
  }) async {
    return await _apiService.createTask(
      userId: userId,
      title: title,
      description: description,
      categoryId: categoryId,
      deadline: deadline,
    );
  }

  Future<Task> updateTask({
    required String taskId,
    required String userId,
    String? title,
    String? description,
    String? categoryId,
    bool? isCompleted,
    DateTime? deadline,
  }) async {
    return await _apiService.updateTask(
      taskId: taskId,
      userId: userId,
      title: title,
      description: description,
      categoryId: categoryId,
      isCompleted: isCompleted,
      deadline: deadline,
    );
  }

  Future<void> deleteTask(String taskId, String userId) async {
    await _apiService.deleteTask(taskId, userId);
  }

  Future<void> toggleTaskStatus(String taskId, String userId) async {
    await _apiService.toggleTaskStatus(taskId, userId);
  }

  Future<List<Category>> getCategories() async {
    return await _apiService.getCategories();
  }
}
