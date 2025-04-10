import 'package:eve/View/Pages/login_page.dart';
import 'package:eve/View/Pages/quiz_page.dart';
import 'package:eve/View/Widgets/back_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eve/View/Widgets/featureCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eve/View/Pages/option_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ViewModel/login_view_model.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:LoginPage(),
      // home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
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
          title: Text("메인 페이지임"),
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
