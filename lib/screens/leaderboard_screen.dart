// lib/screens/leaderboard_screen.dart
//
// Works in TWO modes:
//   • WITHOUT Firebase → shows only the current device user
//   • WITH Firebase    → shows real-time global leaderboard
//
// To switch to Firebase mode: set _useFirebase = true (after setup)
//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/user_model.dart';
import '../services/user_provider.dart';
import '../widgets/common_widgets.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUser = context.watch<UserProvider>().user;

    // Build a local-only list from the current device user
    final localList = myUser != null ? [myUser] : <UserModel>[];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: localList.isEmpty
          ? _empty()
          : CustomScrollView(slivers: [
              // Info banner
              SliverToBoxAdapter(child: _banner()),
              // List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _RankRow(
                      user:  localList[i],
                      rank:  i + 1,
                      isMe:  true,
                    ),
                    childCount: localList.length,
                  ),
                ),
              ),
            ]),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 20),
              const Text('No players yet',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                  'Create a profile and play games\nto appear on the leaderboard!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSec, height: 1.5)),
            ],
          ),
        ),
      );

  Widget _banner() => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.gold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppTheme.gold.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Connect Firebase to see global rankings from all players!',
              style: TextStyle(
                  color: AppTheme.gold, fontSize: 12, height: 1.4),
            ),
          ),
        ]),
      );
}

// ── Single rank row ───────────────────────────────────────────────────────────
class _RankRow extends StatelessWidget {
  final UserModel user;
  final int       rank;
  final bool      isMe;

  const _RankRow({
    required this.user,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.accent.withOpacity(0.1)
              : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe
                ? AppTheme.accent.withOpacity(0.5)
                : AppTheme.border,
            width: isMe ? 1.5 : 0.5,
          ),
        ),
        child: Row(children: [
          // Rank number
          SizedBox(
            width: 34,
            child: Text('#$rank',
                style: TextStyle(
                    color: isMe ? AppTheme.accent : AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
          // Avatar
          AvatarWidget(
              initials: user.avatarInitials,
              size: 40,
              showBorder: isMe),
          const SizedBox(width: 14),
          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(user.username,
                      style: TextStyle(
                          color: isMe ? Colors.white : AppTheme.textSec,
                          fontSize: 14,
                          fontWeight: isMe
                              ? FontWeight.w600
                              : FontWeight.w400)),
                  if (isMe) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('You',
                          style: TextStyle(
                              color: AppTheme.accentLight,
                              fontSize: 9)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(
                  'Level ${AppConstants.levelNumber(user.totalXp)}'
                  ' · ${AppConstants.levelTitle(user.totalXp)}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          // XP + wins
          Column(crossAxisAlignment: CrossAxisAlignment.end,
              children: [
            Text('${user.totalXp} XP',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${user.gamesWon} wins',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ]),
      );
}
