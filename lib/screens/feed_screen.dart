// lib/screens/feed_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/game_social_metadata.dart';
import '../services/game_social_service.dart';
import '../services/user_provider.dart';
import '../services/haptics_service.dart';
import '../services/audio_service.dart';
import '../widgets/anti_gravity.dart';
import '../widgets/bounce_press.dart';
import '../widgets/social_engagement_panel.dart';

import '../games/slide_puzzle/slide_puzzle_screen.dart';
import '../games/trivia_quiz/trivia_quiz_screen.dart';
import '../games/memory_match/memory_match_screen.dart';
import '../games/color_match/color_match_screen.dart';
import '../games/math_blitz/math_blitz_screen.dart';
import '../games/word_scramble/word_scramble_screen.dart';
import '../games/reaction_tap/reaction_tap_screen.dart';
import '../games/number_sequence/number_sequence_screen.dart';
import '../games/simon_says/simon_says_screen.dart';
import '../games/snake_lite/snake_lite_screen.dart';
import '../games/typing_speed/typing_speed_screen.dart';
import '../games/odd_one_out/odd_one_out_screen.dart';
import '../games/pattern_memory/pattern_memory_screen.dart';
import '../games/balloon_pop/balloon_pop_screen.dart';
import '../games/guess_the_flag/guess_the_flag_screen.dart';
import '../games/falling_catch/falling_catch_screen.dart';
import '../games/countdown_clicker/countdown_clicker_screen.dart';
import '../games/anagram_rush/anagram_rush_screen.dart';
import '../games/shape_tap/shape_tap_screen.dart';
import '../games/whack_mole/whack_mole_screen.dart';
import '../games/pairs_equation/pairs_equation_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Game data model
// ─────────────────────────────────────────────────────────────────────────────
class FeedGame {
  final String   id, name, description, emoji, tag;
  final int      plays, likes, comments, shares;
  final Gradient gradient;
  final double   rating;
  final Widget Function() buildScreen;

  /// Path to the 3D-plastic PNG icon, e.g. 'assets/images/games_icon/slide_puzzle.png'
  final String iconAsset;

  /// Pastel card background tint (very light)
  final Color tintBg;
  /// Medium tint — used for tag pills / active states
  final Color tintMid;
  /// Solid darker shade for the hard card shadow
  final Color tintShadow;

