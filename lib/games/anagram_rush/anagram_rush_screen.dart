// lib/games/anagram_rush/anagram_rush_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bounce_press.dart';

class AnagramRushScreen extends StatefulWidget {
  const AnagramRushScreen({super.key});
  @override
  State<AnagramRushScreen> createState() => _AnagramRushScreenState();
}

class _AnagramRushScreenState extends State<AnagramRushScreen> {
  static const List<List<String>> _groups = [
    ['RACE', 'CARE', 'ACRE'],
    ['STOP', 'TOPS', 'POTS', 'SPOT'],
    ['LEMON', 'MELON'],
    ['HEART', 'EARTH', 'HATER'],
    ['NIGHT', 'THING'],
    ['SMILE', 'LIMES', 'MILES'],
    ['NOTES', 'STONE', 'TONES', 'SNORE'],
    ['DUSTY', 'STUDY'],
    ['BELOW', 'ELBOW'],
    ['TASTE', 'STATE'],
  ];

  static final _tint = kGameTints['anagram_rush']!;

  final _rng = Random();
  late List<String> _current;
  late String _show;
  final _ctrl = TextEditingController();
  int _score = 0, _round = 0, _timeLeft = 45;
  Timer? _timer;
  bool _showResult = false;
  String? _flash;
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _load();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _load() {
    _current = _groups[_rng.nextInt(_groups.length)];
    final chars = _current[0].split('')..shuffle();
    _show = chars.join();
    _ctrl.clear();
    _flash = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 0) {
        _endGame();
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _check() {
    final typed = _ctrl.text.trim().toUpperCase();
    if (_current.contains(typed) && typed != _show) {
      setState(() {
        _flash = '✓ +${50 + _round * 5} pts';
        _score += 50 + _round * 5;
        _round++;
      });
      Future.delayed(
        const Duration(milliseconds: 600),
        () => setState(() => _load()),
      );
    } else {
      setState(() => _flash = '✗ Not an anagram of these letters');
      Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(() => _flash = null),
      );
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'anagram_rush',
      gameName: 'Anagram Rush',
      score: _score,
      timeTakenSeconds: 45,
      won: _score >= 200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _tint.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      // ── Header ─────────────────────────────────────────
                      GameHeader(
                        title: '🔤 Anagram Rush',
                        actions: [
                          TimerBadge(seconds: _timeLeft, total: 45),
                          const SizedBox(width: 8),
                          ScoreBadge(score: _score),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GameProgressBar(
                          value: _timeLeft / 45,
                          color: _timeLeft > 20 ? kTeal : kCoral,
                        ),
                      ),

                      const Spacer(),

                      // ── Prompt ─────────────────────────────────────────
                      const Text(
                        'Rearrange to make a valid word!',
                        style: TextStyle(
                          color: kTextSec,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Scrambled letters ──────────────────────────────
                      GameCard(
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 32),
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _show,
                                key: ValueKey(_show),
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: _tint.shadow,
                                  letterSpacing: 8,
                                ),
                              ),
                            ),
                            if (_flash != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _flash!,
                                style: TextStyle(
                                  color: _flash!.contains('✓')
                                      ? kTeal
                                      : kCoral,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── Input + submit ─────────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isFocused
                                        ? _tint.shadow
                                        : kBorder,
                                    width: 1.5,
                                  ),
                                  boxShadow: const [kHardShadow],
                                ),
                                child: TextField(
                                  controller: _ctrl,
                                  focusNode: _focusNode,
                                  autofocus: true,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: TextStyle(
                                    color: kDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                  ),
                                  onSubmitted: (_) => _check(),
                                  decoration: const InputDecoration(
                                    hintText: 'Type word…',
                                    hintStyle: TextStyle(
                                      color: kTextMuted,
                                      letterSpacing: 1,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            BouncePressWidget(
                              onTap: _check,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: kYellow,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: kYellowDark,
                                      blurRadius: 0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: kDark,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Skip ───────────────────────────────────────────
                      TextButton(
                        onPressed: () => setState(() => _load()),
                        child: Text(
                          'Skip this word',
                          style: TextStyle(
                            color: kTextMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_showResult)
            GameResultOverlay(
              score: _score,
              xpEarned: _score >= 200 ? 120 : 20,
              won: _score >= 200,
              onContinue: () => Navigator.pop(context),
              onRetry: () => setState(() {
                _score = 0;
                _round = 0;
                _timeLeft = 45;
                _showResult = false;
                _load();
                _startTimer();
              }),
            ),
        ],
      ),
    );
  }
}
