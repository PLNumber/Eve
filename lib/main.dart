//lib/main.dart (Fitness UI 스타일 적용된 MainPage 포함)
import 'package:eve/provider/audio_provider.dart';
import 'package:eve/provider/local_provider.dart';
import 'package:eve/provider/theme_provider.dart';
import 'package:eve/utils/attendance_reminder.dart';
import 'package:eve/viewModel/login_view_model.dart';
import 'package:eve/views/pages/dictionary_page.dart';
import 'package:eve/views/pages/wrongNotes_page.dart';
import 'package:eve/views/widgets/feature_card.dart';
import 'package:eve/views/widgets/leaderboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/quiz_controller.dart';
import 'views/subpages/weekly_attendance_preview.dart';
import 'viewModel/option_view_model.dart';
import 'firebase_options.dart';
import 'l10n/gen_l10n/app_localizations.dart';
import 'views/pages/login_page.dart';
import 'views/pages/quiz_page.dart';
import 'views/pages/option_page.dart';
import 'views/pages/set_name_page.dart';
import 'views/widgets/nav_util.dart';

import 'services/gemini_service.dart';
import 'services/quiz_service.dart';
import 'repository/quiz_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 자동회전 끔
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AttendanceReminder.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "assets/config/.env");
  final String geminiApiKey = dotenv.env['geminiApiKey'] ?? "";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(
          create:
              (_) => OptionViewModel(
                QuizRepository(GeminiService(apiKey: geminiApiKey)),
              ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        Provider(
          create:
              (_) => QuizController(
                QuizService(
                  QuizRepository(GeminiService(apiKey: geminiApiKey)),
                ),
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const LoginPage();

    final snapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
    final nickname = snapshot.data()?['nickname'];

    if (nickname == null ||
        nickname == user.uid ||
        nickname.toString().trim().isEmpty) {
      return SetUserPage();
    }
    return const MainPage();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final locale = provider.locale;

    return MaterialApp(
      title: 'LexiUp',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily:
              locale.languageCode == 'ko' ? 'BMHANNAAir' : 'OpenDyslexic',
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily:
              locale.languageCode == 'ko' ? 'BMHANNAAir' : 'OpenDyslexic',
        ),
      ),

      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ko')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          return FutureBuilder<Widget>(
            future: _getStartPage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return snapshot.data!;
              }
            },
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  String nickname = "사용자";
  String accuracy = "0.0%";
  String learningTime = "0분";
  int totalSolved = 0;
  int correctSolved = 0;
  int _level = 1;
  int _exp = 0;
  final int _maxExp = 100;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    AttendanceReminder.checkAndNotify();
    _loadUserInfo();
    _loadStats();
    _loadLearningTime();
  }

  // 해당 등급의 텍스트
  String getGradeMappingText() {
    final local = AppLocalizations.of(context)!;
    return local.gradeMappingText;
  }


  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
    final data = doc.data() ?? {};
    setState(() {
      nickname = data['nickname'] ?? "닉네임 없음";
      _level = data['level'] ?? 1;
      _exp = data['experience'] ?? 0;
    });
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = doc.data();
    if (data == null) return;
    correctSolved = (data['correctSolved'] as int?) ?? 0;
    totalSolved = (data['totalSolved'] as int?) ?? 0;
    final double pct = totalSolved > 0 ? correctSolved / totalSolved * 100 : 0;
    setState(() {
      accuracy = "${pct.toStringAsFixed(1)}%";
    });
  }

  Future<void> _loadLearningTime() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final secs = (doc.data()?['timeSpent'] as int?) ?? 0;

    final local = AppLocalizations.of(context)!;

    setState(() {
      final days = secs ~/ 86400;
      final remAfterDays = secs % 86400;
      final hours = remAfterDays ~/ 3600;
      final remAfterHours = remAfterDays % 3600;
      final minutes = remAfterHours ~/ 60;

      final parts = <String>[];

      if (days > 0) {
        parts.add(local.days(days));
      }
      if (hours > 0) {
        parts.add(local.hours(hours));
      }
      if (minutes > 0 || parts.isEmpty) {
        parts.add(local.minutes(minutes));
      }

      learningTime = parts.join(' ');
    });
  }


  String getProfileImage(int level) {
    return 'assets/images/profile_level_$level.png';
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final accentColor = Colors.indigoAccent;
    double accuracyValue = double.tryParse(accuracy.replaceAll('%', '')) ?? 0;
    double accuracyPercent = accuracyValue / 100;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showConfirmDialog(
          context,
          title: local.exit,
          content: local.confirm_exit,
          onConfirm: () => SystemNavigator.pop(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: screenHeight * 0.09,
          leading: IconButton(
            icon: Icon(Icons.menu, size: screenWidth * 0.08),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OptionPage()),
                ),
          ),
          title: Text(
            local.welcomeUser(nickname),
            style: TextStyle(fontSize: screenWidth * 0.045),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                size: screenWidth * 0.08,
              ),
              onPressed: () {
                setState(() {
                  _notificationsEnabled = !_notificationsEnabled;
                });
                if (_notificationsEnabled) {
                  // 알림 켜기: 즉시 체크 & 알림 스케줄(또는 즉시 알림)
                  AttendanceReminder.checkAndNotify();
                } else {
                  // 알림 끄기: 예약된 알림 모두 취소
                  AttendanceReminder.cancelAll();
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.exit_to_app),
          onPressed: () {
            showConfirmDialog(
              context,
              title: local.exit,
              content: local.confirm_exit,
              onConfirm: () => SystemNavigator.pop(),
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: EdgeInsets.all(screenWidth * 0.04),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.1,
                          backgroundImage: AssetImage(getProfileImage(_level)),
                        ),
                        //일일 학습
                        DailyVocabProgress(),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.quiz),
                        label: Text(
                          local.startQuiz,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        onPressed: () async {
                          final popped = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => const QuizPage()),
                          );
                          if (popped == true) {
                            await _loadStats();
                            await _loadLearningTime();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: const StadiumBorder(),
                          elevation: 8,
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                local.myStats,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${local.totalSolved}: $totalSolved",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                      Text(
                                          "${local.correctSolved}: $correctSolved",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                      Text(
                                        "${local.learningTime}: $learningTime",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CircularPercentIndicator(
                                    radius: screenWidth * 0.08,
                                    lineWidth: screenWidth * 0.03,
                                    percent: accuracyPercent.clamp(0.0, 1.0),
                                    center: Text(
                                      accuracy,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.025,
                                      ),
                                    ),
                                    progressColor: Colors.green,
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              LinearProgressIndicator(
                                value: _exp / _maxExp,
                                backgroundColor: Colors.grey.shade300,
                                minHeight: screenHeight * 0.012,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentColor,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                local.levelInfo(_level.toString(), _exp.toString(), _maxExp.toString()),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.02,
                                  color: textColor,
                                ),
                              ),
                              // 정보 창
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: Text(local.questionGrade),
                                              content: Text(
                                                getGradeMappingText(),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(ctx),
                                                  child: Text(local.close),
                                                ),
                                              ],
                                            ),
                                      );
                                    },

                                    child: Text(
                                      local.questionGrade,
                                      style: TextStyle(
                                        color: Colors.indigo,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureButton(
                            context,
                            local.wrongNote,
                            Icons.edit_note,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WrongNotePage(),
                                ),
                              );
                            },
                          ),

                          _buildFeatureButton(
                            context,
                            local.dictionary,
                            Icons.menu_book,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DictionaryPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // 출석 달력
                      SizedBox(height: 20),
                      WeeklyAttendancePreview(), // 일주일 출석만 보여줌

                      SizedBox(height: 20),
                      const LeaderboardSection(),//리더보드

                      //테스트용 마지막 접속일 3일전으로 설정하고 테스트
                      ElevatedButton(
                        child: Text(local.testSet3DaysAgo),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final threeDaysAgo = DateTime.now().subtract(
                            const Duration(days: 3),
                          );
                          await prefs.setString(
                            'lastLoginDate',
                            threeDaysAgo.toIso8601String(),
                          );
                          await AttendanceReminder.checkAndNotify();
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 위젯
Widget _buildFeatureButton(
  BuildContext context,
  String title,
  IconData icon, {
  required VoidCallback onTap,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        width: screenWidth * 0.43,
        height: screenWidth * 0.30,
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: screenWidth * 0.1),
            SizedBox(height: screenWidth * 0.03),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
