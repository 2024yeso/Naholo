import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/type_result_screens/red_panda_screen.dart';

class AnalyzingResultsScreen extends StatefulWidget {
  final String character;

  const AnalyzingResultsScreen({super.key, required this.character});

  @override
  State<AnalyzingResultsScreen> createState() => _AnalyzingResultsScreenState();
}

class _AnalyzingResultsScreenState extends State<AnalyzingResultsScreen>
    with SingleTickerProviderStateMixin {
  // 애니메이션 컨트롤러를 생성하고 초기화

  late final AnimationController _animationController = AnimationController(
    vsync: this, // 애니메이션을 효율적으로 관리하기 위해 vsync를 제공
    duration: const Duration(seconds: 5), // 애니메이션 지속 시간
  )
    ..addListener(
      () {
        // 애니메이션이 진행될 때마다 ValueNotifier의 값을 업데이트
        _value.value = _animationController.value;
      },
    )
    ..addStatusListener((status) {
      // 애니메이션이 완료되었을 때
      if (status == AnimationStatus.completed) {
        // 애니메이션이 완료되면 새로운 화면으로 전환
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RedPandaScreen(
                    character: widget.character,
                  )),
        );
      }
    });

  final ValueNotifier<double> _value = ValueNotifier(0.0); // 애니메이션 진행률을 추적

  // 곡선 애니메이션 정의 (Bounce 효과 추가)
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.bounceIn,
  );

  // 회전 애니메이션 정의
  late final Animation<double> _turn = Tween(
    begin: 0.0, // 애니메이션 시작 시 회전 각도
    end: 2.0, // 애니메이션 종료 시 회전 각도 (2번 회전)
  ).animate(_curve);

  // 상자 데코레이션 애니메이션 정의 (색상 및 모서리 반경 변경)
  late final Animation<Decoration> _decoration = DecorationTween(
          begin: BoxDecoration(
              color: lightpurpleColor, // 시작 색상
              borderRadius: BorderRadius.circular(150)), // 시작 모서리 반경
          end: BoxDecoration(
              color: darkpurpleColor, // 종료 색상
              borderRadius: BorderRadius.circular(200))) // 종료 모서리 반경
      .animate(_curve);

  @override
  void initState() {
    super.initState();
    _animationController.forward(); // 화면 생성 시 애니메이션 시작
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져옵니다.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: lightpurpleColor, // 화면 배경색
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.15, // 상단 여백
            ),
            const Text(
              '결과를 분석중입니다...\n잠시만 기다려주세요',
              style: TextStyle(
                color: darkpurpleColor, // 텍스트 색상
                fontSize: 25, // 텍스트 크기
                fontWeight: FontWeight.w600, // 텍스트 두께
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05, // 텍스트와 애니메이션 사이의 여백
            ),
            // 회전 애니메이션 적용
            RotationTransition(
              turns: _turn, // 회전 애니메이션 적용
              child: DecoratedBoxTransition(
                decoration: _decoration, // 데코레이션 애니메이션 적용
                child: const SizedBox(
                  height: 300, // 상자의 높이
                  width: 300, // 상자의 너비
                  child: Center(
                    child: Text(
                      "?",
                      style: TextStyle(
                          color: Colors.white, // 텍스트 색상
                          fontSize: 80, // 텍스트 크기
                          fontWeight: FontWeight.w600), // 텍스트 두께
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05, // 애니메이션과 진행 바 사이의 여백
            ),
            // 애니메이션 진행률에 따라 업데이트되는 LinearProgressIndicator
            ValueListenableBuilder(
              valueListenable: _value,
              builder: (context, value, child) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LinearProgressIndicator(
                        value: value, // 진행률을 설정 (0.0에서 1.0 사이)
                        backgroundColor: Colors.white, // 진행 바의 배경색
                        color: darkpurpleColor, // 진행 바의 색상
                        minHeight: 25, // 진행 바의 높이
                        borderRadius: BorderRadius.circular(20), // 모서리 둥글게
                      ),
                    ),
                    // 진행률을 %로 표시
                    Text(
                      "${(value * 100).round()}%", // 소수점 없이 정수로 표시
                      style: const TextStyle(
                          fontSize: 20, // 텍스트 크기
                          fontWeight: FontWeight.w600, // 텍스트 두께
                          color: darkpurpleColor), // 텍스트 색상
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
