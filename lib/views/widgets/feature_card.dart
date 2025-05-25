/* lib/views/widgets/feature_card.dart */

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 메인화면 카드
// class FeatureCard extends StatelessWidget {
//   final String imagePath;
//   final String title;
//   final VoidCallback onTap;
//
//   const FeatureCard({
//     Key? key,
//     required this.imagePath,
//     required this.title,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     var screenSize = MediaQuery.of(context).size;
//     var imageWidth = screenSize.width * 0.25; // 화면 너비의 25%를 이미지 너비로 사용
//     var imageHeight = imageWidth; // 너비와 높이를 같게 설정
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth*0.05)),
//         elevation: 4,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(imagePath, width: imageWidth, height: imageHeight),
//             SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color:
//                     Theme.of(context).brightness == Brightness.dark
//                         ? Colors.white
//                         : Colors.black, // 다크 모드에 따라 색상 변경
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//어휘 학습 카드
class DailyVocabProgress extends StatefulWidget {
  @override
  _DailyVocabProgressState createState() => _DailyVocabProgressState();
}

class _DailyVocabProgressState extends State<DailyVocabProgress> {
  int _goal = 30;
  int _completed = 0;
  String _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final List<int> _goalOptions = [10, 20, 30];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && data['vocab_date'] == _todayKey) {
        await prefs.setInt('vocab_completed', data['vocab_completed'] ?? 0);
        await prefs.setString('vocab_date', data['vocab_date']);
      }
    }

    final lastDate = prefs.getString('vocab_date');
    if (lastDate != _todayKey) {
      await prefs.setInt('vocab_completed', 0);
      await prefs.setString('vocab_date', _todayKey);
    }
    setState(() {
      _goal = prefs.getInt('vocab_goal') ?? 30;
      _completed = prefs.getInt('vocab_completed') ?? 0;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vocab_goal', _goal);
    await prefs.setInt('vocab_completed', _completed);
    await prefs.setString('vocab_date', _todayKey);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'vocab_goal': _goal,
        'vocab_completed': _completed,
        'vocab_date': _todayKey,
      }, SetOptions(merge: true));
    }
  }

  void _increaseCompleted() {
    setState(() {
      _completed++;
    });
    _saveData();
  }

  void _changeGoal(int newGoal) {
    setState(() {
      _goal = newGoal;
      _completed = 0;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double percent = _completed / _goal;
    bool isComplete = percent >= 1.0;

    return Row(
      children: [
        CircularPercentIndicator(
          radius: screenWidth * 0.08,
          lineWidth: screenWidth * 0.03,
          percent: percent.clamp(0.0, 1.0),
          center: isComplete
              ? Text("완료!", style: TextStyle(fontSize: screenWidth * 0.025,fontWeight: FontWeight.bold))
              : Text("${(percent * 100).toInt()}%", style: TextStyle(fontSize: screenWidth * 0.025)),
          progressColor: Colors.blueAccent,
          backgroundColor: Colors.grey.shade300,
        ),
        SizedBox(width: screenWidth * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("일일 학습", style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text("하루 목표: ", style: TextStyle(fontSize: screenWidth * 0.025)),
                DropdownButton<int>(
                  value: _goal,
                  items: _goalOptions.map((value) => DropdownMenuItem(
                    value: value,
                    child: Text("$value개",style: TextStyle(fontSize: screenWidth * 0.025)),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _changeGoal(value);
                    }
                  },
                ),
              ],
            ),
            Text("오늘 푼 단어: $_completed개",style: TextStyle(fontSize: screenWidth * 0.025)),
            // const SizedBox(height: 6),
            // ElevatedButton(
            //   onPressed: isComplete ? null : _increaseCompleted,
            //   child: const Text("단어 풀기 +1 (테스트용)"),
            // ),
          ],
        ),
      ],
    );
  }
}
