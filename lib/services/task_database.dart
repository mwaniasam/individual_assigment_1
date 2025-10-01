import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class TaskDatabase {
  static final TaskDatabase _instance = TaskDatabase._internal();
  factory TaskDatabase() => _instance;
  TaskDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate INTEGER NOT NULL,
        reminderTime INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  // Create a new task
  Future<Task> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'dueDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch
      ],
      orderBy: 'dueDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Get tasks due today
  Future<List<Task>> getTodayTasks() async {
    final today = DateTime.now();
    return await getTasksForDate(today);
  }

  // Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    final db = await database;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'dueDate < ? AND isCompleted = 0',
      whereArgs: [startOfToday.millisecondsSinceEpoch],
      orderBy: 'dueDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Get upcoming tasks (future tasks, not today)
  Future<List<Task>> getUpcomingTasks() async {
    final db = await database;
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'dueDate > ? AND isCompleted = 0',
      whereArgs: [endOfToday.millisecondsSinceEpoch],
      orderBy: 'dueDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Get completed tasks
  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isCompleted = 1',
      orderBy: 'dueDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Get tasks that should show reminders
  Future<List<Task>> getTasksWithReminders() async {
    final db = await database;
    final now = DateTime.now();

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'reminderTime <= ? AND isCompleted = 0',
      whereArgs: [now.millisecondsSinceEpoch],
      orderBy: 'reminderTime ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Update a task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get a single task by id
  Future<Task?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  // Mark task as completed
  Future<int> markTaskCompleted(int id) async {
    final task = await getTask(id);
    if (task != null) {
      return await updateTask(task.copyWith(isCompleted: true));
    }
    return 0;
  }

  // Mark task as incomplete
  Future<int> markTaskIncomplete(int id) async {
    final task = await getTask(id);
    if (task != null) {
      return await updateTask(task.copyWith(isCompleted: false));
    }
    return 0;
  }

  // Get tasks count by date (for calendar highlighting)
  Future<Map<DateTime, int>> getTaskCountsByDate() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        dueDate,
        COUNT(*) as count,
        SUM(CASE WHEN isCompleted = 1 THEN 1 ELSE 0 END) as completedCount
      FROM tasks 
      GROUP BY date(dueDate/1000, 'unixepoch')
    ''');

    Map<DateTime, int> taskCounts = {};
    for (var map in maps) {
      final date = DateTime.fromMillisecondsSinceEpoch(map['dueDate']);
      final dateKey = DateTime(date.year, date.month, date.day);
      taskCounts[dateKey] = map['count'];
    }

    return taskCounts;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}