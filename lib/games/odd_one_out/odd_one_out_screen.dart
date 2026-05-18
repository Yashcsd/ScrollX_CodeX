// lib/games/odd_one_out/odd_one_out_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

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
    if (_flash != null) return; // prevent double tap
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
      body: Container(
        decoration: const BoxDecoration(gradient: kGameGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  GameHeader(
                    title: 'Odd One Out',
                    actions: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kYellow.withOpacity(0.3)),
                        ),
                        child: Text('${_round + 1}/8', style: const TextStyle(
                          color: kDark, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      ScoreBadge(score: _score),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    'Tap the one that DOESN\'T belong!',
                    style: TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 32),

                  // 2x2 emoji grid
                  GameCard(
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: List.generate(
                        4,
                            (i) => GestureDetector(
                          onTap: () => _pick(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [kGameShadow],
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

                  const SizedBox(height: 24),
                  if (_flash != null)
                    Text(
                      _flash!,
                      style: TextStyle(
                        color: _flash!.contains('✓') ? Colors.green : Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    const SizedBox(height: 28),

                  const Spacer(),
                ],
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
        ),
      ),
    );
  }
}
