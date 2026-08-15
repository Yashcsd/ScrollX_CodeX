// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/user_model.dart';
import '../services/user_provider.dart';
import '../widgets/anti_gravity.dart';
import '../widgets/bounce_press.dart';
import '../widgets/pill_chip.dart';

const _kYellow     = Color(0xFFE4D400);
const _kYellowDark = Color(0xFFB89800); // solid mustard — no opacity
const _kDark       = Color(0xFF1A1A1A);

Color _ringColor(int rank) {
  switch (rank) {
    case 1:  return const Color(0xFFE4D400);
    case 2:  return const Color(0xFF00E5A0);
    case 3:  return const Color(0xFF00D4FF);
    default: return const Color(0xFF00D4FF);
  }
}

// Solid background tint for avatar ring (no opacity)
Color _ringBg(int rank) {
  switch (rank) {
    case 1:  return const Color(0xFFF5EE80); // pale yellow
    case 2:  return const Color(0xFF80F5D0); // pale teal
    case 3:  return const Color(0xFF80EEFF); // pale blue
    default: return const Color(0xFFE8F8FF); // very pale blue
  }
}

// Solid shadow for avatar ring (no opacity)
Color _ringShadow(int rank) {
  switch (rank) {
    case 1:  return const Color(0xFFB89800); // dark mustard
    case 2:  return const Color(0xFF008A60); // dark teal
    case 3:  return const Color(0xFF0088AA); // dark blue
    default: return const Color(0xFF0088AA);
  }
}

String _fmtXp(int xp) {
  if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(0)}k XP';
  return '$xp XP';
}

