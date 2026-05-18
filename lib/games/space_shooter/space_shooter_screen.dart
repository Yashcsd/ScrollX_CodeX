// lib/games/space_shooter/space_shooter_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SpaceShooterScreen extends StatefulWidget {
  const SpaceShooterScreen({super.key});
  @override
  State<SpaceShooterScreen> createState() => _SpaceShooterScreenState();
}

class _SpaceShooterScreenState extends State<SpaceShooterScreen> {
  final _rng = Random();
  double _shipX = 0.0;
  List<Bullet> _bullets = [];
  List<Enemy> _enemies = [];
  int _score = 0;
  int _lives = 3;
  int _wave = 1;
  Timer? _timer;
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
      setState(() {
        // Move bullets
        for (var bullet in _bullets) {
          bullet.y -= 0.025;
        }
        _bullets.removeWhere((b) => b.y < -1.0);

        // Move enemies
        for (var enemy in _enemies) {
          enemy.y += 0.008 + (_wave * 0.001);
        }

        // Remove off-screen enemies and lose life
        final offScreen = _enemies.where((e) => e.y > 1.0).toList();
        for (var _ in offScreen) {
          _lives--;
          if (_lives <= 0) {
            _endGame();
            return;
          }
        }
        _enemies.removeWhere((e) => e.y > 1.0);

        // Add new enemies
        if (_enemies.length < 3 + _wave && _rng.nextDouble() < 0.03) {
          _enemies.add(Enemy(
            x: _rng.nextDouble() * 1.4 - 0.7,
            y: -1.0,
          ));
        }

        // Check bullet-enemy collision
        for (var bullet in List.from(_bullets)) {
          for (var enemy in List.from(_enemies)) {
            if ((bullet.x - enemy.x).abs() < 0.12 &&
                (bullet.y - enemy.y).abs() < 0.12) {
              _bullets.remove(bullet);
              _enemies.remove(enemy);
              _score += 10;
              if (_score % 100 == 0 && _wave < 5) _wave++;
              break;
            }
          }
        }

        // Check ship-enemy collision
        for (var enemy in List.from(_enemies)) {
          if ((enemy.x - _shipX).abs() < 0.15 && enemy.y > 0.65) {
            _lives--;
            _enemies.remove(enemy);
            if (_lives <= 0) {
              _endGame();
              return;
            }
            break;
          }
        }
      });
    });
  }

  void _moveShip(double dx) {
    setState(() {
      _shipX = (_shipX + dx).clamp(-0.8, 0.8);
    });
  }

  void _shoot() {
    setState(() {
      _bullets.add(Bullet(x: _shipX, y: 0.7));
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'space_shooter',
      gameName: 'Space Shooter',
      score: _score,
      timeTakenSeconds: _score ~/ 5,
      won: _score >= 300,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameHeader(
                      title: 'Space Shooter',
                      actions: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: kBlue.withOpacity(0.5)),
                          ),
                          child: Text('Wave $_wave',
                              style: const TextStyle(
                                  color: kBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        LivesRow(lives: _lives, total: 3),
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
                                  20,
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

                              // Enemies
                              ..._enemies.map((enemy) => Positioned(
                                    left: width / 2 + enemy.x * width / 2 - 20,
                                    top: height / 2 + enemy.y * height / 2 - 20,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: kCoral,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                              color: kCoral.withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2),
                                        ],
                                      ),
                                      child: const Icon(Icons.bug_report,
                                          color: Colors.white, size: 24),
                                    ),
                                  )),

                              // Bullets
                              ..._bullets.map((bullet) => Positioned(
                                    left:
                                        width / 2 + bullet.x * width / 2 - 3,
                                    top: height / 2 + bullet.y * height / 2 - 8,
                                    child: Container(
                                      width: 6,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: kYellow,
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                              color: kYellow.withOpacity(0.6),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                        ],
                                      ),
                                    ),
                                  )),

                              // Player ship
                              Positioned(
                                left: width / 2 + _shipX * width / 2 - 25,
                                bottom: 80,
                                child: Container(
                                  width: 50,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: kYellow,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                          color: kYellow.withOpacity(0.5),
                                          blurRadius: 15,
                                          spreadRadius: 3),
                                    ],
                                  ),
                                  child: const Icon(Icons.rocket_launch,
                                      color: kDark, size: 32),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Controls
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _controlButton(
                                  Icons.arrow_back_rounded, () => _moveShip(-0.2)),
                              const SizedBox(width: 12),
                              _controlButton(Icons.arrow_forward_rounded,
                                  () => _moveShip(0.2)),
                            ],
                          ),
                          _controlButton(Icons.circle, _shoot, isShoot: true),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_showResult)
                  GameResultOverlay(
                    score: _score,
                    xpEarned: _score >= 300 ? 120 : 20,
                    won: _score >= 300,
                    onContinue: () => Navigator.pop(context),
                    onRetry: () => setState(() {
                      _shipX = 0.0;
                      _bullets.clear();
                      _enemies.clear();
                      _score = 0;
                      _lives = 3;
                      _wave = 1;
                      _showResult = false;
                      _startGame();
                    }),
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _controlButton(IconData icon, VoidCallback onTap,
          {bool isShoot = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: isShoot ? 70 : 60,
          height: isShoot ? 70 : 60,
          decoration: BoxDecoration(
            color: isShoot ? kCoral : kYellow,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: isShoot ? kCoral.withOpacity(0.5) : kYellowDark,
                  blurRadius: 0,
                  offset: const Offset(0, 4)),
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: isShoot ? 32 : 28),
        ),
      );
}

class Bullet {
  double x, y;
  Bullet({required this.x, required this.y});
}

class Enemy {
  double x, y;
  Enemy({required this.x, required this.y});
}
