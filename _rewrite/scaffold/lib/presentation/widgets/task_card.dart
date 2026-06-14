import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
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

  String _formatDueDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color get _priorityColor {
    switch (task.priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDecoration =
        task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none;
    final textColor = task.isCompleted
        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
        : theme.colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: _priorityColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => onToggleCompletion(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: textDecoration,
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (task.description != null &&
                                task.description!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration: textDecoration,
                                  color: textColor.withValues(alpha: 0.8),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text(task.priority),
                                  labelStyle: TextStyle(
                                    color: _priorityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  side: BorderSide(color: _priorityColor),
                                  backgroundColor:
                                      _priorityColor.withValues(alpha: 0.1),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                if (task.dueDate != null)
                                  Chip(
                                    avatar: Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    label: Text(_formatDueDate(task.dueDate!)),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: theme.colorScheme.error,
                        onPressed: onDelete,
                        tooltip: 'Delete task',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
