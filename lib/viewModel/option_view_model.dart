// lib/viewModel/option_view_model.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Services/auth_service.dart';
import '../repository/quiz_repository.dart';

class OptionViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final QuizRepository _quizRepository;

  OptionViewModel(this._quizRepository);

  QuizRepository get quizRepository => _quizRepository;

  Future<void> resetUserStats(String uid) async {
    await _quizRepository.resetUserStats(uid);
  }

  Future<void> signOutAndExit() async {
    await _authService.signOutAndExit();
  }

  Future<void> updateNickname(String newNickname) async {
    await _authService.updateNickname(newNickname);
    notifyListeners();
  }

  /// ✅ 닉네임 중복 확인 및 유효성 검사
  Future<String?> checkNicknameAvailable(String nickname) async {
    final isValid = RegExp(r'^[가-힣a-zA-Z0-9]{2,10}$').hasMatch(nickname);
    if (!isValid) return "닉네임은 2~10자, 한글/영문/숫자만 가능합니다.";

    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('nickname', isEqualTo: nickname)
            .get();

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isTaken = query.docs.any((doc) => doc.id != currentUid);

    return isTaken ? "이미 사용 중인 닉네임입니다." : null;
  }
}
