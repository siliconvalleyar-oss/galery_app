import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glassmorphism_widget.dart';

/// Profile editing screen with glassmorphism form fields.
/// Allows editing name, bio, and preferences.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController(text: 'Alex Rivera');
  final _bioController = TextEditingController(
    text: 'Desarrollador apasionado por crear experiencias móviles '
        'impresionantes con Flutter. Especializado en animaciones, '
        'glassmorphism y diseño UI/UX moderno.',
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSave() {
    setState(() => _isSaving = true);

    // Simulate save delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    });
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
                    'Editar Perfil',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(
                        begin: -0.05, end: 0, duration: 300.ms, delay: 100.ms,
                      ),
                ],
              ),

              const SizedBox(height: 32),

              // ─── Avatar Section ─────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Selector de imagen (próximamente)'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'profile-avatar',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                            border: Border.all(
                              color: AppTheme.surface(context),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    delay: 200.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 32),

              // ─── Name Field ─────────────────────────────────
              _buildFieldLabel(context, 'Nombre'),
              const SizedBox(height: 8),
              _buildGlassTextField(
                context,
                controller: _nameController,
                icon: Icons.person_outline,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(
                    begin: 0.05, end: 0, duration: 400.ms, delay: 300.ms,
                  ),

              const SizedBox(height: 20),

              // ─── Bio Field ──────────────────────────────────
              _buildFieldLabel(context, 'Biografía'),
              const SizedBox(height: 8),
              _buildGlassTextField(
                context,
                controller: _bioController,
                icon: Icons.article_outlined,
                maxLines: 4,
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(
                    begin: 0.05, end: 0, duration: 400.ms, delay: 400.ms,
                  ),

              const SizedBox(height: 20),

              // ─── Email Field (disabled) ─────────────────────
              _buildFieldLabel(context, 'Correo electrónico'),
              const SizedBox(height: 8),
              _buildGlassTextField(
                context,
                controller: TextEditingController(text: 'alex@example.com'),
                icon: Icons.email_outlined,
                enabled: false,
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(
                    begin: 0.05, end: 0, duration: 400.ms, delay: 500.ms,
                  ),

              const SizedBox(height: 32),

              // ─── Save Button ────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _onSave,
                  child: GlassCard(
                    width: 200,
                    height: 52,
                    borderRadius: 18,
                    blur: 10,
                    borderWidth: 1.5,
                    padding: const EdgeInsets.all(0),
                    gradientColors: _isSaving
                        ? [
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                          ]
                        : [
                            AppTheme.primaryColor.withValues(alpha: 0.4),
                            AppTheme.secondaryColor.withValues(alpha: 0.2),
                          ],
                    borderGradientColors: [
                      AppTheme.primaryColor.withValues(alpha: 0.5),
                      AppTheme.secondaryColor.withValues(alpha: 0.3),
                    ],
                    child: Center(
                      child: _isSaving
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.textPrimary(context),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check,
                                    color: AppTheme.textPrimary(context),
                                    size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Guardar Cambios',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary(context),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    delay: 600.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.textSecondary(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildGlassTextField(
    BuildContext context, {
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return GlassCard(
      height: maxLines > 1 ? null : 56,
      borderRadius: 16,
      blur: 8,
      borderWidth: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gradientColors: [
        AppTheme.surface(context).withValues(alpha: 0.15),
        AppTheme.surface(context).withValues(alpha: 0.05),
      ],
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(
          color: AppTheme.textPrimary(context),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          icon: Icon(icon,
              color: AppTheme.textSecondary(context), size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
