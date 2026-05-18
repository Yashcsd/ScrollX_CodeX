// lib/games/candy_crush/candy_crush_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class CandyCrushScreen extends StatefulWidget {
  const CandyCrushScreen({super.key});
  @override
  State<CandyCrushScreen> createState() => _CandyCrushScreenState();
}

class _CandyCrushScreenState extends State<CandyCrushScreen> {
  final _rng = Random();
  final List<String> _candies = ['🍬', '🍭', '🍫', '🍩', '🍪'];
  late List<List<String>> _grid;
  int? _selectedRow;
  int? _selectedCol;
  int _score = 0;
  int _moves = 30;
  int _target = 500;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  void _initGrid() {
    _grid = List.generate(
      8,
      (_) => List.generate(8, (_) => _candies[_rng.nextInt(_candies.length)]),
    );
    _removeInitialMatches();
  }

  void _removeInitialMatches() {
    bool hasMatches = true;
    while (hasMatches) {
      hasMatches = false;
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          if (_checkMatch(row, col)) {
            _grid[row][col] = _candies[_rng.nextInt(_candies.length)];
            hasMatches = true;
          }
        }
      }
    }
  }

  bool _checkMatch(int row, int col) {
    final candy = _grid[row][col];

    // Check horizontal
    if (col >= 2 &&
        _grid[row][col - 1] == candy &&
        _grid[row][col - 2] == candy) {
      return true;
    }

    // Check vertical
    if (row >= 2 &&
        _grid[row - 1][col] == candy &&
        _grid[row - 2][col] == candy) {
      return true;
    }

    return false;
  }

  void _onCandyTap(int row, int col) {
    if (_selectedRow == null) {
      setState(() {
        _selectedRow = row;
        _selectedCol = col;
      });
    } else {
      final rowDiff = (row - _selectedRow!).abs();
      final colDiff = (col - _selectedCol!).abs();

      if ((rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)) {
        _swapCandies(row, col);
      }

      setState(() {
        _selectedRow = null;
        _selectedCol = null;
      });
    }
  }

  void _swapCandies(int row, int col) {
    setState(() {
      final temp = _grid[row][col];
      _grid[row][col] = _grid[_selectedRow!][_selectedCol!];
      _grid[_selectedRow!][_selectedCol!] = temp;
    });

    Timer(const Duration(milliseconds: 300), () {
      if (_findMatches()) {
        _moves--;
        _processMatches();
      } else {
        // Swap back if no match
        setState(() {
          final temp = _grid[row][col];
          _grid[row][col] = _grid[_selectedRow!][_selectedCol!];
          _grid[_selectedRow!][_selectedCol!] = temp;
        });
      }

      if (_moves <= 0) {
        _endGame();
      }
    });
  }

  bool _findMatches() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_checkMatch(row, col)) return true;
      }
    }
    return false;
  }

  void _processMatches() {
    bool foundMatch = false;

    // Check horizontal matches
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 6; col++) {
        if (_grid[row][col].isNotEmpty &&
            _grid[row][col] == _grid[row][col + 1] &&
            _grid[row][col] == _grid[row][col + 2]) {
          _grid[row][col] = '';
          _grid[row][col + 1] = '';
          _grid[row][col + 2] = '';
          _score += 30;
          foundMatch = true;
        }
      }
    }

    // Check vertical matches
    for (int col = 0; col < 8; col++) {
      for (int row = 0; row < 6; row++) {
        if (_grid[row][col].isNotEmpty &&
            _grid[row][col] == _grid[row + 1][col] &&
            _grid[row][col] == _grid[row + 2][col]) {
          _grid[row][col] = '';
          _grid[row + 1][col] = '';
          _grid[row + 2][col] = '';
          _score += 30;
          foundMatch = true;
        }
      }
    }

    if (foundMatch) {
      setState(() {});
      Timer(const Duration(milliseconds: 300), () {
        _dropCandies();
        _fillEmpty();
        Timer(const Duration(milliseconds: 200), () {
          if (_findMatches()) {
            _processMatches();
          }
        });
      });
    }
  }

  void _dropCandies() {
    for (int col = 0; col < 8; col++) {
      for (int row = 7; row >= 0; row--) {
        if (_grid[row][col].isEmpty) {
          for (int above = row - 1; above >= 0; above--) {
            if (_grid[above][col].isNotEmpty) {
              _grid[row][col] = _grid[above][col];
              _grid[above][col] = '';
              break;
            }
          }
        }
      }
    }
  }

  void _fillEmpty() {
    setState(() {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          if (_grid[row][col].isEmpty) {
            _grid[row][col] = _candies[_rng.nextInt(_candies.length)];
          }
        }
      }
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'candy_crush',
      gameName: 'Candy Crush',
      score: _score,
      timeTakenSeconds: (30 - _moves) * 5,
      won: _score >= _target,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6B9D), Color(0xFFFFC371)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameHeader(
                      title: 'Candy Crush',
                      actions: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Text('$_moves moves',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        ScoreBadge(score: _score),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GameProgressBar(value: _score / _target),
                    ),
                    const SizedBox(height: 8),
                    Text('Target: $_target',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: 64,
                              itemBuilder: (context, index) {
                                final row = index ~/ 8;
                                final col = index % 8;
                                final isSelected = row == _selectedRow &&
                                    col == _selectedCol;

                                return GestureDetector(
                                  onTap: () => _onCandyTap(row, col),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? kYellow
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: isSelected
                                              ? kYellowDark
                                              : Colors.white.withOpacity(0.5),
                                          width: isSelected ? 3 : 1),
                                    ),
                                    child: Center(
                                      child: Text(_grid[row][col],
                                          style: const TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showResult)
                  GameResultOverlay(
                    score: _score,
                    xpEarned: _score >= _target ? 120 : 20,
                    won: _score >= _target,
                    onContinue: () => Navigator.pop(context),
                    onRetry: () => setState(() {
                      _score = 0;
                      _moves = 30;
                      _showResult = false;
                      _selectedRow = null;
                      _selectedCol = null;
                      _initGrid();
                    }),
                  ),
              ],
            ),
          ),
        ),
      );
}
