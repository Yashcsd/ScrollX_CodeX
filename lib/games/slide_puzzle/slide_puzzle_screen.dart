// lib/games/slide_puzzle/slide_puzzle_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SlidePuzzleScreen extends StatefulWidget {
  const SlidePuzzleScreen({super.key});
  @override
  State<SlidePuzzleScreen> createState() => _SlidePuzzleScreenState();
}

class _SlidePuzzleScreenState extends State<SlidePuzzleScreen> {
  static const int _size = 3;
  late List<int> _tiles;
  int _moves = 0, _seconds = 0;
  bool _won = false, _showResult = false;
  Timer? _timer;
  static const List<int> _goal = [1,2,3,4,5,6,7,8,0];

  static const List<Color> _tileColors = [
    Colors.transparent,
    Color(0xFF7F77DD), Color(0xFF1D9E75), Color(0xFFD4537E),
    Color(0xFFE4D400), Color(0xFF378ADD), Color(0xFFD85A30),
    Color(0xFF639922), Color(0xFFD4537E),
  ];

  @override
  void initState() { super.initState(); _startNew(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startNew() {
    _tiles = List.generate(9, (i) => i);
    _moves = 0; _seconds = 0; _won = false; _showResult = false;
    _shuffle();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_won) setState(() => _seconds++);
    });
  }

  void _shuffle() {
    int empty = _tiles.indexOf(0);
    for (int i = 0; i < 300; i++) {
      final nb = _neighbors(empty)..shuffle();
      final next = nb.first;
      _tiles[empty] = _tiles[next]; _tiles[next] = 0; empty = next;
    }
  }

  List<int> _neighbors(int idx) {
    final r = idx ~/ _size, c = idx % _size;
    return [
      if (r > 0) idx - _size, if (r < _size-1) idx + _size,
      if (c > 0) idx - 1,     if (c < _size-1) idx + 1,
    ];
  }

  void _tap(int i) {
    if (_won) return;
    final empty = _tiles.indexOf(0);
    if (!_neighbors(empty).contains(i)) return;
    setState(() { _tiles[empty] = _tiles[i]; _tiles[i] = 0; _moves++; });
    bool solved = true;
    for (int j = 0; j < 9; j++) { if (_tiles[j] != _goal[j]) { solved = false; break; } }
    if (solved) _onWin();
  }

  int get _score => (1000 - _moves * 5 - _seconds * 2).clamp(100, 1000);

  void _onWin() {
    _timer?.cancel(); _won = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _showResult = true);
      context.read<UserProvider>().recordGameResult(
        gameId: 'slide_puzzle', gameName: 'Slide Puzzle',
        score: _score, timeTakenSeconds: _seconds, won: true,
      );
    });
  }

  String get _timerStr {
    final m = _seconds ~/ 60, s = _seconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: Stack(children: [
        SafeArea(
          bottom: false,
          child: Column(children: [
            GameHeader(title: '🧩 Slide Puzzle', actions: [ScoreBadge(score: _score)]),
            const SizedBox(height: 20),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(child: GameCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(children: [
                    const Text('MOVES', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('$_moves', style: const TextStyle(color: kDark, fontSize: 22, fontWeight: FontWeight.w900)),
                  ]),
                )),
                const SizedBox(width: 12),
                Expanded(child: GameCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(children: [
                    const Text('TIME', style: TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(_timerStr, style: const TextStyle(color: kDark, fontSize: 22, fontWeight: FontWeight.w900)),
                  ]),
                )),
              ]),
            ),
            const SizedBox(height: 24),
            // Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _size, mainAxisSpacing: 6, crossAxisSpacing: 6),
                    itemCount: 9,
                    itemBuilder: (_, i) {
                      final v = _tiles[i];
                      return GestureDetector(
                        onTap: () => _tap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(
                            color: v == 0 ? kGray : _tileColors[v],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: v == 0 ? null : [
                              BoxShadow(color: _tileColors[v].withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: v == 0 ? null : Center(
                            child: Text('$v', style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: OutlineButton(label: 'New Puzzle', icon: Icons.shuffle_rounded, onTap: () => setState(() => _startNew())),
            ),
          ]),
        ),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: 120, won: true,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() => _startNew()),
        ),
      ]),
    ),
  );
}
