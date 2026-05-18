// lib/games/quick_math/quick_math_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class QuickMathScreen extends StatefulWidget {
  const QuickMathScreen({super.key});
  @override
  State<QuickMathScreen> createState() => _QuickMathScreenState();
}

class _QuickMathScreenState extends State<QuickMathScreen> {
  final _rng = Random();
  late String _question;
  late int _answer;
  late List<int> _options;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 60;
  Timer? _timer;
  bool _showResult = false;
  String? _flash;

  @override
  void initState() { super.initState(); _newQuestion(); _startTimer(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _newQuestion() {
    final a = _rng.nextInt(20) + 1;
    final b = _rng.nextInt(20) + 1;
    final op = _rng.nextInt(4);
    
    switch (op) {
      case 0: // Addition
        _question = '$a + $b';
        _answer = a + b;
      case 1: // Subtraction
        if (a > b) {
          _question = '$a - $b';
          _answer = a - b;
        } else {
          _question = '$b - $a';
          _answer = b - a;
        }
      case 2: // Multiplication
        final x = _rng.nextInt(12) + 1;
        final y = _rng.nextInt(12) + 1;
        _question = '$x × $y';
        _answer = x * y;
      default: // Division
        final divisor = _rng.nextInt(10) + 2;
        final quotient = _rng.nextInt(10) + 1;
        _question = '${divisor * quotient} ÷ $divisor';
        _answer = quotient;
    }

    _options = [_answer];
    while (_options.length < 4) {
      final wrong = _answer + _rng.nextInt(21) - 10;
      if (wrong > 0 && !_options.contains(wrong)) _options.add(wrong);
    }
    _options.shuffle();
    _flash = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _pick(int val) {
    final correct = val == _answer;
    setState(() {
      _flash = correct ? '✓' : '✗';
      if (correct) {
        _score += 10 + (_streak * 2);
        _streak++;
      } else {
        _streak = 0;
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _newQuestion());
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'quick_math', gameName: 'Quick Math',
      score: _score, timeTakenSeconds: 60, won: _score >= 250,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Quick Math',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text('🔥 $_streak', style: const TextStyle(
                  color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const Spacer(),
          
          GameCard(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Solve it!', style: TextStyle(fontSize: 14, color: kTextMuted)),
              const SizedBox(height: 16),
              Text(_question, style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.w900, color: kDark)),
              const SizedBox(height: 16),
              if (_flash != null)
                Text(_flash!, style: TextStyle(
                  color: _flash == '✓' ? Colors.green : Colors.red,
                  fontSize: 32, fontWeight: FontWeight.w900)),
            ]),
          ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
              children: _options.map((val) => GestureDetector(
                onTap: () => _pick(val),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [kGameShadow],
                  ),
                  child: Center(child: Text('$val',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kDark))),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text('$_timeLeft s', style: TextStyle(
            color: _timeLeft > 20 ? Colors.green : Colors.red,
            fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 250 ? 120 : 20, won: _score >= 250,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score = 0; _streak = 0; _timeLeft = 60; _showResult = false; _newQuestion(); _startTimer();
          }),
        ),
      ])),
    ),
  );
}
