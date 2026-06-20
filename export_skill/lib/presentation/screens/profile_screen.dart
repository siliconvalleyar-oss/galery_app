import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glassmorphism_widget.dart';

/// Profile screen with glassmorphism profile card, skill bars, and
/// staggered animations for each section.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  final List<_Skill> _skills = [
    _Skill('Flutter', 0.92, AppTheme.primaryColor),
    _Skill('Dart', 0.88, AppTheme.accentColor),
    _Skill('UI/UX', 0.85, AppTheme.secondaryColor),
    _Skill('Firebase', 0.78, AppTheme.warningColor),
    _Skill('Animaciones', 0.95, AppTheme.successColor),
  ];

  final List<_Achievement> _achievements = [
    _Achievement('10K', 'Seguidores', Icons.people, AppTheme.primaryColor),
    _Achievement('50', 'Proyectos', Icons.rocket_launch, AppTheme.secondaryColor),
    _Achievement('3.2K', 'Horas', Icons.timer, AppTheme.accentColor),
    _Achievement('15', 'Premios', Icons.emoji_events, AppTheme.warningColor),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ─── Profile Header Card (using glassmorphism package) ─
              GlassmorphicContainer(
                width: double.infinity,
                height: 220,
                borderRadius: 24,
                blur: 15,
                border: 1.5,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    AppTheme.secondaryColor.withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.3),
                    AppTheme.secondaryColor.withValues(alpha: 0.1),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar with Hero for shared axis transition
                      Hero(
                        tag: 'profile-avatar',
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1 + _pulseController.value * 0.03,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFFFF6584),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'A',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary(context),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Alex Rivera',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Desarrollador Flutter Senior',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(
                    begin: -0.2,
                    end: 0,
                    duration: 500.ms,
                  ),

              // ─── Edit Profile Button ──────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/home/profile/edit'),
                  child: GlassCard(
                    width: 160,
                    height: 42,
                    borderRadius: 14,
                    blur: 6,
                    borderWidth: 1,
                    padding: const EdgeInsets.all(0),
                    gradientColors: [
                      AppTheme.primaryColor.withValues(alpha: 0.25),
                      AppTheme.secondaryColor.withValues(alpha: 0.1),
                    ],
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: AppTheme.textPrimary(context),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Editar Perfil',
                            style: TextStyle(
                              color: AppTheme.textPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 24),

              // ─── Achievements Grid ────────────────────────────────
              SizedBox(
                height: 100,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _achievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(index);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ─── Skills Section ───────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Habilidades',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(
                      begin: -0.1,
                      end: 0,
                      duration: 400.ms,
                      delay: 300.ms,
                    ),
              ),

              const SizedBox(height: 12),

              ...List.generate(_skills.length, (index) {
                return _buildSkillBar(index);
              }),

              const SizedBox(height: 24),

              // ─── About Section ────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Acerca de',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(
                      begin: -0.1,
                      end: 0,
                      duration: 400.ms,
                      delay: 500.ms,
                    ),
              ),

              const SizedBox(height: 12),

              GlassCard(
                height: 100,
                borderRadius: 16,
                blur: 10,
                borderWidth: 1,
                padding: const EdgeInsets.all(16),
        gradientColors: [
          AppTheme.surface(context).withValues(alpha: 0.2),
          AppTheme.surface(context).withValues(alpha: 0.05),
        ],
        child: Text(
          'Desarrollador apasionado por crear experiencias móviles '
          'impresionantes con Flutter. Especializado en animaciones, '
          'glassmorphism y diseño UI/UX moderno.',
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 14,
            height: 1.5,
          ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 500.ms,
                    delay: 600.ms,
                  ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(int index) {
    final ach = _achievements[index];
    return GlassCard(
      height: 90,
      borderRadius: 14,
      blur: 8,
      borderWidth: 0.5,
      padding: const EdgeInsets.all(8),
      gradientColors: [
        ach.color.withValues(alpha: 0.12),
        ach.color.withValues(alpha: 0.03),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ach.icon, color: ach.color, size: 22),
          const SizedBox(height: 4),
          Text(
            ach.value,
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ach.label,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 9,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: (200 + index * 80).ms,
        ).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: (200 + index * 80).ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildSkillBar(int index) {
    final skill = _skills[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        height: 52,
        borderRadius: 14,
        blur: 6,
        borderWidth: 0.5,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gradientColors: [
          AppTheme.surface(context).withValues(alpha: 0.2),
          AppTheme.surface(context).withValues(alpha: 0.05),
        ],
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                skill.name,
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: skill.level),
                duration: Duration(milliseconds: 1000 + index * 200),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: AppTheme.textSecondary(context).withValues(alpha: 0.15),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: LinearGradient(
                                  colors: [
                                    skill.color,
                                    skill.color.withValues(alpha: 0.6),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: skill.color.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(skill.level * 100).toInt()}%',
              style: TextStyle(
                color: skill.color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: (400 + index * 100).ms,
        ).slideX(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          delay: (400 + index * 100).ms,
        );
  }
}

class _Skill {
  final String name;
  final double level;
  final Color color;

  _Skill(this.name, this.level, this.color);
}

class _Achievement {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  _Achievement(this.value, this.label, this.icon, this.color);
}
