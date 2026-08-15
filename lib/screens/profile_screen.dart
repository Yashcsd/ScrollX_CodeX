// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../services/user_provider.dart';
import '../services/audio_service.dart';
import 'feed_screen.dart'; // for allFeedGames

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _editing = false;

  static const Map<String, String> _gameNames = {
    'slide_puzzle':       'Slide Puzzle',
    'trivia_quiz':        'Trivia Quiz',
    'memory_match':       'Memory Match',
    'color_match':        'Color Match',
    'math_blitz':         'Math Blitz',
    'word_scramble':      'Word Scramble',
    'reaction_tap':       'Reaction Tap',
    'number_sequence':    'Number Sequence',
    'simon_says':         'Simon Says',
    'snake_lite':         'Snake Lite',
    'typing_speed':       'Typing Speed',
    'odd_one_out':        'Odd One Out',
    'pattern_memory':     'Pattern Memory',
    'balloon_pop':        'Balloon Pop',
    'guess_the_flag':     'Guess the Flag',
    'falling_catch':      'Falling Catch',
    'countdown_clicker':  'Countdown Clicker',
    'anagram_rush':       'Anagram Rush',
    'shape_tap':          'Shape Tap',
    'whack_mole':         'Whack-a-Mole',
    'pairs_equation':     'Equation Pairs',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [
          Text('⚠️', style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Text('Delete Account?',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
          'This permanently deletes your profile, all scores and XP. This cannot be undone.',
          style: TextStyle(color: AppTheme.textSec, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSec)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<UserProvider>().deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: const [AppTheme.hardShadowStrong],
                border: Border.all(color: AppTheme.dark, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.volume_up_rounded, color: AppTheme.dark),
                          SizedBox(width: 10),
                          Text(
                            'Audio Muted',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: AudioService.isMuted,
                        activeTrackColor: AppTheme.primary,
                        onChanged: (val) async {
                          await AudioService.toggleMute(val);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Music Volume',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSec,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, size: 16, color: AppTheme.textMuted),
                      Expanded(
                        child: Slider(
                          value: AudioService.musicVolume,
                          activeColor: AppTheme.primary,
                          inactiveColor: AppTheme.border,
                          onChanged: AudioService.isMuted
                              ? null
                              : (val) async {
                                  await AudioService.setMusicVolume(val);
                                  setModalState(() {});
                                },
                        ),
                      ),
                      Text(
                        '${(AudioService.musicVolume * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSec,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sound Effects Volume',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSec,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.volume_down_rounded, size: 16, color: AppTheme.textMuted),
                      Expanded(
                        child: Slider(
                          value: AudioService.sfxVolume,
                          activeColor: AppTheme.primary,
                          inactiveColor: AppTheme.border,
                          onChanged: AudioService.isMuted
                              ? null
                              : (val) async {
                                  await AudioService.setSfxVolume(val);
                                  setModalState(() {});
                                },
                        ),
                      ),
                      Text(
                        '${(AudioService.sfxVolume * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSec,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.coral, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.coral,
                            blurRadius: 0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.delete_outline_rounded, color: AppTheme.coral, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Delete Account',
                            style: TextStyle(
                              color: AppTheme.coral,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dark, width: 1.5),
                        boxShadow: const [AppTheme.hardShadowSmall],
                      ),
                      child: const Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final prov = context.read<UserProvider>();

    // ── No profile ────────────────────────────────────────────────────────────
    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Column(children: [
          // Yellow header
          Container(
            color: AppTheme.primary,
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 16, 16, 24),
            child: const Center(
              child: Text(
                'My Profile',
                style: TextStyle(
                  color: AppTheme.dark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.consoleYellow,
                        border: Border.all(
                            color: AppTheme.primary, width: 3),
                      ),
                      child: const Center(
                        child: Text('👾',
                            style: TextStyle(fontSize: 40)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Create Your Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Set a username to track your XP,\nearn badges and climb the leaderboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSec, height: 1.5, fontSize: 13),
                    ),
                    const SizedBox(height: 32),

                    // Input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.border, width: 1.5),
                        color: AppTheme.bgCard,
                      ),
                      child: TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 15),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Enter a username…',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Create button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final n = _nameCtrl.text.trim();
                          if (n.isEmpty) return;
                          prov.createUser(n);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.dark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Create Profile',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );
    }

    // ── Profile exists ────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E8), // warm off-white
      body: CustomScrollView(slivers: [
        // ── Yellow profile header card ──────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHeaderCard(
            user: user,
            editing: _editing,
            nameController: _nameCtrl,
            onEditToggle: () async {
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
            onDeleteTap: () => _openSettingsSheet(context),
          ),
        ),

        // ── XP progress bar ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _XpProgressBar(xp: user.totalXp),
          ),
        ),

        // ── Top Badges ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _SectionCard(
              title: 'Top Badges',
              child: user.badges.isEmpty
                  ? const _EmptySection(
                      text: 'Play games to earn badges!')
                  : GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: user.badges
                          .take(6)
                          .map((b) => _BadgeTile(label: b))
                          .toList(),
                    ),
            ),
          ),
        ),

        // ── Top Games ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _SectionCard(
              title: 'Top Games',
              child: user.bestScores.isEmpty
                  ? const _EmptySection(text: 'No games played yet!')
                  : GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: user.bestScores.entries
                          .take(6)
                          .map((e) {
                        final game = allFeedGames
                            .where((g) => g.id == e.key)
                            .firstOrNull;
                        return _GameTile(
                          tintBg: game?.tintBg ?? const Color(0xFFEEEEE8),
                          tintShadow: game?.tintShadow ?? const Color(0xFF999990),
                          iconAsset: game?.iconAsset,
                          emoji: game?.emoji ?? '🎮',
                          name: _gameNames[e.key] ?? e.key,
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),

        // ── Top Scores ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _SectionCard(
              title: 'Top Scores',
              child: user.bestScores.isEmpty
                  ? const _EmptySection(text: 'No scores yet. Start playing!')
                  : Column(
                      children: user.bestScores.entries
                          .take(5)
                          .map((e) => _ScoreRow(
                                game: _gameNames[e.key] ?? e.key,
                                score: e.value,
                              ))
                          .toList(),
                    ),
            ),
          ),
        ),

        // ── Delete button ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.coral, width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        color: AppTheme.coral, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Account',
                        style: TextStyle(
                          color: AppTheme.coral,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile header card (yellow bg + white card)
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final dynamic user;
  final bool editing;
  final TextEditingController nameController;
  final VoidCallback onEditToggle;
  final VoidCallback onDeleteTap;

  const _ProfileHeaderCard({
    required this.user,
    required this.editing,
    required this.nameController,
    required this.onEditToggle,
    required this.onDeleteTap,
  });

  String _fmtXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(0)}k XP';
    return '$xp XP';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 20),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          // #8/#9 — top radius 50 so yellow bleeds through at the header edge;
          // bottom corners slightly rounded for a clean card feel
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [AppTheme.hardShadow],
        ),
        child: Column(children: [
          // Top row: avatar + info + edit + QR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar — flat square, no shadow or border (#12)
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                    // No border, no boxShadow — sits clean and flat on the white card
                  ),
                  child: Center(
                    child: Text(
                      user.avatarInitials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.dark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + handle + level
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      editing
                          ? SizedBox(
                              height: 36,
                              child: TextField(
                                controller: nameController,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppTheme.primary),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  isDense: true,
                                ),
                              ),
                            )
                          : Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                      const SizedBox(height: 3),
                      Text(
                        '@${user.username.toLowerCase().replaceAll(' ', '_')}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Level badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.dark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Text('💎', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(
                            AppConstants.levelTitle(user.totalXp),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),

                // Edit + Settings + QR column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onEditToggle,
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Icon(
                              editing
                                  ? Icons.check_rounded
                                  : Icons.edit_outlined,
                              size: 16,
                              color: AppTheme.textSec,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onDeleteTap,
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              size: 16,
                              color: AppTheme.textSec,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // QR placeholder
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.consoleYellow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded,
                          color: AppTheme.dark, size: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats bar — full capsule
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.dark,
                borderRadius: BorderRadius.circular(999), // full capsule
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(icon: Icons.bolt_rounded,           value: _fmtXp(user.totalXp)),
                  _vDivider(),
                  _StatItem(icon: Icons.sports_esports_rounded, value: '${user.gamesPlayed} Played'),
                  _vDivider(),
                  _StatItem(icon: Icons.emoji_events_rounded,   value: '${user.gamesWon} Win'),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1, height: 28,
    color: const Color(0xFF444444), // solid dark divider — no opacity
  );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  const _StatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppTheme.consoleYellow, size: 16),
      const SizedBox(width: 5),
      Text(value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          )),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// XP Progress bar
