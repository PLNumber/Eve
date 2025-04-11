// lib/view_model/quiz_view_model.dart

import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

class QuizViewModel extends ChangeNotifier {
  final QuizService _quizService;

  bool isLoading = false;
  String errorMessage = "";

  QuizViewModel(this._quizService);

  Future<void> generateQuiz(String promptTemplate) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      await _quizService.generateQuizForRandomVocab(promptTemplate);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
