// lib/games/balloon_pop/balloon_pop_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class BalloonPopScreen extends StatefulWidget {
  const BalloonPopScreen({super.key});
  @override
  State<BalloonPopScreen> createState() => _BalloonPopScreenState();
}

class _Balloon {
  double x, y, speed, size;
  Color color;
  bool popped;
  _Balloon({required this.x, required this.y, required this.speed,
    required this.size, required this.color, this.popped = false});
}

class _BalloonPopScreenState extends State<BalloonPopScreen> {
  final _rng = Random();
  static const List<Color> _colors = [
    AppTheme.accent, AppTheme.teal, AppTheme.coral, AppTheme.gold, AppTheme.pink,
  ];

  List<_Balloon> _balloons = [];
  int _score = 0;
  int _missed = 0;
  int _timeLeft = 45;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _moveTimer;
  bool _showResult = false;
  bool _started = false;

  @override
  void initState() { super.initState(); _start(); }
  @override
  void dispose() {
    _gameTimer?.cancel(); _spawnTimer?.cancel(); _moveTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _started = true;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) { _endGame(); return; }
      setState(() => _timeLeft--);
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (_) => _spawn());
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _move());
  }

  void _spawn() {
    if (!mounted) return;
    setState(() => _balloons.add(_Balloon(
      x: _rng.nextDouble() * 0.85 + 0.05,
      y: 1.1,
      speed: _rng.nextDouble() * 0.008 + 0.004,
      size: _rng.nextDouble() * 30 + 40,
      color: _colors[_rng.nextInt(_colors.length)],
    )));
  }

  void _move() {
    if (!mounted) return;
    setState(() {
      for (final b in _balloons) {
        if (!b.popped) b.y -= b.speed;
      }
      final before = _balloons.length;
      _balloons.removeWhere((b) => b.y < -0.1);
      final removed = before - _balloons.length;
      _missed += removed;
    });
    if (_missed >= 5 || !mounted) _endGame();
  }

  void _pop(int idx) {
    setState(() {
      _balloons[idx].popped = true;
      _score += 10;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _balloons.removeWhere((b) => b.popped));
    });
  }

  void _endGame() {
    _gameTimer?.cancel(); _spawnTimer?.cancel(); _moveTimer?.cancel();
    if (!mounted) return;
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'balloon_pop', gameName: 'Balloon Pop',
      score: _score, timeTakenSeconds: 45, won: _score >= 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF1E3A5F)])),
        child: SafeArea(child: Stack(children: [
          Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
              child: Row(children: [
                GestureDetector(onTap: ()=>Navigator.pop(context),
                  child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.close, color: Colors.white, size: 18))),
                const SizedBox(width: 12),
                const Text('Balloon Pop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                Text('$_timeLeft s', style: TextStyle(
                  color: _timeLeft > 15 ? AppTheme.teal : AppTheme.coral, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Text('$_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
              ])),
            Padding(padding: const EdgeInsets.fromLTRB(16,8,16,0),
              child: Row(children: [
                const Text('Missed: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ...List.generate(5, (i) => Icon(
                  i < _missed ? Icons.close : Icons.circle,
                  size: 12, color: i < _missed ? AppTheme.coral : Colors.white24)),
              ])),
          ]),
          // Balloons
          for (int i = 0; i < _balloons.length; i++)
            Positioned(
              left: _balloons[i].x * size.width - _balloons[i].size / 2,
              top:  _balloons[i].y * size.height - _balloons[i].size / 2,
              child: GestureDetector(
                onTap: () => _pop(i),
                child: AnimatedScale(
                  scale: _balloons[i].popped ? 1.5 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedOpacity(
                    opacity: _balloons[i].popped ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: _balloons[i].size,
                      height: _balloons[i].size * 1.2,
                      decoration: BoxDecoration(
                        color: _balloons[i].color,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(_balloons[i].size / 2),
                          bottom: Radius.circular(_balloons[i].size / 2.5)),
                        boxShadow: [BoxShadow(color: _balloons[i].color.withOpacity(0.5),
                          blurRadius: 8)],
                      ))))),
            ),
          if (_showResult) GameResultOverlay(
            score: _score, xpEarned: _score >= 100 ? 120 : 20,
            won: _score >= 100,
            onContinue: () => Navigator.pop(context),
            onRetry: () => setState(() {
              _balloons=[]; _score=0; _missed=0; _timeLeft=45; _showResult=false; _start();
            }),
          ),
        ])),
      ),
    );
  }
}
