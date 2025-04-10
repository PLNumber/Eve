import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../Widgets/back_util.dart';

class SetUserPage extends StatefulWidget {
  @override
  _SetUserPage createState() => _SetUserPage();
}

class _SetUserPage extends State<SetUserPage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isSaving = false;
  bool? _isDuplicate; // null = 아직 확인 안함, true = 중복, false = 사용 가능
  String _checkMessage = "";

  bool _validateNickname(String nickname) {
    final regex = RegExp(r'^[가-힣a-zA-Z0-9]+$'); // 한글, 영문, 숫자만 허용
    return regex.hasMatch(nickname) && nickname.length >= 2 && nickname.length <= 10;
  }


  Future<void> _checkNicknameDuplicate() async {
    final inputName = _nicknameController.text.trim();

    if (!_validateNickname(inputName)) {
      setState(() {
        _isDuplicate = null;
        _checkMessage = "닉네임은 2~10자, 한글/영문/숫자만 가능합니다.";
      });
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('nickname', isEqualTo: inputName)
        .get();

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isTaken = query.docs.any((doc) => doc.id != currentUid);

    setState(() {
      _isDuplicate = isTaken;
      _checkMessage = isTaken ? "이미 사용 중인 닉네임입니다." : "사용 가능한 닉네임입니다!";
    });
  }


  Future<void> _saveNickname() async {
    final nickname = _nicknameController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (!_validateNickname(nickname) || _isDuplicate != false || user == null) {
      showSavedSnackBar(context, message: "닉네임을 확인해주세요.");
      return;
    }

    setState(() => _isSaving = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'nickname': nickname,
    });

    showSavedSnackBar(context, message: "닉네임이 저장되었습니다!");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showConfirmDialog(
          context,
          title: "앱 종료",
          content: '정말 앱을 종료하시겠습니까?',
          onConfirm: () {
            SystemNavigator.pop();
          },
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Scaf
        appBar: AppBar(
          title: const Text("닉네임 설정"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Text("닉네임을 입력해주세요", style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: "예: 어휘왕123",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkNicknameDuplicate,
                child: Text("중복 확인"),
              ),
              const SizedBox(height: 8),
              if (_checkMessage.isNotEmpty)
                Text(
                  _checkMessage,
                  style: TextStyle(
                    color: _isDuplicate == false ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveNickname,
                child: const Text("저장하고 시작하기"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),

      ),
    );
  }
}
