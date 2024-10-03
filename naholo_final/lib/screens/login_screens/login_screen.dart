import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/login_platform.dart';
import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/providers/emailVerify_static.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/login_screens/local_signup_screen.dart';
import 'package:nahollo/screens/login_screens/nickname_setting_screen.dart';
import 'package:nahollo/screens/main_screen.dart';

import 'package:http/http.dart' as http;
import 'package:nahollo/api/api.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/test_info.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var infoLogin = Info();
  LoginPlatform _loginPlatform = LoginPlatform.none;
  bool _isObscure = true; // 비밀번호 가시성 여부를 저장하는 변수
  var isLoginSuccess = false;

  // TextEditingController를 생성해서 입력한 값을 제어
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');
      var naholloGoogle = "${googleUser.email}.google";
      try {
        var response = await http.get(
          Uri.parse("${Api.checkId}?user_id=${googleUser.email}.google"),
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print("중복 ID 여부: ${data['available']}");
          if (data["available"] == false) {
            //signup
            //false가 원래 아이디가 없는거
            setState(() {
              infoLogin.userName = googleUser.displayName; //그냥 계정이름
              infoLogin.userId =
                  naholloGoogle; // 나홀로 버전 구글 이메일 --> 원래 이메일에 .google이 붙음
              infoLogin.userPw = googleUser.id; // 고유 아이디
              EmailVerifyStatic.needEmailVerify = false;
              _loginPlatform = LoginPlatform.google;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NicknameSettingScreen(info: infoLogin),
                ),
              );
            });
          } else {
            login(naholloGoogle, googleUser.id); // 로그인
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

  Future<void> login(String id, String pw) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final response = await http.get(
      Uri.parse('${Api.baseUrl}/login/?user_id=$id&user_pw=$pw'),
    );

    if (response.statusCode == 200) {
      var res = jsonDecode(utf8.decode(response.bodyBytes));

      UserModel user = UserModel(
        userId: res['user_id'],
        nickName: res["nickname"],
        userCharacter: res["userCharacter"],
        lv: res["lv"],
        introduce: res["introduce"],
        exp: res["exp"],
      );

      userProvider.setUser(user);

      Fluttertoast.showToast(msg: res["message"]);

      if (context.mounted) {
        FocusScope.of(context).unfocus();
        await Future.delayed(const Duration(milliseconds: 250));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } else {
      Fluttertoast.showToast(msg: "로그인 실패");
      print(
          "Login Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage('assets/images/light_purple_bg.png'),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SizeScaler.scaleSize(context, 25),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: SizeScaler.scaleSize(context, 59),
                    ),
                    SvgPicture.asset(
                      'assets/images/nahollo_logo_human_white.svg',
                      width: SizeScaler.scaleSize(context, 50),
                      height: SizeScaler.scaleSize(context, 50),
                    ),
                    SvgPicture.asset(
                      'assets/images/nahollo_logo_name_white.svg',
                      width: SizeScaler.scaleSize(context, 52.46),
                      height: SizeScaler.scaleSize(context, 9.07),
                    ),
                    SizedBox(
                      height: SizeScaler.scaleSize(context, 37),
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
                      width: SizeScaler.scaleSize(context, 147),
                      height: SizeScaler.scaleSize(context, 26),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        textAlign: TextAlign.start,
                        controller: _idController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.black,
                            size: SizeScaler.scaleSize(context, 10),
                          ),
                          hintText: '아이디 입력',
                          hintStyle: TextStyle(
                              color: const Color(0xff6155a5),
                              fontSize: SizeScaler.scaleSize(context, 8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: SizeScaler.scaleSize(context, 7.5),
                              horizontal: SizeScaler.scaleSize(
                                  context, 5)), // 수직 패딩을 0으로 설정
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: SizeScaler.scaleSize(context, 9)),

                    // 비밀번호 입력창
                    Container(
                      width: SizeScaler.scaleSize(context, 147),
                      height: SizeScaler.scaleSize(context, 26),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        textAlign: TextAlign.start,
                        controller: _pwController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.black,
                              size: SizeScaler.scaleSize(context, 10),
                            ),
                            hintText: '비밀번호 입력',
                            hintStyle: TextStyle(
                                color: const Color(0xff6155a5),
                                fontSize: SizeScaler.scaleSize(context, 8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: SizeScaler.scaleSize(context, 7.5),
                              horizontal: SizeScaler.scaleSize(context, 5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                size: SizeScaler.scaleSize(context, 10),
                                _isObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            )),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: SizeScaler.scaleSize(context, 13),
                    ),

                    // 아이디 찾기, 비밀번호 찾기, 회원가입
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: SizeScaler.scaleSize(context, 25),
                        ),
                        const Text(
                          '아이디 찾기',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const Text(
                          "|",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const Text(
                          '비밀번호 찾기',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        const Text(
                          "|",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LocalSignupScreen()),
                            );
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                        SizedBox(
                          width: SizeScaler.scaleSize(context, 25),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeScaler.scaleSize(context, 17),
                    ),

                    // 로그인 버튼
                    Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black12, // 투명도 26%로 설정 (0.0에서 1.0 사이의 값 사용 가능)
                            offset: Offset(1, 1), // 그림자의 위치
                            blurRadius: 20, // 블러 정도
                            spreadRadius: 0.5, // 그림자의 퍼짐 정도
                          ),
                        ],
                      ),
                      width: SizeScaler.scaleSize(context, 117),
                      height: SizeScaler.scaleSize(context, 27),
                      child: ElevatedButton(
                        onPressed: () {
                          login(
                            _idController.text.trim(),
                            _pwController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 버튼 색
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          '로그인',
                          style: TextStyle(
                              color: darkpurpleColor,
                              fontSize: SizeScaler.scaleSize(context, 9)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeScaler.scaleSize(context, 30),
                    ),
                    Text(
                      'SNS로 빠른 회원가입',
                      style: TextStyle(
                        fontSize: SizeScaler.scaleSize(context, 6),
                        color: darkpurpleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: SizeScaler.scaleSize(context, 17),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            signInWithGoogle();
                            if (isLoginSuccess) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainScreen()));
                            }
                          },
                          child: Container(
                            child: SvgPicture.asset(
                              'assets/images/google_icon.svg',
                              width: SizeScaler.scaleSize(context, 25),
                              height: SizeScaler.scaleSize(context, 25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
