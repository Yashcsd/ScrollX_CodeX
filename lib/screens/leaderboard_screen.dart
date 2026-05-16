// lib/screens/leaderboard_screen.dart
//
// Firebase-backed leaderboard with a local fallback while data loads.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/user_model.dart';
import '../services/user_provider.dart';
import '../widgets/common_widgets.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final myUser = provider.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0B1E), Color(0xFF1A1535), Color(0xFF091827)],
          ),
        ),
        child: Stack(children: [
          CustomPaint(
            painter: _CyberGridPainter(accent: AppTheme.gold),
            size: MediaQuery.of(context).size,
          ),
          ...List.generate(7, (i) => _FloatingParticle(
                delay: i * 320,
                color: i.isEven ? AppTheme.gold : AppTheme.accent,
                size: (i % 3 + 1) * 2.0,
              )),
          SafeArea(
            child: StreamBuilder<List<UserModel>>(
              stream: provider.leaderboardStream(),
              builder: (context, snapshot) {
                final remoteList = snapshot.data ?? <UserModel>[];
                final users = _rankedUsers(remoteList, myUser);

                if (users.isEmpty) return const _EmptyLeaderboard();

                return _LeaderboardContent(
                  users: users,
                  myUserId: myUser?.id,
                  isLive: remoteList.isNotEmpty,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  List<UserModel> _rankedUsers(List<UserModel> remoteUsers, UserModel? myUser) {
    final byId = <String, UserModel>{
      for (final user in remoteUsers) user.id: user,
      if (myUser != null) myUser.id: myUser,
    };

    final users = byId.values.toList()
      ..sort((a, b) {
        final xpCompare = b.totalXp.compareTo(a.totalXp);
        if (xpCompare != 0) return xpCompare;

        final winsCompare = b.gamesWon.compareTo(a.gamesWon);
        if (winsCompare != 0) return winsCompare;

        final playedCompare = b.gamesPlayed.compareTo(a.gamesPlayed);
        if (playedCompare != 0) return playedCompare;

        return a.username.toLowerCase().compareTo(b.username.toLowerCase());
      });

    return users;
  }
}

class _LeaderboardContent extends StatelessWidget {
  final List<UserModel> users;
  final String? myUserId;
  final bool isLive;

  const _LeaderboardContent({
    required this.users,
    required this.myUserId,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LeaderboardHeader(),
                const SizedBox(height: 22),
                _PodiumHero(user: users.first),
                const SizedBox(height: 18),
                _FirebaseBanner(isLive: isLive),
                const SizedBox(height: 22),
                const _SectionTitle(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _RankRow(
                user: users[i],
                rank: i + 1,
                isMe: users[i].id == myUserId,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: (120 * i).ms)
                  .slideX(begin: 0.18, end: 0),
              childCount: users.length,
            ),
          ),
        ),
      ]);
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader();

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.gold.withOpacity(0.35),
                AppTheme.accent.withOpacity(0.18),
              ],
            ),
            border: Border.all(color: AppTheme.gold.withOpacity(0.55), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.emoji_events, color: AppTheme.gold, size: 25),
        ).animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2400.ms, color: AppTheme.gold.withOpacity(0.35)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  shadows: [
                    Shadow(color: AppTheme.gold.withOpacity(0.35), blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Your XP, wins and rank',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ]).animate().fadeIn(duration: 550.ms).slideY(begin: -0.15, end: 0);
}

class _PodiumHero extends StatelessWidget {
  final UserModel user;
  const _PodiumHero({required this.user});

  @override
  Widget build(BuildContext context) {
    final level = AppConstants.levelNumber(user.totalXp);
    final title = AppConstants.levelTitle(user.totalXp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.gold.withOpacity(0.18),
            AppTheme.accent.withOpacity(0.16),
            Colors.black.withOpacity(0.34),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withOpacity(0.42), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withOpacity(0.22),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.gold.withOpacity(0.35),
                  AppTheme.accent.withOpacity(0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          AvatarWidget(initials: user.avatarInitials, size: 78, showBorder: true),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold,
                border: Border.all(color: Colors.white.withOpacity(0.55), width: 2),
                boxShadow: [
                  BoxShadow(color: AppTheme.gold.withOpacity(0.55), blurRadius: 14),
                ],
              ),
              child: const Center(
                child: Text(
                  '#1',
                  style: TextStyle(
                    color: Color(0xFF241500),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Text(
          user.username,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: AppTheme.gold.withOpacity(0.28), blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Level $level - $title',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: _HeroStat(
              label: 'XP',
              value: '${user.totalXp}',
              icon: Icons.bolt,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _HeroStat(
              label: 'Wins',
              value: '${user.gamesWon}',
              icon: Icons.local_fire_department,
              color: AppTheme.coral,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _HeroStat(
              label: 'Played',
              value: '${user.gamesPlayed}',
              icon: Icons.sports_esports,
              color: AppTheme.accent,
            ),
          ),
        ]),
      ]),
    ).animate().fadeIn(duration: 650.ms, delay: 100.ms).scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
        );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.38), width: 1.3),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]),
      );
}

