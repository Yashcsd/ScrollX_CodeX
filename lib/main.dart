// lib/main.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    statusBarColor: Colors.transparent,
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
          '/main': (_) => const MainShell(),
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
  double _navPosition = 0;
  late final PageController _pageCtrl;

  static const _screens = [
    FeedScreen(),
    GamesScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _pageCtrl.addListener(_syncNavPosition);
  }

  void _syncNavPosition() {
    if (!_pageCtrl.hasClients) return;
    final page = _pageCtrl.page;
    if (page == null || !mounted) return;
    setState(() {
      _navPosition = page.clamp(0.0, (_screens.length - 1).toDouble());
    });
  }

  @override
  void dispose() {
    _pageCtrl
      ..removeListener(_syncNavPosition)
      ..dispose();
    super.dispose();
  }

  void _onTap(int i) {
    setState(() => _idx = i);
    if (!_pageCtrl.hasClients) {
      setState(() => _navPosition = i.toDouble());
      return;
    }
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.bg,
        extendBody: true,
        body: PageView(
          controller: _pageCtrl,
          onPageChanged: (i) {
            setState(() {
              _idx = i;
              _navPosition = i.toDouble();
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: _ScrollXNav(
          current: _idx,
          position: _navPosition,
          onTap: _onTap,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav
// ─────────────────────────────────────────────────────────────────────────────
class _ScrollXNav extends StatefulWidget {
  final int current;
  final double position;
  final ValueChanged<int> onTap;
  const _ScrollXNav({
    required this.current,
    required this.position,
    required this.onTap,
  });

  @override
  State<_ScrollXNav> createState() => _ScrollXNavState();
}

class _ScrollXNavState extends State<_ScrollXNav>
    with TickerProviderStateMixin {
  // Navbar base is always visually larger than the active button.
  // Button = 56h, Navbar base = 74h → ratio ~1.32 (cradles the button).
  // The dock is shifted down 6px so icons sit visually centred in the white base.
  static const double _dockWidth    = 300;
  static const double _dockHeight   = 80;
  static const double _buttonWidth  = 70;
  static const double _buttonHeight = 56;
  static const double _trackPadding = 16;
  // Extra downward offset so the white pill sits lower, balancing the button visually
  static const double _dockVerticalShift = 3.5;
  static const Color _activeIcon = Color(0xFF000000);
  static const Color _inactiveIcon = Color(0xFF666666);

  static const _items = [
    _NavItem(
      label: 'Feed',
      tooltip: 'Trending',
      asset: 'assets/icons/feed.svg',
      width: 30,
      height: 30,
    ),
    _NavItem(
      label: 'Games',
      tooltip: 'Categories',
      asset: 'assets/icons/explore.svg',
      width: 35,
      height: 20,
    ),
    _NavItem(
      label: 'Leaderboard',
      tooltip: 'Top Players',
      asset: 'assets/icons/achievement.svg',
      width: 24,
      height: 24,
    ),
    _NavItem(
      label: 'Profile',
      tooltip: 'Achievements',
      asset: 'assets/icons/user.svg',
      width: 24,
      height: 24,
    ),
  ];

  late final AnimationController _pressCtrl;
  late final AnimationController _dockCtrl;
  late final AnimationController _switchCtrl;
  late final AnimationController _tooltipCtrl;

  int? _tooltipIndex;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _dockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _switchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tooltipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 120),
    );
  }

  @override
  void didUpdateWidget(covariant _ScrollXNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) {
      HapticFeedback.selectionClick();
      _switchCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _dockCtrl.dispose();
    _switchCtrl.dispose();
    _tooltipCtrl.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    _hideTooltip();
    HapticFeedback.lightImpact();
    _pressCtrl.forward(from: 0);
    _dockCtrl.forward(from: 0);
    widget.onTap(index);
  }

  void _showTooltip(int index) {
    HapticFeedback.lightImpact();
    setState(() => _tooltipIndex = index);
    _tooltipCtrl.forward(from: 0);
  }

  void _hideTooltip() {
    if (_tooltipIndex == null) return;
    _tooltipCtrl.reverse().whenComplete(() {
      if (mounted) setState(() => _tooltipIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = MediaQuery.of(context).size.width - 24;
    final width = math.min(_dockWidth, math.max(280.0, available));
    final slotWidth = (width - (_trackPadding * 2)) / _items.length;
    final rawPosition =
        widget.position.isFinite ? widget.position : widget.current.toDouble();
    final position = rawPosition.clamp(0.0, (_items.length - 1).toDouble());
    final indicatorLeft =
        (_trackPadding + position * slotWidth + (slotWidth - _buttonWidth) / 2)
            .clamp(_trackPadding, width - _trackPadding - _buttonWidth);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 56),
      child: SizedBox(
        height: _dockHeight + 10,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pressCtrl,
            _dockCtrl,
            _switchCtrl,
            _tooltipCtrl,
          ]),
          builder: (context, _) {
            final dockLift = _dockLift(_dockCtrl.value);
            final stretch = _switchStretch(_switchCtrl.value);
            final activeIconScale = _activeIconScale(_switchCtrl.value);
            final pressX = _pressScaleX(_pressCtrl.value);
            final pressY = _pressScaleY(_pressCtrl.value);
            final pressOffset = _pressOffset(_pressCtrl.value);
            final shadow = _shadowStrength(_pressCtrl.value);

            return Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: width,
                height: _dockHeight + 10,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    _TooltipBubble(
                      visible: _tooltipIndex != null,
                      progress: _tooltipCtrl.value,
                      label: _tooltipIndex == null
                          ? ''
                          : _items[_tooltipIndex!].tooltip,
                      centerX: _tooltipCenter(width, slotWidth),
                      dockWidth: width,
                    ),
                    Transform.translate(
                      offset: Offset(0, dockLift + _ScrollXNavState._dockVerticalShift),
                      child: SizedBox(
                          width: width,
                          height: _dockHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(_dockHeight / 2),
                                    boxShadow: const [
                                      AppTheme.hardShadowStrong,
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: _trackPadding),
                                child: Row(
                                  children: List.generate(_items.length, (i) {
                                    final selected = i == widget.current;
                                    final item = _items[i];
                                    return Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _handleTap(i),
                                        onLongPressStart: (_) =>
                                            _showTooltip(i),
                                        onLongPressEnd: (_) => _hideTooltip(),
                                        child: Center(
                                          child: AnimatedOpacity(
                                            opacity: selected ? 0 : 0.70,
                                            duration: const Duration(
                                                milliseconds: 120),
                                            child: Transform.scale(
                                              scale: 0.95,
                                              child: _NavSvgIcon(
                                                item: item,
                                                color: _inactiveIcon,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              Positioned(
                                left: indicatorLeft.toDouble(),
                                // Centre the button vertically, then shift it up by
                                // _dockVerticalShift so it stays visually centred
                                // even though the white base moved down.
                                top: (_dockHeight - _buttonHeight) / 2 -
                                    _ScrollXNavState._dockVerticalShift,
                                child: Transform.translate(
                                  offset: Offset(0, pressOffset),
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.diagonal3Values(
                                      stretch * pressX,
                                      pressY,
                                      1,
                                    ),
                                    child: _ActiveNavButton(
                                      item: _items[widget.current],
                                      iconScale: activeIconScale,
                                      shadowStrength: shadow,
                                      onTap: () => _handleTap(widget.current),
                                      onLongPressStart: () =>
                                          _showTooltip(widget.current),
                                      onLongPressEnd: _hideTooltip,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _tooltipCenter(double width, double slotWidth) {
    final index = _tooltipIndex ?? widget.current;
    return _trackPadding + (index * slotWidth) + (slotWidth / 2);
  }

  double _dockLift(double t) {
    if (t < 0.5) return -2 * Curves.easeOutCubic.transform(t / 0.5);
    return -2 * (1 - Curves.easeOutCubic.transform((t - 0.5) / 0.5));
  }

  double _switchStretch(double t) => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.12)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 38,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.12, end: 0.96)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 32,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.96, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 30,
        ),
      ]).transform(t);

  double _activeIconScale(double t) => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.08)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 45,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.08, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 55,
        ),
      ]).transform(t);

  double _pressScaleX(double t) => TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.98), weight: 32),
        TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.02), weight: 24),
        TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.03), weight: 22),
        TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 22),
      ]).transform(t);

  double _pressScaleY(double t) => TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.98), weight: 32),
        TweenSequenceItem(tween: Tween(begin: 0.98, end: 0.95), weight: 24),
        TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.03), weight: 22),
        TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 22),
      ]).transform(t);

  double _pressOffset(double t) => TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 4.0), weight: 42),
        TweenSequenceItem(tween: Tween(begin: 4.0, end: 4.0), weight: 18),
        TweenSequenceItem(tween: Tween(begin: 4.0, end: -0.5), weight: 20),
        TweenSequenceItem(tween: Tween(begin: -0.5, end: 0.0), weight: 20),
      ]).transform(t);

  double _shadowStrength(double t) => TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.60), weight: 32),
        TweenSequenceItem(tween: Tween(begin: 0.60, end: 0.55), weight: 24),
        TweenSequenceItem(tween: Tween(begin: 0.55, end: 1.05), weight: 22),
        TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 22),
      ]).transform(t);
}

