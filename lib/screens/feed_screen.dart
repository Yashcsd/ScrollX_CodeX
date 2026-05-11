// lib/screens/feed_screen.dart
// CYBERPUNK NEON STYLE - ALL 25 GAMES
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../core/app_theme.dart';
import '../services/user_provider.dart';
import '../widgets/common_widgets.dart';

// ── Game imports (same as before) ──────────────────────────────────────────
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
class _FeedGame {
  final String   id, name, description, emoji, tag, plays;
  final Gradient gradient;
  final Color    accent, glowColor;
  final double   rating;
  final Widget Function() buildScreen;

  const _FeedGame({
    required this.id, required this.name, required this.description,
    required this.emoji, required this.tag, required this.gradient,
    required this.accent, required this.glowColor, required this.plays,
    required this.rating, required this.buildScreen,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ALL 25 GAMES - Enhanced with glow colors
// ─────────────────────────────────────────────────────────────────────────────
final List<_FeedGame> _allGames = [
  _FeedGame(id:'slide_puzzle', name:'Slide Puzzle', emoji:'🧩', tag:'PUZZLE',
      description:'Arrange tiles in order. Fewer moves = higher score!',
      gradient:AppTheme.puzzleGrad, accent:AppTheme.accent, glowColor:const Color(0xFF7F77DD),
      plays:'12.4k', rating:4.5, buildScreen:()=>const SlidePuzzleScreen()),

  _FeedGame(id:'trivia_quiz', name:'Trivia Quiz', emoji:'🎯', tag:'LIVE API',
      description:'Live questions from the internet. 3 lives, 20s each!',
      gradient:AppTheme.triviaGrad, accent:const Color(0xFF9B59B6), glowColor:const Color(0xFFBB6BD9),
      plays:'8.9k', rating:4.8, buildScreen:()=>const TriviaQuizScreen()),

  _FeedGame(id:'memory_match', name:'Memory Match', emoji:'🃏', tag:'MEMORY',
      description:'Flip cards and find all matching emoji pairs.',
      gradient:AppTheme.memoryGrad, accent:AppTheme.teal, glowColor:const Color(0xFF1D9E75),
      plays:'6.2k', rating:4.3, buildScreen:()=>const MemoryMatchScreen()),

  _FeedGame(id:'color_match', name:'Color Match', emoji:'🎨', tag:'REFLEX',
      description:'Tap the INK color of the word, not what it says!',
      gradient:AppTheme.colorGrad, accent:AppTheme.coral, glowColor:const Color(0xFFFF6B6B),
      plays:'4.1k', rating:4.6, buildScreen:()=>const ColorMatchScreen()),

  _FeedGame(id:'math_blitz', name:'Math Blitz', emoji:'➕', tag:'MATH',
      description:'Solve +, -, × equations against the clock. Build streaks!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A2744), Color(0xFF0D4F3C)]),
      accent:AppTheme.teal, glowColor:const Color(0xFF00D9A3), plays:'5.3k', rating:4.4,
      buildScreen:()=>const MathBlitzScreen()),

  _FeedGame(id:'word_scramble', name:'Word Scramble', emoji:'🔤', tag:'WORDS',
      description:'Unscramble the letters to find the hidden tech word!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1B1035), Color(0xFF3D1A78)]),
      accent:AppTheme.accent, glowColor:const Color(0xFF9F77FF), plays:'3.8k', rating:4.2,
      buildScreen:()=>const WordScrambleScreen()),

  _FeedGame(id:'reaction_tap', name:'Reaction Tap', emoji:'⚡', tag:'REFLEX',
      description:'Tap the moment it turns green. Measure your reaction time!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0D1F0D), Color(0xFF1A3D1A)]),
      accent:AppTheme.teal, glowColor:const Color(0xFF00FF88), plays:'7.1k', rating:4.7,
      buildScreen:()=>const ReactionTapScreen()),

  _FeedGame(id:'number_sequence', name:'Number Sequence', emoji:'🔢', tag:'LOGIC',
      description:'Find the missing number in arithmetic & geometric sequences.',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF0A1628), Color(0xFF1A3A5C)]),
      accent:AppTheme.blue, glowColor:const Color(0xFF4A90E2), plays:'4.5k', rating:4.3,
      buildScreen:()=>const NumberSequenceScreen()),

