// 팝업 다이얼로그 함수
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nahollo/community_screen.dart';
import 'package:nahollo/screens/diary_screens/diary_main.dart';
import 'package:nahollo/screens/diary_screens/diary_user.dart';
import 'package:nahollo/screens/login_screens/login_screen.dart';
import 'package:nahollo/screens/main_screen.dart';
import 'package:nahollo/screens/myPage_screen.dart';
import 'package:nahollo/screens/nahollo_anji_screen.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_main_screen.dart';

void showExitDialog(BuildContext context) {
  //회원가입 취소 팝업창
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // 모서리 둥글게
        ),
        title: const Text(
          '회원가입을 그만하고 나갈까요?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 취소 버튼: 팝업 닫기
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200, // 버튼 배경 색
            ),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 나가기 버튼: 팝업 닫고 추가 동작 가능
              // 원하는 동작 추가 (예: 회원가입 취소, 홈으로 이동 등)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF8A2EC1), // 나가기 버튼 배경색
            ),
            child: const Text('나가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showAppExitDialog(BuildContext context) {
  //앱 나가기 팝업창
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // 모서리 둥글게
        ),
        title: const Text(
          '앱을 나가시겠습니까?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 취소 버튼: 팝업 닫기
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200, // 버튼 배경 색
            ),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 나가기 버튼: 팝업 닫고 추가 동작 가능
              SystemNavigator.pop(); // 안드로이드에서 앱 종료
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF8A2EC1), // 나가기 버튼 배경색
            ),
            child: const Text('나가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

class SizeUtil {
  // 화면 반환
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // 화면 너비 반환
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // 화면 높이 반환
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // 특정 퍼센트의 화면 너비를 반환
  static double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  // 특정 퍼센트의 화면 높이를 반환
  static double getHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }
}

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  void _onItemTapped(int index) {
    // 페이지 이동 로직을 추가
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const NaholloWhereMainScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DiaryMain()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CommunityScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const DiaryUser(
                    authorID: "안녕",
                  )),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedLabelStyle: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.04, // 화면 너비의 4%
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.035, // 화면 너비의 3.5%
      ),
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.selectedIndex, // 선택된 탭 유지
      onTap: _onItemTapped, // 탭 선택 시 _onItemTapped 호출
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "나홀로어디",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '나홀로안지',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: '커뮤니티',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
    );
  }
}
