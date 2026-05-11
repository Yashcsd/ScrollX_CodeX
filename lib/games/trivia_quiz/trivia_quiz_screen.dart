// lib/games/trivia_quiz/trivia_quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../services/trivia_api_service.dart';
import '../../services/user_provider.dart';
import '../../widgets/common_widgets.dart';

class TriviaQuizScreen extends StatefulWidget {
  const TriviaQuizScreen({super.key});
  @override
  State<TriviaQuizScreen> createState() => _TriviaQuizScreenState();
}

class _TriviaQuizScreenState extends State<TriviaQuizScreen>
    with SingleTickerProviderStateMixin {

  List<TriviaQuestion> _questions = [];
  int    _idx       = 0;
  int    _score     = 0;
  int    _lives     = 3;
  int    _timeLeft  = 20;
  String? _selected;
  bool   _answered  = false;
  bool   _loading   = true;
  bool   _gameOver  = false;
  bool   _won       = false;
  String? _errorMsg;

  Timer? _timer;
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _shakeCtrl,
            curve: Curves.elasticIn));
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── Fetch from Open Trivia DB ─────────────────────────────────────────────
  Future<void> _fetchQuestions() async {
    setState(() { _loading = true; _errorMsg = null; });
    try {
      final qs = await TriviaApiService.fetchQuestions(
          amount: 10, difficulty: 'easy');
      setState(() { _questions = qs; _loading = false; });
      _startTimer();
    } catch (e) {
      setState(() { _errorMsg = e.toString(); _loading = false; });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) { t.cancel(); _timeUp(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _timeUp() {
    if (_answered) return;
    setState(() { _answered = true; _lives--; });
    _shakeCtrl.forward(from: 0);
    if (_lives == 0) { _endGame(false); return; }
    Future.delayed(const Duration(seconds: 2), _nextQ);
  }

  void _pick(String ans) {
    if (_answered) return;
    _timer?.cancel();
    final correct = _questions[_idx].correctAnswer;
    setState(() {
      _selected = ans;
      _answered = true;
      if (ans == correct) {
        _score += _timeLeft * 10 + 50;
      } else {
        _lives--;
        _shakeCtrl.forward(from: 0);
      }
    });
    if (_lives <= 0) {
      Future.delayed(const Duration(milliseconds: 1200),
          () => _endGame(false));
    } else {
      Future.delayed(const Duration(milliseconds: 1400), _nextQ);
    }
  }

  void _nextQ() {
    if (_idx + 1 >= _questions.length) { _endGame(true); return; }
    setState(() {
      _idx++;
      _selected = null;
      _answered = false;
    });
    _startTimer();
  }

  void _endGame(bool won) {
    _timer?.cancel();
    setState(() { _gameOver = true; _won = won; });
    context.read<UserProvider>().recordGameResult(
      gameId: 'trivia_quiz', gameName: 'Trivia Quiz',
      score: _score, timeTakenSeconds: (_idx + 1) * 20,
      won: won,
    );
  }

  void _restart() {
    setState(() {
      _idx = 0; _score = 0; _lives = 3;
      _selected = null; _answered = false;
      _gameOver = false; _won = false;
    });
    _fetchQuestions();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: AppTheme.triviaGrad),
      child: SafeArea(
        child: _loading
            ? _buildLoading()
            : _errorMsg != null
                ? _buildError()
                : Stack(children: [
                    _buildGame(),
                    if (_gameOver) GameResultOverlay(
                      score: _score,
                      xpEarned: _won
                          ? AppConstants.xpPerPlay + AppConstants.xpPerWin
                          : AppConstants.xpPerPlay,
                      won: _won,
                      onContinue: () => Navigator.pop(context),
                      onRetry:    _restart,
                    ),
                  ]),
      ),
    ),
  );

  Widget _buildLoading() => const Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircularProgressIndicator(color: AppTheme.accent),
      SizedBox(height: 16),
      Text('Fetching questions from internet…',
          style: TextStyle(color: AppTheme.textSec)),
      SizedBox(height: 6),
      Text('opentdb.com', style: TextStyle(
          color: AppTheme.textMuted, fontSize: 11)),
    ],
  ));

  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⚠️', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        const Text('Could not load questions',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 8),
        Text(_errorMsg!,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: _fetchQuestions, child: const Text('Try Again')),
      ],
    ),
  ));

  Widget _buildGame() {
    final q = _questions[_idx];
    return Column(children: [
      _topBar(),
      const SizedBox(height: 8),
      _progressBar(),
      const SizedBox(height: 20),
      _timerRing(),
      const SizedBox(height: 20),
      _questionCard(q),
      const Spacer(),
      _answers(q),
      const SizedBox(height: 24),
    ]);
  }

  Widget _topBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white10,
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
      const SizedBox(width: 12),
      Text('Q ${_idx+1} / ${_questions.length}',
          style: const TextStyle(color: AppTheme.textSec, fontSize: 14)),
      const Spacer(),
      // Hearts
      Row(children: List.generate(3, (i) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(Icons.favorite, size: 20,
            color: i < _lives ? AppTheme.pink : Colors.white12),
      ))),
      const SizedBox(width: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.gold.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
        ),
        child: Text('$_score pts',
            style: const TextStyle(color: AppTheme.gold,
                fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    ]),
  );

  Widget _progressBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: (_idx + 1) / _questions.length,
        backgroundColor: Colors.white10,
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
        minHeight: 4,
      ),
    ),
  );

  Widget _timerRing() {
    final frac = _timeLeft / 20.0;
    final color = _timeLeft > 10
        ? AppTheme.teal
        : _timeLeft > 5 ? AppTheme.gold : AppTheme.coral;
    return SizedBox(width: 72, height: 72,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: frac, strokeWidth: 5,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        Text('$_timeLeft', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _questionCard(TriviaQuestion q) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(q.category,
            style: const TextStyle(color: AppTheme.accentLight, fontSize: 11)),
      ),
      const SizedBox(height: 14),
      AnimatedBuilder(
        animation: _shakeAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(_shakeAnim.value * 10 * (_idx % 2 == 0 ? 1 : -1), 0),
          child: child,
        ),
        child: Text(q.question,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: Colors.white, height: 1.4)),
      ),
    ]),
  );

  Widget _answers(TriviaQuestion q) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: q.allAnswers.map((a) {
        Color bg     = Colors.white10;
        Color border = Colors.white12;
        Color text   = Colors.white;
        if (_answered) {
          if (a == q.correctAnswer) {
            bg = AppTheme.teal.withOpacity(0.25);
            border = AppTheme.teal; text = AppTheme.teal;
          } else if (a == _selected) {
            bg = AppTheme.coral.withOpacity(0.2);
            border = AppTheme.coral; text = AppTheme.coral;
          }
        }
        return GestureDetector(
          onTap: () => _pick(a),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Text(a,
                style: TextStyle(color: text, fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        );
      }).toList(),
    ),
  );
}
