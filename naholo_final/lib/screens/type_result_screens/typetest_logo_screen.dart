import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/type_result_screens/typetest_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/util.dart';

class TypetestLogoScreen extends StatelessWidget {
  const TypetestLogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage('assets/images/test_bg.png'),
                fit: BoxFit.cover),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeScaler.scaleSize(context, 23)),
            child: Column(
              children: [
                SizedBox(
                  height: SizeScaler.scaleSize(context, 77), // 위쪽 여백 설정
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // 좌우 끝에 위젯 배치
                  children: [
                    Text(
                      "나의 혼.놀 \n유형 테스트",
                      style: TextStyle(
                        color: Colors.white, // 텍스트 색상
                        fontSize: SizeScaler.scaleSize(context, 18), // 텍스트 크기
                        fontWeight: FontWeight.w600, // 텍스트 두께
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/images/rocket_logo.svg', // 로컬에 저장된 SVG 파일 경로
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                    ),
                    SizedBox(
                      width: SizeScaler.scaleSize(context, 8),
                    )
                  ],
                ),
                SizedBox(
                  height: SizeScaler.scaleSize(context, 29),
                ),
                const Text(
                  '넓은 우주 속 나홀로 삶을 즐기는 당신!\n나의 혼자 놀기 유형은 어떤 동물과 비슷할까?',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상
                    fontSize: 15, // 텍스트 크기
                    fontWeight: FontWeight.w500, // 텍스트 두께
                  ),
                ),
                SizedBox(
                  height:
                      SizeScaler.scaleSize(context, 155), // 텍스트와 버튼 사이의 여백 설정
                ),
                SizedBox(
                  width: SizeScaler.scaleSize(context, 174),
                  height: SizeScaler.scaleSize(context, 30), // 버튼의 너비 설정
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TypetestScreen(), // 버튼을 누르면 TypetestScreen으로 이동
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightpurpleColor, // 버튼 배경색 설정
                      padding: const EdgeInsets.symmetric(
                          vertical: 15), // 버튼 내부 패딩 설정
                    ),
                    child: SizedBox(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeScaler.scaleSize(context, 6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(' '),
                            Text(
                              '테스트 시작!', // 버튼의 텍스트
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 10),
                                color: Colors.white, // 텍스트 색상 설정
                              ),
                            ),
                            const Icon(
                              Icons.arrow_right_alt_rounded,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
