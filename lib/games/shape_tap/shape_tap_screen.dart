// lib/games/shape_tap/shape_tap_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class ShapeTapScreen extends StatefulWidget {
  const ShapeTapScreen({super.key});
  @override
  State<ShapeTapScreen> createState() => _ShapeTapScreenState();
}

class _Shape {
  double x, y;
  String type; // 'circle','square','triangle','star'
  Color color;
  bool tapped;
  _Shape({
    required this.x,
    required this.y,
    required this.type,
    required this.color,
    this.tapped = false,
  });
}

class _ShapeTapScreenState extends State<ShapeTapScreen> {
  final _rng = Random();
  static final _tint = kGameTints['shape_tap']!;
  static const _types = ['circle', 'square', 'triangle', 'star'];
  static const _colors = [
    Color(0xFF7F77DD), // accent
    Color(0xFF1D9E75), // teal
    Color(0xFFD85A30), // coral
    Color(0xFFF5C800), // gold
    Color(0xFFD4537E), // pink
  ];

  List<_Shape> _shapes = [];
  String _target = 'circle';
  int _score = 0, _lives = 3, _timeLeft = 45;
  Timer? _gameTimer, _spawnTimer;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _target = _types[_rng.nextInt(_types.length)];
    _start();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) {
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });
    _spawnTimer =
        Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted) return;
      setState(() {
        _shapes.add(_Shape(
          x: _rng.nextDouble() * 0.75 + 0.1,
          y: _rng.nextDouble() * 0.55 + 0.2,
          type: _types[_rng.nextInt(_types.length)],
          color: _colors[_rng.nextInt(_colors.length)],
        ));
        if (_shapes.length > 12) _shapes.removeAt(0);
      });
    });
  }

  void _tap(int idx) {
    final s = _shapes[idx];
    if (s.tapped) return;
    if (s.type == _target) {
      setState(() {
        s.tapped = true;
        _score += 20;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _shapes.remove(s));
      });
    } else {
      setState(() {
        _lives--;
        if (_lives <= 0) _endGame();
      });
    }
    if (_score > 0 && _score % 100 == 0) {
      setState(() => _target = _types[_rng.nextInt(_types.length)]);
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    if (!mounted) return;
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'shape_tap',
      gameName: 'Shape Tap',
      score: _score,
      timeTakenSeconds: 45,
      won: _score >= 120,
    );
  }

  Widget _drawShape(_Shape s, double w, double h) {
    const size = 56.0;
    Widget shape;
    switch (s.type) {
      case 'circle':
        shape = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: s.color,
            boxShadow: [
              BoxShadow(
                color: s.color.withValues(alpha: 0.4),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        );
      case 'square':
        shape = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: s.color,
            boxShadow: [
              BoxShadow(
                color: s.color.withValues(alpha: 0.4),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        );
      case 'triangle':
        shape = CustomPaint(
          size: const Size(size, size),
          painter: _TrianglePainter(s.color),
        );
      default: // star
        shape = Text(
          '⭐',
          style: TextStyle(fontSize: size * 0.8, color: s.color),
        );
    }
    return Positioned(
      left: s.x * w - size / 2,
      top: s.y * h - size / 2,
      child: GestureDetector(
        onTap: () => _tap(_shapes.indexOf(s)),
        child: AnimatedOpacity(
          opacity: s.tapped ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: shape,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _tint.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                GameHeader(
                  title: '🔷 Shape Tap',
                  actions: [
                    TimerBadge(seconds: _timeLeft, total: 45),
                    const SizedBox(width: 8),
                    LivesRow(lives: _lives),
                    const SizedBox(width: 8),
                    ScoreBadge(score: _score),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Target instruction ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GameCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tap all the  ',
                          style: TextStyle(
                            color: kDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _target.toUpperCase(),
                          style: TextStyle(
                            color: _tint.shadow,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          's!',
                          style: TextStyle(
                            color: kDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Shapes on canvas ────────────────────────────────────────
          for (int i = 0; i < _shapes.length; i++)
            _drawShape(_shapes[i], size.width, size.height),

          if (_showResult)
            GameResultOverlay(
              score: _score,
              xpEarned: _score >= 120 ? 120 : 20,
              won: _score >= 120,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _shapes = [];
                _score = 0;
                _lives = 3;
                _timeLeft = 45;
                _showResult = false;
                _target = _types[_rng.nextInt(_types.length)];
                _start();
              }),
            ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_) => false;
}
