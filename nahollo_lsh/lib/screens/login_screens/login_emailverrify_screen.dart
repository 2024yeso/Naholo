import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nahollo/screens/login_screens/nickname_setting_screen.dart';
import 'package:nahollo/test_info.dart';
import 'package:nahollo/util.dart';

class LoginEmailverrifyScreen extends StatefulWidget {
  Info info;
  LoginEmailverrifyScreen({super.key, required this.info});

  @override
  State<LoginEmailverrifyScreen> createState() =>
      _LoginEmailverrifyScreenState();
}

class _LoginEmailverrifyScreenState extends State<LoginEmailverrifyScreen> {
  bool _isEmailVerify = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 이메일 인증 여부 확인
  Future<void> checkEmailVerified() async {
    User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      // 이메일 인증 여부 확인
      await user.reload(); // Firebase에서 사용자 정보 새로고침
      user = _auth.currentUser; // 새로고침된 사용자 정보 반영

      if (user!.emailVerified) {
        print('이메일 인증이 완료되었습니다.');
        Fluttertoast.showToast(msg: '이메일 인증이 완료되었습니다.');
        _isEmailVerify = true;
      } else {
        print('아직 이메일 인증이 완료되지 않았습니다.');
        Fluttertoast.showToast(msg: '아직 이메일 인증이 완료되지 않았습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = SizeUtil.getScreenWidth(context);
    return Scaffold(
      body: Container(
        width: double.infinity, // 부모 위젯의 너비를 화면 전체로 설정
        height: double.infinity, // 부모 위젯의 높이를 화면 전체로 설정

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
                '이메일 인증을 완료한 뒤\n 아래 버튼을 눌러주세요!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: width * 0.2,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await checkEmailVerified();
                    if (_isEmailVerify) {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NicknameSettingScreen(info: widget.info),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('이메일 인증 완료'))
            ],
          ),
        ),
      ),
    );
  }
}
