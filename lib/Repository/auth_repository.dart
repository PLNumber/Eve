import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getUserDoc(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      "nickname": user.uid,
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
  }

  Future<void> updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      "lastLogin": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNickname(String uid, String newNickname) async {
    await _firestore.collection('users').doc(uid).update({
      'nickname': newNickname,
    });
  }

  Future<String?> getNickname(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data()?['nickname'];
  }
}
