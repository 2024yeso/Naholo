import 'package:flutter/material.dart';

import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_main_screen.dart';
import 'package:nahollo/util.dart';

import 'package:o3d/o3d.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final O3DController controller = O3DController(); // 3D 모델 컨트롤러

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;
    final userCharacter =
        Provider.of<UserProvider>(context).user!.userCharacter;
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
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.06, // 상단 여백
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
                    IconButton(
                      onPressed: () {}, // 체크 버튼 클릭 시 동작 (현재 비어 있음)
                      icon: const Icon(
                        Icons.check_circle_outline_outlined,
                        color: Color(0xFFf9747d), // 아이콘 색상
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 0.015 * screenHeight, // 알림과 텍스트 사이의 여백
              ),
              const Text(
                "오늘은 혼술 어때?", // 메인 텍스트
                style: TextStyle(
                  fontSize: 20, // 텍스트 크기
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
                width: screenHeight * 0.35,
                height: screenHeight * 0.35,
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
              Text(
                user!.nickName, // 캐릭터 이름
                style: const TextStyle(
                  color: Colors.white, // 텍스트 색상
                  fontSize: 20, // 텍스트 크기
                  fontWeight: FontWeight.w800, // 텍스트 두께
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
                      width: 0.5 * screenWidth,
                      height: 0.025 * screenHeight,
                      child: const LinearProgressIndicator(
                        color: Color(0xFFf9747d), // 진행 바 색상
                        borderRadius:
                            BorderRadius.all(Radius.circular(20)), // 모서리 둥글게 설정
                        value: 0.7, // 진행률 (0.0에서 1.0 사이)
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.1, // 하단 아이콘 그룹과의 여백
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 아이콘 그룹을 좌우 끝에 배치
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: screenHeight * 0.01), // 좌측 여백
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
                                  BorderRadius.circular(10), // 모서리 둥글게 설정
                            ),
                            height: screenWidth * 0.13,
                            width: screenWidth * 0.13,
                            child: const Icon(
                              Icons.search, // 검색 아이콘
                              color: Colors.white, // 아이콘 색상
                            ),
                          ),
                        ),
                        const Text(
                          "나홀로어디", // 아이콘 하단의 설명 텍스트
                          style: TextStyle(
                              color: Colors.white, fontSize: 10), // 텍스트 색상
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenHeight * 0.01), // 좌우 여백
                    child: Column(
                      children: [
                        GestureDetector(
                          // 책 아이콘을 클릭할 수 있도록 GestureDetector 사용
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                              borderRadius:
                                  BorderRadius.circular(10), // 모서리 둥글게 설정
                            ),
                            height: screenWidth * 0.13,
                            width: screenWidth * 0.13,
                            child: const Icon(
                              Icons.menu_book_rounded, // 책 아이콘
                              color: Colors.white, // 아이콘 색상
                            ),
                          ),
                        ),
                        const Text(
                          "나홀로일지", // 아이콘 하단의 설명 텍스트
                          style: TextStyle(
                              color: Colors.white, fontSize: 10), // 텍스트 색상
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenHeight * 0.01), // 좌우 여백
                    child: Column(
                      children: [
                        GestureDetector(
                          // 홈 아이콘을 클릭할 수 있도록 GestureDetector 사용
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                              borderRadius:
                                  BorderRadius.circular(10), // 모서리 둥글게 설정
                            ),
                            height: screenWidth * 0.13,
                            width: screenWidth * 0.13,
                            child: const Icon(
                              Icons.home_filled, // 홈 아이콘
                              color: Colors.white, // 아이콘 색상
                            ),
                          ),
                        ),
                        const Text(
                          "홈", // 아이콘 하단의 설명 텍스트
                          style: TextStyle(
                              color: Colors.white, fontSize: 10), // 텍스트 색상
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenHeight * 0.01), // 좌우 여백
                    child: Column(
                      children: [
                        GestureDetector(
                          // 채팅 아이콘을 클릭할 수 있도록 GestureDetector 사용
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                              borderRadius:
                                  BorderRadius.circular(10), // 모서리 둥글게 설정
                            ),
                            height: screenWidth * 0.13,
                            width: screenWidth * 0.13,
                            child: const Icon(
                              Icons.chat, // 채팅 아이콘
                              color: Colors.white, // 아이콘 색상
                            ),
                          ),
                        ),
                        const Text(
                          "커뮤니티", // 아이콘 하단의 설명 텍스트
                          style: TextStyle(
                              color: Colors.white, fontSize: 10), // 텍스트 색상
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(right: screenHeight * 0.01), // 우측 여백
                    child: Column(
                      children: [
                        GestureDetector(
                          // 마이페이지 아이콘을 클릭할 수 있도록 GestureDetector 사용
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(0.3), // 배경을 검정색 투명도로 설정
                              borderRadius:
                                  BorderRadius.circular(10), // 모서리 둥글게 설정
                            ),
                            height: screenWidth * 0.13,
                            width: screenWidth * 0.13,
                            child: const Icon(
                              Icons.person, // 마이페이지 아이콘
                              color: Colors.white, // 아이콘 색상
                            ),
                          ),
                        ),
                        const Text(
                          "마이페이지", // 아이콘 하단의 설명 텍스트
                          style: TextStyle(
                              color: Colors.white, fontSize: 10), // 텍스트 색상
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
    );
  }
}
