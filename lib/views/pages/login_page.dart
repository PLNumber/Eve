import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/gen_l10n/app_localizations.dart';
import '../../viewModel/login_view_model.dart';
import 'set_name_page.dart';
import '../../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.login)),
      body: Center(
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) return const CircularProgressIndicator();

            return GestureDetector(
              onTap: () async {
                final userCredential = await viewModel.signInWithGoogle();
                if (userCredential != null) {
                  final uid = userCredential.user?.uid;
                  final userDoc =
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .get();
                  final nickname = userDoc.data()?['nickname'];
                  if (nickname == null ||
                      nickname == uid ||
                      nickname.toString().trim().isEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SetUserPage()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage)),
                  );
                }
              },
              child: Image.asset(
                'assets/images/google.png',
                width: 200,
                height: 50,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}
