// lib/services/quiz_service.dart

import '../repository/quiz_repository.dart';
import 'package:eve/model/quiz.dart';
import '../controller/quiz_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizService {
  final QuizRepository _repository;

  QuizService(this._repository);

  int _quizCount = 0;
  final int reviewInterval = 5; // 5턴마다 복습문제

  //퀴즈를 가져오는 함수인 getQuestion 함수를 구현 해야함
  // 퀴즈 요청
  Future<QuizQuestion?> getQuestion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("사용자 인증 정보가 없습니다.");
    }

    _quizCount++;
    final isReviewTurn = _quizCount % reviewInterval == 0;

    if (isReviewTurn) {
      final reviewWord = await _repository.getRandomIncorrectWord(uid);
      if (reviewWord != null) {
        final question = await _repository.getSavedQuestion(reviewWord);
        return QuizQuestion(
          question: question.question,
          answer: question.answer,
          hint: question.hint,
          distractors: question.distractors,
          feedbacks: question.feedbacks,
          difficulty: question.difficulty,
          isReview: true,
        );
      }
    }

    final vocab = await _repository.selectWord(uid);
    final exists = await _repository.isExist(vocab['어휘']);

    if (!exists) {
      return await _repository.generateQuestion(vocab);
    }

    final question = await _repository.getSavedQuestion(vocab['어휘']);
    return QuizQuestion(
      question: question.question,
      answer: question.answer,
      hint: question.hint,
      distractors: question.distractors,
      feedbacks: question.feedbacks,
      difficulty: question.difficulty,
      isReview: false,
    );
  }

  //compareAnswer 함수를 통해 정답과 사용자가 제출한 답안을 비교하는 함수
  Future<AnswerResult> compareAnswer(QuizQuestion question, String userInput) async {
    final isCorrect = userInput == question.answer;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (isCorrect) {
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final incorrectList = List<String>.from(userDoc.data()?['incorrectWords'] ?? []);
        final wasIncorrect = incorrectList.contains(question.answer);

        // ✅ 항상 시도 횟수는 증가
        await _repository.incrementTotalSolved(uid);

        // ✅ 오답을 낸 적 없는 경우에만 정답률 반영
        if (!wasIncorrect) {
          await _repository.incrementCorrectSolved(uid);
        }
      }
      return AnswerResult(isCorrect: true);
    }

    if (isClearlyInvalidWord(userInput)) {
      return AnswerResult(
        isCorrect: false,
        feedback: "입력하신 단어는 올바른 단어가 아닙니다. 전체 단어를 입력해주세요.",
      );
    }

    final idx = question.distractors.indexOf(userInput);
    if (idx != -1 && idx < question.feedbacks.length) {
      if (uid != null) {
        await _repository.updateStatsOnIncorrect(uid, question.answer);
      }
      return AnswerResult(isCorrect: false, feedback: question.feedbacks[idx]);
    }

    final newFeedback = await _repository.generateFeedBack(question.answer, userInput);
    await _repository.appendFeedback(question.answer, userInput, newFeedback);

    if (uid != null) {
      await _repository.updateStatsOnIncorrect(uid, question.answer);
    }

    return AnswerResult(isCorrect: false, feedback: newFeedback);
  }


  bool isClearlyInvalidWord(String input) {
    for (int i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);

      final isCho = code >= 0x3131 && code <= 0x314E; // 자음
      final isJung = code >= 0x314F && code <= 0x3163; // 모음

      if (isCho || isJung) return true; // 자음/모음만 단독 존재 시 ❌
    }

    return false;
  }

  /*===================================================*/
  //TODO: checkAnswer 함수를 통해 해당하는 문제의 정답을 확인하는 함수를 구현 해야함 x

  //TODO : 이후에 사용자의 통계를 갱신하는 함수인 updateStat 함수를 구현 해야함
}
