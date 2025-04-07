import 'package:eve/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/*구글 로그인만 따지자*/

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // 로그인 성공 시
            if(snapshot.hasData) {
              return MainPage();
            }
            //실패 시
            else {
              return MainPage();
            }
          }
      )
    );
  }
}
