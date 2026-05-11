// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../core/app_theme.dart';
import '../services/user_provider.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  bool _editing = false;

  static const Map<String, String> _gameNames = {
    'slide_puzzle': 'Slide Puzzle',
    'trivia_quiz': 'Trivia Quiz',
    'memory_match': 'Memory Match',
    'color_match': 'Color Match',
    'math_blitz': 'Math Blitz',
    'word_scramble': 'Word Scramble',
    'reaction_tap': 'Reaction Tap',
    'number_sequence': 'Number Sequence',
    'simon_says': 'Simon Says',
    'snake_lite': 'Snake Lite',
    'typing_speed': 'Typing Speed',
    'odd_one_out': 'Odd One Out',
    'pattern_memory': 'Pattern Memory',
    'balloon_pop': 'Balloon Pop',
    'guess_the_flag': 'Guess the Flag',
    'falling_catch': 'Falling Catch',
    'countdown_clicker': 'Countdown Clicker',
    'anagram_rush': 'Anagram Rush',
    'shape_tap': 'Shape Tap',
    'whack_mole': 'Whack-a-Mole',
    'pairs_equation': 'Equation Pairs',
  };

  static const Map<String, IconData> _gameIcons = {
    'slide_puzzle': Icons.grid_4x4,
    'trivia_quiz': Icons.psychology,
    'memory_match': Icons.style,
    'color_match': Icons.palette,
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.coral, size: 28),
          const SizedBox(width: 12),
          const Text('Delete Account?', style: TextStyle(color: Colors.white, fontSize: 20)),
        ]),
        content: const Text(
          'This permanently deletes your profile, all scores and XP. This cannot be undone.',
          style: TextStyle(color: AppTheme.textSec, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSec)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserProvider>().deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.coral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final prov = context.read<UserProvider>();

    // ── No profile yet ────────────────────────────────────────────────────────
    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D0B1E), Color(0xFF1A1535), Color(0xFF0D0B1E)],
            ),
          ),
          child: Stack(children: [
            // Floating particles
            ...List.generate(6, (i) => _FloatingParticle(
              delay: i * 300,
              color: AppTheme.accent,
              size: (i % 3 + 1) * 2.5,
            )),

            Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                // Neon avatar placeholder
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.accent.withOpacity(0.3), Colors.transparent],
                    ),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.6), width: 3),
                    boxShadow: [
                      BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                  child: const Center(
                    child: Text('👾', style: TextStyle(fontSize: 48)),
                  ),
                ).animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2000.ms, color: AppTheme.accent.withOpacity(0.3)),

                const SizedBox(height: 24),

                Text('Create Your Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 20),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                const Text(
                  'Set a username to track your XP, earn badges and climb the leaderboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 14),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 40),

                // Neon input field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(color: AppTheme.accent.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
                    ],
                  ),
                  child: TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Enter a username…',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 24),

                // Neon button
                _NeonButton(
                  onTap: () {
                    final n = _nameCtrl.text.trim();
                    if (n.isEmpty) return;
                    prov.createUser(n);
                  },
                  label: 'Create Profile',
                  icon: Icons.rocket_launch,
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, end: 0),
              ]),
            )),
          ]),
        ),
      );
    }

    // ── Profile exists ────────────────────────────────────────────────────────
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0B1E), Color(0xFF1A1535)],
          ),
        ),
        child: Stack(children: [
          // Cyberpunk grid
          CustomPaint(
            painter: _CyberGridPainter(accent: AppTheme.accent),
            size: MediaQuery.of(context).size,
          ),

          // Floating particles
          ...List.generate(5, (i) => _FloatingParticle(
            delay: i * 400,
            color: AppTheme.accent,
            size: (i % 3 + 1) * 2.0,
          )),

          SafeArea(
            child: CustomScrollView(slivers: [
              // App bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                title: Text('My Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    shadows: [Shadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 10)],
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
                      boxShadow: [
                        BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 12),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(_editing ? Icons.check : Icons.edit_outlined,
                          color: AppTheme.accent, size: 22),
                      onPressed: () async {
                        if (_editing) {
                          final n = _nameCtrl.text.trim();
                          if (n.isNotEmpty && n != user.username) {
                            await prov.updateProfile(n);
                          }
                        } else {
                          _nameCtrl.text = user.username;
                        }
                        setState(() => _editing = !_editing);
                      },
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    // Neon Avatar + Name
                    _NeonProfileHeader(
                      user: user,
                      editing: _editing,
                      nameController: _nameCtrl,
                    ),

                    const SizedBox(height: 28),

                    // XP Progress bar
                    _NeonXpBar(xp: user.totalXp),

                    const SizedBox(height: 24),

                    // Stats grid
                    _StatsGrid(user: user),

                    const SizedBox(height: 28),

                    // Badges section
                    _BadgesSection(badges: user.badges),

                    const SizedBox(height: 28),

                    // Best Scores
                    _BestScoresSection(
                      bestScores: user.bestScores,
                      gameNames: _gameNames,
                    ),

                    const SizedBox(height: 32),

                    // Delete button
                    _NeonDeleteButton(onTap: () => _confirmDelete(context)),

                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Neon Profile Header
// ─────────────────────────────────────────────────────────────────────────────
class _NeonProfileHeader extends StatelessWidget {
  final user;
  final bool editing;
  final TextEditingController nameController;

  const _NeonProfileHeader({
    required this.user,
    required this.editing,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Glowing avatar
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.accent.withOpacity(0.3),
              AppTheme.accent.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          border: Border.all(color: AppTheme.accent.withOpacity(0.6), width: 3),
          boxShadow: [
            BoxShadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 40, spreadRadius: 10),
            BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 80, spreadRadius: 20),
          ],
        ),
        child: Center(
          child: Text(
            user.avatarInitials,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 2000.ms, color: AppTheme.accent.withOpacity(0.2)),

      const SizedBox(height: 16),

      // Username
      editing
          ? Container(
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 2),
          color: Colors.black.withOpacity(0.3),
        ),
        child: TextField(
          controller: nameController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Username',
            hintStyle: TextStyle(color: Colors.white38),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      )
          : Text(
        user.username,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
          shadows: [
            Shadow(color: AppTheme.accent.withOpacity(0.6), blurRadius: 20),
          ],
        ),
      ),

      const SizedBox(height: 10),

      // Level badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.accent.withOpacity(0.3), AppTheme.accent.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 16, spreadRadius: 2),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.military_tech, color: AppTheme.gold, size: 16),
          const SizedBox(width: 6),
          Text(
            'Level ${AppConstants.levelNumber(user.totalXp)} · ${AppConstants.levelTitle(user.totalXp)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ]),
      ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 2500.ms, color: AppTheme.gold.withOpacity(0.3)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Neon XP Bar
// ─────────────────────────────────────────────────────────────────────────────
class _NeonXpBar extends StatelessWidget {
  final int xp;
  const _NeonXpBar({required this.xp});

  @override
  Widget build(BuildContext context) {
    final level = AppConstants.levelNumber(xp);
    final current = xp % 500;
    final progress = current / 500;

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Level $level · ${AppConstants.levelTitle(xp)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        Text('$current / 500 XP',
            style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),

      const SizedBox(height: 8),

      Container(
        height: 10,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(children: [
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.6)],
                  ),
                  boxShadow: [
                    BoxShadow(color: AppTheme.accent.withOpacity(0.6), blurRadius: 12, spreadRadius: 1),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Grid
// ─────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final user;
  const _StatsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatCard(
        label: 'Total XP',
        value: '${user.totalXp}',
        icon: Icons.bolt,
        color: AppTheme.gold,
      )),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(
        label: 'Games Won',
        value: '${user.gamesWon}',
        icon: Icons.emoji_events,
        color: AppTheme.teal,
      )),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(
        label: 'Played',
        value: '${user.gamesPlayed}',
        icon: Icons.sports_esports,
        color: AppTheme.accent,
      )),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            Colors.black.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 16, spreadRadius: 1),
        ],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            )),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            )),
      ]),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badges Section
