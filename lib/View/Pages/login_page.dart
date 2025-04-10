// lib/view/login_page.dart

import 'package:eve/View/Pages/set_name_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                  // 닉네임 확인
                  final uid = userCredential.user?.uid;
                  final userDoc =
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .get();
                  final nickname = userDoc.data()?['nickname'];
                  final user = userCredential.user;

                  if (nickname == null || nickname == user?.uid || nickname.toString().trim().isEmpty) {
                    // 닉네임이 없으면 닉네임 설정 페이지로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SetUserPage()),
                    );
                  } else {
                    // 닉네임이 있으면 메인 페이지로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  }
                } else {
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
