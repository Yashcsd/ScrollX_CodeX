// lib/games/reaction_tap/reaction_tap_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

enum _Phase { waiting, ready, tooEarly, done }

class ReactionTapScreen extends StatefulWidget {
  const ReactionTapScreen({super.key});
  @override
  State<ReactionTapScreen> createState() => _ReactionTapScreenState();
}

class _ReactionTapScreenState extends State<ReactionTapScreen> {
  final _rng = Random();
  _Phase _phase = _Phase.waiting;
  Timer? _timer;
  List<int> _times = [];
  int _round = 0;
  static const int _totalRounds = 5;
  DateTime? _greenAt;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _startWait();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWait() {
    setState(() => _phase = _Phase.waiting);
    final delay = _rng.nextInt(3000) + 1500;
    _timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.ready;
        _greenAt = DateTime.now();
      });
    });
  }

  void _onTap() {
    if (_phase == _Phase.done) return;
    _timer?.cancel();

    if (_phase == _Phase.waiting) {
      setState(() => _phase = _Phase.tooEarly);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _startWait());
      });
      return;
    }

    if (_phase == _Phase.ready) {
      final ms = DateTime.now().difference(_greenAt!).inMilliseconds;
      _times.add(ms);
      _round++;
      if (_round >= _totalRounds) {
        setState(() => _phase = _Phase.done);
        _showResults();
      } else {
        setState(() => _phase = _Phase.waiting);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _startWait();
        });
      }
    }
  }

  void _showResults() {
    final avg = _times.isEmpty
        ? 999
        : (_times.reduce((a, b) => a + b) ~/ _times.length);
    final score = (1000 - avg).clamp(0, 1000);
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'reaction_tap',
      gameName: 'Reaction Tap',
      score: score,
      timeTakenSeconds: 0,
      won: avg < 400,
    );
  }

  int get _avg =>
      _times.isEmpty ? 0 : _times.reduce((a, b) => a + b) ~/ _times.length;
  int get _score => (1000 - _avg).clamp(0, 1000);

  Color get _bgColor {
    switch (_phase) {
      case _Phase.waiting:
        return const Color(0xFF1A1A2E);
      case _Phase.ready:
        return const Color(0xFF0D4F3C);
      case _Phase.tooEarly:
        return const Color(0xFF4F1A0D);
      case _Phase.done:
        return const Color(0xFF1A1A2E);
    }
  }

  String get _instruction {
    switch (_phase) {
      case _Phase.waiting:
        return 'Wait for GREEN…';
      case _Phase.ready:
        return 'TAP NOW!';
      case _Phase.tooEarly:
        return 'Too early! 😬\nWait for green…';
      case _Phase.done:
        return 'All done!';
    }
  }

  Color get _instructionColor {
    switch (_phase) {
      case _Phase.waiting:
        return AppTheme.textSec;
      case _Phase.ready:
        return Colors.white;
      case _Phase.tooEarly:
        return AppTheme.coral;
      case _Phase.done:
        return AppTheme.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _phase == _Phase.done ? null : _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _bgColor,
          child: SafeArea(
            child: Stack(children: [
              Column(children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Reaction Tap',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const Spacer(),
                    Text('Round ${_round + 1} / $_totalRounds',
                        style: const TextStyle(
                            color: AppTheme.textSec, fontSize: 13)),
                  ]),
                ),

                const Spacer(),

                // Big icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    _phase == _Phase.ready
                        ? Icons.bolt
                        : Icons.circle_outlined,
                    key: ValueKey(_phase),
                    size: 100,
                    color: _phase == _Phase.ready
                        ? AppTheme.teal
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 28),

                // Instruction
                Text(
                  _instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _instructionColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                // Last reaction time
                if (_times.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Last: ${_times.last} ms',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16)),
                ],

                const Spacer(),

                // Previous attempts chips
                if (_times.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _times
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('${t} ms',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ))
                          .toList(),
                    ),
                  ),

                if (_times.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Average: $_avg ms',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                ],

                const SizedBox(height: 48),
              ]),

              if (_showResult)
                GameResultOverlay(
                  score: _score,
                  xpEarned: _avg < 400 ? 120 : 20,
                  won: _avg < 400,
                  onContinue: () => Navigator.pop(context),
                  onRetry: () => setState(() {
                    _times = [];
                    _round = 0;
                    _showResult = false;
                    _phase = _Phase.waiting;
                    _startWait();
                  }),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
