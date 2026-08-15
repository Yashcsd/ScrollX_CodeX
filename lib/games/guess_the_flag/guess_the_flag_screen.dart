// lib/games/guess_the_flag/guess_the_flag_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bounce_press.dart';

class GuessTheFlagScreen extends StatefulWidget {
  const GuessTheFlagScreen({super.key});
  @override
  State<GuessTheFlagScreen> createState() => _GuessTheFlagScreenState();
}

class _GuessTheFlagScreenState extends State<GuessTheFlagScreen> {
  static const List<Map<String, String>> _flags = [
    {'flag': '🇮🇳', 'name': 'India'},
    {'flag': '🇺🇸', 'name': 'USA'},
    {'flag': '🇬🇧', 'name': 'UK'},
    {'flag': '🇯🇵', 'name': 'Japan'},
    {'flag': '🇨🇳', 'name': 'China'},
    {'flag': '🇧🇷', 'name': 'Brazil'},
    {'flag': '🇩🇪', 'name': 'Germany'},
    {'flag': '🇫🇷', 'name': 'France'},
    {'flag': '🇦🇺', 'name': 'Australia'},
    {'flag': '🇨🇦', 'name': 'Canada'},
    {'flag': '🇷🇺', 'name': 'Russia'},
    {'flag': '🇮🇹', 'name': 'Italy'},
    {'flag': '🇲🇽', 'name': 'Mexico'},
    {'flag': '🇰🇷', 'name': 'South Korea'},
    {'flag': '🇿🇦', 'name': 'South Africa'},
    {'flag': '🇳🇬', 'name': 'Nigeria'},
    {'flag': '🇦🇷', 'name': 'Argentina'},
    {'flag': '🇸🇦', 'name': 'Saudi Arabia'},
    {'flag': '🇪🇬', 'name': 'Egypt'},
    {'flag': '🇹🇷', 'name': 'Turkey'},
  ];

  static final _tint = kGameTints['guess_the_flag']!;

  final _rng = Random();
  late Map<String, String> _current;
  late List<String> _options;
  int _score = 0, _round = 0;
  bool _showResult = false;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _nextQ();
  }

  void _nextQ() {
    _current = _flags[_rng.nextInt(_flags.length)];
    final opts = {_current['name']!};
    while (opts.length < 4) {
      opts.add(_flags[_rng.nextInt(_flags.length)]['name']!);
    }
    _options = opts.toList()..shuffle();
    _selected = null;
    _answered = false;
  }

  void _pick(String name) {
    if (_answered) return;
    final ok = name == _current['name'];
    setState(() {
      _selected = name;
      _answered = true;
      if (ok) _score += 50;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      _round++;
      if (_round >= 10) {
        _endGame();
      } else {
        setState(() => _nextQ());
      }
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'guess_the_flag',
      gameName: 'Guess the Flag',
      score: _score,
      timeTakenSeconds: 0,
      won: _score >= 300,
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
                  title: '🌍 Guess the Flag',
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
                        '${_round + 1}/10',
                        style: TextStyle(
                          color: _tint.shadow,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Progress ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GameProgressBar(
                    value: (_round + 1) / 10,
                    color: _tint.shadow,
                  ),
                ),

                const Spacer(),

                // ── Prompt ──────────────────────────────────────────────
                const Text(
                  'Which country is this flag?',
                  style: TextStyle(
                    color: kTextSec,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Flag display ────────────────────────────────────────
                GameCard(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 40),
                  child: Text(
                    _current['flag']!,
                    style: const TextStyle(fontSize: 90),
                  ),
                ),

                const Spacer(),

                // ── Answer choices ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    children: _options.map((name) {
                      Color bg = Colors.white;
                      Color border = kBorder;
                      Color text = kDark;

                      if (_answered) {
                        if (name == _current['name']) {
                          bg = kTeal.withValues(alpha: 0.12);
                          border = kTeal;
                          text = kTeal;
                        } else if (name == _selected) {
                          bg = kCoral.withValues(alpha: 0.10);
                          border = kCoral;
                          text = kCoral;
                        }
                      }

                      return BouncePressWidget(
                        onTap: () => _pick(name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border, width: 1.5),
                            boxShadow: const [kHardShadow],
                          ),
                          child: Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          if (_showResult)
            GameResultOverlay(
              score: _score,
              xpEarned: _score >= 300 ? 120 : 20,
              won: _score >= 300,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _score = 0;
                _round = 0;
                _showResult = false;
                _nextQ();
              }),
            ),
        ],
      ),
    );
  }
}