class _FirebaseBanner extends StatelessWidget {
  final bool isLive;
  const _FirebaseBanner({required this.isLive});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.blue.withOpacity(0.16),
              Colors.black.withOpacity(0.24),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.blue.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(color: AppTheme.blue.withOpacity(0.13), blurRadius: 18),
          ],
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.blue.withOpacity(0.18),
              border: Border.all(color: AppTheme.blue.withOpacity(0.4)),
            ),
            child: const Icon(Icons.public, color: AppTheme.blue, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLive
                  ? 'Live Firebase rankings are synced across players.'
                  : 'Loading Firebase rankings. Showing your local profile for now.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
      ).animate().fadeIn(duration: 550.ms, delay: 220.ms).slideY(begin: 0.2, end: 0);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) => const Row(children: [
        Icon(Icons.military_tech, color: AppTheme.gold, size: 20),
        SizedBox(width: 8),
        Text(
          'Current Ranking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]);
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.gold.withOpacity(0.32),
                    AppTheme.accent.withOpacity(0.16),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(color: AppTheme.gold.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.35),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.emoji_events, color: AppTheme.gold, size: 56),
            ).animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2400.ms, color: AppTheme.gold.withOpacity(0.3)),
            const SizedBox(height: 26),
            Text(
              'No Players Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(color: AppTheme.gold.withOpacity(0.32), blurRadius: 12),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 10),
            const Text(
              'Create a profile and play games to appear on the leaderboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
            ).animate().fadeIn(duration: 600.ms, delay: 180.ms),
          ],
        ),
      );
}

class _RankRow extends StatelessWidget {
  final UserModel user;
  final int rank;
  final bool isMe;

  const _RankRow({
    required this.user,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accent.withOpacity(isMe ? 0.16 : 0.08),
              Colors.black.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isMe ? AppTheme.accent.withOpacity(0.48) : Colors.white12,
            width: isMe ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(color: AppTheme.accent.withOpacity(0.16), blurRadius: 16),
          ],
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold.withOpacity(0.14),
              border: Border.all(color: AppTheme.gold.withOpacity(0.45), width: 1.5),
              boxShadow: [
                BoxShadow(color: AppTheme.gold.withOpacity(0.2), blurRadius: 12),
              ],
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AvatarWidget(initials: user.avatarInitials, size: 42, showBorder: isMe),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(
                    user.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.35)),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(
                        color: AppTheme.accentLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text(
                'Level ${AppConstants.levelNumber(user.totalXp)} - ${AppConstants.levelTitle(user.totalXp)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${user.totalXp} XP',
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${user.gamesWon} wins',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ]),
      );
}

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
          color: color.withOpacity(0.58),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.72),
              blurRadius: size * 2.2,
              spreadRadius: size / 2,
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .moveY(
            begin: 0,
            end: -120,
            duration: Duration(milliseconds: 4500 + delay),
            curve: Curves.easeInOut,
          )
          .fadeIn(duration: 1000.ms)
          .then()
          .fadeOut(duration: 1000.ms),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final Color accent;
  _CyberGridPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withOpacity(0.07)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 56) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final dotPaint = Paint()
      ..color = accent.withOpacity(0.24)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 112) {
      for (double y = 0; y < size.height; y += 112) {
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
