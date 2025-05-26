// lib/services/quiz_service.dart

import '../repository/quiz_repository.dart';
import 'package:eve/model/quiz.dart';
import '../controller/quiz_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizService {
  final QuizRepository _repository;

  QuizService(this._repository);

  int _quizCount = 0;
  final int reviewInterval = 5; // 5턴마다 복습문제

  /// ✅ 밑줄 길이 조정 함수 (정답의 길이만큼)
  String adjustBlankLength(String question, String answer) {
    final blankRegex = RegExp(r'_+');
    final stem = extractStem(answer);
    return question.replaceAllMapped(blankRegex, (_) => '_' * stem.length);
  }

  /// ✅ 밑줄이 중간에 끊어진 경우 (예: '__ __')를 한 줄로 보정
  String fixSplitUnderscore(String question) {
    final multiUnderscoreWithSpace = RegExp(r'_+\s+_+');
    return question.replaceAllMapped(multiUnderscoreWithSpace, (match) {
      return match.group(0)!.replaceAll(' ', '');
    });
  }

  /// ✅ 전체 포맷 적용
  String formatQuestion(String question, String answer) {
    final adjusted = adjustBlankLength(question, answer);
    return fixSplitUnderscore(adjusted);
  }

  /// ✅ 동사의 어간 추출
  String extractStem(String verb) {
    if (verb.endsWith('하다')) {
      return verb.substring(0, verb.length - 2);
    } else if (verb.endsWith('가다') || verb.endsWith('오다')) {
      return verb.substring(0, verb.length - 1);
    } else if (verb.endsWith('다')) {
      return verb.substring(0, verb.length - 1);
    } else {
      return verb;
    }
  }

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
        final formattedQuestion = formatQuestion(
          question.question,
          question.answer,
        );
        return QuizQuestion(
          question: formattedQuestion,
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
    final saved = await _repository.getSavedQuestion(vocab['어휘']);
    final formattedQuestion = formatQuestion(saved.question, saved.answer);

    return QuizQuestion(
      question: formattedQuestion,
      answer: saved.answer,
      hint: saved.hint,
      distractors: saved.distractors,
      feedbacks: saved.feedbacks,
      difficulty: saved.difficulty,
      isReview: false,
    );
  }

  Future<AnswerResult> compareAnswer(
    QuizQuestion question,
    String userInput, {
    required bool hasAlreadySubmitted,
  }) async {
    final isCorrect = userInput == question.answer;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (!hasAlreadySubmitted && uid != null) {
      await _repository.incrementTotalSolved(uid);
    }

    if (isCorrect) {
      if (!hasAlreadySubmitted && uid != null) {
        await _repository.incrementCorrectSolved(uid);
        await _repository.updateStatsOnCorrect(
          uid,
          question.answer,
          question.difficulty,
        );
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
      if (!hasAlreadySubmitted && uid != null) {
        await _repository.updateStatsOnIncorrect(uid, question.answer);
      }
      return AnswerResult(isCorrect: false, feedback: question.feedbacks[idx]);
    }

    final newFeedback = await _repository.generateFeedBack(
      question.answer,
      userInput,
    );
    await _repository.appendFeedback(question.answer, userInput, newFeedback);

    if (!hasAlreadySubmitted && uid != null) {
      await _repository.updateStatsOnIncorrect(uid, question.answer);
    }

    return AnswerResult(isCorrect: false, feedback: newFeedback);
  }

  bool isClearlyInvalidWord(String input) {
    for (int i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      final isCho = code >= 0x3131 && code <= 0x314E; // 자음
      final isJung = code >= 0x314F && code <= 0x3163; // 모음
      if (isCho || isJung) return true;
    }
    return false;
  }
}
