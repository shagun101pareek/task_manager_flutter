import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_filter.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/blurred_background.dart';
import '../widgets/dismissible_task_item.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/sort_menu_button.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_search_bar.dart';
import '../theme/app_colors.dart';
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

  Future<void> _handleTaskDismissed(Task task) async {
    final provider = context.read<TaskProvider>();
    final deletedTask = await provider.deleteTask(task.id);
    if (!mounted || deletedTask == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${deletedTask.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await provider.undoLastDelete();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _emptyTitle(TaskProvider provider) {
    if (provider.isSearching) return 'No matching tasks';

    switch (provider.filter) {
      case TaskFilter.all:
        return 'No tasks yet';
      case TaskFilter.completed:
        return 'No completed tasks';
      case TaskFilter.pending:
        return 'No pending tasks';
    }
  }

  String _emptySubtitle(TaskProvider provider) {
    if (provider.isSearching) {
      return 'Try a different search term.';
    }

    switch (provider.filter) {
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
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          SortMenuButton(
            selectedSort: provider.sort,
            onSortChanged: provider.setSort,
          ),
          IconButton(
            tooltip: themeProvider.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ],
      ),
      body: BlurredBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaskSearchBar(
                query: provider.searchQuery,
                onChanged: provider.setSearchQuery,
              ),
              TaskFilterBar(
                selectedFilter: provider.filter,
                onFilterChanged: provider.setFilter,
              ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(provider.errorMessage!),
                        ),
                        TextButton(
                          onPressed: provider.loadTasks,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        elevation: 4,
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading) {
      return Center(
        key: const ValueKey('loading'),
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    final tasks = provider.filteredTasks;

    if (tasks.isEmpty) {
      return EmptyTasksView(
        key: ValueKey(
          'empty_${provider.filter.name}_${provider.searchQuery}_${provider.sort.name}',
        ),
        title: _emptyTitle(provider),
        subtitle: _emptySubtitle(provider),
      );
    }

    return ListView.builder(
      key: ValueKey(
        'list_${provider.filter.name}_${provider.searchQuery}_${provider.sort.name}_${tasks.length}',
      ),
      padding: const EdgeInsets.only(top: 4, bottom: 88),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return _AnimatedTaskItem(
          key: ValueKey(task.id),
          task: task,
          onDismissed: () => _handleTaskDismissed(task),
          onToggleCompletion: () {
            provider.toggleTaskCompletion(task.id);
          },
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
    required this.onDismissed,
    required this.onToggleCompletion,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onDismissed;
  final VoidCallback onToggleCompletion;
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
      child: DismissibleTaskItem(
        task: task,
        onDismissed: onDismissed,
        onToggleCompletion: onToggleCompletion,
        onEdit: onEdit,
      ),
    );
  }
}
