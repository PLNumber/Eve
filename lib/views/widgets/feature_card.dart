/* lib/views/widgets/feature_card.dart */

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../l10n/gen_l10n/app_localizations.dart';

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
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
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

  void _changeGoal(int newGoal) {
    setState(() {
      _goal = newGoal;
      _completed = 0;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
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
          center:
              isComplete
                  ? Text(
                    "완료!",
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : Text(
                    "${(percent * 100).toInt()}%",
                    style: TextStyle(fontSize: screenWidth * 0.025),
                  ),
          progressColor: Colors.blueAccent,
          backgroundColor: Colors.grey.shade300,
        ),
        SizedBox(width: screenWidth * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              local.dailyLearning,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  local.dailyGoal,
                  style: TextStyle(fontSize: screenWidth * 0.025),
                ),
                SizedBox(width: screenWidth * 0.01),
                DropdownButton<int>(
                  value: _goal,
                  items:
                      _goalOptions
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                local.goalCountUnit(value),
                                style: TextStyle(fontSize: screenWidth * 0.025),
                              ),

                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _changeGoal(value);
                    }
                  },
                ),
              ],
            ),
            Text(
              local.todayLearnedWords(_completed),
              style: TextStyle(fontSize: screenWidth * 0.025),
            ),
          ],
        ),
      ],
    );
  }
}
