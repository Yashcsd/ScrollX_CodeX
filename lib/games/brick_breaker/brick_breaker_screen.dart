// lib/games/brick_breaker/brick_breaker_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class BrickBreakerScreen extends StatefulWidget {
  const BrickBreakerScreen({super.key});
  @override
  State<BrickBreakerScreen> createState() => _BrickBreakerScreenState();
}

class _BrickBreakerScreenState extends State<BrickBreakerScreen> {
  double _paddleX = 0.0;
  double _ballX = 0.0;
  double _ballY = 0.5;
  double _ballVelX = 0.03;
  double _ballVelY = -0.03;
  List<Brick> _bricks = [];
  int _score = 0;
  int _lives = 3;
  Timer? _timer;
  bool _gameStarted = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _initBricks();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initBricks() {
    _bricks.clear();
    final colors = [kCoral, kBlue, kTeal, kPink, Colors.orange];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 6; col++) {
        _bricks.add(Brick(
          x: -0.75 + col * 0.3,
          y: -0.8 + row * 0.15,
          color: colors[row % colors.length],
          alive: true,
        ));
      }
    }
  }

  void _startGame() {
    if (_gameStarted) return;
    setState(() => _gameStarted = true);

    _timer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      setState(() {
        // Move ball
        _ballX += _ballVelX;
        _ballY += _ballVelY;

        // Wall collision
        if (_ballX <= -0.95 || _ballX >= 0.95) {
          _ballVelX *= -1;
          _ballX = _ballX.clamp(-0.95, 0.95);
        }
        if (_ballY <= -0.95) {
          _ballVelY *= -1;
          _ballY = -0.95;
        }

        // Paddle collision
        if (_ballY >= 0.82 &&
            _ballY <= 0.88 &&
            (_ballX - _paddleX).abs() < 0.22) {
          _ballVelY = -_ballVelY.abs();
          // Add spin based on where ball hits paddle
          final hitPos = (_ballX - _paddleX) / 0.22;
          _ballVelX = hitPos * 0.04;
        }

        // Bottom boundary - lose life
        if (_ballY > 1.0) {
          _lives--;
          if (_lives <= 0) {
            _endGame();
          } else {
            _ballX = 0.0;
            _ballY = 0.5;
            _ballVelX = 0.03;
            _ballVelY = -0.03;
            _gameStarted = false;
          }
        }

        // Brick collision
        for (var brick in _bricks) {
          if (brick.alive &&
              (_ballX - brick.x).abs() < 0.14 &&
              (_ballY - brick.y).abs() < 0.08) {
            brick.alive = false;
            _ballVelY *= -1;
            _score += 10;
            break;
          }
        }

        // Win condition
        if (_bricks.every((b) => !b.alive)) {
          _endGame();
        }
      });
    });
  }

  void _movePaddle(double dx) {
    setState(() {
      _paddleX = (_paddleX + dx).clamp(-0.8, 0.8);
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'brick_breaker',
      gameName: 'Brick Breaker',
      score: _score,
      timeTakenSeconds: _score ~/ 5,
      won: _bricks.every((b) => !b.alive),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            _movePaddle(details.delta.dx / 200);
            if (!_gameStarted) _startGame();
          },
          child: Container(
            decoration: const BoxDecoration(gradient: kGameGradient),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      GameHeader(
                        title: 'Brick Breaker',
                        actions: [
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
                                // Bricks
                                ..._bricks
                                    .where((b) => b.alive)
                                    .map((brick) => Positioned(
                                          left: width / 2 + brick.x * width / 2 - 25,
                                          top: height / 2 + brick.y * height / 2 - 15,
                                          child: Container(
                                            width: 50,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: brick.color,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                            ),
                                          ),
                                        )),

                                // Ball
                                Positioned(
                                  left: width / 2 + _ballX * width / 2 - 10,
                                  top: height / 2 + _ballY * height / 2 - 10,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: kYellow,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4)),
                                      ],
                                    ),
                                  ),
                                ),

                                // Paddle
                                Positioned(
                                  left: width / 2 + _paddleX * width / 2 - 50,
                                  bottom: 50,
                                  child: Container(
                                    width: 100,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: kDark,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [kGameShadow],
                                    ),
                                  ),
                                ),

                                // Instructions
                                if (!_gameStarted)
                                  Center(
                                    child: GameCard(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text('Swipe to Move!',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: kDark)),
                                          SizedBox(height: 8),
                                          Text('Break all bricks',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: kTextMuted)),
                                        ],
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
                      xpEarned: _bricks.every((b) => !b.alive) ? 120 : 20,
                      won: _bricks.every((b) => !b.alive),
                      onContinue: () => Navigator.pop(context),
                      onRetry: () => setState(() {
                        _paddleX = 0.0;
                        _ballX = 0.0;
                        _ballY = 0.5;
                        _ballVelX = 0.03;
                        _ballVelY = -0.03;
                        _score = 0;
                        _lives = 3;
                        _gameStarted = false;
                        _showResult = false;
                        _initBricks();
                      }),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class Brick {
  double x, y;
  Color color;
  bool alive;
  Brick(
      {required this.x,
      required this.y,
      required this.color,
      this.alive = true});
}
