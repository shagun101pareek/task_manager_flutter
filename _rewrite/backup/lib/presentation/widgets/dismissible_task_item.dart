import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../theme/app_colors.dart';
import 'task_card.dart';

class DismissibleTaskItem extends StatelessWidget {
  const DismissibleTaskItem({
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
    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: TaskCard(
        task: task,
        onToggleCompletion: onToggleCompletion,
        onEdit: onEdit,
      ),
    );
  }
}
