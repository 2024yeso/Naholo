// screens/main_scaffold.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/sizescaler.dart';
import 'where_alone_page.dart';
import 'home_page.dart';
import 'alone_diary_page.dart';
import 'profile_scaffold.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WhereAlonePage(),
      HomePage(),
      AloneDiaryPage(),
      const ProfileScaffold(),
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
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: SizeScaler.scaleSize(context, 15),
            ),
            label: '나홀로 어디',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: SizeScaler.scaleSize(context, 15),
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_book_outlined,
              size: SizeScaler.scaleSize(context, 15),
            ),
            label: '나홀로 일지',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: SizeScaler.scaleSize(context, 15),
            ),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
