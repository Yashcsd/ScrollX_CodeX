// lib/games/typing_speed/typing_speed_screen.dart
import 'dart:async';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class TypingSpeedScreen extends StatefulWidget {
  const TypingSpeedScreen({super.key});
  @override
  State<TypingSpeedScreen> createState() => _TypingSpeedScreenState();
}

class _TypingSpeedScreenState extends State<TypingSpeedScreen> {
  static const List<String> _words = [
    'flutter','android','python','widget','database','server','network',
    'mobile','screen','button','image','scroll','stack','column','gesture',
    'stream','future','async','class','method','object','array','loop',
    'function','variable','constant','import','export','library','package',
  ];

  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<String> _wordList = [];
  int _currentIdx = 0;
  int _score = 0;
  int _errors = 0;
  int _timeLeft = 60;
  Timer? _timer;
  bool _started = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _wordList = List.from(_words)..shuffle();
    _wordList = [..._wordList, ..._wordList];
    _ctrl.addListener(_onType);
  }

  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _onType() {
    if (!_started) { _started = true; _startTimer(); }
    final typed = _ctrl.text;
    if (typed.endsWith(' ') || typed.endsWith('\n')) {
      final word = typed.trim();
      final correct = _wordList[_currentIdx];
      setState(() {
        if (word == correct) _score += 10;
        else _errors++;
        _currentIdx++;
        if (_currentIdx >= _wordList.length) {
          _wordList = [..._wordList, ..._words..shuffle()];
        }
      });
      _ctrl.clear();
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'typing_speed', gameName: 'Typing Speed',
      score: _score, timeTakenSeconds: 60, won: _score >= 150,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: Stack(children: [
        SafeArea(
          bottom: false,
          child: Column(children: [
            GameHeader(title: '⌨️ Typing Speed', actions: [ScoreBadge(score: _score)]),
            const SizedBox(height: 8),
            // Timer + progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GameProgressBar(
                value: _timeLeft / 60,
                color: _timeLeft > 20 ? kTeal : _timeLeft > 10 ? kYellow : kCoral,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(child: GameCard(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(children: [
                    const Text('TIME', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                    Text('$_timeLeft s', style: TextStyle(
                      color: _timeLeft > 20 ? kTeal : _timeLeft > 10 ? kYellow : kCoral,
                      fontSize: 20, fontWeight: FontWeight.w900)),
                  ]),
                )),
                const SizedBox(width: 12),
                Expanded(child: GameCard(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(children: [
                    const Text('ERRORS', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                    Text('$_errors', style: const TextStyle(color: kCoral, fontSize: 20, fontWeight: FontWeight.w900)),
                  ]),
                )),
              ]),
            ),
            const SizedBox(height: 12),
            // Word display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GameCard(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: List.generate(min(15, _wordList.length - _currentIdx), (i) {
                    final idx = _currentIdx + i;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: i == 0 ? kYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: i == 0 ? Border.all(color: kYellowDark) : null,
                      ),
                      child: Text(_wordList[idx],
                        style: TextStyle(
                          color: i == 0 ? kDark : kTextSec,
                          fontSize: 15,
                          fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w400,
                        )),
                    );
                  }),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                autofocus: true,
                style: const TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: _started ? 'Keep typing…' : 'Start typing to begin!',
                  hintStyle: const TextStyle(color: kTextMuted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kYellow, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                ),
              ),
            ),
          ]),
        ),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 150 ? 120 : 20, won: _score >= 150,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score = 0; _errors = 0; _timeLeft = 60; _currentIdx = 0;
            _started = false; _showResult = false; _ctrl.clear();
          }),
        ),
      ]),
    ),
  );
}
