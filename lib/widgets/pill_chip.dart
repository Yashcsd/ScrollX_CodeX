// lib/widgets/pill_chip.dart
// Shared flat pill chip — used by GamesScreen filter row and LeaderboardScreen
// filter pills. No border, no bold shadow. Active state = solid fill + dark
// text. Inactive = pale neutral fill + muted text.
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'bounce_press.dart';

class PillChip extends StatelessWidget {
  /// Display label text
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Whether this chip is in the active/selected state
  final bool active;

  /// Callback when tapped
  final VoidCallback onTap;

  /// Active fill color — defaults to AppTheme.consoleYellow
  final Color? activeColor;

  /// Active text/icon color — defaults to AppTheme.dark
  final Color? activeTextColor;

  const PillChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.activeColor,
    this.activeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final fill   = active ? (activeColor ?? AppTheme.consoleYellow) : const Color(0xFFF5F5F0);
    final fg     = active ? (activeTextColor ?? AppTheme.dark)       : AppTheme.textSec;

    return BouncePressWidget(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(999),
          // No border — color fill alone communicates state.
          // Barely-there shadow on active only, never on inactive chips.
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0xFFCCCBC0), // ~hardShadowSmall warmth
                    blurRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
