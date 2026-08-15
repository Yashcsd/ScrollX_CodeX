// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../main.dart' show MainShell;
import '../services/user_provider.dart';
import '../widgets/scrollx_dark_background.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kYellow     = Color(0xFFE4D400);
const _kYellowDark = Color(0xFF9A8A00);
const _kDark       = Color(0xFF1A1A1A);
const _kWhite      = Colors.white;
const _kTextSec    = Color(0xFFAFAFAF);

// ── Hero game image used on the onboarding screen ────────────────────────────
// Swap this asset if a different one is preferred.
const _kHeroAsset = 'assets/images/games_icon/slide_puzzle.png';

// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  String _enteredName = '';

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() => _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );

  void _getStarted() {
    if (_page == 0) {
      _nextPage();
    } else {
      _showBirthYearPicker();
    }
  }

  void _showBirthYearPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (_) => _BirthYearSheet(
        onContinue: (year) async {
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 200));
          await _finishOnboarding();
        },
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    if (!mounted) return;
    try {
      final prov = context.read<UserProvider>();
      final name =
          _enteredName.trim().isNotEmpty ? _enteredName.trim() : 'Player';
      await prov.createUser(name);
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF050505),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (p) => setState(() => _page = p),
          children: [
            _WelcomePage(currentPage: _page, onGetStarted: _getStarted),
            _NameInputPage(
              currentPage: _page,
              onContinue: (name) {
                setState(() => _enteredName = name);
                _showBirthYearPicker();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: ScrollX wordmark  ("Scroll" white + "X" yellow)
// Mirrors the exact treatment used in _ScrollXBrandBadge (feed_screen.dart)
// but adapted for the dark onboarding context.
// ─────────────────────────────────────────────────────────────────────────────
class _Wordmark extends StatelessWidget {
  final double fontSize;
  const _Wordmark({this.fontSize = 36});

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'National Park',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.0,
          ),
          children: const [
            TextSpan(
              text: 'Scroll',
              style: TextStyle(color: _kWhite),
            ),
            TextSpan(
              text: 'X',
              style: TextStyle(color: AppTheme.consoleYellow),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: rounded hero image
// ─────────────────────────────────────────────────────────────────────────────
class _HeroImage extends StatelessWidget {
  final double size;
  final String asset;

  const _HeroImage({required this.size, required this.asset});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: white bottom panel
// ─────────────────────────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final Widget child;

  const _BottomPanel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: child,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: yellow CTA button
// ─────────────────────────────────────────────────────────────────────────────
class _YellowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _YellowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
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
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: _kDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: page indicator dots
// ─────────────────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  final int current;
  final int total;

  const _PageDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) {
          final active = i == current;
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
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1 — Welcome
// ─────────────────────────────────────────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final int currentPage;
  final VoidCallback onGetStarted;

  const _WelcomePage({
    required this.currentPage,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final imageSize = (size.width * 0.50).clamp(160.0, 210.0);

    return ScrollXDarkBackground(
      patternSeed: 0,
      child: Column(
        children: [
          // ── Dark upper zone ───────────────────────────────────────────
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(height: topPad < 24 ? 24.0 : 8.0),

                  // Wordmark
                  const _Wordmark(fontSize: 34)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(
                        begin: -0.15,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const Spacer(),

                  // Hero image — rounded, shadowed
                  _HeroImage(size: imageSize, asset: _kHeroAsset)
                      .animate()
                      .fadeIn(duration: 700.ms, delay: 150.ms)
                      .scale(
                        begin: const Offset(0.88, 0.88),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        delay: 150.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // ── White bottom panel ─────────────────────────────────────────
          _BottomPanel(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tagline
                  const Text(
                    'Play quick games, build your XP,\nand climb the leaderboard.',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 22),

                  // CTA
                  _YellowButton(
                    label: 'GET STARTED',
                    onTap: onGetStarted,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        delay: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 16),

                  // Indicators
                  Center(
                    child: _PageDots(current: currentPage, total: 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2 — Name input
// ─────────────────────────────────────────────────────────────────────────────
class _NameInputPage extends StatefulWidget {
  final int currentPage;
  final ValueChanged<String> onContinue;

  const _NameInputPage({
    required this.currentPage,
    required this.onContinue,
  });

  @override
  State<_NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<_NameInputPage> {
  final _nameCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final imageSize = (size.width * 0.42).clamp(140.0, 190.0);

    return ScrollXDarkBackground(
      patternSeed: 1,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                // ── Dark upper zone ─────────────────────────────────────
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        SizedBox(height: topPad < 24 ? 20.0 : 4.0),

                        // Wordmark — smaller on page 2 (secondary role)
                        const _Wordmark(fontSize: 26)
                            .animate()
                            .fadeIn(duration: 500.ms),

                        const SizedBox(height: 20),

                        // Hero image
                        _HeroImage(
                          size: imageSize,
                          asset: _kHeroAsset,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 100.ms)
                            .scale(
                              begin: const Offset(0.90, 0.90),
                              end: const Offset(1.0, 1.0),
                              duration: 600.ms,
                              delay: 100.ms,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 24),

                        // Headings
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Let's get to know you",
                                style: const TextStyle(
                                  color: _kTextSec,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ).animate().fadeIn(
                                    duration: 400.ms, delay: 200.ms),
                              const SizedBox(height: 5),
                              Text(
                                'What should we call you?',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: _kWhite,
                                  letterSpacing: -0.5,
                                ),
                              ).animate().fadeIn(
                                    duration: 400.ms, delay: 280.ms),
                            ],
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // ── White bottom panel ──────────────────────────────────
                _BottomPanel(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name input
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _isFocused
                                  ? _kYellow
                                  : const Color(0xFFE8E8E8),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _isFocused
                                    ? _kYellow.withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.03),
                                blurRadius: _isFocused ? 8 : 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _nameCtrl,
                            focusNode: _focusNode,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _kDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: TextStyle(
                                color: Color(0xFFBBBBBB),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CTA
                        _YellowButton(
                          label: 'CONTINUE',
                          onTap: () {
                            final name = _nameCtrl.text.trim();
                            if (name.isNotEmpty) {
                              widget.onContinue(name);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enter your name to continue'),
                                  backgroundColor: _kDark,
                                ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 14),

                        // Indicators
                        Center(
                          child: _PageDots(
                              current: widget.currentPage, total: 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Birth year picker bottom sheet (unchanged logic)
// ─────────────────────────────────────────────────────────────────────────────
class _BirthYearSheet extends StatefulWidget {
  final ValueChanged<int> onContinue;
  const _BirthYearSheet({required this.onContinue});

  @override
  State<_BirthYearSheet> createState() => _BirthYearSheetState();
}

class _BirthYearSheetState extends State<_BirthYearSheet> {
  static const int _minYear = 1950;
  late final int _maxYear;
  int _selectedYear = 2000;
  late FixedExtentScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _maxYear = DateTime.now().year;
    _scrollCtrl =
        FixedExtentScrollController(initialItem: _selectedYear - _minYear);
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
        color: _kWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Yellow wheel section
          Container(
            height: 290,
            decoration: const BoxDecoration(
              color: _kYellow,
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
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'when were you born?',
                  style: TextStyle(
                    color: _kDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
                        final year = _minYear + i;
                        final sel = year == _selectedYear;
                        return Center(
                          child: Text(
                            '$year',
                            style: TextStyle(
                              color: sel
                                  ? _kDark
                                  : _kDark.withValues(alpha: 0.35),
                              fontSize: sel ? 42 : 28,
                              fontWeight: sel
                                  ? FontWeight.w900
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Continue section
          Padding(
            padding: EdgeInsets.fromLTRB(24, 22, 24, bottomPad + 18),
            child: Column(
              children: [
                const Text(
                  'This stays on-device for now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                _YellowButton(
                  label: 'Continue',
                  onTap: () => widget.onContinue(_selectedYear),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
