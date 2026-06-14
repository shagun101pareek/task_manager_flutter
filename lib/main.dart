import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/providers/task_provider.dart';
import 'presentation/screens/task_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
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
