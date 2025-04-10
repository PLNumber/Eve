import 'package:eve/View/Widgets/back_dialog.dart';
import 'package:eve/View/Widgets/back_util.dart';
import 'package:flutter/material.dart';
import '../../Services/auth_service.dart';
import 'login_page.dart';

//퀴즈 페이지

class OptionPage extends StatefulWidget {
  @override
  _OptionPage createState() => _OptionPage();
}

class _OptionPage extends State<OptionPage> {
  AuthService _authService = AuthService();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        // 🔽 SnackBar로 메시지 보여주기
        // 🔽 잠깐 보여주고 나서 페이지 뒤로 가기
        showSnackAndNavigateBack(context);
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text("옵션"),
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  // 🔽 SnackBar로 메시지 보여주기
                  // 🔽 잠깐 보여주고 나서 페이지 뒤로 가기
                  showSnackAndNavigateBack(context);
                },
              );
            },
          ),
        ),

        // body: Center(child: CircularProgressIndicator()),
        body: ListView(
          children: [

            //로그아웃 기능 일단 구현
            ListTile(
              title: Text("로그아웃"),
              onTap: () {
                showConfirmDialog(
                  context,
                  title: '로그아웃 및 종료',
                  content: '정말로 로그아웃을 하시겠습니까?',
                  onConfirm: () {
                    _authService.signOutAndExit();
                  },
                );
              },
            ),




          ],
        ),
      ),
    );
  }
}
