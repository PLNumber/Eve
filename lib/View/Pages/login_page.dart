// views/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ViewModel/login_view_model.dart';
import '../Widgets/squaretitle.dart';
import '../../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories, size: 100),
              const SizedBox(height: 50),
              Text('LexiUp에 오신 것을 환영합니다!', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 50),
              SquareTitle(
                onTap: () async {
                  final success = await loginVM.loginWithGoogle();
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인에 실패했거나 취소되었습니다.')),
                    );
                  }
                },
                imagePath: 'assets/images/google.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