// ─────────────────────────────────────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  final List<String> badges;
  const _BadgesSection({required this.badges});

  static const Map<String, IconData> _badgeIcons = {
    'First Game': Icons.flag,
    '5 Wins': Icons.whatshot,
    '10 Wins': Icons.military_tech,
    '500 XP': Icons.bolt,
    '1K XP': Icons.diamond,
    'Puzzle Pro': Icons.extension,
    'Quiz Ace': Icons.psychology,
    'Memory King': Icons.auto_awesome,
    'Color Master': Icons.palette,
  };

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.workspace_premium, color: AppTheme.gold, size: 20),
        const SizedBox(width: 8),
        const Text('Top Badges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
      ]),

      const SizedBox(height: 16),

      badges.isEmpty
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Text('Play games to earn badges!',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ),
      )
          : GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: badges.map((b) => _BadgeCard(
          label: b,
          icon: _badgeIcons[b] ?? Icons.star,
        )).toList(),
      ),
    ]);
  }
}

class _BadgeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  const _BadgeCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.gold.withOpacity(0.2),
            Colors.black.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppTheme.gold.withOpacity(0.3), blurRadius: 12),
        ],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: AppTheme.gold, size: 28),
        const SizedBox(height: 6),
        Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.7, 0.7));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Best Scores Section
