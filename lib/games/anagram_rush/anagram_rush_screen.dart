// lib/games/anagram_rush/anagram_rush_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class AnagramRushScreen extends StatefulWidget {
  const AnagramRushScreen({super.key});
  @override
  State<AnagramRushScreen> createState() => _AnagramRushScreenState();
}

class _AnagramRushScreenState extends State<AnagramRushScreen> {
  static const List<List<String>> _groups = [
    ['RACE','CARE','ACRE'],
    ['STOP','TOPS','POTS','SPOT'],
    ['LEMON','MELON'],
    ['HEART','EARTH','HATER'],
    ['NIGHT','THING'],
    ['SMILE','LIMES','MILES'],
    ['NOTES','STONE','TONES','SNORE'],
    ['DUSTY','STUDY'],
    ['BELOW','ELBOW'],
    ['TASTE','STATE'],
  ];

  final _rng = Random();
  late List<String> _current;
  late String _show;
  final _ctrl = TextEditingController();
  int _score = 0, _round = 0, _timeLeft = 45;
  Timer? _timer;
  bool _showResult = false;
  String? _flash;

  @override
  void initState() { super.initState(); _load(); _startTimer(); }
  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  void _load() {
    _current = _groups[_rng.nextInt(_groups.length)];
    final chars = _current[0].split('')..shuffle();
    _show = chars.join();
    _ctrl.clear();
    _flash = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _check() {
    final typed = _ctrl.text.trim().toUpperCase();
    if (_current.contains(typed) && typed != _show) {
      setState(() { _flash = '✓ +${50 + _round*5} pts'; _score += 50 + _round*5; _round++; });
      Future.delayed(const Duration(milliseconds: 600), () => setState(() => _load()));
    } else {
      setState(() => _flash = '✗ Not an anagram of these letters');
      Future.delayed(const Duration(milliseconds: 800), () => setState(() => _flash = null));
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'anagram_rush', gameName: 'Anagram Rush',
      score: _score, timeTakenSeconds: 45, won: _score >= 200,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Anagram Rush',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _timeLeft > 20 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _timeLeft > 20 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                ),
                child: Text('$_timeLeft s', style: TextStyle(
                  color: _timeLeft > 20 ? Colors.green : Colors.red,
                  fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GameProgressBar(value: _timeLeft/45),
          ),
          const Spacer(),
          GameCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rearrange to make a valid word!',
                  style: TextStyle(color: kDark, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Text(_show, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900,
                  color: kDark, letterSpacing: 8)),
                if (_flash != null) ...[
                  const SizedBox(height: 12),
                  Text(_flash!, style: TextStyle(
                    color: _flash!.contains('✓') ? Colors.green : Colors.red,
                    fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: kDark, fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.w600),
                onSubmitted: (_) => _check(),
                decoration: InputDecoration(
                  hintText: 'Type word…',
                  hintStyle: const TextStyle(color: kTextMuted),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kYellow, width: 2))),
              )),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _check,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [kGameShadow],
                  ),
                  child: const Icon(Icons.check, size: 22, color: kDark)),
              ),
            ])),
          const SizedBox(height: 16),
          TextButton(onPressed: () => setState(() => _load()),
            child: const Text('Skip this word', style: TextStyle(color: kTextMuted))),
          const SizedBox(height: 16),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 200 ? 120 : 20, won: _score >= 200,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score=0; _round=0; _timeLeft=45; _showResult=false; _load(); _startTimer(); }),
        ),
      ])),
    ),
  );
}
