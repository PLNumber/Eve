/* lib/View/Widgets/nav_util.dart */
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
    builder: (context) => AlertDialog(
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
    builder: (context) => AlertDialog(
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



