import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';

import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/notification_detail_screen.dart';
import '../providers/navigation_provider.dart';

/// Route paths used throughout the app.
class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const notifications = '/home/notifications';
  static const notificationsDetail = '/home/notifications/:id';
  static const profile = '/home/profile';
  static const profileEdit = '/home/profile/edit';

  AppRoutes._();
}

// ─── Transition Builders ────────────────────────────────────────

/// Shared axis transition — scaled (Z-axis). Good for detail views.
CustomTransitionPage _sharedAxisScaledPage({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent,
        child: child,
      );
    },
  );
}

/// Shared axis transition — vertical (Y-axis). Good for edit/settings.
CustomTransitionPage _sharedAxisVerticalPage({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.vertical,
        fillColor: Colors.transparent,
        child: child,
      );
    },
  );
}

/// Fade transition. Good for onboarding → main app.
CustomTransitionPage _fadeTransitionPage({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        ),
        child: child,
      );
    },
  );
}



// ─── Router Provider ────────────────────────────────────────────

/// Riverpod provider for the GoRouter instance.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      // ─── Onboarding (fade in) ──────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // ─── Main shell with bottom nav tabs ───────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // ─── Home Tab ──────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // ─── Notifications Tab ─────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                name: 'notifications',
                builder: (context, state) => _NotificationsTab(),
                routes: [
                  // Notification detail (shared axis scaled + Hero)
                  GoRoute(
                    path: ':id',
                    name: 'notification-detail',
                    pageBuilder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      final extra = state.extra;
                      return _sharedAxisScaledPage(
                        key: state.pageKey,
                        child: NotificationDetailScreen(
                          notificationId: id,
                          notificationData: extra,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ─── Profile Tab ───────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  // Profile edit (shared axis vertical + Hero)
                  GoRoute(
                    path: 'edit',
                    name: 'profile-edit',
                    pageBuilder: (context, state) => _sharedAxisVerticalPage(
                      key: state.pageKey,
                      child: const ProfileEditScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ─── Notifications Tab Wrapper ──────────────────────────────────

/// Thin wrapper that provides the [onUnreadCountChanged] callback to
/// [NotificationsScreen], writing directly to [unreadCountProvider].
class _NotificationsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<_NotificationsTab> {
  @override
  Widget build(BuildContext context) {
    return NotificationsScreen(
      onUnreadCountChanged: (count) {
        ref.read(unreadCountProvider.notifier).setCount(count);
      },
    );
  }
}
