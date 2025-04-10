// lib/view_model/login_view_model.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String errorMessage = '';

  /// 구글 로그인을 호출하는 메서드
  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      return userCredential;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}