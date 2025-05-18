/* lib/views/widgets/nav_util.dart */
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../l10n/gen_l10n/app_localizations.dart';

/// 공용 뒤로가기 SnackBar + 뒤로 이동 함수
void showSnackAndNavigateBack(BuildContext context, {String? message}) {
  final local = AppLocalizations.of(context)!;
  showSavedSnackBar(context, message: message ?? local.saved_message);
  Future.delayed(const Duration(milliseconds: 500), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  });
}

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

/// 공용 뒤로가기/종료 다이얼로그
Future<void> showExitDialog(BuildContext context) async {
  final local = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(local.exit),
          content: Text(local.confirm_exit_quiz),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(local.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              child: Text(local.confirm),
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
  final local = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(local.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(local.confirm),
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
  await showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('정답입니다!'),
          content: const Text('다음 문제를 계속 푸시겠습니까? 아니면 종료하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onEnd();
              },
              child: const Text('종료'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onContinue();
              },
              child: const Text('계속'),
            ),
          ],
        ),
  );
}
