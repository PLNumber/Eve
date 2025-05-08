// lib/services/quiz_service.dart

import '../repository/quiz_repository.dart';
import 'package:eve/model/quiz.dart';


class QuizService {
  final QuizRepository _repository;

  QuizService(this._repository);

  //퀴즈를 가져오는 함수인 getQuestion 함수를 구현 해야함
  // 퀴즈 요청
  Future<QuizQuestion?> getQuestion() async {
    final vocab = await _repository.selectWord();
    final exists = await _repository.isExist(vocab['어휘']);

    if (!exists) {
      return await _repository.generateQuestion(vocab);
    }

    return await _repository.getSavedQuestion(vocab['어휘']);
  }


/*===================================================*/
  //TODO: checkAnswer 함수를 통해 해당하는 문제의 정답을 확인하는 함수를 구현 해야함

  //TODO: compareAnswer 함수를 통해 정답과 사용자가 제출한 답안을 비교하는 함수를 구현 해야함 (오답 일 경우 레포지토리의 requestFeedBack 함수를 호출?)

  //TODO : 이후에 사용자의 통계를 갱신하는 함수인 updateStat 함수를 구현 해야함
}