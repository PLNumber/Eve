import 'package:eve/main.dart';
import 'package:flutter/material.dart';

//퀴즈 페이지

class OptionPage extends StatefulWidget {
  @override
  _OptionPage createState() => _OptionPage();
}

class _OptionPage extends State<OptionPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        // 🔽 SnackBar로 메시지 보여주기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장되었습니다!'),
            duration: Duration(seconds: 1),
          ),
        );

        // 🔽 잠깐 보여주고 나서 페이지 뒤로 가기
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        });
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text("옵션 페이지임"),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('저장되었습니다!'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // 🔽 잠깐 보여주고 나서 페이지 뒤로 가기
                  Future.delayed(Duration(milliseconds: 1000), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  });
                },
              );
            },
          ),
        ),

        // body: Center(child: CircularProgressIndicator()),
        body: Text("여기 옵션페이지임"),
      ),
    );
  }
}
