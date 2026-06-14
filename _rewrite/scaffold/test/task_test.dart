import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/enums/task_filter.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/providers/task_provider.dart';

class _FakeTaskRepository implements TaskRepository {
  List<Task> storedTasks = [];

  @override
  Future<List<Task>> loadTasks() async => List.from(storedTasks);

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    storedTasks = List.from(tasks);
  }
}

void main() {
  group('Task', () {
    test('toMap and fromMap round-trip preserves values', () {
      final task = Task(
        id: '1',
        title: 'Buy groceries',
        description: 'Milk and eggs',
        dueDate: DateTime(2026, 6, 15),
        priority: 'High',
        isCompleted: true,
      );

      final restored = Task.fromMap(task.toMap());

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.dueDate, task.dueDate);
      expect(restored.priority, task.priority);
      expect(restored.isCompleted, task.isCompleted);
    });

    test('copyWith updates fields while keeping id', () {
      final task = Task(title: 'Original', priority: 'Low');
      final updated = task.copyWith(title: 'Updated', priority: 'High');

      expect(updated.id, task.id);
      expect(updated.title, 'Updated');
      expect(updated.priority, 'High');
    });
  });

  group('TaskProvider', () {
    late _FakeTaskRepository repository;
    late TaskProvider provider;

    setUp(() {
      repository = _FakeTaskRepository();
      provider = TaskProvider(repository: repository);
    });

    test('filteredTasks returns correct subsets', () async {
      await provider.addTask(Task(title: 'Pending task', priority: 'Low'));
      await provider.addTask(
        Task(title: 'Done task', priority: 'Medium', isCompleted: true),
      );

      expect(provider.filteredTasks, hasLength(2));

      provider.setFilter(TaskFilter.completed);
      expect(provider.filteredTasks, hasLength(1));
      expect(provider.filteredTasks.first.title, 'Done task');

      provider.setFilter(TaskFilter.pending);
      expect(provider.filteredTasks, hasLength(1));
      expect(provider.filteredTasks.first.title, 'Pending task');
    });

    test('addTask persists to repository', () async {
      await provider.addTask(Task(title: 'Persist me', priority: 'Medium'));

      expect(repository.storedTasks, hasLength(1));
      expect(repository.storedTasks.first.title, 'Persist me');
    });
  });
}
