import 'package:flutter/material.dart';

//퀴즈 페이지

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text('퀴즈페이지 임'),
          centerTitle: true,
        ),

        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
