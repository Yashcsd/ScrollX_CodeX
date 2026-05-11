// lib/screens/feed_screen.dart
// ALL 25 GAMES REGISTERED HERE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/user_provider.dart';
import '../widgets/common_widgets.dart';

// ── Original 4 games ──────────────────────────────────────────────────────────
import '../games/slide_puzzle/slide_puzzle_screen.dart';
import '../games/trivia_quiz/trivia_quiz_screen.dart';
import '../games/memory_match/memory_match_screen.dart';
import '../games/color_match/color_match_screen.dart';

// ── 21 New games ──────────────────────────────────────────────────────────────
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
  final Color    accent;
  final double   rating;
  final Widget Function() buildScreen;

  const _FeedGame({
    required this.id, required this.name, required this.description,
    required this.emoji, required this.tag, required this.gradient,
    required this.accent, required this.plays, required this.rating,
    required this.buildScreen,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ALL 25 GAMES
// ─────────────────────────────────────────────────────────────────────────────
final List<_FeedGame> _allGames = [
  _FeedGame(id:'slide_puzzle',      name:'Slide Puzzle',       emoji:'🧩', tag:'PUZZLE',
      description:'Arrange tiles in order. Fewer moves = higher score!',
      gradient:AppTheme.puzzleGrad, accent:AppTheme.accent, plays:'12.4k', rating:4.5,
      buildScreen:()=>const SlidePuzzleScreen()),

  _FeedGame(id:'trivia_quiz',       name:'Trivia Quiz',        emoji:'🎯', tag:'LIVE API',
      description:'Live questions from the internet. 3 lives, 20s each!',
      gradient:AppTheme.triviaGrad, accent:const Color(0xFF9B59B6), plays:'8.9k', rating:4.8,
      buildScreen:()=>const TriviaQuizScreen()),

  _FeedGame(id:'memory_match',      name:'Memory Match',       emoji:'🃏', tag:'MEMORY',
      description:'Flip cards and find all matching emoji pairs.',
      gradient:AppTheme.memoryGrad, accent:AppTheme.teal, plays:'6.2k', rating:4.3,
      buildScreen:()=>const MemoryMatchScreen()),

  _FeedGame(id:'color_match',       name:'Color Match',        emoji:'🎨', tag:'REFLEX',
      description:'Tap the INK color of the word, not what it says!',
      gradient:AppTheme.colorGrad, accent:AppTheme.coral, plays:'4.1k', rating:4.6,
      buildScreen:()=>const ColorMatchScreen()),

  _FeedGame(id:'math_blitz',        name:'Math Blitz',         emoji:'➕', tag:'MATH',
      description:'Solve +, -, × equations against the clock. Build streaks!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A2744), Color(0xFF0D4F3C)]),
      accent:AppTheme.teal, plays:'5.3k', rating:4.4,
      buildScreen:()=>const MathBlitzScreen()),

  _FeedGame(id:'word_scramble',     name:'Word Scramble',      emoji:'🔤', tag:'WORDS',
      description:'Unscramble the letters to find the hidden tech word!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1B1035), Color(0xFF3D1A78)]),
      accent:AppTheme.accent, plays:'3.8k', rating:4.2,
      buildScreen:()=>const WordScrambleScreen()),

  _FeedGame(id:'reaction_tap',      name:'Reaction Tap',       emoji:'⚡', tag:'REFLEX',
      description:'Tap the moment it turns green. Measure your reaction time!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0D1F0D), Color(0xFF1A3D1A)]),
      accent:AppTheme.teal, plays:'7.1k', rating:4.7,
      buildScreen:()=>const ReactionTapScreen()),

  _FeedGame(id:'number_sequence',   name:'Number Sequence',    emoji:'🔢', tag:'LOGIC',
      description:'Find the missing number in arithmetic & geometric sequences.',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF0A1628), Color(0xFF1A3A5C)]),
      accent:AppTheme.blue, plays:'4.5k', rating:4.3,
      buildScreen:()=>const NumberSequenceScreen()),

  _FeedGame(id:'simon_says',        name:'Simon Says',         emoji:'🎵', tag:'MEMORY',
      description:'Watch the color sequence, then repeat it back perfectly.',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0D1B2A), Color(0xFF1B2838)]),
      accent:AppTheme.pink, plays:'6.8k', rating:4.6,
      buildScreen:()=>const SimonSaysScreen()),

  _FeedGame(id:'snake_lite',        name:'Snake Lite',         emoji:'🐍', tag:'ARCADE',
      description:'Classic snake! Eat food, grow longer, don\'t hit walls.',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0A1A0A), Color(0xFF0D2E0D)]),
      accent:AppTheme.teal, plays:'9.2k', rating:4.7,
      buildScreen:()=>const SnakeLiteScreen()),

  _FeedGame(id:'typing_speed',      name:'Typing Speed',       emoji:'⌨️', tag:'SKILL',
      description:'Type as many words as you can in 60 seconds!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A1A35), Color(0xFF2D1B69)]),
      accent:AppTheme.accent, plays:'3.2k', rating:4.1,
      buildScreen:()=>const TypingSpeedScreen()),

  _FeedGame(id:'odd_one_out',       name:'Odd One Out',        emoji:'🔍', tag:'LOGIC',
      description:'Four emojis — find the one that doesn\'t belong!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF2D1B00), Color(0xFF6B3A00)]),
      accent:AppTheme.gold, plays:'5.6k', rating:4.5,
      buildScreen:()=>const OddOneOutScreen()),

  _FeedGame(id:'pattern_memory',    name:'Pattern Memory',     emoji:'🔲', tag:'MEMORY',
      description:'Memorize which grid cells are lit, then recreate the pattern!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0D1B33), Color(0xFF1A2D55)]),
      accent:AppTheme.blue, plays:'4.0k', rating:4.4,
      buildScreen:()=>const PatternMemoryScreen()),

  _FeedGame(id:'balloon_pop',       name:'Balloon Pop',        emoji:'🎈', tag:'ARCADE',
      description:'Tap rising balloons before they float away!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0A1628), Color(0xFF1E3A5F)]),
      accent:AppTheme.pink, plays:'8.4k', rating:4.6,
      buildScreen:()=>const BalloonPopScreen()),

  _FeedGame(id:'guess_the_flag',    name:'Guess the Flag',     emoji:'🌍', tag:'GEO',
      description:'Which country does this flag belong to? 10 rounds!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A0A2E), Color(0xFF2D1B69)]),
      accent:const Color(0xFF9B59B6), plays:'6.0k', rating:4.5,
      buildScreen:()=>const GuessTheFlagScreen()),

  _FeedGame(id:'falling_catch',     name:'Falling Catch',      emoji:'🧺', tag:'ARCADE',
      description:'Catch stars and diamonds in your basket. Avoid the bombs!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF0A0A1E), Color(0xFF1A1A3E)]),
      accent:AppTheme.accent, plays:'5.5k', rating:4.3,
      buildScreen:()=>const FallingCatchScreen()),

  _FeedGame(id:'countdown_clicker', name:'Countdown Clicker',  emoji:'👆', tag:'SPEED',
      description:'Tap 30 times in 10 seconds. Simple but brutal!',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF1A0A00), Color(0xFF5C2A00)]),
      accent:AppTheme.coral, plays:'11.0k', rating:4.8,
      buildScreen:()=>const CountdownClickerScreen()),

  _FeedGame(id:'anagram_rush',      name:'Anagram Rush',       emoji:'🔀', tag:'WORDS',
      description:'Rearrange the letters to form a valid word against the clock!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF0D1E35), Color(0xFF1A3A2A)]),
      accent:AppTheme.teal, plays:'3.4k', rating:4.2,
      buildScreen:()=>const AnagramRushScreen()),

  _FeedGame(id:'shape_tap',         name:'Shape Tap',          emoji:'🔷', tag:'REFLEX',
      description:'Tap only the specified shape. Ignore all the others!',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF1A001A), Color(0xFF3D0050)]),
      accent:AppTheme.accent, plays:'4.7k', rating:4.4,
      buildScreen:()=>const ShapeTapScreen()),

  _FeedGame(id:'whack_mole',        name:'Whack-a-Mole',       emoji:'🐹', tag:'ARCADE',
      description:'Tap the moles as they pop up! Classic carnival game.',
      gradient:const LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter,
          colors:[Color(0xFF1A0D00), Color(0xFF3D2200)]),
      accent:AppTheme.gold, plays:'10.2k', rating:4.7,
      buildScreen:()=>const WhackMoleScreen()),

  _FeedGame(id:'pairs_equation',    name:'Equation Pairs',     emoji:'🔣', tag:'MATH',
      description:'Match each multiplication equation to its correct answer.',
      gradient:const LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFF0D1F3C), Color(0xFF1A3A6E)]),
      accent:AppTheme.blue, plays:'3.6k', rating:4.3,
      buildScreen:()=>const PairsEquationScreen()),
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
    itemCount: _allGames.length,
    onPageChanged: (i) => setState(() => _page = i),
    itemBuilder: (_, i) => _GameCard(
      game:    _allGames[i],
      isActive: i == _page,
      pageIdx:  i,
      total:    _allGames.length,
      onPlay:   () => _play(_allGames[i]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Game reel card
// ─────────────────────────────────────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final _FeedGame game;
  final bool isActive;
  final int pageIdx, total;
  final VoidCallback onPlay;

  const _GameCard({required this.game, required this.isActive,
    required this.pageIdx, required this.total, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return Stack(children: [
      Container(decoration: BoxDecoration(gradient: game.gradient)),
      CustomPaint(painter: _GridPainter(), size: MediaQuery.of(context).size),

      SafeArea(child: Column(children: [
        // App bar
        Padding(padding: const EdgeInsets.fromLTRB(20,12,20,0),
            child: Row(children: [
              const Text('GameReel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 1.2)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                  child: Text('${pageIdx+1}/$total',
                      style: const TextStyle(color: Colors.white60, fontSize: 10))),
              const Spacer(),
              if (user != null) SizedBox(width: 120, child: XpBarWidget(xp: user.totalXp, compact: true)),
            ])),

        const Spacer(flex: 2),

        // Giant emoji preview
        Text(game.emoji, style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: game.accent.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: game.accent.withOpacity(0.5))),
            child: Text(game.tag, style: TextStyle(color: game.accent,
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1))),

        const Spacer(flex: 2),

        // Info + play button
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 72, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(game.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              Text(game.description, style: const TextStyle(color: AppTheme.textSec, fontSize: 13, height: 1.4), maxLines: 2),
              const SizedBox(height: 10),
              Row(children: [
                ..._stars(game.rating),
                const SizedBox(width: 6),
                Text(game.rating.toStringAsFixed(1),
                    style: const TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 14),
                const Icon(Icons.people_outline, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('${game.plays} plays', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity,
                  child: ElevatedButton(
                      onPressed: onPlay,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: game.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.play_arrow_rounded, size: 22),
                        SizedBox(width: 8),
                        Text('Play Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ]))),
            ])),

        const Padding(padding: EdgeInsets.only(bottom: 10, top: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.keyboard_arrow_up, color: AppTheme.textMuted, size: 18),
              SizedBox(width: 4),
              Text('Swipe for next game', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ])),
      ])),

      // Side actions
      Positioned(right: 12, bottom: 100,
          child: Column(children: [
            _actionBtn(Icons.favorite_border, '${pageIdx * 817 + 2100}', AppTheme.pink),
            const SizedBox(height: 16),
            _actionBtn(Icons.share_outlined, 'Share', AppTheme.textSec),
            const SizedBox(height: 16),
            _actionBtn(Icons.bookmark_border, 'Save', AppTheme.textSec),
          ])),

      // Page dots
      Positioned(right: 6, top: 0, bottom: 0,
          child: Center(child: Column(mainAxisSize: MainAxisSize.min,
              children: List.generate(total > 20 ? 0 : total, (i) =>
                  AnimatedContainer(duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      width: 3, height: i == pageIdx ? 16 : 3,
                      decoration: BoxDecoration(
                          color: i == pageIdx ? Colors.white : Colors.white30,
                          borderRadius: BorderRadius.circular(2))))))),
    ]);
  }

  Widget _actionBtn(IconData icon, String label, Color color) => Column(children: [
    Container(width: 44, height: 44,
        decoration: BoxDecoration(shape: BoxShape.circle,
            color: Colors.black26, border: Border.all(color: Colors.white12)),
        child: Icon(icon, color: color, size: 20)),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(color: color, fontSize: 9)),
  ]);

  List<Widget> _stars(double r) => List.generate(5, (i) =>
      Icon(i < r.floor() ? Icons.star : Icons.star_border, color: AppTheme.gold, size: 14));
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.025)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x,0), Offset(x,size.height), p);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0,y), Offset(size.width,y), p);
  }
  @override bool shouldRepaint(_) => false;
}
