// lib/games/memory_match/memory_match_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});
  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  static const List<String> _emojis = [
    '🎮','🏆','⚡','🎯','🧩','🌟','🔥','💎',
  ];

  late List<String> _cards;
  late List<bool>   _flipped;
  late List<bool>   _matched;
  List<int>         _openIdx = [];
  bool  _canTap    = true;
  int   _moves     = 0;
  int   _seconds   = 0;
  bool  _won       = false;
  bool  _showResult = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _cards   = [..._emojis, ..._emojis]..shuffle();
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _openIdx = [];
    _canTap  = true;
    _moves   = 0;
    _seconds = 0;
    _won     = false;
    _showResult = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_won) setState(() => _seconds++);
    });
  }

  void _tap(int i) {
    if (!_canTap || _flipped[i] || _matched[i]) return;
    setState(() {
      _flipped[i] = true;
      _openIdx.add(i);
    });

    if (_openIdx.length == 2) {
      _canTap = false;
      _moves++;
      final a = _openIdx[0], b = _openIdx[1];

      if (_cards[a] == _cards[b]) {
        setState(() {
          _matched[a] = _matched[b] = true;
          _openIdx = [];
          _canTap  = true;
        });
        if (_matched.every((m) => m)) _onWin();
      } else {
        Future.delayed(const Duration(milliseconds: 900), () {
          setState(() {
            _flipped[a] = _flipped[b] = false;
            _openIdx = [];
            _canTap  = true;
          });
        });
      }
    }
  }

  void _onWin() {
    _timer?.cancel();
    _won = true;
    final score = (800 - _moves * 10 - _seconds * 2).clamp(100, 800);
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _showResult = true);
      context.read<UserProvider>().recordGameResult(
        gameId: 'memory_match', gameName: 'Memory Match',
        score: score, timeTakenSeconds: _seconds, won: true,
      );
    });
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2,'0')}:${sec.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final score = (800 - _moves * 10 - _seconds * 2).clamp(100, 800);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.memoryGrad),
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
                      decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Memory Match',
                      style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  Text('$_moves moves',
                      style: const TextStyle(
                          color: AppTheme.textSec, fontSize: 13)),
                  const SizedBox(width: 12),
                  Text(_fmt(_seconds),
                      style: const TextStyle(
                          color: AppTheme.teal, fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 20),
              // Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10, crossAxisSpacing: 10,
                  ),
                  itemCount: 16,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _tap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _matched[i]
                            ? AppTheme.teal.withOpacity(0.25)
                            : _flipped[i]
                                ? AppTheme.bgSurface
                                : AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _matched[i]
                            ? AppTheme.teal.withOpacity(0.6)
                            : _flipped[i]
                                ? Colors.white24
                                : AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: (_flipped[i] || _matched[i])
                              ? Text(_cards[i],
                                  key: ValueKey('o$i'),
                                  style: const TextStyle(fontSize: 28))
                              : Text('?',
                                  key: ValueKey('c$i'),
                                  style: const TextStyle(fontSize: 22,
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // New game button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _startGame()),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('New Game'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.teal,
                      side: const BorderSide(color: AppTheme.teal),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ]),
            if (_showResult) GameResultOverlay(
              score: score,
              xpEarned: AppConstants.xpPerPlay + AppConstants.xpPerWin,
              won: true,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() => _startGame()),
            ),
          ]),
        ),
      ),
    );
  }
}
