// lib/games/word_scramble/word_scramble_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
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
  late List<String?> _answer;
  late List<String> _letters;
  int _score = 0, _round = 0;
  bool _showResult = false;
  String? _flash;

  @override
  void initState() { super.initState(); _load(); }

  void _load() {
    _current = _words[_rng.nextInt(_words.length)];
    final chars = _current['word']!.split('')..shuffle();
    _scrambled = chars.join();
    _letters = List.from(chars);
    _answer = List.filled(_current['word']!.length, null);
    _flash = null;
  }

  void _tapLetter(int idx) {
    final firstEmpty = _answer.indexOf(null);
    if (firstEmpty == -1) return;
    setState(() { _answer[firstEmpty] = _letters[idx]; _letters[idx] = ''; });
    _checkAnswer();
  }

  void _clearSlot(int idx) {
    if (_answer[idx] == null) return;
    final l = _answer[idx]!;
    final emptyIdx = _letters.indexOf('');
    setState(() { _answer[idx] = null; if (emptyIdx != -1) _letters[emptyIdx] = l; });
  }

  void _checkAnswer() {
    if (!_answer.contains(null) && _answer.join() == _current['word']) {
      setState(() { _flash = '✓ Correct!'; _score += 50 + (10 - _round).clamp(0,10) * 5; });
      Future.delayed(const Duration(milliseconds: 800), () {
        _round++;
        if (_round >= 5) _endGame(true);
        else setState(() => _load());
      });
    }
  }

  void _endGame(bool won) {
    setState(() { _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'word_scramble', gameName: 'Word Scramble',
      score: _score, timeTakenSeconds: 0, won: won,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: Stack(children: [
        SafeArea(bottom: false, child: Column(children: [
          GameHeader(title: '🔤 Word Scramble', actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder)),
              child: Text('Round ${_round+1}/5', style: const TextStyle(color: kTextSec, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            ScoreBadge(score: _score),
          ]),
          const SizedBox(height: 16),
          // Hint card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GameCard(child: Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: kYellow, borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('💡', style: TextStyle(fontSize: 18)))),
              const SizedBox(width: 12),
              Expanded(child: Text(_current['hint']!,
                style: const TextStyle(color: kDark, fontSize: 14, fontWeight: FontWeight.w600))),
            ])),
          ),
          const SizedBox(height: 16),
          // Scrambled word
          GameCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(children: [
              const Text('SCRAMBLED', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(_scrambled, style: const TextStyle(
                color: kYellow, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 8)),
            ]),
          ),
          const SizedBox(height: 16),
          // Answer slots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
              children: List.generate(_answer.length, (i) => GestureDetector(
                onTap: () => _clearSlot(i),
                child: Container(width: 44, height: 48,
                  decoration: BoxDecoration(
                    color: _answer[i] != null ? kYellow.withOpacity(0.15) : kGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _answer[i] != null ? kYellow : kBorder, width: 1.5)),
                  child: Center(child: Text(_answer[i] ?? '',
                    style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w800)))),
              ))),
          ),
          if (_flash != null) ...[
            const SizedBox(height: 12),
            Text(_flash!, style: TextStyle(
              color: _flash!.contains('✓') ? kTeal : kCoral,
              fontSize: 18, fontWeight: FontWeight.w700)),
          ],
          const Spacer(),
          // Letter buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
              children: List.generate(_letters.length, (i) {
                final l = _letters[i];
                return GestureDetector(
                  onTap: l.isEmpty ? null : () => _tapLetter(i),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                    width: 46, height: 50,
                    decoration: BoxDecoration(
                      color: l.isEmpty ? Colors.transparent : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: l.isEmpty ? Colors.transparent : kBorder, width: 1.5),
                      boxShadow: l.isEmpty ? null : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Center(child: Text(l, style: const TextStyle(
                      color: kDark, fontSize: 20, fontWeight: FontWeight.w800)))),
                );
              })),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() {
              _answer = List.filled(_current['word']!.length, null);
              _letters = _current['word']!.split('')..shuffle();
            }),
            icon: const Icon(Icons.refresh_rounded, size: 16, color: kTextMuted),
            label: const Text('Reset', style: TextStyle(color: kTextMuted)),
          ),
          const SizedBox(height: 16),
        ])),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: 120, won: true,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score=0; _round=0; _showResult=false; _load(); }),
        ),
      ]),
    ),
  );
}
