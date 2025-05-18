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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 상단: 로고 또는 타이틀
                Column(
                  children: [
                    const SizedBox(height: 80), // 상단 여백
                    Image(
                      image: AssetImage('assets/images/appImage.png'),
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),

                // Google 로그인 버튼
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ElevatedButton(
                      onPressed: () async {
                        final userCredential =
                        await viewModel.signInWithGoogle();
                        if (userCredential != null) {
                          final uid = userCredential.user?.uid;
                          final userDoc = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .get();
                          final nickname = userDoc.data()?['nickname'];
                          if (nickname == null ||
                              nickname == uid ||
                              nickname.toString().trim().isEmpty) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SetUserPage()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MainPage()),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(viewModel.errorMessage)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        padding: EdgeInsets.zero,              // 기본 패딩 삭제
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: SizedBox(
                        height: 50,                            // 기존 minimumSize 높이와 같게
                        width: double.infinity,                // 가로 꽉 채우기
                        child: Stack(
                          alignment: Alignment.center,         // 텍스트는 가운데
                          children: [
                            // 왼쪽 끝에 로고 고정
                            const Positioned(
                              left: 16,                        // 원하는 만큼 여백 조절
                              child: Image(
                                image: AssetImage('assets/images/google.png'),
                                width: 24,
                                height: 24,
                              ),
                            ),
                            // 가운데 텍스트
                            Text(
                              AppLocalizations.of(context)!.startWithGoogle,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),


                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
