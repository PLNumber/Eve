/*

*/

// lib/view_model/quiz_view_model.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/quiz.dart';
import '../services/openai_service.dart';

class QuizViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OpenAIService _openAIService;

  bool isLoading = false;
  String errorMessage = "";

  QuizViewModel({required String openAIApiKey})
      : _openAIService = OpenAIService(apiKey: openAIApiKey);

  /// vocab4에서 랜덤하게 단어 하나를 가져옵니다.
  Future<Map<String, dynamic>?> getRandomVocabData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("vocab4").get();
      if (snapshot.docs.isEmpty) {
        errorMessage = "단어 데이터가 없습니다.";
        notifyListeners();
        return null;
      }
      int randomIndex = Random().nextInt(snapshot.docs.length);
      final doc = snapshot.docs[randomIndex];
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // 단어 데이터에 Firestore 문서 ID 추가(퀴즈 문제 연결을 위해)
      data["docId"] = doc.id;
      return data;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// 단어 데이터(vocabData)에 대해, 이미 퀴즈 문제가 있으면 가져오고,
  /// 없으면 OpenAI API로 문제를 생성하여 저장합니다.
  Future<void> generateQuizForRandomVocab(String promptTemplate) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      // 1. 랜덤 단어 데이터 가져오기
      Map<String, dynamic>? vocabData = await getRandomVocabData();
      if (vocabData == null) return;

      String vocabDocId = vocabData["docId"];

      // 2. 해당 단어에 이미 생성된 퀴즈 질문이 있는지 확인
      QuerySnapshot quizSnapshot = await _firestore
          .collection("quizQuestions")
          .where("vocabId", isEqualTo: vocabDocId)
          .get();
      if (quizSnapshot.docs.isNotEmpty) {
        print("이미 퀴즈 문제가 존재합니다.");
        isLoading = false;
        notifyListeners();
        return;
      }

      // 3. 퀴즈 문제 생성
      QuizQuestion? quiz = await _openAIService.generateQuizQuestion(vocabData, promptTemplate);
      if (quiz != null) {
        Map<String, dynamic> quizMap = quiz.toMap();
        // 단어와 연결하기 위한 vocabId 필드 추가
        quizMap["vocabId"] = vocabDocId;
        await _firestore.collection("quizQuestions").add(quizMap);
      } else {
        errorMessage = "퀴즈 생성에 실패했습니다.";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
