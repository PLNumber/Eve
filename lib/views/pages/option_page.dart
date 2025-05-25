// ✅ option_page.dart: 사용자 경험치 진행 바 + 레벨별 프로필 이미지 적용
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
  int _level = 1;
  int _exp = 0;
  final int _maxExp = 100;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
    final data = doc.data() ?? {};

    final local = AppLocalizations.of(context)!;
    setState(() {
      _nickname = data['nickname'] ?? local.noNickname;
      _email = user.email ?? local.noEmail;
      _level = data['level'] ?? 1;
      _exp = data['experience'] ?? 0;
    });

    if (mounted && data['level'] != null && data['level'] > _level) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(local.levelUpMessage)));
      });
    }
  }

  String getProfileImage(int level) {
    if (level >= 5) return 'assets/images/profile_level_5.png';
    return 'assets/images/profile_level_$level.png';
  }

  @override
  Widget build(BuildContext context) {
    final optionViewModel = Provider.of<OptionViewModel>(
      context,
      listen: false,
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(local.settings, style: TextStyle(color: textColor, fontSize: screenWidth * 0.055)),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.indigoAccent,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight*0.03),
          _buildProfileSection(context,textColor, subTextColor!),
          SizedBox(height: screenHeight * 0.001),
          _buildExpBar(context),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildOptionCard(
                  context,
                  Icons.music_note,
                  local.sound,
                  () => SoundDialog.show(context),
                  textColor,
                ),
                _buildOptionCard(context,Icons.restore, local.reset_history, () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: Text(local.resetDialogTitle),
                          content: Text(local.resetDialogContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(local.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(local.reset_history),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true && uid != null) {
                    await optionViewModel.resetUserStats(uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(local.historyCleared)),
                    );
                    _loadUserInfo();
                  }
                }, textColor),
                _buildOptionCard(
                  context,
                  Icons.brightness_6,
                  local.change_background,
                  () => BackgroundDialog.show(context),
                  textColor,
                ),
                _buildOptionCard(
                  context,
                  Icons.language,
                  local.change_language,
                  () => LanguageDialog.show(context),
                  textColor,
                ),
                _buildOptionCard(
                  context,
                  Icons.person,
                  local.nickname_change,
                  () => NicknameDialog.show(context),
                  textColor,
                ),
                _buildOptionCard(context,Icons.logout, local.logout, () {
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

  Widget _buildProfileSection(BuildContext context,Color textColor, Color subTextColor) {
    final local = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: CircleAvatar(
            key: ValueKey<int>(_level),
            radius: screenWidth*0.1,
            backgroundImage: AssetImage(getProfileImage(_level)),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          _nickname,
          style: TextStyle(
            fontSize: screenHeight * 0.03,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: screenHeight * 0.001),
        Text(_email, style: TextStyle(color: subTextColor, fontSize: screenWidth * 0.02)),
        SizedBox(height: screenHeight * 0.04),
        Text(
          local.levelLabel(_level),
          style: TextStyle(fontSize: screenHeight * 0.015, color: textColor),
        ),
      ],
    );
  }

  Widget _buildExpBar(BuildContext context) {

    final local = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.expProgress(_exp, _maxExp),
            style: TextStyle(fontSize: screenWidth * 0.02),
          ),
          SizedBox(height: screenHeight * 0.01),
          LinearProgressIndicator(
            value: _exp / _maxExp,
            minHeight: screenHeight * 0.01,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    Color textColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.005),
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo, size: screenWidth * 0.06,),
        title: Text(title, style: TextStyle(color: textColor,fontSize: screenWidth * 0.025)),
        trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.025, color: textColor),
        onTap: onTap,
      ),
    );
  }
}
