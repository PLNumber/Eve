// // views/login_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../ViewModel/login_view_model.dart';
// import '../Widgets/squaretitle.dart';
// import '../../main.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final loginVM = Provider.of<LoginViewModel>(context, listen: false);

//     return Scaffold(
//       backgroundColor: Colors.grey[300],
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.auto_stories, size: 100),
//               const SizedBox(height: 50),
//               Text('LexiUp에 오신 것을 환영합니다!', style: TextStyle(fontSize: 20)),
//               const SizedBox(height: 50),
//               SquareTitle(
//                 onTap: () async {
//                   final success = await loginVM.loginWithGoogle();
//                   if (success) {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => MainPage()),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('로그인에 실패했거나 취소되었습니다.')),
//                     );
//                   }
//                 },
//                 imagePath: 'assets/images/google.png',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  /// 구글 로그인 처리를 수행하는 함수
  Future<UserCredential> signInWithGoogle() async {
    // 1. 구글 로그인 UI 호출
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // 사용자가 로그인 취소한 경우
    if (googleUser == null) {
      throw Exception("사용자가 구글 로그인을 취소했습니다.");
    }

    // 2. 구글 인증 정보 획득
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3. Firebase에 전달할 자격증명 생성
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Firebase 로그인 수행
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인 페이지"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // 구글 로그인 처리
              final userCredential = await signInWithGoogle();
              debugPrint("로그인 성공: ${userCredential.user?.displayName}");
              // 로그인 성공 후 MainPage()로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            } catch (e) {
              debugPrint("로그인 실패: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("로그인 실패: $e")),
              );
            }
          },
          child: const Text("구글로 로그인"),
        ),
      ),
    );
  }
}

// 예시 MainPage 구현
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("메인 페이지"),
      ),
      body: const Center(
        child: Text("환영합니다!"),
      ),
    );
  }
}

