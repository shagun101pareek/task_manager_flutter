import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/blurred_background.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.taskId});

  final String? taskId;

  bool get isEditing => taskId != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _priority = 'Medium';
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillForm();
      });
    }
  }

  void _prefillForm() {
    final task = context.read<TaskProvider>().getTaskById(widget.taskId!);
    if (task == null) return;

    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _dueDate = task.dueDate;
    setState(() {
      _priority = task.priority;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      if (widget.isEditing) {
        final existingTask = provider.getTaskById(widget.taskId!);
        if (existingTask == null) {
          throw Exception('Task not found');
        }

        await provider.updateTask(
          existingTask.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            dueDate: _dueDate,
            clearDueDate: _dueDate == null,
            priority: _priority,
          ),
        );
      } else {
        await provider.addTask(
          Task(
            title: title,
            description: description.isEmpty ? null : description,
            dueDate: _dueDate,
            priority: _priority,
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save task. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _fieldDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.primaryPale.withValues(alpha: 0.5),
      labelStyle: TextStyle(color: AppColors.textSecondaryFor(context)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlurredBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _fieldDecoration('Title'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _fieldDecoration('Description'),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _priority,
                      decoration: _fieldDecoration('Priority'),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _priority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.calendar_today),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.border),
                        backgroundColor: AppColors.primaryPale.withValues(alpha: 0.4),
                      ),
                      label: Text(
                        _dueDate == null
                            ? 'Select due date (optional)'
                            : 'Due: ${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}',
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => setState(() => _dueDate = null),
                          child: const Text('Clear due date'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSaving ? null : _saveTask,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.isEditing ? 'Update Task' : 'Save Task',
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