  const FeedGame({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.tag,
    required this.gradient,
    required this.plays,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.rating,
    required this.buildScreen,
    required this.iconAsset,
    required this.tintBg,
    required this.tintMid,
    required this.tintShadow,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ALL 21 GAMES
// ─────────────────────────────────────────────────────────────────────────────
final List<FeedGame> allFeedGames = [
  FeedGame(
    id: 'slide_puzzle', name: 'Slide Puzzle', emoji: '🧩', tag: 'PUZZLE',
    description: 'Arrange tiles in order. Fewer moves = higher score!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFF5C800), Color(0xFFE6A800)],
    ),
    iconAsset: 'assets/images/games_icon/slide_puzzle.png',
    tintBg: const Color(0xFFFBF9DB), tintMid: const Color(0xFFF7F3B8), tintShadow: const Color(0xFFA49900),
    plays: 12400, likes: 5200, comments: 6100, shares: 7300, rating: 4.5,
    buildScreen: () => const SlidePuzzleScreen(),
  ),
  FeedGame(
    id: 'trivia_quiz', name: 'Trivia Quiz', emoji: '🎯', tag: 'LIVE API',
    description: 'Live questions from the internet. 3 lives, 20s each!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF9B59B6), Color(0xFF6C3483)],
    ),
    iconAsset: 'assets/images/games_icon/trivia_quiz.png',
    tintBg: const Color(0xFFEDECFA), tintMid: const Color(0xFFDBD9F5), tintShadow: const Color(0xFF5B569F),
    plays: 8900, likes: 4800, comments: 5500, shares: 6200, rating: 4.8,
    buildScreen: () => const TriviaQuizScreen(),
  ),
  FeedGame(
    id: 'memory_match', name: 'Memory Match', emoji: '🃏', tag: 'MEMORY',
    description: 'Flip cards and find all matching emoji pairs.',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF1D9E75), Color(0xFF0F5E3A)],
    ),
    iconAsset: 'assets/images/games_icon/memory_match.png',
    tintBg: const Color(0xFFDFF1EC), tintMid: const Color(0xFFC0E4D8), tintShadow: const Color(0xFF157254),
    plays: 6200, likes: 3100, comments: 4200, shares: 5100, rating: 4.3,
    buildScreen: () => const MemoryMatchScreen(),
  ),
  FeedGame(
    id: 'color_match', name: 'Color Match', emoji: '🎨', tag: 'REFLEX',
    description: 'Tap the INK color of the word, not what it says!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFD85A30), Color(0xFF8B2500)],
    ),
    iconAsset: 'assets/images/games_icon/color_match.png',
    tintBg: const Color(0xFFE3EFFA), tintMid: const Color(0xFFC7DEF5), tintShadow: const Color(0xFF28639F),
    plays: 4100, likes: 2900, comments: 3800, shares: 4500, rating: 4.6,
    buildScreen: () => const ColorMatchScreen(),
  ),
  FeedGame(
    id: 'math_blitz', name: 'Math Blitz', emoji: '➕', tag: 'MATH',
    description: 'Solve +, -, × equations against the clock. Build streaks!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF378ADD), Color(0xFF1A5FA8)],
    ),
    iconAsset: 'assets/images/games_icon/math_blitz.png',
    tintBg: const Color(0xFFFBF9DB), tintMid: const Color(0xFFF7F3B8), tintShadow: const Color(0xFFA49900),
    plays: 5300, likes: 3400, comments: 4100, shares: 5000, rating: 4.4,
    buildScreen: () => const MathBlitzScreen(),
  ),
  FeedGame(
    id: 'word_scramble', name: 'Word Scramble', emoji: '🔤', tag: 'WORDS',
    description: 'Unscramble the letters to find the hidden tech word!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF7F77DD), Color(0xFF4A3FA8)],
    ),
    iconAsset: 'assets/images/games_icon/word_scramble.png',
    tintBg: const Color(0xFFFAE8E2), tintMid: const Color(0xFFF4D1C5), tintShadow: const Color(0xFF9C4123),
    plays: 3800, likes: 2200, comments: 3100, shares: 3900, rating: 4.2,
    buildScreen: () => const WordScrambleScreen(),
  ),
  FeedGame(
    id: 'reaction_tap', name: 'Reaction Tap', emoji: '⚡', tag: 'REFLEX',
    description: 'Tap the moment it turns green. Measure your reaction time!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF1D9E75), Color(0xFF0A3D1A)],
    ),
    iconAsset: 'assets/images/games_icon/reaction_tap.png',
    tintBg: const Color(0xFFE9F1E0), tintMid: const Color(0xFFD3E2C1), tintShadow: const Color(0xFF476E18),
    plays: 7100, likes: 4200, comments: 5300, shares: 6100, rating: 4.7,
    buildScreen: () => const ReactionTapScreen(),
  ),
  FeedGame(
    id: 'number_sequence', name: 'Number Sequence', emoji: '🔢', tag: 'LOGIC',
    description: 'Find the missing number in arithmetic & geometric sequences.',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF378ADD), Color(0xFF0A1628)],
    ),
    iconAsset: 'assets/images/games_icon/number_sequence.png',
    tintBg: const Color(0xFFFEF7DB), tintMid: const Color(0xFFFCF0B8), tintShadow: const Color(0xFFB09000),
    plays: 4500, likes: 2700, comments: 3600, shares: 4400, rating: 4.3,
    buildScreen: () => const NumberSequenceScreen(),
  ),
  FeedGame(
    id: 'simon_says', name: 'Simon Says', emoji: '🎵', tag: 'MEMORY',
    description: 'Watch the color sequence, then repeat it back perfectly.',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFD4537E), Color(0xFF6B1A3A)],
    ),
    iconAsset: 'assets/images/games_icon/simon_says.png',
    tintBg: const Color(0xFFF9E7ED), tintMid: const Color(0xFFF3CFDB), tintShadow: const Color(0xFF993C5B),
    plays: 6800, likes: 3900, comments: 4800, shares: 5700, rating: 4.6,
    buildScreen: () => const SimonSaysScreen(),
  ),
  FeedGame(
    id: 'snake_lite', name: 'Snake Lite', emoji: '🐍', tag: 'ARCADE',
    description: 'Classic snake! Eat food, grow longer, don\'t hit walls.',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF1D9E75), Color(0xFF0A1A0A)],
    ),
    iconAsset: 'assets/images/games_icon/snake_lite.png',
    tintBg: const Color(0xFFE9F1E0), tintMid: const Color(0xFFD3E2C1), tintShadow: const Color(0xFF476E18),
    plays: 9200, likes: 5100, comments: 6200, shares: 7400, rating: 4.7,
    buildScreen: () => const SnakeLiteScreen(),
  ),
  FeedGame(
    id: 'typing_speed', name: 'Typing Speed', emoji: '⌨️', tag: 'SKILL',
    description: 'Type as many words as you can in 60 seconds!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF7F77DD), Color(0xFF2D1B69)],
    ),
    iconAsset: 'assets/images/games_icon/typing_speed.png',
    tintBg: const Color(0xFFFBF9DB), tintMid: const Color(0xFFF7F3B8), tintShadow: const Color(0xFFA49900),
    plays: 3200, likes: 1900, comments: 2800, shares: 3500, rating: 4.1,
    buildScreen: () => const TypingSpeedScreen(),
  ),
  FeedGame(
    id: 'odd_one_out', name: 'Odd One Out', emoji: '🔍', tag: 'LOGIC',
    description: 'Four emojis — find the one that doesn\'t belong!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFF5C800), Color(0xFF8B6000)],
    ),
    iconAsset: 'assets/images/games_icon/odd_one_out.png',
    tintBg: const Color(0xFFFBF9DB), tintMid: const Color(0xFFF7F3B8), tintShadow: const Color(0xFFA49900),
    plays: 5600, likes: 3300, comments: 4200, shares: 5100, rating: 4.5,
    buildScreen: () => const OddOneOutScreen(),
  ),
  FeedGame(
    id: 'pattern_memory', name: 'Pattern Memory', emoji: '🔲', tag: 'MEMORY',
    description: 'Memorize which grid cells are lit, then recreate the pattern!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF378ADD), Color(0xFF0D1B33)],
    ),
    iconAsset: 'assets/images/games_icon/pattern_memory.png',
    tintBg: const Color(0xFFFBF9DB), tintMid: const Color(0xFFF7F3B8), tintShadow: const Color(0xFFA49900),
    plays: 4000, likes: 2400, comments: 3300, shares: 4100, rating: 4.4,
    buildScreen: () => const PatternMemoryScreen(),
  ),
  FeedGame(
    id: 'balloon_pop', name: 'Balloon Pop', emoji: '🎈', tag: 'ARCADE',
    description: 'Tap rising balloons before they float away!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFD4537E), Color(0xFF0A1628)],
    ),
    iconAsset: 'assets/images/games_icon/balloon_pop.png',
    tintBg: const Color(0xFFF9E7ED), tintMid: const Color(0xFFF3CFDB), tintShadow: const Color(0xFF993C5B),
    plays: 8400, likes: 4700, comments: 5800, shares: 6900, rating: 4.6,
    buildScreen: () => const BalloonPopScreen(),
  ),
  FeedGame(
    id: 'guess_the_flag', name: 'Guess the Flag', emoji: '🌍', tag: 'GEO',
    description: 'Which country does this flag belong to? 10 rounds!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF9B59B6), Color(0xFF1A0A2E)],
    ),
    iconAsset: 'assets/images/games_icon/guess_the_flag.png',
    tintBg: const Color(0xFFDFF1EC), tintMid: const Color(0xFFC0E4D8), tintShadow: const Color(0xFF157254),
    plays: 6000, likes: 3600, comments: 4500, shares: 5400, rating: 4.5,
    buildScreen: () => const GuessTheFlagScreen(),
  ),
  FeedGame(
    id: 'falling_catch', name: 'Falling Catch', emoji: '🧺', tag: 'ARCADE',
    description: 'Catch stars and diamonds in your basket. Avoid the bombs!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF7F77DD), Color(0xFF0A0A1E)],
    ),
    iconAsset: 'assets/images/games_icon/falling_catch.png',
    tintBg: const Color(0xFFFAE8E2), tintMid: const Color(0xFFF4D1C5), tintShadow: const Color(0xFF9C4123),
    plays: 5500, likes: 3200, comments: 4100, shares: 5000, rating: 4.3,
    buildScreen: () => const FallingCatchScreen(),
  ),
  FeedGame(
    id: 'countdown_clicker', name: 'Countdown Clicker', emoji: '👆', tag: 'SPEED',
    description: 'Tap 30 times in 10 seconds. Simple but brutal!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFD85A30), Color(0xFF1A0A00)],
    ),
    iconAsset: 'assets/images/games_icon/countdown_clicker.png',
    tintBg: const Color(0xFFFBF9DB), tintMid: const Color(0xFFF7F3B8), tintShadow: const Color(0xFFA49900),
    plays: 11000, likes: 5800, comments: 6900, shares: 8100, rating: 4.8,
    buildScreen: () => const CountdownClickerScreen(),
  ),
  FeedGame(
    id: 'anagram_rush', name: 'Anagram Rush', emoji: '🔀', tag: 'WORDS',
    description: 'Rearrange the letters to form a valid word against the clock!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF1D9E75), Color(0xFF0D1E35)],
    ),
    iconAsset: 'assets/images/games_icon/anagram_rush.png',
    tintBg: const Color(0xFFEDECFA), tintMid: const Color(0xFFDBD9F5), tintShadow: const Color(0xFF5B569F),
    plays: 3400, likes: 2000, comments: 2900, shares: 3700, rating: 4.2,
    buildScreen: () => const AnagramRushScreen(),
  ),
  FeedGame(
    id: 'shape_tap', name: 'Shape Tap', emoji: '🔷', tag: 'REFLEX',
    description: 'Tap only the specified shape. Ignore all the others!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF7F77DD), Color(0xFF1A001A)],
    ),
    iconAsset: 'assets/images/games_icon/shape_tap.png',
    tintBg: const Color(0xFFFAE8E2), tintMid: const Color(0xFFF4D1C5), tintShadow: const Color(0xFF9C4123),
    plays: 4700, likes: 2800, comments: 3700, shares: 4600, rating: 4.4,
    buildScreen: () => const ShapeTapScreen(),
  ),
  FeedGame(
    id: 'whack_mole', name: 'Whack-a-Mole', emoji: '🐹', tag: 'ARCADE',
    description: 'Tap the moles as they pop up! Classic carnival game.',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFF5C800), Color(0xFF3D2200)],
    ),
    iconAsset: 'assets/images/games_icon/whack_mole.png',
    tintBg: const Color(0xFFE9F1E0), tintMid: const Color(0xFFD3E2C1), tintShadow: const Color(0xFF476E18),
    plays: 10200, likes: 5500, comments: 6600, shares: 7800, rating: 4.7,
    buildScreen: () => const WhackMoleScreen(),
  ),
  FeedGame(
    id: 'pairs_equation', name: 'Equation Pairs', emoji: '🔣', tag: 'MATH',
    description: 'Match each multiplication equation to its correct answer.',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF378ADD), Color(0xFF0D1F3C)],
    ),
    iconAsset: 'assets/images/games_icon/pairs_equation.png',
    tintBg: const Color(0xFFE3EFFA), tintMid: const Color(0xFFC7DEF5), tintShadow: const Color(0xFF28639F),
    plays: 3600, likes: 2100, comments: 3000, shares: 3800, rating: 4.3,
    buildScreen: () => const PairsEquationScreen(),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Feed Screen
