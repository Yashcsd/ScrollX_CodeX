// lib/games/pattern_memory/pattern_memory_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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
      return _pattern.contains(idx) ? AppTheme.accent : Colors.white10;
    }
    if (_phase == _Phase.result) {
      if (_pattern.contains(idx) && _userTaps.contains(idx)) return AppTheme.teal;
      if (_pattern.contains(idx)) return AppTheme.coral;
      if (_userTaps.contains(idx)) return AppTheme.coral.withOpacity(0.4);
      return Colors.white10;
    }
    return _userTaps.contains(idx) ? AppTheme.accent.withOpacity(0.6) : Colors.white10;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF0D1B33), Color(0xFF1A2D55)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Pattern Memory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('Round $_round  $_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            ])),
          const SizedBox(height: 20),
          Text(
            _phase == _Phase.showing ? '👀 Memorize the pattern!' :
            _phase == _Phase.input   ? '🖐 Tap the same cells!' :
                                       '✓ Checking…',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(shrinkWrap: true, crossAxisCount: _grid,
              mainAxisSpacing: 8, crossAxisSpacing: 8,
              children: List.generate(_grid * _grid, (i) => GestureDetector(
                onTap: () => _tap(i),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _cellColor(i),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  )))))),
          const SizedBox(height: 24),
          if (_phase == _Phase.input)
            ElevatedButton(
              onPressed: _confirm,
              child: const Text('Confirm Pattern'),
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
