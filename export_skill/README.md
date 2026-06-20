# Liquid Glass — Export Skill

Backup de todos los archivos necesarios para recrear la app `liquid_glass_app`.

## Estructura

```
export_skill/
├── README.md                  # Este archivo
├── pubspec.yaml               # Dependencias + configuración
├── analysis_options.yaml      # Lints
├── VERSION                    # Version actual
├── build_and_install.sh       # Build + ADB install script
├── bump_version.sh            # Versionado semántico automático
├── skills/
│   ├── deploy-to-mobile.md    # Skill: build + install en móvil
│   └── ocr-image.md           # Skill: OCR a imágenes
├── scripts/
│   └── ocr.sh                 # Script OCR con tesseract
├── assets/
│   └── icon.svg               # App icon SVG
├── lib/
│   ├── main.dart              # Entry point + ProviderScope + MaterialApp.router
│   ├── core/theme/
│   │   └── app_theme.dart     # Colores, gradientes, light/dark ThemeData
│   ├── data/repositories/
│   │   └── preferences_repository_impl.dart  # SharedPrefs impl
│   ├── domain/
│   │   ├── models/
│   │   │   └── notification_item.dart        # NotificationItem model
│   │   └── repositories/
│   │       └── preferences_repository.dart    # Abstract repo interface
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── navigation_provider.dart      # Unread count provider
│   │   │   ├── theme_overlay_provider.dart    # Theme transition overlay state
│   │   │   └── theme_provider.dart            # ThemeMode + SharedPrefs persistence
│   │   ├── router/
│   │   │   └── app_router.dart               # GoRouter + rutas + transiciones
│   │   ├── screens/
│   │   │   ├── home_screen.dart              # Home con glassmorphism, LiquidBar, carousel, squad
│   │   │   ├── notifications_screen.dart     # Notificaciones con badges + dismiss
│   │   │   ├── notification_detail_screen.dart # Detalle con Hero + acciones
│   │   │   ├── onboarding_screen.dart        # LiquidSwipe onboarding (3 páginas)
│   │   │   ├── profile_screen.dart           # Perfil + achievements + skill bars
│   │   │   ├── profile_edit_screen.dart       # Editar perfil con formulario glass
│   │   │   └── shell_screen.dart             # Shell con LiquidGlassBottomBar
│   │   └── widgets/
│   │       ├── glassmorphism_widget.dart      # GlassCard + GlassButton reutilizables
│   │       ├── liquid_bar.dart                # Barra de progreso con ola animada
│   │       ├── liquid_glass_bottom_bar.dart   # Bottom nav con glassmorphism + badges
│   │       ├── squad_widget.dart              # Grid animado de tarjetas squad
│   │       └── theme_transition_overlay.dart  # Overlay de reveal radial al cambiar tema
└── test/
    ├── unit/
    │   └── notification_item_test.dart        # Unit tests: NotificationItem model
    └── widgets/
        ├── glassmorphism_widget_test.dart     # 15 tests: GlassCard + GlassButton
        ├── home_screen_test.dart             # 19 tests: HomeScreen
        ├── liquid_bar_test.dart              # 10 tests: LiquidBar
        ├── notification_detail_screen_test.dart # Tests: NotificationDetailScreen
        ├── onboarding_screen_test.dart       # Tests: OnboardingScreen
        ├── profile_edit_screen_test.dart      # Tests: ProfileEditScreen
        ├── shell_screen_test.dart            # Tests: LiquidGlassBottomBar
        └── squad_widget_test.dart            # 12 tests: SquadWidget
```

## Cómo recrear la app

```bash
flutter create --project-name liquid_glass_app .
# Copiar archivos de export_skill/ al proyecto
cp -r export_skill/lib .
cp export_skill/pubspec.yaml .
cp export_skill/analysis_options.yaml .
# etc.

flutter pub get
flutter build apk --debug
```

## App características

| Característica | Tecnología |
|---|---|
| Estado global | Riverpod 3.x (NotifierProvider + Provider) |
| Navegación | GoRouter + StatefulShellRoute + transiciones personalizadas |
| Onboarding | LiquidSwipe con efecto ola + smooth_page_indicator |
| Efecto glass | BackdropFilter con ImageFilter.blur + gradientes |
| Barra progreso | LiquidBar: CustomPaint con animación sinusoidal |
| Squad animado | Tarjetas con entrada escalonada + rebote sincronizado |
| Bottom nav | LiquidGlassBottomBar con badges animados + glassmorphism |
| Tema | Dark/Light/System con persistencia en SharedPreferences |
| Transición tema | Radial reveal (ClipPath) animado |
| Notificaciones | Badges, dismiss, mark all read, random generation |
| Tests | 111 tests (widget + unit) |
