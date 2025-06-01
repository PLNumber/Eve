import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatefulWidget {
  @override
  _AttendanceCalendarState createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  Map<String, bool> _attendanceMap = {}; // "yyyy-MM-dd" : true

  @override
  void initState() {
    super.initState();
    _loadAttendance().then((_) {
      _markTodayAsPresent().then((_) {
        _calculateAttendanceStats(); // 🔥 통계 계산 추가!
      });
    });
  }


  Future<void> _loadAttendance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('attendance').doc(uid).get();
    if (doc.exists && doc.data() != null && doc.data()!['dates'] is Map) {
      setState(() {
        _attendanceMap = Map<String, bool>.from(doc.data()!['dates']);
      });
    }
  }

  Future<void> _markTodayAsPresent() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final todayStr = _formatDate(DateTime.now());

    if (!_attendanceMap.containsKey(todayStr)) {
      _attendanceMap[todayStr] = true;
      await FirebaseFirestore.instance.collection('attendance').doc(uid).set({
        'dates': _attendanceMap,
      });
      setState(() {});
    }
  }

  String _formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  bool _isPresent(DateTime day) {
    final dateStr = _formatDate(day);
    return _attendanceMap[dateStr] ?? false;
  }
  int _consecutiveDays = 0;
  double _monthlyAttendanceRate = 0.0;

  Future<void> _calculateAttendanceStats() async {
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // 연속 출석 계산
    int count = 0;
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      if (_attendanceMap[dateStr] == true) {
        count++;
      } else {
        if (i != 0) break;
      }
    }
    _consecutiveDays = count;

    // 이번 달 출석률 계산
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    int totalDays = lastDay.day;
    int presentDays = 0;

    for (int i = 1; i <= totalDays; i++) {
      final dateStr = _formatDate(DateTime(now.year, now.month, i));
      if (_attendanceMap[dateStr] == true) {
        presentDays++;
      }
    }
    _monthlyAttendanceRate = presentDays / totalDays;

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text("✅ 연속 출석: $_consecutiveDays일",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("📅 ${DateTime.now().month}월 출석률: ${(_monthlyAttendanceRate * 100).toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        Expanded( // 🟩 TableCalendar가 남은 영역 차지하게
          child: TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, _) {
                if (_isPresent(day)) {
                  return Icon(Icons.check_circle, color: Colors.green, size: 16);
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

}


