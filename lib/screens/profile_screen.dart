// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/user_provider.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _editing   = false;

  static const Map<String, String> _gameNames = {
    'slide_puzzle': '🧩 Slide Puzzle',
    'trivia_quiz':  '🎯 Trivia Quiz',
    'memory_match': '🃏 Memory Match',
    'color_match':  '🎨 Color Match',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Confirm delete dialog ─────────────────────────────────────────────────
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'This permanently deletes your profile, all scores '
            'and XP from Firestore. This cannot be undone.',
            style: TextStyle(color: AppTheme.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSec)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserProvider>().deleteAccount();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.coral)),
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
        backgroundColor: AppTheme.bg,
        body: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👾',
                  style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              const Text('Create Your Profile',
                  style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              const Text(
                  'Set a username to track your XP, earn badges '
                  'and climb the leaderboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSec, height: 1.5)),
              const SizedBox(height: 32),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter a username…',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true, fillColor: AppTheme.bgSurface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppTheme.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppTheme.accent, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final n = _nameCtrl.text.trim();
                    if (n.isEmpty) return;
                    prov.createUser(n); // CREATE
                  },
                  child: const Text('Create Profile'),
                ),
              ),
            ],
          ),
        )),
      );
    }

    // ── Profile exists ────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit_outlined,
                color: AppTheme.accentLight),
            onPressed: () async {
              if (_editing) {
                final n = _nameCtrl.text.trim();
                if (n.isNotEmpty && n != user.username) {
                  await prov.updateProfile(n); // UPDATE
                }
              } else {
                _nameCtrl.text = user.username;
              }
              setState(() => _editing = !_editing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name
            Center(child: Column(children: [
              AvatarWidget(initials: user.avatarInitials, size: 76),
              const SizedBox(height: 14),
              _editing
                  ? SizedBox(width: 220,
                      child: TextField(
                        controller: _nameCtrl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Username',
                          hintStyle: TextStyle(
                              color: AppTheme.textMuted),
                        ),
                      ))
                  : Text(user.username,
                      style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Text(
                  'Level ${AppConstants.levelNumber(user.totalXp)}'
                  ' · ${AppConstants.levelTitle(user.totalXp)}',
                  style: const TextStyle(
                      color: AppTheme.accentLight,
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ])),
            const SizedBox(height: 20),

            // XP bar
            XpBarWidget(xp: user.totalXp),
            const SizedBox(height: 24),

            // Stats row
            Row(children: [
              Expanded(child: StatCard(
                  label: 'Total XP', value: '${user.totalXp}')),
              const SizedBox(width: 10),
              Expanded(child: StatCard(
                  label: 'Games Won', value: '${user.gamesWon}')),
              const SizedBox(width: 10),
              Expanded(child: StatCard(
                  label: 'Played', value: '${user.gamesPlayed}')),
            ]),
            const SizedBox(height: 24),

            // Badges — READ from user.badges
            const Text('Badges',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            user.badges.isEmpty
                ? const Text('Play games to earn badges!',
                    style: TextStyle(color: AppTheme.textMuted))
                : Wrap(
                    spacing: 8, runSpacing: 8,
                    children: user.badges
                        .map((b) => BadgeChip(label: b))
                        .toList(),
                  ),
            const SizedBox(height: 24),

            // Best scores — READ from user.bestScores
            const Text('Best Scores',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            user.bestScores.isEmpty
                ? const Text('No scores yet. Start playing!',
                    style: TextStyle(color: AppTheme.textMuted))
                : Column(
                    children: user.bestScores.entries.map((e) =>
                      _scoreRow(
                        _gameNames[e.key] ?? e.key,
                        '${e.value} pts',
                      ),
                    ).toList(),
                  ),
            const SizedBox(height: 32),

            // Delete account — DELETE
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppTheme.coral),
                label: const Text('Delete Account',
                    style: TextStyle(color: AppTheme.coral)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppTheme.coral.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(String game, String score) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.bgSurface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(game, style: const TextStyle(
            color: AppTheme.textSec, fontSize: 14)),
        Text(score, style: const TextStyle(
            color: AppTheme.accent, fontSize: 14,
            fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
