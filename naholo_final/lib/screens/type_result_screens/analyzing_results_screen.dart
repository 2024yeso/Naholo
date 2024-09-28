import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/type_result_screens/character_explain_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/util.dart';
import 'package:o3d/o3d.dart';

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
        print("Animation value: ${_animationController.value}");

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
              builder: (context) => CharacterExplainScreen(
                    character: widget.character,
                  )),
        );
      }
    });

  final O3DController controller = O3DController(); // 3D 모델 컨트롤러

  final ValueNotifier<double> _value = ValueNotifier(0.0); // 애니메이션 진행률을 추적

  // 곡선 애니메이션 정의 (Bounce 효과 추가)
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.bounceIn,
  );

  // 회전 애니메이션 정의
  late final Animation<double> _turn1 = Tween(
    begin: 0.0, // 애니메이션 시작 시 회전 각도
    end: 2.0, // 애니메이션 종료 시 회전 각도 (2번 회전)
  ).animate(_curve);

  late final Animation<double> _turn2 = Tween(
    begin: 0.0, // 애니메이션 시작 시 회전 각도
    end: 3.0, // 애니메이션 종료 시 회전 각도 (2번 회전)
  ).animate(_animationController);

  // 상자 데코레이션 애니메이션 정의 (색상 및 모서리 반경 변경)
  late final Animation<Decoration> _decoration = DecorationTween(
          begin: BoxDecoration(
              color: darkpurpleColor, // 시작 색상
              borderRadius: BorderRadius.circular(100)), // 시작 모서리 반경
          end: BoxDecoration(
              color: darkpurpleColor, // 종료 색상
              borderRadius: BorderRadius.circular(150))) // 종료 모서리 반경
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
    var size = SizeUtil.getScreenSize(context);
    // 화면의 너비와 높이를 가져옵니다.

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
                image: AssetImage("assets/images/analsis_bg.png"),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.2, // 상단 여백
                ),
                const Text(
                  '결과를 분석중입니다...\n잠시만 기다려주세요',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상
                    fontSize: 15, // 텍스트 크기
                    fontWeight: FontWeight.w600, // 텍스트 두께
                  ),
                ),
                SizedBox(
                  height: size.height * 0.1, // 텍스트와 애니메이션 사이의 여백
                ),
                // 회전 애니메이션 적용
                Stack(
                  alignment: Alignment.center, // 중앙 정렬
                  children: [
                    // 반투명 원 테두리 추가
                    CustomPaint(
                      size: Size(size.width * 0.4, size.width * 0.4),
                      painter: CircularPathPainter(),
                    ),
                    // 큰 원 (기존의 DecoratedBoxTransition)
                    DecoratedBoxTransition(
                      decoration: _decoration, // 데코레이션 애니메이션 적용
                      child: SizedBox(
                        height: size.width * 0.75, // 상자의 높이
                        width: size.width * 0.75, // 상자의 너비
                        child: const Center(
                          child: Text(
                            "?",
                            style: TextStyle(
                              color: Colors.white, // 텍스트 색상
                              fontSize: 80, // 텍스트 크기
                              fontWeight: FontWeight.w600, // 텍스트 두께
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 작은 흰 원을 큰 원의 주위를 돌게 하는 애니메이션
                    RotationTransition(
                      turns: _turn2, // 회전 애니메이션
                      child: Transform.translate(
                        offset: Offset(0, -size.width * 0.45), // 큰 원의 경계선으로 이동
                        child: Container(
                          width: 15, // 작은 원의 크기
                          height: 15,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // 원 모양
                            color: Colors.white, // 흰색
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2), // 3D 모델 주변 패딩 설정
                      width: SizeScaler.scaleSize(context, 100),
                      height: SizeScaler.scaleSize(context, 100),
                      child: Card(
                        color: Colors.transparent, // 카드 배경 투명
                        elevation: 0, // 그림자 효과 제거
                        child: O3D(
                          disableTap: true, // 탭 동작 비활성화
                          disableZoom: true, // 줌 동작 비활성화
                          controller: controller, // 3D 모델 컨트롤러 사용
                          autoPlay: true, // 자동 재생 설정
                          src: 'assets/glbs/cat.glb', // 3D 모델 파일 경로
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: size.height * 0.04, // 애니메이션과 진행 바 사이의 여백
                ),
                // 애니메이션 진행률에 따라 업데이트되는 LinearProgressIndicator
                ValueListenableBuilder(
                  valueListenable: _value,
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        // 로켓과 진행 바를 Stack으로 감싸서 로켓의 위치를 설정합니다.
                        SizedBox(
                          height: size.width * 0.3,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: size.width * 0.1,
                                    ),
                                    LinearProgressIndicator(
                                      value: value, // 진행률을 설정 (0.0에서 1.0 사이)
                                      backgroundColor:
                                          Colors.white, // 진행 바의 배경색
                                      color: lightpurpleColor, // 진행 바의 색상
                                      minHeight: 25, // 진행 바의 높이
                                      borderRadius:
                                          BorderRadius.circular(20), // 모서리 둥글게
                                    ), // 진행률을 %로 표시
                                    Text(
                                      "${(value * 100).round()}%", // 소수점 없이 정수로 표시
                                      style: const TextStyle(
                                          fontSize: 20, // 텍스트 크기
                                          fontWeight: FontWeight.w600, // 텍스트 두께
                                          color: Colors.white), // 텍스트 색상
                                    ),
                                  ],
                                ),
                              ),
                              // 로켓 아이콘의 위치를 설정
                              Positioned(
                                left: (size.width * 0.05) +
                                    (value *
                                        (size.width * 0.9 - size.width * 0.1)),
                                top: 1,
                                child: const Icon(
                                  Icons.rocket,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircularPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 테두리를 그릴 원의 중심점과 반지름 설정
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 1.13;

    // 원 테두리의 페인트 설정
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5) // 반투명한 색상 설정
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // 선 두께

    // 원 테두리 그리기
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // 화면이 변경될 때마다 다시 그리지 않음
  }
}
