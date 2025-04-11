// lib/view/solve_quiz_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/quiz_test_version_view_model.dart';


class SolveQuizPage extends StatelessWidget {
  const SolveQuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizViewModel = Provider.of<SolveQuizViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("문제 풀기 테스트"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1) "문제 시작" 버튼
            quizViewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                await quizViewModel.fetchQuizForRandomVocab();
                if (quizViewModel.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(quizViewModel.errorMessage)),
                  );
                }
              },
              child: const Text("문제 시작"),
            ),
            const SizedBox(height: 20),

            // 2) 단어 정보 출력 (원한다면)
            if (quizViewModel.currentVocab != null) ...[
              Text(
                "단어: ${quizViewModel.currentVocab!['어휘'] ?? 'N/A'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3) 문제 데이터가 있으면 출력
            if (quizViewModel.currentQuestion != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "문제: ${quizViewModel.currentQuestion!.question}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "정답: ${quizViewModel.currentQuestion!.answer}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "힌트: ${quizViewModel.currentQuestion!.hint}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "예시오답: ${quizViewModel.currentQuestion!.distractors.join(', ')}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "오답 피드백: ${quizViewModel.currentQuestion!.feedback}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "난이도: ${quizViewModel.currentQuestion!.difficulty}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
