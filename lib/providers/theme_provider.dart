import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _remindersEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get remindersEnabled => _remindersEnabled;

  // Light theme colors
  static const Color _lightPrimary = Color(0xFF673AB7);
  static const Color _lightSecondary = Color(0xFFFFC107);
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightError = Color(0xFFF44336);
  static const Color _lightSuccess = Color(0xFF4CAF50);

  // Dark theme colors
  static const Color _darkPrimary = Color(0xFF9575CD);
  static const Color _darkSecondary = Color(0xFFFFD54F);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkError = Color(0xFFEF5350);
  static const Color _darkSuccess = Color(0xFF81C784);

  // Common theme configurations that are shared between light and dark themes
  ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.deepPurple,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightBackground,
      error: _lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
    );
    
    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightBackground,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: const Color(0xFF1E1E1E),
      error: _darkError,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
    );
    
    return _baseTheme(colorScheme).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.black,
        elevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: _darkPrimary,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // Color getters for easy access
  Color get primaryColor => _isDarkMode ? _darkPrimary : _lightPrimary;
  Color get secondaryColor => _isDarkMode ? _darkSecondary : _lightSecondary;
  Color get backgroundColor => _isDarkMode ? _darkBackground : _lightBackground;
  Color get errorColor => _isDarkMode ? _darkError : _lightError;
  Color get successColor => _isDarkMode ? _darkSuccess : _lightSuccess;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  void toggleReminders() {
    _remindersEnabled = !_remindersEnabled;
    notifyListeners();
  }

  void setReminders(bool enabled) {
    _remindersEnabled = enabled;
    notifyListeners();
  }

  /// Returns the appropriate color for a task's status visualization
  /// 
  /// - Returns [successColor] if the task is completed
  /// - Returns [errorColor] if the task is overdue
  /// - Returns [primaryColor] for ongoing tasks
  Color getTaskStatusColor(bool isCompleted, bool isOverdue) {
    if (isCompleted) return successColor;
    if (isOverdue) return errorColor;
    return primaryColor;
  }

  /// Returns the appropriate icon for a task's status visualization
  /// 
  /// - Returns [Icons.check_circle] for completed tasks
  /// - Returns [Icons.warning] for overdue tasks
  /// - Returns [Icons.circle_outlined] for ongoing tasks
  IconData getTaskStatusIcon(bool isCompleted, bool isOverdue) {
    if (isCompleted) return Icons.check_circle;
    if (isOverdue) return Icons.warning;
    return Icons.circle_outlined;
  }

  /// Returns a text description of the task's status
  /// 
  /// This method can be used for accessibility or tooltip text
  String getTaskStatusDescription(bool isCompleted, bool isOverdue) {
    if (isCompleted) return 'Task completed';
    if (isOverdue) return 'Task overdue';
    return 'Task in progress';
  }
}