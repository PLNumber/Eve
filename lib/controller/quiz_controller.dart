// lib/controller/quiz_controller.dart
import 'package:flutter/material.dart';
import 'package:eve/model/quiz.dart';
import '../main.dart';
import '../services/quiz_service.dart';

/// viewModel 없이 Provider를 안 쓰고 직접 컨트롤러로 구성하고 싶을 경우 사용 가능
class QuizController {
  final QuizService _service;

  QuizController(this._service);

  /// 문제를 생성하는 함수
  Future<QuizQuestion?> generateQuiz() async {
    return await _service.getQuestion();
  }

  Future<AnswerResult> checkAnswer(
    QuizQuestion question,
    String userInput, {
    required bool hasAlreadySubmitted,
  }) async {
    return await _service.compareAnswer(
      question,
      userInput,
      hasAlreadySubmitted: hasAlreadySubmitted,
    );
  }

  /// 다음 문제 요청 (generateQuiz와 동일하지만 명시적으로 구분)
  Future<QuizQuestion?> nextQuestion() async {
    return await _service.getQuestion();
  }

  /// 퀴즈 종료 시 메인 페이지로 이동
  void endQuiz(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }
}

class AnswerResult {
  final bool isCorrect;
  final String? feedback;

  AnswerResult({required this.isCorrect, this.feedback});
}
