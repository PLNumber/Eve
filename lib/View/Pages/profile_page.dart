import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/profile_view_model.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(uid),
      child: Scaffold(
        appBar: AppBar(title: const Text('프로필')),
        body: Consumer<ProfileViewModel>(
          builder: (context, vm, child) {
            final user = vm.user;

            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("닉네임: ${user.name}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("자기소개: ${user.bio.isEmpty ? '없음' : user.bio}", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text("레벨: ${user.level}", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text("정답률: ${vm.accuracyText}", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text("학습시간: ${vm.studyTimeText}", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text("누적 출석일: ${user.attendance}일", style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
