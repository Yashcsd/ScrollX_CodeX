// lib/games/flappy_tap/flappy_tap_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class FlappyTapScreen extends StatefulWidget {
  const FlappyTapScreen({super.key});
  @override
  State<FlappyTapScreen> createState() => _FlappyTapScreenState();
}

class _FlappyTapScreenState extends State<FlappyTapScreen> {
  double _birdY = 0.5;
  double _velocity = 0;
  double _gravity = 0.004;
  List<double> _pipes = [];
  double _pipeX = 1.5;
  int _score = 0;
  bool _started = false;
  bool _gameOver = false;
  bool _showResult = false;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _start() {
    _started = true;
    _pipes = [0.3, 0.6];
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) => _update());
  }

  void _tap() {
    if (!_started) { _start(); return; }
    if (_gameOver) return;
    setState(() => _velocity = -0.08);
  }

  void _update() {
    if (!mounted || _gameOver) return;
    setState(() {
      _velocity += _gravity;
      _birdY += _velocity;
      _pipeX -= 0.015;

      // Reset pipe
      if (_pipeX < -0.3) {
        _pipeX = 1.5;
        _pipes = [Random().nextDouble() * 0.4 + 0.2, Random().nextDouble() * 0.4 + 0.2];
        _score++;
      }

      // Check collision
      if (_birdY < 0 || _birdY > 0.9) _end();
      if (_pipeX > 0.4 && _pipeX < 0.6) {
        if (_birdY < _pipes[0] || _birdY > 1 - _pipes[1]) _end();
      }
    });
  }

  void _end() {
    _timer?.cancel();
    setState(() { _gameOver = true; _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'flappy_tap', gameName: 'Flappy Tap',
      score: _score * 10, timeTakenSeconds: 0, won: _score >= 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: _tap,
        child: Container(
          decoration: const BoxDecoration(gradient: kGameGradient),
          child: SafeArea(child: Stack(children: [
            GameHeader(title: 'Flappy Tap', actions: [ScoreBadge(score: _score * 10)]),
            
            if (!_started)
              Center(child: GameCard(
                child: Column(mainAxisSize: MainAxisSize.min, children: const [
                  Text('🐦', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text('Tap to Fly!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kDark)),
                  SizedBox(height: 8),
                  Text('Avoid the pipes', style: TextStyle(fontSize: 14, color: kTextMuted)),
                ]),
              )),

            // Bird
            Positioned(
              left: size.width * 0.5 - 20,
              top: size.height * _birdY - 20,
              child: const Text('🐦', style: TextStyle(fontSize: 40)),
            ),

            // Pipes
            if (_started) ...[
              // Top pipe
              Positioned(
                left: size.width * _pipeX,
                top: 0,
                child: Container(
                  width: 60,
                  height: size.height * _pipes[0],
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                ),
              ),
              // Bottom pipe
              Positioned(
                left: size.width * _pipeX,
                bottom: 0,
                child: Container(
                  width: 60,
                  height: size.height * _pipes[1],
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
              ),
            ],

            if (_showResult) GameResultOverlay(
              score: _score * 10, xpEarned: _score >= 10 ? 120 : 20, won: _score >= 10,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _birdY = 0.5; _velocity = 0; _pipeX = 1.5; _score = 0;
                _started = false; _gameOver = false; _showResult = false;
              }),
            ),
          ])),
        ),
      ),
    );
  }
}
