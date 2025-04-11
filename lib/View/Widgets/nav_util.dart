/* lib/View/Widgets/nav_util.dart */
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


/// 공용 뒤로가기/종료 다이얼로그
Future<void> showExitDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
      title: const Text("종료"),
      content: const Text("정말 퀴즈를 종료하시겠습니까?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
          child: const Text("확인"),
        ),
      ],
    ),
  );
}

/// 커스텀 다이얼로그 (옵션)
Future<void> showConfirmDialog(
    BuildContext context, {
      required String title,
      required String content,
      required VoidCallback onConfirm,
    }) async {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text("확인"),
        ),
      ],
    ),
  );
}




