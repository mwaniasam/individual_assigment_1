import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    final statusColor = themeProvider.getTaskStatusColor(
      task.isCompleted, 
      task.isOverdue
    );
    
    final statusIcon = themeProvider.getTaskStatusIcon(
      task.isCompleted, 
      task.isOverdue
    );

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isLandscape ? 4 : 16, // Even less margin in landscape 
        vertical: isLandscape ? 1 : 4,    // Tighter vertical spacing
      ),
      child: ListTile(
        dense: isLandscape,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 6 : 16,  // Reduced horizontal padding
          vertical: isLandscape ? 0 : 4,
        ),
        leading: IconButton(
          icon: Icon(
            statusIcon,
            color: statusColor,
            size: isLandscape ? 20 : 24,
          ),
          onPressed: () {
            taskProvider.toggleTaskCompletion(task);
          },
          padding: EdgeInsets.all(isLandscape ? 4 : 8),
          constraints: BoxConstraints(
            minWidth: isLandscape ? 32 : 40,
            minHeight: isLandscape ? 32 : 40,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted 
                ? TextDecoration.lineThrough 
                : TextDecoration.none,
            color: task.isCompleted 
                ? Colors.grey 
                : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: TextStyle(
                  color: task.isCompleted 
                      ? Colors.grey 
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(task.dueDate),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (task.reminderTime != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.notifications,
                    size: 14,
                    color: themeProvider.secondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(task.reminderTime!),
                    style: TextStyle(
                      color: themeProvider.secondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                _showDeleteConfirmation(context, taskProvider);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                taskProvider.deleteTask(task.id!);
                onDelete?.call();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Status badge widget for calendar
class TaskStatusBadge extends StatelessWidget {
  final int taskCount;
  final bool hasOverdue;
  final bool hasCompleted;

  const TaskStatusBadge({
    super.key,
    required this.taskCount,
    this.hasOverdue = false,
    this.hasCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    Color badgeColor;
    if (hasOverdue) {
      badgeColor = themeProvider.errorColor;
    } else if (hasCompleted) {
      badgeColor = themeProvider.successColor;
    } else {
      badgeColor = themeProvider.secondaryColor;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Custom app bar for consistent styling
class StudyPlannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const StudyPlannerAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: leading,
      actions: actions,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Loading widget
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}