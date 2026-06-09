import 'package:cloud_firestore/cloud_firestore.dart';

/// A single quiz question, stored at `quiz_questions/{id}` in Firestore.
/// Matches the seed schema in docs/quiz-seed.json:
/// `question: String, choices: List<String>, correctIndex: int, funFact: String`
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.funFact,
  });

  final String id;
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String funFact;

  factory QuizQuestion.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return QuizQuestion(
      id: doc.id,
      question: (data['question'] as String?) ?? '',
      choices:
          (data['choices'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
      funFact: (data['funFact'] as String?) ?? '',
    );
  }
}