  _FeedGame(id:'simon_says', name:'Simon Says', emoji:'🎵', tag:'MEMORY',
      description:'Watch the color sequence, then repeat it back perfectly.',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0D1B2A), Color(0xFF1B2838)]),
      accent:AppTheme.pink, glowColor:const Color(0xFFFF4D94), plays:'6.8k', rating:4.6,
      buildScreen:()=>const SimonSaysScreen()),

  _FeedGame(id:'snake_lite', name:'Snake Lite', emoji:'🐍', tag:'ARCADE',
      description:'Classic snake! Eat food, grow longer, don\'t hit walls.',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0A1A0A), Color(0xFF0D2E0D)]),
      accent:AppTheme.teal, glowColor:const Color(0xFF00FF66), plays:'9.2k', rating:4.7,
      buildScreen:()=>const SnakeLiteScreen()),

  _FeedGame(id:'typing_speed', name:'Typing Speed', emoji:'⌨️', tag:'SKILL',
      description:'Type as many words as you can in 60 seconds!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A1A35), Color(0xFF2D1B69)]),
      accent:AppTheme.accent, glowColor:const Color(0xFF8866FF), plays:'3.2k', rating:4.1,
      buildScreen:()=>const TypingSpeedScreen()),

  _FeedGame(id:'odd_one_out', name:'Odd One Out', emoji:'🔍', tag:'LOGIC',
      description:'Four emojis — find the one that doesn\'t belong!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF2D1B00), Color(0xFF6B3A00)]),
      accent:AppTheme.gold, glowColor:const Color(0xFFFFAA00), plays:'5.6k', rating:4.5,
      buildScreen:()=>const OddOneOutScreen()),

  _FeedGame(id:'pattern_memory', name:'Pattern Memory', emoji:'🔲', tag:'MEMORY',
      description:'Memorize which grid cells are lit, then recreate the pattern!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0D1B33), Color(0xFF1A2D55)]),
      accent:AppTheme.blue, glowColor:const Color(0xFF5599FF), plays:'4.0k', rating:4.4,
      buildScreen:()=>const PatternMemoryScreen()),

  _FeedGame(id:'balloon_pop', name:'Balloon Pop', emoji:'🎈', tag:'ARCADE',
      description:'Tap rising balloons before they float away!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0A1628), Color(0xFF1E3A5F)]),
      accent:AppTheme.pink, glowColor:const Color(0xFFFF66B2), plays:'8.4k', rating:4.6,
      buildScreen:()=>const BalloonPopScreen()),

  _FeedGame(id:'guess_the_flag', name:'Guess the Flag', emoji:'🌍', tag:'GEO',
      description:'Which country does this flag belong to? 10 rounds!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A0A2E), Color(0xFF2D1B69)]),
      accent:const Color(0xFF9B59B6), glowColor:const Color(0xFFBB77DD), plays:'6.0k', rating:4.5,
      buildScreen:()=>const GuessTheFlagScreen()),

  _FeedGame(id:'falling_catch', name:'Falling Catch', emoji:'🧺', tag:'ARCADE',
      description:'Catch stars and diamonds in your basket. Avoid the bombs!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0A0A1E), Color(0xFF1A1A3E)]),
      accent:AppTheme.accent, glowColor:const Color(0xFF9988FF), plays:'5.5k', rating:4.3,
      buildScreen:()=>const FallingCatchScreen()),

  _FeedGame(id:'countdown_clicker', name:'Countdown Clicker', emoji:'👆', tag:'SPEED',
      description:'Tap 30 times in 10 seconds. Simple but brutal!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF1A0A00), Color(0xFF5C2A00)]),
      accent:AppTheme.coral, glowColor:const Color(0xFFFF7744), plays:'11.0k', rating:4.8,
      buildScreen:()=>const CountdownClickerScreen()),

  _FeedGame(id:'anagram_rush', name:'Anagram Rush', emoji:'🔀', tag:'WORDS',
      description:'Rearrange the letters to form a valid word against the clock!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF0D1E35), Color(0xFF1A3A2A)]),
      accent:AppTheme.teal, glowColor:const Color(0xFF00DDAA), plays:'3.4k', rating:4.2,
      buildScreen:()=>const AnagramRushScreen()),

  _FeedGame(id:'shape_tap', name:'Shape Tap', emoji:'🔷', tag:'REFLEX',
      description:'Tap only the specified shape. Ignore all the others!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A001A), Color(0xFF3D0050)]),
      accent:AppTheme.accent, glowColor:const Color(0xFFAA66FF), plays:'4.7k', rating:4.4,
      buildScreen:()=>const ShapeTapScreen()),

  _FeedGame(id:'whack_mole', name:'Whack-a-Mole', emoji:'🐹', tag:'ARCADE',
      description:'Tap the moles as they pop up! Classic carnival game.',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF1A0D00), Color(0xFF3D2200)]),
      accent:AppTheme.gold, glowColor:const Color(0xFFFFBB00), plays:'10.2k', rating:4.7,
      buildScreen:()=>const WhackMoleScreen()),

  _FeedGame(id:'pairs_equation', name:'Equation Pairs', emoji:'🔣', tag:'MATH',
      description:'Match each multiplication equation to its correct answer.',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF0D1F3C), Color(0xFF1A3A6E)]),
      accent:AppTheme.blue, glowColor:const Color(0xFF4488FF), plays:'3.6k', rating:4.3,
      buildScreen:()=>const PairsEquationScreen()),
];

