// lib/games/bubble_shooter/bubble_shooter_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class BubbleShooterScreen extends StatefulWidget {
  const BubbleShooterScreen({super.key});
  @override
  State<BubbleShooterScreen> createState() => _BubbleShooterScreenState();
}

class _BubbleShooterScreenState extends State<BubbleShooterScreen> {
  final _rng = Random();
  final List<Color> _colors = [kCoral, kBlue, kTeal, kPink, Colors.orange];
  List<Bubble> _bubbles = [];
  Bubble? _currentBubble;
  Bubble? _nextBubble;
  double _aimAngle = -pi / 2;
  int _score = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _initBubbles();
    _spawnBubble();
  }

  void _initBubbles() {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 7; col++) {
        _bubbles.add(Bubble(
          x: -0.6 + col * 0.2,
          y: -0.8 + row * 0.15,
          color: _colors[_rng.nextInt(_colors.length)],
        ));
      }
    }
  }

  void _spawnBubble() {
    setState(() {
      _currentBubble = _nextBubble ??
          Bubble(
            x: 0.0,
            y: 0.8,
            color: _colors[_rng.nextInt(_colors.length)],
          );
      _nextBubble = Bubble(
        x: 0.0,
        y: 0.8,
        color: _colors[_rng.nextInt(_colors.length)],
      );
    });
  }

  void _shoot() {
    if (_currentBubble == null) return;

    final bubble = _currentBubble!;
    double vx = cos(_aimAngle) * 0.03;
    double vy = sin(_aimAngle) * 0.03;

    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        bubble.x += vx;
        bubble.y += vy;

        // Wall bounce
        if (bubble.x <= -0.9 || bubble.x >= 0.9) vx *= -1;

        // Check collision with other bubbles
        for (var other in _bubbles) {
          if ((bubble.x - other.x).abs() < 0.15 &&
              (bubble.y - other.y).abs() < 0.15) {
            timer.cancel();
            // Snap to grid position near the collision
            _bubbles.add(Bubble(
              x: other.x,
              y: other.y - 0.15,
              color: bubble.color,
            ));
            _checkMatches(bubble.color, other.x, other.y - 0.15);
            _spawnBubble();
            return;
          }
        }

        // Top boundary
        if (bubble.y <= -0.9) {
          timer.cancel();
          _bubbles.add(Bubble(
            x: bubble.x,
            y: -0.9,
            color: bubble.color,
          ));
          _checkMatches(bubble.color, bubble.x, -0.9);
          _spawnBubble();
        }

        // Game over check
        if (_bubbles.any((b) => b.y > 0.7)) {
          timer.cancel();
          _endGame();
        }
      });
    });
  }

  void _checkMatches(Color color, double x, double y) {
    final matches = <Bubble>[];
    final toCheck = <Bubble>[];
    
    // Find the bubble we just added
    for (var bubble in _bubbles) {
      if ((bubble.x - x).abs() < 0.05 && (bubble.y - y).abs() < 0.05 && bubble.color == color) {
        matches.add(bubble);
        toCheck.add(bubble);
        break;
      }
    }

    while (toCheck.isNotEmpty) {
      final current = toCheck.removeLast();
      for (var other in _bubbles) {
        if (!matches.contains(other) &&
            other.color == color &&
            (current.x - other.x).abs() < 0.15 &&
            (current.y - other.y).abs() < 0.15) {
          matches.add(other);
          toCheck.add(other);
        }
      }
    }

    if (matches.length >= 3) {
      setState(() {
        _bubbles.removeWhere((b) => matches.contains(b));
        _score += matches.length * 10;
      });
    }
  }

  void _updateAim(Offset position) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(position);
    final width = box.size.width;
    final height = box.size.height;

    final dx = localPosition.dx - width / 2;
    final dy = localPosition.dy - height * 0.85;

    setState(() {
      _aimAngle = atan2(dy, dx);
      if (_aimAngle > -pi / 6) _aimAngle = -pi / 6;
      if (_aimAngle < -5 * pi / 6) _aimAngle = -5 * pi / 6;
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'bubble_shooter',
      gameName: 'Bubble Shooter',
      score: _score,
      timeTakenSeconds: _score ~/ 5,
      won: _bubbles.isEmpty,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onPanUpdate: (details) => _updateAim(details.globalPosition),
          onTap: _shoot,
          child: Container(
            decoration: const BoxDecoration(gradient: kGameGradient),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      GameHeader(
                        title: 'Bubble Shooter',
                        actions: [ScoreBadge(score: _score)],
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;

                            return Stack(
                              children: [
                                // Bubbles
                                ..._bubbles.map((bubble) => Positioned(
                                      left: width / 2 + bubble.x * width / 2 - 20,
                                      top: height / 2 + bubble.y * height / 2 - 20,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: bubble.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          boxShadow: [kGameShadow],
                                        ),
                                      ),
                                    )),

                                // Current bubble
                                if (_currentBubble != null)
                                  Positioned(
                                    left: width / 2 +
                                        _currentBubble!.x * width / 2 -
                                        20,
                                    top: height * 0.85 - 20,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _currentBubble!.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                              color: _currentBubble!.color
                                                  .withOpacity(0.5),
                                              blurRadius: 15,
                                              spreadRadius: 3),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Aim line
                                CustomPaint(
                                  size: Size(width, height),
                                  painter: _AimPainter(_aimAngle),
                                ),

                                // Next bubble preview
                                if (_nextBubble != null)
                                  Positioned(
                                    right: 20,
                                    bottom: 20,
                                    child: Column(
                                      children: [
                                        const Text('Next',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: kTextMuted,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: _nextBubble!.color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_showResult)
                    GameResultOverlay(
                      score: _score,
                      xpEarned: _bubbles.isEmpty ? 120 : 20,
                      won: _bubbles.isEmpty,
                      onContinue: () => Navigator.pop(context),
                      onRetry: () => setState(() {
                        _bubbles.clear();
                        _score = 0;
                        _showResult = false;
                        _initBubbles();
                        _spawnBubble();
                      }),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class Bubble {
  double x, y;
  Color color;
  Bubble({required this.x, required this.y, required this.color});
}

class _AimPainter extends CustomPainter {
  final double angle;
  _AimPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final startX = size.width / 2;
    final startY = size.height * 0.85;
    final endX = startX + cos(angle) * 100;
    final endY = startY + sin(angle) * 100;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
