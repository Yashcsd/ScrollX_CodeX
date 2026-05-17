// lib/games/number_sequence/number_sequence_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final type = _rng.nextInt(3);
    final start = _rng.nextInt(20) + 1;
    List<int> seq;
    switch (type) {
      case 0:
        final diff = _rng.nextInt(10) + 2;
        seq = List.generate(5, (i) => start + i * diff);
      case 1:
        final ratio = _rng.nextInt(3) + 2;
        seq = List.generate(5, (i) => start * pow(ratio, i).toInt());
      default:
        seq = [start, start + 1];
        while (seq.length < 5) seq.add(seq[seq.length - 1] + seq[seq.length - 2]);
    }
    _answer = seq[4];
    _sequence = seq.take(4).toList();
    final opts = {_answer};
    while (opts.length < 4) opts.add(_answer + _rng.nextInt(21) - 10);
    _options = opts.toList()..shuffle();
  }

  void _pick(int val) {
    final ok = val == _answer;
    setState(() { _flash = ok ? '✓ Correct!' : '✗ Wrong!'; if (ok) _score += 50; });
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
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: Stack(children: [
        SafeArea(
          bottom: false,
          child: Column(children: [
            GameHeader(title: '🔢 Number Sequence', actions: [ScoreBadge(score: _score)]),
            const SizedBox(height: 12),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GameProgressBar(value: _round / 8),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GameCard(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(children: [
                  const Text('ROUND', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                  Text('${_round + 1} / 8', style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900)),
                ]),
              ),
            ),
            const Spacer(),
            const Text('What comes next?',
              style: TextStyle(color: kTextSec, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            // Sequence tiles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  ..._sequence.map((n) => Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [kHardShadow],
                    ),
                    child: Center(child: Text('$n',
                      style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w800))),
                  )),
                  // Answer slot
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      color: kYellow,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: kYellowDark, blurRadius: 0, offset: Offset(0, 4))],
                    ),
                    child: Center(child: Text(
                      _flash != null ? (_flash!.contains('✓') ? '✓' : '✗') : '?',
                      style: TextStyle(
                        color: _flash != null ? (_flash!.contains('✓') ? kTeal : kCoral) : kDark,
                        fontSize: 24, fontWeight: FontWeight.w900,
                      ),
                    )),
                  ),
                ],
              ),
            ),
            if (_flash != null) ...[
              const SizedBox(height: 12),
              Text(_flash!,
                style: TextStyle(
                  color: _flash!.contains('✓') ? kTeal : kCoral,
                  fontSize: 15, fontWeight: FontWeight.w700,
                )),
            ],
            const Spacer(),
            // Answer options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: _options.map((v) => GestureDetector(
                  onTap: () => _pick(v),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [kHardShadow],
                    ),
                    child: Center(child: Text('$v',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDark))),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ]),
        ),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 200 ? 120 : 20, won: _score >= 200,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score = 0; _round = 0; _showResult = false; _nextQ(); }),
        ),
      ]),
    ),
  );
}
