// lib/games/snake_lite/snake_lite_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SnakeLiteScreen extends StatefulWidget {
  const SnakeLiteScreen({super.key});
  @override
  State<SnakeLiteScreen> createState() => _SnakeLiteScreenState();
}

class _SnakeLiteScreenState extends State<SnakeLiteScreen> {
  static const int _cols = 18, _rows = 22;
  final _rng = Random();

  late List<Point<int>> _snake;
  late Point<int> _food;
  Point<int> _dir = const Point(1, 0);
  Point<int>? _nextDir;
  Timer? _timer;
  int _score = 0;
  bool _gameOver = false;
  bool _showResult = false;
  bool _started = false;

  @override
  void initState() { super.initState(); _reset(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _reset() {
    _snake = [const Point(9,11), const Point(8,11), const Point(7,11)];
    _dir = const Point(1,0);
    _nextDir = null;
    _score = 0;
    _gameOver = false;
    _showResult = false;
    _started = false;
    _placeFood();
  }

  void _start() {
    _started = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 180), (_) => _tick());
  }

  void _placeFood() {
    do {
      _food = Point(_rng.nextInt(_cols), _rng.nextInt(_rows));
    } while (_snake.contains(_food));
  }

  void _tick() {
    if (_gameOver) return;
    if (_nextDir != null) { _dir = _nextDir!; _nextDir = null; }

    final head = Point(_snake.first.x + _dir.x, _snake.first.y + _dir.y);

    // Wall collision
    if (head.x < 0 || head.x >= _cols || head.y < 0 || head.y >= _rows) {
      _end(); return;
    }
    // Self collision
    if (_snake.contains(head)) { _end(); return; }

    setState(() {
      _snake.insert(0, head);
      if (head == _food) { _score += 10; _placeFood(); }
      else { _snake.removeLast(); }
    });
  }

  void _end() {
    _timer?.cancel();
    setState(() { _gameOver = true; _showResult = true; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'snake_lite', gameName: 'Snake Lite',
      score: _score, timeTakenSeconds: 0, won: _score >= 50,
    );
  }

  void _swipe(DragUpdateDetails d) {
    if (!_started) { _start(); return; }
    final dx = d.delta.dx, dy = d.delta.dy;
    if (dx.abs() > dy.abs()) {
      if (dx > 0 && _dir.x == 0) _nextDir = const Point(1,0);
      if (dx < 0 && _dir.x == 0) _nextDir = const Point(-1,0);
    } else {
      if (dy > 0 && _dir.y == 0) _nextDir = const Point(0,1);
      if (dy < 0 && _dir.y == 0) _nextDir = const Point(0,-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width - 48) / _cols;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kGameGradient),
        child: SafeArea(child: Stack(children: [
          Column(children: [
            GameHeader(
              title: 'Snake Lite',
              actions: [ScoreBadge(score: _score)],
            ),
            const SizedBox(height: 12),
            if (!_started)
              Container(margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kYellow.withOpacity(0.3)),
                ),
                child: const Text('Swipe to start & steer!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kDark, fontSize: 14, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            GestureDetector(
              onPanUpdate: _swipe,
              onTap: () { if (!_started) _start(); },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: cellSize * _rows,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [kGameShadow],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(painter: _SnakePainter(
                    snake: _snake, food: _food,
                    cols: _cols, rows: _rows, cellSize: cellSize,
                  )),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _dirBtn(Icons.arrow_upward,    () => { if (_dir.y==0) _nextDir=const Point(0,-1) }),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _dirBtn(Icons.arrow_back,      () => { if (_dir.x==0) _nextDir=const Point(-1,0) }),
              const SizedBox(width: 48),
              _dirBtn(Icons.arrow_forward,   () => { if (_dir.x==0) _nextDir=const Point(1,0) }),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _dirBtn(Icons.arrow_downward,  () => { if (_dir.y==0) _nextDir=const Point(0,1) }),
            ]),
          ]),
          if (_showResult) GameResultOverlay(
            score: _score, xpEarned: _score >= 50 ? 120 : 20,
            won: _score >= 50,
            onContinue: () => Navigator.pop(context),
            onRetry: () => setState(() => _reset()),
          ),
        ])),
      ),
    );
  }

  Widget _dirBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: () { if (!_started) _start(); fn(); },
    child: Container(width: 48, height: 48, margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [kGameShadow],
      ),
      child: Icon(icon, color: kDark, size: 22)),
  );
}

class _SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int cols, rows;
  final double cellSize;

  _SnakePainter({required this.snake, required this.food,
    required this.cols, required this.rows, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final headPaint  = Paint()..color = kYellow;
    final bodyPaint  = Paint()..color = kYellow.withOpacity(0.6);
    final foodPaint  = Paint()..color = Colors.red;

    for (int i = 0; i < snake.length; i++) {
      final p = snake[i];
      final r = Rect.fromLTWH(
        p.x * cellSize + 1, p.y * cellSize + 1,
        cellSize - 2, cellSize - 2);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)),
        i == 0 ? headPaint : bodyPaint);
    }

    final fr = Rect.fromLTWH(
      food.x * cellSize + 2, food.y * cellSize + 2,
      cellSize - 4, cellSize - 4);
    canvas.drawOval(fr, foodPaint);
  }

  @override
  bool shouldRepaint(_SnakePainter old) => true;
}
