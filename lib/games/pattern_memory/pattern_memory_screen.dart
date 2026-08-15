// lib/games/pattern_memory/pattern_memory_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bounce_press.dart';

class PatternMemoryScreen extends StatefulWidget {
  const PatternMemoryScreen({super.key});
  @override
  State<PatternMemoryScreen> createState() => _PatternMemoryScreenState();
}

enum _Phase { showing, input, result }

class _PatternMemoryScreenState extends State<PatternMemoryScreen> {
  final _rng = Random();
  static const int _grid = 4; // 4×4
  static final _tint = kGameTints['pattern_memory']!;

  late Set<int> _pattern;
  Set<int> _userTaps = {};
  _Phase _phase = _Phase.showing;
  int _round = 1;
  int _score = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final count = _min(3 + _round, 10);
    _pattern = {};
    while (_pattern.length < count) {
      _pattern.add(_rng.nextInt(_grid * _grid));
    }
    _userTaps = {};
    _phase = _Phase.showing;
    Future.delayed(
      Duration(milliseconds: (1500 + 300 * _round).clamp(1500, 4000)),
      () {
        if (mounted) setState(() => _phase = _Phase.input);
      },
    );
  }

  void _tap(int idx) {
    if (_phase != _Phase.input) return;
    setState(() {
      if (_userTaps.contains(idx)) {
        _userTaps.remove(idx);
      } else {
        _userTaps.add(idx);
      }
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
        if (_round > 8) {
          _endGame();
          return;
        }
        setState(() => _newRound());
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'pattern_memory',
      gameName: 'Pattern Memory',
      score: _score,
      timeTakenSeconds: 0,
      won: _round >= 5,
    );
  }

  int _min(int a, int b) => a < b ? a : b;

  Color _cellColor(int idx) {
    if (_phase == _Phase.showing) {
      return _pattern.contains(idx) ? kYellow : _tint.mid;
    }
    if (_phase == _Phase.result) {
      if (_pattern.contains(idx) && _userTaps.contains(idx)) return kTeal;
      if (_pattern.contains(idx)) return kCoral;
      if (_userTaps.contains(idx)) return kCoral.withValues(alpha: 0.4);
      return _tint.mid;
    }
    // input phase
    return _userTaps.contains(idx) ? kYellow.withValues(alpha: 0.7) : _tint.mid;
  }

  @override
  Widget build(BuildContext context) {
    final phaseLabel = _phase == _Phase.showing
        ? '👀 Memorize the pattern!'
        : _phase == _Phase.input
            ? '🖐 Tap the same cells!'
            : '✓ Checking…';

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
                  title: '🧠 Pattern Memory',
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
                        'Rd $_round',
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

                // ── Phase label ─────────────────────────────────────────
                GameCard(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                  child: Text(
                    phaseLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Pattern grid ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: _grid,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(
                      _grid * _grid,
                      (i) => BouncePressWidget(
                        onTap: () => _tap(i),
                        scaleDownTo: 0.92,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _cellColor(i),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [kHardShadow],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Confirm button ──────────────────────────────────────
                if (_phase == _Phase.input)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: YellowButton(
                      label: 'Confirm Pattern',
                      icon: Icons.check_rounded,
                      onTap: _confirm,
                    ),
                  ),

                const Spacer(),
              ],
            ),
          ),

          if (_showResult)
            GameResultOverlay(
              score: _score,
              xpEarned: _round >= 5 ? 120 : 20,
              won: _round >= 5,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _score = 0;
                _round = 1;
                _showResult = false;
                _newRound();
              }),
            ),
        ],
      ),
    );
  }
}
