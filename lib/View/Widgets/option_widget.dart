// lib/View/Widgets/option_widget.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Services/auth_service.dart';
import 'back_util.dart';

class NicknameDialog {
  static void show(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final AuthService _authService = AuthService();
    String message = '';
    bool? isAvailable;

    void checkNickname(BuildContext dialogContext) async {
      final nickname = _controller.text.trim();

      final isValid = RegExp(r'^[가-힣a-zA-Z0-9]{2,10}$').hasMatch(nickname);
      if (!isValid) {
        isAvailable = null;
        message = "닉네임은 2~10자, 한글/영문/숫자만 가능합니다.";
        (dialogContext as Element).markNeedsBuild(); // 강제 리빌드
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .get();

      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final taken = query.docs.any((doc) => doc.id != currentUid);

      isAvailable = !taken;
      message = taken ? "이미 사용 중인 닉네임입니다." : "사용 가능한 닉네임입니다!";
      (dialogContext as Element).markNeedsBuild();
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("닉네임 변경"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "새 닉네임 입력",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => checkNickname(context),
                  child: const Text("중복 확인"),
                ),
                const SizedBox(height: 6),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      color: isAvailable == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("확인"),
            onPressed: () async {
              final nickname = _controller.text.trim();
              if (isAvailable != true) {
                showSavedSnackBar(context, message: "닉네임 확인을 완료해주세요.");
                return;
              }
              await _authService.updateNickname(nickname);
              Navigator.pop(context);
              showSavedSnackBar(context, message: "닉네임이 변경되었습니다!");
            },
          ),
        ],
      ),
    );
  }
}