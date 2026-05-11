// lib/games/pairs_equation/pairs_equation_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class PairsEquationScreen extends StatefulWidget {
  const PairsEquationScreen({super.key});
  @override
  State<PairsEquationScreen> createState() => _PairsEquationScreenState();
}

class _Card {
  final String text;
  final int pairId;
  bool flipped;
  bool matched;
  _Card({required this.text, required this.pairId, this.flipped = false, this.matched = false});
}

class _PairsEquationScreenState extends State<PairsEquationScreen> {
  final _rng = Random();
  late List<_Card> _cards;
  List<int> _selected = [];
  int _score = 0, _moves = 0;
  bool _canTap = true;
  bool _showResult = false;

  static List<List<String>> _generatePairs() {
    final rng = Random();
    final pairs = <List<String>>[];
    for (int i = 0; i < 6; i++) {
      final a = rng.nextInt(12) + 1;
      final b = rng.nextInt(12) + 1;
      pairs.add(['$a × $b', '${a*b}']);
    }
    return pairs;
  }

  @override
  void initState() { super.initState(); _setup(); }

  void _setup() {
    final pairs = _generatePairs();
    final cards = <_Card>[];
    for (int i = 0; i < pairs.length; i++) {
      cards.add(_Card(text: pairs[i][0], pairId: i));
      cards.add(_Card(text: pairs[i][1], pairId: i));
    }
    cards.shuffle();
    _cards = cards;
    _selected = [];
    _score = 0;
    _moves = 0;
    _canTap = true;
    _showResult = false;
  }

  void _tap(int idx) {
    if (!_canTap || _cards[idx].flipped || _cards[idx].matched) return;
    setState(() {
      _cards[idx].flipped = true;
      _selected.add(idx);
    });
    if (_selected.length == 2) {
      _canTap = false;
      _moves++;
      final a = _selected[0], b = _selected[1];
      if (_cards[a].pairId == _cards[b].pairId) {
        setState(() {
          _cards[a].matched = _cards[b].matched = true;
          _score += 30;
          _selected = [];
          _canTap = true;
        });
        if (_cards.every((c) => c.matched)) _endGame();
      } else {
        Future.delayed(const Duration(milliseconds: 900), () {
          setState(() {
            _cards[a].flipped = _cards[b].flipped = false;
            _selected = [];
            _canTap = true;
          });
        });
      }
    }
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'pairs_equation', gameName: 'Equation Pairs',
      score: _score, timeTakenSeconds: 0, won: _score >= 120,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF0D1F3C), Color(0xFF1A3A6E)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Equation Pairs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('$_moves moves', style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
              const SizedBox(width: 12),
              Text('$_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            ])),
          const SizedBox(height: 12),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Match each equation to its answer!',
              style: TextStyle(color: AppTheme.textSec, fontSize: 13))),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(shrinkWrap: true, crossAxisCount: 3,
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
              children: List.generate(_cards.length, (i) {
                final c = _cards[i];
                return GestureDetector(
                  onTap: () => _tap(i),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: c.matched
                          ? AppTheme.teal.withOpacity(0.2)
                          : c.flipped
                              ? AppTheme.accent.withOpacity(0.2)
                              : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.matched
                          ? AppTheme.teal.withOpacity(0.6)
                          : c.flipped
                              ? AppTheme.accent.withOpacity(0.6)
                              : Colors.white12, width: c.flipped || c.matched ? 1.5 : 0.5),
                    ),
                    child: Center(child: c.flipped || c.matched
                        ? Text(c.text, textAlign: TextAlign.center,
                            style: TextStyle(
                              color: c.matched ? AppTheme.teal : Colors.white,
                              fontSize: 14, fontWeight: FontWeight.w700))
                        : const Icon(Icons.help_outline, color: AppTheme.textMuted, size: 20))));
              }))),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 120 ? 120 : 20, won: _score >= 120,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() => _setup()),
        ),
      ])),
    ),
  );
}
