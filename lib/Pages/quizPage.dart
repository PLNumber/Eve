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
    return Scaffold(
      appBar: AppBar(
        title: Text('문해력 퀴즈'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }


}
