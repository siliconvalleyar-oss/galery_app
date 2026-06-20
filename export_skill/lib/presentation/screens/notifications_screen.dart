import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glassmorphism_widget.dart';

/// Notifications screen with badge counters and glassmorphism cards.
/// Simulates notifications that can be dismissed and counts that update.
class NotificationsScreen extends StatefulWidget {
  final ValueChanged<int>? onUnreadCountChanged;

  const NotificationsScreen({super.key, this.onUnreadCountChanged});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Simulated notification data
  List<_NotificationItem> _notifications = [];
  int _unreadCount = 0;

  final List<String> _titles = [
    'Nuevo seguidor',
    'Me gusta en tu foto',
    'Comentario nuevo',
    'Actualización del sistema',
    'Mensaje recibido',
    'Recordatorio de evento',
    'Nueva función disponible',
    'Reporte semanal',
  ];

  final List<String> _subtitles = [
    'María García empezó a seguirte',
    'A 15 personas les gustó tu foto',
    'Juan comentó "Increíble trabajo!"',
    'La versión 3.2.0 está disponible',
    'Tienes un mensaje de Ana López',
    'La reunión del equipo empieza en 1 hora',
    'Prueba la nueva función de Squad',
    'Tu resumen semanal está listo',
  ];

  final List<IconData> _icons = [
    Icons.person_add,
    Icons.favorite,
    Icons.chat_bubble_outline,
    Icons.system_update,
    Icons.email_outlined,
    Icons.event,
    Icons.new_releases_outlined,
    Icons.assessment,
  ];

  final List<Color> _colors = [
    AppTheme.primaryColor,
    AppTheme.secondaryColor,
    AppTheme.accentColor,
    AppTheme.successColor,
    AppTheme.warningColor,
    const Color(0xFFE040FB),
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
  ];

  @override
  void initState() {
    super.initState();
    _generateNotifications();
    // Report initial unread count after build to avoid modifying provider during tree build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onUnreadCountChanged?.call(_unreadCount);
    });
  }

  void _generateNotifications() {
    final random = Random();
    final count = random.nextInt(4) + 5; // 5 to 8 notifications
    _notifications = List.generate(count, (index) {
      final i = index % _titles.length;
      return _NotificationItem(
        id: index,
        title: _titles[i],
        subtitle: _subtitles[i],
        icon: _icons[i],
        color: _colors[i],
        time: '${random.nextInt(23) + 1}h',
        isUnread: index < 3, // First 3 are unread
      );
    });
    _unreadCount = _notifications.where((n) => n.isUnread).length;
  }

  void _dismissNotification(int index) {
    setState(() {
      if (_notifications[index].isUnread) {
        _unreadCount--;
      widget.onUnreadCountChanged?.call(_unreadCount);
      }
      _notifications.removeAt(index);
    });
  }

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isUnread = false;
      }
      _unreadCount = 0;
      widget.onUnreadCountChanged?.call(0);
    });
  }

  void _addRandomNotification() {
    final random = Random();
    final i = random.nextInt(_titles.length);
    final newNotif = _NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titles[i],
      subtitle: _subtitles[i],
      icon: _icons[i],
      color: _colors[i],
      time: '0h',
      isUnread: true,
    );
    setState(() {
      _notifications.insert(0, newNotif);
      _unreadCount++;
      widget.onUnreadCountChanged?.call(_unreadCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notificaciones',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ).animate().fadeIn(duration: 400.ms).slideX(
                            begin: -0.1,
                            end: 0,
                            duration: 400.ms,
                          ),
                      const SizedBox(width: 12),
                      // Badge showing total unread
                      if (_unreadCount > 0)
                        badges.Badge(
                          badgeContent: Text(
                            '$_unreadCount',
                            style: TextStyle(
                              color: AppTheme.textPrimary(context),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: AppTheme.secondaryColor,
                            padding: const EdgeInsets.all(6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const SizedBox.shrink(),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_unreadCount > 0)
                        GestureDetector(
                          onTap: _markAllRead,
                          child: Text(
                            'Leer todo',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _addRandomNotification,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.textPrimary(context),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Notifications List ──────────────────────────────
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin notificaciones',
                            style: TextStyle(
                              color: AppTheme.textSecondary(context),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    final notif = _notifications[index];

    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismissNotification(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.errorColor.withValues(alpha: 0.3),
        ),
        child: Icon(Icons.delete_outline, color: AppTheme.textPrimary(context).withValues(alpha: 0.7)),
      ),
      child: GestureDetector(
        onTap: () {
          context.push(
            '/home/notifications/${notif.id}',
            extra: {
              'title': notif.title,
              'subtitle': notif.subtitle,
              'icon': notif.icon,
              'color': notif.color,
              'time': notif.time,
            },
          );
        },
        child: GlassCard(
          height: 80,
          borderRadius: 16,
          blur: 8,
          borderWidth: notif.isUnread ? 1.0 : 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gradientColors: notif.isUnread
              ? [
                  AppTheme.primaryColor.withValues(alpha: 0.12),
                  AppTheme.surface(context).withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.surface(context).withValues(alpha: 0.2),
                  AppTheme.surface(context).withValues(alpha: 0.05),
                ],
          borderGradientColors: notif.isUnread
              ? [
                  AppTheme.primaryColor.withValues(alpha: 0.4),
                  AppTheme.surface(context).withValues(alpha: 0.3),
                ]
              : [
                  AppTheme.textSecondary(context).withValues(alpha: 0.2),
                  AppTheme.textSecondary(context).withValues(alpha: 0.05),
                ],
          child: Row(
          children: [
            // Icon with glow
            Hero(
              tag: 'notification-icon-${notif.id}',
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      notif.color.withValues(alpha: 0.3),
                      notif.color.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: notif.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(notif.icon, color: notif.color, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.title,
                        style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontSize: 14,
                          fontWeight: notif.isUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        notif.time,
                        style: TextStyle(
                          color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (notif.isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  ).animate().fadeIn(
          duration: 400.ms,
          delay: (index * 80).ms,
        ).slideX(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          delay: (index * 80).ms,
        );
  }
}

/// Internal notification item model.
class _NotificationItem {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String time;
  bool isUnread;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
    this.isUnread = true,
  });
}
