import 'package:flutter/foundation.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskProviderStatus { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this._repository});

  final TaskRepository _repository;

  final List<Task> _tasks = [];
  TaskProviderStatus _status = TaskProviderStatus.initial;
  String? _errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _status == TaskProviderStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTasks() async {
    _status = TaskProviderStatus.loading;
    notifyListeners();
    try {
      _tasks
        ..clear()
        ..addAll(await _repository.loadTasks());
      _status = TaskProviderStatus.loaded;
    } catch (_) {
      _status = TaskProviderStatus.error;
      _errorMessage = 'Failed to load tasks.';
    }
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _repository.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _repository.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    await _repository.saveTasks(_tasks);
    notifyListeners();
  }
}
