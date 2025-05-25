import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../viewModel/option_view_model.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../widgets/option_widget.dart';
import '../widgets/nav_util.dart';

class QuizOptionPage extends StatefulWidget {
  @override
  State<QuizOptionPage> createState() => _QuizOptionPageState();
}

class _QuizOptionPageState extends State<QuizOptionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(local.settings),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: '저장하고 나가기',
            onPressed: () {
              final local = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(local.saved_message),
                  duration: Duration(seconds: 1),
                ),
              );
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.pop(context);
              });
            },

          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildOptionCard(
                  Icons.music_note,
                  local.sound,
                  () => SoundDialog.show(context),
                  textColor,
                ),
                _buildOptionCard(
                  Icons.brightness_6,
                  local.change_background,
                  () => BackgroundDialog.show(context),
                  textColor,
                ),
                _buildOptionCard(
                  Icons.language,
                  local.change_language,
                  () => LanguageDialog.show(context),
                  textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color textColor,
  ) {
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
}
