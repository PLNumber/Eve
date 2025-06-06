//firebase에서 가져올 예정
//lib/model/quiz.dart

class QuizQuestion {
  final String question;
  final String answer;
  final String hint;
  final List<String> distractors;
  final List<String> feedbacks; // ✅ 배열로 수정
  final int difficulty;
  final bool isReview;

  QuizQuestion({
    required this.question,
    required this.answer,
    required this.hint,
    required this.distractors,
    required this.feedbacks,
    required this.difficulty,
    this.isReview = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "question": question,
      "answer": answer,
      "hint": hint,
      "distractors": distractors,
      "feedbacks": feedbacks, // ✅ key도 복수형
      "difficulty": difficulty,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      answer: json['answer'],
      hint: json['hint'],
      distractors: List<String>.from(json['distractors']),
      feedbacks: List<String>.from(json['feedbacks']),
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'hint': hint,
      'distractors': distractors,
      'feedbacks': feedbacks,
      'difficulty': difficulty,
    };
  }
}
