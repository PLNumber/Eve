// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Model/user_model.dart';

class AuthService {
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

    await _saveUserDataToFirestore(userCredential);
    return userCredential;
  }

  Future<void> _saveUserDataToFirestore(UserCredential userCredential) async {
    final userDoc = FirebaseFirestore.instance
        .collection('UserData')
        .doc(userCredential.user!.uid);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'Player',
        bio: '',
        level: 1,
        accuracy: 0,
        studyMinutes: 0,
        attendance: 0,
      );

      await userDoc.set(newUser.toMap());
    }
  }


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
