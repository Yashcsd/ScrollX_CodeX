// lib/games/maze_runner/maze_runner_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class MazeRunnerScreen extends StatefulWidget {
  const MazeRunnerScreen({super.key});
  @override
  State<MazeRunnerScreen> createState() => _MazeRunnerScreenState();
}

class _MazeRunnerScreenState extends State<MazeRunnerScreen> {
  final _rng = Random();
  static const _gridSize = 7;
  late List<List<int>> _maze;
  late Point<int> _player;
  late Point<int> _goal;
  int _level = 1;
  int _score = 0;
  int _moves = 0;
  int _timeLeft = 90;
  Timer? _timer;
  bool _showResult = false;
  bool _levelComplete = false;

  // Maze cell types
  static const _empty = 0;
  static const _wall = 1;
  static const _cellPlayer = 2;
  static const _cellGoal = 3;

  @override
  void initState() {
    super.initState();
    _generateMaze();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateMaze() {
    // Simple maze generation with random walls
    _maze = List.generate(_gridSize, (_) => List.filled(_gridSize, _empty));
    
    // Add random walls (more walls as level increases)
    final wallCount = 8 + (_level * 2);
    for (int i = 0; i < wallCount; i++) {
      final x = _rng.nextInt(_gridSize);
      final y = _rng.nextInt(_gridSize);
      _maze[y][x] = _wall;
    }

    // Place player at top-left
    _player = Point(0, 0);
    _maze[0][0] = _empty;

    // Place goal at bottom-right
    _goal = Point(_gridSize - 1, _gridSize - 1);
    _maze[_gridSize - 1][_gridSize - 1] = _empty;

    // Ensure path exists by clearing a simple path
    for (int i = 0; i < _gridSize; i++) {
      _maze[i][min(i, _gridSize - 1)] = _empty;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) {
        _endGame();
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _move(int dx, int dy) {
    if (_levelComplete) return;

    final newX = _player.x + dx;
    final newY = _player.y + dy;

    // Check bounds
    if (newX < 0 || newX >= _gridSize || newY < 0 || newY >= _gridSize) return;

    // Check wall
    if (_maze[newY][newX] == _wall) return;

    setState(() {
      _player = Point(newX, newY);
      _moves++;

      // Check if reached goal
      if (_player == _goal) {
        _levelComplete = true;
        final bonus = max(0, 50 - _moves);
        _score += 100 + bonus;
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_level >= 5) {
            _endGame();
          } else {
            setState(() {
              _level++;
              _moves = 0;
              _levelComplete = false;
              _generateMaze();
            });
          }
        });
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'maze_runner',
      gameName: 'Maze Runner',
      score: _score,
      timeTakenSeconds: 90 - _timeLeft,
      won: _level >= 5,
    );
  }

  Color _getCellColor(int x, int y) {
    if (_player.x == x && _player.y == y) return kYellow;
    if (_goal.x == x && _goal.y == y) return kTeal;
    if (_maze[y][x] == _wall) return kDark;
    return Colors.white;
  }

  Widget _getCellIcon(int x, int y) {
    if (_player.x == x && _player.y == y) {
      return const Icon(Icons.person_rounded, color: kDark, size: 20);
    }
    if (_goal.x == x && _goal.y == y) {
      return const Icon(Icons.flag_rounded, color: Colors.white, size: 20);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: kGameGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameHeader(
                      title: 'Maze Runner',
                      actions: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kTeal.withOpacity(0.3)),
                          ),
                          child: Text('Level $_level',
                              style: const TextStyle(
                                  color: kTeal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        ScoreBadge(score: _score),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statBadge('Moves', '$_moves', kBlue),
                          _statBadge('Time', '${_timeLeft}s',
                              _timeLeft > 30 ? kTeal : kCoral),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Maze grid
                    GameCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Navigate to the flag!',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: kTextMuted,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          AspectRatio(
                            aspectRatio: 1,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _gridSize,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: _gridSize * _gridSize,
                              itemBuilder: (context, index) {
                                final x = index % _gridSize;
                                final y = index ~/ _gridSize;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: _getCellColor(x, y),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: kBorder.withOpacity(0.3)),
                                  ),
                                  child: Center(child: _getCellIcon(x, y)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // D-pad controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          _dirButton(Icons.arrow_upward_rounded, 0, -1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _dirButton(Icons.arrow_back_rounded, -1, 0),
                              const SizedBox(width: 60),
                              _dirButton(Icons.arrow_forward_rounded, 1, 0),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _dirButton(Icons.arrow_downward_rounded, 0, 1),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
                if (_showResult)
                  GameResultOverlay(
                    score: _score,
                    xpEarned: _level >= 5 ? 120 : 20,
                    won: _level >= 5,
                    onContinue: () => Navigator.pop(context),
                    onRetry: () => setState(() {
                      _level = 1;
                      _score = 0;
                      _moves = 0;
                      _timeLeft = 90;
                      _showResult = false;
                      _levelComplete = false;
                      _generateMaze();
                      _startTimer();
                    }),
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _statBadge(String label, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [kGameShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
      );

  Widget _dirButton(IconData icon, int dx, int dy) => GestureDetector(
        onTap: () => _move(dx, dy),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: kYellow,
            shape: BoxShape.circle,
            boxShadow: [
              const BoxShadow(
                  color: kYellowDark, blurRadius: 0, offset: Offset(0, 4)),
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Icon(icon, color: kDark, size: 28),
        ),
      );
}
