// lib/games/countdown_clicker/countdown_clicker_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class CountdownClickerScreen extends StatefulWidget {
  const CountdownClickerScreen({super.key});
  @override
  State<CountdownClickerScreen> createState() => _CountdownClickerScreenState();
}

class _CountdownClickerScreenState extends State<CountdownClickerScreen> {
  int _counter = 0;
  int _target  = 30;
  int _timeLeft = 10;
  Timer? _timer;
  bool _started = false;
  bool _showResult = false;
  bool _won = false;

  void _start() {
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _tap() {
    HapticFeedback.lightImpact();
    if (!_started) _start();
    if (_timeLeft <= 0) return;
    setState(() => _counter++);
    if (_counter >= _target) _endGame();
  }

  void _endGame() {
    _timer?.cancel();
    final won = _counter >= _target;
    setState(() { _won = won; _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'countdown_clicker', gameName: 'Countdown Clicker',
      score: _counter * 10, timeTakenSeconds: 10, won: won,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          const GameHeader(
            title: 'Countdown Clicker',
          ),
          const Spacer(),
          GameCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tap $_target times in 10 seconds!',
                  style: const TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                Stack(alignment: Alignment.center, children: [
                  SizedBox(width: 120, height: 120,
                    child: CircularProgressIndicator(
                      value: _timeLeft / 10,
                      strokeWidth: 8,
                      backgroundColor: kTextMuted.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timeLeft > 5 ? Colors.green : Colors.red),
                    )),
                  Text('$_timeLeft', style: const TextStyle(
                    color: kDark, fontSize: 40, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 24),
                Text('$_counter / $_target',
                  style: const TextStyle(color: kDark, fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _counter / _target,
                    backgroundColor: kTextMuted.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(kYellow),
                    minHeight: 16)),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _tap,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 3)),
              child: const Center(child: Text('TAP!',
                style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.w900))))),
          const SizedBox(height: 48),
        ]),
        if (_showResult) GameResultOverlay(
          score: _counter * 10, xpEarned: _won ? 120 : 20, won: _won,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _counter=0; _timeLeft=10; _started=false; _showResult=false;
          }),
        ),
      ])),
    ),
  );

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
}
