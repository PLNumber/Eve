import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/option_view_model.dart';
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
              title: Text("언어 설정"),
              onTap: () => _showSimpleSnack(context, "언어 설정은 나중에 업데이트 예정!"),
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
