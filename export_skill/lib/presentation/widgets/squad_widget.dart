import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// A "Squad" widget showing a grid of cards with staggered entrance
/// animations and synchronized bounce reactions on touch.
class SquadWidget extends StatefulWidget {
  final int itemCount;
  final double itemHeight;
  final double itemWidth;
  final double spacing;

  const SquadWidget({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 140,
    this.itemWidth = 160,
    this.spacing = 12,
  });

  @override
  State<SquadWidget> createState() => _SquadWidgetState();
}

class _SquadWidgetState extends State<SquadWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnims;
  late AnimationController _staggerController;

  final List<Color> _cardColors = [
    const Color(0xFF6C63FF),
    const Color(0xFFFF6584),
    const Color(0xFF00D9FF),
    const Color(0xFFFFAB40),
    const Color(0xFF00E676),
    const Color(0xFFE040FB),
  ];

  final List<IconData> _cardIcons = [
    Icons.rocket_launch,
    Icons.insights,
    Icons.code,
    Icons.palette,
    Icons.music_note,
    Icons.sports_esports,
  ];

  final List<String> _cardLabels = [
    'Proyectos',
    'Analytics',
    'Desarrollo',
    'Diseño',
    'Música',
    'Gaming',
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controllers = List.generate(widget.itemCount, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _scaleAnims = List.generate(widget.itemCount, (i) {
      return CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.elasticOut,
      );
    });

    // Start stagger animation
    _staggerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Loop the stagger animation
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _staggerController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _staggerController.forward();
          }
        });
      }
    });
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTapCard(int index) {
    // Trigger the bounce animation for the tapped card
    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });

    // Trigger a synchronized wave on other cards
    for (int i = 0; i < widget.itemCount; i++) {
      if (i != index) {
        Future.delayed(
            Duration(milliseconds: 50 * (i < index ? index - i : i - index)),
            () {
          if (mounted) {
            _controllers[i].forward().then((_) {
              _controllers[i].reverse();
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Wrap(
          spacing: widget.spacing,
          runSpacing: widget.spacing,
          children: List.generate(widget.itemCount, (index) {
            final delay = index * 0.15;
            final staggerValue = ((_staggerController.value - delay) / 0.6)
                .clamp(0.0, 1.0);
            final opacity = staggerValue;
            final translateY = (1 - staggerValue) * 40;
            final staggerScale = 0.5 + staggerValue * 0.5;

            return GestureDetector(
              onTap: () => _onTapCard(index),
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Opacity(
                  opacity: opacity,
                  child: ScaleTransition(
                    scale: _scaleAnims[index],
                    child: Transform.scale(
                      scale: staggerScale,
                      child: _buildCard(index),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCard(int index) {
    final colorIndex = index % _cardColors.length;
    final color = _cardColors[colorIndex];

    return Container(
      width: widget.itemWidth,
      height: widget.itemHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Frosted glass blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
            // Gradient tint overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _cardIcons[index % _cardIcons.length],
                  color: color,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  _cardLabels[index % _cardLabels.length],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(index + 1) * 3} items',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

