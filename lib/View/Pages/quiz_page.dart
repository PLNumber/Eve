// import 'package:eve/View/Widgets/back_dialog.dart';
// import 'package:flutter/material.dart';
//
// class QuizPage extends StatefulWidget {
//   @override
//   _QuizPageState createState() => _QuizPageState();
// }
//
// class _QuizPageState extends State<QuizPage> {
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (bool didPop, Object? result) {
//         if (didPop) return;
//         showExitDialog(context);
//       },
//
//       child: Scaffold(
//         appBar: AppBar(
//
//
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () {
//               // 뒤로가기 시 같은 동작 (팝업)
//               showExitDialog(context);
//             },
//           ),
//
//           title: const Text("퀴즈페이지임", textAlign: TextAlign.center),
//
//           actions: [
//             IconButton(
//               icon: Icon(Icons.settings),
//               onPressed: () {
//                 // 설정 팝업 혹은 이동
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (context) => Container(
//                     padding: const EdgeInsets.all(16),
//                     height: 200,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("퀴즈 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                         SizedBox(height: 10),
//                         Text("예: 타이머 on/off, 난이도 설정 등"),
//                         // 여기에 설정 위젯 추가
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//           centerTitle: true,
//         ),
//
//         body: Center(child: CircularProgressIndicator()),
//       ),
//     );
//   }
// }
// lib/view/quiz_page.dart
// lib/view/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/quiz_view_model.dart';


class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  // 개발자가 수정할 수 있는 프롬프트 상수
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
            // 프롬프트 입력란 없이, 버튼 클릭 시 상수 promptTemplate 사용
            quizViewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                await quizViewModel.generateQuizForRandomVocab(promptTemplate);
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


