// lib/games/pairs_equation/pairs_equation_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
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
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Equation Pairs',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kYellow.withOpacity(0.3)),
                ),
                child: Text('$_moves moves', style: const TextStyle(
                  color: kDark, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const SizedBox(height: 12),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Match each equation to its answer!',
              style: TextStyle(color: kDark, fontSize: 14, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          GameCard(
            child: GridView.count(shrinkWrap: true, crossAxisCount: 3,
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
              children: List.generate(_cards.length, (i) {
                final c = _cards[i];
                return GestureDetector(
                  onTap: () => _tap(i),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: c.matched
                          ? Colors.green.withOpacity(0.2)
                          : c.flipped
                              ? kYellow.withOpacity(0.2)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.matched
                          ? Colors.green.withOpacity(0.6)
                          : c.flipped
                              ? kYellow.withOpacity(0.6)
                              : kTextMuted.withOpacity(0.3), width: c.flipped || c.matched ? 1.5 : 0.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08),
                            blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Center(child: c.flipped || c.matched
                        ? Text(c.text, textAlign: TextAlign.center,
                            style: TextStyle(
                              color: c.matched ? Colors.green : kDark,
                              fontSize: 14, fontWeight: FontWeight.w700))
                        : const Icon(Icons.help_outline, color: kTextMuted, size: 20))));
              })),
          ),
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
