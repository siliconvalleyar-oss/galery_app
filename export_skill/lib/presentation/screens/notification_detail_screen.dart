import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glassmorphism_widget.dart';

/// Notification detail screen displaying full notification information.
/// Receives [notificationId] and optional [notificationData] extra.
class NotificationDetailScreen extends StatelessWidget {
  final int notificationId;
  final Object? notificationData;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
    this.notificationData,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data from extra or use defaults
    final data = notificationData is Map<String, dynamic>
        ? notificationData as Map<String, dynamic>
        : <String, dynamic>{};
    final title = data['title'] as String?;
    final subtitle = data['subtitle'] as String?;
    final icon = data['icon'] as IconData?;
    final color = data['color'] as Color?;
    final time = data['time'] as String?;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── App Bar ────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: GlassCard(
                      width: 44,
                      height: 44,
                      borderRadius: 14,
                      blur: 6,
                      borderWidth: 1,
                      padding: const EdgeInsets.all(0),
                      gradientColors: [
                        AppTheme.primaryColor.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: AppTheme.textPrimary(context),
                          size: 22,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(
                        begin: -0.1, end: 0, duration: 300.ms,
                      ),
                  const SizedBox(width: 16),
                  Text(
                    'Notificación',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(
                        begin: -0.05, end: 0, duration: 300.ms, delay: 100.ms,
                      ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Notification Detail Card ───────────────────
              GlassCard(
                width: double.infinity,
                height: null,
                borderRadius: 24,
                blur: 15,
                borderWidth: 1.5,
                padding: const EdgeInsets.all(24),
                gradientColors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                ],
                child: Column(
                  children: [
                    // Icon with glow + Hero animation
                    Hero(
                      tag: 'notification-icon-$notificationId',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (color ?? AppTheme.primaryColor).withValues(alpha: 0.3),
                              (color ?? AppTheme.primaryColor).withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            icon ?? Icons.notifications,
                            color: color ?? AppTheme.primaryColor,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      title ?? 'Notificación #$notificationId',
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Time
                    Text(
                      time ?? 'Desconocido',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      subtitle ?? 'No hay información adicional disponible para esta notificación.',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Actions row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.share_outlined,
                          label: 'Compartir',
                          color: AppTheme.accentColor,
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.bookmark_outline,
                          label: 'Guardar',
                          color: AppTheme.warningColor,
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.delete_outline,
                          label: 'Eliminar',
                          color: AppTheme.errorColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 20),

              // ─── Metadata Card ──────────────────────────────
              GlassCard(
                width: double.infinity,
                height: null,
                borderRadius: 20,
                blur: 10,
                borderWidth: 0.5,
                padding: const EdgeInsets.all(20),
                gradientColors: [
                  AppTheme.surface(context).withValues(alpha: 0.15),
                  AppTheme.surface(context).withValues(alpha: 0.05),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información',
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMetadataRow(context, 'ID', '#$notificationId'),
                    const Divider(color: Colors.white10, height: 24),
                    _buildMetadataRow(context, 'Tipo', 'Notificación estándar'),
                    const Divider(color: Colors.white10, height: 24),
                    _buildMetadataRow(context, 'Estado', 'No leída'),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(
                    begin: 0.1, end: 0, duration: 400.ms, delay: 400.ms,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label (próximamente)'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
