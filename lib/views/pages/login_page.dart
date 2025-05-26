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
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                // 1/4 화면 빈 공간
                Spacer(flex: 1),

                // 로고 이미지 (가로의 40% 크기)
                Center(
                  child: Image.asset(
                    'assets/images/appImage.png',
                    width: screenW * 0.4,
                    height: screenW * 0.4,
                    fit: BoxFit.contain,
                  ),
                ),

                // 로고 아래 약간의 여백
                Spacer(flex: 2),
                // 구글 로그인 버튼
                SafeArea(
                  child: ElevatedButton(
                    onPressed: () async {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 16,
                            child: Image.asset(
                              'assets/images/google.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.startWithGoogle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 버튼 아래 여백
                Spacer(flex: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}
