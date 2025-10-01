import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Task>> _selectedTasks;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedTasks = ValueNotifier(_getTasksForDay(_selectedDay!));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksByDate();
    });
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    super.dispose();
  }

  Future<void> _loadTasksByDate() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.refresh();
    
    _tasksByDate.clear();
    for (final task in taskProvider.allTasks) {
      final dateKey = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      
      if (_tasksByDate[dateKey] == null) {
        _tasksByDate[dateKey] = [];
      }
      _tasksByDate[dateKey]!.add(task);
    }
    
    _selectedTasks.value = _getTasksForDay(_selectedDay!);
    setState(() {});
  }

  List<Task> _getTasksForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _tasksByDate[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
                _selectedTasks.value = _getTasksForDay(_selectedDay!);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasksByDate,
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (isLandscape) {
            return SafeArea(
              child: Row(
                children: [
                  // Calendar side
                  Expanded(
                    flex: 5,  // Slightly reduced calendar space
                    child: Container(
                      margin: const EdgeInsets.all(4), // Reduced margin
                      child: Card(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height - 100, // Account for AppBar and padding
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0), // Reduced padding
                              child: _buildCalendarWidget(themeProvider),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  // Tasks side
                  Expanded(
                    flex: 3,  // More space for tasks
                    child: Column(
                      children: [
                        _buildDateHeader(),
                        Expanded(
                          child: _buildTasksList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SafeArea(
              child: Column(
                children: [
                  // Calendar widget with strict height constraint
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45, // Reduced to 45% to ensure no overflow
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced margins
                      child: SingleChildScrollView(
                        child: _buildCalendarWidget(themeProvider),
                      ),
                    ),
                  ),
                  _buildDateHeader(),
                  Expanded(
                    child: _buildTasksList(),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarWidget(ThemeProvider themeProvider) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return TableCalendar<Task>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat, // Allow user to control format in both orientations
      eventLoader: _getTasksForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: isLandscape ? 28 : 42, // Further reduced for portrait
      daysOfWeekHeight: isLandscape ? 20 : 30, // Further reduced header height
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: BoxDecoration(
          color: themeProvider.primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: themeProvider.secondaryColor,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: themeProvider.primaryColor.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        cellPadding: EdgeInsets.all(isLandscape ? 1 : 2), // Minimal padding
        cellMargin: EdgeInsets.all(isLandscape ? 1 : 1), // Minimal margins
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true, // Always show format button so user can control view
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: themeProvider.primaryColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        formatButtonTextStyle: const TextStyle(
          color: Colors.white,
        ),
        headerPadding: EdgeInsets.symmetric(
          vertical: isLandscape ? 2 : 4, // Minimal header padding for both modes
        ),
        titleTextStyle: TextStyle(
          fontSize: isLandscape ? 14 : 16, // Smaller title in landscape
        ),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedTasks.value = _getTasksForDay(selectedDay);
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, tasks) {
          if (tasks.isEmpty) return null;
          
          final markersToShow = tasks.take(3).toList();
          
          return Positioned(
            bottom: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: markersToShow.map((task) {
                Color markerColor;
                if (task.isCompleted) {
                  markerColor = Colors.green;
                } else if (task.isOverdue) {
                  markerColor = Colors.red;
                } else {
                  markerColor = themeProvider.primaryColor;
                }
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 8 : 12,
        vertical: isLandscape ? 4 : 6, // Minimal vertical padding
      ),
      child: Text(
        _selectedDay != null
            ? isLandscape 
                ? DateFormat('MMM dd, yyyy').format(_selectedDay!) // Shorter format in landscape
                : 'Tasks for ${DateFormat('EEEE, MMM dd, yyyy').format(_selectedDay!)}'
            : 'Select a date',
        style: Theme.of(context).textTheme.titleMedium?.copyWith( // Changed from titleLarge to titleMedium
          fontWeight: FontWeight.bold,
          fontSize: isLandscape ? 14 : 16, // Reduced font size for portrait
        ),
        textAlign: isLandscape ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _buildTasksList() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return ValueListenableBuilder<List<Task>>(
      valueListenable: _selectedTasks,
      builder: (context, tasks, _) {
        if (tasks.isEmpty) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          
          return Center(
            child: Padding(
              padding: EdgeInsets.all(isLandscape ? 16 : 32), // Less padding in landscape
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: isLandscape ? 48 : 80, // Smaller icon in landscape
                    color: themeProvider.primaryColor.withOpacity(0.5),
                  ),
                  SizedBox(height: isLandscape ? 12 : 24), // Less spacing in landscape
                  Text(
                    'No tasks for this date',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryColor,
                      fontSize: isLandscape ? 16 : null, // Smaller text in landscape
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isLandscape ? 4 : 8), // Less spacing
                  Text(
                    'Add a task to get started!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontSize: isLandscape ? 12 : null, // Smaller text in landscape
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isLandscape ? 12 : 24), // Less spacing
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddTask(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 16 : 24, // Less padding in landscape
                        vertical: isLandscape ? 8 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final sortedTasks = List<Task>.from(tasks);
        sortedTasks.sort((a, b) {
          if (a.isOverdue != b.isOverdue) {
            return a.isOverdue ? -1 : 1;
          }
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.dueDate.compareTo(b.dueDate);
        });

        return ListView.builder(
          padding: EdgeInsets.all(isLandscape ? 4 : 8), // Less padding in landscape
          itemCount: sortedTasks.length,
          itemBuilder: (context, index) {
            final task = sortedTasks[index];
            return TaskCard(
              task: task,
              onTap: () => _showTaskDetails(context, task),
              onEdit: () => _editTask(context, task),
              onDelete: () => _deleteTask(context, task),
            );
          },
        );
      },
    );
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskFormScreen(),
      ),
    ).then((_) => _loadTasksByDate());
  }

  void _editTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    ).then((_) => _loadTasksByDate());
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty) ...[
              Text('Description:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(task.description!),
              const SizedBox(height: 16),
            ],
            Text('Due Date:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(DateFormat('EEEE, MMM dd, yyyy').format(task.dueDate)),
            const SizedBox(height: 16),
            Text('Status:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  task.isCompleted ? Icons.check_circle : (task.isOverdue ? Icons.warning : Icons.pending),
                  color: task.isCompleted ? Colors.green : (task.isOverdue ? Colors.red : Colors.orange),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(task.isCompleted ? 'Completed' : (task.isOverdue ? 'Overdue' : 'Pending')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editTask(context, task);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              await taskProvider.deleteTask(task.id!);
              if (mounted) {
                Navigator.pop(context);
                _loadTasksByDate();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}