import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/login_platform.dart';
import 'package:nahollo/screens/login_screens/local_signup_screen.dart';
import 'package:nahollo/screens/login_screens/nickname_setting_screen.dart';
import 'package:nahollo/temporary_server.dart';
import 'package:http/http.dart' as http;
import 'package:nahollo/api/api.dart';
import 'package:nahollo/test_info.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var infoLogin = Info();
  LoginPlatform _loginPlatform = LoginPlatform.none;
  var isIdExist = false;

  // TextEditingController를 생성해서 입력한 값을 제어
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> checkId() async {
    // 중복 ID 확인 테스트
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');
      try {
        var response = await http.get(
          Uri.parse("${Api.checkId}?user_id=${googleUser.email}"),
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print("중복 ID 여부: ${data['available']}");
          if (data["available"] == false) {
            setState(() {
              isIdExist = false;
              infoLogin.userName = googleUser.displayName; //그냥 계정이름
              infoLogin.userId = googleUser.email; // 이메일
              infoLogin.userPw = googleUser.id; // 고유 아이디
              _loginPlatform = LoginPlatform.google;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NicknameSettingScreen(info: infoLogin),
                ),
              );
            });
          } else {
            isIdExist = true;
            // 이미 이메일이 등록된 경우, 로그인 차단
            await GoogleSignIn().disconnect();
            Fluttertoast.showToast(msg: "해당 이메일은 이미 아이디로 등록되어 있습니다.");
          }
        }
      } catch (e) {
        print("Error: $e");
      }
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

  Future<void> testLoginSuccess() async {
    // 로그인 성공 테스트
    var res;
    final response = await http.get(
      Uri.parse(
          '${Api.baseUrl}/login/?user_id=${_idController.text.trim()}&user_pw=${_pwController.text.trim()}'),
    );

    if (response.statusCode == 200) {
      res = jsonDecode(utf8.decode(response.bodyBytes));
      print(
          "Login Success Response: ${res["NICKNAME"]}, ${res["USER_CHARACTER"]}, ${res["LV"]}, ${res["INTRODUCE"]}");
    } else {
      print(
          "Login Success Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkpurpleColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/nahollo_logo.png',
                width: size.width * 0.4,
                height: size.width * 0.4,
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
                    onTap: () {
                      signInWithGoogle();
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
              /* GestureDetector(
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
                ), */
              // 아이디 입력창
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    hintText: '아이디 입력',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // 비밀번호 입력창
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _pwController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    suffixIcon: Icon(Icons.visibility_off, color: Colors.white),
                    hintText: '비밀번호 입력',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),

              // 아이디 찾기, 비밀번호 찾기, 회원가입
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '아이디 찾기',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Text(
                    '비밀번호 찾기',
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LocalSignupScreen()),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 로그인 버튼
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 버튼 색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(color: Color(0xFF9B75E8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
