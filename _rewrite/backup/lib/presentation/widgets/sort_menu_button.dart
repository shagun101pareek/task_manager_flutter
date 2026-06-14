import 'package:flutter/material.dart';

import '../../domain/enums/task_sort.dart';
import '../theme/app_colors.dart';

class SortMenuButton extends StatelessWidget {
  const SortMenuButton({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  final TaskSort selectedSort;
  final ValueChanged<TaskSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskSort>(
      icon: Icon(
        Icons.sort,
        color: AppColors.textPrimaryFor(context),
      ),
      tooltip: 'Sort tasks',
      initialValue: selectedSort,
      onSelected: onSortChanged,
      itemBuilder: (context) {
        return TaskSort.values
            .map(
              (sort) => PopupMenuItem<TaskSort>(
                value: sort,
                child: Row(
                  children: [
                    if (sort == selectedSort)
                      Icon(Icons.check, size: 18, color: AppColors.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(sort.label)),
                  ],
                ),
              ),
            )
            .toList();
      },
    );
  }
}
