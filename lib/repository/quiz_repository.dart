// lib/repository/quiz_repository.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eve/model/quiz.dart';
import '../Services/gemini_service.dart';


class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GeminiService geminiService;

  QuizRepository(this.geminiService);

  // 해당하는 단어를 선택하는  함수인 selectWord 함수를 구현
  // ✅ 1. 랜덤 단어 선택
  Future<Map<String, dynamic>> selectWord() async {
    final snapshot = await _firestore.collection('vocab4').get();
    final docs = snapshot.docs;
    if (docs.isEmpty) throw Exception("단어 데이터가 없습니다.");

    final randomDoc = docs[Random().nextInt(docs.length)];
    final data = randomDoc.data();

    final word = data['어휘'];
    final meanings = List<String>.from(data['의미']);
    final selectedMeaning = meanings[Random().nextInt(meanings.length)];

    final partsOfSpeech = List<String>.from(data['품사']).join(', ');
    final level = data['등급'];

    return {
      '어휘': word,
      '의미': selectedMeaning,
      '품사': partsOfSpeech,
      '등급': level,
    };
  }

  // 선택한 단어로 만든 문제 데이터베이스가 존재하는지 판별하는 isExist 함수를 구현
  // ✅ 2. 문제 존재 여부 확인
  Future<bool> isExist(String word) async {
    final doc = await _firestore.collection('quizzes').doc(word).get();
    return doc.exists;
  }

  // 만약 존재하지 않을 경우, 해당 단어로 문제를 만드는 함수인 generateQuestion 함수를 구현
  // ✅ 3. 문제 생성 (Gemini 사용)
  Future<QuizQuestion> generateQuestion(Map<String, dynamic> vocabData) async {
    final promptTemplate = '''
다음 단어 "{단어}"는 {품사}이며, 의미는 "{의미}"이고 난이도는 {등급}입니다.

이 단어를 활용한 단답형 퀴즈 문제를 다음 JSON 형식으로 바로 출력하세요.
다른 말 없이 아래 형식만 출력하세요.

결과는 반드시 JSON 형식으로, 키는 다음과 같아야 합니다:
"question", "answer", "hint", "distractors", "feedbacks", "difficulty"

- "distractors"는 오답 배열입니다.
- "feedbacks"는 각 오답에 대한 피드백을 순서대로 배열로 작성해주세요.

```json
{
  "question": "질문 내용",
  "answer": "{단어}",
  "hint": "힌트 문장",
  "distractors": ["오답1", "오답2", "오답3"],
  "feedbacks": ["오답1에 대한 설명", "오답2 설명", "오답3 설명"],
  "difficulty": 3
}

''';

    final quiz = await geminiService.generateQuizQuestion(vocabData, promptTemplate);
    if (quiz == null) throw Exception("Gemini 퀴즈 생성 실패");
    await saveQuiz(vocabData['어휘'], quiz);
    return quiz;
  }


  // 해당 문제를 만든 후 저장하는 함수인 saveQuiz 함수를 구현
  // ✅ 4. 문제 저장
  Future<void> saveQuiz(String word, QuizQuestion quiz) async {
    await _firestore.collection('quizzes').doc(word).set(quiz.toMap());
  }

  // ✅ 5. 저장된 문제 불러오기
  Future<QuizQuestion> getSavedQuestion(String word) async {
    final doc = await _firestore.collection('quizzes').doc(word).get();
    final data = doc.data();
    if (data == null) throw Exception("해당 문제를 찾을 수 없습니다.");

    return QuizQuestion(
      question: data['question'],
      answer: data['answer'],
      hint: data['hint'],
      distractors: List<String>.from(data['distractors']),
      feedbacks: List<String>.from(data['feedbacks']), // ✅ key & 타입 변경
      difficulty: data['difficulty'],
    );
  }



/*================================================================================*/

  //TODO : 해당 문제의 정답을 가져 오는 함수인 getAnswer 함수를 구현 해야함

  //TODO : 오답 일 경우, 해당 하는 정답의 피드백을 불러오는 requestFeedBack 함수를 구현 해야함

  //TODO : 만약 해당하는 오답의 피드백이 없을 경우 해당하는 오답의 피드백을 생성하는 generateFeedBack 함수를 구현해야함 (아니면 공용 피드백을 호출하는 방법도 괜찮을듯 함)

  //TODO : 사용자의 정보를 변경하는 changeStat 함수를 구현 해야함 


}