// ─────────────────────────────────────────────────────────────────────────────
// Feed Screen with animations
// ─────────────────────────────────────────────────────────────────────────────
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _play(_FeedGame g) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => g.buildScreen()));
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
    controller: _ctrl,
    scrollDirection: Axis.vertical,
    itemCount: null,
    onPageChanged: (i) => setState(() => _page = i % _allGames.length),
    itemBuilder: (_, i) {
      final idx = i % _allGames.length;
      return _GameCard(
        game: _allGames[idx],
        isActive: idx == _page,
        pageIdx: idx,
        total: _allGames.length,
        onPlay: () => _play(_allGames[idx]),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Neon Cyberpunk Game Card
// ─────────────────────────────────────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final _FeedGame game;
  final bool isActive;
  final int pageIdx, total;
  final VoidCallback onPlay;

  const _GameCard({
    required this.game, required this.isActive,
    required this.pageIdx, required this.total, required this.onPlay
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Stack(children: [
      // Animated gradient background
      Container(
        decoration: BoxDecoration(gradient: game.gradient),
      ),

      // Floating particles
      ...List.generate(8, (i) => _FloatingParticle(
        delay: i * 200,
        color: game.glowColor,
        size: (i % 3 + 1) * 2.0,
      )),

      // Cyberpunk grid
      CustomPaint(
        painter: _CyberGridPainter(accent: game.glowColor),
        size: MediaQuery.of(context).size,
      ),

      SafeArea(child: Column(children: [
        // App bar with glow
        Padding(
          padding: const EdgeInsets.fromLTRB(20,12,20,0),
          child: Row(children: [
            Text('ScrollX',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(color: game.glowColor.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: game.glowColor.withOpacity(0.3)),

            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: game.glowColor.withOpacity(0.3)),
              ),
              child: Text('${pageIdx+1}/$total',
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            if (user != null) SizedBox(width: 120, child: XpBarWidget(xp: user.totalXp, compact: true)),
          ]),
        ),

        const Spacer(flex: 2),

        // 3D Game preview with neon glow
        _Neon3DGamePreview(emoji: game.emoji, glowColor: game.glowColor, tag: game.tag),

        const Spacer(flex: 1),

        // Info section with glassmorphism
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // XP badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: game.glowColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: game.glowColor.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(color: game.glowColor.withOpacity(0.3), blurRadius: 12, spreadRadius: 1),
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.bolt, color: game.glowColor, size: 14),
                const SizedBox(width: 4),
                Text('+120 XP on win',
                    style: TextStyle(color: game.glowColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0),

            const SizedBox(height: 12),

            // Game title with neon effect
            Text(game.name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(color: game.glowColor.withOpacity(0.6), blurRadius: 20),
                  Shadow(color: game.glowColor, blurRadius: 40),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),

            Text(game.description,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              maxLines: 2,
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 12),

            // Stats row
            Row(children: [
              ..._stars(game.rating),
              const SizedBox(width: 6),
              Text(game.rating.toStringAsFixed(1),
                  style: const TextStyle(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 16),
              const Icon(Icons.people_outline, size: 15, color: Colors.white54),
              const SizedBox(width: 4),
              Text('${game.plays} plays',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ]).animate().fadeIn(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 16),

            // Neon pulsing Play button
            _NeonPlayButton(onTap: onPlay, color: game.accent, glowColor: game.glowColor),
          ]),
        ),

        const SizedBox(height: 12),

        // Swipe hint
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.keyboard_arrow_up, color: Colors.white38, size: 18),
          SizedBox(width: 4),
          Text('Swipe for next game',
              style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.5)),
        ]).animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1000.ms).fadeOut(duration: 1000.ms),

        const SizedBox(height: 16),
      ])),

      // Side action buttons with glow
      Positioned(
        right: 14,
        bottom: 120,
        child: Column(children: [
          _NeonActionBtn(
            icon: Icons.favorite_border,
            label: '${pageIdx * 817 + 2100}',
            color: AppTheme.pink,
            glowColor: const Color(0xFFFF4D94),
          ),
          const SizedBox(height: 20),
          _NeonActionBtn(
            icon: Icons.share_outlined,
            label: 'Share',
            color: Colors.white70,
            glowColor: game.glowColor,
          ),
          const SizedBox(height: 20),
          _NeonActionBtn(
            icon: Icons.bookmark_border,
            label: 'Save',
            color: Colors.white70,
            glowColor: game.glowColor,
          ),
        ]),
      ),

      // Animated progress dots
      Positioned(
        right: 8,
        top: 0,
        bottom: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(total > 20 ? 0 : total, (i) =>
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  width: i == pageIdx ? 4 : 3,
                  height: i == pageIdx ? 20 : 4,
                  decoration: BoxDecoration(
                    color: i == pageIdx ? game.glowColor : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: i == pageIdx ? [
                      BoxShadow(color: game.glowColor.withOpacity(0.6), blurRadius: 8, spreadRadius: 1),
                    ] : [],
                  ),
                ).animate(key: ValueKey('dot_$i'))
                    .fadeIn(duration: 200.ms),
            ),
          ),
        ),
      ),
    ]);
  }

  List<Widget> _stars(double r) => List.generate(5, (i) =>
      Icon(i < r.floor() ? Icons.star : Icons.star_border,
          color: AppTheme.gold, size: 15));
}

