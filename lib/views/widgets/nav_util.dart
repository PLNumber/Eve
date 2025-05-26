/* lib/views/widgets/nav_util.dart */
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../l10n/gen_l10n/app_localizations.dart';

/// 공용 스낵바 출력 함수
void showSavedSnackBar(BuildContext context, {String? message}) {
  final local = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? local.saved_message),
      duration: const Duration(milliseconds: 500),
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
  final local = AppLocalizations.of(context)!;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title, style: TextStyle(fontSize: screenWidth * 0.05)),
          content: Text(
            content,
            style: TextStyle(fontSize: screenWidth * 0.03),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                local.cancel,
                style: TextStyle(fontSize: screenWidth * 0.03),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(
                local.confirm,
                style: TextStyle(fontSize: screenWidth * 0.03),
              ),
            ),
          ],
        ),
  );
}

/// ✅ 퀴즈 완료 여부를 묻는 공통 다이얼로그
Future<void> showContinueOrEndDialog(
  BuildContext context, {
  required VoidCallback onContinue,
  required VoidCallback onEnd,
}) async {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  await showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text('정답입니다!', style: TextStyle(fontSize: screenWidth * 0.05)),
          content: Text(
            '다음 문제를 계속 푸시겠습니까? 아니면 종료하시겠습니까?',
            style: TextStyle(fontSize: screenWidth * 0.03),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onEnd();
              },
              child: Text('종료', style: TextStyle(fontSize: screenWidth * 0.03)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onContinue();
              },
              child: Text('계속', style: TextStyle(fontSize: screenWidth * 0.03)),
            ),
          ],
        ),
  );
}
