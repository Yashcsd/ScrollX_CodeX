// lib/games/slide_puzzle/slide_puzzle_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class SlidePuzzleScreen extends StatefulWidget {
  const SlidePuzzleScreen({super.key});
  @override
  State<SlidePuzzleScreen> createState() => _SlidePuzzleScreenState();
}

class _SlidePuzzleScreenState extends State<SlidePuzzleScreen> {
  static const int _size = 3;  // 3×3 grid

  late List<int> _tiles;       // [1..8, 0]  0 = empty
  int  _moves   = 0;
  int  _seconds = 0;
  bool _won     = false;
  bool _showResult = false;
  Timer? _timer;

  // Goal: 1,2,3 / 4,5,6 / 7,8,0
  static const List<int> _goal = [1,2,3,4,5,6,7,8,0];

  static const List<Color> _colors = [
    Colors.transparent,  // 0 = empty
    AppTheme.blue,       // 1
    AppTheme.teal,       // 2
    AppTheme.pink,       // 3
    AppTheme.gold,       // 4
    AppTheme.accent,     // 5
    AppTheme.coral,      // 6
    AppTheme.green,      // 7
    Color(0xFFD4537E),   // 8
  ];

  @override
  void initState() {
    super.initState();
    _startNew();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Init ──────────────────────────────────────────────────────────────────
  void _startNew() {
    _tiles   = List.generate(9, (i) => i); // [0,1..8]
    _moves   = 0;
    _seconds = 0;
    _won     = false;
    _showResult = false;
    _shuffle();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_won) setState(() => _seconds++);
    });
  }

  void _shuffle() {
    int empty = _tiles.indexOf(0);
    for (int i = 0; i < 300; i++) {
      final nb = _neighbors(empty);
      nb.shuffle();
      final next = nb.first;
      _tiles[empty] = _tiles[next];
      _tiles[next]  = 0;
      empty = next;
    }
  }

  List<int> _neighbors(int idx) {
    final row = idx ~/ _size;
    final col = idx % _size;
    final n = <int>[];
    if (row > 0)         n.add(idx - _size);
    if (row < _size - 1) n.add(idx + _size);
    if (col > 0)         n.add(idx - 1);
    if (col < _size - 1) n.add(idx + 1);
    return n;
  }

  // ── Tile tap ──────────────────────────────────────────────────────────────
  void _tap(int tileIdx) {
    if (_won) return;
    final empty = _tiles.indexOf(0);
    if (!_neighbors(empty).contains(tileIdx)) return;
    setState(() {
      _tiles[empty]   = _tiles[tileIdx];
      _tiles[tileIdx] = 0;
      _moves++;
    });
    if (_tiles.every((v) => v == _goal[_tiles.indexOf(v)])) {
      // check goal
      bool solved = true;
      for (int i = 0; i < 9; i++) {
        if (_tiles[i] != _goal[i]) { solved = false; break; }
      }
      if (solved) _onWin();
    }
  }

  int get _score => (1000 - _moves * 5 - _seconds * 2).clamp(100, 1000);

  void _onWin() {
    _timer?.cancel();
    _won = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _showResult = true);
      context.read<UserProvider>().recordGameResult(
        gameId: 'slide_puzzle', gameName: 'Slide Puzzle',
        score: _score, timeTakenSeconds: _seconds, won: true,
      );
    });
  }

  String get _timerStr {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: AppTheme.puzzleGrad),
      child: SafeArea(
        child: Stack(children: [
          Column(children: [
            _header(),
            const SizedBox(height: 16),
            _stats(),
            const Spacer(),
            _grid(),
            const Spacer(),
            _shuffleBtn(),
            const SizedBox(height: 28),
          ]),
          if (_showResult) GameResultOverlay(
            score: _score,
            xpEarned: AppConstants.xpPerPlay + AppConstants.xpPerWin,
            won: true,
            onContinue: () => Navigator.pop(context),
            onRetry: () => setState(() => _startNew()),
          ),
        ]),
      ),
    ),
  );

  Widget _header() => Padding(
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
      const Text('Slide Puzzle',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
        ),
        child: Text('Score: $_score',
            style: const TextStyle(color: AppTheme.accentLight,
                fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    ]),
  );

  Widget _stats() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _chip(Icons.touch_app, '$_moves', 'Moves'),
        _chip(Icons.timer, _timerStr, 'Time'),
      ],
    ),
  );

  Widget _chip(IconData icon, String val, String lbl) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(children: [
      Icon(icon, color: AppTheme.accentLight, size: 18),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(val, style: const TextStyle(fontSize: 16,
            fontWeight: FontWeight.w700, color: Colors.white)),
        Text(lbl, style: const TextStyle(fontSize: 10,
            color: AppTheme.textMuted)),
      ]),
    ]),
  );

  Widget _grid() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _size,
          mainAxisSpacing: 8, crossAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (_, i) {
          final v = _tiles[i];
          return GestureDetector(
            onTap: () => _tap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: v == 0 ? Colors.transparent : _colors[v],
                borderRadius: BorderRadius.circular(12),
                border: v == 0
                    ? Border.all(color: Colors.white24, width: 1.5)
                    : null,
                boxShadow: v == 0
                    ? null
                    : [BoxShadow(
                        color: _colors[v].withOpacity(0.4),
                        blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: v == 0 ? null : Center(
                child: Text('$v',
                    style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _shuffleBtn() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _startNew()),
        icon: const Icon(Icons.shuffle, size: 18),
        label: const Text('New Puzzle'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accentLight,
          side: const BorderSide(color: AppTheme.accent, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ),
  );
}
