// lib/core/game_theme.dart
// Shared UI helpers for all 21 game screens
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Per-game pastel tint tokens — derived from AppTheme base accents
// bg:     ~94% white mix  — card background
// mid:    ~85% white mix  — pills / active states
// shadow: 28% black mix   — hard shadow color
// deep:   15% black mix   — flat full-bleed feed background (dark enough for
//                           white text, still reads as the same hue family)
//         Exception: yellow + gold families use dark text (useDarkText = true)
// ─────────────────────────────────────────────────────────────────────────────
class GameTint {
  final Color bg, mid, shadow, deep;
  /// True for yellow/gold families — deep is light enough that white text
  /// loses contrast; overlay text should use AppTheme.dark instead.
  final bool useDarkText;
  const GameTint(this.bg, this.mid, this.shadow, this.deep,
      {this.useDarkText = false});
}

const kGameTints = <String, GameTint>{
  // ── yellow family (base #E4D400) — deep = #C2B400 ─────────────────────
  'slide_puzzle':      GameTint(Color(0xFFFBF9DB), Color(0xFFF7F3B8), Color(0xFFA49900), Color(0xFFC2B400), useDarkText: true),
  'math_blitz':        GameTint(Color(0xFFFBF9DB), Color(0xFFF7F3B8), Color(0xFFA49900), Color(0xFFC2B400), useDarkText: true),
  'typing_speed':      GameTint(Color(0xFFFBF9DB), Color(0xFFF7F3B8), Color(0xFFA49900), Color(0xFFC2B400), useDarkText: true),
  'odd_one_out':       GameTint(Color(0xFFFBF9DB), Color(0xFFF7F3B8), Color(0xFFA49900), Color(0xFFC2B400), useDarkText: true),
  'pattern_memory':    GameTint(Color(0xFFFBF9DB), Color(0xFFF7F3B8), Color(0xFFA49900), Color(0xFFC2B400), useDarkText: true),
  'countdown_clicker': GameTint(Color(0xFFFBF9DB), Color(0xFFF7F3B8), Color(0xFFA49900), Color(0xFFC2B400), useDarkText: true),
  // ── gold family (base #F5C800) — deep = #D0AA00 ───────────────────────
  'number_sequence':   GameTint(Color(0xFFFEF7DB), Color(0xFFFCF0B8), Color(0xFFB09000), Color(0xFFD0AA00), useDarkText: true),
  // ── purple family (base #7F77DD) — deep = #6C65BC ─────────────────────
  'trivia_quiz':       GameTint(Color(0xFFEDECFA), Color(0xFFDBD9F5), Color(0xFF5B569F), Color(0xFF6C65BC)),
  'anagram_rush':      GameTint(Color(0xFFEDECFA), Color(0xFFDBD9F5), Color(0xFF5B569F), Color(0xFF6C65BC)),
  // ── teal family (base #1D9E75) — deep = #198663 ───────────────────────
  'memory_match':      GameTint(Color(0xFFDFF1EC), Color(0xFFC0E4D8), Color(0xFF157254), Color(0xFF198663)),
  'guess_the_flag':    GameTint(Color(0xFFDFF1EC), Color(0xFFC0E4D8), Color(0xFF157254), Color(0xFF198663)),
  // ── blue family (base #378ADD) — deep = #2F75BC ───────────────────────
  'color_match':       GameTint(Color(0xFFE3EFFA), Color(0xFFC7DEF5), Color(0xFF28639F), Color(0xFF2F75BC)),
  'pairs_equation':    GameTint(Color(0xFFE3EFFA), Color(0xFFC7DEF5), Color(0xFF28639F), Color(0xFF2F75BC)),
  // ── coral family (base #D85A30) — deep = #B84C29 ─────────────────────
  'word_scramble':     GameTint(Color(0xFFFAE8E2), Color(0xFFF4D1C5), Color(0xFF9C4123), Color(0xFFB84C29)),
  'falling_catch':     GameTint(Color(0xFFFAE8E2), Color(0xFFF4D1C5), Color(0xFF9C4123), Color(0xFFB84C29)),
  'shape_tap':         GameTint(Color(0xFFFAE8E2), Color(0xFFF4D1C5), Color(0xFF9C4123), Color(0xFFB84C29)),
  // ── pink family (base #D4537E) — deep = #B4476B ──────────────────────
  'simon_says':        GameTint(Color(0xFFF9E7ED), Color(0xFFF3CFDB), Color(0xFF993C5B), Color(0xFFB4476B)),
  'balloon_pop':       GameTint(Color(0xFFF9E7ED), Color(0xFFF3CFDB), Color(0xFF993C5B), Color(0xFFB4476B)),
  // ── green family (base #639922) — deep = #54821D ──────────────────────
  'reaction_tap':      GameTint(Color(0xFFE9F1E0), Color(0xFFD3E2C1), Color(0xFF476E18), Color(0xFF54821D)),
  'snake_lite':        GameTint(Color(0xFFE9F1E0), Color(0xFFD3E2C1), Color(0xFF476E18), Color(0xFF54821D)),
  'whack_mole':        GameTint(Color(0xFFE9F1E0), Color(0xFFD3E2C1), Color(0xFF476E18), Color(0xFF54821D)),
};

