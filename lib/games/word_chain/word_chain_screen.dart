// lib/games/word_chain/word_chain_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class WordChainScreen extends StatefulWidget {
  const WordChainScreen({super.key});
  @override
  State<WordChainScreen> createState() => _WordChainScreenState();
}

class _WordChainScreenState extends State<WordChainScreen> {
  final _rng = Random();
  static const _words = [
    'APPLE', 'ELEPHANT', 'TABLE', 'ENERGY', 'YELLOW', 'WATER', 'ROBOT', 'TIGER',
    'RADIO', 'ORANGE', 'EARTH', 'HOUSE', 'EAGLE', 'LEMON', 'NIGHT', 'TRAIN',
  ];

  late String _currentWord;
  late List<String> _options;
  int _score = 0;
  int _chain = 0;
  int _timeLeft = 60;
  Timer? _timer;
  bool _showResult = false;
  String? _flash;

  @override
  void initState() { super.initState(); _newRound(); _startTimer(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _newRound() {
    _currentWord = _words[_rng.nextInt(_words.length)];
    final lastLetter = _currentWord[_currentWord.length - 1];
    
    // Find words starting with last letter
    final validWords = _words.where((w) => w[0] == lastLetter && w != _currentWord).toList();
    final invalidWords = _words.where((w) => w[0] != lastLetter && w != _currentWord).toList();
    
    _options = [];
    if (validWords.isNotEmpty) {
      _options.add(validWords[_rng.nextInt(validWords.length)]);
    }
    while (_options.length < 3 && invalidWords.isNotEmpty) {
      final word = invalidWords[_rng.nextInt(invalidWords.length)];
      if (!_options.contains(word)) _options.add(word);
    }
    _options.shuffle();
    _flash = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _pick(String word) {
    final correct = word[0] == _currentWord[_currentWord.length - 1];
    setState(() {
      _flash = correct ? '✓ Chain!' : '✗ Broken!';
      if (correct) {
        _score += 15 + (_chain * 5);
        _chain++;
      } else {
        _chain = 0;
      }
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() { _currentWord = word; _newRound(); });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'word_chain', gameName: 'Word Chain',
      score: _score, timeTakenSeconds: 60, won: _score >= 200,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Word Chain',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kYellow.withOpacity(0.3)),
                ),
                child: Text('Chain: $_chain', style: const TextStyle(
                  color: kDark, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const Spacer(),
          const Text('Pick a word starting with the last letter!', 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kDark)),
          const SizedBox(height: 32),
          
          GameCard(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Current Word:', style: TextStyle(fontSize: 14, color: kTextMuted)),
              const SizedBox(height: 12),
              Text(_currentWord, style: const TextStyle(
                fontSize: 36, fontWeight: FontWeight.w900, color: kDark, letterSpacing: 4)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Ends with: ${_currentWord[_currentWord.length - 1]}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDark)),
              ),
            ]),
          ),

          if (_flash != null) ...[
            const SizedBox(height: 16),
            Text(_flash!, style: TextStyle(
              color: _flash!.contains('✓') ? Colors.green : Colors.red,
              fontSize: 18, fontWeight: FontWeight.w700)),
          ],

          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: _options.map((word) => GestureDetector(
              onTap: () => _pick(word),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [kGameShadow],
                ),
                child: Center(child: Text(word, style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: kDark, letterSpacing: 2))),
              ),
            )).toList()),
          ),
          const SizedBox(height: 16),
          Text('$_timeLeft s', style: TextStyle(
            color: _timeLeft > 20 ? Colors.green : Colors.red,
            fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 200 ? 120 : 20, won: _score >= 200,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score = 0; _chain = 0; _timeLeft = 60; _showResult = false; _newRound(); _startTimer();
          }),
        ),
      ])),
    ),
  );
}