// ─────────────────────────────────────────────────────────────────────────────
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _ctrl = PageController();

  @override
  void initState() {
    super.initState();
    unawaited(_seedFeedSocialStats());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _play(FeedGame g) {
    final userId = context.read<UserProvider>().user?.id;
    unawaited(GameSocialService.recordPlay(
      gameId: g.id,
      userId: userId,
      metadata: GameSocialMetadata(
        gameId: g.id,
        name: g.name,
        description: g.description,
        emoji: g.emoji,
        tag: g.tag,
        rating: g.rating,
      ),
    ));
    Navigator.push(context, MaterialPageRoute(builder: (_) => g.buildScreen()));
  }

  Future<void> _seedFeedSocialStats() async {
    for (final game in allFeedGames) {
      await GameSocialService.seedStats(
        metadata: GameSocialMetadata(
          gameId: game.id,
          name: game.name,
          description: game.description,
          emoji: game.emoji,
          tag: game.tag,
          rating: game.rating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final user = provider.user;
    return Stack(children: [
      PageView.builder(
        controller: _ctrl,
        scrollDirection: Axis.vertical,
        itemCount: null,
        onPageChanged: (_) {
          HapticsService.selection();
          AudioService.playSfx('swipe');
        },
        itemBuilder: (_, i) {
          final idx = i % allFeedGames.length;
          return _FeedCard(
            game: allFeedGames[idx],
            onPlay: () => _play(allFeedGames[idx]),
          );
        },
      ),
      SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(children: [
                const _ScrollXBrandBadge(),
                const Spacer(),
                if (user != null) _FeedXpPill(xp: user.totalXp),
              ]),
            ],
          ),
        ),
      ),
    ]);
  }
}

