// lib/screens/following_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import 'package:nahollo/sizeScaler.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '팔로잉',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeScaler.scaleSize(context, 20),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Center(
        child: Text(
          '팔로잉 목록을 여기에 표시합니다.',
          style: TextStyle(
            fontSize: SizeScaler.scaleSize(context, 14),
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
