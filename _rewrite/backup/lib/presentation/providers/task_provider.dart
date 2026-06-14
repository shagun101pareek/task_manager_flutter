import 'package:flutter/foundation.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_filter.dart';
import '../../domain/enums/task_sort.dart';
import '../../domain/repositories/task_repository.dart';
import '../../services/notification_service.dart';

enum TaskProviderStatus { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this._repository});

  final TaskRepository _repository;

  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.none;
  String _searchQuery = '';
  TaskProviderStatus _status = TaskProviderStatus.initial;
  String? _errorMessage;
  Task? _lastDeletedTask;

  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskFilter get filter => _filter;

  TaskSort get sort => _sort;

  String get searchQuery => _searchQuery;

  TaskProviderStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == TaskProviderStatus.loading;

  bool get isSearching => _searchQuery.trim().isNotEmpty;

  List<Task> get filteredTasks {
    var result = _applyFilter(_tasks);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result
          .where((task) => task.title.toLowerCase().contains(query))
          .toList();
    }

    if (_sort != TaskSort.none) {
      result = List<Task>.from(result)..sort(_compareTasks);
    }

    return result;
  }

  List<Task> _applyFilter(List<Task> source) {
    switch (_filter) {
      case TaskFilter.all:
        return List<Task>.from(source);
      case TaskFilter.completed:
        return source.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return source.where((task) => !task.isCompleted).toList();
    }
  }

  int _priorityWeight(String priority) {
    switch (priority) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      case 'Low':
        return 1;
      default:
        return 0;
    }
  }

  int _compareDueDates(Task a, Task b) {
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  }

  int _compareTasks(Task a, Task b) {
    switch (_sort) {
      case TaskSort.none:
        return 0;
      case TaskSort.priorityHighToLow:
        return _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority));
      case TaskSort.priorityLowToHigh:
        return _priorityWeight(a.priority).compareTo(_priorityWeight(b.priority));
      case TaskSort.dueDateAsc:
        return _compareDueDates(a, b);
      case TaskSort.dueDateDesc:
        return _compareDueDates(b, a);
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
      await NotificationService.syncAllReminders(_tasks);
    } catch (error) {
      _status = TaskProviderStatus.error;
      _errorMessage = 'Failed to load tasks. Please try again.';
    }

    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _persistTasks();
    await NotificationService.scheduleTaskReminder(task);
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return;

    _tasks[index] = updatedTask;
    await _persistTasks();
    await NotificationService.scheduleTaskReminder(updatedTask);
    notifyListeners();
  }

  Future<Task?> deleteTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return null;

    final deletedTask = _tasks.removeAt(index);
    _lastDeletedTask = deletedTask;
    await NotificationService.cancelTaskReminder(taskId);
    await _persistTasks();
    notifyListeners();
    return deletedTask;
  }

  Future<void> undoLastDelete() async {
    final task = _lastDeletedTask;
    if (task == null) return;

    _tasks.add(task);
    _lastDeletedTask = null;
    await _persistTasks();
    await NotificationService.scheduleTaskReminder(task);
    notifyListeners();
  }

  void clearLastDeletedTask() {
    _lastDeletedTask = null;
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;

    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    await _persistTasks();
    await NotificationService.scheduleTaskReminder(_tasks[index]);
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
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
