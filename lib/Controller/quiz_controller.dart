// lib/controller/quiz_controller.dart

import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

/// ViewModel 없이 Provider를 안 쓰고 직접 컨트롤러로 구성하고 싶을 경우 사용 가능
class QuizController {
  final QuizService _quizService;
  bool isLoading = false;
  String errorMessage = "";

  QuizController(this._quizService);

  Future<void> generateQuiz({
    required String promptTemplate,
    required VoidCallback onSuccess,
    required Function(String) onError,
    required VoidCallback onComplete,
  }) async {
    isLoading = true;
    errorMessage = "";

    try {
      await _quizService.generateQuizForRandomVocab(promptTemplate);
      onSuccess();
    } catch (e) {
      errorMessage = e.toString();
      onError(errorMessage);
    } finally {
      isLoading = false;
      onComplete();
    }
  }
}
