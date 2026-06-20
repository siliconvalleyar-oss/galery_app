import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Overlay Data Model ─────────────────────────────────────────────

/// Data for the theme transition overlay animation.
class ThemeOverlayData {
  final Color backgroundColor;
  final Offset origin;

  const ThemeOverlayData({
    required this.backgroundColor,
    required this.origin,
  });
}

// ─── Provider ────────────────────────────────────────────────────────

/// Provider that holds the current overlay data for the theme transition.
/// When non-null, the MainNavigationScreen shows the overlay animation.
/// The overlay clears itself to null once the animation completes.
final themeOverlayProvider =
    NotifierProvider<_ThemeOverlayNotifier, ThemeOverlayData?>(
  _ThemeOverlayNotifier.new,
);

class _ThemeOverlayNotifier extends Notifier<ThemeOverlayData?> {
  @override
  ThemeOverlayData? build() => null;

  void show(ThemeOverlayData data) => state = data;

  void hide() => state = null;
}