// ─────────────────────────────────────────────────────────────────────────────
class _XpProgressBar extends StatelessWidget {
  final int xp;
  const _XpProgressBar({required this.xp});

  @override
  Widget build(BuildContext context) {
    final level    = AppConstants.levelNumber(xp);
    final title    = AppConstants.levelTitle(xp);
    final current  = xp % 500;
    final progress = current / 500.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.hardShadowSmall],
      ),
      child: Row(children: [
        // Level label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.dark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Level $level | $title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 10,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [AppTheme.hardShadowSmall],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge tile — collectible physical badge module
// ─────────────────────────────────────────────────────────────────────────────
class _BadgeTile extends StatelessWidget {
  final String label;
  const _BadgeTile({required this.label});

  // Each badge gets its own color identity
  static const List<_BadgeStyle> _styles = [
    _BadgeStyle(
      top: Color(0xFF2A1A6B), bottom: Color(0xFF0D0828),
      accent: Color(0xFF7F77DD), accentBg: Color(0xFF3A2A7A),
      icon: '⭐', title: 'MVP',
    ),
    _BadgeStyle(
      top: Color(0xFF0A3A6B), bottom: Color(0xFF041828),
      accent: Color(0xFF378ADD), accentBg: Color(0xFF1A4A7A),
      icon: '💎', title: 'Elite',
    ),
    _BadgeStyle(
      top: Color(0xFF6B2A0A), bottom: Color(0xFF280A00),
      accent: Color(0xFFD85A30), accentBg: Color(0xFF7A3A1A),
      icon: '🔥', title: 'Streak',
    ),
    _BadgeStyle(
      top: Color(0xFF1A5A1A), bottom: Color(0xFF082008),
      accent: Color(0xFF1D9E75), accentBg: Color(0xFF1A5A3A),
      icon: '🏆', title: 'Champ',
    ),
    _BadgeStyle(
      top: Color(0xFF5A1A3A), bottom: Color(0xFF200A18),
      accent: Color(0xFFD4537E), accentBg: Color(0xFF6A2A4A),
      icon: '👑', title: 'King',
    ),
    _BadgeStyle(
      top: Color(0xFF3A3A0A), bottom: Color(0xFF181800),
      accent: Color(0xFFE4D400), accentBg: Color(0xFF4A4A10),
      icon: '⚡', title: 'Speed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final idx   = label.hashCode.abs() % _styles.length;
    final style = _styles[idx];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [style.top, style.bottom],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.hardShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.accentBg, // solid tint — no opacity
              border: Border.all(color: style.accent, width: 1.5),
            ),
            child: Center(
              child: Text(style.icon,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 5),
          // Badge title from style
          Text(
            style.title,
            style: TextStyle(
              color: style.accent,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          // Actual badge label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.85, 0.85));
  }
}

class _BadgeStyle {
  final Color top, bottom, accent, accentBg;
  final String icon, title;
  const _BadgeStyle({
    required this.top,
    required this.bottom,
    required this.accent,
    required this.accentBg,
    required this.icon,
    required this.title,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Game tile (for Top Games section)
// ─────────────────────────────────────────────────────────────────────────────
class _GameTile extends StatelessWidget {
  final Color tintBg;
  final Color tintShadow;
  final String? iconAsset;
  final String emoji, name;

  const _GameTile({
    required this.tintBg,
    required this.tintShadow,
    required this.iconAsset,
    required this.emoji,
    required this.name,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: tintBg,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: tintShadow,
          blurRadius: 0,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconAsset != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Image.asset(
              iconAsset!,
              height: 40,
              fit: BoxFit.contain,
            ),
          )
        else
          Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.dark,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8));
}

// ─────────────────────────────────────────────────────────────────────────────
// Score row
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreRow extends StatelessWidget {
  final String game;
  final int score;

  const _ScoreRow({required this.game, required this.score});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [AppTheme.hardShadowSmall],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.teal,
            ),
          ),
          const SizedBox(width: 10),
          Text(game,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.dark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score pts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.15, end: 0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty section placeholder — illustrated, game-style
// ─────────────────────────────────────────────────────────────────────────────
class _EmptySection extends StatelessWidget {
  final String text;
  const _EmptySection({required this.text});

  static const Map<String, _EmptyIllustration> _illustrations = {
    'Play games to earn badges!': _EmptyIllustration(
      icon: Icons.emoji_events_rounded,
      headline: 'No badges yet',
      sub: 'Play games to unlock trophies',
    ),
    'No games played yet!': _EmptyIllustration(
      icon: Icons.sports_esports_rounded,
      headline: 'No games played',
      sub: 'Complete challenges to earn badges',
    ),
    'No scores yet. Start playing!': _EmptyIllustration(
      icon: Icons.bolt_rounded,
      headline: 'No scores yet',
      sub: 'Build your XP to rise here',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final ill = _illustrations[text] ??
        _EmptyIllustration(icon: Icons.sports_esports_rounded, headline: 'Nothing here yet', sub: text);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // #7 — trophy/badge circle: pure black bg, yellow icon
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A), // black bg — icon stays yellow
              shape: BoxShape.circle,
              boxShadow: [AppTheme.hardShadowSmall],
            ),
            child: Center(
              child: Icon(ill.icon, size: 26, color: AppTheme.consoleYellow),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ill.headline,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            ill.sub,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EmptyIllustration {
  final IconData icon;
  final String headline, sub;
  const _EmptyIllustration({
    required this.icon,
    required this.headline,
    required this.sub,
  });
}
