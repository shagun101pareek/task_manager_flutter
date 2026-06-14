class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  bool isCompleted;

  Task({
    String? id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    this.isCompleted = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      priority: map['priority'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
