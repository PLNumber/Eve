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
    return Scaffold(
      
      appBar: AppBar(
        title: Text("옵션 페이지임"),
        leading: Builder(
            builder: (context) {
              return IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage())
                    );
                  }
              );
            }
        ),
      ),
      
      // body: Center(child: CircularProgressIndicator()),
      body: Text("여기 옵션페이지임"),
    );
  }
}
