// lib/games/fruit_ninja/fruit_ninja_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class FruitNinjaScreen extends StatefulWidget {
  const FruitNinjaScreen({super.key});
  @override
  State<FruitNinjaScreen> createState() => _FruitNinjaScreenState();
}

class _FruitNinjaScreenState extends State<FruitNinjaScreen> {
  final _rng = Random();
  final List<String> _fruits = ['🍎', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🥝'];
  List<FruitItem> _items = [];
  int _score = 0;
  int _lives = 3;
  int _combo = 0;
  Timer? _timer;
  bool _showResult = false;

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
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      setState(() {
        // Update fruit positions
        for (var item in _items) {
          item.y += item.velocityY;
          item.velocityY += 0.015; // Gravity
          item.x += item.velocityX;
        }

        // Remove off-screen items
        final missed = _items.where((item) => item.y > 1.2 && !item.sliced).toList();
        for (var item in missed) {
          if (item.emoji != '💣') {
            _lives--;
            _combo = 0;
            if (_lives <= 0) {
              _endGame();
              return;
            }
          }
        }
        _items.removeWhere((item) => item.y > 1.2 || item.sliced);

        // Spawn new items
        if (_items.length < 5 && _rng.nextDouble() < 0.05) {
          final isBomb = _rng.nextDouble() < 0.15;
          _items.add(FruitItem(
            emoji: isBomb ? '💣' : _fruits[_rng.nextInt(_fruits.length)],
            x: _rng.nextDouble() * 1.6 - 0.8,
            y: 1.2,
            velocityX: (_rng.nextDouble() - 0.5) * 0.02,
            velocityY: -0.04 - _rng.nextDouble() * 0.02,
          ));
        }
      });
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final width = box.size.width;
    final height = box.size.height;

    final tapX = (localPosition.dx - width / 2) / (width / 2);
    final tapY = (localPosition.dy - height / 2) / (height / 2);

    setState(() {
      for (var item in List.from(_items)) {
        if (!item.sliced &&
            (item.x - tapX).abs() < 0.2 &&
            (item.y - tapY).abs() < 0.2) {
          item.sliced = true;
          if (item.emoji == '💣') {
            _lives = 0;
            _endGame();
            return;
          } else {
            _combo++;
            _score += 10 + (_combo * 2);
          }
        }
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'fruit_ninja',
      gameName: 'Fruit Ninja',
      score: _score,
      timeTakenSeconds: _score ~/ 10,
      won: _score >= 300,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE5B4), Color(0xFFFFD700)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      GameHeader(
                        title: 'Fruit Ninja',
                        actions: [
                          if (_combo > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.orange.withOpacity(0.6)),
                              ),
                              child: Text('x$_combo',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900)),
                            ),
                          const SizedBox(width: 8),
                          LivesRow(lives: _lives, total: 3),
                          const SizedBox(width: 8),
                          ScoreBadge(score: _score),
                        ],
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;

                            return Stack(
                              children: [
                                // Fruits and bombs
                                ..._items.map((item) => Positioned(
                                      left: width / 2 + item.x * width / 2 - 30,
                                      top: height / 2 + item.y * height / 2 - 30,
                                      child: Transform.rotate(
                                        angle: item.sliced ? pi / 4 : 0,
                                        child: Opacity(
                                          opacity: item.sliced ? 0.3 : 1.0,
                                          child: Text(
                                            item.emoji,
                                            style: const TextStyle(fontSize: 60),
                                          ),
                                        ),
                                      ),
                                    )),

                                // Instructions
                                Center(
                                  child: Opacity(
                                    opacity: 0.3,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text('Swipe to Slice!',
                                            style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white)),
                                        SizedBox(height: 8),
                                        Text('Avoid bombs 💣',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_showResult)
                    GameResultOverlay(
                      score: _score,
                      xpEarned: _score >= 300 ? 120 : 20,
                      won: _score >= 300,
                      onContinue: () => Navigator.pop(context),
                      onRetry: () => setState(() {
                        _items.clear();
                        _score = 0;
                        _lives = 3;
                        _combo = 0;
                        _showResult = false;
                        _startGame();
                      }),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class FruitItem {
  String emoji;
  double x, y;
  double velocityX, velocityY;
  bool sliced;

  FruitItem({
    required this.emoji,
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    this.sliced = false,
  });
}
