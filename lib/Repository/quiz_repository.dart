// lib/repository/quiz_repository.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TODO : 해당하는 단어를 선택하는  함수인 selectWord 함수를 구현해야함 (아래의 코드는 테스트용)
  Future<Map<String, dynamic>?> getRandomVocabData() async {
    final snapshot = await _firestore.collection("vocab4").get();
    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs[Random().nextInt(snapshot.docs.length)];
    final data = doc.data() as Map<String, dynamic>;
    data["docId"] = doc.id;
    return data;
  }

  // TODO : 선택한 단어로 만든 문제 데이터베이스가 존재하는지 판별하는 isExist 함수를 구현해야함 (아래의 코드는 테스틑 용임)
  Future<bool> hasExistingQuiz(String vocabDocId) async {
    final snapshot = await _firestore
        .collection("quizQuestions")
        .where("vocabId", isEqualTo: vocabDocId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // TODO : 만약 존재하지 않을 경우, 해당 단어로 문제를 만드는 함수인 generateQuestion 함수를 구현해야함


  // TODO : 해당 문제를 만든 후 저장하는 함수인 saveQuiz 함수를 구현해야함 (아래의 코드는 테스트용)
  Future<void> saveQuiz(String vocabDocId, Map<String, dynamic> quizMap) async {
    quizMap["vocabId"] = vocabDocId;
    await _firestore.collection("quizQuestions").add(quizMap);
  }



  //TODO : 해당 문제의 정답을 가져 오는 함수인 getAnswer 함수를 구현 해야함

  //TODO : 오답 일 경우, 해당 하는 정답의 피드백을 불러오는 requestFeedBack 함수를 구현 해야함

  //TODO : 만약 해당하는 오답의 피드백이 없을 경우 해당하는 오답의 피드백을 생성하는 generateFeedBack 함수를 구현해야함 (아니면 공용 피드백을 호출하는 방법도 괜찮을듯 함)

  //TODO : 사용자의 정보를 변경하는 changeStat 함수를 구현 해야함 


}
