import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String taskBoxName = 'tasks';
  static const String tasksKey = 'task_list';

  static Box get _box => Hive.box(taskBoxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(taskBoxName);
  }

  static List<Map<dynamic, dynamic>> loadTasks() {
    final stored = _box.get(tasksKey);
    if (stored == null) return [];

    return (stored as List)
        .map((item) => Map<dynamic, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    await _box.put(tasksKey, tasks);
  }
}
