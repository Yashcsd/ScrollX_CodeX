// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'feed_screen.dart'; // reuse allFeedGames + FeedGame

// ─────────────────────────────────────────────────────────────────────────────
// Category filter tags
// ─────────────────────────────────────────────────────────────────────────────
const _allTags = [
  'ALL', 'ARCADE', 'PUZZLE', 'MEMORY', 'REFLEX',
  'MATH', 'WORDS', 'LOGIC', 'SKILL', 'SPEED', 'GEO', 'LIVE API',
];

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});
  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String _search = '';
  String _tag    = 'ALL';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FeedGame> get _filtered {
    return allFeedGames.where((g) {
      final matchTag    = _tag == 'ALL' || g.tag == _tag;
      final matchSearch = _search.isEmpty ||
          g.name.toLowerCase().contains(_search.toLowerCase()) ||
          g.tag.toLowerCase().contains(_search.toLowerCase());
      return matchTag && matchSearch;
    }).toList();
  }

  void _openGame(FeedGame g) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => g.buildScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        // ── Yellow header ──────────────────────────────────────────────────
        _GamesHeader(
          searchCtrl: _searchCtrl,
          onSearch: (v) => setState(() => _search = v),
        ),

        // ── Filter row ─────────────────────────────────────────────────────
        _FilterRow(
          selected: _tag,
          onSelect: (t) => setState(() => _tag = t),
        ),

        // ── Game grid ──────────────────────────────────────────────────────
        Expanded(
          child: games.isEmpty
              ? const _EmptyState()
              : _GameGrid(games: games, onTap: _openGame),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Yellow header with search
// ─────────────────────────────────────────────────────────────────────────────
class _GamesHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;

  const _GamesHeader({required this.searchCtrl, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.fromLTRB(16, top + 16, 16, 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearch,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Search for games',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppTheme.border,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const Icon(Icons.grid_view_rounded,
              color: AppTheme.textMuted, size: 22),
          const SizedBox(width: 14),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter row
// ─────────────────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _allTags.map((tag) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected == tag ? AppTheme.dark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected == tag ? AppTheme.dark : AppTheme.border,
                  width: 1.5,
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: selected == tag ? Colors.white : AppTheme.textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        )).toList(),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Game grid — masonry-style with alternating sizes
// ─────────────────────────────────────────────────────────────────────────────
class _GameGrid extends StatelessWidget {
  final List<FeedGame> games;
  final ValueChanged<FeedGame> onTap;

  const _GameGrid({required this.games, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      itemCount: (games.length / 3).ceil(),
      itemBuilder: (_, rowIdx) {
        final base = rowIdx * 3;
        final isEvenRow = rowIdx % 2 == 0;

        if (isEvenRow) {
          // Row pattern: 1 wide + 1 narrow
          final g0 = base < games.length ? games[base] : null;
          final g1 = base + 1 < games.length ? games[base + 1] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (g0 != null)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: _GameCard(game: g0, height: 160, onTap: onTap),
                    ),
                  ),
                if (g1 != null)
                  Expanded(
                    flex: 2,
                    child: _GameCard(game: g1, height: 160, onTap: onTap),
                  ),
              ],
            ),
          );
        } else {
          // Row pattern: 2 equal cards
          final g0 = base < games.length ? games[base] : null;
          final g1 = base + 1 < games.length ? games[base + 1] : null;
          final g2 = base + 2 < games.length ? games[base + 2] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                if (g0 != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: _GameCard(game: g0, height: 140, onTap: onTap),
                    ),
                  ),
                if (g1 != null)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: g2 != null ? 5.0 : 0.0),
                      child: _GameCard(game: g1, height: 140, onTap: onTap),
                    ),
                  ),
                if (g2 != null)
                  Expanded(
                    child: _GameCard(game: g2, height: 140, onTap: onTap),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual game card
// ─────────────────────────────────────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final FeedGame game;
  final double height;
  final ValueChanged<FeedGame> onTap;

  const _GameCard({
    required this.game,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onTap(game),
    child: Container(
      height: height,
      decoration: BoxDecoration(
        gradient: game.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(children: [
        // Tag badge
        Positioned(
          top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              game.tag,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),

        // Emoji + name at bottom
        Positioned(
          bottom: 10, left: 10, right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                game.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Play overlay on tap
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onTap(game),
              splashColor: Colors.white.withOpacity(0.15),
            ),
          ),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎮', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        const Text(
          'No games found',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Try a different search or filter',
          style: TextStyle(color: AppTheme.textSec, fontSize: 13),
        ),
      ],
    ),
  );
}
