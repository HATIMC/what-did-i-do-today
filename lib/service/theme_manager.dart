import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class ThemeManager extends ChangeNotifier {
  bool _preferencesLoaded = false;
  bool get preferencesLoaded => _preferencesLoaded;

  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  Color _seedColor = Colors.deepPurple; // Default Material 3 seed color
  String _userName = 'Guest'; // New: Default user name
  static const String _themeKey = 'app_theme_mode';
  static const String _colorKey = 'app_seed_color';
  static const String _userNameKey = 'user_name'; // New: Key for user name

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  String get userName => _userName; // New: Getter for user name

  ThemeManager() {
    _loadThemePreferences(); // Load both theme mode, color, and user name when the manager is created
  }

  // Loads the saved theme mode and color from SharedPreferences
  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final int? themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode =
          ThemeMode.system; // Fallback to system if no preference or invalid
    }

    // Load seed color
    final int? colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _seedColor = Color(colorValue);
    } else {
      _seedColor = Colors.deepPurple; // Fallback to default if no preference
    }

    // Load user name
    _userName = prefs.getString(_userNameKey) ?? 'Guest'; // Fallback to 'Guest'

    _preferencesLoaded = true;
    notifyListeners();
  }

  // Toggles the theme and saves the preference
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreferences(); // Save all current preferences
    notifyListeners(); // Notify listeners about the change
  }

  // Sets a new seed color and saves the preference
  void setSeedColor(Color color) {
    _seedColor = color;
    _saveThemePreferences(); // Save all current preferences
    notifyListeners(); // Notify listeners about the change
  }

  // New: Sets a new user name and saves the preference
  void setUserName(String name) {
    _userName = name;
    _saveThemePreferences(); // Save all current preferences
    notifyListeners(); // Notify listeners about the change
  }

  // Saves the current theme mode and color to SharedPreferences
  Future<void> _saveThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
    await prefs.setInt(_colorKey, _seedColor.value);
    await prefs.setString(_userNameKey, _userName); // Save user name
  }

  // You can also add a method to set theme based on system preference
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _saveThemePreferences(); // Save system preference
    notifyListeners();
  }

  /// Returns the ThemeData for the current theme mode and seed color.
  /// When themeMode is ThemeMode.system, it uses the provided systemBrightness.
  ThemeData currentTheme(Brightness? systemBrightness) {
    Brightness effectiveBrightness;

    if (_themeMode == ThemeMode.light) {
      effectiveBrightness = Brightness.light;
    } else if (_themeMode == ThemeMode.dark) {
      effectiveBrightness = Brightness.dark;
    } else {
      // ThemeMode.system
      effectiveBrightness = systemBrightness ?? Brightness.light; // Default to light if systemBrightness is null
    }

    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: effectiveBrightness,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          // Color will be set by the color scheme automatically for onSurface/onPrimary etc.
          // No need to explicitly set it here based on Theme.of(context).colorScheme.onSurface
          // as ThemeData.from handles that.
        ),
        // You can add other text styles here if you want to override defaults
      ),
    );
  }
}