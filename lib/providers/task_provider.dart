import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_database.dart';

class TaskProvider extends ChangeNotifier {
  final TaskDatabase _database = TaskDatabase();
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  List<Task> _overdueTasks = [];
  List<Task> _upcomingTasks = [];
  List<Task> _completedTasks = [];
  bool _isLoading = false;

  // Getters
  List<Task> get allTasks => _allTasks;
  List<Task> get todayTasks => _todayTasks;
  List<Task> get overdueTasks => _overdueTasks;
  List<Task> get upcomingTasks => _upcomingTasks;
  List<Task> get completedTasks => _completedTasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    loadTasks();
  }

  // Load all tasks from database
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    
    debugPrint('📂 TaskProvider: Loading tasks from database...');

    try {
      _allTasks = await _database.getAllTasks();
      debugPrint('✅ TaskProvider: Loaded ${_allTasks.length} tasks from database');
      await _categorizeAllTasks();
    } catch (e) {
      debugPrint('❌ Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Categorize tasks into different lists
  Future<void> _categorizeAllTasks() async {
    try {
      _todayTasks = await _database.getTodayTasks();
      _overdueTasks = await _database.getOverdueTasks();
      _upcomingTasks = await _database.getUpcomingTasks();
      _completedTasks = await _database.getCompletedTasks();
    } catch (e) {
      debugPrint('Error categorizing tasks: $e');
    }
  }

  // Add new task
  Future<void> addTask(Task task) async {
    try {
      debugPrint('💾 TaskProvider: Adding new task: "${task.title}"');
      final newTask = await _database.insertTask(task);
      debugPrint('✅ TaskProvider: Task saved with ID: ${newTask.id}');
      _allTasks.add(newTask);
      await _categorizeAllTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error adding task: $e');
    }
  }

  // Update existing task
  Future<void> updateTask(Task task) async {
    try {
      debugPrint('🔄 TaskProvider: Updating task: "${task.title}" (ID: ${task.id})');
      await _database.updateTask(task);
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = task;
      }
      debugPrint('✅ TaskProvider: Task updated successfully');
      await _categorizeAllTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(int id) async {
    try {
      await _database.deleteTask(id);
      _allTasks.removeWhere((task) => task.id == id);
      await _categorizeAllTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  // Mark task as completed
  Future<void> markTaskCompleted(int id) async {
    try {
      await _database.markTaskCompleted(id);
      await loadTasks();
    } catch (e) {
      debugPrint('Error marking task completed: $e');
    }
  }

  // Mark task as incomplete
  Future<void> markTaskIncomplete(int id) async {
    try {
      await _database.markTaskIncomplete(id);
      await loadTasks();
    } catch (e) {
      debugPrint('Error marking task incomplete: $e');
    }
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    try {
      return await _database.getTasksForDate(date);
    } catch (e) {
      debugPrint('Error getting tasks for date: $e');
      return [];
    }
  }

  // Get tasks with reminders
  Future<List<Task>> getTasksWithReminders() async {
    try {
      return await _database.getTasksWithReminders();
    } catch (e) {
      debugPrint('Error getting tasks with reminders: $e');
      return [];
    }
  }

  // Get task counts by date for calendar highlighting
  Future<Map<DateTime, int>> getTaskCountsByDate() async {
    try {
      return await _database.getTaskCountsByDate();
    } catch (e) {
      debugPrint('Error getting task counts by date: $e');
      return {};
    }
  }

  // Get a single task by id
  Future<Task?> getTask(int id) async {
    try {
      return await _database.getTask(id);
    } catch (e) {
      debugPrint('Error getting task: $e');
      return null;
    }
  }

  // Get tasks for today screen combining overdue, today, and upcoming
  List<Task> getTodayScreenTasks() {
    List<Task> todayScreenTasks = [];
    
    // Add overdue tasks first
    todayScreenTasks.addAll(_overdueTasks);
    
    // Add today's tasks
    todayScreenTasks.addAll(_todayTasks.where((task) => !task.isCompleted));
    
    // Add completed tasks for today
    todayScreenTasks.addAll(_todayTasks.where((task) => task.isCompleted));
    
    return todayScreenTasks;
  }

  // Search tasks by title or description
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _allTasks;
    
    final lowerQuery = query.toLowerCase();
    return _allTasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(lowerQuery);
      final descriptionMatch = task.description?.toLowerCase().contains(lowerQuery) ?? false;
      return titleMatch || descriptionMatch;
    }).toList();
  }

  // Get tasks by completion status
  List<Task> getTasksByStatus({required bool isCompleted}) {
    return _allTasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  // Get upcoming tasks for the next N days
  List<Task> getUpcomingTasksForDays(int days) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return _allTasks.where((task) {
      return !task.isCompleted && 
             task.dueDate.isAfter(now) && 
             task.dueDate.isBefore(futureDate);
    }).toList();
  }

  // Get task statistics
  Map<String, int> getTaskStatistics() {
    return {
      'total': _allTasks.length,
      'completed': _completedTasks.length,
      'overdue': _overdueTasks.length,
      'dueToday': _todayTasks.length,
      'upcoming': _upcomingTasks.length,
    };
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadTasks();
  }
}