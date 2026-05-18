// lib/games/number_sequence/number_sequence_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class NumberSequenceScreen extends StatefulWidget {
  const NumberSequenceScreen({super.key});
  @override
  State<NumberSequenceScreen> createState() => _NumberSequenceScreenState();
}

class _NumberSequenceScreenState extends State<NumberSequenceScreen> {
  final _rng = Random();
  late List<int> _sequence;
  late int _answer;
  late List<int> _options;
  int _score = 0, _round = 0;
  bool _showResult = false;
  String? _flash;

  @override
  void initState() { super.initState(); _nextQ(); }

  void _nextQ() {
    // Arithmetic or geometric sequences
    final type = _rng.nextInt(3);
    final start = _rng.nextInt(20) + 1;
    List<int> seq;
    switch (type) {
      case 0: // arithmetic
        final diff = _rng.nextInt(10) + 2;
        seq = List.generate(5, (i) => start + i * diff);
      case 1: // geometric
        final ratio = _rng.nextInt(3) + 2;
        seq = List.generate(5, (i) => start * pow(ratio, i).toInt());
      default: // Fibonacci-like
        seq = [start, start + 1];
        while (seq.length < 5) seq.add(seq[seq.length-1] + seq[seq.length-2]);
    }
    _answer = seq[4];
    _sequence = seq.take(4).toList();
    final opts = {_answer};
    while (opts.length < 4) opts.add(_answer + _rng.nextInt(21) - 10);
    _options = opts.toList()..shuffle();
  }

  void _pick(int val) {
    final ok = val == _answer;
    setState(() { _flash = ok ? '✓' : '✗'; if (ok) _score += 50; });
    Future.delayed(const Duration(milliseconds: 500), () {
      _round++;
      if (_round >= 8) { _endGame(); return; }
      setState(() { _flash = null; _nextQ(); });
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'number_sequence', gameName: 'Number Sequence',
      score: _score, timeTakenSeconds: 0, won: _score >= 200,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Number Sequence',
            actions: [ScoreBadge(score: _score)],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GameProgressBar(value: _round / 8),
          ),
          const Spacer(),
          GameCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('What comes next?', style: TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                Wrap(alignment: WrapAlignment.center, spacing: 12,
                  children: [
                    ..._sequence.map((n) => Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: kYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kYellow.withOpacity(0.3), width: 2)),
                      child: Center(child: Text('$n', style: const TextStyle(
                        color: kDark, fontSize: 20, fontWeight: FontWeight.w700))))),
                    Container(width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kYellow, width: 2)),
                      child: Center(child: Text(_flash ?? '?',
                        style: TextStyle(
                          color: _flash == '✓' ? Colors.green : _flash == '✗' ? Colors.red : kTextMuted,
                          fontSize: 24, fontWeight: FontWeight.w800)))),
                  ]),
              ],
            ),
          ),
          const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(shrinkWrap: true, crossAxisCount: 2,
              mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
              children: _options.map((v) => GestureDetector(
                onTap: () => _pick(v),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08),
                          blurRadius: 6, offset: const Offset(0, 2)),
                    ]),
                  child: Center(child: Text('$v',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kDark))))
              )).toList())),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 200 ? 120 : 20, won: _score >= 200,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score=0; _round=0; _showResult=false; _nextQ(); }),
        ),
      ])),
    ),
  );
}
