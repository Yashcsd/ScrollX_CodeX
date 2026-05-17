// lib/games/simon_says/simon_says_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SimonSaysScreen extends StatefulWidget {
  const SimonSaysScreen({super.key});
  @override
  State<SimonSaysScreen> createState() => _SimonSaysScreenState();
}

class _SimonSaysScreenState extends State<SimonSaysScreen> {
  static const List<Color> _cols = [kTeal, kBlue, kYellow, kPink];
  static const List<String> _labels = ['GREEN', 'BLUE', 'GOLD', 'PINK'];

  final _rng = Random();
  List<int> _sequence = [];
  int _userIdx = 0;
  bool _showing = false;
  bool _gameOver = false;
  bool _showResult = false;
  int _lit = -1;

  @override
  void initState() { super.initState(); _addAndShow(); }

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
        Future.delayed(const Duration(milliseconds: 500), _addAndShow);
      }
    } else {
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
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(gradient: kGameGradient),
        child: Stack(children: [
          SafeArea(
            bottom: false,
            child: Column(children: [
              GameHeader(title: '🎵 Simon Says', actions: [ScoreBadge(score: score)]),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: GameCard(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      const Text('LEVEL', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('$len', style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900)),
                    ]),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: GameCard(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      const Text('PROGRESS', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('$_userIdx / ${_sequence.length}',
                        style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900)),
                    ]),
                  )),
                ]),
              ),
              const SizedBox(height: 16),
              GameCard(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  _showing ? '👀 Watch carefully…' : '🖐 Your turn! Repeat the pattern',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showing ? kBlue : kDark,
                    fontSize: 14, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              // 2×2 colour grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: List.generate(4, (i) => GestureDetector(
                    onTap: () => _tap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: _lit == i ? _cols[i] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _cols[i], width: 3),
                        boxShadow: [BoxShadow(
                          color: _cols[i],
                          blurRadius: 0,
                          offset: Offset(0, _lit == i ? 2 : 5),
                        )],
                      ),
                      child: Center(child: Text(
                        _labels[i],
                        style: TextStyle(
                          color: _lit == i ? Colors.white : _cols[i],
                          fontSize: 15, fontWeight: FontWeight.w800,
                        ),
                      )),
                    ),
                  )),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: OutlineButton(label: 'Restart', icon: Icons.refresh_rounded, onTap: () => setState(() {
                  _sequence = []; _userIdx = 0; _showing = false;
                  _gameOver = false; _showResult = false; _addAndShow();
                })),
              ),
            ]),
          ),
          if (_showResult) GameResultOverlay(
            score: score, xpEarned: len >= 6 ? 120 : 20, won: len >= 6,
            onContinue: () => Navigator.pop(context),
            onRetry: () => setState(() {
              _sequence = []; _userIdx = 0; _showing = false;
              _gameOver = false; _showResult = false; _addAndShow();
            }),
          ),
        ]),
      ),
    );
  }
}
