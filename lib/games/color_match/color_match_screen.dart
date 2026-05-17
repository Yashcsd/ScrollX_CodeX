// lib/games/color_match/color_match_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class ColorMatchScreen extends StatefulWidget {
  const ColorMatchScreen({super.key});
  @override
  State<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen> {
  static const Map<String, Color> _palette = {
    'RED': Color(0xFFD85A30), 'BLUE': Color(0xFF378ADD),
    'GREEN': Color(0xFF1D9E75), 'GOLD': Color(0xFFE4D400),
    'PURPLE': Color(0xFF7F77DD), 'PINK': Color(0xFFD4537E),
  };

  final _rng = Random();
  late String _wordText, _correctAnswer;
  late Color _wordColor;
  late List<String> _options;
  int _score = 0, _lives = 3;
  double _timeLeft = 5.0;
  Timer? _timer;
  bool _showResult = false;

  @override
  void initState() { super.initState(); _nextRound(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _nextRound() {
    final all = _palette.keys.toList();
    _wordText = all[_rng.nextInt(all.length)];
    _correctAnswer = _rng.nextBool() ? _wordText : all[_rng.nextInt(all.length)];
    _wordColor = _palette[_correctAnswer]!;
    final opts = {_correctAnswer};
    while (opts.length < 4) opts.add(all[_rng.nextInt(all.length)]);
    _options = opts.toList()..shuffle();
    _timeLeft = 5.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _timeLeft -= 0.1);
      if (_timeLeft <= 0) { t.cancel(); _wrong(); }
    });
    setState(() {});
  }

  void _pick(String choice) {
    _timer?.cancel();
    if (choice == _correctAnswer) {
      setState(() => _score += ((_timeLeft / 5.0) * 100).toInt() + 50);
      Future.delayed(const Duration(milliseconds: 150), _nextRound);
    } else { _wrong(); }
  }

  void _wrong() {
    setState(() => _lives--);
    if (_lives <= 0) { _endGame(); return; }
    Future.delayed(const Duration(milliseconds: 400), _nextRound);
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'color_match', gameName: 'Color Match',
      score: _score, timeTakenSeconds: 0, won: _score >= 200,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: Stack(children: [
        SafeArea(bottom: false, child: Column(children: [
          GameHeader(title: '🎨 Color Match', actions: [
            LivesRow(lives: _lives),
            const SizedBox(width: 10),
            ScoreBadge(score: _score),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GameProgressBar(value: (_timeLeft / 5.0).clamp(0, 1),
              color: _timeLeft > 3 ? kTeal : _timeLeft > 1.5 ? kYellow : kCoral),
          ),
          const Spacer(),
          const Text('What COLOR is this text printed in?',
              style: TextStyle(color: kTextSec, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          GameCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Text(_wordText, style: TextStyle(
              fontSize: 52, fontWeight: FontWeight.w900,
              color: _wordColor, letterSpacing: 3)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: GridView.count(
              shrinkWrap: true, crossAxisCount: 2,
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
              children: _options.map((name) => GestureDetector(
                onTap: () => _pick(name),
                child: Container(
                  decoration: BoxDecoration(
                    color: _palette[name]!.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _palette[name]!.withOpacity(0.5), width: 1.5),
                  ),
                  child: Center(child: Text(name, style: TextStyle(
                    color: _palette[name], fontSize: 15, fontWeight: FontWeight.w800))),
                ),
              )).toList(),
            ),
          ),
        ])),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 200 ? 120 : 20, won: _score >= 200,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score = 0; _lives = 3; _showResult = false; _nextRound(); }),
        ),
      ]),
    ),
  );
}