class _ActiveNavButton extends StatelessWidget {
  final _NavItem item;
  final double iconScale;
  final double shadowStrength;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const _ActiveNavButton({
    required this.item,
    required this.iconScale,
    required this.shadowStrength,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Container(
        width: _ScrollXNavState._buttonWidth,
        height: _ScrollXNavState._buttonHeight,
        decoration: BoxDecoration(
          color: AppTheme.consoleYellow,
          borderRadius: BorderRadius.circular(28),
          // No outer border ring — clean yellow pill
          boxShadow: [
            // Reduced Y offset (3px instead of 5px) for yellow button only
            BoxShadow(
              color: Color.lerp(
                AppTheme.yellowDark,
                const Color(0xFF8A7000),
                (1.0 - shadowStrength).clamp(0.0, 1.0),
              )!,
              blurRadius: 0,
              offset: Offset(0, (5 * shadowStrength).clamp(1.0, 3.0)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Transform.scale(
              scale: iconScale,
              child: _NavSvgIcon(
                item: item,
                color: _ScrollXNavState._activeIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  final bool visible;
  final double progress;
  final String label;
  final double centerX;
  final double dockWidth;

  const _TooltipBubble({
    required this.visible,
    required this.progress,
    required this.label,
    required this.centerX,
    required this.dockWidth,
  });

  @override
  Widget build(BuildContext context) {
    const bubbleWidth = 112.0;
    final left =
        (centerX - bubbleWidth / 2).clamp(0.0, dockWidth - bubbleWidth);
    final curved = Curves.easeOutCubic.transform(progress);

    return Positioned(
      left: left,
      bottom: 82 + (1 - curved) * -8,
      child: IgnorePointer(
        ignoring: true,
        child: Opacity(
          opacity: visible ? curved : 0,
          child: Transform.scale(
            scale: 0.96 + curved * 0.04,
            child: Container(
              width: bubbleWidth,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [AppTheme.hardShadowSmall],
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSvgIcon extends StatelessWidget {
  final _NavItem item;
  final Color color;
  const _NavSvgIcon({required this.item, required this.color});

  @override
  Widget build(BuildContext context) => Semantics(
        label: item.label,
        child: SvgPicture.asset(
          item.asset,
          width: item.width,
          height: item.height,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
}

class _NavItem {
  final String label;
  final String tooltip;
  final String asset;
  final double width;
  final double height;

  const _NavItem({
    required this.label,
    required this.tooltip,
    required this.asset,
    required this.width,
    required this.height,
  });
}
