// lib/games/simon_says/simon_says_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SimonSaysScreen extends StatefulWidget {
  const SimonSaysScreen({super.key});
  @override
  State<SimonSaysScreen> createState() => _SimonSaysScreenState();
}

class _SimonSaysScreenState extends State<SimonSaysScreen> {
  static const List<Color> _cols = [
    Color(0xFF1D9E75), Color(0xFF378ADD), Color(0xFFEF9F27), Color(0xFFD4537E),
  ];
  static const List<String> _labels = ['GREEN','BLUE','GOLD','PINK'];

  final _rng = Random();
  List<int> _sequence = [];
  int _userIdx = 0;
  bool _showing = false;
  bool _gameOver = false;
  bool _showResult = false;
  int _lit = -1;

  @override
  void initState() { super.initState(); _addAndShow(); }
  @override
  void dispose() { super.dispose(); }

  void _addAndShow() {
    _sequence.add(_rng.nextInt(4));
    _userIdx = 0;
    _showSequence();
  }

  Future<void> _showSequence() async {
    setState(() => _showing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    for (final idx in _sequence) {
      setState(() => _lit = idx);
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _lit = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    setState(() { _showing = false; _lit = -1; });
  }

  void _tap(int idx) {
    if (_showing || _gameOver) return;
    HapticFeedback.selectionClick();
    setState(() => _lit = idx);
    Future.delayed(const Duration(milliseconds: 200), () => setState(() => _lit = -1));

    if (idx == _sequence[_userIdx]) {
      _userIdx++;
      if (_userIdx == _sequence.length) {
        // Correct full sequence
        Future.delayed(const Duration(milliseconds: 500), _addAndShow);
      }
    } else {
      // Wrong
      _endGame();
    }
  }

  void _endGame() {
    final score = (_sequence.length - 1) * 50;
    setState(() { _gameOver = true; _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'simon_says', gameName: 'Simon Says',
      score: score, timeTakenSeconds: 0, won: _sequence.length >= 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    final len = _sequence.length;
    final score = (len - 1).clamp(0, 999) * 50;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kGameGradient),
        child: SafeArea(child: Stack(children: [
          Column(children: [
            GameHeader(
              title: 'Simon Says',
              actions: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kYellow.withOpacity(0.3)),
                  ),
                  child: Text('Level $len', style: const TextStyle(color: kDark, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                ScoreBadge(score: score),
              ],
            ),
            const Spacer(),
            GameCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_showing ? 'Watch carefully…' : 'Your turn! Repeat the pattern',
                    style: TextStyle(color: _showing ? kYellow : kDark,
                      fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('${_userIdx}/${_sequence.length} correct',
                    style: const TextStyle(color: kTextMuted, fontSize: 12)),
                  const SizedBox(height: 24),
                  // 2x2 grid of color buttons
                  GridView.count(shrinkWrap: true, crossAxisCount: 2,
                    mainAxisSpacing: 16, crossAxisSpacing: 16,
                    children: List.generate(4, (i) => GestureDetector(
                      onTap: () => _tap(i),
                      child: AnimatedContainer(duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          color: _lit == i ? _cols[i] : _cols[i].withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _cols[i].withOpacity(0.6), width: 2),
                          boxShadow: _lit == i ? [BoxShadow(color: _cols[i].withOpacity(0.6),
                            blurRadius: 20, spreadRadius: 4)] : null,
                        ),
                        child: Center(child: Text(_labels[i],
                          style: TextStyle(color: _lit == i ? Colors.white : _cols[i].withOpacity(0.7),
                            fontSize: 16, fontWeight: FontWeight.w700))))))),
                ],
              ),
            ),
            const Spacer(),
            const SizedBox(height: 40),
          ]),
          if (_showResult) GameResultOverlay(
            score: score, xpEarned: len >= 6 ? 120 : 20,
            won: len >= 6,
            onContinue: () => Navigator.pop(context),
            onRetry: () => setState(() {
              _sequence=[]; _userIdx=0; _showing=false;
              _gameOver=false; _showResult=false; _addAndShow();
            }),
          ),
        ])),
      ),
    );
  }
}
