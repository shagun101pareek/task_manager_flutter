import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'blurred_background.dart';

class TaskSearchBar extends StatelessWidget {
  const TaskSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        borderRadius: 16,
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search tasks by title...',
            hintStyle: TextStyle(color: AppColors.textSecondaryFor(context)),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondaryFor(context),
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textSecondaryFor(context),
                    ),
                    onPressed: () => onChanged(''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
