// lib/games/countdown_clicker/countdown_clicker_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF1A0A00), Color(0xFF5C2A00)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Countdown Clicker', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ])),
          const Spacer(),
          Text('Tap $_target times in 10 seconds!',
            style: const TextStyle(color: AppTheme.textSec, fontSize: 15)),
          const SizedBox(height: 20),
          Stack(alignment: Alignment.center, children: [
            SizedBox(width: 120, height: 120,
              child: CircularProgressIndicator(
                value: _timeLeft / 10,
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timeLeft > 5 ? AppTheme.teal : AppTheme.coral),
              )),
            Text('$_timeLeft', style: const TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 20),
          Text('$_counter / $_target',
            style: const TextStyle(color: AppTheme.gold, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _counter / _target,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
              minHeight: 16)),
          const Spacer(),
          GestureDetector(
            onTap: _tap,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: AppTheme.coral.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.coral, width: 3)),
              child: const Center(child: Text('TAP!',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900))))),
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
