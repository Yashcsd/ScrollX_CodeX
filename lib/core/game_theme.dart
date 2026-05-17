// lib/core/game_theme.dart
// Shared UI helpers for all 21 game screens
import 'package:flutter/material.dart';

const kYellow     = Color(0xFFE4D400);
const kYellowDark = Color(0xFF9A8A00);
const kDark       = Color(0xFF1A1A1A);
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

// ── Game screen gradient (yellow top → white bottom) ─────────────────────────
const kGameGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [kYellow, Color(0xFFF5F0C0), Colors.white],
  stops: [0.0, 0.35, 0.65],
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
        color: kYellow,
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: kYellowDark, blurRadius: 0, offset: Offset(0, 5)),
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
