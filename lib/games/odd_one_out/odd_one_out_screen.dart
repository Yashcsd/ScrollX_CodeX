// lib/games/odd_one_out/odd_one_out_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bounce_press.dart';

class OddOneOutScreen extends StatefulWidget {
  const OddOneOutScreen({super.key});
  @override
  State<OddOneOutScreen> createState() => _OddOneOutScreenState();
}

class _OddOneOutScreenState extends State<OddOneOutScreen> {
  final _rng = Random();

  static const List<List<String>> _sets = [
    ['🐶', '🐱', '🐭', '🚗'],
    ['🍎', '🍊', '🍋', '🍕'],
    ['🏀', '⚽', '🎾', '🎸'],
    ['🚀', '✈️', '🚁', '🐟'],
    ['📱', '💻', '🖥️', '🌲'],
    ['🎮', '🕹️', '🎲', '🍔'],
    ['🦁', '🐯', '🐻', '🦋'],
    ['⭐', '🌙', '☀️', '🐙'],
    ['🍕', '🍔', '🌮', '🎂'],
    ['🚂', '🚌', '🚕', '🛸'],
    ['🎵', '🎶', '🎸', '📚'],
    ['💎', '💍', '👑', '🍀'],
    ['🔴', '🟡', '🟢', '📦'],
    ['🌊', '🏔️', '🌋', '💡'],
  ];

  static final _tint = kGameTints['odd_one_out']!;

  late List<String> _items;
  late int _oddIdx;
  int _score = 0;
  int _round = 0;
  bool _showResult = false;
  String? _flash;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final s = _sets[_rng.nextInt(_sets.length)];
    _items = List.from(s)..shuffle();
    // The 4th item in original list is the "odd" one
    _oddIdx = _items.indexOf(s[3]);
    _flash = null;
  }

  void _pick(int idx) {
    if (_flash != null) return;
    final ok = idx == _oddIdx;
    setState(() {
      _flash = ok ? '✓ Correct!' : '✗ Wrong!';
      if (ok) _score += 50;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _round++;
      if (_round >= 8) {
        _endGame();
      } else {
        setState(() => _load());
      }
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'odd_one_out',
      gameName: 'Odd One Out',
      score: _score,
      timeTakenSeconds: 0,
      won: _score >= 250,
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
                // ── Header ──────────────────────────────────────────────
                GameHeader(
                  title: '🔍 Odd One Out',
                  actions: [
                    ScoreBadge(score: _score),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _tint.mid,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [kHardShadow],
                      ),
                      child: Text(
                        '${_round + 1}/8',
                        style: TextStyle(
                          color: _tint.shadow,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Instruction ─────────────────────────────────────────
                GameCard(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                  child: const Text(
                    'Tap the one that DOESN\'T belong!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // ── 2×2 emoji grid ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    children: List.generate(
                      4,
                      (i) => BouncePressWidget(
                        onTap: () => _pick(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [kHardShadow],
                          ),
                          child: Center(
                            child: Text(
                              _items[i],
                              style: const TextStyle(fontSize: 52),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Flash feedback ──────────────────────────────────────
                const SizedBox(height: 24),
                if (_flash != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [kHardShadow],
                    ),
                    child: Text(
                      _flash!,
                      style: TextStyle(
                        color: _flash!.contains('✓') ? kTeal : kCoral,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 44),

                const Spacer(),
              ],
            ),
          ),

          if (_showResult)
            GameResultOverlay(
              score: _score,
              xpEarned: _score >= 250 ? 120 : 20,
              won: _score >= 250,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _score = 0;
                _round = 0;
                _showResult = false;
                _load();
              }),
            ),
        ],
      ),
    );
  }
}
