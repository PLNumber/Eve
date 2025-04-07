import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final String uid;
  UserModel? user;

  ProfileViewModel(this.uid) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('UserData')
        .doc(uid)
        .get();

    if (snapshot.exists) {
      user = UserModel.fromMap(snapshot.data()!, uid);
    }
    notifyListeners();
  }

  String get accuracyText {
    if (user == null || user!.studyMinutes == 0) {
      return "플레이를 하지 않았습니다.";
    }
    return "${user!.accuracy.toStringAsFixed(2)}%";
  }

  String get studyTimeText {
    if (user == null || user!.studyMinutes == 0) return "0분";
    if (user!.studyMinutes >= 60) {
      int hours = user!.studyMinutes ~/ 60;
      int minutes = user!.studyMinutes % 60;
      return "${hours}시간 ${minutes}분";
    }
    return "${user!.studyMinutes}분";
  }

  void updateAttendance() {
    user!.attendance += 1;
    FirebaseFirestore.instance
        .collection('UserData')
        .doc(uid)
        .update({'attendance': user!.attendance});
    notifyListeners();
  }
}
