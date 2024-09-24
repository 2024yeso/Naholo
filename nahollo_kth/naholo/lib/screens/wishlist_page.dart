// lib/screens/wishlist_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import '../widgets/sizescaler.dart';

class WishlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '가고 싶어요',
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
          '가고 싶어요 목록을 여기에 표시합니다.',
          style: TextStyle(
            fontSize: SizeScaler.scaleSize(context, 14),
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
