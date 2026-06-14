import 'package:flutter/foundation.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_filter.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskProviderStatus { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this._repository});

  final TaskRepository _repository;

  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  TaskProviderStatus _status = TaskProviderStatus.initial;
  String? _errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskFilter get filter => _filter;

  TaskProviderStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == TaskProviderStatus.loading;

  List<Task> get filteredTasks {
    switch (_filter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isCompleted).toList();
    }
  }

  Future<void> loadTasks() async {
    _status = TaskProviderStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedTasks = await _repository.loadTasks();
      _tasks
        ..clear()
        ..addAll(loadedTasks);
      _status = TaskProviderStatus.loaded;
    } catch (error) {
      _status = TaskProviderStatus.error;
      _errorMessage = 'Failed to load tasks. Please try again.';
    }

    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _persistTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return;

    _tasks[index] = updatedTask;
    await _persistTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _persistTasks();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;

    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    await _persistTasks();
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistTasks() async {
    try {
      await _repository.saveTasks(_tasks);
      _errorMessage = null;
    } catch (error) {
      _status = TaskProviderStatus.error;
      _errorMessage = 'Failed to save tasks. Please try again.';
      notifyListeners();
      rethrow;
    }
  }
}
