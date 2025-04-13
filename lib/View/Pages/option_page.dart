// ✅ lib/view/pages/option_page.dart 다국어 적용
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/gen_l10n/app_localizations.dart';

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
          title: Text(AppLocalizations.of(context)!.settings),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => showSnackAndNavigateBack(context),
          ),
        ),
        body: ListView(
          children: [
            
            //소리 설정
            OptionTile(
              title: AppLocalizations.of(context)!.sound,
              onTap: () => _showSimpleSnack(context, "소리 설정은 나중에 업데이트 예정!"),
            ),
            
            //초기화 설정
            OptionTile(
              title: AppLocalizations.of(context)!.reset_history,
              onTap: () => _showSimpleSnack(context, "초기화 설정은 나중에 업데이트 예정!"),
            ),
            
            // 배경 설정
            OptionTile(
              title: AppLocalizations.of(context)!.change_background,
              onTap: () => BackgroundDialog.show(context),
            ),
            
            //언어 설정
            OptionTile(
              title: AppLocalizations.of(context)!.change_language,
              onTap: () => LanguageDialog.show(context),
            ),
            
            // 이름 변경
            OptionTile(
              title: AppLocalizations.of(context)!.nickname_change,
              onTap: () => NicknameDialog.show(context),
            ),
            
            // 로그아웃
            OptionTile(
              title: AppLocalizations.of(context)!.logout,
              onTap: () {
                showConfirmDialog(
                  context,
                  title: AppLocalizations.of(context)!.logout,
                  content: AppLocalizations.of(context)!.confirm_logout,
                  onConfirm: () => optionViewModel.signOutAndExit(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //임시용
  void _showSimpleSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
