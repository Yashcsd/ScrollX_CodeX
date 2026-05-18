// lib/games/number_crush/number_crush_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class NumberCrushScreen extends StatefulWidget {
  const NumberCrushScreen({super.key});
  @override
  State<NumberCrushScreen> createState() => _NumberCrushScreenState();
}

class _NumberCrushScreenState extends State<NumberCrushScreen> {
  final _rng = Random();
  late List<int> _grid;
  late int _target;
  List<int> _selected = [];
  int _score = 0;
  int _moves = 15;
  bool _showResult = false;

  @override
  void initState() { super.initState(); _newRound(); }

  void _newRound() {
    _grid = List.generate(16, (_) => _rng.nextInt(9) + 1);
    _target = _rng.nextInt(15) + 10;
    _selected = [];
  }

  void _tap(int idx) {
    if (_selected.contains(idx)) {
      setState(() => _selected.remove(idx));
    } else {
      setState(() => _selected.add(idx));
    }
  }

  void _submit() {
    if (_selected.isEmpty) return;
    final sum = _selected.fold<int>(0, (sum, idx) => sum + _grid[idx]);
    
    if (sum == _target) {
      setState(() {
        _score += 50 + (_selected.length * 10);
        for (final idx in _selected.reversed) {
          _grid[idx] = _rng.nextInt(9) + 1;
        }
        _target = _rng.nextInt(15) + 10;
        _selected = [];
      });
    } else {
      setState(() {
        _moves--;
        _selected = [];
        if (_moves <= 0) _endGame();
      });
    }
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'number_crush', gameName: 'Number Crush',
      score: _score, timeTakenSeconds: 0, won: _score >= 200,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Number Crush',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text('$_moves moves', style: const TextStyle(
                  color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const SizedBox(height: 20),
          
          GameCard(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Target Sum:', style: TextStyle(fontSize: 14, color: kTextMuted)),
              const SizedBox(height: 8),
              Text('$_target', style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.w900, color: kDark)),
              const SizedBox(height: 8),
              if (_selected.isNotEmpty)
                Text('Current: ${_selected.fold<int>(0, (sum, idx) => sum + _grid[idx])}',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: _selected.fold<int>(0, (sum, idx) => sum + _grid[idx]) == _target
                        ? Colors.green : kTextMuted)),
            ]),
          ),

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
                  child: Center(child: Text('${_grid[i]}',
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      color: _selected.contains(i) ? kDark : kTextMuted))),
                ),
              )),
            ),
          ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: YellowButton(
              label: 'SUBMIT',
              onTap: _submit,
            ),
          ),
          const SizedBox(height: 32),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 200 ? 120 : 20, won: _score >= 200,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() {
            _score = 0; _moves = 15; _showResult = false; _newRound();
          }),
        ),
      ])),
    ),
  );
}
