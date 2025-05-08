// lib/views/pages/option_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../viewModel/option_view_model.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../widgets/option_widget.dart';
import '../widgets/nav_util.dart';

class OptionPage extends StatefulWidget {
  @override
  State<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  String _nickname = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    setState(() {
      _nickname = doc.data()?['nickname'] ?? "닉네임 없음";
      _email = user.email ?? "이메일 없음";
    });
  }

  @override
  Widget build(BuildContext context) {
    final optionViewModel = Provider.of<OptionViewModel>(context, listen: false);
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(local.settings, style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.indigoAccent,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          _buildProfileSection(textColor, subTextColor!),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildOptionCard(Icons.music_note, local.sound, () => SoundDialog.show(context), textColor),
                _buildOptionCard(Icons.restore, local.reset_history,
                        () => _showSimpleSnack(context, "초기화 기능은 나중에 추가될 예정입니다."), textColor),
                _buildOptionCard(Icons.brightness_6, local.change_background,
                        () => BackgroundDialog.show(context), textColor),
                _buildOptionCard(Icons.language, local.change_language,
                        () => LanguageDialog.show(context), textColor),
                _buildOptionCard(Icons.person, local.nickname_change,
                        () => NicknameDialog.show(context), textColor),
                _buildOptionCard(Icons.logout, local.logout, () {
                  showConfirmDialog(
                    context,
                    title: local.logout,
                    content: local.confirm_logout,
                    onConfirm: () => optionViewModel.signOutAndExit(),
                  );
                }, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(Color textColor, Color subTextColor) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage("assets/images/profile.png"),
        ),
        const SizedBox(height: 12),
        Text(
          _nickname,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          style: TextStyle(color: subTextColor),
        ),
      ],
    );
  }

  Widget _buildOptionCard(IconData icon, String title, VoidCallback onTap, Color textColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
        onTap: onTap,
      ),
    );
  }

  void _showSimpleSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
