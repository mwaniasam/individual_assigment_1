import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null for new task, existing task for editing

  const TaskFormScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedReminderTime;
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedDate = widget.task!.dueDate;
      
      if (widget.task!.reminderTime != null) {
        _hasReminder = true;
        _selectedReminderTime = TimeOfDay.fromDateTime(widget.task!.reminderTime!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter task description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 24),
            
            // Due date section
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: themeProvider.primaryColor,
                ),
                title: const Text('Due Date'),
                subtitle: Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDate,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reminder section
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      Icons.notifications,
                      color: themeProvider.secondaryColor,
                    ),
                    title: const Text('Set Reminder'),
                    subtitle: Text(
                      _hasReminder && _selectedReminderTime != null
                          ? 'Reminder at ${_selectedReminderTime!.format(context)}'
                          : 'No reminder set',
                    ),
                    value: _hasReminder,
                    onChanged: (value) {
                      setState(() {
                        _hasReminder = value;
                        if (!value) {
                          _selectedReminderTime = null;
                        }
                      });
                    },
                  ),
                  if (_hasReminder) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const SizedBox(width: 40), // Align with switch
                      title: const Text('Reminder Time'),
                      subtitle: Text(
                        _selectedReminderTime != null
                            ? _selectedReminderTime!.format(context)
                            : 'Tap to set time',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectReminderTime,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedReminderTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (_hasReminder && _selectedReminderTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set a reminder time or disable reminder'),
          ),
        );
        return;
      }

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      DateTime? reminderDateTime;
      if (_hasReminder && _selectedReminderTime != null) {
        reminderDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedReminderTime!.hour,
          _selectedReminderTime!.minute,
        );
      }

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dueDate: _selectedDate,
        reminderTime: reminderDateTime,
        isCompleted: widget.task?.isCompleted ?? false,
        createdAt: widget.task?.createdAt,
      );

      if (widget.task != null) {
        // Update existing task
        taskProvider.updateTask(task);
      } else {
        // Add new task
        taskProvider.addTask(task);
      }

      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.task != null 
                ? 'Task updated successfully' 
                : 'Task created successfully',
          ),
        ),
      );
    }
  }
}