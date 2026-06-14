import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_filter.dart';
import '../providers/task_provider.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  Future<void> _openTaskForm({String? taskId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(taskId: taskId),
      ),
    );
  }

  String _emptyTitle(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'No tasks yet';
      case TaskFilter.completed:
        return 'No completed tasks';
      case TaskFilter.pending:
        return 'No pending tasks';
    }
  }

  String _emptySubtitle(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'Tap the + button to create your first task.';
      case TaskFilter.completed:
        return 'Complete a task to see it here.';
      case TaskFilter.pending:
        return 'All caught up! No pending tasks right now.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TaskFilterBar(
            selectedFilter: provider.filter,
            onFilterChanged: provider.setFilter,
          ),
          if (provider.errorMessage != null)
            MaterialBanner(
              content: Text(provider.errorMessage!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: provider.loadTasks,
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    final tasks = provider.filteredTasks;

    if (tasks.isEmpty) {
      return EmptyTasksView(
        key: ValueKey('empty_${provider.filter.name}'),
        title: _emptyTitle(provider.filter),
        subtitle: _emptySubtitle(provider.filter),
      );
    }

    return ListView.builder(
      key: ValueKey('list_${provider.filter.name}_${tasks.length}'),
      padding: const EdgeInsets.only(top: 4, bottom: 88),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return _AnimatedTaskItem(
          key: ValueKey(task.id),
          task: task,
          onToggleCompletion: () {
            provider.toggleTaskCompletion(task.id);
          },
          onDelete: () => provider.deleteTask(task.id),
          onEdit: () => _openTaskForm(taskId: task.id),
        );
      },
    );
  }
}

class _AnimatedTaskItem extends StatelessWidget {
  const _AnimatedTaskItem({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: TaskCard(
        task: task,
        onToggleCompletion: onToggleCompletion,
        onDelete: onDelete,
        onEdit: onEdit,
      ),
    );
  }
}
