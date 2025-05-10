// ✅ lib/view/pages/quiz_page.dart 분리 작업 후 구조
// View: QuizPage
// 로직 분리 대상: 문제 생성, 정답 제출 처리, 피드백 생성 → controller로 이동 예정

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controller/quiz_controller.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../model/quiz.dart';
import '../widgets/nav_util.dart';

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
  String answerHintText = '답 입력';
  final TextEditingController _answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = context.read<QuizController>();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final quiz = await controller.generateQuiz();
    if (quiz == null) {
      setState(() {
        errorMessage = "문제 생성 실패: 서버에서 문제를 받아올 수 없습니다.";
        isLoading = false;
      });
      return;
    }

    setState(() {
      currentQuestion = quiz;
      isLoading = false;
    });
  }

  Future<void> _submitAnswer(String input) async {
    if (currentQuestion == null) return;
    final result = await controller.checkAnswer(currentQuestion!, input);

    if (result.isCorrect) {
      _answerCtrl.clear();
      setState(() => answerHintText = '답 입력');

      await showContinueOrEndDialog(
        context,
        onContinue: () async {
          final newQuiz = await controller.nextQuestion();
          if (newQuiz != null) {
            setState(() => currentQuestion = newQuiz);
          } else {
            setState(() => errorMessage = "다음 문제를 가져올 수 없습니다.");
          }
        },
        onEnd: () {
          controller.endQuiz(context);
        },
      );
    } else {
      _answerCtrl.clear();

      if (result.feedback != null) {
        _showFeedbackDialog(result.feedback!);
      }

      final initialHint = _extractInitialHint(currentQuestion!.answer);
      setState(() => answerHintText = initialHint);
    }
  }

  void _showFeedbackDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('피드백'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _extractInitialHint(String text) {
    const CHO = [
      'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ',
      'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ',
      'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
    ];
    return text.split('').map((c) {
      final code = c.codeUnitAt(0);
      if (code >= 0xAC00 && code <= 0xD7A3) {
        final diff = code - 0xAC00;
        final idx = diff ~/ (21 * 28);
        return CHO[idx];
      }
      return c;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showConfirmDialog(
          context,
          title: local.exit,
          content: local.confirm_exit,
          onConfirm: () => controller.endQuiz(context), // ✅ 메인페이지로 이동
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('퀴즈 풀기'),
          automaticallyImplyLeading: false, // ⛔️ 기본 뒤로가기 버튼 제거
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showConfirmDialog(
                context,
                title: local.exit,
                content: local.confirm_exit,
                onConfirm: () => controller.endQuiz(context), // ✅ 메인페이지로 이동
              );
            },
          ),
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : _buildQuizContent(),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //복습문제 뱃지 포함
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('난이도 ${question.difficulty}', style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      if (question.isReview)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '복습 문제',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        question.question,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showFeedbackDialog(question.hint),
                        child: const Text('힌트'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(60, 40)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _answerCtrl,
                          decoration: InputDecoration(
                            hintText: answerHintText,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _submitAnswer(_answerCtrl.text.trim()),
                        child: const Text('확인'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(60, 40)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
