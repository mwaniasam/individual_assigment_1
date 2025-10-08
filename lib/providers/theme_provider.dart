import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class ThemeProvider extends ChangeNotifier {
  // Platform-specific corner radius
  final double _cornerRadius = Platform.isIOS ? 12.0 : 8.0;
  
  // Platform-specific elevation values
  final double _cardElevation = Platform.isIOS ? 1.0 : 2.0;
  final double _navBarElevation = Platform.isIOS ? 0.0 : 8.0;

  // Brightness override settings
  Brightness? _brightnessOverride;
  bool get hasOverride => _brightnessOverride != null;
  Brightness get effectiveBrightness => 
      _brightnessOverride ?? (_isDarkMode ? Brightness.dark : Brightness.light);

  // Theme transition durations
  final Duration themeChangeDuration = const Duration(milliseconds: 300);
  final Duration colorTweenDuration = const Duration(milliseconds: 200);
  
  /// Returns a curve for theme transition animations
  Curve get themeChangeCurve => Curves.easeInOut;
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
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: Platform.isIOS ? 1.0 : 2.0),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: _navBarElevation,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
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

  /// Toggles between light and dark theme with animation support
  /// 
  /// The transition will use [themeChangeDuration] and [themeChangeCurve]
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Sets the theme mode with animation support
  /// 
  /// @param isDark Whether to set dark mode (true) or light mode (false)
  void setTheme(bool isDark) {
    if (_isDarkMode == isDark) return;
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
    _savePreferences();
  }

  /// Override the brightness setting independently of the theme mode
  /// 
  /// This is useful for specific screens or contexts where you want to
  /// temporarily force a specific brightness without changing the overall theme.
  /// Pass null to remove the override.
  void overrideBrightness(Brightness? brightness) {
    if (_brightnessOverride == brightness) return;
    _brightnessOverride = brightness;
    notifyListeners();
  }

  /// Clear any active brightness override
  void clearBrightnessOverride() {
    if (_brightnessOverride == null) return;
    _brightnessOverride = null;
    notifyListeners();
  }

  /// Saves the current theme and reminder preferences to persistent storage
  /// 
  /// This method will be implemented to save preferences using SharedPreferences
  Future<void> _savePreferences() async {
    // TODO: Implement saving preferences using SharedPreferences
    // await SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool('darkMode', _isDarkMode);
    //   prefs.setBool('reminders', _remindersEnabled);
    // });
  }

  /// Loads saved theme and reminder preferences from persistent storage
  /// 
  /// This method will be implemented to load preferences using SharedPreferences
  Future<void> loadPreferences() async {
    // TODO: Implement loading preferences using SharedPreferences
    // await SharedPreferences.getInstance().then((prefs) {
    //   _isDarkMode = prefs.getBool('darkMode') ?? false;
    //   _remindersEnabled = prefs.getBool('reminders') ?? true;
    //   notifyListeners();
    // });
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