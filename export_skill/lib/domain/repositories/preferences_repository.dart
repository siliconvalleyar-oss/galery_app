import 'package:flutter/material.dart';

/// Abstract repository for persisting and retrieving user preferences.
abstract class PreferencesRepository {
  /// Load the saved [ThemeMode], or return [ThemeMode.dark] as fallback.
  Future<ThemeMode> getThemeMode();

  /// Persist the selected [ThemeMode] for future sessions.
  Future<void> setThemeMode(ThemeMode mode);
}
