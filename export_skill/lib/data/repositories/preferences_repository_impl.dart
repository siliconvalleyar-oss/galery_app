import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/preferences_repository.dart';

/// SharedPreferences-backed implementation of [PreferencesRepository].
class SharedPrefsPreferencesRepository implements PreferencesRepository {
  static const _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  SharedPrefsPreferencesRepository(this._prefs);

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeString = _prefs.getString(_themeKey) ?? 'dark';
    return switch (themeString) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      _ => 'dark',
    };
    await _prefs.setString(_themeKey, modeString);
  }
}
