// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// ✅ 구글 로그인 및 사용자 등록 처리
  Future<UserCredential> signInWithGoogle() async {
    // 1. 구글 로그인 UI 호출
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("사용자가 구글 로그인을 취소했습니다.");
    }

    // 2. 구글 인증 정보 획득
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3. Firebase 자격증명 생성
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Firebase 로그인 수행
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) throw Exception("Firebase 사용자 정보가 없습니다.");

    // 5. Firestore에 사용자 정보 등록 또는 업데이트
    final userDoc = _firestore.collection("users").doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      // 신규 사용자: 초기 데이터 등록
      await userDoc.set({
        "nickname": user.uid,
        "level": 1,
        "experience": 0,
        "totalSolved": 0,
        "correctSolved": 0,
        "consecutiveAttendance": 0,
        "wordHistory": [],
        "incorrectWords": [],
        "reviewProgress": {},
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      // 기존 사용자: 마지막 로그인 시간만 갱신
      await userDoc.update({
        "lastLogin": FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  /// ✅ 닉네임 업데이트
  Future<void> updateNickname(String newNickname) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'nickname': newNickname,
      });
    }
  }

  /// ✅ 현재 사용자 닉네임 가져오기
  Future<String> getNickname() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      return snapshot.data()?['nickname'] ?? '닉네임 없음';
    }
    return '로그인 안 됨';
  }

  /// ✅ 로그아웃 및 앱 종료
  Future<void> signOutAndExit() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      SystemNavigator.pop(); // 앱 종료
    } catch (error) {
      print("로그아웃 실패: $error");
    }
  }
}
