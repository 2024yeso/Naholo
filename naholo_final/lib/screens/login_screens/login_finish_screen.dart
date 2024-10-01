import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/login_screens/login_welcome_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/util.dart';
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
              image: AssetImage('assets/images/login_finsh_bg.png'),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '로그인이 완료되었습니다',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeScaler.scaleSize(context, 14),
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
                ],
              ),
              SizedBox(
                height: size.height * 0.1,
              ),
              SvgPicture.asset(
                'assets/images/nahollo_logo_purple.svg', // 로컬에 저장된 SVG 파일 경로
                width: SizeScaler.scaleSize(context, 119),
                height: SizeScaler.scaleSize(context, 78),
              ),
              SizedBox(
                height: SizeScaler.scaleSize(context, 100),
              ),
              SizedBox(
                width: SizeScaler.scaleSize(context, 141),
                height: SizeScaler.scaleSize(context, 30),
                child: ElevatedButton(
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
                    width: SizeUtil.getScreenWidth(context) * 0.5,
                    child: Center(
                      child: Text(
                        "계속하기",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeScaler.scaleSize(context, 9)),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
