import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'attendance_calendar.dart';

class WeeklyAttendancePreview extends StatefulWidget {
  @override
  _WeeklyAttendancePreviewState createState() => _WeeklyAttendancePreviewState();
}

class _WeeklyAttendancePreviewState extends State<WeeklyAttendancePreview> {
  Map<String, bool> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _markTodayAttendance(); // 👈 오늘 출석 먼저 기록
    _loadAttendance();       // 이후 데이터 불러오기
  }


  Future<void> _loadAttendance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('attendance').doc(uid).get();
    if (doc.exists && doc.data()?['dates'] is Map) {
      setState(() {
        _attendanceMap = Map<String, bool>.from(doc.data()!['dates']);
      });
    }
  }

  String _formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> _markTodayAttendance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final todayKey = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(uid)
        .set({
      'dates': {
        todayKey: true,
      }
    }, SetOptions(merge: true));

    print("정상적으로 출석 저장됨: $todayKey");
  }



  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekDays = List<Map<String, dynamic>>.generate(7, (i) {
      final day = today.subtract(Duration(days: today.weekday - 1 - i));
      return {
        'date': "${day.month}/${day.day}",
        'checked': _attendanceMap[_formatDate(day)] ?? false,
      };
    });

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(height: 500, child: AttendanceCalendar()),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📆 이번 주 출석",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                return Column(
                  children: [
                    Text(day['date']!),
                    Icon(
                      day['checked']!
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: day['checked']! ? Colors.green : Colors.grey,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
