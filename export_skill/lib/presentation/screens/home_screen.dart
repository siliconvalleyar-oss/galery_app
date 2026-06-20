import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/theme_overlay_provider.dart';
import '../widgets/glassmorphism_widget.dart';
import '../widgets/liquid_bar.dart';
import '../widgets/squad_widget.dart';

/// Home screen - demonstrates glassmorphism cards, LiquidBar, Squad widget,
/// feature carousel with smooth_page_indicator, and dynamic animations.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _autoScrollTimer;

  final List<_FeatureCardData> _features = const [
    _FeatureCardData(
      icon: Icons.blur_on,
      title: 'Glassmorphism',
      description: 'Efecto vidrio esmerilado con BackdropFilter y gradientes en toda la UI.',
      color: Color(0xFF6C63FF),
    ),
    _FeatureCardData(
      icon: Icons.waves,
      title: 'Liquid Swipe',
      description: 'Transiciones fluidas con ondas líquidas para navegación y onboarding.',
      color: Color(0xFF00D9FF),
    ),
    _FeatureCardData(
      icon: Icons.groups,
      title: 'Squad Animado',
      description: 'Animaciones grupales sincronizadas con micro-interacciones al tocar.',
      color: Color(0xFFFF6584),
    ),
    _FeatureCardData(
      icon: Icons.show_chart,
      title: 'Liquid Bar',
      description: 'Barra de progreso deformable con efecto de ola animada.',
      color: Color(0xFF4ECDC4),
    ),
    _FeatureCardData(
      icon: Icons.circle_notifications,
      title: 'Badges en Tiempo Real',
      description: 'Sistema de notificaciones con contadores dinámicos y badges.',
      color: Color(0xFFFFB347),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll carousel every 4 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        final nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage >= _features.length) {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        } else {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ).animate().fadeIn(duration: 400.ms).slideX(
                            begin: -0.1,
                            end: 0,
                            duration: 400.ms,
                          ),
                      const SizedBox(height: 4),
                      Text(
                        'Explora los efectos visuales',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    ],
                  ),
                  // Theme toggle + avatar
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Theme toggle button
                      _ThemeToggleButton(),
                      const SizedBox(width: 8),
                      // Avatar with glass effect
                      GlassCard(
                        width: 52,
                        height: 52,
                        borderRadius: 16,
                        blur: 8,
                        borderWidth: 1,
                        padding: const EdgeInsets.all(0),
                        gradientColors: [
                          AppTheme.primaryColor.withValues(alpha: 0.3),
                          AppTheme.secondaryColor.withValues(alpha: 0.1),
                        ],
                        child: Center(
                          child: Icon(
                            Icons.person,
                            color: AppTheme.textPrimary(context),
                            size: 28,
                          ),
                        ),
                      ).animate().scale(
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                            delay: 350.ms,
                          ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Liquid Bar (floating progress) ──────────────────
              GlassCard(
                width: double.infinity,
                height: 80,
                borderRadius: 20,
                blur: 12,
                borderWidth: 1,
                padding: const EdgeInsets.all(16),
                gradientColors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.03),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso del proyecto',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '68%',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const LiquidBar(
                      progress: 0.68,
                      height: 6,
                      colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 500.ms,
                    delay: 200.ms,
                  ),

              const SizedBox(height: 24),

              // ─── Feature Carousel ────────────────────────────────
              Text(
                'Características',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(
                    begin: -0.1,
                    end: 0,
                    duration: 400.ms,
                    delay: 300.ms,
                  ),

              const SizedBox(height: 16),

              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _features.length,
                  itemBuilder: (context, index) {
                    return _buildFeatureCard(context, index);
                  },
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

              const SizedBox(height: 12),

              // ─── Page Indicator ──────────────────────────────────
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _features.length,
                  effect: WormEffect(
                    activeDotColor: AppTheme.accentColor,
                    dotColor: AppTheme.textSecondary(context).withValues(alpha: 0.3),
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
  
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms).scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    delay: 500.ms,
                  ),

              const SizedBox(height: 24),

              // ─── Stats Row ───────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.favorite,
                      value: '128',
                      label: 'Likes',
                      color: AppTheme.secondaryColor,
                      delay: 400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.visibility,
                      value: '2.4k',
                      label: 'Visitas',
                      color: AppTheme.accentColor,
                      delay: 500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.star,
                      value: '4.8',
                      label: 'Rating',
                      color: AppTheme.warningColor,
                      delay: 600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Section Title ───────────────────────────────────
              Text(
                'Squad - Equipo',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(
                    begin: -0.1,
                    end: 0,
                    duration: 400.ms,
                    delay: 400.ms,
                  ),

              const SizedBox(height: 16),

              // ─── Squad Widget ────────────────────────────────────
              const SquadWidget(
                itemCount: 6,
                itemHeight: 130,
                itemWidth: 160,
                spacing: 12,
              ),

              const SizedBox(height: 24),

              // ─── Activity Card ───────────────────────────────────
              Text(
                'Actividad Reciente',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(
                    begin: -0.1,
                    end: 0,
                    duration: 400.ms,
                    delay: 500.ms,
                  ),

              const SizedBox(height: 12),

              _buildActivityItem(
                context,
                icon: Icons.download,
                title: 'Instalación completada',
                subtitle: 'Hace 2 minutos',
                color: AppTheme.successColor,
                delay: 600,
              ),
              _buildActivityItem(
                context,
                icon: Icons.person_add,
                title: 'Nuevo miembro',
                subtitle: 'Hace 15 minutos',
                color: AppTheme.primaryColor,
                delay: 700,
              ),
              _buildActivityItem(
                context,
                icon: Icons.update,
                title: 'Actualización v2.0',
                subtitle: 'Hace 1 hora',
                color: AppTheme.warningColor,
                delay: 800,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required int delay,
  }) {
    return GlassCard(
      height: 90,
      borderRadius: 16,
      blur: 10,
      borderWidth: 1,
      padding: const EdgeInsets.all(12),
      gradientColors: [
        color.withValues(alpha: 0.15),
        color.withValues(alpha: 0.03),
      ],
      borderGradientColors: [
        color.withValues(alpha: 0.3),
        color.withValues(alpha: 0.05),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: delay.ms,
        );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
  }) {
    return GlassCard(
      height: 64,
      borderRadius: 14,
      blur: 8,
      borderWidth: 0.5,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gradientColors: [
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.02),
      ],
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary(context),
            size: 20,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay.ms).slideX(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          delay: delay.ms,
        );
  }

  Widget _buildFeatureCard(BuildContext context, int index) {
    final feature = _features[index];
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;
        if (_pageController.position.haveDimensions) {
          final page = _pageController.page ?? 0;
          final difference = (page - index).abs().clamp(0.0, 1.0);
          scale = 1.0 - (difference * 0.08);
        }
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GlassCard(
          height: 180,
          borderRadius: 20,
          blur: 12,
          borderWidth: 1.5,
          padding: const EdgeInsets.all(20),
          gradientColors: [
            feature.color.withValues(alpha: 0.2),
            feature.color.withValues(alpha: 0.05),
          ],
          borderGradientColors: [
            feature.color.withValues(alpha: 0.4),
            AppTheme.surface(context).withValues(alpha: 0.3),
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      feature.color.withValues(alpha: 0.3),
                      feature.color.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: feature.color.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(feature.icon, color: feature.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                feature.description,
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme mode icon helper — top-level so it's accessible from any widget.
IconData _themeModeIcon(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.dark => Icons.dark_mode,
    ThemeMode.light => Icons.light_mode,
    ThemeMode.system => Icons.settings_brightness,
  };
}

/// Toggle button that captures its own tap position for the radial reveal.
class _ThemeToggleButton extends ConsumerWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Offset? tapPos;
    final themeMode = ref.watch(themeModeProvider);

    return GestureDetector(
      onTapDown: (details) => tapPos = details.globalPosition,
      onTap: () {
        // Calculate old background before toggling
        final brightness = themeMode == ThemeMode.dark
            ? Brightness.dark
            : themeMode == ThemeMode.light
                ? Brightness.light
                : WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final oldBg = brightness == Brightness.dark
            ? AppTheme.darkBackground
            : AppTheme.lightBackground;

        // Toggle theme via Riverpod (also persists)
        ref.read(themeModeProvider.notifier).toggle();

        // Trigger overlay transition animation
        ref.read(themeOverlayProvider.notifier).show(ThemeOverlayData(
          backgroundColor: oldBg,
          origin: tapPos ?? Offset.zero,
        ));
      },
      child: GlassCard(
        width: 40,
        height: 40,
        borderRadius: 12,
        blur: 6,
        borderWidth: 1,
        padding: const EdgeInsets.all(0),
        gradientColors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.03),
        ],
        child: Center(
          child: Icon(
            _themeModeIcon(themeMode),
            color: AppTheme.textPrimary(context),
            size: 20,
          ),
        ),
      ),
    ).animate().scale(
          duration: 500.ms,
          curve: Curves.elasticOut,
          delay: 300.ms,
        );
  }
}

/// Data model for a feature card in the carousel.
class _FeatureCardData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
