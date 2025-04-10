// lib/service/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // 로그인 후 Firestore에 사용자 정보 저장
    await _createOrUpdateUser(userCredential.user);
    return userCredential;
  }

  Future<void> _createOrUpdateUser(User? user) async {
    if (user == null) return;

    final userDoc = _firestore.collection("users").doc(user.uid);

    // 사용자가 이미 존재하는지 확인
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      // 신규 사용자 생성 시, 기본 닉네임은 user.uid로 설정
      await userDoc.set({
        "nickname": user.uid, // 구글 계정 UID를 닉네임으로 사용
        "level": 1,
        "experience": 0,
        "totalSolved": 0,
        "correctSolved": 0,
        "consecutiveAttendance": 0,
        "wordHistory": [],
        "incorrectWords": [],
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      // 기존 사용자라면 마지막 로그인 시간만 업데이트
      await userDoc.update({
        "lastLogin": FieldValue.serverTimestamp(),
      });
    }
  }
}
