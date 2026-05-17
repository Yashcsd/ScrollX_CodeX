// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/user_model.dart';
import '../services/user_provider.dart';

const _kYellow     = Color(0xFFE4D400);
const _kYellowDark = Color(0xFF9A8A00);
const _kDark       = Color(0xFF1A1A1A);

Color _ringColor(int rank) {
  switch (rank) {
    case 1:  return const Color(0xFFE4D400);
    case 2:  return const Color(0xFF00E5A0);
    case 3:  return const Color(0xFF00D4FF);
    default: return const Color(0xFF00D4FF);
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
                child: _HeroCard(topUser: topUser)
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
                            // Filter pills
                            Row(children: [
                              _FilterPill(
                                icon: Icons.public_rounded,
                                label: '#01',
                                active: _isGlobal,
                                onTap: () =>
                                    setState(() => _isGlobal = true),
                              ),
                              const SizedBox(width: 10),
                              _FilterPill(
                                icon: Icons.location_on_outlined,
                                label: '#01',
                                active: !_isGlobal,
                                onTap: () =>
                                    setState(() => _isGlobal = false),
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
        boxShadow: [
          // Hard 3-D depth
          const BoxShadow(
            color: _kYellowDark,
            blurRadius: 0,
            offset: Offset(0, 7),
          ),
          // Soft ambient
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(children: [
        // ── Profile row ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                  boxShadow: [
                    BoxShadow(
                      color: _kYellow.withOpacity(0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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

        // ── Stats bar — black rounded bottom ──────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: _kDark,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                icon: '⚡',
                label: topUser != null
                    ? _fmtXp(topUser!.totalXp)
                    : '50k XP',
              ),
              _vLine(),
              _StatItem(
                icon: '🎮',
                label: topUser != null
                    ? '${topUser!.gamesPlayed} Played'
                    : '500 Played',
              ),
              _vLine(),
              _StatItem(
                icon: '🏆',
                label: topUser != null
                    ? '${topUser!.gamesWon} Win'
                    : '458 Win',
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _vLine() => Container(
    width: 1,
    height: 24,
    color: Colors.white.withOpacity(0.12),
  );
}

class _StatItem extends StatelessWidget {
  final String icon, label;
  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(icon, style: const TextStyle(fontSize: 15)),
      const SizedBox(width: 6),
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
// Filter pills
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? _kYellow : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active
              ? _kYellowDark
              : const Color(0xFFCCBB00).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: active
            ? [
                const BoxShadow(
                  color: _kYellowDark,
                  blurRadius: 0,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: active ? _kDark : const Color(0xFF888888)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                color: active ? _kDark : const Color(0xFF888888),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    ),
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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ring = _ringColor(widget.rank);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isMe
                ? const Color(0xFFFFFBCC)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            border: widget.isMe
                ? Border.all(
                    color: _kYellow.withOpacity(0.6),
                    width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(children: [
            // Glow ring avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 2.5),
                color: ring.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: ring.withOpacity(0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.user.avatarInitials,
                  style: const TextStyle(
                    fontSize: 15,
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
                      color: Color(0xFF999999),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kDark,
                      borderRadius: BorderRadius.circular(10),
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

            // XP badge — black + yellow text
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kDark,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _fmtXp(widget.user.totalXp),
                style: const TextStyle(
                  color: _kYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
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
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              const BoxShadow(
                color: _kYellowDark,
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 8),
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
          'Play games to appear on the leaderboard.',
          style: TextStyle(color: Color(0xFF666666), fontSize: 13),
        ),
      ],
    ),
  );
}
