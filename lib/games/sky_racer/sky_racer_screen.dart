// lib/games/sky_racer/sky_racer_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SkyRacerScreen extends StatefulWidget {
  const SkyRacerScreen({super.key});
  @override
  State<SkyRacerScreen> createState() => _SkyRacerScreenState();
}

class _SkyRacerScreenState extends State<SkyRacerScreen> {
  final _rng = Random();
  double _carX = 0.0; // -1 to 1
  List<Obstacle> _obstacles = [];
  int _score = 0;
  int _distance = 0;
  double _speed = 3.0;
  Timer? _timer;
  bool _gameOver = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_gameOver) return;

      setState(() {
        // Move obstacles down (normalized speed)
        for (var obs in _obstacles) {
          obs.y += 0.015;
        }

        // Remove off-screen obstacles and award points
        final removed = _obstacles.where((obs) => obs.y > 1.0).toList();
        for (var obs in removed) {
          _score += 10;
        }
        _obstacles.removeWhere((obs) => obs.y > 1.0);

        // Add new obstacles
        if (_obstacles.isEmpty || _obstacles.last.y > 0.2) {
          final lane = _rng.nextInt(3) - 1; // -1, 0, 1
          _obstacles.add(Obstacle(x: lane.toDouble(), y: -0.1));
        }

        // Check collision (player is at bottom)
        for (var obs in _obstacles) {
          if (obs.y > 0.75 && obs.y < 0.85 && (obs.x - _carX).abs() < 0.3) {
            _gameOver = true;
            _endGame();
            return;
          }
        }

        // Update distance
        _distance++;
        if (_distance % 50 == 0) {
          _score += 5;
        }
      });
    });
  }

  void _moveCar(double direction) {
    if (_gameOver) return;
    setState(() {
      _carX = (_carX + direction).clamp(-1.0, 1.0);
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'sky_racer',
      gameName: 'Sky Racer',
      score: _score,
      timeTakenSeconds: _distance ~/ 50,
      won: _score >= 500,
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
                      title: 'Sky Racer',
                      actions: [ScoreBadge(score: _score)],
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          // Road
                          Center(
                            child: Container(
                              width: 280,
                              decoration: BoxDecoration(
                                color: kDark.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomPaint(
                                painter: _RoadPainter(_distance),
                              ),
                            ),
                          ),

                          // Obstacles
                          ..._obstacles.map((obs) => Positioned(
                                left: MediaQuery.of(context).size.width / 2 +
                                    obs.x * 80 -
                                    20,
                                top: MediaQuery.of(context).size.height *
                                        obs.y -
                                    20,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: kCoral,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [kGameShadow],
                                  ),
                                  child: const Icon(Icons.warning_rounded,
                                      color: Colors.white, size: 24),
                                ),
                              )),

                          // Player car
                          Positioned(
                            left: MediaQuery.of(context).size.width / 2 +
                                _carX * 80 -
                                25,
                            bottom: 100,
                            child: Container(
                              width: 50,
                              height: 70,
                              decoration: BoxDecoration(
                                color: kYellow,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5)),
                                ],
                              ),
                              child: const Icon(Icons.directions_car_rounded,
                                  color: kDark, size: 32),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _controlButton(Icons.arrow_back_rounded, -1),
                          _controlButton(Icons.arrow_forward_rounded, 1),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_showResult)
                  GameResultOverlay(
                    score: _score,
                    xpEarned: _score >= 500 ? 120 : 20,
                    won: _score >= 500,
                    onContinue: () => Navigator.pop(context),
                    onRetry: () => setState(() {
                      _carX = 0.0;
                      _obstacles.clear();
                      _score = 0;
                      _distance = 0;
                      _speed = 3.0;
                      _gameOver = false;
                      _showResult = false;
                      _startGame();
                    }),
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _controlButton(IconData icon, double direction) => GestureDetector(
        onTap: () => _moveCar(direction),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: kYellow,
            shape: BoxShape.circle,
            boxShadow: [
              const BoxShadow(
                  color: kYellowDark, blurRadius: 0, offset: Offset(0, 5)),
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Icon(icon, color: kDark, size: 36),
        ),
      );
}

class Obstacle {
  double x, y;
  Obstacle({required this.x, required this.y});
}

class _RoadPainter extends CustomPainter {
  final int distance;
  _RoadPainter(this.distance);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 3;

    final offset = (distance % 40).toDouble();
    for (double y = -offset; y < size.height; y += 40) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + 20),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