class _ScrollXBrandBadge extends StatelessWidget {
  const _ScrollXBrandBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [AppTheme.hardShadowSmall],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999),
          ),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              children: [
                TextSpan(text: 'Scroll', style: TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'X',
                  style: TextStyle(color: AppTheme.consoleYellow),
                ),
              ],
            ),
          ),
        ),
      );
}

class _FeedXpPill extends StatelessWidget {
  final int xp;
  const _FeedXpPill({required this.xp});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Text('⚡', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$xp XP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Feed Card — TikTok style
// ─────────────────────────────────────────────────────────────────────────────
class _FeedCard extends StatelessWidget {
  final FeedGame game;
  final VoidCallback onPlay;

  const _FeedCard({required this.game, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return _FeedCardView(
      game: game,
      onPlay: onPlay,
    );
  }
}

class _FeedCardView extends StatelessWidget {
  final FeedGame game;
  final VoidCallback onPlay;

  const _FeedCardView({
    required this.game,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize  = MediaQuery.of(context).size;
    final topPad      = MediaQuery.of(context).padding.top;
    const bottomPad   = 20.0;

    // Poster: square, 80% of screen width, 25% border radius
    final posterSize  = screenSize.width * 0.80;
    final posterRadius = posterSize * 0.25;

    // How much vertical space the bottom info block needs (approx)
    const infoHeight  = 165.0; // user row + desc + play button
    const navHeight   = 82.0;  // dock + shadow

    // Centre the poster vertically in the remaining space above the info block
    final availableH  = screenSize.height - topPad - navHeight - bottomPad - infoHeight;
    final posterTop   = topPad + (availableH - posterSize) / 2;

    // Bottom info sits just above the nav bar
    const infoBottom  = bottomPad + navHeight + 35;

    return Stack(children: [
      // ── Full-screen gradient background ───────────────────────────────
      Container(decoration: BoxDecoration(gradient: game.gradient)),

      // ── Top bar ────────────────────────────────────────────────────────
      const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            SizedBox.shrink(),
            Spacer(),
          ]),
        ),
      ),

      // ── Game poster — centred square ───────────────────────────────────
      Positioned(
        left: (screenSize.width - posterSize) / 2,
        top: posterTop.clamp(topPad + 60.0, screenSize.height * 0.5),
        child: AntiGravityWidget(
          driftPixels: 3.0,
          child: Container(
            width: posterSize,
            height: posterSize,
            decoration: BoxDecoration(
              color: game.tintBg,
              borderRadius: BorderRadius.circular(posterRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.50),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: game.tintShadow,
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(children: [
              // Game icon — large, centered, no background shape
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    game.iconAsset,
                    width: posterSize * 0.68,
                    height: posterSize * 0.68,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Tag badge top-left
              Positioned(
                top: 14, left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    game.tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),

      // ── Reusable real-time social engagement panel ─────────────────────
      Positioned(
        right: 20,
        bottom: infoBottom + 40,
        child: SocialEngagementPanel(
          gameId: game.id,
          metadata: GameSocialMetadata(
            gameId: game.id,
            name: game.name,
            description: game.description,
            emoji: game.emoji,
            tag: game.tag,
            rating: game.rating,
          ),
        ),
      ),

      // ── Bottom info + play button ──────────────────────────────────────
      // Order: play button → your.game row → description
      // Bottom of description sits 16px above the nav bar.
      Positioned(
        left: 0, right: 0,
        bottom: infoBottom + 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1 — Play button
              BouncePressWidget(
                onTap: onPlay,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [AppTheme.hardShadowSmall],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Play ${game.name}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 2 — your.game row
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        game.iconAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'your.${game.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              // 3 — description
              Text(
                game.description,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
