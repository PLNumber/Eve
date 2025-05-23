/* lib/views/widgets/feature_card.dart */

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 메인화면 카드
class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var imageWidth = screenSize.width * 0.25; // 화면 너비의 25%를 이미지 너비로 사용
    var imageHeight = imageWidth; // 너비와 높이를 같게 설정

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: imageWidth, height: imageHeight),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black, // 다크 모드에 따라 색상 변경
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
    double percent = _completed / _goal;
    bool isComplete = percent >= 1.0;

    return Row(
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 8.0,
          percent: percent.clamp(0.0, 1.0),
          center: isComplete
              ? const Text("완료!", style: TextStyle(fontWeight: FontWeight.bold))
              : Text("${(percent * 100).toInt()}%", style: const TextStyle(fontSize: 18)),
          progressColor: Colors.blueAccent,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("어휘 학습", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Text("하루 목표: "),
                DropdownButton<int>(
                  value: _goal,
                  items: _goalOptions.map((value) => DropdownMenuItem(
                    value: value,
                    child: Text("$value개"),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _changeGoal(value);
                    }
                  },
                ),
              ],
            ),
            Text("오늘 푼 단어: $_completed개"),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: isComplete ? null : _increaseCompleted,
              child: const Text("단어 풀기 +1 (테스트용)"),
            ),
          ],
        ),
      ],
    );
  }
}
