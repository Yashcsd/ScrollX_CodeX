// lib/games/trivia_quiz/trivia_quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_theme.dart';
import '../../services/trivia_api_service.dart';
import '../../services/user_provider.dart';
import '../../services/haptics_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/anti_gravity.dart';
import '../../widgets/bounce_press.dart';

class TriviaQuizScreen extends StatefulWidget {
  const TriviaQuizScreen({super.key});
  @override
  State<TriviaQuizScreen> createState() => _TriviaQuizScreenState();
}

class _TriviaQuizScreenState extends State<TriviaQuizScreen>
    with SingleTickerProviderStateMixin {
  List<TriviaQuestion> _questions = [];
  int _idx = 0, _score = 0, _lives = 3, _timeLeft = 20;
  String? _selected;
  bool _answered = false, _loading = true, _gameOver = false, _won = false;
  String? _errorMsg;
  Timer? _timer;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _fetchQuestions();
    AudioService.playMusic('quiz');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    AudioService.stopMusic();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    setState(() { _loading = true; _errorMsg = null; });
    try {
      final qs = await TriviaApiService.fetchQuestions(amount: 10, difficulty: 'easy');
      setState(() { _questions = qs; _loading = false; });
      _startTimer();
    } catch (e) { setState(() { _errorMsg = e.toString(); _loading = false; }); }
  }

  void _startTimer() {
    _timer?.cancel(); _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) { t.cancel(); _timeUp(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 5) {
        HapticsService.timerTick(_timeLeft);
        if (_timeLeft > 0) {
          if (_timeLeft <= 3) {
            AudioService.playSfx('tension_tick');
          } else {
            AudioService.playSfx('tick');
          }
        }
      }
    });
  }

  void _timeUp() {
    if (_answered) return;
    HapticsService.failureSequence();
    setState(() { _answered = true; _lives--; });
    _shakeCtrl.forward(from: 0);
    if (_lives == 0) { _endGame(false); return; }
    Future.delayed(const Duration(seconds: 2), _nextQ);
  }

  void _pick(String ans) {
    if (_answered) return;
    _timer?.cancel();
    final correct = _questions[_idx].correctAnswer;
    final isCorrect = ans == correct;
    if (isCorrect) {
      HapticsService.medium();
      AudioService.playSfx('coin');
    } else {
      HapticsService.failureSequence();
      AudioService.playSfx('fail');
    }
    setState(() {
      _selected = ans; _answered = true;
      if (isCorrect) _score += _timeLeft * 10 + 50;
      else { _lives--; _shakeCtrl.forward(from: 0); }
    });
    if (_lives <= 0) Future.delayed(const Duration(milliseconds: 1200), () => _endGame(false));
    else Future.delayed(const Duration(milliseconds: 1400), _nextQ);
  }

  void _nextQ() {
    if (_idx + 1 >= _questions.length) { _endGame(true); return; }
    setState(() { _idx++; _selected = null; _answered = false; });
    _startTimer();
  }

  void _endGame(bool won) {
    _timer?.cancel();
    setState(() { _gameOver = true; _won = won; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'trivia_quiz', gameName: 'Trivia Quiz',
      score: _score, timeTakenSeconds: (_idx + 1) * 20, won: won,
    );
  }

  void _restart() {
    setState(() { _idx=0; _score=0; _lives=3; _selected=null; _answered=false; _gameOver=false; _won=false; });
    _fetchQuestions();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(gradient: kGameGradient),
      child: _loading ? _buildLoading()
          : _errorMsg != null ? _buildError()
          : Stack(children: [
              SafeArea(bottom: false, child: _buildGame()),
              if (_gameOver) GameResultOverlay(
                score: _score,
                xpEarned: _won ? 120 : 20,
                won: _won,
                onContinue: () => Navigator.pop(context),
                onRetry: _restart,
              ),
            ]),
    ),
  );

  Widget _buildLoading() => const Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircularProgressIndicator(color: kYellow, strokeWidth: 3),
      SizedBox(height: 16),
      Text('Fetching questions…', style: TextStyle(color: kTextSec, fontSize: 14)),
      SizedBox(height: 4),
      Text('opentdb.com', style: TextStyle(color: kTextMuted, fontSize: 11)),
    ],
  ));

  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('⚠️', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 16),
      const Text('Could not load questions', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(_errorMsg!, style: const TextStyle(color: kTextMuted, fontSize: 11), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      YellowButton(label: 'Try Again', onTap: _fetchQuestions),
    ]),
  ));

  Widget _buildGame() {
    final q = _questions[_idx];
    return Column(children: [
      GameHeader(title: '🎯 Trivia Quiz', actions: [
        LivesRow(lives: _lives),
        const SizedBox(width: 10),
        ScoreBadge(score: _score),
      ]),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GameProgressBar(value: (_idx + 1) / _questions.length),
      ),
      const SizedBox(height: 16),
      // Timer ring
      SizedBox(width: 72, height: 72,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(
            value: _timeLeft / 20.0, strokeWidth: 6,
            backgroundColor: kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeLeft > 10 ? kTeal : _timeLeft > 5 ? kYellow : kCoral),
          ),
          Text('$_timeLeft', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: _timeLeft > 10 ? kTeal : _timeLeft > 5 ? kYellow : kCoral)),
        ]),
      ),
      const SizedBox(height: 16),
      // Question card
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AntiGravityWidget(
          child: GameCard(child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: kYellow.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(q.category, style: const TextStyle(color: kDark, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(_shakeAnim.value * 10 * (_idx % 2 == 0 ? 1 : -1), 0),
                child: child),
              child: Text(q.question, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kDark, height: 1.4)),
            ),
          ])),
        ),
      ),
      const Spacer(),
      // Answers
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(children: q.allAnswers.map((a) {
          Color bg = Colors.white, border = kBorder, text = kDark;
          if (_answered) {
            if (a == q.correctAnswer) { bg = kTeal.withOpacity(0.12); border = kTeal; text = kTeal; }
            else if (a == _selected) { bg = kCoral.withOpacity(0.1); border = kCoral; text = kCoral; }
          }
          return BouncePressWidget(
            onTap: () => _pick(a),
            enableHaptics: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Text(a, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList()),
      ),
    ]);
  }
}
