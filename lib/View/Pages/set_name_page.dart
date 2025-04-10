// lib/View/Pages/set_name_page.dart
import 'package:flutter/material.dart';
import 'package:eve/View/Widgets/back_dialog.dart';
import 'package:flutter/services.dart';
import '../../main.dart';

class SetUserPage extends StatefulWidget {
  @override
  _SetUserPage createState() => _SetUserPage();
}

class _SetUserPage extends State<SetUserPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showConfirmDialog(
          context,
          title: "앱 종료",
          content: '정말 앱을 종료하시겠습니까?',
          onConfirm: () {
            SystemNavigator.pop();
          },
        );
      },

      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // 뒤로가기 시 같은 동작 (팝업)
              showConfirmDialog(
                context,
                title: "앱 종료",
                content: '정말 앱을 종료하시겠습니까?',
                onConfirm: () {
                  SystemNavigator.pop();
                },
              );
            },
          ),

          title: const Text("사용자 이름 설정", textAlign: TextAlign.center),

          actions: [
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                // 설정 팝업 혹은 이동
                showConfirmDialog(
                  context,
                  title: "건너뛰기",
                  content: '정말 닉네임을 설정하지 않고 건너뛰기 하시겠습니까?',
                  onConfirm: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  },
                );
              },
            ),
          ],
          centerTitle: true,
        ),

        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
