import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/task_repository_impl.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/task_list_screen.dart';
import 'services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(repository: TaskRepositoryImpl()),
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      home: const TaskListScreen(),
    );
  }
}
