// lib/view/pages/quiz_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ViewModel/quiz_view_model.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  static const String promptTemplate =
      "아래 단어와 의미를 참고하여 단답형 문제를 생성해줘. 결과는 반드시 JSON 형식으로, 키는 '문제', '정답', '힌트', '예시오답', '오답피드백', '난이도'로 해줘.\n"
      "단어: {어휘}\n의미: {의미}\n난이도: {난이도}";

  @override
  Widget build(BuildContext context) {
    final quizViewModel = Provider.of<QuizViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("퀴즈 풀기"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            quizViewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                await quizViewModel.generateQuiz(promptTemplate);
                if (quizViewModel.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(quizViewModel.errorMessage)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("퀴즈 생성 및 저장 완료!")),
                  );
                }
              },
              child: const Text("퀴즈 시작"),
            ),
          ],
        ),
      ),
    );
  }
}