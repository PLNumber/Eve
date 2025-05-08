import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../Services/gemini_service.dart';
import '../../controller/quiz_controller.dart';
import '../../model/quiz.dart';
import '../../repository/quiz_repository.dart';
import '../../services/quiz_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // ────────────────────────────────────────────────────────
  // 1) 상태 변수 & 컨트롤러 초기화
  // ────────────────────────────────────────────────────────

  // 비즈니스 로직을 담당하는 컨트롤러
  late final QuizController controller;

  // 현재 화면에 표시할 문제 모델 (null 이면 아직 문제 없음)
  //QuizQuestion? currentQuestion;
  QuizQuestion currentQuestion = QuizQuestion(
    question: '로딩중',
    answer: '로딩중',
    hint: '로딩중',
    distractors: [],
    feedbacks: [],
    difficulty: 0,
  );

  // API 요청 중임을 표시할 플래그
  bool isLoading = false;

  // 에러 발생 시 에러 메시지 보관
  String errorMessage = "";

  //
  final TextEditingController _answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // controller 에 Service → Repository → GeminiService 순서로 주입
    controller = QuizController(
      QuizService(
        QuizRepository(GeminiService(apiKey: dotenv.env['geminiApiKey'] ?? "")),
      ),
    );
    _generateQuiz(); //들어오자마자 문제 생성 호출
  }

  // ────────────────────────────────────────────────────────
  // 2) 문제 생성(데이터 요청) 로직
  // ────────────────────────────────────────────────────────

  Future<void> _generateQuiz() async {
    setState(() {
      isLoading = true; // 로딩 시작
      errorMessage = ""; // 이전 에러 초기화
    });

    try {
      // 실제 문제 요청: 컨트롤러가 GeminiService 통해 AI(혹은 백엔드) 호출
      final quiz = await controller.generateQuiz();
      if (quiz == null) {
        setState(() {
          errorMessage = "문제 생성 실패: 서버에서 문제를 받아올 수 없습니다.";
          isLoading = false;
        });
        return;
      } else {
        setState(() {
          // 가져온 QuizQuestion 모델을 화면에 띄움
          currentQuestion = quiz;
        });
      }
    } catch (e) {
      // 에러 발생 시 메시지 저장
      setState(() {
        errorMessage = "문제 생성 실패: ${e.toString()}";
      });
    } finally {
      // 로딩 종료
      setState(() {
        isLoading = false;
      });
    }
  }

  //UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // // 키보드 올라올 때 자동으로 위로 올라가도록
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('퀴즈 풀기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 문제 영역
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 난이도 레이블
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '난이도 ${currentQuestion.difficulty}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 문제 텍스트
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    currentQuestion.question,
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 힌트 / 입력 / 확인
                              Row(
                                children: [
                                  // 힌트 버튼
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text('힌트'),
                                              content: Text(
                                                currentQuestion.hint,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('닫기'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    child: const Text('힌트'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(60, 40),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 답 입력 필드
                                  Expanded(
                                    child: TextField(
                                      controller: _answerCtrl,
                                      decoration: InputDecoration(
                                        hintText: '답 입력', //TODO: 틀렸을때 '답 입력' 대신 정답 초성을 보여줘야 함
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
                                  // 확인 버튼
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: 정답 확인 & 다음 문제 로직 & 틀렸을떄 답 입력 필드에서 초성 보여줘야됨
                                    },
                                    child: const Text('확인'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(60, 40),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // (키보드 영역은 실제 디바이스 키보드가 올라오며, 이 Container 위에 고정되어 있게 됩니다)
                    ],
                  ),
                ),
      ),
    );
  }
}
