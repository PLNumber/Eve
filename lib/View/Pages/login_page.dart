// lib/view/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/login_view_model.dart';
import '../../main.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인 페이지")),
      body: Center(
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            // 로딩 상태면 CircularProgressIndicator 표시
            if (viewModel.isLoading) {
              return const CircularProgressIndicator();
            }
            return ElevatedButton(
              onPressed: () async {
                final userCredential = await viewModel.signInWithGoogle();
                if (userCredential != null) {
                  // 로그인 성공 시 MainPage로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                } else {
                  // 에러 메시지가 있으면 스낵바로 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage)),
                  );
                }
              },
              child: const Text("구글로 로그인"),
            );
          },
        ),
      ),
    );
  }
}
