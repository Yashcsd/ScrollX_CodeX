// lib/games/math_blitz/math_blitz_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../services/haptics_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/anti_gravity.dart';
import '../../widgets/bounce_press.dart';

class MathBlitzScreen extends StatefulWidget {
  const MathBlitzScreen({super.key});
  @override
  State<MathBlitzScreen> createState() => _MathBlitzScreenState();
}

class _MathBlitzScreenState extends State<MathBlitzScreen> {
  final _rng = Random();
  int _a = 0, _b = 0, _correct = 0, _score = 0, _streak = 0, _timeLeft = 60;
  String _op = '+';
  List<int> _options = [];
  bool _gameOver = false, _showResult = false;
  Timer? _timer;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _nextQ();
    _startTimer();
    AudioService.playMusic('arcade');
  }
  @override
  void dispose() {
    _timer?.cancel();
    AudioService.stopMusic();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 5) {
        HapticsService.timerTick(_timeLeft);
        if (_timeLeft > 0) {
          if (_timeLeft <= 3) {
            AudioService.playSfx('tension_tick');
          } else {
            AudioService.playSfx('tick');
          }
        }
      }
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
    while (opts.length < 4) opts.add(_correct + _rng.nextInt(21) - 10);
    _options = opts.toList()..shuffle();
  }

  void _pick(int val) {
    if (_gameOver) return;
    final ok = val == _correct;
    if (ok) {
      HapticsService.medium();
      AudioService.playSfx('coin');
    } else {
      HapticsService.failureSequence();
      AudioService.playSfx('fail');
    }
    setState(() {
      _feedback = ok ? '✓' : '✗';
      if (ok) { _streak++; _score += 10 + (_streak * 2); }
      else _streak = 0;
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
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: Stack(children: [
        SafeArea(bottom: false, child: Column(children: [
          GameHeader(title: '➕ Math Blitz', actions: [ScoreBadge(score: _score)]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Text('🔥 Streak: ', style: TextStyle(color: kTextSec, fontSize: 13)),
                Text('$_streak', style: const TextStyle(color: kCoral, fontSize: 13, fontWeight: FontWeight.w800)),
              ]),
              TimerBadge(seconds: _timeLeft, total: 60),
            ]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GameProgressBar(value: _timeLeft / 60,
              color: _timeLeft > 20 ? kTeal : _timeLeft > 10 ? kYellow : kCoral),
          ),
          const Spacer(),
          AntiGravityWidget(
            child: GameCard(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text('$_a $_op $_b = ?',
                    key: ValueKey('$_a$_op$_b'),
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: kDark)),
                ),
                if (_feedback != null) ...[
                  const SizedBox(height: 12),
                  Text(_feedback!, style: TextStyle(
                    fontSize: 32, color: _feedback == '✓' ? kTeal : kCoral,
                    fontWeight: FontWeight.w900)),
                ],
              ]),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: GridView.count(
              shrinkWrap: true, crossAxisCount: 2,
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
              children: _options.map((v) => BouncePressWidget(
                onTap: () => _pick(v),
                enableHaptics: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Center(child: Text('$v', style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: kDark))),
                ),
              )).toList(),
            ),
          ),
        ])),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 100 ? 120 : 20, won: _score >= 100,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score=0; _streak=0; _timeLeft=60; _gameOver=false; _showResult=false; _nextQ(); _startTimer();
          }),
        ),
      ]),
    ),
  );
}
