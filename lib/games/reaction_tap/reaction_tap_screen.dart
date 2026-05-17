// lib/games/reaction_tap/reaction_tap_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  void initState() { super.initState(); _startWait(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startWait() {
    setState(() => _phase = _Phase.waiting);
    final delay = _rng.nextInt(3000) + 1500;
    _timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() { _phase = _Phase.ready; _greenAt = DateTime.now(); });
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
    final avg = _times.isEmpty ? 999 : (_times.reduce((a, b) => a + b) ~/ _times.length);
    final score = (1000 - avg).clamp(0, 1000);
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'reaction_tap', gameName: 'Reaction Tap',
      score: score, timeTakenSeconds: 0, won: avg < 400,
    );
  }

  int get _avg => _times.isEmpty ? 0 : _times.reduce((a, b) => a + b) ~/ _times.length;
  int get _score => (1000 - _avg).clamp(0, 1000);

  Color get _tapColor {
    switch (_phase) {
      case _Phase.ready:    return kTeal;
      case _Phase.tooEarly: return kCoral;
      default:              return kDark;
    }
  }

  String get _instruction {
    switch (_phase) {
      case _Phase.waiting:  return 'Wait for GREEN…';
      case _Phase.ready:    return 'TAP NOW!';
      case _Phase.tooEarly: return 'Too early!\nWait for green…';
      case _Phase.done:     return 'All done!';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: Stack(children: [
        SafeArea(
          bottom: false,
          child: Column(children: [
            GameHeader(title: '⚡ Reaction Tap', actions: [ScoreBadge(score: _score)]),
            const SizedBox(height: 12),
            // Round progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: List.generate(_totalRounds, (i) => Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i < _round ? kTeal : (i == _round ? kYellow : kBorder),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ))),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(child: GameCard(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(children: [
                    const Text('ROUND', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                    Text('$_round / $_totalRounds', style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900)),
                  ]),
                )),
                const SizedBox(width: 12),
                Expanded(child: GameCard(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(children: [
                    const Text('LAST', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                    Text(_times.isEmpty ? '—' : '${_times.last} ms',
                      style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900)),
                  ]),
                )),
              ]),
            ),
            const Spacer(),
            // Big tap target
            GestureDetector(
              onTap: _phase == _Phase.done ? null : _onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 200, height: 200,
                decoration: BoxDecoration(
                  color: _tapColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _tapColor, blurRadius: 0, offset: const Offset(0, 6))],
                ),
                child: Center(
                  child: Text(
                    _phase == _Phase.ready ? 'TAP!' : _phase == _Phase.tooEarly ? '😬' : '●',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _instruction,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _phase == _Phase.ready ? kTeal : _phase == _Phase.tooEarly ? kCoral : kTextSec,
                fontSize: 18, fontWeight: FontWeight.w700,
              ),
            ),
            if (_times.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Average: $_avg ms', style: const TextStyle(color: kTextMuted, fontSize: 13)),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: OutlineButton(label: 'Restart', icon: Icons.refresh_rounded, onTap: () => setState(() {
                _times = []; _round = 0; _showResult = false; _phase = _Phase.waiting; _startWait();
              })),
            ),
          ]),
        ),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _avg < 400 ? 120 : 20, won: _avg < 400,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _times = []; _round = 0; _showResult = false; _phase = _Phase.waiting; _startWait();
          }),
        ),
      ]),
    ),
  );
}
