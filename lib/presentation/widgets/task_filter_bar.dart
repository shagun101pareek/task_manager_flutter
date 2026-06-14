import 'package:flutter/material.dart';

import '../../domain/enums/task_filter.dart';

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
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<TaskFilter>(
        segments: TaskFilter.values
            .map(
              (filter) => ButtonSegment(
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
    );
  }
}
