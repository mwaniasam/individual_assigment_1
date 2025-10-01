import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/task_database.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  List<Task> _allTasks = [];
  bool _isLoading = true;
  final TaskDatabase _database = TaskDatabase();

  @override
  void initState() {
    super.initState();
    _loadDatabaseContent();
  }

  Future<void> _loadDatabaseContent() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _database.getAllTasks();
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
      debugPrint('🔍 Database Viewer: Loaded ${tasks.length} tasks directly from database');
    } catch (e) {
      debugPrint('❌ Database Viewer Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer (Debug)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDatabaseContent,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Database info header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Database Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Tasks in Database: ${_allTasks.length}'),
                      Text('Database Type: SQLite'),
                      Text('Last Updated: ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}'),
                    ],
                  ),
                ),
                
                // Tasks list
                Expanded(
                  child: _allTasks.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storage, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No tasks in database',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add some tasks to see them here',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _allTasks.length,
                          itemBuilder: (context, index) {
                            final task = _allTasks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: task.isCompleted
                                      ? Colors.green
                                      : (task.isOverdue ? Colors.red : Colors.orange),
                                  child: Text(
                                    '${task.id}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow('ID', '${task.id}'),
                                        _buildDetailRow('Title', task.title),
                                        if (task.description != null && task.description!.isNotEmpty)
                                          _buildDetailRow('Description', task.description!),
                                        _buildDetailRow(
                                          'Due Date',
                                          DateFormat('MMM dd, yyyy - HH:mm').format(task.dueDate),
                                        ),
                                        if (task.reminderTime != null)
                                          _buildDetailRow(
                                            'Reminder',
                                            DateFormat('MMM dd, yyyy - HH:mm').format(task.reminderTime!),
                                          ),
                                        _buildDetailRow(
                                          'Status',
                                          task.isCompleted ? 'Completed' : 'Pending',
                                        ),
                                        _buildDetailRow(
                                          'Created',
                                          DateFormat('MMM dd, yyyy - HH:mm').format(task.createdAt),
                                        ),
                                        _buildDetailRow(
                                          'Overdue',
                                          task.isOverdue.toString(),
                                        ),
                                        _buildDetailRow(
                                          'Due Today',
                                          task.isDueToday.toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // Bottom actions
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loadDatabaseContent,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Provider.of<TaskProvider>(context, listen: false).refresh();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('App data refreshed from database'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.sync),
                          label: const Text('Sync App'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}