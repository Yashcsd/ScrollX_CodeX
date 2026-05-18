// lib/games/temple_run/temple_run_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class TempleRunScreen extends StatefulWidget {
  const TempleRunScreen({super.key});
  @override
  State<TempleRunScreen> createState() => _TempleRunScreenState();
}

class _TempleRunScreenState extends State<TempleRunScreen> {
  final _rng = Random();
  int _lane = 1; // 0=left, 1=center, 2=right
  List<Obstacle> _obstacles = [];
  List<Coin> _coins = [];
  int _score = 0;
  int _distance = 0;
  double _speed = 0.05;
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
        // Move obstacles and coins
        for (var obs in _obstacles) {
          obs.y += 0.02;
        }
        for (var coin in _coins) {
          coin.y += 0.02;
        }

        // Remove off-screen items
        _obstacles.removeWhere((obs) => obs.y > 1.2);
        _coins.removeWhere((coin) => coin.y > 1.2);

        // Spawn obstacles
        if (_obstacles.isEmpty || _obstacles.last.y > 0.4) {
          final lane = _rng.nextInt(3);
          _obstacles.add(Obstacle(lane: lane, y: -0.2));
        }

        // Spawn coins
        if (_coins.length < 3 && _rng.nextDouble() < 0.08) {
          final lane = _rng.nextInt(3);
          _coins.add(Coin(lane: lane, y: -0.2));
        }

        // Check obstacle collision
        for (var obs in _obstacles) {
          if (obs.lane == _lane && obs.y > 0.6 && obs.y < 0.8) {
            _gameOver = true;
            _endGame();
            return;
          }
        }

        // Collect coins
        for (var coin in List.from(_coins)) {
          if (coin.lane == _lane && coin.y > 0.6 && coin.y < 0.8) {
            _coins.remove(coin);
            _score += 10;
          }
        }

        // Update distance and score
        _distance++;
        if (_distance % 100 == 0) {
          _score += 50;
        }
      });
    });
  }

  void _changeLane(int direction) {
    setState(() {
      _lane = (_lane + direction).clamp(0, 2);
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'temple_run',
      gameName: 'Temple Run',
      score: _score,
      timeTakenSeconds: _distance ~/ 30,
      won: _score >= 500,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8B4513), Color(0xFF654321)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameHeader(
                      title: 'Temple Run',
                      actions: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.6)),
                          ),
                          child: Text('${_distance}m',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        ScoreBadge(score: _score),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          // Path lanes
                          Center(
                            child: Container(
                              width: 280,
                              decoration: BoxDecoration(
                                color: Colors.brown.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: List.generate(
                                  3,
                                  (i) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(0.2)),
                                          right: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(0.2)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Obstacles
                          ..._obstacles.map((obs) {
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final screenHeight =
                                MediaQuery.of(context).size.height;
                            final laneX = screenWidth / 2 +
                                (obs.lane - 1) * 90 -
                                20;

                            return Positioned(
                              left: laneX,
                              top: screenHeight / 2 + obs.y * screenHeight / 2 - 20,
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
                            );
                          }),

                          // Coins
                          ..._coins.map((coin) {
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final screenHeight =
                                MediaQuery.of(context).size.height;
                            final laneX = screenWidth / 2 +
                                (coin.lane - 1) * 90 -
                                15;

                            return Positioned(
                              left: laneX,
                              top: screenHeight / 2 + coin.y * screenHeight / 2 - 15,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: kYellow,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: kYellow.withOpacity(0.5),
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
                            left: MediaQuery.of(context).size.width / 2 +
                                (_lane - 1) * 90 -
                                25,
                            bottom: 150,
                            child: Container(
                              width: 50,
                              height: 60,
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
                              child: const Icon(Icons.directions_run_rounded,
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
                      _lane = 1;
                      _obstacles.clear();
                      _coins.clear();
                      _score = 0;
                      _distance = 0;
                      _speed = 0.05;
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

  Widget _controlButton(IconData icon, int direction) => GestureDetector(
        onTap: () => _changeLane(direction),
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
  int lane;
  double y;
  Obstacle({required this.lane, required this.y});
}

class Coin {
  int lane;
  double y;
  Coin({required this.lane, required this.y});
}
