//lib/views/pages/set_name_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../widgets/nav_util.dart';

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
    final local = AppLocalizations.of(context)!;
    final inputName = _nicknameController.text.trim();

    if (!_validateNickname(inputName)) {
      setState(() {
        _isDuplicate = null;
        _checkMessage = local.invalidNicknameFormat;
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
      _checkMessage = isTaken ? local.nicknameDuplicateExists : local.nicknameAvailable;
    });
  }


  Future<void> _saveNickname() async {
    final local = AppLocalizations.of(context)!;
    final nickname = _nicknameController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (!_validateNickname(nickname) || _isDuplicate != false || user == null) {
      showSavedSnackBar(context, message: local.nicknameCheckError);
      return;
    }

    setState(() => _isSaving = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'nickname': nickname,
    });

    showSavedSnackBar(context, message: local.nicknameSaved);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showConfirmDialog(
          context,
          title: local.exit,
          content: local.confirm_exit,
          onConfirm: () {
            SystemNavigator.pop();
          },
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Scaf
        appBar: AppBar(
          title: Text(local.setNicknameTitle),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(local.promptEnterNickname, style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: local.exampleNickname,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkNicknameDuplicate,
                child: Text(AppLocalizations.of(context)!.check_duplicate),
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
                child: Text(local.saveAndStart),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),

      ),
    );
  }
}
