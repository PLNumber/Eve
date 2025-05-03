// lib/services/quiz_service.dart

import '../repository/quiz_repository.dart';
import '../services/openai_service.dart';
import '../model/quiz.dart';

class QuizService {
  final QuizRepository _quizRepo;
  final OpenAIService _openAIService;

  QuizService(this._quizRepo, this._openAIService);

  Future<void> generateQuizForRandomVocab(String promptTemplate) async {
    final vocabData = await _quizRepo.getRandomVocabData();
    if (vocabData == null) throw Exception("단어 데이터 없음");

    final docId = vocabData["docId"];
    final exists = await _quizRepo.hasExistingQuiz(docId);
    if (exists) return;

    final quiz = await _openAIService.generateQuizQuestion(vocabData, promptTemplate);
    if (quiz == null) throw Exception("퀴즈 생성 실패");

    await _quizRepo.saveQuiz(docId, quiz.toMap());
  }

  //TODO :  퀴즈를 가져오는 함수인 getQuestion 함수를 구현 해야함

  //TODO: checkAnswer 함수를 통해 해당하는 문제의 정답을 확인하는 함수를 구현 해야함

  //TODO: compareAnswer 함수를 통해 정답과 사용자가 제출한 답안을 비교하는 함수를 구현 해야함 (오답 일 경우 레포지토리의 requestFeedBack 함수를 호출?)

  //TODO : 이후에 사용자의 통계를 갱신하는 함수인 updateStat 함수를 구현 해야함
}