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
}