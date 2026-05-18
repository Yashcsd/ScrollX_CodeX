// lib/games/pattern_memory/pattern_memory_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class PatternMemoryScreen extends StatefulWidget {
  const PatternMemoryScreen({super.key});
  @override
  State<PatternMemoryScreen> createState() => _PatternMemoryScreenState();
}

enum _Phase { showing, input, result }

class _PatternMemoryScreenState extends State<PatternMemoryScreen> {
  final _rng = Random();
  static const int _grid = 4; // 4x4
  late Set<int> _pattern;
  Set<int> _userTaps = {};
  _Phase _phase = _Phase.showing;
  int _round = 1;
  int _score = 0;
  bool _showResult = false;

  @override
  void initState() { super.initState(); _newRound(); }

  void _newRound() {
    final count = min(3 + _round, 10); // more cells as rounds progress
    _pattern = {};
    while (_pattern.length < count) _pattern.add(_rng.nextInt(_grid * _grid));
    _userTaps = {};
    _phase = _Phase.showing;
    // Show for (1.5 + 0.3*round) seconds then hide
    Future.delayed(Duration(milliseconds: (1500 + 300 * _round).clamp(1500, 4000)), () {
      setState(() => _phase = _Phase.input);
    });
  }

  void _tap(int idx) {
    if (_phase != _Phase.input) return;
    setState(() {
      if (_userTaps.contains(idx)) _userTaps.remove(idx);
      else _userTaps.add(idx);
    });
  }

  void _confirm() {
    if (_phase != _Phase.input) return;
    final ok = _userTaps.length == _pattern.length &&
        _userTaps.every(_pattern.contains);
    setState(() {
      _phase = _Phase.result;
      if (ok) _score += 50 + _round * 10;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (ok) {
        _round++;
        if (_round > 8) { _endGame(); return; }
        setState(() => _newRound());
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'pattern_memory', gameName: 'Pattern Memory',
      score: _score, timeTakenSeconds: 0, won: _round >= 5,
    );
  }

  int min(int a, int b) => a < b ? a : b;

  Color _cellColor(int idx) {
    if (_phase == _Phase.showing) {
      return _pattern.contains(idx) ? kYellow : Colors.white;
    }
    if (_phase == _Phase.result) {
      if (_pattern.contains(idx) && _userTaps.contains(idx)) return Colors.green;
      if (_pattern.contains(idx)) return Colors.red;
      if (_userTaps.contains(idx)) return Colors.red.withOpacity(0.4);
      return Colors.white;
    }
    return _userTaps.contains(idx) ? kYellow.withOpacity(0.6) : Colors.white;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Pattern Memory',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kYellow.withOpacity(0.3)),
                ),
                child: Text('Round $_round', style: const TextStyle(
                  color: kDark, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _phase == _Phase.showing ? '👀 Memorize the pattern!' :
            _phase == _Phase.input   ? '🖐 Tap the same cells!' :
                                       '✓ Checking…',
            style: const TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          GameCard(
            child: GridView.count(shrinkWrap: true, crossAxisCount: _grid,
              mainAxisSpacing: 8, crossAxisSpacing: 8,
              children: List.generate(_grid * _grid, (i) => GestureDetector(
                onTap: () => _tap(i),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _cellColor(i),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [kGameShadow],
                  ))))),
          ),
          const SizedBox(height: 24),
          if (_phase == _Phase.input)
            YellowButton(
              onTap: _confirm,
              label: 'Confirm Pattern',
            ),
          const Spacer(),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _round >= 5 ? 120 : 20,
          won: _round >= 5,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score=0; _round=1; _showResult=false; _newRound(); }),
        ),
      ])),
    ),
  );
}
