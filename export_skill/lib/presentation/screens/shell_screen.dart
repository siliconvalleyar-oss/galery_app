import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/theme_overlay_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/liquid_glass_bottom_bar.dart';
import '../widgets/theme_transition_overlay.dart';

/// Shell screen used by GoRouter's [StatefulShellRoute.indexedStack].
/// Provides the [LiquidGlassBottomBar] and handles the theme transition overlay.
class ShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayData = ref.watch(themeOverlayProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    // Map route index to the current index
    final currentIndex = navigationShell.currentIndex;

    Widget content = Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: LiquidGlassBottomBar(
          currentIndex: currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const [
            LiquidGlassBottomBarItem(
              label: 'Inicio',
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
            ),
            LiquidGlassBottomBarItem(
              label: 'Notificaciones',
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
            ),
            LiquidGlassBottomBarItem(
              label: 'Perfil',
              icon: Icons.person_outline,
              activeIcon: Icons.person,
            ),
          ],
          badgeCounts: [0, unreadCount, 0],
        ),
      ),
    );

    // Wrap with theme transition overlay when active
    if (overlayData != null) {
      content = Stack(
        children: [
          content,
          ThemeTransitionOverlay(
            backgroundColor: overlayData.backgroundColor,
            origin: overlayData.origin,
            onComplete: () {
              ref.read(themeOverlayProvider.notifier).hide();
            },
          ),
        ],
      );
    }

    return content;
  }
}
