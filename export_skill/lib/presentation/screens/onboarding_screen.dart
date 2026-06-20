import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/glassmorphism_widget.dart';

/// Onboarding screen with LiquidSwipe transitions.
/// Shows 3 pages with wave effect and a "Get Started" button on the last page.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final LiquidController _liquidController = LiquidController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenido',
      subtitle: 'Descubre una experiencia fluida\ncon diseño glassmorphism',
      icon: Icons.water_drop,
      gradientStart: const Color(0xFF6C63FF),
      gradientEnd: const Color(0xFF3F3D9E),
    ),
    OnboardingPage(
      title: 'Liquid Swipe',
      subtitle: 'Navegación con efecto de ola\nlíquida que arrastra el contenido',
      icon: Icons.swipe,
      gradientStart: const Color(0xFFFF6584),
      gradientEnd: const Color(0xFFCC3355),
    ),
    OnboardingPage(
      title: 'Todo Listo',
      subtitle: 'Explora las pantallas con\nefectos visuales impresionantes',
      icon: Icons.rocket_launch,
      gradientStart: const Color(0xFF00D9FF),
      gradientEnd: const Color(0xFF0099CC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: _pages
                .map((page) => _buildPage(page))
                .toList(),
            liquidController: _liquidController,
            waveType: WaveType.liquidReveal,
            enableLoop: false,
            fullTransitionValue: 500,
            onPageChangeCallback: (page) {
              setState(() => _currentPage = page);
            },
            slideIconWidget: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white54,
              size: 20,
            ),
            positionSlideIcon: 0.85,
          ),

          // Bottom section with page indicator and skip/get started button
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator using smooth_page_indicator package
                AnimatedSmoothIndicator(
                  activeIndex: _currentPage,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    spacing: 8,
                    expansionFactor: 3,
                    activeDotColor: Colors.white,
                    dotColor: Color(0x4DFFFFFF),
                  ),
                ),
                const SizedBox(height: 24),

                // Skip / Get Started button
                // Note: each button handles its own tap independently
                // to avoid GestureDetector nesting conflicts with LiquidSwipe.
                _currentPage < _pages.length - 1
                    ? GestureDetector(
                        onTap: () {
                          _liquidController.animateToPage(
                            page: _currentPage + 1,
                          );
                        },
                        child: Text(
                          'Saltar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : GlassButton(
                        label: 'Comenzar',
                        icon: Icons.arrow_forward,
                        onTap: () => context.go('/home'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            page.gradientStart,
            page.gradientEnd,
            page.gradientStart.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Icon with glassmorphism background
                GlassCard(
                  width: 120,
                  height: 120,
                  borderRadius: 30,
                  blur: 10,
                  borderWidth: 1,
                  gradientColors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  padding: const EdgeInsets.all(0),
                  child: Center(
                    child: Icon(
                      page.icon,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 48),

                // Title
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  page.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for onboarding page configuration.
class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}
