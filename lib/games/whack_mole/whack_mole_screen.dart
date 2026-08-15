// lib/games/whack_mole/whack_mole_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bounce_press.dart';

class WhackMoleScreen extends StatefulWidget {
  const WhackMoleScreen({super.key});
  @override
  State<WhackMoleScreen> createState() => _WhackMoleScreenState();
}

class _WhackMoleScreenState extends State<WhackMoleScreen> {
  final _rng = Random();
  static const int _holes = 9;
  static final _tint = kGameTints['whack_mole']!;

  List<bool> _active = List.filled(_holes, false);
  List<bool> _hit = List.filled(_holes, false);
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _moleTimer;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) {
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });

    _moleTimer =
        Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      setState(() {
        _active = List.filled(_holes, false);
        _hit = List.filled(_holes, false);
        final count = _rng.nextInt(3) + 1;
        final idxs = List.generate(_holes, (i) => i)..shuffle();
        for (int i = 0; i < count; i++) {
          _active[idxs[i]] = true;
        }
      });
    });
  }

  void _whack(int idx) {
    if (!_active[idx] || _hit[idx]) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _hit[idx] = true;
      _score += 20;
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    if (!mounted) return;
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'whack_mole',
      gameName: 'Whack-a-Mole',
      score: _score,
      timeTakenSeconds: 30,
      won: _score >= 150,
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
                  title: '🔨 Whack-a-Mole',
                  actions: [
                    TimerBadge(seconds: _timeLeft, total: 30),
                    const SizedBox(width: 8),
                    ScoreBadge(score: _score),
                  ],
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GameProgressBar(
                    value: _timeLeft / 30,
                    color: _timeLeft > 10 ? kTeal : kCoral,
                  ),
                ),

                const Spacer(),

                // ── Mole grid ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    children: List.generate(
                      _holes,
                      (i) => BouncePressWidget(
                        onTap: () => _whack(i),
                        scaleDownTo: 0.88,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          decoration: BoxDecoration(
                            color: _hit[i]
                                ? kYellow.withValues(alpha: 0.6)
                                : _active[i]
                                    ? Colors.white
                                    : _tint.mid,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [kHardShadow],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: _active[i] && !_hit[i]
                                  ? const Text(
                                      '🐹',
                                      key: ValueKey('mole'),
                                      style: TextStyle(fontSize: 40),
                                    )
                                  : _hit[i]
                                      ? const Text(
                                          '💥',
                                          key: ValueKey('hit'),
                                          style: TextStyle(fontSize: 36),
                                        )
                                      : const SizedBox(
                                          key: ValueKey('empty'),
                                        ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          if (_showResult)
            GameResultOverlay(
              score: _score,
              xpEarned: _score >= 150 ? 120 : 20,
              won: _score >= 150,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _active = List.filled(_holes, false);
                _hit = List.filled(_holes, false);
                _score = 0;
                _timeLeft = 30;
                _showResult = false;
                _start();
              }),
            ),
        ],
      ),
    );
  }
}
