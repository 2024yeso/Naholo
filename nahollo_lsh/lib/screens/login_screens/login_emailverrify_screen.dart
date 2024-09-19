import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:nahollo/api/api.dart';
import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/login_screens/login_finish_screen.dart';
import 'package:nahollo/screens/main_screen.dart';
import 'package:nahollo/test_info.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class LoginEmailverrifyScreen extends StatefulWidget {
  Info info;
  LoginEmailverrifyScreen({super.key, required this.info});

  @override
  State<LoginEmailverrifyScreen> createState() =>
      _LoginEmailverrifyScreenState();
}

class _LoginEmailverrifyScreenState extends State<LoginEmailverrifyScreen> {
  bool _isEmailVerify = false;
  bool _isInfoSend = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(String id, String pw) async {
    // Provider를 미리 가져와서 저장
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 로그인 성공
    var res;
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/login/?user_id=$id&user_pw=$pw'),
    );

    if (response.statusCode == 200) {
      res = jsonDecode(utf8.decode(response.bodyBytes));

      // UserModel을 생성하여 provider에 저장
      UserModel user = UserModel(
        nickName: res["NICKNAME"],
        userCharacter: res["USER_CHARACTER"],
        lv: res["LV"],
        introduce: res["INTRODUCE"],
      );

      // provider에 유저 정보 저장
      userProvider.setUser(user);

      Fluttertoast.showToast(
        msg: res["message"],
      );
      print(
          "Login Success Response: ${res["NICKNAME"]}, ${res["USER_CHARACTER"]}, ${res["LV"]}, ${res["INTRODUCE"]}");
    } else {
      Fluttertoast.showToast(
        msg: "로그인 실패",
      );
      print(
          "Login Success Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  Future<void> addUser() async {
    //my sql DB에 정보 저장  회원가입
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/add_user/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "USER_ID": widget.info.userId,
        "USER_PW": widget.info.userPw,
        "NAME": widget.info.userName,
        "PHONE": "010-1234-5678",
        "BIRTH": widget.info.birth,
        "GENDER": widget.info.gender,
        "NICKNAME": widget.info.nickName,
        "USER_CHARACTER": "Hero",
        "LV": 1,
        "INTRODUCE": "Hello, I am a test user!",
        "IMAGE": 1
      }),
    );

    if (response.statusCode == 200) {
      print("Add User Response: ${utf8.decode(response.bodyBytes)}");
      _isInfoSend = true;
    } else {
      print(
          "Add User Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

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
        await addUser();
        await login(widget.info.userId, widget.info.userPw);
      } else {
        print('아직 이메일 인증이 완료되지 않았습니다.');
        Fluttertoast.showToast(msg: '아직 이메일 인증이 완료되지 않았습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = SizeUtil.getScreenWidth(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showExitDialog(context);
      },
      child: Scaffold(
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
                                builder: (context) => const LoginFinishScreen(),
                              ));
                        }
                      }
                    },
                    child: const Text('이메일 인증 완료'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
