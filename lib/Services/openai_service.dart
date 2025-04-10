// lib/services/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Model/quiz.dart';


class OpenAIService {
  final String apiKey;

  OpenAIService({required this.apiKey});

  /// vocabData에는 '어휘', '의미', '등급' 등 정보가 있다고 가정합니다.
  /// promptTemplate는 {어휘}, {의미}, {난이도} 등의 플레이스홀더를 포함할 수 있습니다.
  Future<QuizQuestion?> generateQuizQuestion(Map<String, dynamic> vocabData, String promptTemplate) async {
    String vocabulary = vocabData['어휘'].toString();
    String meaning = (vocabData['의미'] is List)
        ? (vocabData['의미'] as List).join('\n')
        : vocabData['의미'].toString();
    int difficulty = int.tryParse(vocabData['등급'].toString()) ?? 1;

    String prompt = promptTemplate
        .replaceAll("{어휘}", vocabulary)
        .replaceAll("{의미}", meaning)
        .replaceAll("{난이도}", difficulty.toString());

    final url = Uri.https("api.openai.com", "/v1/chat/completions");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are an assistant that generates quiz questions based on provided vocabulary data."},
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.7,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String content = data["choices"][0]["message"]["content"];

      try {
        final jsonResult = jsonDecode(content);
        QuizQuestion quiz = QuizQuestion(
          question: jsonResult["문제"],
          answer: jsonResult["정답"],
          hint: jsonResult["힌트"],
          distractors: List<String>.from(jsonResult["예시오답"]),
          feedback: jsonResult["오답피드백"],
          difficulty: int.tryParse(jsonResult["난이도"].toString()) ?? difficulty,
        );
        return quiz;
      } catch (e) {
        print("OpenAI 응답 파싱 에러: $e");
        return null;
      }
    } else {
      print("OpenAI API 에러: ${response.statusCode} ${response.body}");

      return null;
    }
  }
}
