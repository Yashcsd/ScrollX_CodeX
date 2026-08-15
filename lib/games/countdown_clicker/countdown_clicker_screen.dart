// lib/games/countdown_clicker/countdown_clicker_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../services/haptics_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bounce_press.dart';
import '../../widgets/anti_gravity.dart';

class CountdownClickerScreen extends StatefulWidget {
  const CountdownClickerScreen({super.key});
  @override
  State<CountdownClickerScreen> createState() =>
      _CountdownClickerScreenState();
}

class _CountdownClickerScreenState extends State<CountdownClickerScreen>
    with SingleTickerProviderStateMixin {
  static final _tint = kGameTints['countdown_clicker']!;

  int _counter = 0;
  int _target = 30;
  int _timeLeft = 10;
  Timer? _timer;
  bool _started = false;
  bool _showResult = false;
  bool _won = false;

  late final AnimationController _ringBounceCtrl;
  late final Animation<double> _ringBounceAnim;

  @override
  void initState() {
    super.initState();
    _ringBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _ringBounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_ringBounceCtrl);
    AudioService.playMusic('arcade');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringBounceCtrl.dispose();
    AudioService.stopMusic();
    super.dispose();
  }

  void _start() {
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) {
        _endGame();
        return;
      }
      setState(() => _timeLeft--);
      if (_timeLeft <= 5) {
        HapticsService.timerTick(_timeLeft);
        if (_timeLeft > 0) {
          if (_timeLeft <= 3) {
            AudioService.playSfx('tension_tick');
          } else {
            AudioService.playSfx('tick');
          }
        }
      }
    });
  }

  void _tap() {
    HapticsService.light();
    _ringBounceCtrl.forward(from: 0.0);
    if (!_started) _start();
    if (_timeLeft <= 0) return;
    setState(() => _counter++);
    if (_counter >= _target) _endGame();
  }

  void _endGame() {
    _timer?.cancel();
    final won = _counter >= _target;
    setState(() {
      _won = won;
      _showResult = true;
    });
    context.read<UserProvider>().recordGameResult(
      gameId: 'countdown_clicker',
      gameName: 'Countdown Clicker',
      score: _counter * 10,
      timeTakenSeconds: 10,
      won: won,
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
                  title: '⚡ Countdown Clicker',
                  actions: [
                    ScoreBadge(score: _counter * 10),
                  ],
                ),

                const Spacer(),

                // ── Instruction ─────────────────────────────────────────
                AntiGravityWidget(
                  child: GameCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    child: Text(
                      'Tap $_target times in 10 seconds!',
                      style: const TextStyle(
                        color: kDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Timer ring ──────────────────────────────────────────
                ScaleTransition(
                  scale: _ringBounceAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _timeLeft / 10,
                          strokeWidth: 8,
                          backgroundColor: _tint.mid,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft > 5 ? kTeal : kCoral,
                          ),
                        ),
                      ),
                      Text(
                        '$_timeLeft',
                        style: const TextStyle(
                          color: kDark,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Progress ────────────────────────────────────────────
                Text(
                  '$_counter / $_target',
                  style: TextStyle(
                    color: _tint.shadow,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: GameProgressBar(
                    value: _counter / _target,
                    color: kYellow,
                  ),
                ),

                const Spacer(),

                // ── Tap button ──────────────────────────────────────────
                BouncePressWidget(
                  onTap: _tap,
                  scaleDownTo: 0.9,
                  enableHaptics: false,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: kYellow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kYellowDark,
                          blurRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'TAP!',
                        style: TextStyle(
                          color: kDark,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),

          if (_showResult)
            GameResultOverlay(
              score: _counter * 10,
              xpEarned: _won ? 120 : 20,
              won: _won,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _counter = 0;
                _timeLeft = 10;
                _started = false;
                _showResult = false;
              }),
            ),
        ],
      ),
    );
  }
}
