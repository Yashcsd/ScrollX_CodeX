// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/user_provider.dart';
import '../main.dart' show MainShell;

const _kYellow     = Color(0xFFE4D400);
const _kYellowMid  = Color(0xFFCCBB00);
const _kYellowDark = Color(0xFF9A8A00);
const _kDark       = Color(0xFF1A1A1A);

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Shell
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int  _page      = 0;
  bool _signingIn = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _googleLogin() async {
    setState(() => _signingIn = true);
    final user = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _signingIn = false);

    if (user != null) {
      // Google login succeeded → finish onboarding immediately, no birth year needed
      await _finishOnboarding();
    }
  }

  void _getStarted() {
    if (_page == 0) {
      _nextPage();
    } else {
      // GET STARTED without Google → show birth year picker
      _showBirthYearPicker();
    }
  }

  void _showBirthYearPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (_) => _BirthYearSheet(
        onContinue: (year) async {
          Navigator.pop(context); // close sheet first
          await _finishOnboarding();
        },
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    if (!mounted) return;

    final prov         = context.read<UserProvider>();
    final firebaseUser = AuthService.currentUser;
    final name         = firebaseUser?.displayName ??
        firebaseUser?.email?.split('@').first ??
        'Player';

    // createUser sets _sessionActive = true and calls notifyListeners()
    await prov.createUser(name);

    // Safety net: if _AppRoot didn't navigate yet, push manually
    if (mounted && prov.isLoggedIn) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false, // remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kYellow,
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (p) => setState(() => _page = p),
          children: [
            // ── Page 1: ScrollX title only ──────────────────────────────
            _OnboardPage(
              page: 0,
              currentPage: _page,
              showGoogleButton: false,
              signingIn: _signingIn,
              onGetStarted: _getStarted,
              onGoogleLogin: _googleLogin,
            ),
            // ── Page 2: Welcome to + Google login ───────────────────────
            _OnboardPage(
              page: 1,
              currentPage: _page,
              showGoogleButton: true,
              signingIn: _signingIn,
              onGetStarted: _getStarted,
              onGoogleLogin: _googleLogin,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single onboarding page
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardPage extends StatelessWidget {
  final int page;
  final int currentPage;
  final bool showGoogleButton;
  final bool signingIn;
  final VoidCallback onGetStarted;
  final VoidCallback onGoogleLogin;

  const _OnboardPage({
    required this.page,
    required this.currentPage,
    required this.showGoogleButton,
    required this.signingIn,
    required this.onGetStarted,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(children: [
      // ── Yellow-olive gradient background ─────────────────────────────
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4C800),
              Color(0xFF9A8E00),
            ],
          ),
        ),
      ),

      // ── Hanging character from top ────────────────────────────────────
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: _HangingCharacter(
          topPad: topPad,
          screenWidth: size.width,
          screenHeight: size.height,
        ),
      ),

      // ── Bottom content area ───────────────────────────────────────────
      Positioned(
        left: 0, right: 0, bottom: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showGoogleButton) ...[
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  // ScrollX title
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Scroll',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'X',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: _kYellow,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit, sed do\neiusmod tempor incididunt ut l',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  if (showGoogleButton) ...[
                    const SizedBox(height: 18),
                    _GoogleButton(
                      loading: signingIn,
                      onTap: onGoogleLogin,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // White bottom sheet
            _BottomSheet(
              currentPage: currentPage,
              onGetStarted: onGetStarted,
            ),
          ],
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hanging character — emoji rabbit hanging upside down
// ─────────────────────────────────────────────────────────────────────────────
class _HangingCharacter extends StatelessWidget {
  final double topPad;
  final double screenWidth;
  final double screenHeight;

  const _HangingCharacter({
    required this.topPad,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final charSize = screenWidth * 0.52;

    return SizedBox(
      height: screenHeight * 0.54,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Rope from very top
          Positioned(
            top: topPad,
            child: Container(
              width: 4,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Character circle
          Positioned(
            top: topPad + 30,
            child: Container(
              width: charSize,
              height: charSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '🐰',
                  style: TextStyle(fontSize: charSize * 0.55),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.08, end: 0,
                    curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google login button
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _GoogleButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // G circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(9),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kDark,
                    ),
                  )
                : const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Login with google',
            style: TextStyle(
              color: _kDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  )
      .animate()
      .fadeIn(duration: 400.ms, delay: 100.ms)
      .slideX(begin: -0.08, end: 0);
}

// ─────────────────────────────────────────────────────────────────────────────
// White bottom sheet with GET STARTED + dots
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final int currentPage;
  final VoidCallback onGetStarted;

  const _BottomSheet({
    required this.currentPage,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 0,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 22, 24, bottomPad + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // GET STARTED button
          GestureDetector(
            onTap: onGetStarted,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: const BoxDecoration(
                color: _kYellow,
                borderRadius: BorderRadius.all(Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: _kYellowDark,
                    blurRadius: 0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'GET STARTED',
                  style: TextStyle(
                    color: _kDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Page indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? _kYellow : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Birth Year Picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _BirthYearSheet extends StatefulWidget {
  final ValueChanged<int> onContinue;
  const _BirthYearSheet({required this.onContinue});
  @override
  State<_BirthYearSheet> createState() => _BirthYearSheetState();
}

class _BirthYearSheetState extends State<_BirthYearSheet> {
  static const int _minYear = 1950;
  static const int _maxYear = 2015;

  int _selectedYear = 2000;
  late FixedExtentScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = FixedExtentScrollController(
      initialItem: _selectedYear - _minYear,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Yellow top with year wheel ──────────────────────────────────
          Container(
            height: 290,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_kYellow, _kYellowMid],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: _kYellowDark,
                  blurRadius: 0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(children: [
              const SizedBox(height: 24),
              const Text(
                'when were you born?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _scrollCtrl,
                  itemExtent: 58,
                  perspective: 0.003,
                  diameterRatio: 1.6,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) {
                    setState(() => _selectedYear = _minYear + i);
                    HapticFeedback.selectionClick();
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _maxYear - _minYear + 1,
                    builder: (_, i) {
                      final year      = _minYear + i;
                      final isSelected = year == _selectedYear;
                      return Center(
                        child: Text(
                          '$year',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            fontSize: isSelected ? 42 : 28,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ]),
          ),

          // ── White bottom ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24, 22, 24, bottomPad + 18),
            child: Column(children: [
              const Text(
                'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit, sed\ndo eiusmod tempor incididunt ut l',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => widget.onContinue(_selectedYear),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: _kYellow,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: _kYellowDark,
                        blurRadius: 0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: _kDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
