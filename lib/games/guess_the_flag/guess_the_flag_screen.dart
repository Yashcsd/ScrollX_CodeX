// lib/games/guess_the_flag/guess_the_flag_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1A0A2E), Color(0xFF2D1B69)])),
      child: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
            child: Row(children: [
              GestureDetector(onTap: ()=>Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18))),
              const SizedBox(width: 12),
              const Text('Guess the Flag', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('${_round+1}/10  $_score pts', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            ])),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: (_round+1)/10,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent), minHeight: 4)),
          const Spacer(),
          Text('Which country is this flag?', style: const TextStyle(color: AppTheme.textSec, fontSize: 15)),
          const SizedBox(height: 24),
          Text(_current['flag']!, style: const TextStyle(fontSize: 100)),
          const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: _options.map((name) {
              Color bg = Colors.white10, border = Colors.white12;
              Color text = Colors.white;
              if (_answered) {
                if (name == _current['name']) { bg = AppTheme.teal.withOpacity(0.25); border = AppTheme.teal; text = AppTheme.teal; }
                else if (name == _selected)   { bg = AppTheme.coral.withOpacity(0.2); border = AppTheme.coral; text = AppTheme.coral; }
              }
              return GestureDetector(
                onTap: () => _pick(name),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border)),
                  child: Row(children: [
                    Text(name, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w500)),
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
