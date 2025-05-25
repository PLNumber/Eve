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
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final wordHistory = List<String>.from(userDoc.data()?['wordHistory'] ?? []);
    final userLevel = userDoc.data()?['level'] ?? 1;

    // ✅ 레벨 기반 등급 필터링
    final levelRange = getGradeRangeFromLevel(userLevel);

    // ✅ vocab4에서 등급 + history 제외 필터
    final vocabSnap =
        await _firestore
            .collection('vocab')
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
  Future<QuizQuestion> generateQuestion(Map<String, dynamic> vocabData) async {
    final promptTemplate = '''
당신은 한국어 문해력 평가를 위한 퀴즈 문제 출제자입니다.

다음 단어 "{단어}"는 {품사}이며, 의미는 "{의미}"이고 난이도는 {등급}입니다.

당신의 임무는 이 단어를 활용하여 정확하고 문맥이 분명한 단답형 퀴즈 문제를 작성하는 것입니다.  
다음 조건을 반드시 지키세요:

---

📌 [문제(question)] 조건:

1. 문제 문장은 반드시 **2문장 이상**으로 구성하여, 문맥을 충분히 제공합니다.

2. 정답이 사용된 자리는 반드시 **정답의 글자 수만큼 밑줄( _ )을 정확하게 사용**하여 가려주세요.
   - 예: 정답이 “책임감”(3글자) → “___”
   - 예: 정답이 “강”(1글자) → “_”
   - ❗절대 더 많거나 적게 밑줄을 사용하지 마세요.

3. **동사인 경우**, 문맥에 맞는 활용형을 사용하되 **어간(어휘의 고정된 부분)**만 가리고,  
   **어미(변화하는 부분)는 그대로 노출**하여 문법상 자연스럽게 보이도록 하세요.
   - 예: 정답 “보다” → 문장: “그는 논문을 __고 분석했다.”
   - 예: 정답 “달리다” → 문장: “그는 새벽마다 공원을 ___고 있었다.”

4. 밑줄( _ )의 개수는 반드시 **정답에서 가려진 부분의 글자 수와 정확히 일치**해야 합니다.
   - 예: “가능성”이면 “______” / “의심하다”면 “_____다”
   - ❗한 글자 단어는 `_`, 두 글자면 `__`, 세 글자면 `___`입니다.
   - 절대 "__" 또는 "_____"처럼 과도하거나 불일치하게 넣지 마세요.

5. 중의적인 단어는 피하고, **정답만 정확히 들어맞는 문장**을 구성하세요.

---

📌 [정답(answer)] 조건:

- 반드시 **기본형(원형)**으로 작성하세요. 예: “달리다”, “가능성”

❗ 정답의 밑줄은 항상 **한 덩어리로 연속된 밑줄(_)**로 표시해야 합니다.

예:
- 정답이 “책임감” → “___”
- 정답이 “떠나가다” → “_______”
- 절대 “___ ___”처럼 나누지 마세요. 공백 없이 붙여서 써야 합니다.


---

📌 [오답(distractors)] 조건:

- 정답과 의미/형태가 비슷하지만 문맥상 어색하거나 부적절한 단어 3개를 작성하세요.

---

📌 [피드백(feedbacks)] 조건:

- 각 오답에 대해 왜 틀렸는지 **문맥 중심으로 설명**하세요.

---

📌 [힌트(hint)] 조건:

- 직접적인 정의 대신, **문맥을 유추할 수 있는 간접적인 힌트**를 작성하세요.
- 각 오답에 대해 왜 틀렸는지를 **문맥 중심으로 설명**하세요.
- 단, 절대 정답 단어를 직접 언급하거나 유추할 수 있도록 말하지 마세요.
  예: "정답은 ~다", "정답처럼 ~한 느낌이다" → ❌ 금지

- 피드백은 오직 해당 오답이 왜 부적절한지에만 집중하세요.
  예시:
  - 오답: "기쁘다" → 피드백: "이 문장은 감정이 복잡하고 당황한 상황으로, 긍정적인 감정은 어울리지 않습니다."
❗ 피드백 작성 시 주의사항:
- 절대 정답 단어를 직접 쓰지 마세요. ("정답은 어리둥절하다" ❌)
- 정답을 유추할 수 있는 표현도 금지입니다. ("정답처럼 당황한 감정" ❌)
- 피드백은 오직 오답의 부적절성을 설명하는 데에만 집중하세요.


---

📌 [난이도(difficulty)] 조건:

- 난이도는 1~5 사이의 정수이며, {등급숫자}를 그대로 사용하세요.

---

📌 [출력 형식]
- 반드시 아래 JSON 형식만 출력하세요. 다른 설명은 절대 포함하지 마세요.

```json
{
  "question": "문맥 기반 문장 (정답과 밑줄 길이 일치)",
  "answer": "{단어}",  // 동사일 경우 반드시 원형
  "hint": "문맥을 간접적으로 설명",
  "distractors": ["혼동어1", "혼동어2", "혼동어3"],
  "feedbacks": ["오답1 설명", "오답2 설명", "오답3 설명"],
  "difficulty": {등급숫자}
}

❌ 자주 발생하는 금지사항 (꼭 지키세요)

절대 정답을 노출하지 마세요.

절대 정답의 글자 수와 일치하지 않는 밑줄을 사용하지 마세요.

절대 출력 형식 외의 문장을 추가하지 마세요.


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

  /*================================================================================*/

  //해당 문제의 정답을 가져 오는 함수인 getAnswer 함수를 구현 해야함  x

  //오답 일 경우, 해당 하는 정답의 피드백을 불러오는 requestFeedBack 함수를 구현 해야함

  //만약 해당하는 오답의 피드백이 없을 경우 해당하는 오답의 피드백을 생성하는 generateFeedBack 함수를 구현해야함 (아니면 공용 피드백을 호출하는 방법도 괜찮을듯 함)

  //사용자의 정보를 변경하는 changeStat 함수를 구현 해야함
}
