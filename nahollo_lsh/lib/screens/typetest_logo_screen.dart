import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/typetest_screen.dart';

class TypetestLogoScreen extends StatelessWidget {
  const TypetestLogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
// 화면의 너비와 높이를 가져옵니다.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: lightpurpleColor, // 배경색 설정
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.15, // 위쪽 여백 설정
            ),
            Padding(
              padding: const EdgeInsets.all(30), // 전체 패딩 설정
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 좌우 끝에 위젯 배치
                children: [
                  const Text(
                    "나의 혼.놀 \n유형 테스트",
                    style: TextStyle(
                      color: darkpurpleColor, // 텍스트 색상
                      fontSize: 40, // 텍스트 크기
                      fontWeight: FontWeight.w600, // 텍스트 두께
                    ),
                  ),
                  Image.asset(
                    'assets/images/roket_logo.png', // 로켓 로고 이미지 경로
                    scale: 0.5, // 이미지 크기 조정
                  ),
                ],
              ),
            ),
            const Text(
              '넓은 우주 속 나홀로 삶을 즐기는 당신! \n나의 혼자 놀기 유형은 어떤 동물과 비슷할까?',
              style: TextStyle(
                color: darkpurpleColor, // 텍스트 색상
                fontSize: 18, // 텍스트 크기
                fontWeight: FontWeight.w500, // 텍스트 두께
              ),
            ),
            SizedBox(
              height: screenHeight * 0.4, // 텍스트와 버튼 사이의 여백 설정
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TypetestScreen(), // 버튼을 누르면 TypetestScreen으로 이동
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkpurpleColor, // 버튼 배경색 설정
                padding:
                    const EdgeInsets.symmetric(vertical: 15), // 버튼 내부 패딩 설정
              ),
              child: SizedBox(
                width: screenWidth * 0.8, // 버튼의 너비 설정
                child: const Center(
                  child: Text(
                    '테스트 시작!', // 버튼의 텍스트
                    style: TextStyle(
                      color: lightpurpleColor, // 텍스트 색상 설정
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
