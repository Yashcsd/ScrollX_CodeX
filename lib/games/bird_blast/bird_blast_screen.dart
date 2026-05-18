// lib/games/bird_blast/bird_blast_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class BirdBlastScreen extends StatefulWidget {
  const BirdBlastScreen({super.key});
  @override
  State<BirdBlastScreen> createState() => _BirdBlastScreenState();
}

class _BirdBlastScreenState extends State<BirdBlastScreen> {
  final _rng = Random();
  double _birdY = 0.0;
  double _birdVelocity = 0.0;
  List<Pipe> _pipes = [];
  int _score = 0;
  int _bestScore = 0;
  Timer? _timer;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _birdY = 0.0;
      _birdVelocity = 0.0;
      _pipes.clear();
      _gameStarted = false;
      _gameOver = false;
    });
  }

  void _startGame() {
    if (_gameStarted) return;
    setState(() => _gameStarted = true);

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_gameOver) return;

      setState(() {
        // Apply gravity
        _birdVelocity += 0.015;
        _birdY += _birdVelocity;

        // Move pipes
        for (var pipe in _pipes) {
          pipe.x -= 0.05;
        }

        // Remove off-screen pipes
        _pipes.removeWhere((pipe) => pipe.x < -0.3);

        // Add new pipes
        if (_pipes.isEmpty || _pipes.last.x < 0.5) {
          final gapY = _rng.nextDouble() * 0.6 - 0.3;
          _pipes.add(Pipe(x: 1.2, gapY: gapY, scored: false));
        }

        // Check collision
        if (_birdY > 0.9 || _birdY < -0.9) {
          _endGame();
          return;
        }

        for (var pipe in _pipes) {
          if ((pipe.x - 0.0).abs() < 0.15) {
            if (_birdY < pipe.gapY - 0.25 || _birdY > pipe.gapY + 0.25) {
              _endGame();
              return;
            }
            if (!pipe.scored) {
              pipe.scored = true;
              _score++;
            }
          }
        }
      });
    });
  }

  void _flap() {
    if (!_gameStarted) {
      _startGame();
    }
    if (!_gameOver) {
      setState(() => _birdVelocity = -0.3);
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gameOver = true;
      if (_score > _bestScore) _bestScore = _score;
      _showResult = true;
    });
    context.read<UserProvider>().recordGameResult(
      gameId: 'bird_blast',
      gameName: 'Bird Blast',
      score: _score * 10,
      timeTakenSeconds: _score * 2,
      won: _score >= 10,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onTap: _flap,
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
                        title: 'Bird Blast',
                        actions: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.orange.withOpacity(0.5)),
                            ),
                            child: Text('Best: $_bestScore',
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
                            // Pipes
                            ..._pipes.map((pipe) {
                              final screenWidth =
                                  MediaQuery.of(context).size.width;
                              final screenHeight =
                                  MediaQuery.of(context).size.height;
                              final pipeX = screenWidth / 2 + pipe.x * 200;

                              return Stack(
                                children: [
                                  // Top pipe
                                  Positioned(
                                    left: pipeX - 30,
                                    top: 0,
                                    child: Container(
                                      width: 60,
                                      height: screenHeight / 2 +
                                          pipe.gapY * 200 -
                                          80,
                                      decoration: BoxDecoration(
                                        color: kTeal,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                  // Bottom pipe
                                  Positioned(
                                    left: pipeX - 30,
                                    bottom: 0,
                                    child: Container(
                                      width: 60,
                                      height: screenHeight / 2 -
                                          pipe.gapY * 200 -
                                          80,
                                      decoration: BoxDecoration(
                                        color: kTeal,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            // Bird
                            Center(
                              child: Transform.translate(
                                offset: Offset(
                                    -50, _birdY * MediaQuery.of(context).size.height / 2),
                                child: Transform.rotate(
                                  angle: _birdVelocity * 0.5,
                                  child: Container(
                                    width: 50,
                                    height: 50,
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
                                      child: Text('🐦',
                                          style: TextStyle(fontSize: 28)),
                                    ),
                                  ),
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
                                      Text('Tap to Fly!',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              color: kDark)),
                                      SizedBox(height: 8),
                                      Text('Avoid the pipes',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: kTextMuted)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_showResult)
                    GameResultOverlay(
                      score: _score * 10,
                      xpEarned: _score >= 10 ? 120 : 20,
                      won: _score >= 10,
                      onContinue: () => Navigator.pop(context),
                      onRetry: () {
                        setState(() {
                          _score = 0;
                          _showResult = false;
                        });
                        _resetGame();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class Pipe {
  double x, gapY;
  bool scored;
  Pipe({required this.x, required this.gapY, this.scored = false});
}
