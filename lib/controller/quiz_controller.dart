// lib/controller/quiz_controller.dart


import 'package:eve/model/quiz.dart';
import '../services/quiz_service.dart';

/// viewModel 없이 Provider를 안 쓰고 직접 컨트롤러로 구성하고 싶을 경우 사용 가능
class QuizController {
  final QuizService _service;
  QuizController(this._service);

  /// 문제를 생성하는 함수
  Future<QuizQuestion?> generateQuiz() async {
    return await _service.getQuestion();
  }

// TODO : 사용자는 답안을 제출 한 후, requestAnswer 함수를 통해 해당 답안과 일치하는지 판별하는 것을 구현 해야함

// TODO : 사용자가 문제를 푼 후, 다음 문제로 넘어가는(다음 퀴즈를 생성하는) 함수인 nextQuestion 함수를 구현 해야함

// TODO : 사용자가 문제를 푼 후, 종료한 후 지금까지 푼 단어를 요약하는 메인페이지로 이동하는 함수인 endQuiz 함수를 구현 해야함
}
