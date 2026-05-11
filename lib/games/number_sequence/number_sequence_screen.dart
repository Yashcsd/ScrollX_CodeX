// lib/games/number_sequence/number_sequence_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF0A1628), Color(0xFF1A3A5C)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Number Sequence', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('$_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            ])),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _round / 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent), minHeight: 4)),
          const Spacer(),
          const Text('What comes next?', style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
          const SizedBox(height: 20),
          Wrap(alignment: WrapAlignment.center, spacing: 12,
            children: [
              ..._sequence.map((n) => Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.5))),
                child: Center(child: Text('$n', style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))))),
              Container(width: 60, height: 60,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 2, style: BorderStyle.solid)),
                child: Center(child: Text(_flash ?? '?',
                  style: TextStyle(
                    color: _flash == '✓' ? AppTheme.teal : _flash == '✗' ? AppTheme.coral : Colors.white54,
                    fontSize: 24, fontWeight: FontWeight.w800)))),
            ]),
          const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(shrinkWrap: true, crossAxisCount: 2,
              mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
              children: _options.map((v) => GestureDetector(
                onTap: () => _pick(v),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12)),
                  child: Center(child: Text('$v',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))))
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
