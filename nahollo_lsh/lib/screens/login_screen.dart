import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/login_platform.dart';
import 'package:nahollo/screens/nickname_setting_screen.dart';
import 'package:nahollo/temporary_server.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');
      user_name = googleUser.displayName;
      user_email = googleUser.email;
      user_id = googleUser.id;

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
    }
  }

  void signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.google:
        // 추가
        await GoogleSignIn().signOut();
        break;
      case LoginPlatform.none:
        break;
    }

    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  void disconnect() async {
    await GoogleSignIn().disconnect();
    print('로그아웃됨!');

    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkpurpleColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/nahollo_logo.png',
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            const Text(
              'SNS로 빠른 회원가입',
              style: TextStyle(
                color: darkpurpleColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await signInWithGoogle();
                    if (_loginPlatform == LoginPlatform.google) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NicknameSettingScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                      child: Image.asset('assets/images/google_icon.png')),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            const Text(
              'OR',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            GestureDetector(
              onTap: () {
                disconnect();
              },
              child: Container(
                child: const Text(
                  "로그아웃",
                  style: TextStyle(
                    color: lightpurpleColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
