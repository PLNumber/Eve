import 'package:eve/Services/auth_service.dart';
import 'package:eve/View/Pages/login_page.dart';
import 'package:eve/View/Pages/quiz_page.dart';
import 'package:eve/View/Widgets/back_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eve/View/Widgets/featureCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eve/View/Pages/option_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'View/Pages/set_name_page.dart';
import 'ViewModel/login_view_model.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 추가
import 'package:cloud_firestore/cloud_firestore.dart';




/*메인 페이지*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 시스템 전 초기화
  
  //firebase 사용
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  
  // //화면 고정
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);

  
  //await dotenv.load(fileName: 'assets/config/.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final nickname = snapshot.data()?["nickname"];

    // 닉네임이 없거나, uid 그대로인 경우 → SetUserPage로
    if (nickname == null || nickname == user.uid || nickname.toString().trim().isEmpty) {
      return SetUserPage();
    }

    return const MainPage(); // 닉네임이 정상적으로 설정된 경우
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder<Widget>(
        future: _getStartPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

        //앱 종료
        showConfirmDialog(
          context,
          title: "앱 종료",
          content: '정말 앱을 종료하시겠습니까?',
          onConfirm: () {
            SystemNavigator.pop();
          },
        );
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text("환영합니다, $nickname님"), // 닉네임을 제목에 표시
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OptionPage()),
                  );
                },
              );
            },
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
                  //퀴즈 화면
                  FeatureCard(
                    icon: Icons.quiz,
                    title: "퀴즈",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    throw UnimplementedError();
  }
}