// ─────────────────────────────────────────────────────────────────────────────
class _BestScoresSection extends StatelessWidget {
  final Map<String, int> bestScores;
  final Map<String, String> gameNames;

  const _BestScoresSection({
    required this.bestScores,
    required this.gameNames,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.emoji_events, color: AppTheme.teal, size: 20),
        const SizedBox(width: 8),
        const Text('Best Scores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
      ]),

      const SizedBox(height: 16),

      bestScores.isEmpty
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Text('No scores yet. Start playing!',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ),
      )
          : Column(
        children: bestScores.entries.take(5).map((e) => _ScoreRow(
          game: gameNames[e.key] ?? e.key,
          score: '${e.value} pts',
        )).toList(),
      ),
    ]);
  }
}

class _ScoreRow extends StatelessWidget {
  final String game, score;
  const _ScoreRow({required this.game, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.1),
            Colors.black.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: AppTheme.accent.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.teal,
              boxShadow: [
                BoxShadow(color: AppTheme.teal.withOpacity(0.6), blurRadius: 8, spreadRadius: 2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(game,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
        ]),
        Text(score,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            )),
      ]),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Neon Button
// ─────────────────────────────────────────────────────────────────────────────
class _NeonButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const _NeonButton({
    required this.onTap,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.accent, Color(0xFF6B5FCC)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 24, spreadRadius: 2),
            BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 40, spreadRadius: 5),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              )),
        ]),
      ).animate(onPlay: (c) => c.repeat())
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.03, 1.03), duration: 1000.ms)
          .then()
          .scale(begin: const Offset(1.03, 1.03), end: const Offset(1.0, 1.0), duration: 1000.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete Button
// ─────────────────────────────────────────────────────────────────────────────
class _NeonDeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NeonDeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.coral.withOpacity(0.5), width: 2),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_outline, color: AppTheme.coral, size: 20),
          SizedBox(width: 8),
          Text('Delete Account',
              style: TextStyle(
                color: AppTheme.coral,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Particle
// ─────────────────────────────────────────────────────────────────────────────
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
          color: color.withOpacity(0.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.8), blurRadius: size * 2, spreadRadius: size / 2),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat())
          .moveY(begin: 0, end: -120, duration: Duration(milliseconds: 5000 + delay), curve: Curves.easeInOut)
          .fadeIn(duration: 1200.ms)
          .then()
          .fadeOut(duration: 1200.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cyberpunk Grid
// ─────────────────────────────────────────────────────────────────────────────
class _CyberGridPainter extends CustomPainter {
  final Color accent;
  _CyberGridPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withOpacity(0.06)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}