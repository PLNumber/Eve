// ✅ GeminiService 리팩토링 (등급 문자열에서 난이도 숫자 추출 + 품사 일치 조건 추가 + 불필요한 수정 방지)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eve/model/quiz.dart';

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  int extractLevelNumber(String levelTag) {
    final match = RegExp(r'(\d+)').firstMatch(levelTag);
    return match != null ? int.parse(match.group(1)!) : 3;
  }

  Future<QuizQuestion?> generateQuizQuestion(
      Map<String, dynamic> vocabData,
      String promptTemplate,
      ) async {
    final word = vocabData['어휘'];
    final meaning = vocabData['의미'];
    final pos = vocabData['품사'];
    final level = vocabData['등급'];
    final levelNum = extractLevelNumber(level).toString();

    final prompt = promptTemplate
        .replaceAll('{단어}', word)
        .replaceAll('{의미}', meaning)
        .replaceAll('{품사}', pos)
        .replaceAll('{등급}', level)
        .replaceAll('{등급숫자}', levelNum)
        .replaceAll('{품사검증}', '''
- 주어진 단어의 품사가 **{품사}**이면, 문장 속 밑줄도 해당 품사 자리에 위치해야 합니다.
- 예: 단어가 명사면 → '____를 받았다' / 단어가 동사면 → '__는 중이다'
- ❌ 동사 자리에 명사를 정답으로 넣거나, 명사 자리에 동사를 넣지 마세요.
''');

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
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
      final json = jsonDecode(response.body);
      final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (text == null) {
        print('📭 Gemini 응답 text 없음: $word');
        return null;
      }
      //
      // print('[Gemini 응답 원문: $word] → $text');

      final cleaned = text.replaceAll(RegExp(r'^```json|```'), '').trim();
      final safeCleaned = cleaned.replaceAll(r"\'", "'"); // ← 이 줄 추가
      final map = jsonDecode(safeCleaned);

      map['difficulty'] ??= extractLevelNumber(level);
      return QuizQuestion.fromJson(map);
    } catch (e) {
      print('Gemini Error: $e');
      return null;
    }
  }

  Future<QuizQuestion?> reviewAndFixQuiz(
      Map<String, dynamic> quiz,
      Map<String, dynamic> vocabData,
      ) async {
    final prompt = _buildReviewPrompt(quiz, vocabData);
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
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
      final json = jsonDecode(response.body);
      final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text == null) return null;

      final cleaned = text.replaceAll(RegExp(r'^```json|```'), '').trim();

// ✅ JSON이 아닌 경우 그냥 무시
      if (!cleaned.startsWith('{')) {
        print('✅ Gemini 응답이 자연어입니다. 수정 없이 원본 유지');
        return null;
      }

// ✅ 이스케이프 문자 정리
      final safeCleaned = cleaned.replaceAll(r"\'", "'");

      final map = jsonDecode(safeCleaned);

      final level = vocabData['등급'];
      map['difficulty'] ??= extractLevelNumber(level);
      return QuizQuestion.fromJson(map);
    } catch (e) {
      print('Review Fix Error: $e');
      return null;
    }
  }


  String _buildReviewPrompt(
      Map<String, dynamic> quiz,
      Map<String, dynamic> vocabData,
      ) {
    final quizJson = jsonEncode(quiz);
    final word = vocabData['어휘'];
    final meaning = vocabData['의미'];
    final pos = vocabData['품사'];
    final level = vocabData['등급'];
    final levelNum = extractLevelNumber(level);

    return '''
너는 한국어 문해력 평가용 퀴즈 문제를 검토하는 전문가야.

아래 JSON 형식의 문제는 AI가 생성한 결과야. 이 문제를 다음 기준에 따라 철저히 검토하고, 수정해야 할 부분이 있다면 수정된 JSON을 반환해.

---
📌 [검토 기준]
1. 문법적으로 올바른가?
   - 조사, 어미, 품사 간 결합이 자연스러운가? 
   - 예: "우리 반을 담임을 맡다 ❌" → "우리 반의 담임을 맡다 ✅"

2. 문맥이 자연스러운가? (어색하거나 의미가 모호하지 않아야 함)

3. 정답은 명확하며, 오답은 정답이 될 수 없도록 문맥이 설정되었는가?

4. distractors와 feedback은 정답과 구별되고 논리적인가?

5. JSON 형식을 정확하게 지키고 있는가?

6. 동사인 경우, 밑줄은 어간만 가리고 문장 속 어미는 그대로 유지되었는가?

7. 문장의 밑줄 위치와 정답의 품사가 일치하는가? 
   - 예: 명사면 명사 자리, 동사면 동사 자리

8. 원본 문제에 문법적/논리적 문제가 없다면 **절대 수정하지 마세요.**
   - 불필요한 수정은 문제의 일관성을 해칠 수 있습니다.
   - 문법/의미 오류가 있을 때에만 수정하세요.

---
📌 [어휘 정보]
- 단어: "$word"
- 품사: $pos
- 의미: "$meaning"
- 난이도: $levelNum

---
📌 [문제 JSON]
$quizJson

---
📌 [출력 형식]
```json
{
  "question": "문맥 기반 문장 (정답 밑줄 처리 포함)",
  "answer": "$word",
  "hint": "문맥을 유추할 수 있는 힌트",
  "distractors": ["혼동어1", "혼동어2", "혼동어3"],
  "feedbacks": ["오답1 피드백", "오답2 피드백", "오답3 피드백"],
  "difficulty": $levelNum
}

''';
  }
}
