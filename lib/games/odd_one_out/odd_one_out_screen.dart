// lib/games/odd_one_out/odd_one_out_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B00), Color(0xFF6B3A00)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Odd One Out',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_round + 1}/8  $_score pts',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'Tap the one that DOESN\'T belong!',
                    style: TextStyle(color: AppTheme.textSec, fontSize: 15),
                  ),
                  const SizedBox(height: 32),

                  // 2x2 emoji grid — fixed bracket structure
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
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
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white12, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                _items[i],
                                style:
                                const TextStyle(fontSize: 52),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Flash message — now OUTSIDE GridView, correct position
                  const SizedBox(height: 24),
                  if (_flash != null)
                    Text(
                      _flash!,
                      style: TextStyle(
                        color: _flash!.contains('✓')
                            ? AppTheme.teal
                            : AppTheme.coral,
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
