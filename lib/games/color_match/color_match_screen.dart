// lib/games/color_match/color_match_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class ColorMatchScreen extends StatefulWidget {
  const ColorMatchScreen({super.key});
  @override
  State<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen> {
  static const Map<String, Color> _palette = {
    'RED':    AppTheme.coral,
    'BLUE':   AppTheme.blue,
    'GREEN':  AppTheme.teal,
    'GOLD':   AppTheme.gold,
    'PURPLE': AppTheme.accent,
    'PINK':   AppTheme.pink,
  };

  final _rng = Random();
  late String _wordText;       // word displayed
  late Color  _wordColor;      // ink color
  late String _correctAnswer;  // name matching _wordColor
  late List<String> _options;

  int    _score     = 0;
  int    _lives     = 3;
  double _timeLeft  = 5.0;
  Timer? _timer;
  bool   _showResult = false;
  bool   _gameOver   = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextRound() {
    final all = _palette.keys.toList();

    // Word text — random color name
    _wordText = all[_rng.nextInt(all.length)];

    // Ink color — 50 % chance it matches the word (Stroop effect)
    if (_rng.nextBool()) {
      _correctAnswer = _wordText;
    } else {
      do {
        _correctAnswer = all[_rng.nextInt(all.length)];
      } while (_correctAnswer == _wordText);
    }
    _wordColor = _palette[_correctAnswer]!;

    // 4 options including the correct one
    final opts = {_correctAnswer};
    while (opts.length < 4) {
      opts.add(all[_rng.nextInt(all.length)]);
    }
    _options = opts.toList()..shuffle();

    // Reset timer
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
    } else {
      _wrong();
    }
  }

  void _wrong() {
    setState(() => _lives--);
    if (_lives <= 0) { _endGame(); return; }
    Future.delayed(const Duration(milliseconds: 400), _nextRound);
  }

  void _endGame() {
    _timer?.cancel();
    setState(() { _gameOver = true; _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'color_match', gameName: 'Color Match',
      score: _score, timeTakenSeconds: 0,
      won: _score >= 200,
    );
  }

  void _restart() {
    setState(() {
      _score = 0; _lives = 3;
      _showResult = false; _gameOver = false;
    });
    _nextRound();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: AppTheme.colorGrad),
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
                    decoration: BoxDecoration(color: Colors.white10,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Color Match', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700,
                    color: Colors.white)),
                const Spacer(),
                Row(children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.favorite, size: 20,
                      color: i < _lives ? AppTheme.pink : Colors.white12),
                ))),
                const SizedBox(width: 12),
                Text('$_score',
                    style: const TextStyle(color: AppTheme.gold,
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ]),
            ),
            const SizedBox(height: 16),
            // Timer bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_timeLeft / 5.0).clamp(0.0, 1.0),
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeLeft > 3 ? AppTheme.teal
                        : _timeLeft > 1.5 ? AppTheme.gold
                        : AppTheme.coral,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            const Spacer(),
            const Text('What COLOR is this text printed in?',
                style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
            const SizedBox(height: 24),
            // The Stroop word
            Text(_wordText,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: _wordColor,
                  letterSpacing: 3,
                )),
            const Spacer(),
            // Answer grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 2.6,
                children: _options.map((name) => GestureDetector(
                  onTap: () => _pick(name),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _palette[name]!.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _palette[name]!.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(name,
                          style: TextStyle(
                              color: _palette[name],
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ]),
          if (_showResult) GameResultOverlay(
            score: _score,
            xpEarned: _score >= 200
                ? AppConstants.xpPerPlay + AppConstants.xpPerWin
                : AppConstants.xpPerPlay,
            won: _score >= 200,
            onContinue: () => Navigator.pop(context),
            onRetry:    _restart,
          ),
        ]),
      ),
    ),
  );
}
