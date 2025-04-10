// lib/View/Widgets/option_widget.dart
import 'package:flutter/material.dart';
import 'package:eve/Services/auth_service.dart';
import 'back_util.dart'; // showSavedSnackBar 등 사용

class NicknameDialog {
  static void show(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final AuthService _authService = AuthService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("닉네임 변경"),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "새 닉네임 입력"),
        ),
        actions: [
          TextButton(
            child: Text("취소"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("확인"),
            onPressed: () async {
              final newName = _controller.text.trim();
              if (newName.isNotEmpty) {
                await _authService.updateNickname(newName);
                Navigator.pop(context);
                showSavedSnackBar(context, message: "닉네임이 변경되었습니다!");
              } else {
                showSavedSnackBar(context, message: "닉네임을 입력해주세요.");
              }
            },
          ),
        ],
      ),
    );
  }
}
