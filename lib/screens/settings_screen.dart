import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import 'database_viewer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<ThemeProvider, TaskProvider>(
        builder: (context, themeProvider, taskProvider, child) {
          return ListView(
            children: [
              // App preferences section
              _buildSectionHeader(context, 'App Preferences'),
              
              // Dark mode toggle
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: themeProvider.primaryColor,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    themeProvider.isDarkMode 
                        ? 'Dark theme enabled' 
                        : 'Light theme enabled',
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              
              // Reminders toggle
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
                  secondary: Icon(
                    themeProvider.remindersEnabled 
                        ? Icons.notifications_active 
                        : Icons.notifications_off,
                    color: themeProvider.remindersEnabled 
                        ? themeProvider.secondaryColor 
                        : Colors.grey,
                  ),
                  title: const Text('Task Reminders'),
                  subtitle: Text(
                    themeProvider.remindersEnabled
                        ? 'Reminders enabled'
                        : 'Reminders disabled',
                  ),
                  value: themeProvider.remindersEnabled,
                  onChanged: (value) {
                    themeProvider.toggleReminders();
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Storage information section
              _buildSectionHeader(context, 'Storage Information'),
              
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    Icons.storage,
                    color: themeProvider.primaryColor,
                  ),
                  title: const Text('Database'),
                  subtitle: const Text('SQLite local storage'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () => _showStorageInfo(context),
                ),
              ),
              
              // Debug: Database viewer button  
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(
                    Icons.developer_mode,
                    color: Colors.purple,
                  ),
                  title: const Text('Database Viewer (Debug)'),
                  subtitle: const Text('View raw database contents'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDatabaseViewer(context),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Task statistics section
              _buildSectionHeader(context, 'Statistics'),
              
              _buildTaskStatistics(context, taskProvider, themeProvider),
              
              const SizedBox(height: 24),
              
              // App information section
              _buildSectionHeader(context, 'App Information'),
              
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info,
                        color: themeProvider.primaryColor,
                      ),
                      title: const Text('About'),
                      subtitle: const Text('Study Planner v1.0.0'),
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.color_lens,
                        color: themeProvider.primaryColor,
                      ),
                      title: const Text('Theme Preview'),
                      subtitle: const Text('View current color scheme'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemePreview(context, themeProvider),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Data management section
              _buildSectionHeader(context, 'Data Management'),
              
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                      title: const Text('Refresh Data'),
                      subtitle: const Text('Reload all tasks from database'),
                      onTap: () => _refreshData(context, taskProvider),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text('Clear All Data'),
                      subtitle: const Text('Delete all tasks (cannot be undone)'),
                      onTap: () => _showClearDataDialog(context, taskProvider),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTaskStatistics(
    BuildContext context,
    TaskProvider taskProvider,
    ThemeProvider themeProvider,
  ) {
    final stats = taskProvider.getTaskStatistics();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total',
                    stats['total']?.toString() ?? '0',
                    Icons.list_alt,
                    themeProvider.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completed',
                    stats['completed']?.toString() ?? '0',
                    Icons.check_circle,
                    themeProvider.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Overdue',
                    stats['overdue']?.toString() ?? '0',
                    Icons.warning,
                    themeProvider.errorColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Upcoming',
                    stats['upcoming']?.toString() ?? '0',
                    Icons.schedule,
                    themeProvider.secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showStorageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.storage),
              SizedBox(width: 8),
              Text('Storage Information'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Database Type: SQLite'),
              SizedBox(height: 8),
              Text('Storage Location: Local device'),
              SizedBox(height: 8),
              Text('Data Persistence: All tasks are stored locally and persist between app sessions.'),
              SizedBox(height: 8),
              Text('Privacy: Your data never leaves your device.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Study Planner',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 48),
      children: const [
        Text('A simple and elegant task management app designed for students.'),
        SizedBox(height: 8),
        Text('Features:'),
        Text('• Task creation and management'),
        Text('• Calendar view with task highlighting'),
        Text('• Reminders and notifications'),
        Text('• Dark and light themes'),
        Text('• Local SQLite storage'),
      ],
    );
  }

  void _showThemePreview(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Theme Preview'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorPreview('Primary', themeProvider.primaryColor),
                _buildColorPreview('Secondary', themeProvider.secondaryColor),
                _buildColorPreview('Background', themeProvider.backgroundColor),
                _buildColorPreview('Success', themeProvider.successColor),
                _buildColorPreview('Error', themeProvider.errorColor),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorPreview(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _refreshData(BuildContext context, TaskProvider taskProvider) {
    taskProvider.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Clear All Data'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete all tasks? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Delete all tasks
                final allTasks = taskProvider.allTasks;
                for (final task in allTasks) {
                  if (task.id != null) {
                    await taskProvider.deleteTask(task.id!);
                  }
                }
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _showDatabaseViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DatabaseViewerScreen(),
      ),
    );
  }
}