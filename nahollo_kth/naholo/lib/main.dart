// lib/main.dart

import 'package:flutter/material.dart';
import 'sizescaler.dart'; // SizeScaler 임포트
import 'where_alone_page.dart';
import 'home_page.dart';
import 'alone_diary_page.dart';
import 'profile_scaffold.dart'; // 수정된 경로

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 만약 로그인한 사용자 정보를 관리하는 Provider나 상태 관리 시스템이 있다면 여기에 추가할 수 있습니다.

  @override
  Widget build(BuildContext context) {
    // 로그인된 사용자 ID를 가져옵니다.
    final String loggedInUserId = 'user1'; // 실제로는 로그인 로직을 통해 가져와야 합니다.

    return MaterialApp(
      title: 'My Page UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MainScaffold(loggedInUserId: loggedInUserId),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final String loggedInUserId;

  MainScaffold({required this.loggedInUserId});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0; // 현재 선택된 페이지 인덱스

  late List<Widget> _pages; // 페이지 목록을 늦은 초기화로 변경

  @override
  void initState() {
    super.initState();
    // 페이지 목록 초기화
    _pages = [
      WhereAlonePage(),
      HomePage(),
      AloneDiaryPage(),
      ProfileScaffold(userId: widget.loggedInUserId), // 사용자 ID 전달
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 4개 이상의 아이템을 사용할 때 필요
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: SizeScaler.scaleSize(context, 24)),
            label: '나홀로 어디',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: SizeScaler.scaleSize(context, 24)),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, size: SizeScaler.scaleSize(context, 24)),
            label: '나홀로 일지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: SizeScaler.scaleSize(context, 24)),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
