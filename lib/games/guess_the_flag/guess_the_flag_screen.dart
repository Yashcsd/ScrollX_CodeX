// lib/games/guess_the_flag/guess_the_flag_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/game_theme.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class GuessTheFlagScreen extends StatefulWidget {
  const GuessTheFlagScreen({super.key});
  @override
  State<GuessTheFlagScreen> createState() => _GuessTheFlagScreenState();
}

class _GuessTheFlagScreenState extends State<GuessTheFlagScreen> {
  static const List<Map<String,String>> _flags = [
    {'flag':'🇮🇳','name':'India'},    {'flag':'🇺🇸','name':'USA'},
    {'flag':'🇬🇧','name':'UK'},       {'flag':'🇯🇵','name':'Japan'},
    {'flag':'🇨🇳','name':'China'},    {'flag':'🇧🇷','name':'Brazil'},
    {'flag':'🇩🇪','name':'Germany'},  {'flag':'🇫🇷','name':'France'},
    {'flag':'🇦🇺','name':'Australia'},{'flag':'🇨🇦','name':'Canada'},
    {'flag':'🇷🇺','name':'Russia'},   {'flag':'🇮🇹','name':'Italy'},
    {'flag':'🇲🇽','name':'Mexico'},   {'flag':'🇰🇷','name':'South Korea'},
    {'flag':'🇿🇦','name':'South Africa'},{'flag':'🇳🇬','name':'Nigeria'},
    {'flag':'🇦🇷','name':'Argentina'},{'flag':'🇸🇦','name':'Saudi Arabia'},
    {'flag':'🇪🇬','name':'Egypt'},    {'flag':'🇹🇷','name':'Turkey'},
  ];

  final _rng = Random();
  late Map<String,String> _current;
  late List<String> _options;
  int _score = 0, _round = 0;
  bool _showResult = false;
  String? _selected;
  bool _answered = false;

  @override
  void initState() { super.initState(); _nextQ(); }

  void _nextQ() {
    _current = _flags[_rng.nextInt(_flags.length)];
    final opts = {_current['name']!};
    while (opts.length < 4) {
      opts.add(_flags[_rng.nextInt(_flags.length)]['name']!);
    }
    _options = opts.toList()..shuffle();
    _selected = null;
    _answered = false;
  }

  void _pick(String name) {
    if (_answered) return;
    final ok = name == _current['name'];
    setState(() { _selected = name; _answered = true; if (ok) _score += 50; });
    Future.delayed(const Duration(milliseconds: 1200), () {
      _round++;
      if (_round >= 10) _endGame();
      else setState(() => _nextQ());
    });
  }

  void _endGame() {
    setState(() => _showResult = true);
    context.read<UserProvider>().recordGameResult(
      gameId: 'guess_the_flag', gameName: 'Guess the Flag',
      score: _score, timeTakenSeconds: 0, won: _score >= 300,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          GameHeader(
            title: 'Guess the Flag',
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kYellow.withOpacity(0.3)),
                ),
                child: Text('${_round+1}/10', style: const TextStyle(
                  color: kDark, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ScoreBadge(score: _score),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GameProgressBar(value: (_round+1)/10),
          ),
          const Spacer(),
          const Text('Which country is this flag?', style: TextStyle(color: kDark, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Text(_current['flag']!, style: const TextStyle(fontSize: 100)),
          const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: _options.map((name) {
              Color bg = Colors.white, border = kTextMuted.withOpacity(0.3);
              Color text = kDark;
              if (_answered) {
                if (name == _current['name']) { bg = Colors.green.withOpacity(0.2); border = Colors.green; text = Colors.green; }
                else if (name == _selected)   { bg = Colors.red.withOpacity(0.2); border = Colors.red; text = Colors.red; }
              }
              return GestureDetector(
                onTap: () => _pick(name),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border), boxShadow: [kGameShadow]),
                  child: Row(children: [
                    Text(name, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w600)),
                  ])));
            }).toList())),
          const SizedBox(height: 24),
        ]),
        if (_showResult) GameResultOverlay(
          score: _score, xpEarned: _score >= 300 ? 120 : 20, won: _score >= 300,
          onContinue: () => Navigator.pop(context),
          onRetry: () => setState(() { _score=0; _round=0; _showResult=false; _nextQ(); }),
        ),
      ])),
    ),
  );
}
