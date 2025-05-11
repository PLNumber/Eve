// ✅ lib/view/pages/quiz_page.dart 리디자인: 종료 버튼도 확인 다이얼로그 적용
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controller/quiz_controller.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../model/quiz.dart';
import '../widgets/nav_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool hasSubmitted = false;
  int _level = 1;
  int _exp = 0;
  final int _maxExp = 100;
  late final DateTime _quizStartTime;
  final TextEditingController _answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = context.read<QuizController>();
    _quizStartTime = DateTime.now();
    _loadQuiz();
    _loadUserLevel();
  }

  Future<void> _loadUserLevel() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final data = doc.data() ?? {};
    setState(() {
      _level = data['level'] ?? 1;
      _exp = data['experience'] ?? 0;
    });
  }

  Color getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green.shade200;
      case 2:
        return Colors.blue.shade100;
      case 3:
        return Colors.amber.shade200;
      case 4:
        return Colors.orange.shade300;
      case 5:
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Future<void> _endQuiz() async {
    final seconds = DateTime.now().difference(_quizStartTime).inSeconds;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'timeSpent': FieldValue.increment(seconds)});
    }
    controller.endQuiz(context);
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

    final result = await controller.checkAnswer(
      currentQuestion!,
      input,
      hasAlreadySubmitted: hasSubmitted,
    );

    hasSubmitted = true;

    if (result.isCorrect) {
      _answerCtrl.clear();
      setState(() => answerHintText = '답 입력');

      await showContinueOrEndDialog(
        context,
        onContinue: () async {
          final newQuiz = await controller.nextQuestion();
          if (newQuiz != null) {
            setState(() {
              currentQuestion = newQuiz;
              hasSubmitted = false;
            });
          } else {
            setState(() => errorMessage = "다음 문제를 가져올 수 없습니다.");
          }
        },
        onEnd: () async => await _endQuiz(),
      );
    } else {
      _answerCtrl.clear();
      if (result.feedback != null) _showFeedbackDialog(result.feedback!);
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
        ],
      ),
    );
  }

  String _extractInitialHint(String text) {
    const CHO = ['ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
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
    final quiz = currentQuestion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showConfirmDialog(
          context,
          title: local.exit,
          content: local.confirm_exit,
          onConfirm: () async => await _endQuiz(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                showConfirmDialog(
                  context,
                  title: local.exit,
                  content: local.confirm_exit,
                  onConfirm: () => _endQuiz(),
                );
              },
            )
          ],
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LinearProgressIndicator(
                  value: _exp / _maxExp,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: getDifficultyColor(quiz?.difficulty ?? 0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("난이도 ${quiz?.difficulty ?? '-'}"),
                    ),
                    if (quiz?.isReview == true)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("복습 문제", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            quiz!.question,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showFeedbackDialog(quiz.hint),
                            child: const Text('힌트'),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}