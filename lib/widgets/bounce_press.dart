// lib/widgets/bounce_press.dart
import 'package:flutter/material.dart';
import '../services/haptics_service.dart';
import '../services/audio_service.dart';

class BouncePressWidget extends StatefulWidget {
  final Widget child;
  final double scaleDownTo;
  final VoidCallback? onTap;
  final bool enableHaptics;

  const BouncePressWidget({
    super.key,
    required this.child,
    this.scaleDownTo = 0.95,
    this.onTap,
    this.enableHaptics = true,
  });

  @override
  State<BouncePressWidget> createState() => _BouncePressWidgetState();
}

class _BouncePressWidgetState extends State<BouncePressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: widget.scaleDownTo).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    _ctrl.forward();
    if (widget.enableHaptics) {
      HapticsService.light();
    }
    AudioService.playSfx('tap');
  }

  void _onPointerUp() {
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onPointerDown(),
      onPointerUp: (_) => _onPointerUp(),
      onPointerCancel: (_) => _onPointerUp(),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: widget.child,
        ),
      ),
    );
  }
}
