import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/task_repository_impl.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/task_list_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await PreferencesService.init();
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadThemeMode(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            repository: TaskRepositoryImpl(),
          ),
        ),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      home: const TaskListScreen(),
    );
  }
}
