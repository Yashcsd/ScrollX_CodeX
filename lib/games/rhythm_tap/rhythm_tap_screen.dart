// lib/games/rhythm_tap/rhythm_tap_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class RhythmTapScreen extends StatefulWidget {
  const RhythmTapScreen({super.key});
  @override
  State<RhythmTapScreen> createState() => _RhythmTapScreenState();
}

class _Note {
  double y;
  int lane;
  bool hit;
  _Note({required this.y, required this.lane, this.hit = false});
}

class _RhythmTapScreenState extends State<RhythmTapScreen> {
  final _rng = Random();
  List<_Note> _notes = [];
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _missed = 0;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  bool _started = false;
  bool _showResult = false;
  int _timeLeft = 60;

  @override
  void dispose() { _gameTimer?.cancel(); _spawnTimer?.cancel(); super.dispose(); }

  void _start() {
    _started = true;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) _endGame();
      else setState(() => _timeLeft--);
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (_) => _spawn());
    Timer.periodic(const Duration(milliseconds: 30), (_) => _move());
  }

  void _spawn() {
    if (!mounted) return;
    setState(() => _notes.add(_Note(y: 0, lane: _rng.nextInt(4))));
  }

  void _move() {
    if (!mounted) return;
    setState(() {
      for (final note in _notes) {
        if (!note.hit) note.y += 0.015;
      }
      final before = _notes.length;
      _notes.removeWhere((n) => n.y > 1.1);
      final removed = before - _notes.length;
      if (removed > 0) {
        _missed += removed;
        _combo = 0;
      }
    });
  }

  void _tap(int lane) {
    HapticFeedback.lightImpact();
    if (!_started) { _start(); return; }
    
    final hitZone = _notes.where((n) => n.lane == lane && !n.hit && n.y > 0.75 && n.y < 0.95).toList();
    if (hitZone.isNotEmpty) {
      final note = hitZone.first;
      setState(() {
        note.hit = true;
        _score += 10 + (_combo * 2);
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _notes.remove(note));
      });
    } else {
      setState(() => _combo = 0);
    }
  }

  void _endGame() {
    _gameTimer?.cancel(); _spawnTimer?.cancel();
    if (!mounted) return;
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'rhythm_tap', gameName: 'Rhythm Tap',
      score: _score, timeTakenSeconds: 60, won: _score >= 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kGameGradient),
        child: SafeArea(child: Stack(children: [
          GameHeader(
            title: 'Rhythm Tap',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Text('x$_combo', style: const TextStyle(
                  color: Colors.purple, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),

          if (!_started)
            Center(child: GameCard(
              child: Column(mainAxisSize: MainAxisSize.min, children: const [
                Text('🎵', style: TextStyle(fontSize: 60)),
                SizedBox(height: 16),
                Text('Tap the Beat!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kDark)),
                SizedBox(height: 8),
                Text('Hit notes when they reach the line', style: TextStyle(fontSize: 14, color: kTextMuted)),
              ]),
            )),

          // Lanes
          if (_started)
            Positioned.fill(
              child: Row(children: List.generate(4, (i) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.white.withOpacity(0.2))),
                  ),
                ),
              ))),
            ),

          // Hit line
          if (_started)
            Positioned(
              bottom: size.height * 0.15,
              left: 0, right: 0,
              child: Container(height: 3, color: kYellow),
            ),

          // Notes
          for (final note in _notes)
            Positioned(
              left: (size.width / 4) * note.lane + (size.width / 8) - 20,
              top: size.height * note.y,
              child: AnimatedOpacity(
                opacity: note.hit ? 0 : 1,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 8)],
                  ),
                ),
              ),
            ),

          // Tap buttons
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: Row(children: List.generate(4, (i) => Expanded(
              child: GestureDetector(
                onTap: () => _tap(i),
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.touch_app, color: Colors.white, size: 32)),
                ),
              ),
            ))),
          ),

          if (_started)
            Positioned(
              top: 100, left: 0, right: 0,
              child: Center(child: Text('$_timeLeft s', style: TextStyle(
                color: _timeLeft > 20 ? Colors.green : Colors.red,
                fontSize: 16, fontWeight: FontWeight.w700))),
            ),

          if (_showResult) GameResultOverlay(
            score: _score, xpEarned: _score >= 300 ? 120 : 20, won: _score >= 300,
            onContinue: () => Navigator.pop(context),
            onRetry: () => setState(() {
              _notes = []; _score = 0; _combo = 0; _maxCombo = 0; _missed = 0;
              _timeLeft = 60; _started = false; _showResult = false;
            }),
          ),
        ])),
      ),
    );
  }
}
