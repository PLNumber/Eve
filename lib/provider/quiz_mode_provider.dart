// ✅ quiz_mode_provider.dart: 퀴즈 생성 방식만 별도로 관리하는 Provider
import 'package:flutter/material.dart';

/// 퀴즈 생성 방식 Enum 정의
enum QuizGenerationMode { gemini, urimalsaem }

/// 퀴즈 생성 방식 Provider
class QuizModeProvider with ChangeNotifier {
  QuizGenerationMode _mode = QuizGenerationMode.gemini;

  QuizGenerationMode get mode => _mode;

  void setMode(QuizGenerationMode newMode) {
    _mode = newMode;
    notifyListeners();
  }

  String get modeLabel {
    switch (_mode) {
      case QuizGenerationMode.gemini:
        return 'Gemini 기반';
      case QuizGenerationMode.urimalsaem:
        return '우리말샘 기반';
    }
  }
}
