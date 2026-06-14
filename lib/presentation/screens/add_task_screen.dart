import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.taskId});

  final String? taskId;

  bool get isEditing => taskId != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Medium';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefillForm());
    }
  }

  void _prefillForm() {
    final task = context.read<TaskProvider>().getTaskById(widget.taskId!);
    if (task == null) return;
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _dueDate = task.dueDate;
    setState(() => _priority = task.priority);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TaskProvider>();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.isEditing) {
      final existing = provider.getTaskById(widget.taskId!);
      if (existing == null) return;
      await provider.updateTask(
        existing.copyWith(
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
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
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
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDueDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _dueDate == null
                      ? 'Select due date (optional)'
                      : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saveTask,
                child: Text(widget.isEditing ? 'Update Task' : 'Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