// ─────────────────────────────────────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isGlobal = true;

  List<UserModel> _rankedUsers(List<UserModel> remote, UserModel? me) {
    final byId = <String, UserModel>{
      for (final u in remote) u.id: u,
      if (me != null) me.id: me,
    };
    return byId.values.toList()
      ..sort((a, b) {
        final x = b.totalXp.compareTo(a.totalXp);
        if (x != 0) return x;
        final w = b.gamesWon.compareTo(a.gamesWon);
        if (w != 0) return w;
        return b.gamesPlayed.compareTo(a.gamesPlayed);
      });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final myUser   = provider.user;
    final topPad   = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<UserModel>>(
        stream: provider.leaderboardStream(),
        builder: (context, snapshot) {
          final remoteList = snapshot.data ?? <UserModel>[];
          final users      = _rankedUsers(remoteList, myUser);
          final topUser    = users.isNotEmpty ? users.first : null;

          return Column(
            children: [
              // ── YELLOW TOP SECTION ───────────────────────────────────────
              Container(
                color: _kYellow,
                padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 24),
                child: AntiGravityWidget(
                  driftPixels: 2.0,
                  child: _HeroCard(topUser: topUser),
                )
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: -0.06, end: 0,
                        curve: Curves.easeOutCubic),
              ),

              // ── WHITE BOTTOM SECTION ─────────────────────────────────────
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: users.isEmpty
                      ? const _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                              16, 16, 16, 110),
                          children: [
                            // Filter pills — Global / Nearby
                            Row(children: [
                              PillChip(
                                icon: Icons.public_rounded,
                                label: 'Global',
                                active: _isGlobal,
                                onTap: () => setState(() => _isGlobal = true),
                              ),
                              const SizedBox(width: 8),
                              PillChip(
                                icon: Icons.location_on_outlined,
                                label: 'Nearby',
                                active: !_isGlobal,
                                onTap: () => setState(() => _isGlobal = false),
                              ),
                            ]),

                            const SizedBox(height: 14),

                            // Rank tiles
                            ...List.generate(
                              users.length,
                              (i) => _RankTile(
                                user: users[i],
                                rank: i + 1,
                                isMe: users[i].id == myUser?.id,
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 350.ms,
                                      delay: (60 * i).ms)
                                  .slideY(
                                      begin: 0.12,
                                      end: 0,
                                      curve: Curves.easeOutCubic),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card — white card floating on yellow bg
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final UserModel? topUser;
  const _HeroCard({required this.topUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          // Hard 3-D depth — solid mustard, no opacity
          BoxShadow(
            color: _kYellowDark,
            blurRadius: 0,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(children: [
        // ── Profile row ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 25, 16, 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: rank + badge + username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '#01',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        color: _kDark,
                        height: 1.0,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _kDark,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [AppTheme.hardShadowSmall],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💎',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            topUser != null
                                ? AppConstants.levelTitle(
                                    topUser!.totalXp)
                                : 'Elight',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      topUser != null
                          ? '@${topUser!.username}'
                          : '@Technoblade',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _kYellow,
                  boxShadow: const [AppTheme.hardShadowSmall],
                ),
                child: Center(
                  child: Text(
                    topUser?.avatarInitials ?? 'TE',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _kDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Stats bar — full capsule, content-width with padding ─────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: _kDark,
              borderRadius: BorderRadius.circular(999), // full capsule
              boxShadow: const [AppTheme.hardShadowSmall],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.bolt_rounded,
                  label: topUser != null
                      ? _fmtXp(topUser!.totalXp)
                      : '50k XP',
                ),
                _vLine(),
                _StatItem(
                  icon: Icons.sports_esports_rounded,
                  label: topUser != null
                      ? '${topUser!.gamesPlayed} Played'
                      : '500 Played',
                ),
                _vLine(),
                _StatItem(
                  icon: Icons.emoji_events_rounded,
                  label: topUser != null
                      ? '${topUser!.gamesWon} Win'
                      : '458 Win',
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _vLine() => Container(
    width: 1,
    height: 24,
    color: const Color(0xFF444444), // solid dark divider — no opacity
  );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: _kYellow, size: 16),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          )),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Rank tile — white card on white bg with subtle shadow
// ─────────────────────────────────────────────────────────────────────────────
class _RankTile extends StatefulWidget {
  final UserModel user;
  final int rank;
  final bool isMe;

  const _RankTile({
    required this.user,
    required this.rank,
    required this.isMe,
  });

  @override
  State<_RankTile> createState() => _RankTileState();
}

class _RankTileState extends State<_RankTile> {
  @override
  Widget build(BuildContext context) {
    final ring = _ringColor(widget.rank);

    return BouncePressWidget(
      onTap: () {
        // Option to trigger selection or detail view
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: widget.isMe
              ? const Color(0xFFFFFBCC)
              : const Color(0xFFF8F8F4), // lighter warm surface
          borderRadius: BorderRadius.circular(20),
          border: widget.isMe
              ? Border.all(color: _kYellow, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDDDCCC), // very subtle warm grey — barely visible
              blurRadius: 0,
              offset: Offset(0, 1), // reduced from 3 to 1
            ),
          ],
        ),
        child: Row(children: [
          // Glow ring avatar — stronger border
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 3),
              color: _ringBg(widget.rank),
              boxShadow: [
                BoxShadow(
                  color: _ringShadow(widget.rank),
                  blurRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.user.avatarInitials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Rank
          SizedBox(
            width: 42,
            child: Text(
              '#${widget.rank.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: _kDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          // Username + You badge
          Expanded(
            child: Row(children: [
              Flexible(
                child: Text(
                  '@${widget.user.username}',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isMe) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ]),
          ),

          // XP pill — pure black + yellow text, tighter
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kDark,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0A0A0A), // solid near-black
                  blurRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _fmtXp(widget.user.totalXp),
              style: const TextStyle(
                color: _kYellow,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — illustrated game-style
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: _kYellow,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kYellowDark, // solid mustard — no opacity
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text('🏆', style: TextStyle(fontSize: 38)),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'No Players Yet',
          style: TextStyle(
            color: _kDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '⚡ Build your XP to rise here',
          style: TextStyle(color: Color(0xFF666666), fontSize: 13),
        ),
        const SizedBox(height: 4),
        const Text(
          '🎮 Play games to appear on the leaderboard',
          style: TextStyle(color: Color(0xFF888888), fontSize: 12),
        ),
      ],
    ),
  );
}
