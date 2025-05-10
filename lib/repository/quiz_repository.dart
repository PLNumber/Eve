// lib/repository/quiz_repository.dart

import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eve/model/quiz.dart';
import '../Services/gemini_service.dart';
import 'package:http/http.dart' as http; // 추가 필요

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GeminiService geminiService;

  QuizRepository(this.geminiService);

  // 해당하는 단어를 선택하는  함수인 selectWord 함수를 구현
  // ✅ 1. 랜덤 단어 선택
  Future<Map<String, dynamic>> selectWord(String uid) async {
    // 1. 사용자의 wordHistory 불러오기
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final wordHistory = List<String>.from(userDoc.data()?['wordHistory'] ?? []);

    // 2. vocab4 컬렉션 전체 단어 가져오기
    final snapshot = await _firestore.collection('vocab4').get();
    final docs = snapshot.docs;

    if (docs.isEmpty) throw Exception("단어 데이터가 없습니다.");

    // 3. 아직 푼 적 없는 단어로 필터링
    final remaining = docs.where((doc) {
      final word = doc.data()['어휘'];
      return !wordHistory.contains(word);
    }).toList();

    if (remaining.isEmpty) throw Exception("모든 단어를 푸셨습니다!");

    // 4. 랜덤으로 하나 선택
    final randomDoc = remaining[Random().nextInt(remaining.length)];
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

    final quiz = await geminiService.generateQuizQuestion(
      vocabData,
      promptTemplate,
    );
    if (quiz == null) throw Exception("Gemini 퀴즈 생성 실패");
    await saveQuiz(vocabData['어휘'], quiz);
    return quiz;
  }

  // 해당 문제를 만든 후 저장하는 함수인 saveQuiz 함수를 구현
  // ✅ 4. 문제 저장
  Future<void> saveQuiz(String word, QuizQuestion quiz) async {
    await _firestore.collection('quizzes').doc(word).set(quiz.toMap());
  }

  // ✅ 5. 저장된 문제 불러오기\
  Future<QuizQuestion> getSavedQuestion(String word) async {
    final doc = await _firestore.collection('quizzes').doc(word).get();
    final data = doc.data();
    if (data == null) throw Exception("해당 문제를 찾을 수 없습니다.");

    return QuizQuestion(
      question: data['question'],
      answer: data['answer'],
      hint: data['hint'],
      distractors: List<String>.from(data['distractors']),
      feedbacks: List<String>.from(data['feedbacks']),
      // ✅ key & 타입 변경
      difficulty: data['difficulty'],
    );
  }

  // 피드백 생성하기
  Future<String> generateFeedBack(String answer, String wrongInput) async {
    final prompt = '''
사용자가 입력한 단어는 문제의 정답이 아닙니다.

오답: "$wrongInput"

정답 단어는 공개하지 마세요.  
대신 오답이 왜 적절하지 않은지, 의미적으로 어떤 점이 잘못되었는지를 한 문장으로 설명해주세요.  
정답을 유추할 수 없도록 설명은 일반적인 수준으로 제한합니다.

아래 JSON 형식으로만 응답하세요:
{"feedback": "입력한 단어는 사람이나 물건의 가치를 나타내지만, 문맥상 맞지 않습니다."}
''';


    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiService.apiKey}',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 200) {
        throw Exception("Gemini 응답 실패: ${response.statusCode}");
      }

      String raw = jsonDecode(response.body)["candidates"][0]["content"]["parts"][0]["text"]
          .replaceAll(RegExp(r'```json|```'), '')
          .trim();

      final parsed = jsonDecode(raw);
      return parsed['feedback'] ?? "피드백 생성에 실패했습니다.";
    } catch (e) {
      return "피드백 생성에 실패했습니다.";
    }
  }

  // 피드백 저장하기
  Future<void> appendFeedback(String word, String input, String feedback) async {
    await _firestore.collection('quizzes').doc(word).update({
      'distractors': FieldValue.arrayUnion([input]),
      'feedbacks': FieldValue.arrayUnion([feedback]),
    });
  }

  // 맞출시 통계 저장
  Future<void> updateStatsOnCorrect(String uid, String word) async {
    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();

    final reviewMap = Map<String, dynamic>.from(userDoc.data()?['reviewProgress'] ?? {});
    final hasSeenBefore = reviewMap.containsKey(word);
    final correctCount = reviewMap[word] ?? 0;

    final updates = <String, dynamic>{
      'wordHistory': FieldValue.arrayUnion([word]),
    };

    // ✅ 정답률 반영 조건:
    //  - 처음 푼 문제 (hasSeenBefore == false)
    //  - 복습 중인데 아직 맞춘 적 없는 경우 (== 0)
    if (!hasSeenBefore || (hasSeenBefore && correctCount == 0)) {
      updates['totalSolved'] = FieldValue.increment(1);
      updates['correctSolved'] = FieldValue.increment(1);
    }

    if (hasSeenBefore) {
      final newCount = correctCount + 1;

      if (newCount >= 3) {
        updates['reviewProgress.$word'] = FieldValue.delete();
        updates['incorrectWords'] = FieldValue.arrayRemove([word]);
      } else {
        updates['reviewProgress.$word'] = newCount;
      }
    }

    await userRef.update(updates);
  }


  // 틀릴 시 통계 저장
  Future<void> updateStatsOnIncorrect(String uid, String word) async {
    final userRef = _firestore.collection('users').doc(uid);
    await userRef.update({
      //'totalSolved': FieldValue.increment(1),
      'incorrectWords': FieldValue.arrayUnion([word]),
      'wordHistory': FieldValue.arrayUnion([word]),
      'reviewProgress.$word': 0, // 틀리면 다시 초기화
    });
  }

  // 복습문제 가져오기
  Future<String?> getRandomIncorrectWord(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final incorrect = List<String>.from(userDoc.data()?['incorrectWords'] ?? []);
    if (incorrect.isEmpty) return null;

    final randomWord = incorrect[Random().nextInt(incorrect.length)];
    return randomWord;
  }

  Future<void> incrementTotalSolved(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'totalSolved': FieldValue.increment(1),
    });
  }

  Future<void> incrementCorrectSolved(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'correctSolved': FieldValue.increment(1),
    });
  }



  // 기록 초기화
  Future<void> resetUserStats(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userRef.update({
      'wordHistory': [],
      'incorrectWords': [],
      'reviewProgress': {},
      'totalSolved': 0,
      'correctSolved': 0,
    });
  }

  /*================================================================================*/

  //TODO : 해당 문제의 정답을 가져 오는 함수인 getAnswer 함수를 구현 해야함  x

  //오답 일 경우, 해당 하는 정답의 피드백을 불러오는 requestFeedBack 함수를 구현 해야함

  //만약 해당하는 오답의 피드백이 없을 경우 해당하는 오답의 피드백을 생성하는 generateFeedBack 함수를 구현해야함 (아니면 공용 피드백을 호출하는 방법도 괜찮을듯 함)

  //TODO : 사용자의 정보를 변경하는 changeStat 함수를 구현 해야함
}
