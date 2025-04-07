import 'package:flutter/material.dart';

/// 공용 스낵바 출력 함수
void showSavedSnackBar(BuildContext context, {String message = '저장되었습니다!'}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    ),
  );
}
