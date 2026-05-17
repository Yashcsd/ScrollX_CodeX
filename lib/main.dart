// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/app_theme.dart';
import 'screens/feed_screen.dart';
import 'screens/games_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'services/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()..initialize(),
      child: const ScrollXApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class ScrollXApp extends StatelessWidget {
  const ScrollXApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppConstants.appName,
    theme: AppTheme.theme,
    debugShowCheckedModeBanner: false,
    home: const _AppRoot(),
    // Named routes for clean navigation
    routes: {
      '/main':       (_) => const MainShell(),
      '/onboarding': (_) => const OnboardingScreen(),
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppRoot — watches UserProvider and routes accordingly
// ─────────────────────────────────────────────────────────────────────────────
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    // Still loading SharedPreferences
    if (provider.isLoading) {
      return const _SplashScreen();
    }

    // Session active → main app with fade transition
    if (provider.isLoggedIn) {
      return const MainShell();
    }

    // No session → onboarding
    return const OnboardingScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash screen — shown only while SharedPreferences loads (~100 ms)
// ─────────────────────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Color(0xFFE4D400),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ScrollX',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
          SizedBox(height: 28),
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main shell — 4-tab navigation
// ─────────────────────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  static const _screens = [
    FeedScreen(),
    GamesScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _idx = i);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    extendBody: true,
    body: IndexedStack(index: _idx, children: _screens),
    bottomNavigationBar: _ScrollXNav(current: _idx, onTap: _onTap),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav
// ─────────────────────────────────────────────────────────────────────────────
class _ScrollXNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _ScrollXNav({required this.current, required this.onTap});

  static const _icons = [
    Icons.sports_esports_rounded,
    Icons.videogame_asset_rounded,
    Icons.emoji_events_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // White pill
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.13),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
            // Icons
            Positioned.fill(
              child: Row(
                children: List.generate(_icons.length, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: i == current
                          ? _ActiveBubble(icon: _icons[i])
                          : _InactiveIcon(icon: _icons[i]),
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActiveBubble extends StatelessWidget {
  final IconData icon;
  const _ActiveBubble({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: 62, height: 62,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppTheme.primary,
      boxShadow: [
        const BoxShadow(
          color: Color(0xFFB89000),
          blurRadius: 0,
          offset: Offset(0, 5),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.22),
          blurRadius: 12,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Icon(icon, color: AppTheme.dark, size: 28),
  );
}

class _InactiveIcon extends StatelessWidget {
  final IconData icon;
  const _InactiveIcon({required this.icon});

  @override
  Widget build(BuildContext context) =>
      Icon(icon, color: const Color(0xFF888888), size: 26);
}
