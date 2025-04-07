// views/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/login_view_model.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final user = loginVM.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('환영합니다, ${user?.displayName ?? '사용자'}님'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await loginVM.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          '로그인 성공! 이메일: ${user?.email}',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
