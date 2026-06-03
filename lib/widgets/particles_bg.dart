// lib/widgets/particles_bg.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class FloatingParticlesBackground extends StatefulWidget {
  final Widget? child;

  const FloatingParticlesBackground({super.key, this.child});

  @override
  State<FloatingParticlesBackground> createState() =>
      _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState
    extends State<FloatingParticlesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Orb> _orbs = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Define 4 soft background gradient orbs matching ScrollX colors
    _orbs.addAll([
      _Orb(
        x: 0.15,
        y: 0.25,
        radius: 0.35,
        color: AppTheme.teal.withValues(alpha: 0.025),
        angleSpeed: 0.8,
        orbitRadius: 0.08,
      ),
      _Orb(
        x: 0.85,
        y: 0.40,
        radius: 0.40,
        color: AppTheme.coral.withValues(alpha: 0.02),
        angleSpeed: -0.6,
        orbitRadius: 0.10,
      ),
      _Orb(
        x: 0.30,
        y: 0.75,
        radius: 0.45,
        color: AppTheme.primary.withValues(alpha: 0.03),
        angleSpeed: 0.5,
        orbitRadius: 0.06,
      ),
      _Orb(
        x: 0.70,
        y: 0.85,
        radius: 0.38,
        color: AppTheme.pink.withValues(alpha: 0.02),
        angleSpeed: -0.7,
        orbitRadius: 0.09,
      ),
    ]);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _OrbsPainter(
                  orbs: _orbs,
                  progress: _ctrl.value,
                ),
              );
            },
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Orb {
  final double x;
  final double y;
  final double radius;
  final Color color;
  final double angleSpeed;
  final double orbitRadius;

  _Orb({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.angleSpeed,
    required this.orbitRadius,
  });
}

class _OrbsPainter extends CustomPainter {
  final List<_Orb> orbs;
  final double progress;

  _OrbsPainter({required this.orbs, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final orb in orbs) {
      final angle = progress * math.pi * 2 * orb.angleSpeed;
      final dx = orb.x + math.cos(angle) * orb.orbitRadius;
      final dy = orb.y + math.sin(angle) * orb.orbitRadius;

      final center = Offset(dx * size.width, dy * size.height);
      final r = orb.radius * size.width;

      // Draw large blurred orb using simple gradient mask/filter
      paint.color = orb.color;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.45);

      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) => true;
}
