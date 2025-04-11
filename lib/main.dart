// lib/main.dart

import 'package:eve/provider/local_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart'; // 또는 정확한 상대경로



import 'ViewModel/login_view_model.dart';
import 'ViewModel/option_view_model.dart';
import 'ViewModel/quiz_view_model.dart';
import 'firebase_options.dart';
import 'view/pages/login_page.dart';
import 'view/pages/quiz_page.dart';
import 'view/pages/option_page.dart';
import 'view/pages/set_name_page.dart';
import 'view/widgets/feature_card.dart';
import 'view/widgets/nav_util.dart';

import 'services/auth_service.dart';
import 'services/openai_service.dart';
import 'services/quiz_service.dart';
import 'repository/quiz_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "assets/config/.env");
  final String openAIApiKey = dotenv.env['openAIApiKey'] ?? "";

  // //화면 고정
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);

  //await dotenv.load(fileName: 'assets/config/.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => OptionViewModel()),
        ChangeNotifierProvider(
          create: (_) => QuizViewModel(
            QuizService(
              QuizRepository(),
              OpenAIService(apiKey: openAIApiKey),
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

    final snapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    final nickname = snapshot.data()?['nickname'];

    if (nickname == null || nickname == user.uid || nickname.toString().trim().isEmpty) {
      return SetUserPage();
    }
    return const MainPage();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'LexiUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      //언어 설정
      locale: provider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      localizationsDelegates: const[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],


      home: FutureBuilder<Widget>(
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
  String nickname = "불러오는 중 . . .";
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  void _loadNickname() async {
    final nick = await _authService.getNickname();
    setState(() {
      nickname = nick;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        showConfirmDialog(
          context,
          title: "앱 종료",
          content: '정말 앱을 종료하시겠습니까?',
          onConfirm: () => SystemNavigator.pop(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("환영합니다, $nickname님"),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OptionPage()),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("퀴즈를 선택해보세요", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  FeatureCard(
                    imagePath: 'assets/images/korean_quiz.png',
                    title: "   ",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
