import 'package:flutter/material.dart';

import '../../domain/enums/task_filter.dart';
import '../theme/app_colors.dart';
import 'blurred_background.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GlassCard(
        padding: const EdgeInsets.all(6),
        borderRadius: 20,
        child: SegmentedButton<TaskFilter>(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryPale;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryDark;
              }
              return AppColors.textSecondary;
            }),
          ),
          segments: TaskFilter.values
              .map(
                (filter) => ButtonSegment<TaskFilter>(
                  value: filter,
                  label: Text(filter.label),
                ),
              )
              .toList(),
          selected: {selectedFilter},
          onSelectionChanged: (selection) {
            onFilterChanged(selection.first);
          },
        ),
      ),
    );
  }
}
