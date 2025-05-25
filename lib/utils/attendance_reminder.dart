import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AttendanceReminder {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const String _prefKey = 'lastLoginDate';

  /// 앱 시작 시 한 번만 호출하여 알림 플러그인 초기화
  static Future<void> init() async {
    // 타임존 데이터 초기화
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
  }

  /// 앱 실행(로그인) 시마다 호출:
  /// 마지막 접속일과 비교하여 1일 이상 차이 나면 즉시 알림
  /// 이후 현재 날짜로 마지막 접속일 갱신
  static Future<void> checkAndNotify() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString(_prefKey);
    final now = DateTime.now();

    if (lastLoginStr != null) {
      final lastLogin = DateTime.parse(lastLoginStr);
      final daysAway = now.difference(lastLogin).inDays;
      if (daysAway >= 1) {
        await _showNotification(daysAway);
      }
    }

    // 마지막 접속일을 현재로 갱신
    await prefs.setString(_prefKey, now.toIso8601String());
  }

  /// n일 동안 미접속 알림 띄우기
  static Future<void> _showNotification(int daysAway) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'attendance_channel',
      '출석 알림',
      channelDescription: '오랜 미접속 사용자에게 알림을 보냅니다.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      '출석 알림',
      '접속 안 한 지 ${daysAway}일 되었습니다. 출석을 기록해 주세요!',
      details,
    );
  }
}
