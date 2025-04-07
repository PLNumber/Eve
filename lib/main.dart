import 'package:eve/Pages/quizPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


//메인 페이지

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  QuizPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  
  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {

    throw UnimplementedError();
  }
  
}