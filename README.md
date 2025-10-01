# 📚 Flutter Study Planner

A comprehensive Flutter application for managing study schedules, tasks, and academic goals with a beautiful, responsive design.

## ✨ Features

- **📅 Interactive Calendar**: View and manage tasks with an intuitive calendar interface
- **📝 Task Management**: Create, edit, and track study tasks with priorities and deadlines
- **🌓 Dark/Light Theme**: Seamless theme switching for comfortable studying
- **📱 Responsive Design**: Optimized for both portrait and landscape orientations
- **💾 Local Storage**: SQLite database for offline task persistence
- **🎯 Smart Organization**: Categorize tasks by subject and priority levels

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flutter-study-planner.git
cd flutter-study-planner
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## 🛠️ Built With

- **Flutter**: UI framework
- **Provider**: State management
- **SQLite**: Local database
- **table_calendar**: Calendar widget
- **Material Design 3**: UI components

## 📖 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── task.dart
├── providers/                # State management
│   ├── task_provider.dart
│   └── theme_provider.dart
├── screens/                  # App screens
│   ├── calendar_screen.dart
│   ├── home_screen.dart
│   └── task_form_screen.dart
├── services/                 # Business logic
│   └── database_helper.dart
└── widgets/                  # Reusable components
    └── task_card.dart
```

## 👨‍💻 Author

Samuel Mwania - [s.mwania@alustudent.com](mailto:s.mwania@alustudent.com)