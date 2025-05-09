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

  // 답 입력 필드에 hintText에 들어갈 str
  String answerHintText = '답 입력';

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
                                  // 확인 버튼
                                  //TODO: showdialog로 피드백 보여줘야됨 - 1)오답에 대한 피드백 있으면 그냥 보여줌 2)없는경우(이건 service, repositroy에 구현)
                                  ElevatedButton(
                                    onPressed: () async{
                                      final input = _answerCtrl.text.trim();
                                      //정답 확인
                                      if (input == currentQuestion.answer){
                                        // 맞았을 때: 입력 초기화, hintText 리셋, 다음 문제 로드
                                        _answerCtrl.clear();
                                        setState(()=> answerHintText = '답 입력');
                                        await _generateQuiz();
                                      } else{
                                        // 틀렸을 때: 입력 초기화, 초성 hint로 변경
                                        _answerCtrl.clear();
                                        final initialHint = _extractInitialHint(currentQuestion.answer);
                                        setState(()=> answerHintText = initialHint);
                                      }
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

  //초성 찾는 코드
  String _extractInitialHint(String text){
    const CHO = ['ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
    return text.split('').map((c) {
      final code = c.codeUnitAt(0);
      if(code >= 0xAC00 && code <= 0xD7A3){
        final diff = code - 0xAC00;
        final idx = diff ~/ (21 * 28);
        return CHO[idx];
      }
      return c;
    }).join();
  }
}

//Todo: 오답시 피드백 없는경우 생성하는건 servie, repository에서 구현 필요
//Todo: 사용자 정보 갱신도 servie, repository에서 구현 필요