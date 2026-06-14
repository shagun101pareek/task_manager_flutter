import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../services/hive_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<List<Task>> loadTasks() async {
    final maps = HiveService.loadTasks();
    return maps.map(Task.fromMap).toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final maps = tasks.map((task) => task.toMap()).toList();
    await HiveService.saveTasks(maps);
  }
}
