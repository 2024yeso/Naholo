import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/type_result_screens/character_creating_screen.dart';
import 'package:nahollo/screens/type_result_screens/typetest_logo_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class LoginWelcomeScreen extends StatefulWidget {
  const LoginWelcomeScreen({super.key});

  @override
  State<LoginWelcomeScreen> createState() => _LoginWelcomeScreenState();
}

class _LoginWelcomeScreenState extends State<LoginWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  String assignRandomCharacter() {
    // 6개의 캐릭터 리스트
    List<String> characters = [
      'hedgehog',
      'cat',
      'red_panda',
      'squid',
      'owl',
      'koala',
    ];

    // 랜덤 인덱스 생성 (0부터 5까지의 값)
    int randomIndex = Random().nextInt(characters.length);

    // 랜덤 캐릭터 선택
    String assignedCharacter = characters[randomIndex];

    print('선택된 캐릭터는: $assignedCharacter');
    return assignedCharacter;
  }

  void main() {
    assignRandomCharacter();
  }

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정 (5초 주기로 애니메이션 반복)
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // 첫 번째 색상 (보라색에서 흰색으로 전환)
    _colorAnimation1 = ColorTween(
      begin: const Color(0xffc078ff), // 보라색
      end: Colors.white, // 흰색
    ).animate(_controller);

    // 두 번째 색상 (흰색에서 보라색으로 전환)
    _colorAnimation2 = ColorTween(
      begin: Colors.white, // 흰색
      end: const Color(0xffc078ff), // 보라색
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    final size = MediaQuery.of(context).size;
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
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _colorAnimation1.value!,
                    _colorAnimation2.value!,
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeScaler.scaleSize(context, 25)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${user?.nickName}",
                                style: const TextStyle(
                                  color: Color(0xff7839cb),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                " 님",
                                style: TextStyle(
                                  color: Color(0xff7839cb),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        '나홀로 행성 가입을 축하합니다! 멋있는 이름이네요',
                        style: TextStyle(
                          color: Color(0xff16377e),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: SizeScaler.scaleSize(context, 36),
                      ),
                      Container(
                        width: SizeScaler.scaleSize(context, 117),
                        height: SizeScaler.scaleSize(context, 27),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff8BACFF),
                                Color(0xffD05AFF),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TypetestLogoScreen(), // 버튼을 누르면 TypetestlogoScreen으로 이동
                                ));
                          },
                          child: SizedBox(
                            width: size.width * 0.45,
                            child: const Center(
                              child: Text(
                                "나만의 캐릭터 만들기",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeScaler.scaleSize(context, 13),
                      ),
                      SizedBox(
                        width: SizeScaler.scaleSize(context, 117),
                        height: SizeScaler.scaleSize(context, 27),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkpurpleColor,
                          ),
                          onPressed: () {
                            var character = assignRandomCharacter();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CharacterCreatingScreen(
                                    character: character,
                                  ),
                                ));
                          },
                          child: SizedBox(
                            width: size.width * 0.45,
                            child: const Center(
                              child: Text(
                                "바로 시작하기",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
