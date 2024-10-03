import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';

import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/attend_screens/attend_main_screen.dart';
import 'package:nahollo/screens/mypage_screens/profile_scaffold.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_main_screen.dart';
import 'package:nahollo/screens/diary_screens/diary_main.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_day_data.dart';
import 'package:nahollo/util.dart';

import 'package:o3d/o3d.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final O3DController controller = O3DController(); // 3D 모델 컨트롤러
  DateTime today = DateTime.now(); // 현재 날짜와 시간을 가져옵니다.
  String _message = "";

  Future<void> updateUser(
      String userId, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('${Api.baseUrl}/update_user/$userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData), // 데이터를 JSON 형식으로 변환하여 전달
      );

      if (response.statusCode == 200) {
        print("User information updated successfully");
      } else {
        print("Failed to update user: ${response.statusCode}");
        print("Error message: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void updateUserDetails() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String userId = userProvider.user?.userId ?? '';

    Map<String, dynamic> updatedData = {
      "LV": userProvider.user?.lv,
      "Exp": userProvider.user?.exp,
      "usercharacter": userProvider.user?.userCharacter,
    };

    updateUser(userId, updatedData);
  }

  Future<void> checkAttendance() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId ?? '';

    final url = Uri.parse('${Api.baseUrl}/attendance/check');

    // 출석 체크 요청 데이터
    final body = json.encode({'username': userId});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // 응답을 JSON으로 변환
        final Map<String, dynamic> responseData = json.decode(response.body);

        // List<dynamic>을 List<String>으로 변환
        List<String> stringList =
            (responseData['attendance_dates'] as List<dynamic>)
                .whereType<String>() // String 타입인 요소만 필터링
                .map((element) => element.toString()) // 각 요소를 String으로 변환
                .toList();

        attendanceDays = stringList;

        // message를 _message에 저장하고 다이얼로그 처리
        setState(() {
          _message = responseData['message'];

          if (_message == 'attendance.') {
            // 출석 체크가 완료된 경우에만 다이얼로그 표시
            showAttendanceDialog(context, '오늘도 출석하셨네요!');
          } else if (_message == 'already') {
            // 이미 출석한 경우에는 아무 작업도 하지 않음
            print('이미 출석 체크를 했습니다.');
          }
        });

        print("메세지 $_message");
      } else {
        print('출석 체크 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('출석 체크 요청 중 오류 발생: $e');
    }
  }

// 출석 체크 성공 시 다이얼로그를 표시하는 함수
  void showAttendanceDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('출석 성공!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAttendance();
    updateUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;
    final userCharacter =
        Provider.of<UserProvider>(context).user!.userCharacter;
    final userid = Provider.of<UserProvider>(context).user!.userId;
    print(userid);

    final userExp = Provider.of<UserProvider>(context).user!.exp;
    // 화면의 너비와 높이를 가져옵니다.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        //didPop == true , 뒤로가기 제스쳐가 감지되면 호출 된다.
        if (didPop) {
          print('didPop호출');
          return;
        }
        updateUserDetails();
        showAppExitDialog(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('assets/images/main_screen_bg.png'), // 배경 이미지 설정
              fit: BoxFit.cover, // 이미지를 화면에 꽉 채우도록 설정
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeScaler.scaleSize(context, 15),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.06, // 상단 여백
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: SizeScaler.scaleSize(context, 0)),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // 좌우 끝에 아이콘 배치
                    children: [
                      IconButton(
                        onPressed: () {}, // 알림 버튼 클릭 시 동작 (현재 비어 있음)
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white, // 아이콘 색상
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 0.015 * screenHeight, // 알림과 텍스트 사이의 여백
                ),
                Text(
                  "오늘은 혼술 어때?", // 메인 텍스트
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 13), // 텍스트 크기
                    color: Colors.white, // 텍스트 색상
                  ),
                ),
                TextButton(
                  onPressed: () {}, // 텍스트 버튼 클릭 시 동작 (현재 비어 있음)
                  child: Text(
                    '요즘 뜨는 술집 보러가기', // 버튼 텍스트
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withOpacity(0.5),
                    ), // 텍스트 색상
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2), // 3D 모델 주변 패딩 설정
                  width: screenHeight * 0.4,
                  height: screenHeight * 0.4,
                  child: Card(
                    color: Colors.transparent, // 카드 배경 투명
                    elevation: 0, // 그림자 효과 제거
                    child: O3D(
                      disableTap: true, // 탭 동작 비활성화
                      disableZoom: true, // 줌 동작 비활성화
                      controller: controller, // 3D 모델 컨트롤러 사용
                      autoPlay: true, // 자동 재생 설정
                      src: 'assets/glbs/$userCharacter.glb', // 3D 모델 파일 경로
                    ),
                  ),
                ),
                const Text(
                  '오늘은 혼자 무엇을 할까?', // 서브 텍스트
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ), // 텍스트 색상
                ),
                SizedBox(
                  height: SizeScaler.scaleSize(context, 3),
                ),
                Text(
                  user!.nickName, // 캐릭터 이름
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상
                    fontSize: SizeScaler.scaleSize(context, 13.5), // 텍스트 크기
                    fontWeight: FontWeight.w600, // 텍스트 두께
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Lv.${user.lv}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0), // 진행 바 주변 패딩
                      child: SizedBox(
                        width: SizeScaler.scaleSize(context, 73),
                        height: SizeScaler.scaleSize(context, 6),
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFFf9747d), // 진행 바 색상
                          value: userExp != null
                              ? userExp / 100
                              : 0, // 진행률 (0.0에서 1.0 사이)
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.1, // 하단 아이콘 그룹과의 여백
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return const NaholloWhereMainScreen();
                                },
                              ));
                            },
                            // 검색 아이콘을 클릭할 수 있도록 GestureDetector 사용
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                                borderRadius:
                                    BorderRadius.circular(5), // 모서리 둥글게 설정
                              ),
                              height: screenWidth * 0.15,
                              width: screenWidth * 0.15,
                              child: Icon(
                                Icons.search, // 검색 아이콘
                                color: Colors.white, // 아이콘 색상
                                size: SizeScaler.scaleSize(context, 21),
                              ),
                            ),
                          ),
                          AutoSizeText(
                            "나홀로어디?", // 아이콘 하단의 설명 텍스트
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeScaler.scaleSize(context, 6)),
                            // 텍스트 색상
                            maxLines: 1,
                            minFontSize: 5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print(user);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return const DiaryMain();
                                },
                              ));
                            },
                            // 책 아이콘을 클릭할 수 있도록 GestureDetector 사용
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                                borderRadius:
                                    BorderRadius.circular(5), // 모서리 둥글게 설정
                              ),
                              height: screenWidth * 0.15,
                              width: screenWidth * 0.15,
                              child: Icon(
                                Icons.book_outlined, // 책 아이콘
                                color: Colors.white, // 아이콘 색상
                                size: SizeScaler.scaleSize(context, 21),
                              ),
                            ),
                          ),
                          AutoSizeText(
                            "나홀로일지", // 아이콘 하단의 설명 텍스트
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeScaler.scaleSize(context, 6)),
                            // 텍스트 색상
                            maxLines: 1,
                            minFontSize: 5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          GestureDetector(
                            // 홈 아이콘을 클릭할 수 있도록 GestureDetector 사용
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                                borderRadius:
                                    BorderRadius.circular(5), // 모서리 둥글게 설정
                              ),
                              height: screenWidth * 0.15,
                              width: screenWidth * 0.15,
                              child: Icon(
                                Icons.home_outlined, // 홈 아이콘
                                color: Colors.white, // 아이콘 색상
                                size: SizeScaler.scaleSize(context, 21),
                              ),
                            ),
                          ),
                          AutoSizeText(
                            "홈", // 아이콘 하단의 설명 텍스트
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeScaler.scaleSize(context, 6)),
                            // 텍스트 색상
                            maxLines: 1,
                            minFontSize: 5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendMainScreen(
                                  attendance_dates: attendanceDays,
                                ),
                              ),
                            ),
                            // 채팅 아이콘을 클릭할 수 있도록 GestureDetector 사용
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                                borderRadius:
                                    BorderRadius.circular(5), // 모서리 둥글게 설정
                              ),
                              height: screenWidth * 0.15,
                              width: screenWidth * 0.15,
                              child: Icon(
                                Icons.check_box_outlined,
                                color: Colors.white,
                                size:
                                    SizeScaler.scaleSize(context, 21), // 아이콘 색상
                              ),
                            ),
                          ),
                          AutoSizeText(
                            "출석", // 아이콘 하단의 설명 텍스트
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeScaler.scaleSize(context, 6)),
                            // 텍스트 색상
                            maxLines: 1,
                            minFontSize: 5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScaffold(),
                              ),
                            ),
                            // 마이페이지 아이콘을 클릭할 수 있도록 GestureDetector 사용
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                                borderRadius:
                                    BorderRadius.circular(5), // 모서리 둥글게 설정
                              ),
                              height: screenWidth * 0.15,
                              width: screenWidth * 0.15,
                              child: Icon(
                                Icons.person_outline, // 마이페이지 아이콘
                                color: Colors.white, // 아이콘 색상
                                size: SizeScaler.scaleSize(context, 21),
                              ),
                            ),
                          ),
                          AutoSizeText(
                            "마이페이지", // 아이콘 하단의 설명 텍스트
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    SizeScaler.scaleSize(context, 6)), // 텍스트 색상
                            maxLines: 1,
                            minFontSize: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
