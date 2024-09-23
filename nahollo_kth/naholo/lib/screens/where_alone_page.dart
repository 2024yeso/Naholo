// lib/screens/where_alone_page.dart
import 'package:flutter/material.dart';
import '../widgets/sizescaler.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle

class WhereAlonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나홀로 어디',
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
            Icons.search,
            color: Colors.grey,
            size: SizeScaler.scaleSize(context, 100),
          ),
        ),
      ),
    );
  }
}
