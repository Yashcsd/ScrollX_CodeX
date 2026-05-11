// lib/games/typing_speed/typing_speed_screen.dart
import 'dart:async';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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
        if (_currentIdx >= _wordList.length) { _wordList = [..._wordList, ..._words..shuffle()]; }
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
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A35), Color(0xFF2D1B69)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Typing Speed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('$_timeLeft s', style: TextStyle(
                color: _timeLeft > 20 ? AppTheme.teal : _timeLeft > 10 ? AppTheme.gold : AppTheme.coral,
                fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Text('$_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            ])),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _timeLeft / 60,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent), minHeight: 4)),
          const SizedBox(height: 16),
          // Word display
          Container(margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12)),
            child: Wrap(spacing: 8, runSpacing: 8,
              children: List.generate(min(15, _wordList.length - _currentIdx), (i) {
                final idx = _currentIdx + i;
                return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: i == 0 ? AppTheme.accent.withOpacity(0.25) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: i == 0 ? Border.all(color: AppTheme.accent.withOpacity(0.6)) : null),
                  child: Text(_wordList[idx],
                    style: TextStyle(color: i == 0 ? Colors.white : AppTheme.textSec, fontSize: 16,
                      fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w400)));
              }))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Words: $_currentIdx  ', style: const TextStyle(color: AppTheme.teal, fontSize: 12)),
            Text('Errors: $_errors', style: const TextStyle(color: AppTheme.coral, fontSize: 12)),
          ]),
          const Spacer(),
          Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16),
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: _started ? 'Keep typing…' : 'Start typing to begin!',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true, fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
              ),
            )),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 150 ? 120 : 20, won: _score >= 150,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score=0; _errors=0; _timeLeft=60; _currentIdx=0;
            _started=false; _showResult=false; _ctrl.clear();
          }),
        ),
      ])),
    ),
  );
}


