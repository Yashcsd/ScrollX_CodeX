// lib/services/trivia_api_service.dart
//
// Uses the FREE Open Trivia Database API — no key required.
// Endpoint: https://opentdb.com/api.php
// Docs:     https://opentdb.com/api_config.php
//
import 'dart:convert';
import 'package:http/http.dart' as http;

class TriviaQuestion {
  final String       question;
  final String       correctAnswer;
  final List<String> allAnswers;   // shuffled (correct + 3 wrong)
  final String       difficulty;
  final String       category;

  TriviaQuestion({
    required this.question,
    required this.correctAnswer,
    required this.allAnswers,
    required this.difficulty,
    required this.category,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    final correct   = _decode(json['correct_answer']  ?? '');
    final incorrect = (json['incorrect_answers'] as List)
        .map((e) => _decode(e.toString()))
        .toList();
    final all = [...incorrect, correct]..shuffle();
    return TriviaQuestion(
      question:      _decode(json['question']  ?? ''),
      correctAnswer: correct,
      allAnswers:    all,
      difficulty:    json['difficulty'] ?? 'easy',
      category:      _decode(json['category'] ?? ''),
    );
  }

  // HTML entity decoder
  static String _decode(String s) => s
      .replaceAll('&amp;',  '&')
      .replaceAll('&lt;',   '<')
      .replaceAll('&gt;',   '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&eacute;','é')
      .replaceAll('&ndash;','–')
      .replaceAll('&mdash;','—');
}

class TriviaApiService {
  // ── Fetch questions from opentdb.com ──────────────────────────────────────
  // amount    : how many questions (max 50)
  // category  : null = any  |  9 = General  |  18 = Computers  |  21 = Sports
  // difficulty: 'easy' | 'medium' | 'hard'
  static Future<List<TriviaQuestion>> fetchQuestions({
    int    amount    = 10,
    int?   category,
    String difficulty = 'easy',
  }) async {
    final params = {
      'amount':     amount.toString(),
      'type':       'multiple',
      'difficulty': difficulty,
      if (category != null) 'category': category.toString(),
    };

    final uri = Uri.parse('https://opentdb.com/api.php')
        .replace(queryParameters: params);

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['response_code'] == 0) {
          return (body['results'] as List)
              .map((q) => TriviaQuestion.fromJson(q as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}

    // Offline fallback
    return _fallback();
  }

  // ── Offline fallback questions ─────────────────────────────────────────────
  static List<TriviaQuestion> _fallback() => [
    TriviaQuestion(
      question: 'Which planet is known as the Red Planet?',
      correctAnswer: 'Mars',
      allAnswers: ['Venus', 'Jupiter', 'Mars', 'Saturn'],
      difficulty: 'easy', category: 'Science',
    ),
    TriviaQuestion(
      question: 'What is the capital of Australia?',
      correctAnswer: 'Canberra',
      allAnswers: ['Sydney', 'Melbourne', 'Perth', 'Canberra'],
      difficulty: 'easy', category: 'Geography',
    ),
    TriviaQuestion(
      question: 'Who painted the Mona Lisa?',
      correctAnswer: 'Leonardo da Vinci',
      allAnswers: ['Michelangelo', 'Raphael', 'Leonardo da Vinci', 'Picasso'],
      difficulty: 'easy', category: 'Art',
    ),
    TriviaQuestion(
      question: 'What is the fastest land animal?',
      correctAnswer: 'Cheetah',
      allAnswers: ['Lion', 'Horse', 'Cheetah', 'Leopard'],
      difficulty: 'easy', category: 'Nature',
    ),
    TriviaQuestion(
      question: 'In what year was the first iPhone released?',
      correctAnswer: '2007',
      allAnswers: ['2005', '2006', '2007', '2008'],
      difficulty: 'easy', category: 'Technology',
    ),
    TriviaQuestion(
      question: 'How many sides does a hexagon have?',
      correctAnswer: '6',
      allAnswers: ['5', '6', '7', '8'],
      difficulty: 'easy', category: 'Mathematics',
    ),
    TriviaQuestion(
      question: 'Which gas do plants absorb from the atmosphere?',
      correctAnswer: 'Carbon dioxide',
      allAnswers: ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Hydrogen'],
      difficulty: 'easy', category: 'Science',
    ),
    TriviaQuestion(
      question: 'What is the largest ocean on Earth?',
      correctAnswer: 'Pacific Ocean',
      allAnswers: ['Atlantic Ocean', 'Indian Ocean', 'Pacific Ocean', 'Arctic Ocean'],
      difficulty: 'easy', category: 'Geography',
    ),
    TriviaQuestion(
      question: 'Who wrote "Romeo and Juliet"?',
      correctAnswer: 'William Shakespeare',
      allAnswers: ['Charles Dickens', 'Mark Twain', 'William Shakespeare', 'Jane Austen'],
      difficulty: 'easy', category: 'Literature',
    ),
    TriviaQuestion(
      question: 'What is 15 × 15?',
      correctAnswer: '225',
      allAnswers: ['200', '215', '225', '230'],
      difficulty: 'easy', category: 'Mathematics',
    ),
  ];
}
