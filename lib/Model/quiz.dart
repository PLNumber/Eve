//firebase에서 가져올 예정
//lib/Model/quiz.dart

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


  //문제 데이터베이스 가져오는 함수
  Map<String, dynamic> toMap() {
    return {
      "question": question, // 문제
      "answer": answer,   // 어휘
      "hint": hint,   // 힌트
      "distractors": distractors, // 예시 오답
      "feedback": feedback,   //피드백
      "difficulty": difficulty, //난이도
    };
  }
}