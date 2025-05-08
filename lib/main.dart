// ✅ lib/main.dart (다국어 적용된 MainPage 포함)
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

import 'Controller/quiz_controller.dart';
import 'viewModel/option_view_model.dart';

import 'firebase_options.dart';
import 'l10n/gen_l10n/app_localizations.dart';
import 'views/pages/login_page.dart';
import 'views/pages/quiz_page.dart';
import 'views/pages/option_page.dart';
import 'views/pages/set_name_page.dart';
import 'views/widgets/feature_card.dart';
import 'views/widgets/nav_util.dart';

import 'services/auth_service.dart';
import 'Services/gemini_service.dart';
import 'services/quiz_service.dart';
import 'repository/quiz_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "assets/config/.env");
  final String geminiApiKey = dotenv.env['geminiApiKey'] ?? "";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => OptionViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        Provider(
          create: (_) => QuizController(
            QuizService(
              QuizRepository(
                GeminiService(apiKey: geminiApiKey),
              ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    return MaterialApp(
      title: 'LexiUp',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      locale: provider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
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
        }
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
  String nickname = "  ";
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
          title: AppLocalizations.of(context)!.exit,
          content: AppLocalizations.of(context)!.confirm_exit,
          onConfirm: () => SystemNavigator.pop(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(nickname),
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
              Text(AppLocalizations.of(context)!.title, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