// ─────────────────────────────────────────────────────────────────────────────
// 3D Game Preview with Neon Glow
// ─────────────────────────────────────────────────────────────────────────────
class _Neon3DGamePreview extends StatelessWidget {
  final String emoji;
  final Color glowColor;
  final String tag;

  const _Neon3DGamePreview({
    required this.emoji,
    required this.glowColor,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Tag badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: glowColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: glowColor.withOpacity(0.5), width: 1.5),
        ),
        child: Text(tag,
            style: TextStyle(
              color: glowColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            )),
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

      const SizedBox(height: 16),

      // 3D glossy container
      Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              glowColor.withOpacity(0.3),
              Colors.black.withOpacity(0.4),
            ],
          ),
          border: Border.all(color: glowColor.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 5),
            BoxShadow(color: glowColor.withOpacity(0.2), blurRadius: 80, spreadRadius: 15),
          ],
        ),
        child: Stack(children: [
          // Inner glow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: RadialGradient(
                colors: [
                  glowColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Emoji
          Center(
            child: Text(emoji,
                style: const TextStyle(fontSize: 90)),
          ),
        ]),
      ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, color: glowColor.withOpacity(0.4))
          .then()
          .shake(duration: 3000.ms, hz: 0.5, curve: Curves.easeInOut),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Neon Play Button with pulse animation
// ─────────────────────────────────────────────────────────────────────────────
class _NeonPlayButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final Color glowColor;

  const _NeonPlayButton({
    required this.onTap,
    required this.color,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
            BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 40, spreadRadius: 5),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 26, color: Colors.white),
            SizedBox(width: 8),
            Text('Play Now',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                )),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.05, 1.05),
        duration: 1000.ms,
      )
          .then()
          .scale(
        begin: const Offset(1.05, 1.05),
        end: const Offset(1.0, 1.0),
        duration: 1000.ms,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Neon Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _NeonActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color glowColor;

  const _NeonActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: glowColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: glowColor.withOpacity(0.2), blurRadius: 12, spreadRadius: 1),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, color: glowColor.withOpacity(0.3)),

      const SizedBox(height: 6),

      Text(label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: glowColor.withOpacity(0.5), blurRadius: 4)],
          )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Particle Animation
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingParticle extends StatelessWidget {
  final int delay;
  final Color color;
  final double size;

  const _FloatingParticle({
    required this.delay,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(delay);
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final top = random.nextDouble() * MediaQuery.of(context).size.height;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.6),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.8), blurRadius: size * 2, spreadRadius: size / 2),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .moveY(
        begin: 0,
        end: -100,
        duration: Duration(milliseconds: 4000 + delay),
        curve: Curves.easeInOut,
      )
          .fadeIn(duration: 1000.ms)
          .then()
          .fadeOut(duration: 1000.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cyberpunk Grid Painter
// ─────────────────────────────────────────────────────────────────────────────
class _CyberGridPainter extends CustomPainter {
  final Color accent;
  _CyberGridPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withOpacity(0.08)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Glow dots at intersections (sparse)
    final dotPaint = Paint()
      ..color = accent.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 100) {
      for (double y = 0; y < size.height; y += 100) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}