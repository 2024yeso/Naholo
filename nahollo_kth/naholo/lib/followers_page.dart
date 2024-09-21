// lib/screens/followers_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import '../sizescaler.dart'; // SizeScaler 임포트

class FollowersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '팔로워',
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
      body: Center(
        child: Text(
          '팔로워 목록을 여기에 표시합니다.',
          style: TextStyle(
            fontSize: SizeScaler.scaleSize(context, 14),
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
