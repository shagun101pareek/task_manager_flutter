enum TaskSort {
  none,
  priorityHighToLow,
  priorityLowToHigh,
  dueDateAsc,
  dueDateDesc;

  String get label {
    switch (this) {
      case TaskSort.none:
        return 'Default';
      case TaskSort.priorityHighToLow:
        return 'Priority (High → Low)';
      case TaskSort.priorityLowToHigh:
        return 'Priority (Low → High)';
      case TaskSort.dueDateAsc:
        return 'Due date (Earliest)';
      case TaskSort.dueDateDesc:
        return 'Due date (Latest)';
    }
  }
}
