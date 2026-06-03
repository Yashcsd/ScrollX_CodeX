import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../main.dart' show MainShell;
import '../services/user_provider.dart';

const _kYellow = Color(0xFFE4D400);
const _kYellowMid = Color(0xFFCCBB00);
const _kYellowDark = Color(0xFF9A8A00);
const _kDark = Color(0xFF1A1A1A);

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

  void _nextPage() {
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

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
      final name = _enteredName.trim().isNotEmpty ? _enteredName.trim() : 'Player';

      debugPrint('Starting onboarding completion for user: $name');
      await prov.createUser(name);
      await Future.delayed(const Duration(milliseconds: 150));

      if (mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error in _finishOnboarding: $e');
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
      ),
      child: Scaffold(
        backgroundColor: _kYellow,
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (p) => setState(() => _page = p),
          children: [
            _OnboardPage(
              currentPage: _page,
              onGetStarted: _getStarted,
              titlePrefix: null,
            ),
            _NameInputPage(
              currentPage: _page,
              onContinue: (name) {
                setState(() {
                  _enteredName = name;
                });
                _showBirthYearPicker();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final int currentPage;
  final VoidCallback onGetStarted;
  final String? titlePrefix;

  const _OnboardPage({
    required this.currentPage,
    required this.onGetStarted,
    required this.titlePrefix,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _HangingCharacter(
            topPad: topPad,
            screenWidth: size.width,
            screenHeight: size.height,
            emoji: '🐰',
            floating: false,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titlePrefix != null) ...[
                      Text(
                        titlePrefix!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
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
                      'Play quick games, build your XP, and keep everything local for now while we prepare the Supabase migration.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _BottomSheet(
                currentPage: currentPage,
                onGetStarted: onGetStarted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HangingCharacter extends StatelessWidget {
  final double topPad;
  final double screenWidth;
  final double screenHeight;
  final String emoji;
  final bool floating;

  const _HangingCharacter({
    required this.topPad,
    required this.screenWidth,
    required this.screenHeight,
    this.emoji = '🐰',
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    final charSize = screenWidth * 0.52;

    return SizedBox(
      height: screenHeight * 0.54,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
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
                  emoji,
                  style: TextStyle(fontSize: charSize * 0.55),
                ),
              ),
            )
                .animate(
                  onPlay: floating
                      ? (controller) => controller.repeat(reverse: true)
                      : null,
                )
                .fadeIn(duration: 600.ms)
                .slideY(
                  begin: floating ? -0.04 : -0.08,
                  end: floating ? 0.04 : 0.0,
                  duration: floating ? 2.seconds : 600.ms,
                  curve: floating ? Curves.easeInOut : Curves.easeOutBack,
                ),
          ),
        ],
      ),
    );
  }
}

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
            child: Column(
              children: [
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
                        final year = _minYear + i;
                        final isSelected = year == _selectedYear;
                        return Center(
                          child: Text(
                            '$year',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.35),
                              fontSize: isSelected ? 42 : 28,
                              fontWeight:
                                  isSelected ? FontWeight.w900 : FontWeight.w400,
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
          Padding(
            padding: EdgeInsets.fromLTRB(24, 22, 24, bottomPad + 18),
            child: Column(
              children: [
                const Text(
                  'This stays on-device for now. We will connect the new backend in the next step.',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Name Input Page (Step 2)
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
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
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

    return Stack(
      children: [
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
        SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: size.height * 0.32,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Positioned(
                                top: 0,
                                child: Container(
                                  width: 4,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 15,
                                child: Container(
                                  width: size.width * 0.40,
                                  height: size.width * 0.40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 0,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '🦊',
                                      style: TextStyle(fontSize: size.width * 0.40 * 0.55),
                                    ),
                                  ),
                                )
                                    .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(reverse: true),
                                    )
                                    .fadeIn(duration: 600.ms)
                                    .slideY(
                                      begin: -0.04,
                                      end: 0.04,
                                      duration: 2.seconds,
                                      curve: Curves.easeInOut,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Let's get to know you",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
                              const SizedBox(height: 4),
                              Text(
                                "What should we call you?",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
                              const SizedBox(height: 8),
                              const Text(
                                "Your name helps personalize your ScrollX experience.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    _BottomSheetWithNameInput(
                      currentPage: widget.currentPage,
                      controller: _nameCtrl,
                      focusNode: _focusNode,
                      isFocused: _isFocused,
                      onContinue: () {
                        final name = _nameCtrl.text.trim();
                        if (name.isNotEmpty) {
                          widget.onContinue(name);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your name to continue'),
                              backgroundColor: _kDark,
                            ),
                          );
                        }
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.15, end: 0, duration: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomSheetWithNameInput extends StatelessWidget {
  final int currentPage;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final VoidCallback onContinue;

  const _BottomSheetWithNameInput({
    required this.currentPage,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onContinue,
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isFocused ? _kYellowMid : const Color(0xFFE8E8E8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFocused
                      ? const Color(0xFFE8D500).withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isFocused ? 8 : 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
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
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onContinue,
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
                  'CONTINUE',
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
