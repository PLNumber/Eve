// ✅ lib/main.dart (Fitness UI 스타일 적용된 MainPage 포함)
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

import 'controller/quiz_controller.dart';
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
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

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
  String nickname = "";
  String accuracy = "0%";
  String learningTime = "0분";
  int _level = 1;
  int _exp = 0;
  final int _maxExp = 100;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadStats();
    _loadLearningTime();
  }

  String getGradeMappingText() {
    return '''
레벨 1 ~ 9   : 1등급
레벨 10 ~ 24 : 2등급
레벨 25 ~ 49 : 3등급
레벨 50 ~ 74 : 4등급
레벨 75 ~ 100: 5등급
''';
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

    final int correct = (data['correctSolved'] as int?) ?? 0;
    final int total = (data['totalSolved'] as int?) ?? 0;
    final double pct = total > 0 ? correct / total * 100 : 0;

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
    if (level >= 5) return 'assets/images/profile_level_5.png';
    return 'assets/images/profile_level_$level.png';
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final accentColor = Colors.indigoAccent;

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(nickname.isNotEmpty ? "$nickname님, 환영합니다!" : "LexiUp"),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OptionPage()),
                ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: CircleAvatar(
                    key: ValueKey<int>(_level),
                    radius: 50,
                    backgroundImage: AssetImage(getProfileImage(_level)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
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
                          minimumSize: const Size.fromHeight(50),
                          textStyle: const TextStyle(fontSize: 18),
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _exp / _maxExp,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "레벨 $_level ($_exp / $_maxExp)",
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: textColor),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text("레벨별 문제 등급 안내"),
                                      content: Text(getGradeMappingText()),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("닫기"),
                                        ),
                                      ],
                                    ),
                              );
                            },

                            child: Text(
                              "내 등급 범위 보기",
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DashboardCard(
                    icon: Icons.access_time,
                    label: "플레이 시간",
                    value: learningTime,
                  ),
                  _DashboardCard(
                    icon: Icons.star,
                    label: "정답률",
                    value: accuracy,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("복습할 단어 풀기 (추후 업데이트)"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("단어사전 (추후 업데이트)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: textColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor?.withAlpha(178),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
