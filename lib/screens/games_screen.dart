// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/anti_gravity.dart';
import '../widgets/bounce_press.dart';
import '../widgets/pill_chip.dart';
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
      // Top radius 50 so yellow bleeds through cleanly at top edge (#8/#9)
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, top + 58, 20, 24), // wider side padding gives content breathing room (#3)
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [AppTheme.hardShadowSmall],
        ),
        child: Row(children: [
          const SizedBox(width: 18),
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
          const SizedBox(width: 16),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter row — uses shared PillChip (no borders, no bold shadows)
// ─────────────────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => ColoredBox(
    // No decoration/border — the white background alone with no bottom
    // decoration eliminates the unwanted underline under the chip row (#2)
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _allTags.map((tag) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PillChip(
              label: tag,
              active: selected == tag,
              onTap: () => onSelect(tag),
            ),
          )).toList(),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Game grid — uniform 2-column, every card identical shape
// ─────────────────────────────────────────────────────────────────────────────
class _GameGrid extends StatelessWidget {
  final List<FeedGame> games;
  final ValueChanged<FeedGame> onTap;

  const _GameGrid({required this.games, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: games.length,
      itemBuilder: (_, i) => _GameCard(game: games[i], onTap: onTap),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual game card — plastic icon on pastel tinted background
// Icon floats (AntiGravityWidget) inside a static card surface
// ─────────────────────────────────────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final FeedGame game;
  final ValueChanged<FeedGame> onTap;

  const _GameCard({
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => BouncePressWidget(
    onTap: () => onTap(game),
    scaleDownTo: 0.94,
    child: Container(
      decoration: BoxDecoration(
        color: game.tintBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon — floats in upper ~62% ───────────────────────────────
          Expanded(
            flex: 62,
            child: AntiGravityWidget(
              driftPixels: 1.5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Image.asset(
                  game.iconAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Name + tag pill in lower ~38% ─────────────────────────────
          Expanded(
            flex: 38,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    game.name,
                    style: const TextStyle(
                      color: AppTheme.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Tag pill — always shown on every card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: game.tintMid,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.tag,
                      style: TextStyle(
                        color: game.tintShadow,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [AppTheme.hardShadow],
          ),
          child: const Icon(
            Icons.sports_esports_rounded,
            size: 40,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 20),
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
