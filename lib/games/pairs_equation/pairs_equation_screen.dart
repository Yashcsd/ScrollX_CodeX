// lib/games/pairs_equation/pairs_equation_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bounce_press.dart';

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
  _Card({
    required this.text,
    required this.pairId,
    this.flipped = false,
    this.matched = false,
  });
}

class _PairsEquationScreenState extends State<PairsEquationScreen> {
  final _rng = Random();
  static final _tint = kGameTints['pairs_equation']!;

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
      pairs.add(['$a × $b', '${a * b}']);
    }
    return pairs;
  }

  @override
  void initState() {
    super.initState();
    _setup();
  }

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
      gameId: 'pairs_equation',
      gameName: 'Equation Pairs',
      score: _score,
      timeTakenSeconds: 0,
      won: _score >= 120,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _tint.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                GameHeader(
                  title: '🔢 Equation Pairs',
                  actions: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [kHardShadow],
                      ),
                      child: Text(
                        '$_moves moves',
                        style: const TextStyle(
                          color: kTextSec,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScoreBadge(score: _score),
                  ],
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GameCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: const Text(
                      'Match each equation to its answer!',
                      style: TextStyle(
                        color: kDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card grid ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: List.generate(
                      _cards.length,
                      (i) {
                        final c = _cards[i];
                        Color bg;
                        Color border;
                        Color text;

                        if (c.matched) {
                          bg = kTeal.withValues(alpha: 0.12);
                          border = kTeal;
                          text = kTeal;
                        } else if (c.flipped) {
                          bg = _tint.mid;
                          border = _tint.shadow;
                          text = _tint.shadow;
                        } else {
                          bg = Colors.white;
                          border = kBorder;
                          text = kTextMuted;
                        }

                        return BouncePressWidget(
                          onTap: () => _tap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: border,
                                  width:
                                      c.flipped || c.matched ? 1.5 : 1),
                              boxShadow: const [kHardShadow],
                            ),
                            child: Center(
                              child: c.flipped || c.matched
                                  ? Text(
                                      c.text,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    )
                                  : Icon(
                                      Icons.help_outline_rounded,
                                      color: kTextMuted,
                                      size: 20,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_showResult)
            GameResultOverlay(
              score: _score,
              xpEarned: _score >= 120 ? 120 : 20,
              won: _score >= 120,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() => _setup()),
            ),
        ],
      ),
    );
  }
}
