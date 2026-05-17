// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';

// ── XP Progress Bar ────────────────────────────────────────────────────────────
class XpBarWidget extends StatelessWidget {
  final int  xp;
  final bool compact;
  const XpBarWidget({super.key, required this.xp, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final progress  = AppConstants.xpProgress(xp);
    final lvl       = AppConstants.levelNumber(xp);
    final title     = AppConstants.levelTitle(xp);
    final xpInLevel = xp % 500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level $lvl · $title',
                  style: const TextStyle(
                      color: AppTheme.textSec,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Text('$xpInLevel / 500 XP',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
        if (!compact) const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: compact ? 3 : 5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Avatar circle ─────────────────────────────────────────────────────────────
class AvatarWidget extends StatelessWidget {
  final String initials;
  final double size;
  final bool   showBorder;

  const AvatarWidget({
    super.key,
    required this.initials,
    this.size       = 44,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppTheme.primary,
      border: showBorder
          ? Border.all(color: AppTheme.primary, width: 2)
          : null,
    ),
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppTheme.dark,
          fontSize: size * 0.30,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

// ── Badge chip ────────────────────────────────────────────────────────────────
class BadgeChip extends StatelessWidget {
  final String label;
  const BadgeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
    ),
    child: Text(label,
        style: const TextStyle(
            color: AppTheme.dark,
            fontSize: 11,
            fontWeight: FontWeight.w600)),
  );
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: AppTheme.textMuted)),
      ],
    ),
  );
}

// ── Game result overlay (shown after win/loss) ────────────────────────────────
class GameResultOverlay extends StatelessWidget {
  final int      score;
  final int      xpEarned;
  final bool     won;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const GameResultOverlay({
    super.key,
    required this.score,
    required this.xpEarned,
    required this.won,
    required this.onContinue,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black87,
    child: Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: won ? AppTheme.teal : AppTheme.coral,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (won ? AppTheme.teal : AppTheme.coral).withOpacity(0.2),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? '🏆' : '💀',
                style: const TextStyle(fontSize: 52))
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(
              won ? 'Well Played!' : 'Game Over',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: won ? AppTheme.teal : AppTheme.coral,
              ),
            ).animate().slideY(begin: 0.3, duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 20),
            _row('Score',     '$score pts', AppTheme.dark),
            const SizedBox(height: 8),
            _row('XP Earned', '+$xpEarned XP', AppTheme.primary),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border, width: 1.5),
                    foregroundColor: AppTheme.textSec,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Retry',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.dark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Next Game',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ),
      ).animate().slideY(begin: 0.5, duration: 500.ms,
          curve: Curves.easeOutCubic),
    ),
  );

  Widget _row(String label, String value, Color color) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: const TextStyle(
              color: AppTheme.textSec, fontSize: 14)),
      Text(value,
          style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700)),
    ],
  );
}
