/* lib/View/Widgets/back_util.dart */
import 'package:flutter/material.dart';
import '../../main.dart';

/// 공용 뒤로가기 SnackBar + 뒤로 이동 함수
void showSnackAndNavigateBack(BuildContext context, {String message = '저장되었습니다!'}) {
  showSavedSnackBar(context, message: message);
  Future.delayed(Duration(milliseconds: 1000), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  });
}

/// 공용 스낵바 출력 함수
void showSavedSnackBar(BuildContext context, {String message = '저장되었습니다!'}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    ),
  );
}
