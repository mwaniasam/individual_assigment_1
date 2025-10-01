import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/task.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'screens/today_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/task_form.dart';

void main() {
  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Study Planner',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const MainScreen(),
            routes: {
              '/today': (context) => const TodayScreen(),
              '/calendar': (context) => const CalendarScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/add-task': (context) => const TaskFormScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TodayScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Show reminder dialog on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForReminders();
    });
  }

  Future<void> _checkForReminders() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (!themeProvider.remindersEnabled) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasksWithReminders = await taskProvider.getTasksWithReminders();

    if (tasksWithReminders.isNotEmpty && mounted) {
      _showReminderDialog(tasksWithReminders);
    }
  }

  void _showReminderDialog(List<Task> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.amber),
              SizedBox(width: 8),
              Text('Task Reminders'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: tasks.length == 1
                ? Text('Reminder: ${tasks.first.title}')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You have ${tasks.length} task reminders:'),
                      const SizedBox(height: 8),
                      ...tasks.take(3).map((task) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• ${task.title}'),
                          )),
                      if (tasks.length > 3)
                        Text('... and ${tasks.length - 3} more'),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedIndex = 0; // Navigate to Today screen
                });
              },
              child: const Text('View Tasks'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: themeProvider.primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.today),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}