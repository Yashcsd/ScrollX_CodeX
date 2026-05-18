// lib/games/color_switch/color_switch_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class ColorSwitchScreen extends StatefulWidget {
  const ColorSwitchScreen({super.key});
  @override
  State<ColorSwitchScreen> createState() => _ColorSwitchScreenState();
}

class _ColorSwitchScreenState extends State<ColorSwitchScreen> {
  final _rng = Random();
  static const _colors = [Colors.red, Colors.blue, Colors.green, kYellow, Colors.purple];
  static const _names = ['RED', 'BLUE', 'GREEN', 'YELLOW', 'PURPLE'];
  
  late Color _topColor;
  late Color _bottomColor;
  int _score = 0;
  int _timeLeft = 45;
  Timer? _timer;
  bool _showResult = false;
  String? _flash;

  @override
  void initState() { super.initState(); _newRound(); _startTimer(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _newRound() {
    _topColor = _colors[_rng.nextInt(_colors.length)];
    _bottomColor = _colors[_rng.nextInt(_colors.length)];
    _flash = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _tap(bool match) {
    final correct = (_topColor == _bottomColor) == match;
    setState(() {
      _flash = correct ? '✓ Correct!' : '✗ Wrong!';
      if (correct) _score += 10;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _newRound());
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'color_switch', gameName: 'Color Switch',
      score: _score, timeTakenSeconds: 45, won: _score >= 150,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Color Switch',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _timeLeft > 20 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _timeLeft > 20 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                ),
                child: Text('$_timeLeft s', style: TextStyle(
                  color: _timeLeft > 20 ? Colors.green : Colors.red,
                  fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const Spacer(),
          const Text('Do the colors match?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDark)),
          const SizedBox(height: 40),
          
          GameCard(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  color: _topColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [kGameShadow],
                ),
              ),
              const SizedBox(height: 20),
              const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kDark)),
              const SizedBox(height: 20),
              Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  color: _bottomColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [kGameShadow],
                ),
              ),
            ]),
          ),

          if (_flash != null) ...[
            const SizedBox(height: 20),
            Text(_flash!, style: TextStyle(
              color: _flash!.contains('✓') ? Colors.green : Colors.red,
              fontSize: 18, fontWeight: FontWeight.w700)),
          ],

          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: YellowButton(
                label: '✓ MATCH',
                onTap: () => _tap(true),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlineButton(
                label: '✗ DIFFERENT',
                onTap: () => _tap(false),
              )),
            ]),
          ),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 150 ? 120 : 20, won: _score >= 150,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score = 0; _timeLeft = 45; _showResult = false; _newRound(); _startTimer();
          }),
        ),
      ])),
    ),
  );
}
