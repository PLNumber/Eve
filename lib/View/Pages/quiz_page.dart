import 'package:eve/View/Widgets/back_dialog.dart';
import 'package:eve/main.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showExitDialog(context);
      },

      child: Scaffold(
        appBar: AppBar(


          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // 뒤로가기 시 같은 동작 (팝업)
              showExitDialog(context);
            },
          ),

          title: const Text("퀴즈페이지임", textAlign: TextAlign.center),

          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // 설정 팝업 혹은 이동
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(16),
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("퀴즈 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("예: 타이머 on/off, 난이도 설정 등"),
                        // 여기에 설정 위젯 추가
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          centerTitle: true,
        ),

        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
