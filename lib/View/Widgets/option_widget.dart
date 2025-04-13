// lib/View/Widgets/option_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../provider/local_provider.dart';
import '../../provider/theme_provider.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.change_background),
        children: [
          SimpleDialogOption(
            child: Text(AppLocalizations.of(context)!.default_background),
            onPressed: () {
              themeProvider.setTheme(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: Text(AppLocalizations.of(context)!.dark_background),
            onPressed: () {
              themeProvider.setTheme(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}


// 닉네임 다이얼로그
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
      message = result ?? AppLocalizations.of(context)!.nickname_available;
      (dialogContext as Element).markNeedsBuild(); // 강제 리빌드
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.change_nickname),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.nickname_placeholder,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => checkNickname(context),
                  child: Text(AppLocalizations.of(context)!.check_duplicate),
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
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.confirm),
            onPressed: () async {
              final nickname = _controller.text.trim();
              if (isAvailable != true) {
                showSavedSnackBar(context, message: AppLocalizations.of(context)!.nickname_check_prompt);
                return;
              }

              await viewModel.updateNickname(nickname);
              Navigator.pop(context);
              showSavedSnackBar(context, message: AppLocalizations.of(context)!.nickname_success);
            },
          ),
        ],
      ),
    );
  }
}