const kYellow     = Color(0xFFE4D400);
const kYellowDark = Color(0xFF9A8A00);
const kDark       = Color(0xFF1A1A1A);
const kBlack      = Color(0xFF000000); // pure black for trophy/badge circles
const kGray       = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFE8E8E8);
const kTextSec    = Color(0xFF666666);
const kTextMuted  = Color(0xFF999999);
const kTeal       = Color(0xFF1D9E75);
const kCoral      = Color(0xFFD85A30);
const kBlue       = Color(0xFF378ADD);
const kPink       = Color(0xFFD4537E);
const kHardShadow = BoxShadow(
  color: Color(0xFFBBBAB0), // solid warm grey — no opacity
  blurRadius: 0,
  spreadRadius: 0,
  offset: Offset(0, 4),
);

// ── Game screen background — solid black replaces full-screen yellow fill ───
// Use this for Typing Speed, Number Sequence, and any game that previously
// used a solid yellow/gold fill as its full-screen scaffold background.
const kGameScaffoldBg = Color(0xFF1A1A1A);

// ── Selected chip text — white on yellow fill ─────────────────────────────
const kSelectedChipText = Colors.white;

// ── Top-player #1 rank tile — bottom-only hard shadow for 3D plastic feel ──
const kRankOneShadow = BoxShadow(
  color: Color(0xFF1A1A1A), // solid near-black bottom line
  blurRadius: 0,
  spreadRadius: 0,
  offset: Offset(0, 4),
);

// ── Game screen gradient (yellow top → rich mid → white bottom) ──────────────
// More atmospheric than a flat solid — yellow family reads as same ScrollX
// brand while adding depth. Not used on buttons/chips, only full-screen bg.
const kGameGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [kYellow, Color(0xFFD8CC00), Color(0xFFF5F0C0), Colors.white],
  stops: [0.0, 0.20, 0.50, 0.80],
);

// ── Dark game gradient — for game screens that used solid yellow bg (#13/14) ─
// Black scaffold with a subtle yellow atmospheric glow at the top.
// Keeps the yellow family feel while giving high contrast for UI chrome.
const kDarkGameGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF2A2600), Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
  stops: [0.0, 0.35, 1.0],
);

// ── Back button ───────────────────────────────────────────────────────────────
class GameBackButton extends StatelessWidget {
  const GameBackButton({super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      width: 40, height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [kHardShadow],
      ),
      child: const Icon(Icons.arrow_back_ios_new_rounded,
          color: kDark, size: 18),
    ),
  );
}

// ── Score badge ───────────────────────────────────────────────────────────────
class ScoreBadge extends StatelessWidget {
  final int score;
  final String suffix;
  const ScoreBadge({super.key, required this.score, this.suffix = 'pts'});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: kDark,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: Color(0xFF0A0A0A), blurRadius: 0, offset: Offset(0, 4)),
      ],
    ),
    child: Text('$score $suffix',
        style: const TextStyle(
            color: kYellow, fontSize: 13, fontWeight: FontWeight.w800)),
  );
}

// ── Timer badge ───────────────────────────────────────────────────────────────
class TimerBadge extends StatelessWidget {
  final int seconds;
  final int total;
  const TimerBadge({super.key, required this.seconds, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = seconds > total * 0.5
        ? kTeal
        : seconds > total * 0.25 ? kYellow : kCoral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
        boxShadow: const [kHardShadow],
      ),
      child: Text('${seconds}s',
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }
}

// ── Lives row ─────────────────────────────────────────────────────────────────
class LivesRow extends StatelessWidget {
  final int lives;
  final int total;
  const LivesRow({super.key, required this.lives, this.total = 3});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(total, (i) => Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        i < lives ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
        size: 20,
        color: i < lives ? kCoral : kBorder,
      ),
    )),
  );
}

// ── Yellow progress bar ───────────────────────────────────────────────────────
class GameProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  const GameProgressBar({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      backgroundColor: kBorder,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? kYellow),
      minHeight: 8,
    ),
  );
}

// ── Yellow 3D button ──────────────────────────────────────────────────────────
// Background is pure white; text + icon stay dark (#1A1A1A).
// The mustard hard shadow underneath preserves the plastic 3D / console feel.
class YellowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  const YellowButton({super.key, required this.label,
      required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 54,
      decoration: const BoxDecoration(
        color: Colors.white,                           // #1 — white CTA bg
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: kYellowDark, blurRadius: 0, offset: Offset(0, 5)), // mustard hard shadow kept
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (icon != null) ...[
          Icon(icon, color: kDark, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label, style: const TextStyle(
            color: kDark, fontSize: 15, fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}

// ── White outlined button ─────────────────────────────────────────────────────
class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  const OutlineButton({super.key, required this.label,
      required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: const [kHardShadow],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (icon != null) ...[
          Icon(icon, color: kDark, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label, style: const TextStyle(
            color: kDark, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

// ── White floating card ───────────────────────────────────────────────────────
class GameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const GameCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [kHardShadow],
    ),
    child: child,
  );
}

// ── Game header row ───────────────────────────────────────────────────────────
class GameHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  const GameHeader({super.key, required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
        16, MediaQuery.of(context).padding.top + 12, 16, 0),
    child: Row(children: [
      const GameBackButton(),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w800, color: kDark)),
      const Spacer(),
      ...actions,
    ]),
  );
}
