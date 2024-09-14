import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/type_result_screens/red_panda_creating_screen.dart';
import 'package:nahollo/screens/typetest_logo_screen.dart';
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
    List<String> characters = ['고슴도치', '고양이', '래서판다', '오징어', '올빼미', '코알라'];

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
    return Scaffold(
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${user?.nickName} 님",
                          style: const TextStyle(
                            color: darkpurpleColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    const Text(
                      '나홀로 행성 가입을 축하합니다! 멋있는 이름이네요',
                      style: TextStyle(
                        color: Color(0xff16377e),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff9372ff),
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
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkpurpleColor,
                      ),
                      onPressed: () {
                        var character = assignRandomCharacter();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RedPandaCreatingScreen(
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
