import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:eve/model/quiz.dart';

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<QuizQuestion?> generateQuizQuestion(
    Map<String, dynamic> vocabData,
    String promptTemplate,
  ) async {
    final word = vocabData['어휘'];
    final meaning = vocabData['의미'];
    final pos = vocabData['품사'];
    final level = vocabData['등급'];

    final prompt = promptTemplate
        .replaceAll('{단어}', word)
        .replaceAll('{의미}', meaning)
        .replaceAll('{품사}', pos)
        .replaceAll('{등급}', level);

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

      if (response.statusCode != 200) {
        print("❌ Gemini API 에러: ${response.statusCode}");
        print("본문: ${response.body}");
        return null;
      }

      final decoded = jsonDecode(response.body);
      String? text =
          decoded["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      // ✅ 코드 블럭 제거
      if (text != null && text.startsWith("```json")) {
        text = text.replaceAll("```json", "").replaceAll("```", "").trim();
      }

      if (text == null || text.isEmpty) {
        print("❗ Gemini 응답 내용이 비어있습니다");
        print("전체 응답: ${response.body}");
        return null;
      }

      // ✅ text 내용이 리스트인지 객체인지 구분하여 파싱
      final parsed = jsonDecode(text);
      final quizJson = parsed is List ? parsed[0] : parsed;

      return QuizQuestion(
        question: quizJson['question'] ?? "",
        answer: quizJson['answer'] ?? "",
        hint: quizJson['hint'] ?? "힌트 없음",
        distractors: List<String>.from(quizJson['distractors'] ?? []),
        feedbacks: List<String>.from(quizJson['feedbacks'] ?? []),
        // ✅ 복수형 피드백
        difficulty: int.tryParse(quizJson['difficulty']?.toString() ?? "") ?? 3,
      );
    } catch (e) {
      print("❗ Gemini 응답 파싱 에러: $e");
      return null;
    }
  }
}
