// lib/games/word_scramble/word_scramble_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class WordScrambleScreen extends StatefulWidget {
  const WordScrambleScreen({super.key});
  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  static const List<Map<String,String>> _words = [
    {'word':'FLUTTER','hint':'Google UI framework'},
    {'word':'ANDROID','hint':'Mobile OS by Google'},
    {'word':'PYTHON','hint':'Snake-named language'},
    {'word':'KOTLIN','hint':'Android\'s official language'},
    {'word':'GITHUB','hint':'Code hosting platform'},
    {'word':'WIDGET','hint':'UI building block'},
    {'word':'LIBRARY','hint':'Reusable code package'},
    {'word':'DATABASE','hint':'Stores structured data'},
    {'word':'SERVER','hint':'Hosts web services'},
    {'word':'NETWORK','hint':'Connects computers'},
    {'word':'PIXEL','hint':'Smallest screen unit'},
    {'word':'BROWSER','hint':'Surfs the internet'},
    {'word':'COMPILER','hint':'Turns code to binary'},
    {'word':'OBJECT','hint':'Instance of a class'},
    {'word':'SYNTAX','hint':'Code grammar rules'},
    {'word':'DEPLOY','hint':'Launch your app'},
    {'word':'STREAM','hint':'Continuous data flow'},
    {'word':'PACKAGE','hint':'Flutter dependency'},
    {'word':'EMULATOR','hint':'Simulates a device'},
    {'word':'SCAFFOLD','hint':'Basic Flutter structure'},
  ];

  final _rng = Random();
  late Map<String,String> _current;
  late String _scrambled;
  late List<String?> _answer;   // slots
  late List<String> _letters;   // available tappable letters
  int _score = 0;
  int _round = 0;
  bool _showResult = false;
  bool _won = false;
  String? _flash;

  @override
  void initState() { super.initState(); _load(); }

  void _load() {
    _current   = _words[_rng.nextInt(_words.length)];
    final chars = _current['word']!.split('');
    chars.shuffle();
    _scrambled = chars.join();
    _letters   = List.from(chars); // each letter is tappable once
    _answer    = List.filled(_current['word']!.length, null);
    _flash     = null;
  }

  void _tapLetter(int idx) {
    final firstEmpty = _answer.indexOf(null);
    if (firstEmpty == -1) return;
    setState(() {
      _answer[firstEmpty] = _letters[idx];
      _letters[idx] = '';
    });
    _checkAnswer();
  }

  void _clearSlot(int idx) {
    if (_answer[idx] == null) return;
    final l = _answer[idx]!;
    final emptyIdx = _letters.indexOf('');
    setState(() {
      _answer[idx] = null;
      if (emptyIdx != -1) _letters[emptyIdx] = l;
    });
  }

  void _checkAnswer() {
    final attempt = _answer.join();
    if (!_answer.contains(null) && attempt == _current['word']) {
      setState(() { _flash = '✓ Correct!'; _score += 50 + (10 - _round).clamp(0,10) * 5; });
      Future.delayed(const Duration(milliseconds: 800), () {
        _round++;
        if (_round >= 5) {
          _endGame(true);
        } else {
          setState(() => _load());
        }
      });
    }
  }

  void _endGame(bool won) {
    setState(() { _won = won; _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'word_scramble', gameName: 'Word Scramble',
      score: _score, timeTakenSeconds: 0, won: won,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1B1035), Color(0xFF3D1A78)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Word Scramble', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('Round ${_round+1}/5', style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
              const SizedBox(width: 12),
              Text('$_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            ])),
          const SizedBox(height: 24),
          // Hint
          Container(margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12)),
            child: Row(children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(_current['hint']!, style: const TextStyle(color: AppTheme.accentLight, fontSize: 14)),
            ])),
          const SizedBox(height: 24),
          // Scrambled word display
          Text('Scrambled:', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(_scrambled, style: const TextStyle(color: AppTheme.accent, fontSize: 28,
            fontWeight: FontWeight.w800, letterSpacing: 6)),
          const SizedBox(height: 30),
          // Answer slots
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
              children: List.generate(_answer.length, (i) => GestureDetector(
                onTap: () => _clearSlot(i),
                child: Container(width: 44, height: 48,
                  decoration: BoxDecoration(
                    color: _answer[i] != null ? AppTheme.accent.withOpacity(0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _answer[i] != null ? AppTheme.accent : Colors.white24, width: 1.5)),
                  child: Center(child: Text(_answer[i] ?? '', style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)))))))),
          if (_flash != null) ...[
            const SizedBox(height: 16),
            Text(_flash!, style: const TextStyle(color: AppTheme.teal, fontSize: 20, fontWeight: FontWeight.w700)),
          ],
          const Spacer(),
          // Letter buttons
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10,
              children: List.generate(_letters.length, (i) {
                final l = _letters[i];
                return GestureDetector(
                  onTap: l.isEmpty ? null : () => _tapLetter(i),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                    width: 46, height: 50,
                    decoration: BoxDecoration(
                      color: l.isEmpty ? Colors.transparent : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: l.isEmpty ? Colors.transparent : Colors.white24)),
                    child: Center(child: Text(l, style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)))));
              }))),
          const SizedBox(height: 20),
          TextButton.icon(onPressed: () => setState(() {
            _answer = List.filled(_current['word']!.length, null);
            _letters = _current['word']!.split('');
            _letters.shuffle();
          }),
            icon: const Icon(Icons.refresh, size: 16, color: AppTheme.textMuted),
            label: const Text('Reset', style: TextStyle(color: AppTheme.textMuted))),
          const SizedBox(height: 16),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _won ? 120 : 20, won: _won,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score=0; _round=0; _showResult=false; _load(); }),
        ),
      ])),
    ),
  );
}
