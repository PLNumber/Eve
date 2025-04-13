// lib/View/Widgets/option_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../provider/local_provider.dart';
import 'nav_util.dart';
import '../../ViewModel/option_view_model.dart';

//옵션 타일
class OptionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const OptionTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}

// 언어 다이얼로그
class LanguageDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.language_selection),
        children: [
          SimpleDialogOption(
            child: Text(AppLocalizations.of(context)!.korean),
            onPressed: () {
              Provider.of<LocaleProvider>(context, listen: false).setLocale("ko");
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: Text(AppLocalizations.of(context)!.english),
            onPressed: () {
              Provider.of<LocaleProvider>(context, listen: false).setLocale("en");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}


// 배경 다이얼로그
class BackgroundDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.change_background),
        children: [
          SimpleDialogOption(
            child: Text(AppLocalizations.of(context)!.default_background),
            onPressed: () {
              //TODO : 배경 설정 해야함
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: Text(AppLocalizations.of(context)!.dark_background),
            onPressed: () {
              // TODO: 배경 설정해야함
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}



class NicknameDialog {
  static void show(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final viewModel = Provider.of<OptionViewModel>(context, listen: false);

    String message = '';
    bool? isAvailable;

    void checkNickname(BuildContext dialogContext) async {
      final nickname = _controller.text.trim();
      final result = await viewModel.checkNicknameAvailable(nickname);

      isAvailable = result == null;
      message = result ?? "사용 가능한 닉네임입니다!";
      (dialogContext as Element).markNeedsBuild(); // 강제 리빌드
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("닉네임 변경"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "새 닉네임 입력",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => checkNickname(context),
                  child: const Text("중복 확인"),
                ),
                const SizedBox(height: 6),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      color: isAvailable == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("확인"),
            onPressed: () async {
              final nickname = _controller.text.trim();
              if (isAvailable != true) {
                showSavedSnackBar(context, message: "닉네임 확인을 완료해주세요.");
                return;
              }

              await viewModel.updateNickname(nickname);
              Navigator.pop(context);
              showSavedSnackBar(context, message: "닉네임이 변경되었습니다!");
            },
          ),
        ],
      ),
    );
  }
}
