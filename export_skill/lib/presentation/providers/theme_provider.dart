import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for a [SharedPreferences] instance, configured once at app startup.
final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('prefsProvider must be overridden in ProviderScope');
});

/// Provider for the current [ThemeMode], backed by a [ThemeModeNotifier].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Manages the app's [ThemeMode] with persistence to [SharedPreferences].
///
/// Cycles through dark → light → system → dark on each [toggle] call.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';
  static const _cycle = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];

  @override
  ThemeMode build() => ThemeMode.dark;

  /// Load the persisted theme, or fall back to dark.
  void loadFromPrefs() {
    final prefs = ref.read(prefsProvider);
    final themeString = prefs.getString(_key) ?? 'dark';
    state = switch (themeString) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  /// Cycle to the next theme and persist the choice.
  void toggle() {
    final currentIndex = _cycle.indexOf(state);
    final newMode = _cycle[(currentIndex + 1) % _cycle.length];

    final modeString = switch (newMode) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      _ => 'dark',
    };
    ref.read(prefsProvider).setString(_key, modeString);

    state = newMode;
  }
}
