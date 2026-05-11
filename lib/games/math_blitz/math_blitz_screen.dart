// lib/games/math_blitz/math_blitz_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class MathBlitzScreen extends StatefulWidget {
  const MathBlitzScreen({super.key});
  @override
  State<MathBlitzScreen> createState() => _MathBlitzScreenState();
}

class _MathBlitzScreenState extends State<MathBlitzScreen> {
  final _rng = Random();
  int _a = 0, _b = 0;
  String _op = '+';
  int _correct = 0;
  List<int> _options = [];
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 60;
  bool _gameOver = false;
  bool _showResult = false;
  Timer? _timer;
  String? _feedback; // '✓' or '✗'

  @override
  void initState() { super.initState(); _nextQ(); _startTimer(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _nextQ() {
    final ops = ['+', '-', '×'];
    _op = ops[_rng.nextInt(3)];
    switch (_op) {
      case '+': _a = _rng.nextInt(50)+1; _b = _rng.nextInt(50)+1; _correct = _a+_b;
      case '-': _a = _rng.nextInt(50)+10; _b = _rng.nextInt(_a)+1; _correct = _a-_b;
      default:  _a = _rng.nextInt(12)+1; _b = _rng.nextInt(12)+1; _correct = _a*_b;
    }
    final opts = {_correct};
    while (opts.length < 4) {
      opts.add(_correct + _rng.nextInt(21) - 10);
    }
    _options = opts.toList()..shuffle();
  }

  void _pick(int val) {
    if (_gameOver) return;
    final ok = val == _correct;
    setState(() {
      _feedback = ok ? '✓' : '✗';
      if (ok) { _streak++; _score += 10 + (_streak * 2); }
      else { _streak = 0; }
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() { _feedback = null; _nextQ(); });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() { _gameOver = true; _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'math_blitz', gameName: 'Math Blitz',
      score: _score, timeTakenSeconds: 60, won: _score >= 100,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A2744), Color(0xFF0D4F3C)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          // Header
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Math Blitz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.gold.withOpacity(0.4))),
                child: Text('$_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 14))),
            ])),
          const SizedBox(height: 16),
          // Timer bar
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Streak: $_streak 🔥', style: const TextStyle(color: AppTheme.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('$_timeLeft s', style: TextStyle(
                    color: _timeLeft > 20 ? AppTheme.teal : _timeLeft > 10 ? AppTheme.gold : AppTheme.coral,
                    fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: _timeLeft / 60,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeLeft > 20 ? AppTheme.teal : _timeLeft > 10 ? AppTheme.gold : AppTheme.coral),
                  minHeight: 6)),
            ])),
          const Spacer(),
          // Question
          AnimatedSwitcher(duration: const Duration(milliseconds: 200),
            child: Text('$_a $_op $_b = ?',
              key: ValueKey('$_a$_op$_b'),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white))),
          if (_feedback != null)
            Text(_feedback!, style: TextStyle(
              fontSize: 40, color: _feedback == '✓' ? AppTheme.teal : AppTheme.coral)),
          const Spacer(),
          // Options grid
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(shrinkWrap: true, crossAxisCount: 2,
              mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
              children: _options.map((v) => GestureDetector(
                onTap: () => _pick(v),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24)),
                  child: Center(child: Text('$v',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))))
              )).toList())),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 100 ? 120 : 20,
          won: _score >= 100,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score=0; _streak=0; _timeLeft=60; _gameOver=false; _showResult=false;
            _nextQ(); _startTimer();
          }),
        ),
      ])),
    ),
  );
}
