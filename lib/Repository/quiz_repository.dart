// lib/repository/quiz_repository.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getRandomVocabData() async {
    final snapshot = await _firestore.collection("vocab4").get();
    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs[Random().nextInt(snapshot.docs.length)];
    final data = doc.data() as Map<String, dynamic>;
    data["docId"] = doc.id;
    return data;
  }

  Future<bool> hasExistingQuiz(String vocabDocId) async {
    final snapshot = await _firestore
        .collection("quizQuestions")
        .where("vocabId", isEqualTo: vocabDocId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> saveQuiz(String vocabDocId, Map<String, dynamic> quizMap) async {
    quizMap["vocabId"] = vocabDocId;
    await _firestore.collection("quizQuestions").add(quizMap);
  }
}