// lib/games/stack_tower/stack_tower_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class StackTowerScreen extends StatefulWidget {
  const StackTowerScreen({super.key});
  @override
  State<StackTowerScreen> createState() => _StackTowerScreenState();
}

class _StackTowerScreenState extends State<StackTowerScreen> {
  List<Block> _blocks = [];
  double _currentX = -0.8;
  double _currentWidth = 0.4;
  int _direction = 1;
  int _score = 0;
  Timer? _timer;
  bool _gameOver = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _blocks.add(Block(x: 0.0, width: 0.4, y: 0.9));
    _startMoving();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMoving() {
    _timer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      if (_gameOver) return;

      setState(() {
        _currentX += _direction * 0.015;
        if (_currentX > 0.8 || _currentX < -0.8) {
          _direction *= -1;
        }
      });
    });
  }

  void _dropBlock() {
    if (_gameOver) return;

    final lastBlock = _blocks.last;
    final overlap = _calculateOverlap(lastBlock);

    if (overlap <= 0.05) {
      _endGame();
      return;
    }

    setState(() {
      // Calculate new block position
      final leftEdge1 = lastBlock.x - lastBlock.width / 2;
      final rightEdge1 = lastBlock.x + lastBlock.width / 2;
      final leftEdge2 = _currentX - _currentWidth / 2;
      final rightEdge2 = _currentX + _currentWidth / 2;

      final overlapLeft = leftEdge1 > leftEdge2 ? leftEdge1 : leftEdge2;
      final overlapRight = rightEdge1 < rightEdge2 ? rightEdge1 : rightEdge2;
      
      final newWidth = overlapRight - overlapLeft;
      final newX = (overlapLeft + overlapRight) / 2;
      final newY = lastBlock.y - 0.08;

      _blocks.add(Block(x: newX, width: newWidth, y: newY));
      _currentWidth = newWidth;
      _currentX = _direction > 0 ? -0.8 : 0.8;
      _score++;
    });
  }

  double _calculateOverlap(Block lastBlock) {
    final leftEdge1 = lastBlock.x - lastBlock.width / 2;
    final rightEdge1 = lastBlock.x + lastBlock.width / 2;
    final leftEdge2 = _currentX - _currentWidth / 2;
    final rightEdge2 = _currentX + _currentWidth / 2;

    final overlapLeft = leftEdge1 > leftEdge2 ? leftEdge1 : leftEdge2;
    final overlapRight = rightEdge1 < rightEdge2 ? rightEdge1 : rightEdge2;

    return overlapRight - overlapLeft;
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gameOver = true;
      _showResult = true;
    });
    context.read<UserProvider>().recordGameResult(
      gameId: 'stack_tower',
      gameName: 'Stack Tower',
      score: _score * 10,
      timeTakenSeconds: _score * 2,
      won: _score >= 20,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onTap: _dropBlock,
          child: Container(
            decoration: const BoxDecoration(gradient: kGameGradient),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      GameHeader(
                        title: 'Stack Tower',
                        actions: [ScoreBadge(score: _score)],
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;

                            return Stack(
                              children: [
                                // Stacked blocks
                                ..._blocks.map((block) => Positioned(
                                      left: width / 2 +
                                          block.x * width / 2 -
                                          block.width * width / 4,
                                      top: height * block.y,
                                      child: Container(
                                        width: block.width * width / 2,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              _getBlockColor(_blocks.indexOf(block)),
                                              _getBlockColor(_blocks.indexOf(block))
                                                  .withOpacity(0.7),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          boxShadow: [kGameShadow],
                                        ),
                                      ),
                                    )),

                                // Moving block
                                if (!_gameOver)
                                  Positioned(
                                    left: width / 2 +
                                        _currentX * width / 2 -
                                        _currentWidth * width / 4,
                                    top: height *
                                        (_blocks.last.y - 0.08),
                                    child: Container(
                                      width: _currentWidth * width / 2,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: kYellow,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                              color: kYellow.withOpacity(0.5),
                                              blurRadius: 15,
                                              spreadRadius: 3),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Instructions
                                if (_blocks.length == 1)
                                  Center(
                                    child: GameCard(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text('Tap to Stack!',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  color: kDark)),
                                          SizedBox(height: 8),
                                          Text('Perfect timing = higher tower',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: kTextMuted)),
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
                      score: _score * 10,
                      xpEarned: _score >= 20 ? 120 : 20,
                      won: _score >= 20,
                      onContinue: () => Navigator.pop(context),
                      onRetry: () => setState(() {
                        _blocks.clear();
                        _blocks.add(Block(x: 0.0, width: 0.4, y: 0.9));
                        _currentX = -0.8;
                        _currentWidth = 0.4;
                        _direction = 1;
                        _score = 0;
                        _gameOver = false;
                        _showResult = false;
                        _startMoving();
                      }),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

  Color _getBlockColor(int index) {
    final colors = [kTeal, kBlue, kPink, kCoral, Colors.purple, Colors.orange];
    return colors[index % colors.length];
  }
}

class Block {
  double x, width, y;
  Block({required this.x, required this.width, required this.y});
}
