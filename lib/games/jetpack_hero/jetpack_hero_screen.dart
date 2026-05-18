// lib/games/jetpack_hero/jetpack_hero_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class JetpackHeroScreen extends StatefulWidget {
  const JetpackHeroScreen({super.key});
  @override
  State<JetpackHeroScreen> createState() => _JetpackHeroScreenState();
}

class _JetpackHeroScreenState extends State<JetpackHeroScreen> {
  final _rng = Random();
  double _playerY = 0.0;
  double _velocityY = 0.0;
  bool _jetpackOn = false;
  List<Laser> _lasers = [];
  List<Coin> _coins = [];
  int _score = 0;
  int _distance = 0;
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
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_gameOver) return;

      setState(() {
        // Apply jetpack or gravity
        if (_jetpackOn) {
          _velocityY -= 0.015;
        } else {
          _velocityY += 0.012;
        }

        _velocityY = _velocityY.clamp(-0.25, 0.25);
        _playerY += _velocityY;
        _playerY = _playerY.clamp(-0.85, 0.85);

        // Move obstacles
        for (var laser in _lasers) {
          laser.x -= 0.03;
        }
        for (var coin in _coins) {
          coin.x -= 0.03;
        }

        // Remove off-screen items
        _lasers.removeWhere((laser) => laser.x < -1.2);
        _coins.removeWhere((coin) => coin.x < -1.2);

        // Spawn lasers
        if (_lasers.isEmpty || _lasers.last.x < 0.6) {
          final isTop = _rng.nextBool();
          _lasers.add(Laser(
            x: 1.2,
            y: isTop ? -0.5 : 0.5,
            isTop: isTop,
          ));
        }

        // Spawn coins
        if (_coins.length < 3 && _rng.nextDouble() < 0.05) {
          _coins.add(Coin(
            x: 1.2,
            y: _rng.nextDouble() * 1.2 - 0.6,
          ));
        }

        // Check laser collision
        for (var laser in _lasers) {
          if ((laser.x - (-0.5)).abs() < 0.2) {
            if (laser.isTop && _playerY < -0.3) {
              _gameOver = true;
              _endGame();
              return;
            }
            if (!laser.isTop && _playerY > 0.3) {
              _gameOver = true;
              _endGame();
              return;
            }
          }
        }

        // Collect coins
        for (var coin in List.from(_coins)) {
          if ((coin.x - (-0.5)).abs() < 0.15 &&
              (_playerY - coin.y).abs() < 0.15) {
            _coins.remove(coin);
            _score += 10;
          }
        }

        // Update distance
        _distance++;
        if (_distance % 100 == 0) {
          _score += 20;
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'jetpack_hero',
      gameName: 'Jetpack Hero',
      score: _score,
      timeTakenSeconds: _distance ~/ 30,
      won: _score >= 500,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onTapDown: (_) => setState(() => _jetpackOn = true),
          onTapUp: (_) => setState(() => _jetpackOn = false),
          onTapCancel: () => setState(() => _jetpackOn = false),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      GameHeader(
                        title: 'Jetpack Hero',
                        actions: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: kBlue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: kBlue.withOpacity(0.6)),
                            ),
                            child: Text('${_distance}m',
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
                                // Stars background
                                ...List.generate(
                                    30,
                                    (i) => Positioned(
                                          left: _rng.nextDouble() * width,
                                          top: _rng.nextDouble() * height,
                                          child: Container(
                                            width: 2,
                                            height: 2,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )),

                                // Lasers
                                ..._lasers.map((laser) {
                                  final laserX =
                                      width / 2 + laser.x * width / 2;
                                  return Positioned(
                                    left: laserX - 5,
                                    top: laser.isTop ? 0 : null,
                                    bottom: laser.isTop ? null : 0,
                                    child: Container(
                                      width: 10,
                                      height: height * 0.3,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: laser.isTop
                                              ? Alignment.topCenter
                                              : Alignment.bottomCenter,
                                          end: laser.isTop
                                              ? Alignment.bottomCenter
                                              : Alignment.topCenter,
                                          colors: [
                                            kCoral,
                                            kCoral.withOpacity(0.3),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                              color: kCoral.withOpacity(0.5),
                                              blurRadius: 15,
                                              spreadRadius: 3),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                // Coins
                                ..._coins.map((coin) {
                                  final coinX = width / 2 + coin.x * width / 2;
                                  final coinY =
                                      height / 2 + coin.y * height / 2;
                                  return Positioned(
                                    left: coinX - 15,
                                    top: coinY - 15,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: kYellow,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: kYellow.withOpacity(0.6),
                                              blurRadius: 10,
                                              spreadRadius: 2),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text('💰',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  );
                                }),

                                // Player
                                Positioned(
                                  left: width * 0.2,
                                  top: height / 2 + _playerY * height / 2 - 25,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: kYellow,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color: _jetpackOn
                                                ? Colors.orange
                                                    .withOpacity(0.8)
                                                : Colors.black
                                                    .withOpacity(0.3),
                                            blurRadius: _jetpackOn ? 20 : 10,
                                            spreadRadius: _jetpackOn ? 5 : 0,
                                            offset: const Offset(0, 5)),
                                      ],
                                    ),
                                    child: const Icon(Icons.rocket_launch,
                                        color: kDark, size: 28),
                                  ),
                                ),

                                // Instructions
                                if (_distance < 50)
                                  const Center(
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        'Hold to Fly Up\nRelease to Fall',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
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
                      xpEarned: _score >= 500 ? 120 : 20,
                      won: _score >= 500,
                      onContinue: () => Navigator.pop(context),
                      onRetry: () => setState(() {
                        _playerY = 0.0;
                        _velocityY = 0.0;
                        _jetpackOn = false;
                        _lasers.clear();
                        _coins.clear();
                        _score = 0;
                        _distance = 0;
                        _gameOver = false;
                        _showResult = false;
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

class Laser {
  double x;
  double y;
  bool isTop;
  Laser({required this.x, required this.y, required this.isTop});
}

class Coin {
  double x, y;
  Coin({required this.x, required this.y});
}
