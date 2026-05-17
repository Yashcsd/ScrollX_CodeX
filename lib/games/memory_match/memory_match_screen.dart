// lib/games/memory_match/memory_match_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});
  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  static const List<String> _emojis = ['🎮','🏆','⚡','🎯','🧩','🌟','🔥','💎'];
  late List<String> _cards;
  late List<bool> _flipped, _matched;
  List<int> _openIdx = [];
  bool _canTap = true;
  int _moves = 0, _seconds = 0;
  bool _won = false, _showResult = false;
  Timer? _timer;

  @override
  void initState() { super.initState(); _startGame(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startGame() {
    _cards = [..._emojis, ..._emojis]..shuffle();
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _openIdx = []; _canTap = true; _moves = 0; _seconds = 0;
    _won = false; _showResult = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_won) setState(() => _seconds++);
    });
  }

  void _tap(int i) {
    if (!_canTap || _flipped[i] || _matched[i]) return;
    setState(() { _flipped[i] = true; _openIdx.add(i); });
    if (_openIdx.length == 2) {
      _canTap = false; _moves++;
      final a = _openIdx[0], b = _openIdx[1];
      if (_cards[a] == _cards[b]) {
        setState(() { _matched[a] = _matched[b] = true; _openIdx = []; _canTap = true; });
        if (_matched.every((m) => m)) _onWin();
      } else {
        Future.delayed(const Duration(milliseconds: 900), () {
          setState(() { _flipped[a] = _flipped[b] = false; _openIdx = []; _canTap = true; });
        });
      }
    }
  }

  void _onWin() {
    _timer?.cancel(); _won = true;
    final score = (800 - _moves * 10 - _seconds * 2).clamp(100, 800);
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _showResult = true);
      context.read<UserProvider>().recordGameResult(
        gameId: 'memory_match', gameName: 'Memory Match',
        score: score, timeTakenSeconds: _seconds, won: true,
      );
    });
  }

  String _fmt(int s) => '${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final score = (800 - _moves * 10 - _seconds * 2).clamp(100, 800);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(gradient: kGameGradient),
        child: Stack(children: [
          SafeArea(
            bottom: false,
            child: Column(children: [
              GameHeader(title: '🃏 Memory Match', actions: [ScoreBadge(score: score)]),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: GameCard(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      const Text('MOVES', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('$_moves', style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900)),
                    ]),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: GameCard(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      const Text('TIME', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text(_fmt(_seconds), style: const TextStyle(color: kDark, fontSize: 20, fontWeight: FontWeight.w900)),
                    ]),
                  )),
                ]),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: 16,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _tap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _matched[i] ? kTeal.withOpacity(0.15)
                              : _flipped[i] ? kYellow.withOpacity(0.2) : kGray,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _matched[i] ? kTeal : _flipped[i] ? kYellow : kBorder,
                            width: 1.5),
                        ),
                        child: Center(child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: (_flipped[i] || _matched[i])
                              ? Text(_cards[i], key: ValueKey('o$i'), style: const TextStyle(fontSize: 26))
                              : Text('?', key: ValueKey('c$i'), style: const TextStyle(
                                  fontSize: 20, color: kTextMuted, fontWeight: FontWeight.w700)),
                        )),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: OutlineButton(label: 'New Game', icon: Icons.refresh_rounded, onTap: () => setState(() => _startGame())),
              ),
            ]),
          ),
          if (_showResult) GameResultOverlay(
            score: score, xpEarned: 120, won: true,
            onContinue: () => Navigator.pop(context),
            onRetry: () => setState(() => _startGame()),
          ),
        ]),
      ),
    );
  }
}
