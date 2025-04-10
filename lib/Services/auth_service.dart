// lib/service/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<UserCredential> signInWithGoogle() async {
    // 구글 로그인 UI 호출
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception("사용자가 구글 로그인을 취소했습니다.");
    }

    // 구글 인증 정보 획득
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Firebase에 전달할 자격증명 생성
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase 로그인 수행
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}