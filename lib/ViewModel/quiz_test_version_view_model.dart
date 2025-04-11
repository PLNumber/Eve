// lib/view_model/solve_quiz_view_model.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/quiz.dart';

/// 문제를 가져오고 화면에 표시하기 위한 뷰모델
class SolveQuizViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;       // 로딩 상태
  String errorMessage = "";     // 에러 메시지

  // 현재 선택된 단어 데이터 (필요시 화면에 단어도 출력 가능)
  Map<String, dynamic>? currentVocab;
  // 현재 화면에 표시할 문제
  QuizQuestion? currentQuestion;

  /// 1. vocab5 컬렉션에서 랜덤하게 단어 하나를 가져온 뒤,
  /// 2. 해당 단어의 '어휘' 값과 question 컬렉션의 '정답' 값이 같은 문서를 찾아 currentQuestion에 할당합니다.
  Future<void> fetchQuizForRandomVocab() async {
    isLoading = true;
    errorMessage = "";
    currentQuestion = null;
    currentVocab = null;
    notifyListeners();

    try {
      // 1. vocab5 컬렉션에서 랜덤 단어 하나 가져오기
      QuerySnapshot vocabSnapshot = await _firestore.collection("vocab5").get();
      if (vocabSnapshot.docs.isEmpty) {
        errorMessage = "단어 데이터(vocab5)가 비어 있습니다.";
        notifyListeners();
        return;
      }
      int randomIndex = Random().nextInt(vocabSnapshot.docs.length);
      final vocabDoc = vocabSnapshot.docs[randomIndex];

      // 현재 단어 데이터
      currentVocab = vocabDoc.data() as Map<String, dynamic>;
      // docId는 필요에 따라 저장 (여기서는 '어휘' 값만 사용)
      currentVocab!["docId"] = vocabDoc.id;

      // 2. vocab5의 '어휘'와 question 컬렉션의 '정답'이 일치하는 문서를 찾기
      String vocabWord = currentVocab!["어휘"];
      QuerySnapshot questionSnapshot = await _firestore
          .collection("question")
          .where("정답", isEqualTo: vocabWord)
          .get();

      if (questionSnapshot.docs.isNotEmpty) {
        // 검색된 question 문서 중 첫 번째 문서를 사용
        final qData = questionSnapshot.docs.first.data() as Map<String, dynamic>;

        currentQuestion = QuizQuestion(
          question: qData["문제"] ?? "",
          answer: qData["정답"] ?? "",
          hint: qData["힌트"] ?? "",
          distractors: List<String>.from(qData["예시오답"] ?? []),
          feedback: qData["오답피드백"] ?? "",
          difficulty: qData["난이도"] ?? 1,
        );
      } else {
        errorMessage = "해당 단어에 대한 문제가 question 컬렉션에 존재하지 않습니다.";
      }
    } catch (e) {
      errorMessage = "문제를 불러오는 중 오류 발생: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
