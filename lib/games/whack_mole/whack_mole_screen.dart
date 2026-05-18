// lib/games/whack_mole/whack_mole_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class WhackMoleScreen extends StatefulWidget {
  const WhackMoleScreen({super.key});
  @override
  State<WhackMoleScreen> createState() => _WhackMoleScreenState();
}

class _WhackMoleScreenState extends State<WhackMoleScreen> {
  final _rng = Random();
  static const int _holes = 9;

  List<bool> _active = List.filled(_holes, false);
  List<bool> _hit    = List.filled(_holes, false);
  int _score    = 0;
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

    _moleTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      setState(() {
        // Hide previous moles
        _active = List.filled(_holes, false);
        _hit    = List.filled(_holes, false);
        // Show 1–3 new random moles
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
      body: Container(
        decoration: const BoxDecoration(gradient: kGameGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  GameHeader(
                    title: 'Whack-a-Mole',
                    actions: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _timeLeft > 10 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _timeLeft > 10 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                        ),
                        child: Text('$_timeLeft s', style: TextStyle(
                          color: _timeLeft > 10 ? Colors.green : Colors.red,
                          fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      ScoreBadge(score: _score),
                    ],
                  ),

                  const Spacer(),

                  // Timer bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GameProgressBar(
                      value: _timeLeft / 30,
                      color: _timeLeft > 10 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mole grid
                  GameCard(
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: List.generate(
                        _holes,
                            (i) => GestureDetector(
                          onTap: () => _whack(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                              color: _hit[i]
                                  ? kYellow.withOpacity(0.3)
                                  : _active[i]
                                  ? Colors.brown.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6, offset: const Offset(0, 2)),
                              ],
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

              if (_showResult)
                GameResultOverlay(
                  score: _score,
                  xpEarned: _score >= 150 ? 120 : 20,
                  won: _score >= 150,
                  onContinue: () => Navigator.pop(context),
                  onRetry: () => setState(() {
                    _active = List.filled(_holes, false);
                    _hit    = List.filled(_holes, false);
                    _score    = 0;
                    _timeLeft = 30;
                    _showResult = false;
                    _start();
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
