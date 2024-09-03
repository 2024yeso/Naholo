// main.dart (임시)
import 'package:flutter/material.dart';
import 'diary/diary_main.dart'; // 나홀로일지

// main
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // 초기 페이지를 설정합니다.
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 버튼을 눌렀을 때 DiaryMain 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DiaryMain()),
            );
          },
          child: Text('Go to Diary Main'),
        ),
      ),
    );
  }
}
