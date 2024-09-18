import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NaholloWhereRegisterSearchScreen extends StatefulWidget {
  const NaholloWhereRegisterSearchScreen({super.key});

  @override
  State<NaholloWhereRegisterSearchScreen> createState() =>
      _NaholloWhereRegisterSearchScreenState();
}

class _NaholloWhereRegisterSearchScreenState
    extends State<NaholloWhereRegisterSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
        options: const NaverMapViewOptions(),
        onMapReady: (controller) {
          print("로딩됨");
        },
      ),
    );
  }
}
