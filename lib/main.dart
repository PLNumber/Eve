//lib/main.dart (Fitness UI 스타일 적용된 MainPage 포함)
import 'package:eve/provider/audio_provider.dart';
import 'package:eve/provider/local_provider.dart';
import 'package:eve/provider/theme_provider.dart';
import 'package:eve/viewModel/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'controller/attendance_calendar.dart';
import 'controller/quiz_controller.dart';
import 'controller/weekly_attendance_preview.dart';
import 'viewModel/option_view_model.dart';
import 'firebase_options.dart';
import 'l10n/gen_l10n/app_localizations.dart';
import 'views/pages/login_page.dart';
import 'views/pages/quiz_page.dart';
import 'views/pages/option_page.dart';
import 'views/pages/set_name_page.dart';
import 'views/widgets/nav_util.dart';

import 'Services/gemini_service.dart';
import 'services/auth_service.dart';
import 'services/quiz_service.dart';
import 'repository/quiz_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 자동회전 끔
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
              locale.languageCode == 'ko' ? 'IropkeBatang' : 'OpenDyslexic',
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily:
              locale.languageCode == 'ko' ? 'IropkeBatang' : 'OpenDyslexic',
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
    _loadUserInfo();
    _loadStats();
    _loadLearningTime();
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
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final secs = (doc.data()?['timeSpent'] as int?) ?? 0;
    setState(() {
      final days = secs ~/ 86400;
      final remAfterDays = secs % 86400;
      final hours = remAfterDays ~/ 3600;
      final remAfterHours = remAfterDays % 3600;
      final minutes = remAfterHours ~/ 60;
      if (days > 0) {
        learningTime = [
          "$days일",
          if (hours > 0) "${hours}시간",
          if (minutes > 0) "${minutes}분",
        ].join(' ');
      } else if (hours > 0) {
        learningTime = ["${hours}시간", if (minutes > 0) "${minutes}분"].join(' ');
      } else {
        learningTime = "$minutes분";
      }
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
          toolbarHeight: 70,
          leading: IconButton(
            icon: const Icon(Icons.menu, size: 50),
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OptionPage()),
            ),
          ),
          title: Text("$nickname님 환영합니다!"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                size: 50,
              ),
              onPressed: () {
                setState(() {
                  _notificationsEnabled = !_notificationsEnabled;
                });
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
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
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
                          radius: 50,
                          backgroundImage: AssetImage(getProfileImage(_level)),
                        ),
                        //TODO : 어휘 학습 구현 해야함
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(accuracy, style: const TextStyle(fontSize: 24)),
                            const Text("어휘 학습"),
                            const Text("하루 목표: 30개"),
                          ],
                        ),
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
                        label: const Text("퀴즈 시작하기"),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
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
              const SizedBox(height: 48),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text("나의 통계", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("총 푼 횟수: $totalSolved"),
                                      Text("맞춘 횟수: $correctSolved"),
                                      Text("플레이 시간: $learningTime"),
                                    ],
                                  ),
                                  CircularPercentIndicator(
                                    radius: 60.0,
                                    lineWidth: 8.0,
                                    percent: accuracyPercent.clamp(0.0, 1.0),
                                    center: Text(accuracy),
                                    progressColor: Colors.green,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: _exp / _maxExp,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                              const SizedBox(height: 8),
                              Text("레벨 $_level ($_exp / $_maxExp)", style: TextStyle(fontSize: 14, color: textColor)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureButton("오답 노트", Icons.edit_note, onTap: () {
                            // TODO: 오답 노트 페이지 이동
                          }),
                          _buildFeatureButton("단어 사전", Icons.menu_book, onTap: () {
                            // TODO: 단어 사전 페이지 이동
                          }),
                        ],
                      ),

                      // 달력
                      SizedBox(height: 20),
                      WeeklyAttendancePreview(), // 🔥 일주일 출석만 보여줌
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

Widget _buildFeatureButton(String title, IconData icon, {required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        width: 120,
        height: 120,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Icon(icon, size: 36),
          ],
        ),
      ),
    ),
  );
}

