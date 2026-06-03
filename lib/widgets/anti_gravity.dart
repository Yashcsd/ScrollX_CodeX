// lib/widgets/anti_gravity.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AntiGravityWidget extends StatefulWidget {
  final Widget child;
  final double driftPixels;
  final int? durationMs;
  final bool horizontal;

  const AntiGravityWidget({
    super.key,
    required this.child,
    this.driftPixels = 2.0,
    this.durationMs,
    this.horizontal = false,
  });

  @override
  State<AntiGravityWidget> createState() => _AntiGravityWidgetState();
}

class _AntiGravityWidgetState extends State<AntiGravityWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final double _randomPhase;

  @override
  void initState() {
    super.initState();
    // Add a random phase and duration offset so widgets drift asynchronously
    final rand = math.Random();
    _randomPhase = rand.nextDouble() * math.pi * 2;
    final dur = widget.durationMs ?? (2800 + rand.nextInt(1200));

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: dur),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        // Use a clean sine wave to create a smooth, continuous float loop
        final angle = (_ctrl.value * math.pi * 2) + _randomPhase;
        final offsetValue = math.sin(angle) * widget.driftPixels;
        final offset = widget.horizontal
            ? Offset(offsetValue, 0)
            : Offset(0, offsetValue);
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
