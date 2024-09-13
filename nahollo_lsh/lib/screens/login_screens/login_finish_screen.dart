import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/mediaqueryutil.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/login_screens/login_welcome_screen.dart';
import 'package:provider/provider.dart';

class LoginFinishScreen extends StatefulWidget {
  const LoginFinishScreen({super.key});

  @override
  State<LoginFinishScreen> createState() => _LoginFinishScreenState();
}

class _LoginFinishScreenState extends State<LoginFinishScreen> {
  @override
  Widget build(BuildContext context) {
    // provider에서 유저 정보를 가져옴
    final user = Provider.of<UserProvider>(context).user;

    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/nickname_bg.png'),
            fit: BoxFit.cover),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '로그인이 완료되었습니다',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Text(
              "${user?.nickName}님, 환영합니다!",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            SvgPicture.asset(
              'assets/images/nahollo_logo_purple.svg', // 로컬에 저장된 SVG 파일 경로
              width: MediaQueryUtil.getScreenWidth(context) * 0.5,
              height: MediaQueryUtil.getScreenWidth(context) * 0.5,
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginWelcomeScreen(), // 버튼을 누르면 LoginWelcomeScreen으로 이동
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: lightpurpleColor,
                foregroundColor: darkpurpleColor,
              ),
              child: SizedBox(
                width: MediaQueryUtil.getScreenWidth(context) * 0.5,
                child: const Center(  
                  child: Text(
                    "계속하기",
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
