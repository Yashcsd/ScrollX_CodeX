// lib/games/falling_catch/falling_catch_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class FallingCatchScreen extends StatefulWidget {
  const FallingCatchScreen({super.key});
  @override
  State<FallingCatchScreen> createState() => _FallingCatchScreenState();
}

class _FallingItem {
  double x, y, speed;
  String emoji;
  bool caught;
  _FallingItem({required this.x, required this.y, required this.speed, required this.emoji, this.caught = false});
}

class _FallingCatchScreenState extends State<FallingCatchScreen> {
  final _rng = Random();
  static const _good = ['⭐','💎','🏆','💰','🎯'];
  static const _bad  = ['💣','☠️','🔥'];
  List<_FallingItem> _items = [];
  double _basketX = 0.5;
  int _score = 0, _lives = 3, _timeLeft = 60;
  Timer? _gameTimer, _spawnTimer, _moveTimer;
  bool _showResult = false;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _start()); }
  @override
  void dispose() { _gameTimer?.cancel(); _spawnTimer?.cancel(); _moveTimer?.cancel(); super.dispose(); }

  void _start() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      setState(() => _items.add(_FallingItem(
        x: _rng.nextDouble() * 0.85 + 0.05,
        y: 0,
        speed: _rng.nextDouble() * 0.012 + 0.008,
        emoji: _rng.nextDouble() < 0.25 ? _bad[_rng.nextInt(_bad.length)] : _good[_rng.nextInt(_good.length)],
      )));
    });
    _moveTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted) return;
      setState(() {
        for (final item in _items) {
          item.y += item.speed;
          // Check basket catch
          if (!item.caught && item.y > 0.85 && item.y < 0.95 &&
              (item.x - _basketX).abs() < 0.12) {
            item.caught = true;
            if (_bad.contains(item.emoji)) { _lives--; if (_lives <= 0) _endGame(); }
            else _score += 20;
          }
        }
        _items.removeWhere((i) => i.y > 1.1 || i.caught);
      });
    });
  }

  void _endGame() {
    _gameTimer?.cancel(); _spawnTimer?.cancel(); _moveTimer?.cancel();
    if (!mounted) return;
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'falling_catch', gameName: 'Falling Catch',
      score: _score, timeTakenSeconds: 60, won: _score >= 150,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (d) => setState(() {
          _basketX = (_basketX + d.delta.dx / size.width).clamp(0.08, 0.92);
        }),
        onPanUpdate: (d) => setState(() {
          _basketX = (_basketX + d.delta.dx / size.width).clamp(0.08, 0.92);
        }),
        child: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1E), Color(0xFF1A1A3E)])),
          child: SafeArea(child: Stack(children: [
            // Header
            Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
              child: Row(children: [
                GestureDetector(onTap: ()=>Navigator.pop(context),
                  child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.close, color: Colors.white, size: 18))),
                const SizedBox(width: 12),
                const Text('Falling Catch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                Row(children: List.generate(3, (i) => Icon(
                  Icons.favorite, size: 18, color: i < _lives ? AppTheme.pink : Colors.white12))),
                const SizedBox(width: 12),
                Text('$_score', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 16)),
              ])),
            // Falling items
            for (final item in _items)
              Positioned(
                left: item.x * size.width - 18,
                top:  item.y * size.height,
                child: Text(item.emoji, style: const TextStyle(fontSize: 32))),
            // Basket
            Positioned(
              left: _basketX * size.width - 36,
              bottom: size.height * 0.1,
              child: const Text('🧺', style: TextStyle(fontSize: 52))),
            // Timer
            Positioned(bottom: 20, left: 0, right: 0,
              child: Center(child: Text('$_timeLeft s', style: TextStyle(
                color: _timeLeft > 15 ? AppTheme.teal : AppTheme.coral,
                fontSize: 14, fontWeight: FontWeight.w700)))),
            if (_showResult) GameResultOverlay(
              score: _score, xpEarned: _score >= 150 ? 120 : 20, won: _score >= 150,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _items=[]; _score=0; _lives=3; _timeLeft=60; _showResult=false; _start();
              }),
            ),
          ])),
        ),
      ),
    );
  }
}
