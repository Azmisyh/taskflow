import '../models/task.dart';
import '../models/category.dart';

class MockApiService {
  // Base URL untuk Mock API (gunakan JSONPlaceholder atau buat mock server sendiri)
  // Untuk demo, kita akan menggunakan in-memory mock data
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // In-memory storage untuk simulasi
  static final List<Task> _tasks = [];
  static final List<Category> _categories = [
    Category(id: '1', name: 'Work', color: '#FF5722'),
    Category(id: '2', name: 'Personal', color: '#2196F3'),
    Category(id: '3', name: 'Shopping', color: '#4CAF50'),
    Category(id: '4', name: 'Health', color: '#9C27B0'),
    Category(id: '5', name: 'Education', color: '#FF9800'),
  ];

  // Simulasi delay network
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Category Methods
  Future<List<Category>> getCategories() async {
    await _delay();
    return List.from(_categories);
  }

  // Task Methods
  Future<List<Task>> getTasks(String userId) async {
    await _delay();
    return _tasks.where((task) => task.userId == userId).toList();
  }

  Future<Task?> getTaskById(String taskId, String userId) async {
    await _delay();
    try {
      return _tasks.firstWhere(
        (task) => task.id == taskId && task.userId == userId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<Task> createTask({
    required String userId,
    required String title,
    required String description,
    required String categoryId,
    DateTime? deadline,
  }) async {
    await _delay();

    final category = _categories.firstWhere((cat) => cat.id == categoryId);
    final now = DateTime.now();

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      categoryId: categoryId,
      categoryName: category.name,
      isCompleted: false,
      deadline: deadline,
      createdAt: now,
      updatedAt: now,
      userId: userId,
    );

    _tasks.add(newTask);
    return newTask;
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
    await _delay();

    final taskIndex = _tasks.indexWhere(
      (task) => task.id == taskId && task.userId == userId,
    );

    if (taskIndex == -1) {
      throw Exception('Task not found');
    }

    final existingTask = _tasks[taskIndex];
    Category? category;
    String? categoryName;

    if (categoryId != null) {
      category = _categories.firstWhere((cat) => cat.id == categoryId);
      categoryName = category.name;
    }

    final updatedTask = existingTask.copyWith(
      title: title,
      description: description,
      categoryId: categoryId ?? existingTask.categoryId,
      categoryName: categoryName ?? existingTask.categoryName,
      isCompleted: isCompleted,
      deadline: deadline,
      updatedAt: DateTime.now(),
    );

    _tasks[taskIndex] = updatedTask;
    return updatedTask;
  }

  Future<void> deleteTask(String taskId, String userId) async {
    await _delay();
    _tasks.removeWhere((task) => task.id == taskId && task.userId == userId);
  }

  Future<void> toggleTaskStatus(String taskId, String userId) async {
    await _delay();
    final taskIndex = _tasks.indexWhere(
      (task) => task.id == taskId && task.userId == userId,
    );

    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      _tasks[taskIndex] = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
    }
  }
}
