import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/typetest_logo_screen.dart';
import 'package:nahollo/temporary_server.dart';

class WelcomeScreen extends StatelessWidget {
  final nickname = user_nickname;
  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: darkpurpleColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$nickname 님",
              style: const TextStyle(
                color: lightpurpleColor,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            const Text(
              '나홀로 행성 가입을 축하합니다!\n멋있는 이름이네요',
              style: TextStyle(
                color: lightpurpleColor,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: lightpurpleColor,
                foregroundColor: darkpurpleColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TypetestLogoScreen(), // 버튼을 누르면 TypetestScreen으로 이동
                    ));
              },
              child: const Text(
                "나만의 캐릭터 만들기",
              ),
            )
          ],
        ),
      ),
    );
  }
}
