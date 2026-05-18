// lib/games/spin_wheel/spin_wheel_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});
  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final List<int> _segments = [10, 50, 20, 100, 30, 5, 40, 200];
  final List<Color> _colors = [
    kYellow,
    kTeal,
    kCoral,
    kBlue,
    kPink,
    const Color(0xFFFF9500),
    const Color(0xFF9B59B6),
    const Color(0xFF1ABC9C),
  ];

  int _targetSegment = 0;
  int _score = 0;
  int _round = 1;
  int _lives = 3;
  bool _isSpinning = false;
  bool _showResult = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );
    _newRound();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _newRound() {
    setState(() {
      _targetSegment = _rng.nextInt(_segments.length);
      _message = null;
    });
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() => _isSpinning = true);

    // Random final position
    final landedSegment = _rng.nextInt(_segments.length);
    final extraSpins = 3 + _rng.nextDouble() * 2;
    final targetAngle = (extraSpins * 2 * pi) +
        (landedSegment * 2 * pi / _segments.length) +
        (pi / _segments.length);

    _spinAnimation = Tween<double>(
      begin: 0,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.forward(from: 0).then((_) {
      final correct = landedSegment == _targetSegment;
      setState(() {
        _isSpinning = false;
        if (correct) {
          _score += _segments[landedSegment];
          _message = '🎉 Perfect! +${_segments[landedSegment]}';
          _round++;
          if (_round > 10) {
            _endGame();
            return;
          }
        } else {
          _lives--;
          _message = '❌ Wrong! Lost a life';
          if (_lives <= 0) {
            _endGame();
            return;
          }
        }
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !_showResult) _newRound();
      });
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'spin_wheel',
      gameName: 'Spin Wheel',
      score: _score,
      timeTakenSeconds: _round * 5,
      won: _round > 10,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: kGameGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameHeader(
                      title: 'Spin Wheel',
                      actions: [
                        LivesRow(lives: _lives, total: 3),
                        const SizedBox(width: 8),
                        ScoreBadge(score: _score),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Round indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: kDark,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [kGameShadow],
                      ),
                      child: Text('Round $_round / 10',
                          style: const TextStyle(
                              color: kYellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                    ),

                    const Spacer(),

                    // Target instruction
                    GameCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Stop the wheel on:',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: kTextMuted,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: _colors[_targetSegment],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [kGameShadow],
                            ),
                            child: Text('${_segments[_targetSegment]}',
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Wheel
                    AnimatedBuilder(
                      animation: _spinAnimation,
                      builder: (context, child) => Transform.rotate(
                        angle: _spinAnimation.value,
                        child: child,
                      ),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10)),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _WheelPainter(_segments, _colors),
                        ),
                      ),
                    ),

                    // Pointer
                    Transform.translate(
                      offset: const Offset(0, -150),
                      child: Icon(Icons.arrow_drop_down_rounded,
                          size: 48, color: kDark.withOpacity(0.8)),
                    ),

                    const Spacer(),

                    // Message
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(_message!,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _message!.contains('Perfect')
                                    ? kTeal
                                    : kCoral)),
                      ),

                    const SizedBox(height: 16),

                    // Spin button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: YellowButton(
                        label: _isSpinning ? 'Spinning...' : 'SPIN!',
                        onTap: _isSpinning ? () {} : _spin,
                        icon: Icons.refresh_rounded,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
                if (_showResult)
                  GameResultOverlay(
                    score: _score,
                    xpEarned: _round > 10 ? 120 : 20,
                    won: _round > 10,
                    onContinue: () => Navigator.pop(context),
                    onRetry: () => setState(() {
                      _score = 0;
                      _round = 1;
                      _lives = 3;
                      _showResult = false;
                      _newRound();
                    }),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _WheelPainter extends CustomPainter {
  final List<int> segments;
  final List<Color> colors;

  _WheelPainter(this.segments, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final startAngle = i * segmentAngle - pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${segments[i]}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Draw center circle
    canvas.drawCircle(
      center,
      30,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      20,
      Paint()..color = kDark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
