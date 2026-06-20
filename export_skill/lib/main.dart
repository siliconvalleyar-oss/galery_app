import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
      ],
      child: const LiquidGlassApp(),
    ),
  );
}

/// Root application widget.
///
/// Uses a single [MaterialApp.router] from the start, avoiding the
/// conditional MaterialApp/MaterialApp.router switch that could leave
/// the app stuck on the splash screen. Preferences load in the
/// background without blocking the UI.
class LiquidGlassApp extends ConsumerStatefulWidget {
  const LiquidGlassApp({super.key});

  @override
  ConsumerState<LiquidGlassApp> createState() => _LiquidGlassAppState();
}

class _LiquidGlassAppState extends ConsumerState<LiquidGlassApp> {
  @override
  void initState() {
    super.initState();
    // Load persisted theme preference in the background — no need to await
    // because the app shows the onboarding screen first regardless.
    Future.microtask(() {
      if (!mounted) return;
      try {
        ref.read(themeModeProvider.notifier).loadFromPrefs();
      } catch (_) {
        // If SharedPreferences fails, fall back to default theme
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Liquid Glass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
