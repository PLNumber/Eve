// viewmodels/login_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  LoginViewModel() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> loginWithGoogle() async {
    final userCredential = await _authService.signInWithGoogle();
    return userCredential != null;
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
