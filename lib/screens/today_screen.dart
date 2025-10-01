import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh tasks when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StudyPlannerAppBar(
        title: 'Today',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).refresh();
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const LoadingWidget(message: 'Loading tasks...');
          }

          final overdueTasks = taskProvider.overdueTasks;
          final todayTasks = taskProvider.todayTasks.where((task) => !task.isCompleted).toList();
          final completedTodayTasks = taskProvider.todayTasks.where((task) => task.isCompleted).toList();

          final hasAnyTasks = overdueTasks.isNotEmpty || todayTasks.isNotEmpty || completedTodayTasks.isNotEmpty;

          if (!hasAnyTasks) {
            return EmptyStateWidget(
              icon: Icons.today,
              title: 'No tasks for today',
              subtitle: 'Add a task to get started with your study plan!',
              actionText: 'Add Task',
              onActionPressed: () => _navigateToAddTask(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () => taskProvider.refresh(),
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              children: [
                // Date header
                _buildDateHeader(context),
                
                // Task statistics
                _buildTaskStatistics(context, taskProvider),
                
                // Overdue tasks section
                if (overdueTasks.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Overdue',
                    overdueTasks.length,
                    Icons.warning,
                    Provider.of<ThemeProvider>(context).errorColor,
                  ),
                  ...overdueTasks.map((task) => _buildTaskCard(context, task)),
                  const SizedBox(height: 16),
                ],

                // Today's tasks section
                if (todayTasks.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Due Today',
                    todayTasks.length,
                    Icons.today,
                    Provider.of<ThemeProvider>(context).primaryColor,
                  ),
                  ...todayTasks.map((task) => _buildTaskCard(context, task)),
                  const SizedBox(height: 16),
                ],

                // Completed tasks section
                if (completedTodayTasks.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Completed Today',
                    completedTodayTasks.length,
                    Icons.check_circle,
                    Provider.of<ThemeProvider>(context).successColor,
                  ),
                  ...completedTodayTasks.map((task) => _buildTaskCard(context, task)),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final today = DateTime.now();
    final dateString = DateFormat('EEEE, MMMM dd').format(today);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Provider.of<ThemeProvider>(context).primaryColor,
            Provider.of<ThemeProvider>(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Your tasks for today',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatistics(BuildContext context, TaskProvider taskProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final stats = taskProvider.getTaskStatistics();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Overdue',
              stats['overdue'] ?? 0,
              Icons.warning,
              themeProvider.errorColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Due Today',
              stats['dueToday'] ?? 0,
              Icons.today,
              themeProvider.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Completed',
              stats['completed'] ?? 0,
              Icons.check_circle,
              themeProvider.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return TaskCard(
      task: task,
      onTap: () => _showTaskDetails(context, task),
      onEdit: () => _navigateToEditTask(context, task),
    );
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskFormScreen(),
      ),
    );
  }

  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Task title
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted 
                        ? TextDecoration.lineThrough 
                        : TextDecoration.none,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Task details
                _buildDetailRow(
                  Icons.calendar_today,
                  'Due Date',
                  DateFormat('EEEE, MMM dd, yyyy').format(task.dueDate),
                  themeProvider.getTaskStatusColor(task.isCompleted, task.isOverdue),
                ),
                
                if (task.reminderTime != null)
                  _buildDetailRow(
                    Icons.notifications,
                    'Reminder',
                    DateFormat('MMM dd, yyyy - HH:mm').format(task.reminderTime!),
                    themeProvider.secondaryColor,
                  ),
                
                _buildDetailRow(
                  Icons.info_outline,
                  'Status',
                  task.isCompleted ? 'Completed' : 
                    (task.isOverdue ? 'Overdue' : 'Pending'),
                  themeProvider.getTaskStatusColor(task.isCompleted, task.isOverdue),
                ),
                
                _buildDetailRow(
                  Icons.access_time,
                  'Created',
                  DateFormat('MMM dd, yyyy - HH:mm').format(task.createdAt),
                  Colors.grey,
                ),
                
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToEditTask(context, task);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Provider.of<TaskProvider>(context, listen: false)
                              .toggleTaskCompletion(task);
                          Navigator.pop(context);
                        },
                        icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                        label: Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}