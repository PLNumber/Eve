// lib/views/pages/quiz_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../controller/quiz_controller.dart';
import '../../services/quiz_service.dart';
import '../../repository/quiz_repository.dart';
import '../../Services/gemini_service.dart';
import '../../model/quiz.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final QuizController controller;
  QuizQuestion? currentQuestion;
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    controller = QuizController(
      QuizService(
        QuizRepository(
          GeminiService(apiKey: dotenv.env['geminiApiKey'] ?? ""),
        ),
      ),
    );
  }

  Future<void> _generateQuiz() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final quiz = await controller.generateQuiz();
      setState(() {
        currentQuestion = quiz as QuizQuestion?;
      });
    } catch (e) {
      setState(() {
        errorMessage = "문제 생성 실패: ${e.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("퀴즈 풀기"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage.isNotEmpty
              ? Text(errorMessage, style: const TextStyle(color: Colors.red))
              : currentQuestion != null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentQuestion!.question,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text("힌트: ${currentQuestion!.hint}"),
            ],
          )
              : ElevatedButton(
            onPressed: _generateQuiz,
            child: const Text("퀴즈 시작"),
          ),
        ),
      ),
    );
  }
}
