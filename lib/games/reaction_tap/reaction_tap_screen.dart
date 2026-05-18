// lib/games/reaction_tap/reaction_tap_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
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
        return kTextMuted;
      case _Phase.ready:
        return kYellow;
      case _Phase.tooEarly:
        return Colors.red;
      case _Phase.done:
        return kYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _phase == _Phase.done ? null : _onTap,
        child: Container(
          decoration: const BoxDecoration(gradient: kGameGradient),
          child: SafeArea(
            child: Stack(children: [
              Column(children: [
                GameHeader(
                  title: 'Reaction Tap',
                  actions: [ScoreBadge(score: _score)],
                ),
                const SizedBox(height: 20),

                Text('Round ${_round + 1} / $_totalRounds',
                    style: const TextStyle(color: kDark, fontSize: 14, fontWeight: FontWeight.w600)),

                const Spacer(),

                GameCard(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: _phase == _Phase.ready
                          ? kYellow.withOpacity(0.1)
                          : _phase == _Phase.tooEarly
                              ? Colors.red.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            _phase == _Phase.ready ? Icons.bolt : Icons.circle_outlined,
                            key: ValueKey(_phase),
                            size: 100,
                            color: _phase == _Phase.ready ? kYellow : kTextMuted,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _instruction,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _instructionColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_times.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Last: ${_times.last} ms',
                              style: const TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                if (_times.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _times
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Text('${t} ms',
                                    style: const TextStyle(color: kDark, fontSize: 12, fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Average: $_avg ms',
                      style: const TextStyle(color: kDark, fontSize: 14, fontWeight: FontWeight.w600)),
                ],

                const SizedBox(height: 32),
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
