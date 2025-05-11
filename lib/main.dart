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
          fontFamily: locale.languageCode == 'ko' ? 'IropkeBatang' : 'OpenDyslexic',
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: locale.languageCode == 'ko' ? 'IropkeBatang' : 'OpenDyslexic',
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

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _loadStats();
    _loadLearningTime();
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
          "$minutes분",
        ].join(' ');
      } else if (hours > 0) {
        learningTime = ["${hours}시간", if (minutes > 0) "${minutes}분"].join(' ');
      } else {
        learningTime = "$minutes분";
      }
    });
  }

  void _loadNickname() async {
    final nick = await _authService.getNickname();
    setState(() {
      nickname = nick;
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

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

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
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(nickname.isNotEmpty ? "$nickname님, 안녕하세요!" : "LexiUp"),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영합니다.
              Text(
                local.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //TODO : 학습 시간
                  _DashboardCard(
                    icon: Icons.access_time,
                    label: "학습 시간",
                    value: learningTime,
                  ),
                  _DashboardCard(
                    icon: Icons.star,
                    label: "정답률",
                    value: accuracy,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
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
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
