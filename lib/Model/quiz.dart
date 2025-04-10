//firebase에서 가져올 예정

class QuizQuestion {
  final String question;
  final String answer;
  final String hint;
  final List<String> distractors;
  final String feedback;
  final int difficulty;

  QuizQuestion({
    required this.question,
    required this.answer,
    required this.hint,
    required this.distractors,
    required this.feedback,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      "question": question,
      "answer": answer,
      "hint": hint,
      "distractors": distractors,
      "feedback": feedback,
      "difficulty": difficulty,
    };
  }
}