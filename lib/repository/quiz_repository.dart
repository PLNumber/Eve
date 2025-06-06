// lib/repository/quiz_repository.dart

import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eve/model/quiz.dart';
import '../services/gemini_service.dart';
import 'package:http/http.dart' as http; // 추가 필요

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService geminiService;

  QuizRepository(this.geminiService);

  // 해당하는 단어를 선택하는  함수인 selectWord 함수를 구현
  // ✅ 1. 랜덤 단어 선택
  Future<Map<String, dynamic>> selectWord(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final wordHistory = List<String>.from(userDoc.data()?['wordHistory'] ?? []);
    final userLevel = userDoc.data()?['level'] ?? 1;

    // ✅ 레벨 기반 등급 필터링
    final levelRange = getGradeRangeFromLevel(userLevel);

    // ✅ vocab4에서 등급 + history 제외 필터
    final vocabSnap =
        await _firestore
            .collection('vocab2')
            .where('등급', whereIn: levelRange)
            .get();

    final remaining =
        vocabSnap.docs.where((doc) {
          final word = doc.data()['어휘'];
          return !wordHistory.contains(word);
        }).toList();

    if (remaining.isEmpty) {
      throw Exception("해당 레벨에 맞는 단어를 모두 푸셨습니다!");
    }

    // ✅ 랜덤 단어 선택
    final selectedDoc = remaining[Random().nextInt(remaining.length)];
    final vocabData = selectedDoc.data();

    final word = vocabData['어휘'];
    final meanings = List<String>.from(vocabData['의미']);
    final selectedMeaning = meanings[Random().nextInt(meanings.length)];
    final partsOfSpeech = List<String>.from(vocabData['품사']).join(', ');
    final levelTag = vocabData['등급'];

    // ✅ 문제 존재 여부 확인 및 생성
    final exists = await isExist(word);

    if (!exists) {
      final newQuiz = await generateQuestion({
        '어휘': word,
        '의미': selectedMeaning,
        '품사': partsOfSpeech,
        '등급': levelTag,
      });
      await saveQuiz(word, newQuiz);
    }

    return {
      '어휘': word,
      '의미': selectedMeaning,
      '품사': partsOfSpeech,
      '등급': levelTag,
    };
  }

  // 레벨에 따른 등급
  List<String> getGradeRangeFromLevel(int level) {
    if (level <= 9) return ["1등급"];
    if (level <= 24) return ["1등급", "2등급"];
    if (level <= 49) return ["1등급", "2등급", "3등급"];
    if (level <= 74) return ["1등급", "2등급", "3등급", "4등급"];
    return ["1등급", "2등급", "3등급", "4등급", "5등급"];
  }

  // 선택한 단어로 만든 문제 데이터베이스가 존재하는지 판별하는 isExist 함수를 구현
  // ✅ 2. 문제 존재 여부 확인
  Future<bool> isExist(String word) async {
    final doc = await _firestore.collection('quizzes').doc(word).get();
    return doc.exists;
  }

  // 만약 존재하지 않을 경우, 해당 단어로 문제를 만드는 함수인 generateQuestion 함수를 구현
  // ✅ 3. 문제 생성 (Gemini 사용)
  Future<QuizQuestion> generateQuestion(Map<String, dynamic> vocabData, {int maxAttempts = 3}) async {
    final promptTemplate = '''
너는 한국어 문해력 평가용 퀴즈 문제를 만드는 AI야.

다음 단어 정보를 참고하여, 실제 **책/신문/시험 문제**에서 따온 것처럼 보이는 문맥 속 문장을 만들고, 해당 단어가 빈칸으로 가려지는 문제를 생성해줘.

---

📌 [단어 정보]
- 단어: "{단어}"
- 품사: {품사}
- 의미: "{의미}"
- 난이도: {등급}
- 난이도 숫자: {등급숫자}

---
📌 [의미 사용 조건]

- 반드시 위에서 주어진 **의미**를 참고하여 문제 문장을 구성하세요.
- 예시로 나열된 단어들(예: 종이, 먹, 붓 등)을 문맥 속에 자연스럽게 포함하거나,
  정의된 의미가 잘 드러나는 상황을 설정해서 문제를 작성하세요.
- 의미를 단순히 참고만 하지 말고, **문제 문장에 반영하세요.**

---

📌 [문제(question)] 조건:

1. 문제는 반드시 **2문장 이상**으로 구성하여 문맥을 충분히 제공합니다.

2. 정답이 사용된 자리는 **정답에서 가려질 부분의 글자 수만큼 정확히 연속된 밑줄(_)**로 가리세요.
   - 예: "책임감" → "___", "강" → "_"
   - ❗ 공백 없이 연속된 밑줄만 사용하고, 나눠 쓰지 마세요. (예: "___ ___" ❌)

3. **동사인 경우**, 문장에서는 활용형(예: -는, -고 있는)을 사용하되,
-   밑줄은 **동사의 어간만 가리도록 처리하세요**.
-   - 예: "보다" → "_고 있다", "통과하다" → "___하는"
-   - 즉, 어간만 밑줄로 처리하고 어미는 남겨야 합니다.
+   밑줄은 **정답 단어의 어간**에만 적용되도록 하세요.
+   - 예: 정답이 "보다"이면 → "_고 있다", 정답이 "통과하다"이면 → "___하는"
+   - 예: 정답이 "썩다"이고 문장에서는 "썩어나는"으로 쓰였으면 → "_어나는"으로 처리
+   - 즉, 문장에 사용된 형태에서 **정답의 어간에 해당하는 부분만** 밑줄로 가리고, 나머지 어미는 그대로 남겨야 합니다.

4. 밑줄 수는 **정확히 가려진 부분의 글자 수**와 일치해야 합니다.

5. 문맥상 **정답 외 단어는 들어갈 수 없도록** 문제를 구성하세요.

6. 정답 단어가 **문장 내 실제로 사용된 형태**에서 **밑줄 처리**되도록 하세요.
   - 예: 단어가 "짧다"라면 → 문장에서 "짧은", "짧아서" 등 활용형 사용 후 어간만 밑줄 처리

---

📌 [정답(answer)] 조건:

- 반드시 **기본형(원형)** 으로 작성하세요.
  - 예: "보다", "달리다"

---

📌 [오답(distractors)] 조건:

- 정답과 **형태 또는 의미가 유사하지만**, **문맥상 어울리지 않는 단어** 3개를 제시하세요.

---

📌 [피드백(feedbacks)] 조건:

- 각 오답이 **문맥에서 왜 적절하지 않은지** 구체적으로 설명하세요.
- ❗ 절대 정답을 직접 언급하거나 유추할 수 있게 설명하지 마세요.

---

📌 [힌트(hint)] 조건:

- 정답을 직접 언급하지 말고, **문맥적 힌트**를 자연스럽게 제시하세요.

---

📌 [난이도(difficulty)] 조건:

- 숫자 1~5 중, 주어진 등급 숫자 {등급숫자}를 그대로 사용하세요.

---

📌 [출력 형식]

반드시 아래 JSON 형식만 출력하세요. 그 외의 설명이나 텍스트는 절대 포함하지 마세요:

```json
{
  "question": "문맥 기반 문장 (정답 밑줄 처리 포함)",
  "answer": "{단어}", 
  "hint": "문맥을 유추할 수 있는 힌트",
  "distractors": ["혼동어1", "혼동어2", "혼동어3"],
  "feedbacks": ["오답1 피드백", "오답2 피드백", "오답3 피드백"],
  "difficulty": {등급숫자}
}

''';

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final quiz = await geminiService.generateQuizQuestion(vocabData, promptTemplate);

      if (quiz != null) {
        print('📦 [시도 $attempt] Gemini 원본 문제 JSON:\n${jsonEncode(quiz.toJson())}');
        print("🔍 정답 비교: quiz.answer = '\${quiz.answer}', 기대값 = '\${vocabData['어휘']}'");
      } else {
        print('❌ [시도 $attempt] Gemini 문제가 null임');
      }

      if (quiz != null && _isValidQuiz(quiz, vocabData['어휘'])) {
        final fixed = await geminiService.reviewAndFixQuiz(quiz.toJson(), vocabData);

        if (fixed != null && _isValidQuiz(fixed, vocabData['어휘'])) {
          print('🛠 [시도 $attempt] 수정된 문제 JSON:\n${jsonEncode(fixed.toJson())}');
          await saveQuiz(vocabData['어휘'], fixed);
          return fixed;
        } else if (fixed == null) {
          // ✅ 수정이 필요 없다고 판단되었을 때 원본 사용
          print('✅ [시도 $attempt] 수정 불필요, 원본 문제 채택');
          await saveQuiz(vocabData['어휘'], quiz);
          return quiz;
        } else {
          print('⚠️ [시도 $attempt] 수정된 문제가 유효하지 않음');
        }
      }

    }

    throw Exception("퀴즈 생성 실패: $maxAttempts회 시도했지만 유효한 문제를 만들지 못했습니다.");
  }

  bool _isValidQuiz(QuizQuestion quiz, String word) {
    return quiz.answer == word && quiz.question.contains('_');
  }

  Future<void> saveQuiz(String word, QuizQuestion quiz) async {
    await _firestore.collection('quizzes').doc(word).set(quiz.toJson());
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
너는 한국어 문해력 평가 시스템의 피드백 생성자야.

다음은 사용자가 푼 문제에서의 오답과 정답 정보야:

- 사용자 입력(오답): "$wrongInput"
- 실제 정답: "$answer"

너의 임무는 **오답이 왜 정답이 될 수 없는지**를 설명하는 피드백을 **1문장**으로 생성하는 거야.

---

📌 반드시 다음 조건을 모두 지켜야 해:

1. 피드백은 반드시 **1문장**으로 생성해.
2. 피드백은 오답 단어의 **의미, 품사, 쓰임**을 바탕으로 작성해.
3. **정답 단어를 직접 언급하지 마.**
   - 예: "정답은 ~~다", "~~와는 다르게", "정답처럼 ~~하다" → ❌ 금지
4. **정답을 유추할 수 있는 표현도 절대 쓰지 마.**
   - 예: "이 문장은 ~~한 단어가 들어가야 하므로 부적절하다" → ❌
5. '문맥상 맞지 않습니다' 같은 뭉뚱그린 말은 쓰지 말고, **구체적으로 오답의 문제를 설명해.**
   - 예시: "입력한 단어는 긍정적인 감정이지만, 문장은 혼란스러운 상황이다." → ✅
6. **문법적, 어휘적 정확성**을 유지하며 자연스러운 한국어로 작성해.

---

📌 반드시 아래 JSON 형식으로만 응답해야 해.  
**JSON 외에는 어떤 문장도 출력하지 마.**

```json
{"feedback": "입력한 단어는 '~'라는 의미지만, 이 문장은 '~' 상황을 묘사하고 있어 어울리지 않습니다."}
''';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiService.apiKey}',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 200) {
        throw Exception("Gemini 응답 실패: ${response.statusCode}");
      }

      String raw =
          jsonDecode(
                response.body,
              )["candidates"][0]["content"]["parts"][0]["text"]
              .replaceAll(RegExp(r'```json|```'), '')
              .trim();

      final parsed = jsonDecode(raw);
      return parsed['feedback'] ?? "피드백 생성에 실패했습니다.";
    } catch (e) {
      return "피드백 생성에 실패했습니다.";
    }
  }

  // 피드백 저장하기
  Future<void> appendFeedback(
    String word,
    String input,
    String feedback,
  ) async {
    await _firestore.collection('quizzes').doc(word).update({
      'distractors': FieldValue.arrayUnion([input]),
      'feedbacks': FieldValue.arrayUnion([feedback]),
    });
  }

  // 맞출시 통계 저장
  Future<void> updateStatsOnCorrect(
    String uid,
    String word,
    int difficulty,
  ) async {
    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();

    final reviewMap = Map<String, dynamic>.from(
      userDoc.data()?['reviewProgress'] ?? {},
    );
    final hasSeenBefore = reviewMap.containsKey(word);
    final correctCount = reviewMap[word] ?? 0;

    final updates = <String, dynamic>{
      'wordHistory': FieldValue.arrayUnion([word]),
    };

    // ✅ 경험치 차등 계산
    final currentExp = userDoc.data()?['experience'] ?? 0;
    final currentLevel = userDoc.data()?['level'] ?? 1;
    int gainedExp = switch (difficulty) {
      1 => 10,
      2 => 15,
      3 => 20,
      4 => 25,
      5 => 30,
      _ => 10,
    };

    int newExp = currentExp + gainedExp;
    int newLevel = currentLevel;

    if (newExp >= 100) {
      newLevel += 1;
      newExp -= 100;
    }

    updates['experience'] = newExp;
    updates['level'] = newLevel;

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
      'incorrectWords': FieldValue.arrayUnion([word]),
      'wordHistory': FieldValue.arrayUnion([word]),
      'reviewProgress.$word': 0, // 틀리면 다시 초기화
    });
  }

  // 복습문제 가져오기
  Future<String?> getRandomIncorrectWord(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final incorrect = List<String>.from(
      userDoc.data()?['incorrectWords'] ?? [],
    );
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
}
