import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart'; // 또는 정확한 상대경로


import '../../ViewModel/option_view_model.dart';
import '../../provider/local_provider.dart';
import '../Widgets/nav_util.dart';
import '../Widgets/option_widget.dart';

class OptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final optionViewModel = Provider.of<OptionViewModel>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showSnackAndNavigateBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("설정"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              showSnackAndNavigateBack(context);
            },
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text("소리 설정"),
              onTap: () => _showSimpleSnack(context, "소리 설정은 나중에 업데이트 예정!"),
            ),
            ListTile(
              title: Text("초기화 설정"),
              onTap: () => _showSimpleSnack(context, "초기화 설정은 나중에 업데이트 예정!"),
            ),
            ListTile(
              title: Text("배경 설정"),
              onTap: () => _showSimpleSnack(context, "배경 설정은 나중에 업데이트 예정!"),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.change_language),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => SimpleDialog(
                    title: Text("언어 선택"),
                    children: [
                      SimpleDialogOption(
                        child: Text("한국어"),
                        onPressed: () {
                          Provider.of<LocaleProvider>(context, listen: false)
                              .setLocale("ko");
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("English"),
                        onPressed: () {
                          Provider.of<LocaleProvider>(context, listen: false)
                              .setLocale("en");
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              title: Text("이름 변경"),
              onTap: () => NicknameDialog.show(context),
            ),
            ListTile(
              title: Text("로그아웃"),
              onTap: () {
                showConfirmDialog(
                  context,
                  title: '로그아웃 및 종료',
                  content: '정말로 로그아웃을 하시겠습니까?',
                  onConfirm: () {
                    optionViewModel.signOutAndExit();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSimpleSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
  }
}
