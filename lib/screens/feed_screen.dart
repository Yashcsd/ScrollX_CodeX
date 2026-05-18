// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/user_provider.dart';

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
import '../games/color_switch/color_switch_screen.dart';
import '../games/flappy_tap/flappy_tap_screen.dart';
import '../games/reflex_master/reflex_master_screen.dart';
import '../games/word_chain/word_chain_screen.dart';
import '../games/rhythm_tap/rhythm_tap_screen.dart';
import '../games/emoji_match/emoji_match_screen.dart';
import '../games/number_crush/number_crush_screen.dart';
import '../games/quick_math/quick_math_screen.dart';
import '../games/maze_runner/maze_runner_screen.dart';
import '../games/spin_wheel/spin_wheel_screen.dart';
import '../games/sky_racer/sky_racer_screen.dart';
import '../games/bird_blast/bird_blast_screen.dart';
import '../games/brick_breaker/brick_breaker_screen.dart';
import '../games/space_shooter/space_shooter_screen.dart';
import '../games/fruit_ninja/fruit_ninja_screen.dart';
import '../games/doodle_jump/doodle_jump_screen.dart';
import '../games/stack_tower/stack_tower_screen.dart';
import '../games/bubble_shooter/bubble_shooter_screen.dart';
import '../games/candy_crush/candy_crush_screen.dart';
import '../games/temple_run/temple_run_screen.dart';
import '../games/jetpack_hero/jetpack_hero_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Game data model
// ─────────────────────────────────────────────────────────────────────────────
class FeedGame {
  final String   id, name, description, emoji, tag;
  final int      plays, likes, comments, shares;
  final Gradient gradient;
  final double   rating;
  final Widget Function() buildScreen;

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
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ALL 41 GAMES (21 original + 10 new puzzle/skill + 10 entertainment/arcade)
// ─────────────────────────────────────────────────────────────────────────────
final List<FeedGame> allFeedGames = [
  FeedGame(
    id: 'slide_puzzle', name: 'Slide Puzzle', emoji: '🧩', tag: 'PUZZLE',
    description: 'Arrange tiles in order. Fewer moves = higher score!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFF5C800), Color(0xFFE6A800)],
    ),
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
    plays: 3600, likes: 2100, comments: 3000, shares: 3800, rating: 4.3,
    buildScreen: () => const PairsEquationScreen(),
  ),
  FeedGame(
    id: 'color_switch', name: 'Color Switch', emoji: '🎨', tag: 'REFLEX',
    description: 'Tap MATCH if colors are same, DIFFERENT if not. Fast reflexes!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    ),
    plays: 7200, likes: 4100, comments: 5000, shares: 6100, rating: 4.6,
    buildScreen: () => const ColorSwitchScreen(),
  ),
  FeedGame(
    id: 'flappy_tap', name: 'Flappy Tap', emoji: '🐦', tag: 'ARCADE',
    description: 'Tap to fly! Navigate through gaps without hitting obstacles.',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    ),
    plays: 9800, likes: 5600, comments: 6700, shares: 7900, rating: 4.8,
    buildScreen: () => const FlappyTapScreen(),
  ),
  FeedGame(
    id: 'reflex_master', name: 'Reflex Master', emoji: '⚡', tag: 'REFLEX',
    description: 'Tap the arrow direction shown! Test your reaction speed.',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
    ),
    plays: 6500, likes: 3800, comments: 4700, shares: 5600, rating: 4.5,
    buildScreen: () => const ReflexMasterScreen(),
  ),
  FeedGame(
    id: 'word_chain', name: 'Word Chain', emoji: '🔗', tag: 'WORDS',
    description: 'Connect words where last letter matches first letter!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    plays: 4200, likes: 2600, comments: 3400, shares: 4300, rating: 4.4,
    buildScreen: () => const WordChainScreen(),
  ),
  FeedGame(
    id: 'rhythm_tap', name: 'Rhythm Tap', emoji: '🎵', tag: 'ARCADE',
    description: 'Tap the notes as they reach the line. Perfect timing wins!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFE056FD), Color(0xFF8E2DE2)],
    ),
    plays: 8100, likes: 4900, comments: 5800, shares: 6900, rating: 4.7,
    buildScreen: () => const RhythmTapScreen(),
  ),
  FeedGame(
    id: 'emoji_match', name: 'Emoji Match', emoji: '😊', tag: 'MEMORY',
    description: 'Find matching emoji pairs in this memory challenge!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
    ),
    plays: 5900, likes: 3500, comments: 4400, shares: 5300, rating: 4.5,
    buildScreen: () => const EmojiMatchScreen(),
  ),
  FeedGame(
    id: 'number_crush', name: 'Number Crush', emoji: '🔢', tag: 'MATH',
    description: 'Match numbers that add up to the target sum. Quick thinking!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    ),
    plays: 4800, likes: 2900, comments: 3700, shares: 4600, rating: 4.3,
    buildScreen: () => const NumberCrushScreen(),
  ),
  FeedGame(
    id: 'quick_math', name: 'Quick Math', emoji: '➗', tag: 'MATH',
    description: 'Solve arithmetic problems fast! Build streaks for bonus points.',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    ),
    plays: 7400, likes: 4300, comments: 5200, shares: 6300, rating: 4.6,
    buildScreen: () => const QuickMathScreen(),
  ),
  FeedGame(
    id: 'maze_runner', name: 'Maze Runner', emoji: '🏃', tag: 'PUZZLE',
    description: 'Navigate through mazes to reach the goal. 5 levels!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
    ),
    plays: 6100, likes: 3600, comments: 4500, shares: 5400, rating: 4.4,
    buildScreen: () => const MazeRunnerScreen(),
  ),
  FeedGame(
    id: 'spin_wheel', name: 'Spin Wheel', emoji: '🎡', tag: 'ARCADE',
    description: 'Stop the spinning wheel on the target number. Timing is key!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF30CFD0), Color(0xFF330867)],
    ),
    plays: 8700, likes: 5100, comments: 6100, shares: 7200, rating: 4.7,
    buildScreen: () => const SpinWheelScreen(),
  ),
  FeedGame(
    id: 'sky_racer', name: 'Sky Racer', emoji: '🏎️', tag: 'ARCADE',
    description: 'Unlimited racing! Dodge obstacles and collect points!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    plays: 12500, likes: 7200, comments: 8100, shares: 9300, rating: 4.9,
    buildScreen: () => const SkyRacerScreen(),
  ),
  FeedGame(
    id: 'bird_blast', name: 'Bird Blast', emoji: '🐦', tag: 'ARCADE',
    description: 'Flappy bird style! Tap to fly through pipes. Addictive!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    ),
    plays: 15200, likes: 8900, comments: 9800, shares: 11200, rating: 4.8,
    buildScreen: () => const BirdBlastScreen(),
  ),
  FeedGame(
    id: 'brick_breaker', name: 'Brick Breaker', emoji: '🧱', tag: 'ARCADE',
    description: 'Classic brick breaker! Swipe to move paddle and break all bricks.',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    ),
    plays: 9800, likes: 5700, comments: 6800, shares: 7900, rating: 4.6,
    buildScreen: () => const BrickBreakerScreen(),
  ),
  FeedGame(
    id: 'space_shooter', name: 'Space Shooter', emoji: '🚀', tag: 'ARCADE',
    description: 'Shoot aliens in space! Survive waves and get high scores!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
    ),
    plays: 11400, likes: 6800, comments: 7900, shares: 9100, rating: 4.7,
    buildScreen: () => const SpaceShooterScreen(),
  ),
  FeedGame(
    id: 'fruit_ninja', name: 'Fruit Ninja', emoji: '🍉', tag: 'ARCADE',
    description: 'Swipe to slice fruits! Avoid bombs and build combos!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFF9A56), Color(0xFFFF6B95)],
    ),
    plays: 13800, likes: 8100, comments: 9200, shares: 10500, rating: 4.8,
    buildScreen: () => const FruitNinjaScreen(),
  ),
  FeedGame(
    id: 'doodle_jump', name: 'Doodle Jump', emoji: '🦘', tag: 'ARCADE',
    description: 'Jump on platforms! Go as high as you can without falling!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
    ),
    plays: 10900, likes: 6400, comments: 7500, shares: 8700, rating: 4.7,
    buildScreen: () => const DoodleJumpScreen(),
  ),
  FeedGame(
    id: 'stack_tower', name: 'Stack Tower', emoji: '🏗️', tag: 'ARCADE',
    description: 'Stack blocks perfectly! Build the highest tower possible!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFFA751), Color(0xFFFFE259)],
    ),
    plays: 8900, likes: 5200, comments: 6300, shares: 7400, rating: 4.5,
    buildScreen: () => const StackTowerScreen(),
  ),
  FeedGame(
    id: 'bubble_shooter', name: 'Bubble Shooter', emoji: '🫧', tag: 'PUZZLE',
    description: 'Match 3+ bubbles! Aim and shoot to clear the board!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
    ),
    plays: 12100, likes: 7000, comments: 8100, shares: 9400, rating: 4.8,
    buildScreen: () => const BubbleShooterScreen(),
  ),
  FeedGame(
    id: 'candy_crush', name: 'Candy Crush', emoji: '🍬', tag: 'PUZZLE',
    description: 'Match 3 candies! Swap and crush to reach the target score!',
    gradient: const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)],
    ),
    plays: 16700, likes: 9800, comments: 11200, shares: 13100, rating: 4.9,
    buildScreen: () => const CandyCrushScreen(),
  ),
  FeedGame(
    id: 'temple_run', name: 'Temple Run', emoji: '🏃', tag: 'ARCADE',
    description: 'Endless runner! Switch lanes to avoid obstacles and collect coins!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF8B4513), Color(0xFF654321)],
    ),
    plays: 14300, likes: 8400, comments: 9600, shares: 11000, rating: 4.8,
    buildScreen: () => const TempleRunScreen(),
  ),
  FeedGame(
    id: 'jetpack_hero', name: 'Jetpack Hero', emoji: '🚀', tag: 'ARCADE',
    description: 'Jetpack joyride style! Hold to fly, avoid lasers, collect coins!',
    gradient: const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    ),
    plays: 13200, likes: 7700, comments: 8900, shares: 10200, rating: 4.8,
    buildScreen: () => const JetpackHeroScreen(),
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _play(FeedGame g) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => g.buildScreen()));
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
    controller: _ctrl,
    scrollDirection: Axis.vertical,
    itemCount: null,
    itemBuilder: (_, i) {
      final idx = i % allFeedGames.length;
      return _FeedCard(
        game:    allFeedGames[idx],
        onPlay:  () => _play(allFeedGames[idx]),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Feed Card — TikTok style
// ─────────────────────────────────────────────────────────────────────────────
class _FeedCard extends StatelessWidget {
  final FeedGame game;
  final VoidCallback onPlay;

  const _FeedCard({required this.game, required this.onPlay});

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;
    final user = context.watch<UserProvider>().user;

    return Stack(children: [
      // Full-screen gradient background
      Container(
        decoration: BoxDecoration(gradient: game.gradient),
      ),

      // Top bar — ScrollX logo pill
      SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            // ScrollX pill logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'ScrollX',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            // XP pill
            if (user != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  const Text('⚡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('${user.totalXp} XP',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
          ]),
        ),
      ),

      // Right side actions (TikTok style)
      Positioned(
        right: 12,
        bottom: bottomPad + 80,
        child: Column(children: [
          _SideAction(
            icon: Icons.favorite_rounded,
            label: _fmt(game.likes),
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          _SideAction(
            icon: Icons.chat_bubble_rounded,
            label: _fmt(game.comments),
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          _SideAction(
            icon: Icons.near_me_rounded,
            label: _fmt(game.shares),
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          _SideAction(
            icon: Icons.more_horiz_rounded,
            label: '',
            color: Colors.white,
          ),
        ]),
      ),

      // Bottom info + play button
      Positioned(
        left: 0, right: 0,
        bottom: bottomPad,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User row
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(game.emoji,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'your.game',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 16),
              ]),
              const SizedBox(height: 8),
              // Description
              Text(
                game.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              // Play button
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
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
            ],
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side action button
// ─────────────────────────────────────────────────────────────────────────────
class _SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SideAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: color, size: 28),
    if (label.isNotEmpty) ...[
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    ],
  ]);
}
