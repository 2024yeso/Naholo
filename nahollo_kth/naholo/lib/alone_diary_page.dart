// lib/screens/alone_diary_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import '../sizescaler.dart'; // SizeScaler 임포트

class AloneDiaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나홀로 일지',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeScaler.scaleSize(context, 20),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Center(
          child: Icon(
            Icons.book,
            color: Colors.grey,
            size: SizeScaler.scaleSize(context, 100),
          ),
        ),
      ),
    );
  }
}
