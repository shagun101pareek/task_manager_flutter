import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      home: Scaffold(
        appBar: AppBar(title: const Text('Task Manager')),
        body: const Center(child: Text('Task Manager')),
      ),
    );
  }
}
