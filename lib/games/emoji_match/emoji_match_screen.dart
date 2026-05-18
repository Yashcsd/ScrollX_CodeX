// lib/games/emoji_match/emoji_match_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class EmojiMatchScreen extends StatefulWidget {
  const EmojiMatchScreen({super.key});
  @override
  State<EmojiMatchScreen> createState() => _EmojiMatchScreenState();
}

class _EmojiMatchScreenState extends State<EmojiMatchScreen> {
  final _rng = Random();
  static const _emojis = ['😀','😎','🥳','😍','🤩','😜','🤪','😇','🥰','😘','🤗','🤭','🤫','🤔','🤨','😏','😌','😴'];
  
  late List<String> _grid;
  List<int> _selected = [];
  int _score = 0;
  int _moves = 20;
  int _timeLeft = 90;
  Timer? _timer;
  bool _showResult = false;

  @override
  void initState() { super.initState(); _setupGrid(); _startTimer(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _setupGrid() {
    final pairs = <String>[];
    for (int i = 0; i < 8; i++) {
      final emoji = _emojis[_rng.nextInt(_emojis.length)];
      pairs.addAll([emoji, emoji]);
    }
    _grid = pairs..shuffle();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _tap(int idx) {
    if (_selected.contains(idx) || _grid[idx].isEmpty) return;
    if (_selected.length >= 2) return;

    setState(() => _selected.add(idx));

    if (_selected.length == 2) {
      _moves--;
      final a = _selected[0], b = _selected[1];
      if (_grid[a] == _grid[b]) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _score += 20;
              _grid[a] = '';
              _grid[b] = '';
              _selected = [];
              if (_grid.every((e) => e.isEmpty)) _endGame();
            });
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _selected = []);
        });
      }
      if (_moves <= 0) {
        Future.delayed(const Duration(milliseconds: 1000), () => _endGame());
      }
    }
  }

  void _endGame() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'emoji_match', gameName: 'Emoji Match',
      score: _score, timeTakenSeconds: 90, won: _score >= 160,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Emoji Match',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.withOpacity(0.3)),
                ),
                child: Text('$_moves moves', style: const TextStyle(
                  color: Colors.pink, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Match all emoji pairs!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kDark)),
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List.generate(16, (i) => GestureDetector(
                onTap: () => _tap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _selected.contains(i) ? kYellow : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [kGameShadow],
                  ),
                  child: Center(child: Text(
                    _grid[i].isEmpty ? '✓' : _grid[i],
                    style: TextStyle(
                      fontSize: _grid[i].isEmpty ? 24 : 36,
                      color: _grid[i].isEmpty ? Colors.green : null),
                  )),
                ),
              )),
            ),
          ),

          const Spacer(),
          Text('$_timeLeft s', style: TextStyle(
            color: _timeLeft > 30 ? Colors.green : Colors.red,
            fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 160 ? 120 : 20, won: _score >= 160,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score = 0; _moves = 20; _timeLeft = 90; _showResult = false;
            _selected = []; _setupGrid(); _startTimer();
          }),
        ),
      ])),
    ),
  );
}
