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
      // appBar: AppBar(
      //   title: Text('문해력 퀴즈'),
      //   centerTitle: true,
      //   backgroundColor: Colors.teal,
      // ),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
