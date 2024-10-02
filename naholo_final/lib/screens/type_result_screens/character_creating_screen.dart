import 'package:flutter/material.dart';

import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/main_screen.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class CharacterCreatingScreen extends StatefulWidget {
  String character;

  CharacterCreatingScreen({super.key, required this.character});

  @override
  State<CharacterCreatingScreen> createState() =>
      _CharacterCreatingScreenState();
}

class _CharacterCreatingScreenState extends State<CharacterCreatingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse(); // 애니메이션 반전
        } else if (status == AnimationStatus.dismissed) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.updateUserCharacter(widget.character);
          // reverse 애니메이션이 끝난 후 다음 화면으로 이동
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const MainScreen()), // 이동할 새로운 화면
            (Route<dynamic> route) => false, // 모든 이전 라우트를 삭제
          );
        }
      },
    );

  String getKoreanSaid(String character) {
    if (character == "red_panda") {
      return "혼자 노는 것도 잘하고\n같이 노는 것도 좋아";
    } else if (character == "squid") {
      return "혼자있는 게 좋지만 가끔 외로워";
    } else if (character == "cat") {
      return "다꺼져 말걸지마";
    } else if (character == "koala") {
      return "모든 게 귀찮아! 그냥 나혼자 할래";
    } else if (character == "owl") {
      return "고독을 즐긴다";
    } else {
      return "혼자가 좋지만\n사실은 같이 노는 것도 좋아";
    }
  }

  String changeToKoreanName(String English) {
    switch (English) {
      case 'squid':
        return '오징어';
      case 'red_panda':
        return '래서판다';
      case 'owl':
        return '올빼미';
      case 'koala':
        return '코알라';
      case 'hedgehog':
        return '고슴도치';
      case 'cat':
        return '고양이';
      default:
        return '알 수 없는 동물'; // 정의되지 않은 경우의 기본값
    }
  }

  late final Animation<double> _animation =
      Tween<double>(begin: 0.0, end: 0.8).animate(_curve);

  late final CurvedAnimation _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                image: AssetImage('assets/images/character_creating_bg.png'),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.2,
                ),
                Text(
                  getKoreanSaid(widget.character),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Text(
                  changeToKoreanName(widget.character),
                  style: const TextStyle(
                    color: Color(0xFFf6841b),
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.yellow.withOpacity(0.6), // 중심부
                            Colors.yellow.withOpacity(0.3),
                            Colors.yellow.withOpacity(0.1), // 바깥쪽은 거의 투명
                            Colors.yellow.withOpacity(0.05),
                            Colors.transparent, // 완전히 투명 (빛의 끝부분)
                          ], //처음에 무슨 색을 가질지 설정, 먼저 나온 색이 중심색 나중에 나온 색이 끝부분 색,
                          stops: [
                            _animation.value * 0.2, // 중심부는 고정
                            _animation.value * 0.5, // 중간 부분
                            _animation.value * 0.7, // 바깥쪽 부분
                            _animation.value * 0.9,
                            _animation.value * 1.0, // 완전히 투명해지는 부분
                          ], //색이 어디서 변할지 위치 선정 0.0이 중심 1.0이 끝부분
                          center: Alignment.center,
                          radius: _animation.value,
                        ),
                      ),
                      child:
                          Image.asset('assets/images/${widget.character}.png'),
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
