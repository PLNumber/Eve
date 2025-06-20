// ✅ lib/view/pages/quiz_page.dart 리디자인: 종료 버튼도 확인 다이얼로그 적용
import 'package:eve/views/pages/quiz_option_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controller/quiz_controller.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../model/quiz.dart';
import '../widgets/nav_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final FocusNode _answerFocusNode;

  late final QuizController controller;
  QuizQuestion? currentQuestion;
  bool isLoading = false;
  String errorMessage = "";
  String answerHintText = '답 입력(Enter answer)';
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
    _loadQuiz(isFirst: true); // 첫문제 로딩
    _loadUserLevel();
    _answerFocusNode = FocusNode(); // ⚡ 추가
    // 위젯 빌드 완료 후에 포커스 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show'); // 키보드 강제 표시
    });
  }

  @override
  void dispose() {
    _answerFocusNode.dispose(); // ⚡ 추가
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserLevel() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
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
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'timeSpent': FieldValue.increment(seconds),
      });
    }
    controller.endQuiz(context);
  }

  Future<void> _loadQuiz({bool isFirst = false}) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
      currentQuestion = null;
    });

    final quiz =
        isFirst
            ? await controller.generateQuiz()
            : await controller.nextQuestion();

    if (quiz == null) {
      setState(() {
        errorMessage =
            errorMessage = AppLocalizations.of(context)!.quizErrorNext;
        isLoading = false;
      });
      return;
    }

    setState(() {
      currentQuestion = quiz;
      isLoading = false;
      hasSubmitted = false;
      _answerCtrl.clear();
      answerHintText = '답 입력(Enter answer)';
    });
  }

  Future<void> _submitAnswer(String input) async {
    final local = AppLocalizations.of(context)!;
    if (currentQuestion == null) return;

    final result = await controller.checkAnswer(
      currentQuestion!,
      input,
      hasAlreadySubmitted: hasSubmitted,
    );

    if (!hasSubmitted) {
      await _increaseDailyVocabCount(); // 처음 제출일 때만 증가
    }

    hasSubmitted = true;

    if (result.isCorrect) {
      _answerCtrl.clear();
      setState(() => answerHintText = '답 입력(Enter answer)');

      await showContinueOrEndDialog(
        context,
        onContinue: () async {
          await _loadQuiz();
          // final newQuiz = await controller.nextQuestion();
          // if (newQuiz != null) {
          //   setState(() {
          //     currentQuestion = newQuiz;
          //     hasSubmitted = false;
          //   });
          // } else {
          //   setState(() => errorMessage = local.quizErrorNext);
          // }
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

  Future<void> _increaseDailyVocabCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final lastDate = prefs.getString('vocab_date');
    if (lastDate != todayKey) {
      await prefs.setInt('vocab_completed', 0);
      await prefs.setString('vocab_date', todayKey);
    }

    int completed = prefs.getInt('vocab_completed') ?? 0;
    completed++;
    await prefs.setInt('vocab_completed', completed);
    await prefs.setString('vocab_date', todayKey);

    // ✅ Firestore에도 저장
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'vocab_completed': completed,
      'vocab_date': todayKey,
    }, SetOptions(merge: true));
  }

  void _showFeedbackDialog(String message) {
    final local = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(local.hint),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(local.confirm),
              ),
            ],
          ),
    );
  }

  String _extractInitialHint(String text) {
    const CHO = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ',
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
        resizeToAvoidBottomInset: false, //변경
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizOptionPage()),
                ),
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
            ),
          ],
        ),
        body: SafeArea(
          child:
              isLoading || currentQuestion == null
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text(
                          "다음 문제 생성 중...",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  : errorMessage.isNotEmpty
                  ? Center(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 레벨 progress bar 생략
                      //const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: getDifficultyColor(
                                            quiz?.difficulty ?? 0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          local.difficultyBadge(
                                            quiz?.difficulty ?? 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.lightbulb_outline),
                                    tooltip: local.hint,
                                    onPressed:
                                        () => _showFeedbackDialog(quiz!.hint),
                                  ),

                                  if (quiz?.isReview == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        local.reviewBadge,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    quiz!.question.replaceAllMapped(
                                      RegExp(r'_+'),
                                      (match) =>
                                          '▁' *
                                          match
                                              .group(0)!
                                              .length, // ex: ___ → ▁▁▁
                                    ),
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _answerCtrl,
                                      focusNode: _answerFocusNode, //
                                      autofocus: true, //
                                      decoration: InputDecoration(
                                        hintText: answerHintText,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                    ),
                                    tooltip: local.confirm,
                                    onPressed:
                                        () => _submitAnswer(
                                          _answerCtrl.text.trim(),
                                        ),
                                  ),
                                  if (hasSubmitted && !isLoading)
                                    IconButton(
                                      icon: const Icon(Icons.skip_next),
                                      tooltip: local.next_question,
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                          errorMessage = '';
                                        });

                                        final newQuiz = await controller.nextQuestion();

                                        if (newQuiz != null) {
                                          setState(() {
                                            currentQuestion = newQuiz;
                                            hasSubmitted = false;
                                            _answerCtrl.clear();
                                            answerHintText = '답 입력(Enter answer)';
                                          });
                                        } else {
                                          setState(() {
                                            errorMessage = local.quizErrorNext;
                                          });
                                        }

                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                    ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
        ),
      ),
    );
  }
}
