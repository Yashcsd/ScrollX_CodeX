// lib/games/reflex_master/reflex_master_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class ReflexMasterScreen extends StatefulWidget {
  const ReflexMasterScreen({super.key});
  @override
  State<ReflexMasterScreen> createState() => _ReflexMasterScreenState();
}

class _ReflexMasterScreenState extends State<ReflexMasterScreen> {
  final _rng = Random();
  String _direction = '';
  String _arrow = '';
  int _score = 0;
  int _lives = 3;
  int _timeLeft = 60;
  Timer? _gameTimer;
  Timer? _arrowTimer;
  bool _showResult = false;

  @override
  void initState() { super.initState(); _start(); }
  @override
  void dispose() { _gameTimer?.cancel(); _arrowTimer?.cancel(); super.dispose(); }

  void _start() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) _endGame();
      else setState(() => _timeLeft--);
    });
    _showArrow();
  }

  void _showArrow() {
    final dirs = ['UP', 'DOWN', 'LEFT', 'RIGHT'];
    final arrows = ['⬆️', '⬇️', '⬅️', '➡️'];
    final idx = _rng.nextInt(4);
    setState(() {
      _direction = dirs[idx];
      _arrow = arrows[idx];
    });
    _arrowTimer?.cancel();
    _arrowTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() { _lives--; if (_lives <= 0) _endGame(); else _showArrow(); });
      }
    });
  }

  void _tap(String dir) {
    _arrowTimer?.cancel();
    if (dir == _direction) {
      setState(() { _score += 20; _showArrow(); });
    } else {
      setState(() { _lives--; if (_lives <= 0) _endGame(); else _showArrow(); });
    }
  }

  void _endGame() {
    _gameTimer?.cancel(); _arrowTimer?.cancel();
    if (!mounted) return;
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'reflex_master', gameName: 'Reflex Master',
      score: _score, timeTakenSeconds: 60, won: _score >= 200,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Reflex Master',
            actions: [
              LivesRow(lives: _lives),
              const SizedBox(width: 12),
              ScoreBadge(score: _score),
            ],
          ),
          const Spacer(),
          const Text('Tap the matching direction!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kDark)),
          const SizedBox(height: 40),
          
          GameCard(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_arrow, style: const TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              Text(_direction, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kDark)),
            ]),
          ),

          const Spacer(),
          
          // Direction buttons
          Column(children: [
            _dirButton('⬆️', 'UP'),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _dirButton('⬅️', 'LEFT'),
              const SizedBox(width: 80),
              _dirButton('➡️', 'RIGHT'),
            ]),
            _dirButton('⬇️', 'DOWN'),
          ]),
          
          const SizedBox(height: 20),
          Text('$_timeLeft s', style: TextStyle(
            color: _timeLeft > 20 ? Colors.green : Colors.red,
            fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 200 ? 120 : 20, won: _score >= 200,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score = 0; _lives = 3; _timeLeft = 60; _showResult = false; _start();
          }),
        ),
      ])),
    ),
  );

  Widget _dirButton(String emoji, String dir) => GestureDetector(
    onTap: () => _tap(dir),
    child: Container(
      width: 70, height: 70,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [kGameShadow],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 36))),
    ),
  );
}
