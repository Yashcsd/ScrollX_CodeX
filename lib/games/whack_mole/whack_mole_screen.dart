// lib/games/whack_mole/whack_mole_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0D00), Color(0xFF3D2200)],
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
                          'Whack-a-Mole',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_timeLeft s',
                          style: TextStyle(
                            color: _timeLeft > 10
                                ? AppTheme.teal
                                : AppTheme.coral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_score pts',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Timer bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _timeLeft / 30,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _timeLeft > 10
                              ? AppTheme.teal
                              : AppTheme.coral,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mole grid — fixed bracket structure
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  ? AppTheme.gold.withOpacity(0.3)
                                  : _active[i]
                                  ? const Color(0xFF5C3A00)
                                  : Colors.brown.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _active[i]
                                    ? Colors.brown
                                    : Colors.white10,
                              ),
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