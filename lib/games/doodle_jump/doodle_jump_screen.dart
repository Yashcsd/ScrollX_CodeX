// lib/games/doodle_jump/doodle_jump_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class DoodleJumpScreen extends StatefulWidget {
  const DoodleJumpScreen({super.key});
  @override
  State<DoodleJumpScreen> createState() => _DoodleJumpScreenState();
}

class _DoodleJumpScreenState extends State<DoodleJumpScreen> {
  final _rng = Random();
  double _playerX = 0.0;
  double _playerY = 0.5;
  double _velocityY = 0.0;
  List<Platform> _platforms = [];
  int _score = 0;
  int _highScore = 0;
  Timer? _timer;
  bool _gameOver = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _initPlatforms();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initPlatforms() {
    _platforms.clear();
    for (int i = 0; i < 8; i++) {
      _platforms.add(Platform(
        x: _rng.nextDouble() * 1.6 - 0.8,
        y: 0.8 - i * 0.25,
      ));
    }
  }

  void _startGame() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_gameOver) return;

      setState(() {
        // Apply gravity
        _velocityY += 0.01;
        _playerY += _velocityY;

        // Check platform collision (only when falling)
        if (_velocityY > 0) {
          for (var platform in _platforms) {
            final verticalDist = _playerY - platform.y;
            final horizontalDist = (_playerX - platform.x).abs();
            
            if (verticalDist > -0.05 && verticalDist < 0.05 && horizontalDist < 0.2) {
              _velocityY = -0.3;
              _score += 10;
              break;
            }
          }
        }

        // Move platforms down when player goes up
        if (_playerY < -0.1) {
          final offset = -_playerY - (-0.1);
          _playerY = -0.1;
          for (var platform in _platforms) {
            platform.y += offset;
          }

          // Remove off-screen platforms
          _platforms.removeWhere((p) => p.y > 1.2);

          // Add new platforms
          while (_platforms.length < 8) {
            _platforms.add(Platform(
              x: _rng.nextDouble() * 1.6 - 0.8,
              y: _platforms.isEmpty ? -0.2 : _platforms.first.y - 0.25,
            ));
          }
        }

        // Game over
        if (_playerY > 1.0) {
          _gameOver = true;
          if (_score > _highScore) _highScore = _score;
          _endGame();
        }
      });
    });
  }

  void _tilt(double dx) {
    setState(() {
      _playerX = (_playerX + dx).clamp(-0.9, 0.9);
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'doodle_jump',
      gameName: 'Doodle Jump',
      score: _score,
      timeTakenSeconds: _score ~/ 10,
      won: _score >= 500,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            _tilt(details.delta.dx / 200);
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF87CEEB), Color(0xFFE0F6FF)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      GameHeader(
                        title: 'Doodle Jump',
                        actions: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: kBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBlue.withOpacity(0.5)),
                            ),
                            child: Text('Best: $_highScore',
                                style: const TextStyle(
                                    color: kBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          ScoreBadge(score: _score),
                        ],
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;

                            return Stack(
                              children: [
                                // Platforms
                                ..._platforms.map((platform) => Positioned(
                                      left: width / 2 +
                                          platform.x * width / 2 -
                                          35,
                                      top: height / 2 +
                                          platform.y * height / 2 -
                                          8,
                                      child: Container(
                                        width: 70,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: kTeal,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                      ),
                                    )),

                                // Player
                                Positioned(
                                  left: width / 2 + _playerX * width / 2 - 20,
                                  top: height / 2 + _playerY * height / 2 - 20,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: kYellow,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5)),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text('😊',
                                          style: TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Swipe left/right to move',
                            style: TextStyle(
                                fontSize: 14,
                                color: kDark,
                                fontWeight: FontWeight.w600)),
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
                        _playerX = 0.0;
                        _playerY = 0.5;
                        _velocityY = 0.0;
                        _score = 0;
                        _gameOver = false;
                        _showResult = false;
                        _initPlatforms();
                        _startGame();
                      }),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class Platform {
  double x, y;
  Platform({required this.x, required this.y});
}
